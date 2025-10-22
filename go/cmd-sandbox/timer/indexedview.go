package main

import (
	"image"

	"github.com/guigui-gui/guigui"
	"github.com/guigui-gui/guigui/basicwidget"
)

// IndexedViewWidget is a widget that manages multiple child widgets with a sidebar list.
type IndexedViewWidget struct {
	guigui.DefaultWidget

	background basicwidget.Background
	panel      basicwidget.Panel
	list       basicwidget.List[NoValue]

	widgets   []guigui.Widget
	listItems []basicwidget.ListItem[NoValue]
	index     int
}

// NewIndexedViewWidget creates a new instance.
func NewIndexedViewWidget() *IndexedViewWidget {
	w := &IndexedViewWidget{
		index: 0,
	}
	w.list.SetStyle(basicwidget.ListStyleSidebar)
	return w
}

// AddWidget adds a widget with a label to the indexed view.
func (w *IndexedViewWidget) AddWidget(label string, widget guigui.Widget) {
	w.listItems = append(w.listItems, basicwidget.ListItem[NoValue]{
		Text: label,
	})
	w.widgets = append(w.widgets, widget)
}

// AddChildren adds child widgets to the IndexedViewWidget.
func (w *IndexedViewWidget) AddChildren(_ *guigui.Context, adder *guigui.ChildAdder) {
	adder.AddChild(&w.panel)
	adder.AddChild(w.widgets[w.index])
}

// Update updates the IndexedViewWidget's state and configures the panel and list.
func (w *IndexedViewWidget) Update(_ *guigui.Context) error {
	w.list.SetItems(w.listItems)
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

// Layout calculates the layout for child widgets within the IndexedViewWidget.
func (w *IndexedViewWidget) Layout(context *guigui.Context, widget guigui.Widget) image.Rectangle {
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
