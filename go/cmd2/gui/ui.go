package main

import (
	"fmt"
	"image"

	"github.com/guigui-gui/guigui"
	"github.com/guigui-gui/guigui/basicwidget"
	"github.com/hajimehoshi/ebiten/v2"
)

type Root struct {
	guigui.DefaultWidget

	textInput   basicwidget.TextInput
	counterText basicwidget.Text

	background  basicwidget.Background
	resetButton basicwidget.Button
	decButton   basicwidget.Button
	incButton   basicwidget.Button

	counter         int
	text            string
	shouldTerminate bool
	initialized     bool
}

func (r *Root) AddChildren(context *guigui.Context, adder *guigui.ChildAdder) {
	adder.AddChild(&r.background)
	adder.AddChild(&r.textInput)
	// context.SetFocused(&r.textInput, true)
	// r.textInput.SetValue(r.text)
	// No way to set the caret position?
	// r.textInput.
	// r.textInput
	// r.textInput.ReplaceValueAtSelection(r.text)
	adder.AddChild(&r.counterText)
	adder.AddChild(&r.resetButton)
	adder.AddChild(&r.decButton)
	adder.AddChild(&r.incButton)
}

func (r *Root) Update(context *guigui.Context) error {
	if r.shouldTerminate {
		return ebiten.Termination
	}
	// if !r.initialized {
	// 	r.textInput.ReplaceValueAtSelection(r.text)
	// 	context.SetFocused(&r.textInput, true)
	// 	r.initialized = true
	// }

	r.counterText.SetSelectable(true)
	r.counterText.SetBold(true)
	r.counterText.SetHorizontalAlign(basicwidget.HorizontalAlignCenter)
	r.counterText.SetVerticalAlign(basicwidget.VerticalAlignMiddle)
	r.counterText.SetScale(4)
	r.counterText.SetValue(fmt.Sprintf("%d", r.counter))

	r.textInput.SetOnKeyJustPressed(func(key ebiten.Key) (handled bool) {
		switch key.String() {
		case "Enter":
			// handled = true
			r.shouldTerminate = true
		}
		return
	})

	r.textInput.SetOnValueChanged(func(text string, _ bool) {
		r.text = text
	})

	r.resetButton.SetText("Reset")
	r.resetButton.SetOnUp(func() {
		r.counter = 0
	})
	context.SetEnabled(&r.resetButton, r.counter != 0)

	r.decButton.SetText("Decrement")
	r.decButton.SetOnUp(func() {
		r.counter--
	})

	r.incButton.SetText("Increment")
	r.incButton.SetOnUp(func() {
		r.counter++
	})

	return nil
}

func (r *Root) Layout(context *guigui.Context, widget guigui.Widget) image.Rectangle {
	switch widget {
	case &r.background:
		return context.Bounds(r)
	}

	u := basicwidget.UnitSize(context)
	return (guigui.LinearLayout{
		Direction: guigui.LayoutDirectionVertical,
		Items: []guigui.LinearLayoutItem{
			{
				Widget: &r.textInput,
				Size:   guigui.FixedSize(u),
			},
			{
				Widget: &r.counterText,
				Size:   guigui.FlexibleSize(1),
			},
			{
				Size: guigui.FixedSize(u),
				Layout: guigui.LinearLayout{
					Direction: guigui.LayoutDirectionHorizontal,
					Items: []guigui.LinearLayoutItem{
						{
							Widget: &r.resetButton,
							Size:   guigui.FixedSize(6 * u),
						},
						{
							Size: guigui.FlexibleSize(1),
						},
						{
							Widget: &r.decButton,
							Size:   guigui.FixedSize(6 * u),
						},
						{
							Widget: &r.incButton,
							Size:   guigui.FixedSize(6 * u),
						},
					},
					Gap: u / 2,
				},
			},
		},
		Gap: u,
	}).WidgetBounds(context, context.Bounds(r).Inset(u), widget)
}
