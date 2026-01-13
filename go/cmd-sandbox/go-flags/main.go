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

func main() {
	params := foobarParams{
		exeName: appID,
		stdin:   os.Stdin,
		stdout:  os.Stdout,
		stderr:  os.Stderr,
	}
	if !term.IsTerminal(int(os.Stdin.Fd())) {
		params.stdin = bufio.NewReader(os.Stdin)
	}
	if term.IsTerminal(int(os.Stdout.Fd())) {
		params.isTerm = true
	} else {
		bufStdout := bufio.NewWriter(os.Stdout)
		defer bufStdout.Flush()
		params.stdout = bufStdout
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
