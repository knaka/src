// Package main is a main.
package main

import (
	"log"

	"github.com/knaka/go-utils/funcopt"
)

// foobarParams holds configuration parameters.
type foobarParams struct {
	verbose bool
}

// Options is functional options type
type Options []funcopt.Option[foobarParams]

// WithVerbose sets the verbosity.
var WithVerbose = funcopt.New(func(params *foobarParams, verbose bool) {
	params.verbose = verbose
})

// foobar does something.
func foobar(opts ...funcopt.Option[foobarParams]) (err error) {
	params := foobarParams{}
	if err = funcopt.Apply(&params, opts); err != nil {
		return
	}
	log.Println("Done")
	return
}
