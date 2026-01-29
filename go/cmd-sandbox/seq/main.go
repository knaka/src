package main

import (
	"iter"
	"log"
	"slices"

	//lint:ignore ST1001
	//nolint:staticcheck
	//revive:disable-next-line:dot-imports
	. "app/cmd-sandbox/seq/xiter"

	"github.com/k0kubun/pp"
	"golang.org/x/exp/constraints"

	//lint:ignore ST1001
	//nolint:staticcheck
	//revive:disable-next-line:dot-imports
	. "github.com/knaka/go-utils"
)

// Iterate generates an infinite sequence by repeatedly applying a function
// to the previous value, starting from the initial value.
// This is equivalent to Haskell's Iterate function.
func Iterate[T constraints.Integer](
	stepFunc func(T) T,
	initial T,
) iter.Seq[T] {
	return func(yield func(T) bool) {
		current := initial
		for yield(current) {
			current = stepFunc(current)
		}
	}
}

// TakeWhile returns elements from seq while the predicate f returns true.
// This is equivalent to Haskell's takeWhile function.
func TakeWhile[T any](f func(T) bool, seq iter.Seq[T]) iter.Seq[T] {
	return func(yield func(T) bool) {
		for v := range seq {
			if !f(v) {
				return
			}
			if !yield(v) {
				return
			}
		}
	}
}

// Range returns an arithmetic sequence starting from start.
// This is similar to Haskell's enumFromThenTo, Python's range, or Rust's (start..=end).step_by(step).
//   - Range(start) returns start, start+1, start+2, ... (infinite)
//   - Range(start, end) returns start, start+1, ..., end (inclusive, step=1)
//   - Range(start, end, step) returns start, start+step, ..., up to end (inclusive)
//
// It uses Iterate internally to generate the sequence.
func Range[T constraints.Integer](start T, args ...T) iter.Seq[T] {
	var end *T
	step := T(1)

	if len(args) >= 1 {
		end = &args[0]
	}
	if len(args) >= 2 {
		step = args[1]
	}

	// step == 0: return empty sequence to avoid infinite loop
	if step == 0 {
		return func(yield func(T) bool) {}
	}

	infiniteSeq := Iterate(func(n T) T { return n + step }, start)

	// No end specified: return infinite sequence
	if end == nil {
		return infiniteSeq
	}

	// With end: use TakeWhile to limit the sequence
	var predicate func(T) bool
	if step > 0 {
		predicate = func(n T) bool { return n <= *end }
	} else {
		predicate = func(n T) bool { return n >= *end }
	}
	return TakeWhile(predicate, infiniteSeq)
}

// Count returns an infinite arithmetic sequence starting from start with given step.
// This is similar to Python's itertools.count(start, step).
//
//	Count(0, 1)   // 0, 1, 2, 3, ... (same as Range(0))
//	Count(10, -1) // 10, 9, 8, 7, ... (infinite descending)
//	Count(0, 2)   // 0, 2, 4, 6, ... (infinite even numbers)
func Count[T constraints.Integer](start, step T) iter.Seq[T] {
	return Iterate(func(n T) T { return n + step }, start)
}

// Take returns an iterator over seq that stops after n values.
// This is an alias for Limit.
func Take[V any](seq iter.Seq[V], n int) iter.Seq[V] {
	return Limit(seq, n)
}

// Naturals0 is an infinite sequence of natural numbers starting from 0: 0, 1, 2, 3, ...
var Naturals0 = Range(0)

// Naturals is an alias for Naturals0.
var Naturals = Naturals0

// Naturals1 is an infinite sequence of natural numbers starting from 1: 1, 2, 3, ...
var Naturals1 = Range(1)

func factorialRec(n int) int {
	if n == 0 {
		return 1
	}
	return n * factorialRec(n-1)
}

func factorialIter(n int) int {
	return Reduce(
		func(acc, v int) int { return acc * v },
		1,
		Range(2, n),
	)
}

func sumRec[T constraints.Integer](n T) T {
	if n == 0 {
		return 0
	}
	return n + sumRec(n-1)
}

func sumIter[T constraints.Integer](n T) T {
	return Reduce(
		func(acc, v T) T { return acc + v },
		0,
		Range(1, n),
	)
}

func main() {
	Must(pp.Println("fd7b955", slices.Collect(
		Limit(
			Map(
				func(n int) int { return n * 2 },
				Naturals,
			),
			5,
		),
	)))
	Must(pp.Println("e73449f", slices.Collect(
		Limit(
			Zip(
				Naturals,
				Map(func(n int) int { return n * 2 }, Naturals),
			),
			5,
		),
	)))
	for pair := range Limit(
		Zip(
			Naturals0,
			Map(func(n int64) int64 { return n * 2 }, Count(int64(0), 1)),
		),
		5,
	) {
		if pair.Ok1 && pair.Ok2 {
			Must(pp.Println("01c838a", pair.V1, pair.V2))
		}
	}
	log.Println("0bdab24", factorialRec(5))
	log.Println("e41f382", factorialIter(5))
	Must(pp.Println("bc5ea1a", slices.Collect(
		Range(2, 12, 3),
	)))
	Must(pp.Println("f769a60", slices.Collect(
		Range(12, -4, -2),
	)))
	Must(pp.Println("e18a710", slices.Collect(
		Take(Count(3, -2), 10),
	)))
	log.Println("d3eee75", sumRec(int64(10)) == sumIter(int64(10)))
	// log.Println("a710a99", sumRec(100000000)) // fatal error: stack overflow
	log.Println("a710a99", sumIter(100000000)) // works
}
