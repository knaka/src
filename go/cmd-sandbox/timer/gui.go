package main

import (
	"context"
	"fmt"
	"image"
	"time"

	"github.com/guigui-gui/guigui"
	"github.com/guigui-gui/guigui/basicwidget"
	"github.com/hajimehoshi/ebiten/v2"
)

// TimerWidget is timer widget.
type TimerWidget struct {
	guigui.DefaultWidget

	background  basicwidget.Background
	timeText    basicwidget.Text
	startButton basicwidget.Button
	stopButton  basicwidget.Button

	i      int
	params *timerParams
	cancel context.CancelFunc
}

// AddChildren adds child widgets.
func (w *TimerWidget) AddChildren(_ *guigui.Context, adder *guigui.ChildAdder) {
	adder.AddChild(&w.background)
	adder.AddChild(&w.timeText)
	adder.AddChild(&w.startButton)
	adder.AddChild(&w.stopButton)
}

// Layout layouts a child widget.
func (w *TimerWidget) Layout(context *guigui.Context, child guigui.Widget) image.Rectangle {
	switch child {
	case &w.background:
		return context.Bounds(w)
	}
	u := basicwidget.UnitSize(context)
	return (guigui.LinearLayout{
		Direction: guigui.LayoutDirectionVertical,
		Items: []guigui.LinearLayoutItem{
			{
				Widget: &w.timeText,
				Size:   guigui.FixedSize(u),
			},
			{
				Size: guigui.FlexibleSize(1),
			},
			{
				Size: guigui.FixedSize(u),
				Layout: guigui.LinearLayout{
					Direction: guigui.LayoutDirectionHorizontal,
					Items: []guigui.LinearLayoutItem{
						{
							Size: guigui.FlexibleSize(1),
						},
						{
							Widget: &w.startButton,
							Size:   guigui.FixedSize(6 * u),
						},
						{
							Widget: &w.stopButton,
							Size:   guigui.FixedSize(6 * u),
						},
					},
					Gap: u / 2,
				},
			},
		},
		Gap: u,
	}).WidgetBounds(context, context.Bounds(w).Inset(u), child)
}

// Update updates the widget.
func (w *TimerWidget) Update(gctx *guigui.Context) (err error) {
	// w.timeText.SetValue(w.timeTextField)

	w.startButton.SetText("Start")
	gctx.SetEnabled(&w.startButton, w.cancel == nil)
	w.startButton.SetOnUp(func() {
		ctx, cancel := context.WithTimeout(context.Background(), time.Duration(w.params.timeout)*time.Second)
		go runTicker(ctx, func(timeStr string) {
			fmt.Fprintf(w.params.stdout, "Timer %d ticked: %s\n", w.i, timeStr)
			w.timeText.SetValue(timeStr)
			guigui.RequestRedraw(&w.timeText)
		})
		w.cancel = cancel
	})

	w.stopButton.SetText("Stop")
	gctx.SetEnabled(&w.stopButton, w.cancel != nil)
	w.stopButton.SetOnUp(func() {
		w.cancel()
		w.cancel = nil
		w.timeText.SetValue("Stopped")
		// w.timeTextField = "Stopped"
		guigui.RequestRedraw(&w.timeText)
	})

	return
}

var _ guigui.Widget = &TimerWidget{}

func entryGUITimer(params *timerParams) (err error) {
	if params.num == 1 {
		rootWindow := TimerWidget{
			params: params,
			i:      0,
		}
		rootWindow.timeText.SetValue("N/A")
		opt := guigui.RunOptions{
			Title:         "Timer",
			WindowMinSize: image.Pt(600, 300),
			RunGameOptions: &ebiten.RunGameOptions{
				ApplePressAndHoldEnabled: true,
			},
		}
		err = guigui.Run(&rootWindow, &opt)
	}
	return
}
