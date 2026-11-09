extends RefCounted
## UI-only state shared across routes. Game and service state will have separate owners.

const NAMES := ["Aarav", "Diya", "Kabir", "Myra"]
const SETTINGS_PATH := "user://meadow_ui.cfg"

var player_count := 4
var online_count := 2
var difficulty := 1
var animal := 0
var player_names := NAMES.duplicate()
var player_colors := [0, 1, 2, 3]
var team_seats := [false, false, false, false]
var room_code := ""
var room_host := false
var match_mode: StringName = &"online"
var saved_preview := false
var tab_indexes := {}
var settings := ConfigFile.new()

func _init() -> void:
	settings.load(SETTINGS_PATH)

func set_setting(key: String, value: Variant) -> void:
	settings.set_value("settings", key, value)
	settings.save(SETTINGS_PATH)

func setting(key: String, fallback: Variant) -> Variant:
	return settings.get_value("settings", key, fallback)

var handoff_pending := false
var last_roll := 0
var turn := 0
var events: Array[String] = []
