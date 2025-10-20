// Main package.
package main

import (
	"bufio"
	"fmt"
	"io"
	"log"
	"os"

	"github.com/mattn/go-isatty"
	"github.com/spf13/pflag"
)

var appID = "foobar"

type entryParams struct {
	exeName    string
	stdin      io.Reader
	stdout     io.Writer
	stderr     io.Writer
	isTerminal bool
}

func showUsage(flags *pflag.FlagSet, stderr io.Writer) {
	fmt.Fprintf(stderr, "Usage: %s [options] [arg...]\n", appID)
	flags.SetOutput(stderr)
	flags.PrintDefaults()
}

// foobarEntry is the entry point.
func foobarEntry(args []string, params *entryParams) (err error) {
	flags := pflag.NewFlagSet(appID, pflag.ContinueOnError)
	var shouldPrintHelp bool
	flags.BoolVarP(&shouldPrintHelp, "help", "h", false, "Show help")
	err = flags.Parse(args)
	if err != nil {
		return
	}
	args = flags.Args()
	if shouldPrintHelp {
		showUsage(flags, params.stderr)
		return
	}
	return
}

func main() {
	var stdout io.Writer = os.Stdout
	isTerminal := isatty.IsTerminal(os.Stdout.Fd())
	if !isTerminal {
		bufStdout := bufio.NewWriter(os.Stdout)
		defer bufStdout.Flush()
		stdout = bufStdout
	}
	err := foobarEntry(os.Args[1:], &entryParams{exeName: os.Args[0], stdin: os.Stdin, stdout: stdout, stderr: os.Stderr, isTerminal: isTerminal})
	if err != nil {
		log.Fatalf("%s: %v\n", appID, err)
	}
}
