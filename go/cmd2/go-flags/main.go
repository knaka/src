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

func showUsage(cmdln *pflag.FlagSet, stderr io.Writer) {
	fmt.Fprintf(os.Stderr, "Usage: %s [options] [file...]\n", appID)
	cmdln.SetOutput(stderr)
	cmdln.PrintDefaults()
}

// foobarEntry is the entrypoint.
func foobarEntry(args []string) (err error) {
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
	return
}

func main() {
	err := foobarEntry(os.Args[1:])
	if err != nil {
		log.Fatalf("%s: %v\n", appID, err)
	}
}
