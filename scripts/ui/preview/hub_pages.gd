extends RefCounted

const UI = preload("res://scripts/ui/preview/meadow_controls.gd")
const ANIMALS := ["Fox", "Bunny", "Hedgehog", "Deer", "Owl", "Raccoon"]
const BADGES := [
	"Ludo Rookie", "Steady Roller", "Win Streaker", "Team Player", "Lucky Roll", "Night Owl",
	"Match Master", "Victory Pro", "Dice Collector", "Streaming Champ", "Friend Circle", "Legend of Meadow",
]

static func build(page) -> void:
	match page.current:
		&"settings": _settings(page)
		&"profile": _profile(page)
		&"badges": _badges(page)
		&"leaderboard": _leaderboard(page)
		&"invite": _invite(page)
		&"rewards": _rewards(page)
		&"collections": _collections(page)
		&"shop": _shop(page)
		&"wallet": _wallet(page)

static func _settings(page) -> void:
	var body: VBoxContainer = page.body
	var audio := UI.panel(body, "Audio")
	_switch(audio, page, "Music", "music")
	_switch(audio, page, "Effects", "effects")
	_switch(audio, page, "Haptics", "haptics")
	var gameplay := UI.panel(body, "Gameplay")
	_switch(gameplay, page, "Auto Roll Dice", "auto_roll", false)
	_setting_options(gameplay, page, "Game Speed", "speed", ["Slow", "Normal", "Fast"], 1)
	_switch(gameplay, page, "Confirm Before Exit", "confirm_exit")
	_switch(UI.panel(body, "Accessibility"), page, "Reduced Motion", "reduced_motion", false)
	_setting_options(UI.panel(body, "Language"), page, "Language", "language", ["English", "हिन्दी"], 0)
	UI.label(body, "Settings are saved on this device. Audio and gameplay options connect in the gameplay phase.", 14, true)

static func _switch(parent: Control, page, title: String, key: String, initial := true) -> void:
	var line := UI.row(parent)
	var label := UI.label(line, title, 17)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var toggle := CheckButton.new()
	toggle.button_pressed = page.state.setting(key, initial)
	toggle.custom_minimum_size = Vector2(56, 33)
	var active := preload("res://assets/ui/icons/switch_on.svg")
	var inactive := preload("res://assets/ui/icons/switch_off.svg")
	toggle.add_theme_icon_override("checked", active)
	toggle.add_theme_icon_override("unchecked", inactive)
	toggle.add_theme_icon_override("checked_mirrored", active)
	toggle.add_theme_icon_override("unchecked_mirrored", inactive)
	toggle.toggled.connect(_save_toggle.bind(page, key))
	line.add_child(toggle)

static func _save_toggle(active: bool, page, key: String) -> void:
	page.state.set_setting(key, active)

static func _setting_options(parent: Control, page, title: String, key: String, options: Array, initial: int) -> void:
	var line := UI.row(parent)
	var label := UI.label(line, title, 17)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var selector := OptionButton.new()
	for option in options:
		selector.add_item(option)
	selector.select(page.state.setting(key, initial))
	selector.item_selected.connect(_save_option.bind(page, key))
	line.add_child(selector)

static func _save_option(index: int, page, key: String) -> void:
	page.state.set_setting(key, index)

static func _profile(page) -> void:
	var body: VBoxContainer = page.body
	var identity := UI.row(UI.panel(body))
	var portrait := UI.image(identity, UI.animal(0), 134)
	portrait.custom_minimum_size.x = 127
	var about := UI.column(identity)
	about.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UI.label(about, page.state.setting("display_name", "MeadowFox"), 23)
	UI.label(about, "Level 1", 16)
	UI.progress(about, 0, 100)
	UI.button(about, "Edit Name", _edit_name.bind(page), false, "", 37)
	var account := UI.panel(body, "Account Link")
	UI.label(account, "Guest · This device", 16)
	UI.button(account, "Manage Account", page.notice.bind("Manage Account", "Account linking will be connected in a later phase."), true)
	var stats := UI.panel(body, "Match Stats")
	for labels in [["Matches Played\n0", "Matches Won\n0"], ["Win Rate\n—", "Best Streak\n0"]]:
		var line := UI.row(stats)
		for item in labels:
			UI.label(UI.panel(line), item, 16, true)
	var links := UI.row(body)
	UI.button(links, "Badges", page.open.bind(&"badges"), false, "paw")
	UI.button(links, "Leaderboard", page.open.bind(&"leaderboard"), false, "coin")
	UI.button(body, "Invite Friends", page.open.bind(&"invite"), true, "friends")

