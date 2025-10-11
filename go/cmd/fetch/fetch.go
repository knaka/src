//revive:disable-next-line
package main

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"path"
	"path/filepath"
)

const appID = "fetch"

// FuncOption represents a configuration option for functional option.
type FuncOption[T any] func(params *T) error

// applyOptions applies a slice of functional options to the given parameters.
func applyOptions[T any](params *T, opts []FuncOption[T]) (err error) {
	for _, opt := range opts {
		err = opt(params)
		if err != nil {
			return
		}
	}
	return
}

// fetchParams holds configuration parameters for fetch operations.
type fetchParams struct {
	stdout           io.Writer
	stderr           io.Writer
	workingDirectory string
	verbose          bool
}

// WithDir sets the working directory for the fetch operation.
func WithDir(dir string) FuncOption[fetchParams] {
	return func(params *fetchParams) (err error) {
		params.workingDirectory = dir
		return
	}
}

// WithStdout sets the stdout stream for the fetch operation.
func WithStdout(stdout io.Writer) FuncOption[fetchParams] {
	return func(params *fetchParams) (err error) {
		params.stdout = stdout
		return
	}
}

// WithStderr sets the stderr stream for the fetch operation.
func WithStderr(stderr io.Writer) FuncOption[fetchParams] {
	return func(params *fetchParams) (err error) {
		params.stderr = stderr
		return
	}
}

// WithVerbose sets the verbosity.
func WithVerbose(f bool) FuncOption[fetchParams] {
	return func(params *fetchParams) (err error) {
		params.verbose = f
		return
	}
}

// Fetch downloads a file from the given URL to the local filesystem.
func Fetch(url string, opts ...FuncOption[fetchParams]) (err error) {
	params := fetchParams{
		workingDirectory: ".",
		verbose:          false,
		stdout:           os.Stdout,
		stderr:           os.Stderr,
	}
	err = applyOptions(&params, opts)
	if err != nil {
		return
	}
	if params.verbose {
		fmt.Fprintf(params.stderr, "Fetching %s ...\n", url)
	}
	base := path.Base(url)
	outPath := filepath.Join(params.workingDirectory, base)
	// Get follows 30* redirect.
	resp, err := http.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("HTTP %d: %s", resp.StatusCode, resp.Status)
	}
	outFile, err := os.Create(outPath)
	if err != nil {
		return err
	}
	defer outFile.Close()
	_, err = io.Copy(outFile, resp.Body)
	if err != nil {
		return err
	}
	if params.verbose {
		fmt.Fprintf(params.stderr, "Saved to %s\n", outPath)
	}
	return nil
}

func fetchMain(args []string) (err error) {
	for _, arg := range args {
		Fetch(arg, WithVerbose(true))
	}
	return
}

func main() {
	err := fetchMain(os.Args[1:])
	if err != nil {
		log.Fatalf("%s: %v\n", appID, err)
	}
}
