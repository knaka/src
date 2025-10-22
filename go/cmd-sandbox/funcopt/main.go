// Main package.
package main

import (
	"fmt"
	"io"
	"log"
	"os"

	"github.com/spf13/pflag"
	//revive:disable-next-line:dot-imports
	. "github.com/knaka/go-utils"
)

var appID = "funcopt"

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

// funcoptEntry is the entry point.
func funcoptEntry(args []string, params *entryParams) (err error) {
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

	var opts1 Options
	opts1 = append(opts1, WithVerbose(true))
	Must(foobar(opts1...))

	var opts2 barbazOptions
	opts2 = append(opts2, WithName("World"))
	Must(barbaz(opts2...))

	return
}

func main() {
	err := funcoptEntry(os.Args[1:], &entryParams{exeName: os.Args[0], stdin: os.Stdin, stdout: os.Stdout, stderr: os.Stderr})
	if err != nil {
		log.Fatalf("%s: %v\n", appID, err)
	}
}
