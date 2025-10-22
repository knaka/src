// Main package.
package main

import (
	"context"
	"io"
	"log"
	"os"

	"app/cmd2/context-value/lib"
)

var appID = "contextValue"

type entryParams struct {
	exeName string
	stdin   io.Reader
	stdout  io.Writer
	stderr  io.Writer
}

type serviceLocatorT struct{}

func (*serviceLocatorT) GetFooService() int {
	return 123
}

func (*serviceLocatorT) GetBarService() string {
	return "BAR"
}

// contextValueEntry is the entry point.
func contextValueEntry(_ []string, _ *entryParams) (err error) {
	sl := serviceLocatorT{}
	ctx := context.Background()
	ctx = lib.ContextWithServiceLocator(ctx, &sl)
	lib.DoSomething(ctx)
	return
}

func main() {
	err := contextValueEntry(os.Args[1:], &entryParams{exeName: os.Args[0], stdin: os.Stdin, stdout: os.Stdout, stderr: os.Stderr})
	if err != nil {
		log.Fatalf("%s: %v\n", appID, err)
	}
}
