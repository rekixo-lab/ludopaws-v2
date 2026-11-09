extends Control
## A visual die face for the UI preview and the event history.

const PIPS := [
	[4], [0, 8], [0, 4, 8], [0, 2, 6, 8], [0, 2, 4, 6, 8], [0, 2, 3, 5, 6, 8],
]

var value := 1

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE

func _draw() -> void:
	var frame := StyleBoxFlat.new()
	frame.bg_color = Color("#f4e3bf")
	frame.border_color = Color("#ab8656")
	frame.set_border_width_all(2)
	frame.set_corner_radius_all(10)
	frame.shadow_color = Color("#060d08b0")
	frame.shadow_size = 3
	frame.shadow_offset = Vector2(0, 2)
	draw_style_box(frame, Rect2(Vector2.ZERO, size))
	for pip in PIPS[clampi(value, 1, 6) - 1]:
		var position := Vector2(0.25 + 0.25 * (pip % 3), 0.25 + 0.25 * floori(pip / 3.0)) * size
		draw_circle(position, size.x * 0.063, Color("#282015"), true, -1.0, true)
