extends RefCounted

const UI = preload("res://scripts/ui/preview/meadow_controls.gd")
const ANIMALS := ["Fox", "Rabbit", "Hedgehog", "Raccoon"]
const PALETTE := ["Red", "Blue", "Yellow", "Green"]
const COLORS := [Color("#45221d"), Color("#14344d")]

static func build(page) -> void:
	match page.current:
		&"online": _online(page)
		&"team_up": _team(page)
		&"friends": _friends(page)
		&"room": _room(page)
		&"robot": _local_setup(page, true)
		&"pass_and_play": _local_setup(page, false)

static func _online(page) -> void:
	var body: VBoxContainer = page.body
	UI.label(body, "Play online with real players.", 19, true)
	var options := UI.row(body)
	for count in [2, 4]:
		UI.button(options, "%s Players" % count, _online_size.bind(page, count), page.state.online_count == count, "team" if count == 2 else "friends", 92)
	UI.label(UI.panel(body), "●   Matchmaking preview", 15, true)
	UI.illustration(body, "online_lakeside", 273)
	UI.button(body, "Find Match", _queue.bind(page, &"online"), true, "globe", 60)

static func _online_size(page, count: int) -> void:
	page.state.online_count = count
	page.refresh()

static func _queue(page, mode: StringName) -> void:
	var title := "Find Team" if mode == &"team_up" else "Find Match"
	var frame: VBoxContainer = page.dialog(title, "This is a UI preview. You can open a sample match or cancel.")
	UI.button(frame, "Open Match Preview", page.start_match.bind(mode), true, "play")
	UI.button(frame, "Cancel Search", page.dismiss)

static func _team(page) -> void:
	var body: VBoxContainer = page.body
	UI.label(body, "Play together with a friend\nagainst another team.", 19, true)
	UI.label(UI.panel(body), "2  vs  2", 34, true)
	var banners := UI.row(body)
	for team in 2:
		var card := UI.panel(banners, "Team Red" if team == 0 else "Team Blue", COLORS[team])
		for seat in 2:
			var index := team * 2 + seat
			var occupied: bool = page.state.team_seats[index]
			UI.button(card, "You  ✓" if occupied else "Seat %s   +" % (seat + 1), _pick_seat.bind(page, index), occupied, "profile", 62)
	UI.illustration(body, "team_meadow", 193)
	UI.button(body, "Find Team", _queue.bind(page, &"team_up"), true, "friends", 60)

static func _pick_seat(page, index: int) -> void:
	var occupied: bool = page.state.team_seats[index]
	page.state.team_seats.fill(false)
	page.state.team_seats[index] = not occupied
	page.refresh()

static func _friends(page) -> void:
	var body: VBoxContainer = page.body
	UI.label(body, "Play with your friends.", 19, true)
	var actions := UI.row(body)
	UI.button(actions, "Create Room", _create_room.bind(page), true, "add", 64)
	UI.button(actions, "Join Room", _ask_code.bind(page), false, "friends", 64)
	var code: String = page.state.room_code
	var rail := UI.row(UI.panel(body))
	var invite_label := UI.label(rail, "Invite Code   %s" % (code if not code.is_empty() else "—"), 19)
	invite_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if not code.is_empty():
		UI.button(rail, "Copy", page.copy_text.bind(code), true)
	UI.label(body, "Your Friends", 24)
	for index in 4:
		var names := ["FoxRider", "BunnyPop", "BearBuddy", "RaccoonPlay"]
		var friend := UI.row(UI.panel(body))
		var avatar := UI.image(friend, UI.animal([0, 1, 2, 5][index]), 47)
		avatar.custom_minimum_size.x = 47
		var identity := UI.column(friend, 0)
		identity.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		UI.label(identity, names[index], 17)
		UI.label(identity, "Sample contact", 13)
		var invite := UI.button(friend, "Invite", page.notice.bind("Invite", "Friend invites will use the multiplayer service when connected."), true, "", 40)
		invite.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	UI.button(body, "Invite Friends", page.open.bind(&"invite"), false, "friends")

