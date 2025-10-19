// Package lib is a library.
package lib

import (
	"context"
	"fmt"
	"log"
)

type ctxKey struct{}

type serviceLocatorI interface {
	GetFooService() int
	// GetBazService() int
}

// ContextWithServiceLocator returns a derived context that points to the parent context. In the derived context, the associated value is a service locator for this package.
func ContextWithServiceLocator(ctx context.Context, sl serviceLocatorI) context.Context {
	ctxRet := context.WithValue(ctx, ctxKey{}, sl)
	// ctxRet = sublib.ContextWithServiceLocator(ctxRet, sl)
	return ctxRet
}

// serviceLocator retrieves the service locator for this package from the context value.
func serviceLocator(ctx context.Context) serviceLocatorI {
	if sl, ok := ctx.Value(ctxKey{}).(serviceLocatorI); ok {
		return sl
	}
	panic(fmt.Errorf("service locator for this package is not set in the context"))
}

// DoSomething does something.
func DoSomething(ctx context.Context) {
	sl := serviceLocator(ctx)
	log.Println("518a101", sl.GetFooService())
}
