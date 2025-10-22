package main

import (
	"fmt"
	"image"
	"sync"

	"github.com/guigui-gui/guigui"
	"github.com/hajimehoshi/ebiten/v2"
)

// NoValue represents an empty value type for situations where no actual value is needed.
type NoValue = struct{}

// Finalizer is an interface that need cleanup when destroyed.
type Finalizer interface {
	Finalize()
}

func entryGUITimer(params *timerParams) (err error) {
	var rootWindow guigui.Widget
	var title string
	var childWidgets []guigui.Widget
	var wg sync.WaitGroup
	switch params.num {
	case 0:
		return
	case 1:
		title = "Timer"
		timerWidget := NewTimerWidget(0, params, &wg)
		rootWindow = timerWidget
		childWidgets = append(childWidgets, timerWidget)
	default:
		title = "Timers"
		indexedViewWidget := NewIndexedViewWidget()
		for i := range params.num {
			timerWidget := NewTimerWidget(i, params, &wg)
			indexedViewWidget.AddWidget(fmt.Sprintf("Timer %d", i), timerWidget)
			childWidgets = append(childWidgets, timerWidget)
		}
		rootWindow = indexedViewWidget
	}
	opt := guigui.RunOptions{
		Title:         title,
		WindowMinSize: image.Pt(600, 300),
		RunGameOptions: &ebiten.RunGameOptions{
			ApplePressAndHoldEnabled: true,
		},
	}
	err = guigui.Run(rootWindow, &opt)
	if err != nil {
		return
	}
	for _, widget := range childWidgets {
		if finalizer, ok := widget.(Finalizer); ok {
			finalizer.Finalize()
		}
	}
	wg.Wait()
	return
}
