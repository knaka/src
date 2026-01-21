// Main package.
package main

import (
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
	return
}

func main() {
	params := foobarParams{
		exeName: appID,
		stdin:   os.Stdin,
		stdout:  os.Stdout,
		stderr:  os.Stderr,
		isTerm:  term.IsTerminal(int(os.Stdout.Fd())),
	}
	var shouldPrintHelp bool
	pflag.BoolVarP(&shouldPrintHelp, "help", "h", false, "show help")

	pflag.Usage = func() {
		fmt.Fprintf(os.Stderr, "Usage: %s [flags] [arg...]\n\nFlags:\n", appID)
		pflag.PrintDefaults()
	}
	pflag.BoolVarP(&params.verbose, "verbose", "v", false, "verbosity")
	pflag.BoolVarP(&params.colored, "coloroed", "c", params.isTerm, "colored")

	pflag.Parse()
	params.args = pflag.Args()
	if shouldPrintHelp {
		pflag.Usage()
		return
	}
	err := foobarEntry(&params)
	if err != nil {
		log.Fatalf("%s: %v\n", appID, err)
	}
}
