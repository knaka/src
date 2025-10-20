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
	"github.com/spf13/pflag"
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

func showUsage(flags *pflag.FlagSet, stderr io.Writer) {
	fmt.Fprintf(stderr, "Usage: %s [options] [arg...]\n", appID)
	flags.SetOutput(stderr)
	flags.PrintDefaults()
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
	var rootCmd = &cobra.Command{
		Use:   appID,
		Short: "Multi-commands demo",
		Long:  `Multi-commands demo`,
		RunE: func(_ *cobra.Command, args []string) (err error) {
			return multicmdsEntry(args, &params)
		},
	}
	rootCmd.PersistentFlags().BoolVarP(&params.verbose, "verbose", "v", false, "verbose output")
	rootCmd.SetArgs(os.Args[1:])
	for _, subcmd := range subcmds {
		rootCmd.AddCommand(subcmd.command)
		if subcmd.params != nil {
			*subcmd.params = &params
		}
	}
	err := rootCmd.Execute()
	if err != nil {
		log.Fatalf("%s: %v\n", appID, err)
	}
}
