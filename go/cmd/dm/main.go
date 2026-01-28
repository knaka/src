// CLI command to dump a file in hex format.
package main

import (
	"bufio"
	"fmt"
	"io"
	"log"
	"os"
	"strings"

	_ "github.com/knaka/go-utils/initwait"
	"github.com/spf13/pflag"
	"golang.org/x/term"

	//revive:disable:dot-imports
	. "github.com/knaka/go-utils"
)

func printable(ch byte) bool {
	return 0x20 <= ch && ch < 0x7F
}

const chNotPrintable = "."

const numPerLine = 16

const (
	escSeqRed = "\033[31m"
	escSeqEnd = "\033[0m"
)

func dumpStream(reader io.Reader, writer io.Writer, colored bool) (err error) {
	bufReader := bufio.NewReader(reader)
	bufWriter := bufio.NewWriter(writer)
	defer (func() { bufWriter.Flush() })()
	buf := make([]byte, numPerLine)
	for addr := 0; ; addr += numPerLine {
		pn := PtrResult(bufReader.Read(buf)).NilIf(io.EOF)
		if pn == nil {
			break
		}
		var hexes []string
		readable := ""
		for i := range numPerLine {
			if i < *pn {
				hexes = append(hexes, fmt.Sprintf("%02X", buf[i]))
				if printable(buf[i]) {
					readable += string(buf[i])
				} else {
					if colored {
						readable += escSeqRed + chNotPrintable + escSeqEnd
					} else {
						readable += chNotPrintable
					}
				}
			} else {
				hexes = append(hexes, "  ")
				readable += " "
			}
		}
		Must(fmt.Fprintf(bufWriter, "%08X | %s | %s\n",
			addr,
			strings.Join(hexes, " "),
			readable,
		))
	}
	return
}

func dumpFile(path string, writer io.Writer, colored bool) (err error) {
	file, err := os.Open(path)
	if err != nil {
		return
	}
	defer (func() { Must(file.Close()) })()
	return dumpStream(file, writer, colored)
}

var appID = "dm"

type dmParams struct {
	exeName string
	stdin   io.Reader
	stdout  io.Writer
	stderr  io.Writer
	isTerm  bool
	args    []string

	verbose bool
}

const stdinFilename = "-"

// dmEntry is the entry point.
func dmEntry(params *dmParams) (err error) {
	paths := params.args
	if len(paths) == 0 {
		paths = append(paths, stdinFilename)
	}
	for _, path := range paths {
		if path == stdinFilename {
			err = dumpStream(params.stdin, params.stdout, params.isTerm)
		} else {
			err = dumpFile(path, params.stdout, params.isTerm)
		}
		if err != nil {
			return
		}
	}
	return
}

func main() {
	params := dmParams{
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
		defer (func() { bufStdout.Flush() })()
		params.stdout = bufStdout
	}
	flags := pflag.NewFlagSet(appID, pflag.PanicOnError)
	var shouldPrintHelp bool
	flags.BoolVarP(&shouldPrintHelp, "help", "h", false, "Show help")

	flags.BoolVarP(&params.verbose, "verbose", "v", false, "Verbosity")

	flags.Parse(os.Args[1:])
	params.args = flags.Args()
	if shouldPrintHelp {
		// showUsage(flags, os.Stderr)
		return
	}
	err := dmEntry(&params)
	if err != nil {
		log.Fatalf("%s: %v\n", appID, err)
	}
}
