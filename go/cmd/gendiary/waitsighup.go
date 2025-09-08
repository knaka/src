//go:build debug && (darwin || linux)
// +build debug
// +build darwin linux

package main

import (
	"fmt"
	"os"
	"os/signal"
	"syscall"
	"time"
)

// waitSIGHUP waits for a SIGHUP signal on Unixy systems.
// Activated by --waitsighup or --wait-sighup flags, or WAITSIGHUP or WAIT_SIGHUP environment variables.
// User can run 'kill -HUP <pid>' to proceed. Signal handling is restored to default after first signal.
func waitSIGHUP() {
	waitsSig := false
	if len(os.Args) > 1 &&
		(os.Args[1] == "--waitsighup" || os.Args[1] == "--wait-sighup") {
		waitsSig = true
		os.Args = append(os.Args[:1], os.Args[2:]...)
	}
	if !waitsSig &&
		os.Getenv("WAITSIGHUP") == "" &&
		os.Getenv("WAIT_SIGHUP") == "" {
		return
	}
	pid := os.Getpid()
	fmt.Fprintf(os.Stderr, "Process %d is waiting for SIGHUP signal. Run the following to proceed:\n", pid)
	fmt.Fprintf(os.Stderr, "  kill -HUP %d\n", pid)
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGHUP)
	sig := <-sigCh
	signal.Reset(syscall.SIGHUP)
	fmt.Fprintf(os.Stderr, "Signal %v received.\n", sig)
	time.Sleep(1 * time.Second)
}

func init() {
	waitSIGHUP()
}
