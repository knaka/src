package main

import (
	"iter"
	"slices"

	//lint:ignore ST1001
	//nolint:staticcheck
	//revive:disable-next-line:dot-imports
	. "app/cmd-sandbox/seq/xiter"

	"github.com/k0kubun/pp"
	"golang.org/x/exp/constraints"
)

// iterate generates an infinite sequence by repeatedly applying a function
// to the previous value, starting from the initial value.
// This is equivalent to Haskell's iterate function.
func iterate[T constraints.Integer](
	stepFunc func(T) T,
	initial T,
) iter.Seq[T] {
	return func(yield func(T) bool) {
		current := initial
		for {
			if !yield(current) {
				break
			}
			current = stepFunc(current)
		}
	}
}

// naturals is an infinite sequence of natural numbers: 0, 1, 2, 3, ...
var naturals = iterate(func(n int) int { return n + 1 }, 0)

func main() {
	pp.Println("fd7b955", slices.Collect(
		Limit(
			Map(
				func(n int) int { return n * 2 },
				naturals,
			),
			5,
		),
	))
	pp.Println("e73449f", slices.Collect(
		Limit(
			Zip(
				naturals,
				Map(func(n int) int { return n * 2 }, naturals),
			),
			5,
		),
	))
	for pair := range Limit(
		Zip(
			naturals,
			Map(func(n int) int { return n * 2 }, naturals),
		),
		5,
	) {
		if pair.Ok1 && pair.Ok2 {
			pp.Println("01c838a", pair.V1, pair.V2)
		}
	}
}
