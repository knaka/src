// Main package.
package main

import (
	"context"
	"io"
	"log"
	"os"

	mainctx "app/cmd2/context-value/ctx"

	//revive:disable-next-line:dot-imports
	. "github.com/knaka/go-utils"
)

var appID = "contextValue"

type entryParams struct {
	exeName string
	stdin   io.Reader
	stdout  io.Writer
	stderr  io.Writer
}

// contextValueEntry is the entry point.
func contextValueEntry(_ []string, _ *entryParams) (err error) {
	ctx := mainctx.WithValue(context.Background(), &mainctx.Params{
		Foo: 123,
		Bar: "abc",
	})
	val := Value(mainctx.Value(ctx))
	log.Println("a783815:", val.Foo, val.Bar)
	return
}

func main() {
	err := contextValueEntry(os.Args[1:], &entryParams{exeName: os.Args[0], stdin: os.Stdin, stdout: os.Stdout, stderr: os.Stderr})
	if err != nil {
		log.Fatalf("%s: %v\n", appID, err)
	}
}
