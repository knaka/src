package main

import (
	"bytes"
	"context"
	"io"
	"strings"
	"testing"
	"time"
)

func TestNewTimer_CancelAfter5Point5Seconds(t *testing.T) {
	const testCancelDelayMs = 5500

	t.Parallel()

	// Create context with 10 second timeout
	ctx := context.Background()
	ctx, cancel := context.WithTimeout(ctx, 10*time.Second)
	defer cancel()

	// Cancel context after 5.5 seconds
	go func() {
		time.Sleep(testCancelDelayMs * time.Millisecond)
		cancel()
	}()

	// Run the timer
	startTime := time.Now()
	timeStrCh := NewTimer(ctx, DefaultTimerConfig())

	// Collect time strings from channel
	var timeStrings []string
	for timeStr := range timeStrCh {
		timeStrings = append(timeStrings, timeStr)
	}
	elapsed := time.Since(startTime)

	// Verify timing (should be around 5.5 seconds, not 10)
	if elapsed >= 10*time.Second {
		t.Errorf("Timer ran too long: %v, expected around 5.5 seconds", elapsed)
	}

	if elapsed < 5*time.Second {
		t.Errorf("Timer stopped too early: %v, expected at least 5 seconds", elapsed)
	}

	// Should have approximately 5-6 time strings (5.5 seconds with 1 second intervals)
	if len(timeStrings) < 5 || len(timeStrings) > 6 {
		t.Errorf("Expected 5 or 6 time strings, got %d", len(timeStrings))
	}

	t.Logf("Collected %d time strings in %v", len(timeStrings), elapsed)
	for i, timeStr := range timeStrings {
		t.Logf("Time string %d: %s", i+1, timeStr)
	}
}

// createPipe creates a pipe for stdin simulation in tests
func createPipe(_ *testing.T) (io.Reader, io.WriteCloser) {
	r, w := io.Pipe()
	return r, w
}

func TestTimerEntry_InputAfter5Point5Seconds(t *testing.T) {
	t.Parallel()

	const testInputDelayMs = 5500

	// Create a pipe for stdin simulation
	stdinReader, stdinWriter := createPipe(t)
	var stdout, stderr bytes.Buffer

	// Send input signal after 5.5 seconds
	go func() {
		time.Sleep(testInputDelayMs * time.Millisecond)
		stdinWriter.Write([]byte("\n"))
		stdinWriter.Close()
	}()

	// Run the timer with 10 second timeout
	startTime := time.Now()
	err := timerEntry([]string{"--timeout", "10"}, &entryParams{
		exeName: "timer",
		stdin:   stdinReader,
		stdout:  &stdout,
		stderr:  &stderr,
	})
	elapsed := time.Since(startTime)

	if err != nil {
		t.Errorf("Expected no error, got %v", err)
	}

	// Verify timing (should be around 5.5 seconds, not 10)
	if elapsed >= 10*time.Second {
		t.Errorf("Timer ran too long: %v, expected around 5.5 seconds", elapsed)
	}

	if elapsed < 5*time.Second {
		t.Errorf("Timer stopped too early: %v, expected at least 5 seconds", elapsed)
	}

	// Should show "Enter " message
	stderrOutput := stderr.String()
	if !strings.Contains(stderrOutput, "Enter ") {
		t.Errorf("Expected stderr to contain 'Enter ', got: %s", stderrOutput)
	}

	// Should have approximately 5-6 time strings (5.5 seconds with 1 second intervals)
	stdoutOutput := stdout.String()
	timeStrings := strings.Split(strings.TrimSpace(stdoutOutput), "\n")
	if stdoutOutput == "" {
		timeStrings = []string{}
	}

	if len(timeStrings) < 5 || len(timeStrings) > 6 {
		t.Errorf("Expected 5 or 6 time strings, got %d", len(timeStrings))
	}

	t.Logf("Collected %d time strings in %v", len(timeStrings), elapsed)
	for i, timeStr := range timeStrings {
		t.Logf("Time string %d: %s", i+1, timeStr)
	}
}

