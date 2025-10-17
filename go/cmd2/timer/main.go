// Timer.
package main

import (
	"bufio"
	"context"
	"fmt"
	"io"
	"log"
	"os"
	"time"

	"github.com/spf13/pflag"
)

var appID = ""

const timerTimeoutSeconds = 10

func showUsage(cmdln *pflag.FlagSet, stderr io.Writer) {
	fmt.Fprintf(os.Stderr, "Usage: %s [options] [file...]\n", appID)
	cmdln.SetOutput(stderr)
	cmdln.PrintDefaults()
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
	timeCh := make(chan string, config.BufferSize)

	go func() {
		defer close(timeCh)
		ticker := time.NewTicker(config.Interval)
		defer ticker.Stop()

		for {
			select {
			case <-ctx.Done():
				return
			case <-ticker.C:
				timeStr := time.Now().Format(config.TimeFormat)
				select {
				case timeCh <- timeStr:
					// Successfully sent
				case <-ctx.Done():
					// Context cancelled while trying to send
					return
				}
			}
		}
	}()

	return timeCh
}

// timerEntry is the entrypoint.
func timerEntry(args []string) (err error) {
	flags := pflag.NewFlagSet(appID, pflag.ContinueOnError)
	var shouldPrintHelp bool
	flags.BoolVarP(&shouldPrintHelp, "help", "h", false, "Show help")
	err = flags.Parse(args)
	if err != nil {
		return
	}
	args = flags.Args()
	if shouldPrintHelp {
		showUsage(flags, os.Stderr)
		return
	}

	ctx := context.Background()
	ctx, cancel := context.WithTimeout(ctx, timerTimeoutSeconds*time.Second)
	defer cancel()

	// Create timer with default configuration
	timerConfig := DefaultTimerConfig()
	timeStrCh := NewTimer(ctx, timerConfig)

	// Start input monitoring
	go (func() {
		scanner := bufio.NewScanner(os.Stdin)
		for scanner.Scan() {
			// Cancel when Enter is pressed
			cancel()
			return
		}
	})()

	fmt.Fprintf(os.Stderr, "Timer started. Press Enter to stop.\n")

loop:
	for {
		select {
		case <-ctx.Done():
			break loop
		case timeStr, ok := <-timeStrCh:
			if !ok {
				// Channel closed
				break loop
			}
			// Print time string to stdout
			fmt.Println(timeStr)
		}
	}

	// Determine the cause of cancellation
	ctxErr := ctx.Err()
	switch ctxErr {
	case context.DeadlineExceeded:
		fmt.Fprintf(os.Stderr, "Timer stopped (timeout after %d seconds).\n", timerTimeoutSeconds)
	case context.Canceled:
		fmt.Fprintf(os.Stderr, "Timer stopped (Enter pressed).\n")
	default:
		err = fmt.Errorf("unknown cause %v", ctxErr)
	}
	return
}

func main() {
	err := timerEntry(os.Args[1:])
	if err != nil {
		log.Fatalf("%s: %v\n", appID, err)
	}
}