static func _edit_name(page) -> void:
	var dialog: VBoxContainer = page.dialog("Edit Profile", "Choose a display name for this device.")
	var edit := UI.field(dialog, page.state.setting("display_name", "MeadowFox"))
	UI.button(dialog, "Save Name", _save_name.bind(page, edit), true)
	UI.button(dialog, "Cancel", page.dismiss)

static func _save_name(page, edit: LineEdit) -> void:
	var value := edit.text.strip_edges()
	if not value.is_empty():
		page.state.set_setting("display_name", value)
		page.refresh()

static func _badges(page) -> void:
	var body: VBoxContainer = page.body
	var index: int = page.state.tab_indexes.get("badges", 0)
	UI.choices(body, ["All (12)", "Earned (6)", "Locked (6)"], index, page.select_tab.bind("badges"))
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 10)
	body.add_child(grid)
	for i in BADGES.size():
		var earned := i < 6
		if (index == 1 and not earned) or (index == 2 and earned):
			continue
		var badge := UI.panel(grid)
		var stamp := UI.image(badge, UI.atlas("woodland_badges", i % 6, UI.icon("paw")), 62)
		if not earned:
			stamp.modulate = Color("#777e76")
		var name_label := UI.label(badge, BADGES[i], 13, true)
		name_label.custom_minimum_size.y = 21
		if earned:
			UI.label(badge, "✓ Earned", 13, true)
		else:
			UI.progress(badge, 0, 100)
	UI.label(body, "Sample badge progress", 13, true)

static func _leaderboard(page) -> void:
	var body: VBoxContainer = page.body
	var index: int = page.state.tab_indexes.get("leaderboard", 0)
	UI.choices(body, ["Global", "Friends"], index, page.select_tab.bind("leaderboard"))
	UI.illustration(body, "leaderboard_podium", 202)
	var names := ["BunnyAce", "PineRaccoon", "DeerDash", "OtterLuck", "MapleBear", "CloverCat", "HillSquirrel", "MeadowOwl"] if index == 0 else ["FoxRider", "BunnyPop", "BearBuddy", "RaccoonPlay"]
	var rankings := UI.panel(body)
	for i in names.size():
		var line := UI.row(rankings)
		var name_label := UI.label(line, "%d   %s" % [i + 1, names[i]], 16)
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var score := UI.label(line, str(13620 - i * 380), 16)
		score.autowrap_mode = TextServer.AUTOWRAP_OFF
	UI.label(UI.panel(body), "Your rank   —", 20, true)
	UI.label(body, "Sample rankings", 13, true)

static func _invite(page) -> void:
	var body: VBoxContainer = page.body
	UI.illustration(body, "friends_invitation", 208)
	UI.label(body, "Invite friends to LUDO PAWS\nand play together in Moonlit Meadow!", 18, true)
	var code := UI.panel(body, "Your Invite Code")
	UI.label(code, "Available when linked", 19, true)
	UI.button(body, "Share Invite", page.notice.bind("Share Invite", "Invite codes require a linked account."), true, "friends")
	var reward := UI.panel(body, "Invite Reward")
	UI.label(reward, "500 Paw Coins per verified friend · Preview", 16)
	var verification := UI.panel(body, "Verification Progress")
	UI.progress(verification, 0, 5)
	UI.label(verification, "0 / 5", 15, true)

static func _rewards(page) -> void:
	var body: VBoxContainer = page.body
	_reward_card(body, page, "Daily Gift", "daily_gift", "Open your daily gift to get rewards!", "Claim")
	_reward_card(body, page, "Free Spin", "free_spin", "Spin the wheel for exciting rewards!", "Spin")
	UI.button(body, "Weekly Challenge & Collections", page.open.bind(&"collections"), true, "gift")

