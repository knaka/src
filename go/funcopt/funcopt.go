// Package funcopt provides Functional Option Pattern helpers.
package funcopt

// Option represents a configuration option for functional option.
type Option[T any] func(params *T) error

// New creates a functional option.
func New[T any, U any](fn func(*T, U)) func(v U) Option[T] {
	return func(value U) Option[T] {
		return func(params *T) (err error) {
			fn(params, value)
			return nil
		}
	}
}

// NewFailable creates a functional option that can fail.
func NewFailable[T any, U any](fn func(*T, U) error) func(v U) Option[T] {
	return func(value U) Option[T] {
		return func(params *T) (err error) {
			return fn(params, value)
		}
	}
}

// Apply applies a slice of functional options to the given parameters.
func Apply[T any](params *T, opts []Option[T]) (err error) {
	for _, opt := range opts {
		err = opt(params)
		if err != nil {
			return
		}
	}
	return
}
