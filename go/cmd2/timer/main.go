// Timer.
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
)

var appID = "timer"

type entryParams struct {
	exeName string
	stdin   io.Reader
	stdout  io.Writer
	stderr  io.Writer
}

func showUsage(flags *pflag.FlagSet, stderr io.Writer) {
	fmt.Fprintf(stderr, "Usage: %s [options] [arg...]\n", appID)
	flags.SetOutput(stderr)
	flags.PrintDefaults()
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

// timerEntry is the entrypoint.
func timerEntry(args []string, params *entryParams) (err error) {
	flags := pflag.NewFlagSet(appID, pflag.ContinueOnError)
	var shouldPrintHelp bool
	flags.BoolVarP(&shouldPrintHelp, "help", "h", false, "Show help")
	var timeoutSeconds int
	flags.IntVarP(&timeoutSeconds, "timeout", "t", 30, "Timeout in seconds")
	err = flags.Parse(args)
	if err != nil {
		return
	}
	args = flags.Args()
	if shouldPrintHelp {
		showUsage(flags, params.stderr)
		return
	}

	ctx := context.Background()
	ctx, cancel := context.WithTimeout(ctx, time.Duration(timeoutSeconds)*time.Second)
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
		fmt.Fprintf(params.stderr, "Timer stopped (timeout after %d seconds).\n", timeoutSeconds)
	case context.Canceled:
		fmt.Fprintf(params.stderr, "Timer stopped (interrupted).\n")
	default:
		if ctxErr != nil {
			return fmt.Errorf("unknown cause %v", ctxErr)
		}
	}
	return
}

func main() {
	err := timerEntry(os.Args[1:], &entryParams{exeName: os.Args[0], stdin: os.Stdin, stdout: os.Stdout, stderr: os.Stderr})
	if err != nil {
		log.Fatalf("%s: %v\n", appID, err)
	}
}
