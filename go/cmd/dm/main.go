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

const stdinFilename = "-"

// dumpFile dumps a file in hex format. If the filename is "-", it reads from stdin. If the writer is a terminal, it uses colors.
func dumpFile(filePath string, params *entryParams) (err error) {
	reader := params.stdin
	if filePath != stdinFilename {
		file, errTmp := os.Open(filePath)
		if errTmp != nil {
			return errTmp
		}
		defer file.Close()
		reader = bufio.NewReader(file)
	}
	buf := make([]byte, numPerLine)
	for addr := 0; ; addr += numPerLine {
		pn := PtrResult(reader.Read(buf)).NilIf(io.EOF)
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
					if params.isTerminal {
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
		Must(fmt.Fprintf(params.stdout, "%08X | %s | %s\n",
			addr,
			strings.Join(hexes, " "),
			readable,
		))
	}
	return
}

var appID = "dm"

type entryParams struct {
	exeName     string
	stdin       io.Reader
	stdout      io.Writer
	stderr      io.Writer
	stdinIsTerm bool
	isTerminal  bool

	verbose bool
}

// dmEntry is the entry point.
func dmEntry(files []string, params *entryParams) (err error) {
	if len(files) == 0 {
		files = append(files, stdinFilename)
	}
	for _, file := range files {
		err = dumpFile(file, params)
		if err != nil {
			return
		}
	}
	return
}

func main() {
	params := entryParams{
		exeName:    appID,
		stdin:      os.Stdin,
		stdout:     os.Stdout,
		stderr:     os.Stderr,
		isTerminal: term.IsTerminal(int(os.Stdout.Fd())),
	}
	if !term.IsTerminal(int(os.Stdin.Fd())) {
		params.stdin = bufio.NewReader(os.Stdin)
	}
	if !params.isTerminal {
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
		// showUsage(flags, os.Stderr)
		return
	}
	err := dmEntry(flags.Args(), &params)
	if err != nil {
		log.Fatalf("%s: %v\n", appID, err)
	}
}
