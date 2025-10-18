package main

import (
	"bytes"
	"strings"
	"testing"
)

func TestFoobarEntry_Help(t *testing.T) {
	var stdout, stderr bytes.Buffer
	err := foobarEntry([]string{"--help"}, &entryParams{
		exeName: "test-foobar",
		stdin:   strings.NewReader(""),
		stdout:  &stdout,
		stderr:  &stderr,
	})
	if err != nil {
		t.Errorf("Expected no error, got %v", err)
	}
	output := stderr.String()
	if !strings.Contains(output, "Usage:") {
		t.Errorf("Expected help output to contain 'Usage:', got: %s", output)
	}
	if !strings.Contains(output, "test-foobar") {
		t.Errorf("Expected help output to contain 'test-foobar', got: %s", output)
	}
	if !strings.Contains(output, "--help") {
		t.Errorf("Expected help output to contain '--help', got: %s", output)
	}
}
