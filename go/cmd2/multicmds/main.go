// Main package.
package main

import (
	"bufio"
	"fmt"
	"io"
	"log"
	"os"

	"github.com/mattn/go-isatty"
	"github.com/spf13/cobra"
)

var appID = "multicmds"

type entryParams struct {
	exeName    string
	stdin      io.Reader
	stdout     io.Writer
	stderr     io.Writer
	isTerminal bool

	verbose bool
}

type subcmd struct {
	command *cobra.Command
	params  **entryParams
}

var subcmds []*subcmd

func multicmdsEntry(_ []string, params *entryParams) (err error) {
	fmt.Fprintln(params.stderr, "Without subcommand")
	fmt.Fprintln(params.stderr, "verbose:", params.verbose)
	return
}

func main() {
	params := entryParams{
		exeName:    appID,
		stdin:      os.Stdin,
		stdout:     os.Stdout,
		stderr:     os.Stderr,
		isTerminal: isatty.IsTerminal(os.Stdout.Fd()),
	}
	if !params.isTerminal {
		bufStdout := bufio.NewWriter(os.Stdout)
		defer bufStdout.Flush()
		params.stdout = bufStdout
	}
	var command = &cobra.Command{
		Use:   appID,
		Short: "Multi-commands demo",
		Long:  `Multi-commands demo`,
		RunE: func(_ *cobra.Command, args []string) (err error) {
			return multicmdsEntry(args, &params)
		},
	}
	command.PersistentFlags().BoolVarP(&params.verbose, "verbose", "v", false, "verbose output")
	command.SetArgs(os.Args[1:])
	for _, subcmd := range subcmds {
		command.AddCommand(subcmd.command)
		if subcmd.params != nil {
			*subcmd.params = &params
		}
	}
	err := command.Execute()
	if err != nil {
		log.Fatalf("%s: %v\n", appID, err)
	}
}
