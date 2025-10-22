// Main package.
package main

import (
	"io"
	"log"
	"os"

	"github.com/mattn/go-isatty"
)

var appID = "isterminal"

type entryParams struct {
	exeName string
	stdin   io.Reader
	stdout  io.Writer
	stderr  io.Writer
}

// isterminalEntry is the entry point.
func isterminalEntry(_ []string, params *entryParams) (err error) {
	isTerminal := (func() bool {
		if file, ok := params.stdout.(*os.File); ok {
			// github.com/mattn/go-isatty
			return isatty.IsTerminal(file.Fd())
		}
		return false
	})()
	log.Println("isTerminal:", isTerminal)
	return
}

func main() {
	err := isterminalEntry(os.Args[1:], &entryParams{exeName: os.Args[0], stdin: os.Stdin, stdout: os.Stdout, stderr: os.Stderr})
	if err != nil {
		log.Fatalf("%s: %v\n", appID, err)
	}
}
