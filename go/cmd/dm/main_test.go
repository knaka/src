package main

import (
	"bytes"
	"os"
	"testing"

	//revive:disable:dot-imports
	. "github.com/knaka/go-utils"
)

func TestDumpFile(t *testing.T) {
	tempFile := Value(os.CreateTemp("", "file-*.dat"))
	defer (func() {
		Ignore(tempFile.Close())
		Must(os.Remove(tempFile.Name()))
	})()
	data := []byte{0xFF, 0xFF, 0xC0, 0x01, 0xC0, 0xDE, 0xFF, 0xFF}
	Must(tempFile.Write(data))
	Must(tempFile.Close())
	input := Value(os.Open(tempFile.Name()))
	defer (func() { Must(input.Close()) })()
	var buf bytes.Buffer
	Must(dumpStream(
		input,
		&buf,
		false,
	))
	output := buf.String()
	expected := "C0 01 C0 DE"
	if !bytes.Contains([]byte(output), []byte(expected)) {
		t.Errorf("Expected output to contain %q, but got %q", expected, output)
	}
}