static func _reward_card(parent: Control, page, title: String, illustration: String, description: String, action: String) -> void:
	var box := UI.panel(parent)
	UI.label(box, title, 24, true)
	UI.illustration(box, illustration, 137)
	UI.label(box, description, 14, true)
	UI.button(box, action, page.notice.bind(title, "Reward preview. Your balance stays at zero."), true, "paw")

static func _collections(page) -> void:
	var body: VBoxContainer = page.body
	var index: int = page.state.tab_indexes.get("collections", 0)
	UI.choices(body, ["Weekly Challenge", "Collections"], index, page.select_tab.bind("collections"))
	if index == 0:
		var weekly := UI.panel(body, "Weekly Challenge")
		UI.image(weekly, UI.icon("gift"), 76)
		UI.label(weekly, "Complete 3 challenges to earn a special reward!", 17, true)
		UI.progress(weekly, 0, 3)
		UI.label(weekly, "0 / 3  ·  Challenge preview", 15, true)
	UI.label(body, "Collections", 25, true)
	var titles := ["Meadow Friends", "Moonlit Boards", "Lucky Dice"]
	var destinations := [0, 1, 2]
	var art := [UI.animal(1), UI.icon("ludo_board"), UI.icon("pass_play")]
	for i in titles.size():
		var line := UI.row(UI.panel(body))
		var thumbnail := UI.image(line, art[i], 74)
		thumbnail.custom_minimum_size.x = 82
		var details := UI.column(line)
		details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		UI.label(details, titles[i], 18)
		UI.progress(details, 0, 6)
		UI.button(details, "View Collection  ›", _open_shop.bind(page, destinations[i]), false, "", 37)

static func _open_shop(page, tab: int) -> void:
	page.state.tab_indexes["shop"] = tab
	page.open_nested(&"shop")

static func _shop(page) -> void:
	var body: VBoxContainer = page.body
	var index: int = page.state.tab_indexes.get("shop", 0)
	UI.choices(body, ["Paws", "Boards", "Dice"], index, page.select_tab.bind("shop"))
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 7)
	grid.add_theme_constant_override("v_separation", 10)
	body.add_child(grid)
	var products: Array = ANIMALS if index == 0 else (["Meadow", "Woodland", "Moonlit"] if index == 1 else ["Classic", "Lucky", "Golden"])
	for i in products.size():
		var card := UI.panel(grid)
		var art := UI.animal(i) if index == 0 else UI.icon("ludo_board" if index == 1 else "pass_play")
		UI.image(card, art, 101)
		UI.label(card, products[i], 15, true)
		UI.label(card, "◆ %d" % [300, 300, 350, 400, 400, 450][i], 14, true)
		UI.button(card, "Preview", _product.bind(page, products[i], art), true, "", 38).add_theme_font_size_override("font_size", 13)
	UI.button(body, "Wallet", page.open.bind(&"wallet"), false, "gem")

static func _product(page, name: String, art: Texture2D) -> void:
	var card: VBoxContainer = page.dialog(name, "Collection preview")
	UI.image(card, art, 175)
	UI.button(card, "Close", page.dismiss, true)

static func _wallet(page) -> void:
	var body: VBoxContainer = page.body
	var balance := UI.panel(body)
	UI.image(balance, UI.icon("gem"), 58)
	UI.label(balance, "My Gems   0", 27, true)
	var index: int = page.state.tab_indexes.get("wallet", 0)
	UI.choices(body, ["Pending", "Credited"], index, page.select_tab.bind("wallet"))
	var orders := UI.panel(body, "Pending Orders" if index == 0 else "Credited Orders")
	UI.label(orders, "No purchases on this device.", 18, true)
	UI.button(body, "Check Status", page.notice.bind("Purchase Status", "There are no local purchase records."), true)
	UI.button(body, "Restore Purchase", page.notice.bind("Restore Purchase", "Purchase services will be connected in a later phase."))
