//go:build debug && darwin
// +build debug,darwin

package main

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"strings"
	"time"
)

// debuggerProcessExists checks if a debugger process is currently attached to the given PID.
// It searches for common debugger patterns like "dlv attach" (GoLand/IntelliJ) and "/dlv dap" (VSCode).
// Returns true if a debugger is found, false otherwise.
func debuggerProcessExists(pid int) (exists bool) {
	cmd := exec.Command("ps", "wx")
	cmdOut, _ := cmd.StdoutPipe()
	defer (func() { cmdOut.Close() })()
	scanner := bufio.NewScanner(cmdOut)
	cmd.Start() // Start() does not block while Run() does.
	// On VSCode, os/exec.Command.Wait() (os/exec.Command.Process.Wait()) does not return after debugger is attached.
	// defer (func() { V0(cmd.Wait()) })()
	for scanner.Scan() {
		line := scanner.Text()
		// IntelliJ IDEA, GoLand
		if strings.Contains(line, "dlv") &&
			strings.Contains(line, fmt.Sprintf("attach %d", pid)) {
			return true
		}
		// VSCode. "Debug Adapter Protocol"
		if strings.Contains(line, "/dlv dap") {
			return true
		}
	}
	return false
}

// waitDebugger pauses execution until a debugger is attached to the current process.
// It can be triggered by:
// - Command line flags: --waitdebugger or --wait-debugger
// - Environment variables: WAITDEBUGGER or WAIT_DEBUGGER
func waitDebugger() {
	waitsDebugger := false
	if len(os.Args) > 1 &&
		(os.Args[1] == "--waitdebugger" || os.Args[1] == "--wait-debugger") {
		waitsDebugger = true
		os.Args = append(os.Args[:1], os.Args[2:]...)
	}
	if !waitsDebugger && os.Getenv("WAITDEBUGGER") == "" &&
		os.Getenv("WAIT_DEBUGGER") == "" {
		return
	}
	pid := os.Getpid()
	fmt.Fprintf(os.Stderr, "Process %d is waiting for debugger to attach.\n", pid)
	for {
		time.Sleep(1 * time.Second)
		if debuggerProcessExists(pid) {
			break
		}
	}
	fmt.Fprintf(os.Stderr, "Debugger attached.\n")
	time.Sleep(1 * time.Second)
}

func init() {
	waitDebugger()
}
