package main

import (
	"bufio"
	"fmt"
	"io"
	"iter"
	"log"
	"os"
	"strings"

	"github.com/spf13/pflag"
	"golang.org/x/term"

	//lint:ignore ST1001
	//nolint:staticcheck
	//revive:disable-next-line:dot-imports
	. "github.com/knaka/go-utils"

	//lint:ignore ST1001
	//nolint:staticcheck
	//revive:disable-next-line:dot-imports
	. "github.com/knaka/go-utils/xiter"
)

var appID = "scan"

type scanParams struct {
	exeName string
	stdin   io.Reader
	stdout  io.Writer
	stderr  io.Writer
	isTerm  bool
	args    []string

	verbose bool
	colored bool
}

func linesSeq(reader io.Reader) iter.Seq[string] {
	return func(yield func(string) bool) {
		scanner := bufio.NewScanner(reader)
		for scanner.Scan() {
			if !yield(scanner.Text()) {
				return
			}
		}
	}
}

// scanEntry is the entry point.
func scanEntry(params *scanParams) (err error) {
	for _, arg := range params.args {
		lines := linesSeq(Value(os.Open(arg)))
		modLines := Map(
			func(line string) string { return "37b4c67: " + line },
			lines,
		)
		for line := range modLines {
			log.Println("e2332db", line)
		}
	}
	for item := range strings.SplitSeq("foo###bar###baz", "###") {
		log.Println("7705877", item)
	}
	for line := range strings.Lines("hoge\nfuga\nfoo\n") {
		// newlines remain.
		log.Printf("1dcbe67: %s", line)
	}
	return
}

func main() {
	params := scanParams{
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
	err := scanEntry(&params)
	if err != nil {
		log.Fatalf("%s: %v\n", appID, err)
	}
	Range
}
