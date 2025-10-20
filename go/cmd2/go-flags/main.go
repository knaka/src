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

type foobarParams struct {
	exeName string
	stdin   io.Reader
	stdout  io.Writer
	stderr  io.Writer
	isTerm  bool
	args    []string

	verbose bool
	colored bool
}

// foobarEntry is the entry point.
func foobarEntry(params *foobarParams) (err error) {
	if params.verbose {
		for i, arg := range params.args {
			log.Println(i, arg)
		}
	}
	return
}

func showUsage(flags *pflag.FlagSet, stderr io.Writer) {
	fmt.Fprintf(stderr, `Usage: %s [flags] [arg...]

Flags:
`, appID)
	flags.SetOutput(stderr)
	flags.PrintDefaults()
}

func main() {
	params := foobarParams{
		exeName: appID,
		stdin:   os.Stdin,
		stdout:  os.Stdout,
		stderr:  os.Stderr,
		isTerm:  term.IsTerminal(int(os.Stdout.Fd())),
	}
	if !term.IsTerminal(int(os.Stdin.Fd())) {
		params.stdin = bufio.NewReader(os.Stdin)
	}
	if !params.isTerm {
		bufStdout := bufio.NewWriter(os.Stdout)
		defer bufStdout.Flush()
		params.stdout = bufStdout
	}
	flags := pflag.NewFlagSet(appID, pflag.PanicOnError)
	var shouldPrintHelp bool
	flags.BoolVarP(&shouldPrintHelp, "help", "h", false, "show help")

	flags.BoolVarP(&params.verbose, "verbose", "v", false, "verbosity")
	flags.BoolVarP(&params.colored, "coloroed", "c", params.isTerm, "colored")

	flags.Parse(os.Args[1:])
	params.args = flags.Args()
	if shouldPrintHelp {
		showUsage(flags, os.Stderr)
		return
	}
	err := foobarEntry(&params)
	if err != nil {
		log.Fatalf("%s: %v\n", appID, err)
	}
}
