// Main package.
package main

import (
	"bufio"
	"fmt"
	"io"
	"log"
	"os"

	"github.com/spf13/cobra"
	"golang.org/x/term"
)

var appID = "multicmds"

type rootParams struct {
	exeName string
	stdin   io.Reader
	stdout  io.Writer
	stderr  io.Writer
	isTerm  bool
	args    []string

	verbose bool
	bar     bool
}

type subcmd struct {
	command       *cobra.Command
	rootParamsRef **rootParams
}

var subcmds []*subcmd

func multicmdsEntry(params *rootParams) (err error) {
	fmt.Fprintln(params.stderr, "Without subcommand")
	fmt.Fprintln(params.stderr, "verbose:", params.verbose)
	return
}

func main() {
	params := rootParams{
		exeName: appID,
		stdin:   os.Stdin,
		stdout:  os.Stdout,
		stderr:  os.Stderr,
	}
	if !term.IsTerminal(int(os.Stdin.Fd())) {
		params.stdin = bufio.NewReader(os.Stdin)
	}
	if term.IsTerminal(int(os.Stdout.Fd())) {
		params.isTerm = true
	} else {
		bufStdout := bufio.NewWriter(os.Stdout)
		defer bufStdout.Flush()
		params.stdout = bufStdout
	}
	command := &cobra.Command{
		Use:   appID + " [flags]",
		Short: "Multi-commands Short",
		Long:  `Multi-commands Long`,
		RunE: func(_ *cobra.Command, args []string) (err error) {
			params.args = args
			return multicmdsEntry(&params)
		},
	}
	command.PersistentFlags().BoolVarP(&params.verbose, "verbose", "v", false, "verbose output")
	flags := command.Flags()
	flags.BoolVarP(&params.bar, "bar", "b", false, "bar")
	for _, subcmd := range subcmds {
		command.AddCommand(subcmd.command)
		if subcmd.rootParamsRef != nil {
			*subcmd.rootParamsRef = &params
		}
	}
	command.SetArgs(os.Args[1:])
	err := command.Execute()
	if err != nil {
		log.Fatalf("%s: %v\n", appID, err)
	}
}
