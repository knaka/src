package xiter

import (
	"iter"

	"golang.org/x/exp/constraints"
)

// Take returns an iterator over seq that stops after n values.
func Take[V any](seq iter.Seq[V], n int) iter.Seq[V] {
	return func(yield func(V) bool) {
		if n <= 0 {
			return
		}
		for v := range seq {
			if !yield(v) {
				return
			}
			if n--; n <= 0 {
				break
			}
		}
	}
}

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
