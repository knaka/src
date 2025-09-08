//go:build debug
// +build debug

package main

import (
	"bufio"
	"fmt"
	"net"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
)

// waitHTTP waits for an HTTP request to be made to a dynamically assigned port.
// Activated by --waithttp or --wait-http flags, or WAITHTTP or WAIT_HTTP environment variables.
func waitHTTP() {
	waitsHTTP := false
	if len(os.Args) > 1 &&
		(os.Args[1] == "--waithttp" || os.Args[1] == "--wait-http") {
		waitsHTTP = true
		os.Args = append(os.Args[:1], os.Args[2:]...)
	}
	if !waitsHTTP &&
		os.Getenv("WAITHTTP") == "" &&
		os.Getenv("WAIT_HTTP") == "" {
		return
	}
	listener, err := net.Listen("tcp", ":0")
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to get free port: %v\n", err)
		os.Exit(1)
	}
	port := listener.Addr().(*net.TCPAddr).Port
	listener.Close()
	pid := os.Getpid()
	fmt.Fprintf(os.Stderr, "Process %d is waiting for HTTP access at http://127.0.0.1:%d .\n", pid, port)
	done := make(chan bool, 1)
	http.HandleFunc("/", func(w http.ResponseWriter, _ *http.Request) {
		fmt.Fprintf(w, "OK")
		select {
		case done <- true:
		default:
		}
	})
	go func() {
		http.ListenAndServe(fmt.Sprintf(":%d", port), nil)
	}()
	<-done
	fmt.Fprintf(os.Stderr, "HTTP request received.\n")
	time.Sleep(1 * time.Second)
}

// waitSTDIN waits for user input on standard input.
// Activated by --waitstdin or --wait-stdin flags, or WAITSTDIN or WAIT_STDIN environment variables.
// User can press Enter to proceed.
func waitSTDIN() {
	waitsSTDIN := false
	if len(os.Args) > 1 &&
		(os.Args[1] == "--waitstdin" || os.Args[1] == "--wait-stdin") {
		waitsSTDIN = true
		os.Args = append(os.Args[:1], os.Args[2:]...)
	}
	if !waitsSTDIN &&
		os.Getenv("WAITSTDIN") == "" &&
		os.Getenv("WAIT_STDIN") == "" {
		return
	}
	pid := os.Getpid()
	fmt.Fprintf(os.Stderr, "Process %d is waiting for input on stdin. Press Enter to proceed:\n", pid)
	scanner := bufio.NewScanner(os.Stdin)
	scanner.Scan()
	fmt.Fprintf(os.Stderr, "Input received.\n")
	time.Sleep(1 * time.Second)
}

// waitSIGINT waits for an interrupt signal (SIGINT or SIGTERM).
// Activated by --waitsigint or --wait-sigint flags, or WAITSIGINT or WAIT_SIGINT environment variables.
// User can press Ctrl+C to proceed. Signal handling is restored to default after first signal.
func waitSIGINT() {
	waitsSIGINT := false
	if len(os.Args) > 1 &&
		(os.Args[1] == "--waitsigint" || os.Args[1] == "--wait-sigint") {
		waitsSIGINT = true
		os.Args = append(os.Args[:1], os.Args[2:]...)
	}
	if !waitsSIGINT &&
		os.Getenv("WAITSIGINT") == "" &&
		os.Getenv("WAIT_SIGINT") == "" {
		return
	}
	pid := os.Getpid()
	fmt.Fprintf(os.Stderr, "Process %d is waiting for interrupt signal. Press Ctrl+C to proceed:\n", pid)
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
	sig := <-sigCh
	signal.Reset(syscall.SIGINT, syscall.SIGTERM)
	fmt.Fprintf(os.Stderr, "Signal %v received.\n", sig)
	time.Sleep(1 * time.Second)
}

func init() {
	waitHTTP()
	waitSTDIN()
	waitSIGINT()
}
