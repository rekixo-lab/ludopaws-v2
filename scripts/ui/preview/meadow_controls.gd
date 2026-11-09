extends RefCounted
## Shared controls for the Moonlit Meadow screens.

const SERIF = preload("res://assets/ui/brand/display_serif.tres")
const INK := Color("#fff0cc")
const GOLD := Color("#d5a65d")
const MINT = preload("res://assets/ui/backgrounds/mint_pill.svg")
const SURFACE = preload("res://assets/ui/backgrounds/mode_card_surface.svg")
const WOOD = preload("res://assets/ui/backgrounds/chestnut_wood_grain.webp")
const WOOD_SHADER = preload("res://assets/ui/backgrounds/wood_panel.gdshader")

static func texture(path: String) -> Texture2D:
	return load(path) as Texture2D if ResourceLoader.exists(path) else null

static func icon(name: String) -> Texture2D:
	return texture("res://assets/ui/icons/%s.svg" % name)

static func art(name: String) -> Texture2D:
	return texture("res://assets/ui/illustrations/%s.webp" % name)

static func image(parent: Control, source: Texture2D, height: int, cover := false) -> TextureRect:
	var view := TextureRect.new()
	view.texture = source
	view.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	view.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED if cover else TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	view.custom_minimum_size.y = height
	view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(view)
	return view

static func illustration(parent: Control, name: String, height: int) -> TextureRect:
	var view := image(parent, art(name), height, true)
	var blend := ShaderMaterial.new()
	blend.shader = preload("res://assets/ui/backgrounds/meadow_illustration.gdshader")
	view.material = blend
	return view

static func animal(index: int) -> Texture2D:
	return atlas("woodland_animals", index, icon("paw"))

static func atlas(name: String, index: int, fallback: Texture2D) -> Texture2D:
	var sheet := art(name)
	if sheet == null:
		return fallback
	var region := AtlasTexture.new()
	var cell := sheet.get_size() / Vector2(3, 2)
	region.atlas = sheet
	region.region = Rect2(Vector2(index % 3, floori(index / 3.0)) * cell, cell)
	region.filter_clip = true
	return region

static func label(parent: Control, value: String, font_size := 18, centered := false) -> Label:
	var item := Label.new()
	item.text = value
	item.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if centered else HORIZONTAL_ALIGNMENT_LEFT
	item.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item.add_theme_font_override("font", SERIF)
	item.add_theme_font_size_override("font_size", font_size)
	item.add_theme_color_override("font_color", INK)
	parent.add_child(item)
	return item

static func column(parent: Control, separation := 10) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", separation)
	parent.add_child(box)
	return box

static func row(parent: Control, separation := 8) -> HBoxContainer:
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", separation)
	parent.add_child(box)
	return box

static func surface(fill: Color, border := GOLD, radius := 16) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(radius)
	style.set_content_margin_all(10.0)
	style.shadow_color = Color(0, 0, 0, 0.48)
	style.shadow_size = 4
	style.shadow_offset = Vector2(0, 3)
	return style

static func panel(parent: Control, heading := "", fill := Color("#0b2920eb")) -> VBoxContainer:
	var frame := PanelContainer.new()
	frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	frame.add_theme_stylebox_override("panel", surface(fill))
	parent.add_child(frame)
	var body := column(frame)
	if not heading.is_empty():
		label(body, heading, 22)
	return body

static func button(parent: Control, title: String, action: Callable, primary := false, glyph := "", height := 47) -> Button:
	var item := Button.new()
	item.text = title
	item.icon = icon(glyph) if not glyph.is_empty() else null
	item.alignment = HORIZONTAL_ALIGNMENT_CENTER
	item.expand_icon = true
	item.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	item.add_theme_constant_override("icon_max_width", 25)
	item.custom_minimum_size.y = height
	item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item.add_theme_font_override("font", SERIF)
	item.add_theme_font_size_override("font_size", 17)
	item.add_theme_color_override("font_color", Color("#06251a") if primary else INK)
	item.add_theme_color_override("font_hover_color", Color("#06251a") if primary else Color.WHITE)
	item.add_theme_color_override("font_pressed_color", Color("#06251a") if primary else INK)
	var skin := StyleBoxTexture.new()
	skin.texture = MINT if primary else SURFACE
	for side in [SIDE_LEFT, SIDE_RIGHT]:
		skin.set_texture_margin(side, 19 if primary else 20)
		skin.set_content_margin(side, 8)
	for side in [SIDE_TOP, SIDE_BOTTOM]:
		skin.set_texture_margin(side, 13 if primary else 18)
		skin.set_content_margin(side, 5)
	item.add_theme_stylebox_override("normal", skin)
	var hover := skin.duplicate() as StyleBoxTexture
	hover.modulate_color = Color("#d6f8dc")
	var pressed := skin.duplicate() as StyleBoxTexture
	pressed.modulate_color = Color("#96bea7")
	item.add_theme_stylebox_override("hover", hover)
	item.add_theme_stylebox_override("pressed", pressed)
	var focus := surface(Color.TRANSPARENT, Color("#b0ffe1"), 14)
	focus.shadow_size = 0
	item.add_theme_stylebox_override("focus", focus)
	parent.add_child(item)
	item.pressed.connect(action)
	return item

static func choices(parent: Control, options: Array, current: int, action: Callable) -> void:
	var line := row(parent)
	for i in options.size():
		button(line, str(options[i]), action.bind(i), i == current)

static func field(parent: Control, value: String, hint := "", max_chars := 24) -> LineEdit:
	var edit := LineEdit.new()
	edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	edit.custom_minimum_size.y = 40
	edit.text = value
	edit.placeholder_text = hint
	edit.max_length = max_chars
	edit.add_theme_stylebox_override("normal", surface(Color("#f1ddb0"), GOLD, 12))
	edit.add_theme_color_override("font_color", Color("#261c12"))
	edit.add_theme_color_override("font_placeholder_color", Color("#65533b"))
	parent.add_child(edit)
	return edit

static func progress(parent: Control, value: int, total: int) -> void:
	var meter := ProgressBar.new()
	meter.custom_minimum_size.y = 20
	meter.max_value = total
	meter.value = value
	meter.show_percentage = false
	meter.add_theme_stylebox_override("background", surface(Color("#0d3327"), GOLD, 10))
	meter.add_theme_stylebox_override("fill", surface(Color("#72dbab"), Color("#b4f6d0"), 10))
	parent.add_child(meter)
