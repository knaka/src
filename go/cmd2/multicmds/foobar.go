package main

import (
	"fmt"

	"github.com/spf13/cobra"
)

type foobarParams struct {
	*rootParams

	fuga bool
}

func foobarEntry(params *foobarParams) (err error) {
	fmt.Fprintln(params.stderr, "isTerminal:", params.isTerm)
	fmt.Fprintln(params.stderr, "verbose:", params.verbose)
	fmt.Fprintln(params.stderr, "fuga:", params.fuga)
	for _, arg := range params.args {
		fmt.Fprintf(params.stdout, "  %s\n", arg)
	}
	return
}

func init() {
	var params foobarParams

	command := cobra.Command{
		Use:   "foobar" + " [flags] [file...]",
		Short: "foobar Short",
		Long:  `foobar Long`,
		RunE: func(_ *cobra.Command, args []string) (err error) {
			params.args = args
			return foobarEntry(&params)
		},
	}
	flags := command.Flags()
	flags.BoolVarP(&params.fuga, "fuga", "f", false, "Fuga")

	subcmds = append(subcmds, &subcmd{
		command: &command,
		params:  &params.rootParams,
	})
}
