// Main for `fetch` command.
package main

import (
	"log"
	"os"

	//revive:disable-next-line:dot-imports
	. "github.com/knaka/go-utils"
	_ "github.com/knaka/go-utils/initwait"
	"github.com/knaka/go-utils/net"
)

const appID = "fetch"

func fetchMain(args []string) (err error) {
	defer Catch(&err)
	for _, arg := range args {
		Must(net.Fetch(arg, net.WithVerbose(true)))
	}
	return
}

func main() {
	err := fetchMain(os.Args[1:])
	if err != nil {
		log.Fatalf("%s: %v\n", appID, err)
	}
}
