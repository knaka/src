// Package ctx manages context for main package.
package ctx

import (
	"context"
	"fmt"
)

type key struct{}

// Params will be associated with a context.
type Params struct {
	Foo int
	Bar string
}

// WithValue returns a derived context that points to the parent context. In the derived context, the associated value is val.
func WithValue(ctx context.Context, val *Params) context.Context {
	return context.WithValue(ctx, key{}, val)
}

// Value retrieves the context value.
func Value(ctx context.Context) (ctxValue *Params, err error) {
	var ok bool
	if ctxValue, ok = ctx.Value(key{}).(*Params); !ok {
		return nil, fmt.Errorf("invalid context")
	}
	return
}
