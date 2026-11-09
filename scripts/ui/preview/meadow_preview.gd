extends Control
## Connects the finalized Home entry points to the Moonlit Meadow UI previews.

signal route_changed(route: StringName)

const UI = preload("res://scripts/ui/preview/meadow_controls.gd")
const State = preload("res://scripts/ui/preview/preview_state.gd")
const Lobby = preload("res://scripts/ui/preview/lobby_pages.gd")
const Match = preload("res://scripts/ui/preview/match_pages.gd")
const Hub = preload("res://scripts/ui/preview/hub_pages.gd")

const TITLES := {
	&"online": ["Online", "globe"], &"team_up": ["Team Up", "team"],
	&"friends": ["Friends", "friends"], &"robot": ["Play Robot", "robot"],
	&"pass_and_play": ["Pass & Play", "pass_play"], &"room": ["Room Invite", "friends"],
	&"match": ["", ""], &"results": ["Match Results", "coin"],
	&"details": ["Match Details", "ludo_board"], &"settings": ["Settings", "paw"],
	&"profile": ["Profile", "profile"], &"badges": ["Badges", "paw"],
	&"leaderboard": ["Leaderboard", "coin"], &"invite": ["Invite Friends", "friends"],
	&"rewards": ["Rewards", "gift"], &"collections": ["Collections", "gift"],
	&"shop": ["Shop", "shop"], &"wallet": ["Wallet", "gem"],
}
const TABS := [&"play", &"rewards", &"shop", &"profile"]

var state := State.new()
var history: Array[StringName] = []
var current: StringName = &"play"
var scroll: ScrollContainer
var body: VBoxContainer
var overlay: Control
var scenery: TextureRect
var top_inset := 0.0:
	set(value):
		top_inset = value
		if is_instance_valid(scenery):
			scenery.offset_top = -top_inset

func open(route: StringName) -> void:
	if route == &"continue_match":
		start_match(state.match_mode, state.saved_preview)
		return
	if route in TABS:
		history.clear()
		_show(route)
	elif route in TITLES and route != current:
		history.append(current)
		_show(route)

func open_nested(route: StringName) -> void:
	if route in TITLES and route != current:
		history.append(current)
		_show(route)

func back() -> void:
	if is_instance_valid(overlay):
		dismiss()
	elif current == &"match" and state.setting("confirm_exit", true):
		Match.save_dialog(self)
	else:
		_pop()

func _pop() -> void:
	if history.is_empty():
		_show(&"play")
	else:
		_show(history.pop_back())

func start_match(mode: StringName, resume := false) -> void:
	if not resume:
		reset_match()
	state.saved_preview = false
	state.match_mode = mode
	if current not in [&"match", &"results"]:
		history.append(current)
	_show(&"match")

func reset_match() -> void:
	state.handoff_pending = false
	state.last_roll = 0
	state.turn = 0
	state.events.clear()

func replay() -> void:
	start_match(state.match_mode)

func finish_match() -> void:
	# Replacing the board route keeps Results → Home/Rematch predictable.
	_show(&"results")

func refresh() -> void:
	var position := scroll.scroll_vertical
	_show(current)
	scroll.set_deferred("scroll_vertical", position)

func select_tab(index: int, group: String) -> void:
	state.tab_indexes[group] = index
	refresh()

