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

var appID = "hello"

type helloParams struct {
	exeName string
	stdin   io.Reader
	stdout  io.Writer
	stderr  io.Writer
	isTerm  bool
	args    []string

	verbose bool
	colored bool

	name string
}

// helloEntry is the entry point.
func helloEntry(params *helloParams) (err error) {
	fmt.Fprintf(params.stdout, "Hello, %s!\n", params.name)
	return
}

func main() {
	params := helloParams{
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

	pflag.StringVarP(&params.name, "name", "n", "World", "name")

	pflag.Parse()
	params.args = pflag.Args()
	if shouldPrintHelp {
		pflag.Usage()
		return
	}
	err := helloEntry(&params)
	if err != nil {
		log.Fatalf("%s: %v\n", appID, err)
	}
}
