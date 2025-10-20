// Main package.
package main

import (
	"bufio"
	"fmt"
	"io"
	"log"
	"os"

	"github.com/spf13/pflag"
	"golang.org/x/term"
)

var appID = "foobar"

type entryParams struct {
	exeName    string
	stdin      io.Reader
	stdout     io.Writer
	stderr     io.Writer
	isTerminal bool

	verbose bool
}

// foobarEntry is the entry point.
func foobarEntry(args []string, params *entryParams) (err error) {
	if params.verbose {
		for i, arg := range args {
			log.Println(i, arg)
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

	flags.BoolVarP(&params.verbose, "verbose", "v", false, "Verbosity")

	flags.Parse(os.Args[1:])
	if shouldPrintHelp {
		showUsage(flags, os.Stderr)
		return
	}
	err := foobarEntry(flags.Args(), &params)
	if err != nil {
		log.Fatalf("%s: %v\n", appID, err)
	}
}
