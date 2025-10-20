package main

import (
	"fmt"

	"github.com/spf13/cobra"
)

type fooEntryParams struct {
	*entryParams
	fuga bool
}

func fooEntry(args []string, params *fooEntryParams) (err error) {
	fmt.Fprintln(params.stderr, "isTerminal:", params.isTerminal)
	fmt.Fprintln(params.stderr, "verbose:", params.verbose)
	fmt.Fprintln(params.stderr, "fuga:", params.fuga)
	for _, arg := range args {
		fmt.Fprintf(params.stdout, "  %s\n", arg)
	}
	return
}

func init() {
	var params fooEntryParams

	command := cobra.Command{
		Use:   "foo [flags]",
		Short: "Foo Short",
		Long:  `Foo Long`,
		RunE: func(_ *cobra.Command, args []string) (err error) {
			return fooEntry(args, &params)
		},
	}
	flags := command.Flags()
	flags.BoolVarP(&params.fuga, "fuga", "f", false, "Fuga")

	subcmds = append(subcmds, &subcmd{
		command: &command,
		params:  &params.entryParams,
	})
}
