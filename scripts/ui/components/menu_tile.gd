@tool
extends Button

const CARD_SURFACE := preload("res://assets/ui/backgrounds/mode_card_surface.svg")
const LABEL_FONT := preload("res://assets/ui/brand/ui_sans_bold.tres")

@export var title: String = "":
	set(value):
		title = value
		if is_node_ready():
			$Contents/Title.text = title
			tooltip_text = title

@export var glyph: Texture2D:
	set(value):
		glyph = value
		if is_node_ready():
			$Contents/Glyph.texture = glyph

@export var navigation_item := false
@export var current := false
@export_range(0, 64) var glyph_size := 0

func _ready() -> void:
	$Contents/Glyph.texture = glyph
	$Contents/Title.text = title
	tooltip_text = title
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var default_glyph_size := 30 if navigation_item else 46
	$Contents/Glyph.custom_minimum_size = Vector2.ONE * (glyph_size if glyph_size > 0 else default_glyph_size)
	$Contents/Title.add_theme_font_override("font", LABEL_FONT)
	$Contents/Title.add_theme_font_size_override("font_size", 16 if navigation_item else 22)
	if navigation_item:
		var base := Color("#205b43") if current else Color.TRANSPARENT
		var border := Color("#81e9b0") if current else Color.TRANSPARENT
		add_theme_stylebox_override("normal", _style(base, border))
		add_theme_stylebox_override("hover", _style(Color("#64432c") if not current else base.lightened(0.13), border))
		add_theme_stylebox_override("pressed", _style(Color("#4b301f") if not current else base.darkened(0.2), border))
	else:
		add_theme_stylebox_override("normal", _card_style(Color.WHITE))
		add_theme_stylebox_override("hover", _card_style(Color(1.13, 1.13, 1.13)))
		add_theme_stylebox_override("pressed", _card_style(Color(0.82, 0.82, 0.82)))
	add_theme_stylebox_override("focus", _style(Color.TRANSPARENT, Color("#fff0c5")))

func _card_style(tint: Color) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = CARD_SURFACE
	style.modulate_color = tint
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		style.set_texture_margin(side, 22)
	return style

func _style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(13 if navigation_item else 20)
	return style
