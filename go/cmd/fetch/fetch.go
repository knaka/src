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

type fetchParams struct {
	workingDirectory string
}

type fetchOption func(params *fetchParams) error

func workingDirectory(dir string) fetchOption {
	return func(params *fetchParams) (err error) {
		params.workingDirectory = dir
		return
	}
}

func fetch(url string, opts ...fetchOption) (err error) {
	params := fetchParams{
		workingDirectory: ".",
	}
	for _, opt := range opts {
		err = opt(&params)
		if err != nil {
			return
		}
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
	return err
}

func fetchMain(args []string) (err error) {
	for _, arg := range args {
		fetch(arg, workingDirectory("."))
	}
	return
}

func main() {
	err := fetchMain(os.Args[1:])
	if err != nil {
		log.Fatalf("%s: %v\n", appID, err)
	}
}