func TestTimerEntry_Timeout(t *testing.T) {
	t.Parallel()

	const testTimeoutSeconds = 5

	// Create a pipe for stdin simulation (but don't send anything)
	stdinReader, stdinWriter := createPipe(t)
	defer stdinWriter.Close()

	var stdout, stderr bytes.Buffer

	// Run the timer
	startTime := time.Now()
	err := timerEntry([]string{"--timeout", "5"}, &entryParams{
		exeName: "timer",
		stdin:   stdinReader,
		stdout:  &stdout,
		stderr:  &stderr,
	})
	elapsed := time.Since(startTime)

	if err != nil {
		t.Errorf("Expected no error, got %v", err)
	}

	// Verify timing (should be around testTimeoutSeconds)
	minTime := time.Duration(testTimeoutSeconds*900) * time.Millisecond  // 90% of timeout
	maxTime := time.Duration(testTimeoutSeconds*1250) * time.Millisecond // 125% of timeout
	if elapsed < minTime || elapsed > maxTime {
		t.Errorf("Timer elapsed time %v, expected around %d seconds", elapsed, testTimeoutSeconds)
	}

	// Should show "timeout" message
	stderrOutput := stderr.String()
	if !strings.Contains(stderrOutput, "timeout") {
		t.Errorf("Expected stderr to contain 'timeout', got: %s", stderrOutput)
	}

	// Should have approximately testTimeoutSeconds time strings
	stdoutOutput := stdout.String()
	timeStrings := strings.Split(strings.TrimSpace(stdoutOutput), "\n")
	if stdoutOutput == "" {
		timeStrings = []string{}
	}

	expectedMin := testTimeoutSeconds - 1
	expectedMax := testTimeoutSeconds + 1
	if len(timeStrings) < expectedMin || len(timeStrings) > expectedMax {
		t.Errorf("Expected %d-%d time strings, got %d", expectedMin, expectedMax, len(timeStrings))
	}

	t.Logf("Collected %d time strings in %v (timeout)", len(timeStrings), elapsed)
}

func TestTimerEntry_ImmediateInput(t *testing.T) {
	t.Parallel()

	// Use strings.Reader with newline for immediate input
	var stdout, stderr bytes.Buffer

	params := &entryParams{
		exeName: "timer",
		stdin:   strings.NewReader("\n"),
		stdout:  &stdout,
		stderr:  &stderr,
	}

	// Run the timer
	startTime := time.Now()
	err := timerEntry([]string{"--timeout", "10"}, params)
	elapsed := time.Since(startTime)

	if err != nil {
		t.Errorf("Expected no error, got %v", err)
	}

	// Should stop almost immediately
	if elapsed > 1*time.Second {
		t.Errorf("Timer ran too long: %v, expected immediate stop", elapsed)
	}

	// Should show "Enter ..." message
	stderrOutput := stderr.String()
	if !strings.Contains(stderrOutput, "Enter ") {
		t.Errorf("Expected stderr to contain 'Enter ', got: %s", stderrOutput)
	}

	// Should have 0 or 1 time strings since it stops immediately
	stdoutOutput := stdout.String()
	timeStrings := strings.Split(strings.TrimSpace(stdoutOutput), "\n")
	if stdoutOutput == "" {
		timeStrings = []string{}
	}

	if len(timeStrings) > 1 {
		t.Errorf("Expected 0 or 1 time strings, got %d", len(timeStrings))
	}

	t.Logf("Collected %d time strings in %v (immediate)", len(timeStrings), elapsed)
}

func TestTimerEntry_Help(t *testing.T) {
	var stdout, stderr bytes.Buffer

	params := &entryParams{
		exeName: "test-timer",
		stdin:   strings.NewReader(""),
		stdout:  &stdout,
		stderr:  &stderr,
	}

	err := timerEntry([]string{"--help"}, params)
	if err != nil {
		t.Errorf("Expected no error, got %v", err)
	}

	output := stderr.String()
	if !strings.Contains(output, "Usage:") {
		t.Errorf("Expected help output to contain 'Usage:', got: %s", output)
	}
	if !strings.Contains(output, "--help") {
		t.Errorf("Expected help output to contain '--help', got: %s", output)
	}
	if !strings.Contains(output, "--timeout") {
		t.Errorf("Expected help output to contain '--timeout', got: %s", output)
	}
}
