// Generate monthly/yearly notes template in a diary format.
package main

import (
	"bufio"
	"fmt"
	"io"
	"log"
	"os"
	"strconv"
	"time"

	"github.com/spf13/pflag"
	"golang.org/x/term"

	//revive:disable-next-line dot-import
	. "github.com/knaka/go-utils"
)

var appID = "gendiary"

type gendiaryParams struct {
	exeName string
	stdin   io.Reader
	stdout  io.Writer
	stderr  io.Writer
	isTerm  bool
	args    []string

	year            int
	month           int
	woMonthlyHeader bool
}

var weekDays = []string{"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"}

// writeMonthlyNotes generates a monthly diary template with a header for each day.
func writeMonthlyNotes(params *gendiaryParams) (err error) {
	if !params.woMonthlyHeader {
		fmt.Fprintf(params.stdout, "# %04d-%02d Monthly Notes\n", params.year, params.month)
	}
	daysInMonth := time.Date(params.year, time.Month(params.month+1), 0, 0, 0, 0, 0, time.UTC).Day()
	for day := 1; day <= daysInMonth; day++ {
		t := time.Date(params.year, time.Month(params.month), day, 0, 0, 0, 0, time.UTC)
		fmt.Fprintf(params.stdout, "\n## %04d-%02d-%02d %s\n", params.year, params.month, day, weekDays[t.Weekday()])
	}
	return nil
}

// writeYearlyNotes generates a yearly diary template with a header for each day.
func writeYearlyNotes(params *gendiaryParams) (err error) {
	fmt.Fprintf(params.stdout, "# %04d Yearly Notes\n", params.year)
	params.woMonthlyHeader = true
	for month := 1; month <= 12; month++ {
		params.month = month
		Must(writeMonthlyNotes(params))
	}
	return nil
}

// gendiaryEntry is the entry point.
func gendiaryEntry(params *gendiaryParams) (err error) {
	defer Catch(&err)
	if params.year <= 0 && len(params.args) >= 1 {
		params.year = Value(strconv.Atoi(params.args[0]))
	}
	if params.month <= 0 && len(params.args) >= 2 {
		params.month = Value(strconv.Atoi(params.args[1]))
	}
	if params.year <= 0 && params.month <= 0 {
		return fmt.Errorf(
			"invalid year or month | year: %d, month: %d", params.year, params.month,
		)
	}
	if params.month > 0 {
		return writeMonthlyNotes(params)
	} else {
		return writeYearlyNotes(params)
	}
}

func main() {
	params := gendiaryParams{
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
	var shouldPrintHelp bool
	pflag.BoolVarP(&shouldPrintHelp, "help", "h", false, "show help")

	pflag.Usage = func() {
		fmt.Fprintf(os.Stderr, `Usage: %s [options] <year> <month>
       %s [options] <year>

`, appID, appID)
		pflag.PrintDefaults()
	}

	pflag.Parse()
	params.args = pflag.Args()
	if shouldPrintHelp {
		pflag.Usage()
		return
	}
	err := gendiaryEntry(&params)
	if err != nil {
		log.Fatalf("%s: %v\n", appID, err)
	}
}
