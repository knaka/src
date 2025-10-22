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

// NoValue represents an empty value type for situations where no actual value is needed.
type NoValue = struct{}

// TimerWidget is timer widget.
type TimerWidget struct {
	guigui.DefaultWidget

	background  basicwidget.Background
	timeText    basicwidget.Text
	startButton basicwidget.Button
	stopButton  basicwidget.Button

	index  int
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
	w.startButton.SetText("Start")
	gctx.SetEnabled(&w.startButton, w.cancel == nil)
	w.startButton.SetOnUp(func() {
		ctx, cancel := context.WithTimeout(context.Background(), time.Duration(w.params.timeout)*time.Second)
		go runTicker(ctx, func(timeStr string) {
			fmt.Fprintf(w.params.stdout, "Timer %d ticked: %s\n", w.index, timeStr)
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
		guigui.RequestRedraw(&w.timeText)
	})

	return
}

var _ guigui.Widget = &TimerWidget{}

// MultiWidget is a generic widget that manages multiple child widgets with a sidebar list.
type MultiWidget[T guigui.Widget] struct {
	guigui.DefaultWidget

	background basicwidget.Background
	panel      basicwidget.Panel
	list       basicwidget.List[NoValue]

	widgets []T
	index   int
}

// AddChildren adds child widgets to the MultiWidget.
func (w *MultiWidget[T]) AddChildren(_ *guigui.Context, adder *guigui.ChildAdder) {
	adder.AddChild(&w.panel)
	adder.AddChild(w.widgets[w.index])
}

// Update updates the MultiWidget's state and configures the panel and list.
func (w *MultiWidget[T]) Update(_ *guigui.Context) error {
	w.panel.SetStyle(basicwidget.PanelStyleSide)
	w.panel.SetBorders(basicwidget.PanelBorder{
		End: true,
	})
	w.panel.SetContent(&w.list)
	w.panel.SetContentConstraints(basicwidget.PanelContentConstraintsFixedWidth)
	w.list.SetOnItemSelected(func(index int) {
		_, ok := w.list.ItemByIndex(index)
		if !ok {
			w.index = 0
			return
		}
		w.index = index
	})
	return nil
}

// Layout calculates the layout for child widgets within the MultiWidget.
func (w *MultiWidget[T]) Layout(context *guigui.Context, widget guigui.Widget) image.Rectangle {
	switch widget {
	case &w.background:
		return context.Bounds(w)
	}
	layout := guigui.LinearLayout{
		Direction: guigui.LayoutDirectionHorizontal,
		Items: []guigui.LinearLayoutItem{
			{
				Widget: &w.panel,
				Size:   guigui.FixedSize(8 * basicwidget.UnitSize(context)),
			},
			{
				Size: guigui.FlexibleSize(1),
			},
		},
	}
	if widget == &w.panel {
		return layout.WidgetBounds(context, context.Bounds(w), widget)
	}
	return layout.ItemBounds(context, context.Bounds(w), 1)
}

func entryGUITimer(params *timerParams) (err error) {
	var rootWindow guigui.Widget
	var title string
	if params.num == 0 {
		return nil
	} else if params.num == 1 {
		title = "Timer"
		timerWidget := TimerWidget{
			params: params,
			index:  0,
		}
		timerWidget.timeText.SetValue("N/A")
		rootWindow = &timerWidget
	} else {
		title = "Timers"
		var listItems []basicwidget.ListItem[NoValue]
		var timerWidgets []*TimerWidget
		for i := range params.num {
			listItems = append(listItems, basicwidget.ListItem[NoValue]{
				Text: fmt.Sprintf("Timer %d", i),
			},
			)
			timerWidgets = append(timerWidgets, &TimerWidget{
				index:  i,
				params: params,
			})
			timerWidgets[i].timeText.SetValue(fmt.Sprintf("N/A (%d)", i))
		}
		multiWidget := MultiWidget[*TimerWidget]{
			widgets: timerWidgets,
			index:   0,
		}
		multiWidget.list.SetItems(listItems)
		multiWidget.list.SetStyle(basicwidget.ListStyleSidebar)
		rootWindow = &multiWidget
	}
	opt := guigui.RunOptions{
		Title:         title,
		WindowMinSize: image.Pt(600, 300),
		RunGameOptions: &ebiten.RunGameOptions{
			ApplePressAndHoldEnabled: true,
		},
	}
	return guigui.Run(rootWindow, &opt)
}
