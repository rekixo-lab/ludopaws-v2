extends Control

signal route_requested(route: StringName)

const DESIGN_SIZE := Vector2(430, 826)
const MIN_LAYOUT_HEIGHT := 760.0
const HERO_DESIGN_HEIGHT := 454.0
const HERO_WIDE := preload("res://assets/ui/brand/home_woodland_hero.webp")
const HERO_PORTRAIT := preload("res://assets/ui/brand/home_woodland_hero_portrait.webp")

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
			item.pressed.connect(_request_route.bind(item.get_meta("route")))
	for argument in OS.get_cmdline_user_args():
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
	if navigation.select_route(route):
		play_content.visible = route == &"play"
	route_requested.emit(route)

func _capture_preview(path: String) -> void:
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var error := get_viewport().get_texture().get_image().save_png(path)
	get_tree().quit(error)