static func _create_room(page) -> void:
	page.state.room_host = true
	page.state.room_code = "LP%04d" % randi_range(0, 9999)
	page.open(&"room")

static func _ask_code(page) -> void:
	var frame: VBoxContainer = page.dialog("Join Room", "Enter a room code to preview the room.")
	var code := UI.field(frame, "", "Room code", 8)
	var error := UI.label(frame, "", 14, true)
	UI.button(frame, "Continue", _join_code.bind(page, code, error), true)
	code.grab_focus()

static func _join_code(page, code: LineEdit, error: Label) -> void:
	var value := code.text.strip_edges().to_upper()
	if value.length() < 4 or value.contains("_") or not ("R" + value).is_valid_ascii_identifier():
		error.text = "Use 4–8 letters or digits."
		return
	page.state.room_code = value
	page.state.room_host = false
	page.open(&"room")

static func _room(page) -> void:
	var body: VBoxContainer = page.body
	var room := UI.panel(body)
	UI.label(room, "Room Host", 23, true)
	UI.image(room, UI.animal(0), 126)
	UI.label(room, page.state.setting("display_name", "MeadowFox") if page.state.room_host else "MeadowFox", 21, true)
	UI.label(room, "Room Code", 21, true)
	UI.button(room, page.state.room_code + "   ▣", page.copy_text.bind(page.state.room_code), false, "", 58)
	UI.label(room, "Players: 1 / 4  ·  Preview", 18, true)
	var players := UI.row(room)
	for i in 4:
		var slot := UI.column(players)
		slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		UI.image(slot, UI.animal(0) if i == 0 else UI.icon("paw"), 46)
		UI.label(slot, "Host" if i == 0 else "Waiting…", 13, true)
	UI.button(body, "Open Friends Match", page.start_match.bind(&"friends"), true, "friends", 60)

static func _local_setup(page, robot: bool) -> void:
	var body: VBoxContainer = page.body
	UI.label(body, "Play against smart robots" if robot else "Play together on this device", 18, true)
	var count := UI.panel(body, "Players" if robot else "Number of Players")
	UI.choices(count, [2, 3, 4], page.state.player_count - 2, _set_setup.bind(page, "player_count", 2))
	if robot:
		var difficulty := UI.panel(body, "Difficulty")
		UI.choices(difficulty, ["Easy", "Normal", "Hard"], page.state.difficulty, _set_setup.bind(page, "difficulty", 0))
		var pick := UI.row(UI.panel(body, "Choose Your Animal"))
		for i in ANIMALS.size():
			var item := UI.column(pick, 3)
			item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			UI.image(item, UI.animal([0, 1, 2, 5][i]), 72)
			var option := UI.button(item, ANIMALS[i], _set_setup.bind(i, page, "animal", 0), page.state.animal == i, "", 40)
			option.add_theme_font_size_override("font_size", 12)
	else:
		var setup := UI.panel(body, "Player Setup")
		for i in page.state.player_count:
			var line := UI.row(setup)
			UI.label(line, str(i + 1), 17)
			var entry := UI.field(line, page.state.player_names[i], "Player name")
			entry.text_changed.connect(_set_name.bind(page, i))
			var selector := OptionButton.new()
			for color in PALETTE:
				selector.add_item(color)
			selector.select(page.state.player_colors[i])
			selector.item_selected.connect(_set_color.bind(page, i, selector))
			line.add_child(selector)
	UI.button(body, "Start Game", page.start_match.bind(page.current), true, "play", 60)

static func _set_setup(index: int, page, property: String, offset: int) -> void:
	page.state.set(property, index + offset)
	page.refresh()

static func _set_name(value: String, page, index: int) -> void:
	page.state.player_names[index] = value

static func _set_color(color: int, page, index: int, selector: OptionButton) -> void:
	var previous: int = page.state.player_colors[index]
	var other: int = page.state.player_colors.find(color)
	if other >= 0 and other != index:
		page.state.player_colors[other] = previous
	page.state.player_colors[index] = color
	if other >= 0 and other < page.state.player_count and other != index:
		selector.get_parent().get_parent().get_child(other + 1).get_child(2).select(previous)
