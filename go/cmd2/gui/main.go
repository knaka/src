// Text entry.
package main

import (
	"fmt"
	"image"
	"io"
	"log"
	"os"

	"github.com/guigui-gui/guigui"
	"github.com/hajimehoshi/ebiten/v2"
	"github.com/spf13/pflag"

	_ "github.com/knaka/go-utils/initwait"
	//revive:disable-next-line:dot-imports
	// . "github.com/knaka/go-utils"
)

var appID = ""

func showUsage(cmdln *pflag.FlagSet, stderr io.Writer) {
	fmt.Fprintf(os.Stderr, "Usage: %s [options] [file...]\n", appID)
	cmdln.SetOutput(stderr)
	cmdln.PrintDefaults()
}

var root = Root{
	shouldTerminate: false,
	text:            "",
	initialized:     false,
}

// Entry is the entrypoint.
func Entry(args []string) (err error) {
	flags := pflag.NewFlagSet(appID, pflag.ContinueOnError)
	var shouldPrintHelp bool
	flags.BoolVarP(&shouldPrintHelp, "help", "h", false, "Show help")
	err = flags.Parse(args)
	if err != nil {
		return
	}
	args = flags.Args()
	if shouldPrintHelp {
		showUsage(flags, os.Stderr)
		return
	}
	opt := &guigui.RunOptions{
		Title:         "Counter",
		WindowMinSize: image.Pt(600, 300),
		RunGameOptions: &ebiten.RunGameOptions{
			ApplePressAndHoldEnabled: true,
			SingleThread:             true,
		},
	}
	if err := guigui.Run(&root, opt); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	return
}

func main() {
	err := Entry(os.Args[1:])
	if err != nil {
		log.Fatalf("%s: %v\n", appID, err)
	}
	log.Println("text:", root.text)
}
