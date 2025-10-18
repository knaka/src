package main

import (
	"bytes"
	"strings"
	"testing"
)

func TestFoobarEntry_Help(t *testing.T) {
	var bufStderr bytes.Buffer
	err := foobarEntry([]string{"--help"}, &entryParams{
		stderr: &bufStderr,
	})
	if err != nil {
		t.Errorf("Expected no error, got %v", err)
	}
	strStderr := bufStderr.String()
	if !strings.Contains(strStderr, "Usage:") {
		t.Errorf("Expected help output to contain 'Usage:', got: %s", strStderr)
	}
}
