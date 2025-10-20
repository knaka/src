// timer
package main

import (
	"bufio"
	"context"
	"fmt"
	"io"
	"log"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/spf13/pflag"
	"golang.org/x/term"
)

var appID = "timer"

type entryParams struct {
	exeName    string
	stdin      io.Reader
	stdout     io.Writer
	stderr     io.Writer
	isTerminal bool

	verbose bool
	timeout int
}

// TimerConfig holds configuration for the timer
type TimerConfig struct {
	Interval   time.Duration
	TimeFormat string
	BufferSize int
}

// DefaultTimerConfig returns a default timer configuration
func DefaultTimerConfig() TimerConfig {
	return TimerConfig{
		Interval:   1 * time.Second,
		TimeFormat: time.RFC3339,
		BufferSize: 10,
	}
}

// NewTimer creates a new timer with the given configuration
func NewTimer(ctx context.Context, config TimerConfig) <-chan string {
	timeStrCh := make(chan string, config.BufferSize)

	go func() {
		defer close(timeStrCh)
		ticker := time.NewTicker(config.Interval)
		defer ticker.Stop()

		for {
			select {
			case <-ctx.Done():
				return
			case <-ticker.C:
				timeStr := time.Now().Format(config.TimeFormat)
				select {
				case timeStrCh <- timeStr:
					// Successfully sent
				case <-ctx.Done():
					// Context cancelled while trying to send
					return
				}
			}
		}
	}()

	return timeStrCh
}

// timerEntry is the entry point.
func timerEntry(_ []string, params *entryParams) (err error) {
	ctx := context.Background()
	ctx, cancel := context.WithTimeout(ctx, time.Duration(params.timeout)*time.Second)
	defer cancel()

	// Set up signal handling for graceful shutdown
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
	go func() {
		<-sigCh
		cancel()
	}()

	// Create timer with default configuration
	timeStrCh := NewTimer(ctx, DefaultTimerConfig())

	// Start input monitoring
	go (func() {
		scanner := bufio.NewScanner(params.stdin)
		for scanner.Scan() {
			// Cancel when Enter is pressed
			cancel()
			return
		}
	})()

	fmt.Fprintf(params.stderr, "Timer started. Press Enter or Ctrl+C to stop.\n")

	for timeStr := range timeStrCh {
		fmt.Fprintln(params.stdout, timeStr)
	}

	// Determine the cause of cancellation
	ctxErr := ctx.Err()
	switch ctxErr {
	case context.DeadlineExceeded:
		fmt.Fprintf(params.stderr, "Timer stopped (timeout after %d seconds).\n", params.timeout)
	case context.Canceled:
		fmt.Fprintf(params.stderr, "Timer stopped (interrupted).\n")
	default:
		if ctxErr != nil {
			return fmt.Errorf("unknown cause %v", ctxErr)
		}
	}
	return
}

func showUsage(flags *pflag.FlagSet, stderr io.Writer) {
	fmt.Fprintf(stderr, `Usage: %s [options] [arg...]

Options:
`, appID)
	flags.SetOutput(stderr)
	flags.PrintDefaults()
}

func main() {
	params := entryParams{
		exeName: appID,
		stdin:   os.Stdin,
		stdout:  os.Stdout,
		stderr:  os.Stderr,
	}
	if !term.IsTerminal(int(os.Stdin.Fd())) {
		params.stdin = bufio.NewReader(os.Stdin)
	}
	if term.IsTerminal(int(os.Stdout.Fd())) {
		params.isTerminal = true
	} else {
		bufStdout := bufio.NewWriter(os.Stdout)
		defer bufStdout.Flush()
		params.stdout = bufStdout
	}
	flags := pflag.NewFlagSet(appID, pflag.PanicOnError)
	var shouldPrintHelp bool
	flags.BoolVarP(&shouldPrintHelp, "help", "h", false, "Show help")

	flags.BoolVarP(&params.verbose, "verbose", "v", false, "verbosity")
	flags.IntVarP(&params.timeout, "timeout", "t", 30, "timeout in seconds")

	flags.Parse(os.Args[1:])
	if shouldPrintHelp {
		showUsage(flags, os.Stderr)
		return
	}
	err := timerEntry(flags.Args(), &params)
	if err != nil {
		log.Fatalf("%s: %v\n", appID, err)
	}
}
