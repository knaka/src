// Package main is a main.
package main

import (
	"log"
)

// barbazParams holds configuration parameters.
type barbazParams struct {
	name string
}

// barbazOptions is functional options type
type barbazOptions []func(*barbazParams) error

// WithName sets the name.
func WithName(name string) func(*barbazParams) error {
	return func(params *barbazParams) (err error) {
		params.name = name
		return
	}
}

// barbaz does something.
func barbaz(opts ...func(*barbazParams) error) (err error) {
	params := barbazParams{}
	for _, opt := range opts {
		if err = opt(&params); err != nil {
			return
		}
	}
	log.Println("Hello,", params.name)
	return
}
