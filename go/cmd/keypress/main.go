// Main package.
package main

import (
	"fmt"
	"io"
	"log"
	"os"
	"slices"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/spf13/pflag"
)

var appID = "keypress"

type keypressParams struct {
	exeName string
	stdin   io.Reader
	stdout  io.Writer
	stderr  io.Writer
	args    []string

	verbose bool
	colored bool
}

type model struct {
	key string
}

func (m model) Init() tea.Cmd {
	return nil
}

var keyRet string

var items = []string{
	" ", "!", `"`, "#", "$", "%", "&", "'", "(", ")", "*", "+", ",", "-", ".", "/",
	"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ":", ";", "<", "=", ">", "?",
	"@", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O",
	"P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "[", `\`, "]", "^", "_",
	"`", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o",
	"p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "{", "|", "}", "~",

	"ctrl+a", "ctrl+b", "ctrl+c", "ctrl+d", "ctrl+e", "ctrl+f",
	"ctrl+g", "ctrl+h", "ctrl+i", "ctrl+j", "ctrl+k", "ctrl+l",
	"ctrl+m", "ctrl+n", "ctrl+o", "ctrl+p", "ctrl+q", "ctrl+r",
	"ctrl+s", "ctrl+t", "ctrl+u", "ctrl+v", "ctrl+w", "ctrl+x",
	"ctrl+y", "ctrl+z",

	"enter", "esc",
	"left", "right", "up", "down",
	"pgup", "pgdown",
	"home", "end",
	"delete", "backspace",
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.KeyMsg:
		key := msg.String()
		if key == "" {
			break
		}
		if slices.Contains(items, key) {
			keyRet = key
			return m, tea.Quit
		}
		m.key = key
	}
	return m, nil
}

func (m model) View() string {
	// return fmt.Sprintf("3c05aa5: <%s>\n", m.key)
	return ""
}

// keypressEntry is the entry point.
func keypressEntry(_ *keypressParams) (err error) {
	if _, err := tea.NewProgram(model{}).Run(); err == nil {
		fmt.Printf("%s", keyRet)
	} else {
		fmt.Println("Error running program:", err)
		os.Exit(1)
	}
	return
}

func main() {
	params := keypressParams{
		exeName: appID,
		stdin:   os.Stdin,
		stdout:  os.Stdout,
		stderr:  os.Stderr,
	}
	var shouldPrintHelp bool
	pflag.BoolVarP(&shouldPrintHelp, "help", "h", false, "show help")

	pflag.Usage = func() {
		fmt.Fprintf(os.Stderr, "Usage: %s [flags] [arg...]\n\nFlags:\n", appID)
		pflag.PrintDefaults()
	}
	pflag.BoolVarP(&params.verbose, "verbose", "v", false, "verbosity")

	pflag.Parse()
	params.args = pflag.Args()
	if shouldPrintHelp {
		pflag.Usage()
		return
	}
	err := keypressEntry(&params)
	if err != nil {
		log.Fatalf("%s: %v\n", appID, err)
	}
}
