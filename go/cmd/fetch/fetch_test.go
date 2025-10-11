package main

import (
	"bytes"
	"fmt"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestFetch(t *testing.T) {
	// Create a test HTTP server
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "text/plain")
		fmt.Fprint(w, "test content")
	}))
	defer server.Close()

	// Create a temporary directory for testing
	tempDir, err := os.MkdirTemp("", "fetch_test")
	if err != nil {
		t.Fatalf("Failed to create temp dir: %v", err)
	}
	defer os.RemoveAll(tempDir)

	// Test basic fetch
	err = Fetch(server.URL+"/testfile.txt", WithDir(tempDir))
	if err != nil {
		t.Fatalf("Fetch failed: %v", err)
	}

	// Verify file was created and has correct content
	filePath := filepath.Join(tempDir, "testfile.txt")
	content, err := os.ReadFile(filePath)
	if err != nil {
		t.Fatalf("Failed to read downloaded file: %v", err)
	}

	if string(content) != "test content" {
		t.Errorf("Expected 'test content', got '%s'", string(content))
	}
}

func TestFetchWithVerbose(t *testing.T) {
	// Create a test HTTP server
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "text/plain")
		fmt.Fprint(w, "verbose test content")
	}))
	defer server.Close()

	// Create a temporary directory for testing
	tempDir, err := os.MkdirTemp("", "fetch_verbose_test")
	if err != nil {
		t.Fatalf("Failed to create temp dir: %v", err)
	}
	defer os.RemoveAll(tempDir)

	// Capture stderr output using buffer
	var stderrBuf bytes.Buffer

	// Test fetch with verbose
	err = Fetch(server.URL+"/verbose.txt",
		WithDir(tempDir),
		WithVerbose(true),
		WithStderr(&stderrBuf))
	if err != nil {
		t.Fatalf("Fetch failed: %v", err)
	}

	// Check stderr content
	stderrStr := stderrBuf.String()
	if !strings.Contains(stderrStr, "Fetching") {
		t.Errorf("Expected verbose output to contain 'Fetching', got: %s", stderrStr)
	}
	if !strings.Contains(stderrStr, "Saved to") {
		t.Errorf("Expected verbose output to contain 'Saved to', got: %s", stderrStr)
	}
}

func TestFetchNonExistentURL(t *testing.T) {
	tempDir, err := os.MkdirTemp("", "fetch_error_test")
	if err != nil {
		t.Fatalf("Failed to create temp dir: %v", err)
	}
	defer os.RemoveAll(tempDir)

	// Test fetch with non-existent URL
	err = Fetch("http://localhost:99999/nonexistent", WithDir(tempDir))
	if err == nil {
		t.Error("Expected error for non-existent URL, got nil")
	}
}

func TestFetch404Error(t *testing.T) {
	// Create a test HTTP server that returns 404
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusNotFound)
		fmt.Fprint(w, "Not Found")
	}))
	defer server.Close()

	tempDir, err := os.MkdirTemp("", "fetch_404_test")
	if err != nil {
		t.Fatalf("Failed to create temp dir: %v", err)
	}
	defer os.RemoveAll(tempDir)

	// Test fetch with 404 response
	err = Fetch(server.URL+"/notfound.txt", WithDir(tempDir))
	if err == nil {
		t.Error("Expected error for 404 response, got nil")
	}
	if !strings.Contains(err.Error(), "HTTP 404") {
		t.Errorf("Expected '404' in error message, got: %v", err)
	}
}
