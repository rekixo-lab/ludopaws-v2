extends Control

signal route_requested(route: StringName)

const DESIGN_SIZE := Vector2(430, 826)

@onready var canvas: Control = $Canvas

func _ready() -> void:
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
	var factor := minf(size.x / DESIGN_SIZE.x, size.y / DESIGN_SIZE.y)
	canvas.scale = Vector2.ONE * factor
	canvas.position = (size - DESIGN_SIZE * factor) * 0.5

func _request_route(route: StringName) -> void:
	route_requested.emit(route)

func _capture_preview(path: String) -> void:
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var error := get_viewport().get_texture().get_image().save_png(path)
	get_tree().quit(error)
