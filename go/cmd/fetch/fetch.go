package main

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"path"
	"path/filepath"

	//revive:disable-next-line:dot-imports
	. "github.com/knaka/go-utils"
	"github.com/knaka/go-utils/funcopt"
)

// fetchParams holds configuration parameters for fetch operations.
type fetchParams struct {
	stderr  io.Writer
	dir     string
	verbose bool
}

// WithDir sets the working directory for the fetch operation.
var WithDir = funcopt.NewFailable(func(params *fetchParams, dir string) error {
	if _, err := os.Stat(dir); os.IsNotExist(err) {
		return fmt.Errorf("directory does not exist: %s", dir)
	}
	params.dir = dir
	return nil
})

// WithStderr sets the stderr stream for the fetch operation.
var WithStderr = funcopt.New(func(params *fetchParams, stderr io.Writer) {
	params.stderr = stderr
})

// WithVerbose sets the verbosity.
var WithVerbose = funcopt.New(func(params *fetchParams, verbose bool) {
	params.verbose = verbose
})

// Fetch downloads a file from the given URL to the local filesystem.
func Fetch(url string, opts ...funcopt.Option[fetchParams]) (err error) {
	defer Catch(&err)
	params := fetchParams{
		dir:     ".",
		verbose: false,
		stderr:  os.Stderr,
	}
	Must(funcopt.Apply(&params, opts))
	if params.verbose {
		fmt.Fprintf(params.stderr, "Fetching %s ...\n", url)
	}
	base := path.Base(url)
	outPath := filepath.Join(params.dir, base)
	// `Get` follows 30* redirection.
	resp := Value(http.Get(url))
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		Throw(fmt.Errorf("HTTP %d: %s", resp.StatusCode, resp.Status))
	}
	outFile := Value(os.Create(outPath))
	defer outFile.Close()
	Must(io.Copy(outFile, resp.Body))
	if params.verbose {
		fmt.Fprintf(params.stderr, "Saved to %s\n", outPath)
	}
	return
}
