// Timer example.
package main

import (
	"bufio"
	"context"
	"fmt"
	"io"
	"log"
	"os"
	"os/signal"
	"sync"
	"syscall"
	"time"

	"github.com/spf13/pflag"
	"golang.org/x/term"
)

var appID = "timer"

type timerParams struct {
	exeName    string
	stdin      io.Reader
	stdout     io.Writer
	stderr     io.Writer
	isTerminal bool
	args       []string

	verbose bool
	timeout int
	num     int
}

// runTicker creates a new timer with the given configuration
func runTicker(
	ctx context.Context,
	callback func(string),
) {
	ticker := time.NewTicker(1 * time.Second)
	defer ticker.Stop()
	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			timeStr := time.Now().Format(time.RFC3339)
			if callback != nil {
				callback(timeStr)
			}
		}
	}
}

// timerEntry is the entry point.
func timerEntry(params *timerParams) (err error) {
	if params.num <= 0 {
		return
	}
	var ctx0 context.Context
	var cancels []context.CancelFunc
	var wg sync.WaitGroup
	for i := range params.num {
		ctx, cancel := context.WithTimeout(context.Background(), time.Duration(params.timeout)*time.Second)
		if ctx0 == nil {
			ctx0 = ctx
		}
		cancels = append(cancels, cancel)
		wg.Add(1)
		go func() {
			defer wg.Done()
			runTicker(ctx, func(timeStr string) {
				fmt.Fprintf(params.stdout, "Timer %d ticked: %s\n", i, timeStr)
			})
		}()
	}
	cancelAll := func() {
		for _, cancel := range cancels {
			cancel()
		}
	}
	defer cancelAll()

	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, os.Interrupt, syscall.SIGINT, syscall.SIGTERM)
	go (func() {
		<-sigCh
		cancelAll()
	})()

	go (func() {
		for bufio.NewScanner(params.stdin).Scan() {
			cancelAll()
			break
		}
	})()

	wg.Wait()

	// Determine the cause of cancellation
	ctxErr := ctx0.Err()
	switch ctxErr {
	case nil:
	case context.DeadlineExceeded:
		fmt.Fprintf(params.stderr, "Timer stopped (timeout after %d seconds).\n", params.timeout)
	case context.Canceled:
		fmt.Fprintf(params.stderr, "Timer stopped (interrupted).\n")
	default:
		return fmt.Errorf("unknown cause %v", ctxErr)
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
	params := timerParams{
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
	flags.IntVarP(&params.num, "num", "n", 1, "number of timer")

	flags.Parse(os.Args[1:])
	params.args = flags.Args()
	if shouldPrintHelp {
		showUsage(flags, os.Stderr)
		return
	}
	err := timerEntry(&params)
	if err != nil {
		log.Fatalf("%s: %v\n", appID, err)
	}
}
