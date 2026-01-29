package main

import (
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
				Range(0),
			),
			5,
		),
	)))
	Must(pp.Println("e73449f", slices.Collect(
		Limit(
			Zip(
				Range(0),
				Map(func(n int) int { return n * 2 }, Range(0)),
			),
			5,
		),
	)))
	for pair := range Limit(
		Zip(
			Range(0),
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
	log.Println("a3f0432", sumIter(0))
}
