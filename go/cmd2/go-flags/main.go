// Main package.
package main

import (
	"fmt"
	"io"
	"log"
	"os"

	"github.com/spf13/pflag"
)

var appID = "foobar"

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

// foobarEntry is the entry point.
func foobarEntry(args []string, params *entryParams) (err error) {
	// isTerminal := (func() bool {
	// 	if file, ok := params.stdout.(*os.File); ok {
	// 		// github.com/mattn/go-isatty
	// 		return isatty.IsTerminal(file.Fd())
	// 	}
	// 	return false
	// })()
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
	err := foobarEntry(os.Args[1:], &entryParams{exeName: os.Args[0], stdin: os.Stdin, stdout: os.Stdout, stderr: os.Stderr})
	if err != nil {
		log.Fatalf("%s: %v\n", appID, err)
	}
}
