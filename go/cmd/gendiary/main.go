// Generate monthly notes in a diary format.
package main

import (
	"bufio"
	"fmt"
	"os"
	"path/filepath"
	"strconv"
	"time"

	"github.com/spf13/pflag"

	//revive:disable-next-line dot-import
	. "github.com/knaka/go-utils"
)

var weekDays = []string{"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"}

func writeMonthlyNotes(writer *bufio.Writer, year, month int) (err error) {
	defer Catch(&err)
	V0(fmt.Fprintf(writer, "# %04d-%02d Monthly Notes\n", year, month))
	daysInMonth := time.Date(year, time.Month(month+1), 0, 0, 0, 0, 0, time.UTC).Day()
	for day := 1; day <= daysInMonth; day++ {
		t := time.Date(year, time.Month(month), day, 0, 0, 0, 0, time.UTC)
		V0(fmt.Fprintf(writer, "\n## %04d-%02d-%02d %s\n", year, month, day, weekDays[t.Weekday()]))
	}
	return nil
}

func main() {
	pflag.Usage = func() {
		_ = V(fmt.Fprintf(os.Stderr, "Usage: %s [options] <year> <month>\n", filepath.Base(os.Args[0])))
		pflag.PrintDefaults()
	}
	var putsHelp bool
	pflag.BoolVarP(&putsHelp, "help", "h", false, "Prints help message.")
	V0(pflag.CommandLine.Parse(os.Args[1:]))
	if putsHelp {
		pflag.Usage()
		os.Exit(0)
	}
	if pflag.NArg() < 2 {
		pflag.Usage()
		os.Exit(1)
	}
	year := V(strconv.Atoi(pflag.Arg(0)))
	month := V(strconv.Atoi(pflag.Arg(1)))
	writer := bufio.NewWriter(os.Stdout)
	V0(writeMonthlyNotes(writer, year, month))
	V0(writer.Flush())
}
