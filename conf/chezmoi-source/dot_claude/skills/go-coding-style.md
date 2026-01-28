---
name: go-coding-style
description: Go coding style guidelines. Use when writing, editing, or reviewing Go code to ensure consistent coding patterns and avoid common pitfalls.
---

# Go Coding Style

## defer with IIFE

Always use IIFE (Immediately Invoked Function Expression) with `defer` to avoid unexpected behavior.

In Go, `defer` evaluates function arguments immediately at the defer statement, not when the deferred function executes. This can cause subtle bugs:

```go
// BAD: f.Close() is called immediately, not deferred
defer IgnoreError(f.Close())

// BAD: Same problem - the argument is evaluated immediately
defer log.Println(f.Close())

// GOOD: The anonymous function is deferred, its body executes later
defer (func() { IgnoreError(f.Close()) })()

// GOOD: Safe to add error handling later
defer (func() {
    if err := f.Close(); err != nil {
        log.Printf("failed to close: %v", err)
    }
})()
```

Using IIFE consistently prevents bugs when refactoring code, such as wrapping a call with error handling or logging.
