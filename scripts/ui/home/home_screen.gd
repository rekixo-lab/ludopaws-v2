extends Control

signal route_requested(route: StringName)

const Preview := preload("res://scripts/ui/preview/meadow_preview.gd")
const DESIGN_SIZE := Vector2(430, 826)
const MIN_LAYOUT_HEIGHT := 760.0
const HERO_DESIGN_HEIGHT := 454.0
const HERO_WIDE := preload("res://assets/ui/brand/home_woodland_hero.webp")
const HERO_PORTRAIT := preload("res://assets/ui/brand/home_woodland_hero_portrait.webp")

var preview: Control

@onready var canvas: Control = $Canvas
@onready var play_content: Control = $Canvas/PlayContent
@onready var hero: TextureRect = $Canvas/PlayContent/WoodlandHero
@onready var brand: Control = $Canvas/PlayContent/BrandTitle
@onready var navigation = $Canvas/BottomNavigation

func _ready() -> void:
	get_window().content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	get_window().content_scale_size = Vector2i(DESIGN_SIZE)
	resized.connect(_fit_canvas)
	_fit_canvas()
	for item: Button in get_tree().get_nodes_in_group("home_routes"):
		if is_ancestor_of(item):
			var route: StringName = item.get_meta("route")
			if item.get_parent() == $Canvas/PlayContent/Currencies/Gems:
				route = &"wallet"
			item.pressed.connect(_request_route.bind(route))
	preview = Preview.new()
	canvas.add_child(preview)
	canvas.move_child(preview, navigation.get_index())
	preview.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	preview.hide()
	preview.top_inset = -hero.offset_top
	preview.route_changed.connect(_update_visible_route)
	route_requested.connect(preview.open)
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--preview-route="):
			_request_route(StringName(argument.trim_prefix("--preview-route=")))
		if argument.begins_with("--capture-home="):
			_capture_preview(argument.trim_prefix("--capture-home="))

func _fit_canvas() -> void:
	var area := _safe_content_area()
	if area.size.x <= 0.0 or area.size.y <= 0.0:
		return
	var factor := minf(area.size.x / DESIGN_SIZE.x, area.size.y / MIN_LAYOUT_HEIGHT)
	canvas.size = Vector2(DESIGN_SIZE.x, area.size.y / factor)
	canvas.scale = Vector2.ONE * factor
	canvas.position = area.position + Vector2((area.size.x - DESIGN_SIZE.x * factor) * 0.5, 0.0)
	# Draw the artwork into the cutout inset while keeping controls inside it.
	hero.offset_top = -area.position.y / factor
	if is_instance_valid(preview):
		preview.top_inset = -hero.offset_top
	var available_hero_height := HERO_DESIGN_HEIGHT + canvas.size.y - DESIGN_SIZE.y - hero.offset_top
	_fit_hero(available_hero_height)

func _fit_hero(available_height: float) -> void:
	var wide_layout := DESIGN_SIZE.x / available_height >= 1.0
	hero.texture = HERO_WIDE if wide_layout else HERO_PORTRAIT
	var brand_scale := 0.77 if wide_layout else 1.0
	brand.scale = Vector2.ONE * brand_scale
	brand.position = Vector2((DESIGN_SIZE.x - brand.size.x * brand_scale) * 0.5 + 2.0, 57.0 if wide_layout else 65.0)
	var source_size := hero.texture.get_size()
	var art_height := DESIGN_SIZE.x * source_size.y / source_size.x if wide_layout else available_height
	hero.offset_bottom = hero.offset_top + art_height - canvas.size.y

	# Sample a proportional crop rather than changing any object's aspect ratio.
	var frame_size := Vector2(DESIGN_SIZE.x, art_height)
	var uniform_scale := maxf(frame_size.x / source_size.x, frame_size.y / source_size.y)
	var visible_fraction := frame_size / (source_size * uniform_scale)
	var hero_material := hero.material as ShaderMaterial
	hero_material.set_shader_parameter("visible_fraction", visible_fraction)
	hero_material.set_shader_parameter("crop_origin", (Vector2.ONE - visible_fraction) * 0.5)
	hero_material.set_shader_parameter("fade_start", 0.91 if wide_layout else 0.85)

func _safe_content_area() -> Rect2:
	var area := Rect2(Vector2.ZERO, size)
	if OS.get_name() != "Android":
		return area
	var window_pixels := get_window().size
	if window_pixels.x <= 0 or window_pixels.y <= 0:
		return area
	var safe_pixels := DisplayServer.get_display_safe_area().intersection(Rect2i(Vector2i.ZERO, window_pixels))
	if not safe_pixels.has_area():
		return area
	var units_per_pixel := size / Vector2(window_pixels)
	return Rect2(Vector2(safe_pixels.position) * units_per_pixel, Vector2(safe_pixels.size) * units_per_pixel)

func _request_route(route: StringName) -> void:
	route_requested.emit(route)

func _update_visible_route(route: StringName) -> void:
	play_content.visible = route == &"play"
	navigation.visible = route in [&"play", &"rewards", &"shop", &"profile", &"online", &"team_up", &"friends"]
	navigation.select_route(route if route in [&"rewards", &"shop", &"profile"] else &"play")

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and is_instance_valid(preview) and preview.visible:
		preview.back()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and is_instance_valid(preview) and preview.visible:
		preview.back()
		get_viewport().set_input_as_handled()

func _capture_preview(path: String) -> void:
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var error := get_viewport().get_texture().get_image().save_png(path)
	get_tree().quit(error)