func _show(route: StringName) -> void:
	current = route
	for child in get_children():
		remove_child(child)
		child.queue_free()
	overlay = null
	visible = route != &"play"
	route_changed.emit(route)
	if not visible:
		return

	var base := ColorRect.new()
	base.color = Color("#071c18")
	add_child(base)
	base.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	var backdrop := UI.art("moonlit_screen")
	if backdrop == null:
		backdrop = UI.texture("res://assets/ui/backgrounds/moonlit_meadow.webp")
	scenery = UI.image(self, backdrop, 0, true)
	scenery.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	scenery.offset_top = -top_inset
	var has_tabs := route in [&"online", &"team_up", &"friends", &"rewards", &"shop", &"profile"]
	scroll = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	add_child(scroll)
	scroll.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	scroll.offset_left = 15
	scroll.offset_right = -15
	scroll.offset_top = 15
	scroll.offset_bottom = -92 if has_tabs else -12
	body = UI.column(scroll, 8 if route in [&"match", &"results"] else 12)
	body.size_flags_horizontal = SIZE_EXPAND_FILL
	if route not in [&"online", &"team_up", &"friends"]:
		var brand := preload("res://scenes/ui/components/brand_title.tscn").instantiate() as Control
		var brand_area := Control.new()
		brand_area.custom_minimum_size.y = 103
		body.add_child(brand_area)
		brand_area.add_child(brand)
		brand.scale = Vector2.ONE * 0.68
		brand.position = Vector2(116, -4)
		var subtitle_panel := PanelContainer.new()
		subtitle_panel.position = Vector2(124, 78)
		subtitle_panel.size = Vector2(152, 24)
		var subtitle_skin := UI.surface(Color("#442817"), Color("#af7e42"), 8)
		subtitle_skin.set_content_margin_all(3)
		subtitle_panel.add_theme_stylebox_override("panel", subtitle_skin)
		brand_area.add_child(subtitle_panel)
		var subtitle := UI.label(subtitle_panel, "Moonlit Meadow", 13, true)
		subtitle.autowrap_mode = TextServer.AUTOWRAP_OFF
	var header: Array = TITLES[route]
	if route == &"match":
		header = [Match.mode_title(state.match_mode), Match.mode_icon(state.match_mode)]
	_header(header[0], header[1])
	if route in [&"online", &"team_up", &"friends", &"robot", &"pass_and_play", &"room"]:
		Lobby.build(self)
	elif route in [&"match", &"results", &"details"]:
		Match.build(self)
	else:
		Hub.build(self)

func _header(title: String, glyph: String) -> void:
	var bar := UI.row(body)
	bar.alignment = BoxContainer.ALIGNMENT_CENTER
	var go_back := UI.button(bar, "‹", back, false, "", 55)
	go_back.custom_minimum_size.x = 45
	go_back.add_theme_font_size_override("font_size", 29)
	go_back.size_flags_horizontal = SIZE_SHRINK_CENTER
	go_back.tooltip_text = "Back"
	var frame := Control.new()
	frame.custom_minimum_size.y = 68
	frame.size_flags_horizontal = SIZE_EXPAND_FILL
	bar.add_child(frame)
	var plaque := UI.art("woodland_header")
	var wood := UI.image(frame, plaque if plaque != null else UI.WOOD, 0)
	wood.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	if plaque == null:
		wood.stretch_mode = TextureRect.STRETCH_SCALE
		var finish := ShaderMaterial.new()
		finish.shader = UI.WOOD_SHADER
		wood.material = finish
	var heading := UI.row(frame)
	heading.alignment = BoxContainer.ALIGNMENT_CENTER
	heading.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	heading.mouse_filter = MOUSE_FILTER_IGNORE
	if not glyph.is_empty():
		var stamp := UI.image(heading, UI.icon(glyph), 30)
		stamp.custom_minimum_size.x = 31
	var title_label := UI.label(heading, title, 23, true)
	title_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	var settings := UI.button(bar, "⚙", open.bind(&"settings"), false, "", 55)
	settings.custom_minimum_size.x = 45
	settings.size_flags_horizontal = SIZE_SHRINK_CENTER
	settings.tooltip_text = "Settings"
	if current == &"settings":
		settings.visible = false

func dialog(title: String, message: String) -> VBoxContainer:
	dismiss()
	var veil := ColorRect.new()
	veil.color = Color("#05100edc")
	add_child(veil)
	veil.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	overlay = veil
	var center := CenterContainer.new()
	veil.add_child(center)
	center.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	var frame := UI.panel(center)
	frame.get_parent().custom_minimum_size.x = 330
	var sign := Control.new()
	sign.custom_minimum_size.y = 59
	frame.add_child(sign)
	var wood := UI.image(sign, UI.art("woodland_header"), 0)
	wood.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	var heading := UI.label(sign, title, 23, true)
	heading.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	heading.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	UI.label(frame, message, 16, true)
	return frame

func dismiss() -> void:
	if is_instance_valid(overlay):
		remove_child(overlay)
		overlay.queue_free()
		overlay = null
		scroll.show()
		scroll.mouse_filter = MOUSE_FILTER_STOP

func notice(title: String, message: String) -> void:
	UI.button(dialog(title, message), "OK", dismiss, true)

func copy_text(value: String) -> void:
	DisplayServer.clipboard_set(value)
	notice("Copied", value)

func go_home() -> void:
	history.clear()
	_show(&"play")
