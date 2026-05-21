extends Control

const BG_COLOR: Color = Color("#0a0a1e")
const GOLD_COLOR: Color = Color("#f0c040")
const PANEL_COLOR: Color = Color(0.08, 0.08, 0.16, 0.72)
const TEXT_COLOR: Color = Color("#e0d5b7")
const DAMAGE_COLOR: Color = Color("#ff6060")

var label_round: Label
var label_title: Label
var label_last_action: Label
var label_log: Label
var log_scroll: ScrollContainer
var btn_action: Button
var arena_panel: PanelContainer
var arena_field: Control
var arena_effect_layer: Control
var arena_action_label: Label
var fighter_a: PanelContainer
var fighter_b: PanelContainer
var fighter_a_mark: Label
var fighter_b_mark: Label
var fighter_a_name: Label
var fighter_b_name: Label
var fighter_a_subtitle: Label
var fighter_b_subtitle: Label
var fighter_a_power: Label
var fighter_b_power: Label
var panel_a: PanelContainer
var panel_b: PanelContainer
var label_a: Label
var label_b: Label
var hp_a: ProgressBar
var hp_b: ProgressBar
var technique_grid_a: GridContainer
var technique_grid_b: GridContainer
var label_result: Label
var final_choice_box: VBoxContainer
var final_choice_buttons: HBoxContainer
var btn_ascend: Button
var btn_yield: Button

var last_hp_a: int = -1
var last_hp_b: int = -1
var last_current_attacker: String = ""
var sparring_finished: bool = false


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	UIEffects.apply_button_press_tween(self)
	GameManager.duel_prepared.connect(_on_duel_data)
	GameManager.duel_updated.connect(_on_duel_data)
	GameManager.duel_finished.connect(_on_duel_finished)
	if not NetworkManager.message_received.is_connected(_on_network_message):
		NetworkManager.message_received.connect(_on_network_message)
	if not GameManager.duel_data.is_empty():
		_on_duel_data(GameManager.duel_data)
	GameManager.start_duel_if_host()


func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = BG_COLOR
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var root := VBoxContainer.new()
	UIEffects.apply_phone_safe_margins(root, 38.0, 44.0, 48.0)
	root.add_theme_constant_override("separation", 8)
	add_child(root)

	label_title = _make_label("仙位之争", 28, GOLD_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
	root.add_child(label_title)

	arena_panel = _make_duel_arena()
	root.add_child(arena_panel)

	var mid := HBoxContainer.new()
	mid.custom_minimum_size = Vector2(1, 138)
	mid.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	mid.add_theme_constant_override("separation", 8)
	root.add_child(mid)

	panel_a = _make_panel()
	label_a = _make_label(GameManager.player_a.player_name, 15, TEXT_COLOR)
	hp_a = _make_hp_bar()
	technique_grid_a = _make_technique_grid()
	var box_a := VBoxContainer.new()
	box_a.add_theme_constant_override("separation", 6)
	box_a.add_child(label_a)
	box_a.add_child(hp_a)
	panel_a.add_child(box_a)
	mid.add_child(panel_a)

	var vs := _make_label("VS", 30, GOLD_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
	vs.custom_minimum_size = Vector2(44, 1)
	vs.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	mid.add_child(vs)

	panel_b = _make_panel()
	label_b = _make_label(GameManager.player_b.player_name, 15, TEXT_COLOR)
	hp_b = _make_hp_bar()
	technique_grid_b = _make_technique_grid()
	var box_b := VBoxContainer.new()
	box_b.add_theme_constant_override("separation", 6)
	box_b.add_child(label_b)
	box_b.add_child(hp_b)
	panel_b.add_child(box_b)
	mid.add_child(panel_b)

	label_round = _make_label("回合：-", 18, GOLD_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
	root.add_child(label_round)

	var action_panel := PanelContainer.new()
	action_panel.custom_minimum_size = Vector2(1, 118)
	action_panel.add_theme_stylebox_override("panel", _make_panel_style(false))
	root.add_child(action_panel)

	label_last_action = _make_label("等待出招：最终对战看境界、战力、速度、法宝、构筑、暴击和闪避。", 15, TEXT_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
	label_last_action.text = "等待出招：中间看本回合，下方只留最近战报。"
	label_last_action.add_theme_font_size_override("font_size", 18)
	label_last_action.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	action_panel.add_child(label_last_action)

	log_scroll = ScrollContainer.new()
	log_scroll.custom_minimum_size = Vector2(1, 104)
	log_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	log_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	log_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(log_scroll)

	label_log = _make_label("等待对决数据...", 15, TEXT_COLOR, HORIZONTAL_ALIGNMENT_LEFT)
	label_log.text = "等待对决数据..."
	label_log.add_theme_font_size_override("font_size", 16)
	label_log.custom_minimum_size = Vector2(360, 104)
	label_log.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label_log.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	log_scroll.add_child(label_log)

	label_result = _make_label("", 24, GOLD_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
	label_result.custom_minimum_size = Vector2(1, 50)
	root.add_child(label_result)

	final_choice_box = VBoxContainer.new()
	final_choice_box.visible = false
	final_choice_box.alignment = BoxContainer.ALIGNMENT_CENTER
	final_choice_box.add_theme_constant_override("separation", 8)
	root.add_child(final_choice_box)

	var final_choice_title := _make_label("仙位抉择", 24, GOLD_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
	final_choice_box.add_child(final_choice_title)

	final_choice_buttons = HBoxContainer.new()
	final_choice_buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	final_choice_buttons.add_theme_constant_override("separation", 16)
	final_choice_box.add_child(final_choice_buttons)

	btn_ascend = Button.new()
	btn_ascend.text = "踏入仙门"
	btn_ascend.custom_minimum_size = Vector2(210, 58)
	btn_ascend.add_theme_font_size_override("font_size", 22)
	btn_ascend.pressed.connect(_on_final_choice_pressed.bind("ascend"))
	final_choice_buttons.add_child(btn_ascend)

	btn_yield = Button.new()
	btn_yield.text = "放弃仙位，让他飞升"
	btn_yield.custom_minimum_size = Vector2(280, 58)
	btn_yield.add_theme_font_size_override("font_size", 22)
	btn_yield.pressed.connect(_on_final_choice_pressed.bind("yield"))
	final_choice_buttons.add_child(btn_yield)

	btn_action = Button.new()
	btn_action.text = "出招"
	btn_action.custom_minimum_size = Vector2(340, 54)
	btn_action.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn_action.add_theme_font_size_override("font_size", 28)
	btn_action.pressed.connect(_on_action_pressed)
	root.add_child(btn_action)


func _make_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _make_panel_style(false))
	return panel


func _make_panel_style(glowing: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL_COLOR
	style.border_width_left = 2 if not glowing else 4
	style.border_width_top = 2 if not glowing else 4
	style.border_width_right = 2 if not glowing else 4
	style.border_width_bottom = 2 if not glowing else 4
	style.border_color = GOLD_COLOR
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 12
	style.content_margin_top = 12
	style.content_margin_right = 12
	style.content_margin_bottom = 12
	if glowing:
		style.shadow_color = Color(0.941176, 0.752941, 0.25098, 0.55)
		style.shadow_size = 14
	return style


func _make_duel_arena() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(1, 230)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _make_arena_style())

	arena_field = Control.new()
	arena_field.clip_contents = false
	arena_field.custom_minimum_size = Vector2(1, 230)
	arena_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	arena_field.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(arena_field)

	arena_action_label = _make_label("双方入阵，等待起手。", 18, GOLD_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
	arena_action_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	arena_action_label.position = Vector2(10, 8)
	arena_action_label.size = Vector2(1, 34)
	arena_action_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	arena_field.add_child(arena_action_label)

	fighter_a = _make_fighter_marker(true)
	fighter_a_mark = fighter_a.get_node("Body/Mark") as Label
	fighter_a_name = fighter_a.get_node("Body/Name") as Label
	fighter_a_subtitle = fighter_a.get_node("Body/Subtitle") as Label
	fighter_a_power = fighter_a.get_node("Body/Power") as Label
	arena_field.add_child(fighter_a)

	fighter_b = _make_fighter_marker(false)
	fighter_b_mark = fighter_b.get_node("Body/Mark") as Label
	fighter_b_name = fighter_b.get_node("Body/Name") as Label
	fighter_b_subtitle = fighter_b.get_node("Body/Subtitle") as Label
	fighter_b_power = fighter_b.get_node("Body/Power") as Label
	arena_field.add_child(fighter_b)

	var center_vs := _make_label("VS", 26, GOLD_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
	center_vs.name = "CenterVS"
	center_vs.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	center_vs.custom_minimum_size = Vector2(70, 48)
	arena_field.add_child(center_vs)

	arena_effect_layer = Control.new()
	arena_effect_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	arena_effect_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	arena_field.add_child(arena_effect_layer)

	arena_field.resized.connect(_layout_duel_arena)
	call_deferred("_layout_duel_arena")
	return panel


func _make_arena_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#101024")
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.94, 0.75, 0.25, 0.72)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.content_margin_left = 10
	style.content_margin_top = 10
	style.content_margin_right = 10
	style.content_margin_bottom = 10
	return style


func _make_fighter_marker(left_side: bool) -> PanelContainer:
	var marker := PanelContainer.new()
	marker.custom_minimum_size = Vector2(116, 116)
	marker.add_theme_stylebox_override("panel", _make_fighter_style(false, left_side))

	var body := VBoxContainer.new()
	body.name = "Body"
	body.alignment = BoxContainer.ALIGNMENT_CENTER
	body.add_theme_constant_override("separation", 0)
	marker.add_child(body)

	var mark := _make_label("道", 42, GOLD_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
	mark.name = "Mark"
	mark.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	body.add_child(mark)

	var name_label := _make_label("无名", 17, TEXT_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
	name_label.name = "Name"
	body.add_child(name_label)

	var subtitle := _make_label("散修", 13, Color("#b8ad90"), HORIZONTAL_ALIGNMENT_CENTER)
	subtitle.name = "Subtitle"
	body.add_child(subtitle)

	var power := _make_label("战力 0", 13, GOLD_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
	power.name = "Power"
	body.add_child(power)
	return marker


func _make_fighter_style(active: bool, left_side: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#17172f") if left_side else Color("#12152d")
	style.border_width_left = 2 if not active else 4
	style.border_width_top = 2 if not active else 4
	style.border_width_right = 2 if not active else 4
	style.border_width_bottom = 2 if not active else 4
	style.border_color = GOLD_COLOR if active else Color("#3f4674")
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	style.content_margin_left = 8
	style.content_margin_top = 6
	style.content_margin_right = 8
	style.content_margin_bottom = 6
	if active:
		style.shadow_color = Color(0.94, 0.75, 0.25, 0.50)
		style.shadow_size = 18
	return style


func _layout_duel_arena() -> void:
	if arena_field == null or fighter_a == null or fighter_b == null:
		return
	var field_size: Vector2 = arena_field.size
	var marker_size := Vector2(116, 116)
	var y: float = maxf(48.0, field_size.y * 0.55 - marker_size.y * 0.5)
	fighter_a.position = Vector2(18.0, y)
	fighter_b.position = Vector2(maxf(18.0, field_size.x - marker_size.x - 18.0), y)
	var center_vs := arena_field.get_node_or_null("CenterVS") as Label
	if center_vs != null:
		center_vs.position = Vector2(field_size.x * 0.5 - 35.0, y + 34.0)
		center_vs.size = Vector2(70.0, 48.0)
	if arena_action_label != null:
		arena_action_label.position = Vector2(12.0, 8.0)
		arena_action_label.size = Vector2(maxf(1.0, field_size.x - 24.0), 34.0)


func _make_label(text: String, font_size: int, color: Color, alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = alignment
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label


func _make_hp_bar() -> ProgressBar:
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(1, 18)
	bar.min_value = 0.0
	bar.max_value = 100.0
	bar.value = 100.0

	var background_style := StyleBoxFlat.new()
	background_style.bg_color = Color("#151420")
	background_style.border_width_left = 1
	background_style.border_width_top = 1
	background_style.border_width_right = 1
	background_style.border_width_bottom = 1
	background_style.border_color = Color("#f0c040")
	background_style.corner_radius_top_left = 7
	background_style.corner_radius_top_right = 7
	background_style.corner_radius_bottom_left = 7
	background_style.corner_radius_bottom_right = 7
	bar.add_theme_stylebox_override("background", background_style)

	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = Color("#c04040")
	fill_style.corner_radius_top_left = 7
	fill_style.corner_radius_top_right = 7
	fill_style.corner_radius_bottom_left = 7
	fill_style.corner_radius_bottom_right = 7
	bar.add_theme_stylebox_override("fill", fill_style)
	return bar


func _make_technique_grid() -> GridContainer:
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	return grid


func _make_duel_technique_card(text: String, filled: bool) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(112, 54)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#f5e6c8") if filled else Color(0.08, 0.08, 0.16, 0.85)
	style.border_color = GOLD_COLOR if filled else Color("#3a3a6e")
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 5
	style.content_margin_top = 3
	style.content_margin_right = 5
	style.content_margin_bottom = 3
	card.add_theme_stylebox_override("panel", style)

	var label := _make_label(text, 11, Color("#2a2a2a") if filled else Color("#8a8070"), HORIZONTAL_ALIGNMENT_CENTER)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	card.add_child(label)
	return card


func _on_action_pressed() -> void:
	if sparring_finished:
		btn_action.disabled = true
		btn_action.text = "等待对方..."
		if NetworkManager.is_host:
			GameManager.on_duel_continue_received(1, {})
		else:
			NetworkManager.send_message("duel_continue", {})
		return
	btn_action.disabled = true
	label_log.text += "\n出招已确认，等待天机推演..."
	_scroll_log_to_bottom()
	if NetworkManager.is_host:
		GameManager.settle_duel_action()
	else:
		NetworkManager.send_message("duel_action")


func _on_final_choice_pressed(choice: String) -> void:
	btn_ascend.disabled = true
	btn_yield.disabled = true
	var message := "你选择踏入仙门。"
	if choice == "yield":
		message = "你选择放弃仙位，让对方飞升。"
	label_result.text = message
	label_log.text += "\n" + message
	_scroll_log_to_bottom()
	_play_final_choice_banner(choice, false)
	if NetworkManager.is_host:
		GameManager.on_duel_final_choice_received(1, {"choice": choice})
	else:
		NetworkManager.send_message("duel_final_choice", {"choice": choice})


func _on_network_message(msg_type: String, data: Dictionary) -> void:
	if msg_type == "duel_final_choice_result":
		_show_final_choice_result(data)


func _show_final_choice_result(data: Dictionary) -> void:
	var local_peer_id: int = 1 if NetworkManager.is_host else multiplayer.get_unique_id()
	var ascender_peer_id: int = int(data.get("ascender_peer_id", 0))
	var choice: String = str(data.get("choice", "ascend"))
	if choice == "yield":
		if local_peer_id == ascender_peer_id:
			label_result.text = "对方让出仙位。\n你被亲手送入仙门。"
			_spawn_final_banner("受让成仙", Color("#f0c040"), "他退了一步，把整座仙门推给了你。")
			_flash_final_color(Color(1.0, 0.82, 0.20, 0.34))
		else:
			label_result.text = "你让出了仙位。\n最后一劫，成全了对方。"
			_spawn_final_banner("让出仙位", Color("#80c080"), "最后一步，你没有踏过去。")
			_flash_final_color(Color(0.35, 0.75, 0.55, 0.32))
	else:
		if local_peer_id == ascender_peer_id:
			label_result.text = "你踏入仙门。\n仙位归你。"
			_spawn_final_banner("踏入仙门", Color("#f0c040"), "这一门一关，身后皆是旧人。")
			_flash_final_color(Color(1.0, 0.82, 0.20, 0.34))
		else:
			label_result.text = "对方踏入仙门。\n你止步门外。"
			_spawn_final_banner("仙门相隔", Color("#c04040"), "你只差一步，却再也追不上了。")
			_flash_final_color(Color(0.75, 0.12, 0.12, 0.32))
	UIEffects.screen_shake(self, 6.0, 0.32)


func _play_final_choice_banner(choice: String, from_result: bool) -> void:
	if choice == "yield":
		_spawn_final_banner("让出仙位", Color("#80c080"), "最后一步，你没有踏过去。")
		_flash_final_color(Color(0.35, 0.75, 0.55, 0.28))
	else:
		_spawn_final_banner("踏入仙门", Color("#f0c040"), "这一门一关，身后皆是旧人。")
		_flash_final_color(Color(1.0, 0.82, 0.20, 0.28))
	if not from_result:
		UIEffects.screen_shake(self, 5.0, 0.24)


func _on_duel_data(data: Dictionary) -> void:
	var mode: String = str(data.get("mode", "final"))
	if label_title != null:
		var fallback_title: String = "论道切磋" if mode == "sparring" else "仙位之争"
		label_title.text = str(data.get("title", fallback_title))
	if not bool(data.has("ending")):
		sparring_finished = false
	var stats_a: Dictionary = data.get("player_a_stats", {}) as Dictionary
	var stats_b: Dictionary = data.get("player_b_stats", {}) as Dictionary
	var hp_now_a: int = int(stats_a.get("当前气血", int(stats_a.get("气血", 1))))
	var hp_now_b: int = int(stats_b.get("当前气血", int(stats_b.get("气血", 1))))
	var previous_attacker := _previous_attacker_from_data(data)

	_update_panel(label_a, hp_a, GameManager.player_a.player_name, stats_a)
	_update_panel(label_b, hp_b, GameManager.player_b.player_name, stats_b)
	_update_duel_technique_grid(technique_grid_a, GameManager.player_a)
	_update_duel_technique_grid(technique_grid_b, GameManager.player_b)
	var current_attacker_key: String = str(data.get("current_attacker", data.get("first_attacker", "player_a")))
	_highlight_first(current_attacker_key)
	label_round.text = "回合：" + str(int(data.get("round", 1))) + "｜当前：" + _duel_actor_name(current_attacker_key) + "出招"

	var logs: Array = data.get("log", []) as Array
	label_log.text = _format_recent_logs(logs)
	_scroll_log_to_bottom()
	var last_result: Dictionary = data.get("last_result", {}) as Dictionary
	if label_last_action != null:
		label_last_action.text = _format_last_action(last_result) if not last_result.is_empty() else _format_opening_compare(stats_a, stats_b)
	_update_arena(stats_a, stats_b, current_attacker_key, last_result)
	var was_crit: bool = bool(last_result.get("暴击", false))
	var was_dodge: bool = bool(last_result.get("闪避", false))
	if was_dodge and last_hp_a >= 0 and last_hp_b >= 0:
		var dodge_panel: Control = fighter_b if previous_attacker == "player_a" and fighter_b != null else fighter_a
		if dodge_panel == null:
			dodge_panel = panel_b if previous_attacker == "player_a" else panel_a
		_spawn_float_text(dodge_panel, "闪避！", Color("#80e0ff"))

	var played_motion := false
	if last_hp_a >= 0 and hp_now_a < last_hp_a:
		if not played_motion:
			_play_attack_motion(previous_attacker)
			played_motion = true
		_spawn_damage_number(fighter_a if fighter_a != null else panel_a, last_hp_a - hp_now_a, was_crit)
	if last_hp_b >= 0 and hp_now_b < last_hp_b:
		if not played_motion:
			_play_attack_motion(previous_attacker)
			played_motion = true
		_spawn_damage_number(fighter_b if fighter_b != null else panel_b, last_hp_b - hp_now_b, was_crit)

	last_hp_a = hp_now_a
	last_hp_b = hp_now_b
	last_current_attacker = current_attacker_key
	btn_action.disabled = false
	btn_action.text = "出招"


func _previous_attacker_from_data(data: Dictionary) -> String:
	if last_current_attacker != "":
		return last_current_attacker
	var current := str(data.get("current_attacker", data.get("first_attacker", "player_a")))
	return "player_b" if current == "player_a" else "player_a"


func _duel_actor_name(actor_key: String) -> String:
	if actor_key == "player_b":
		return GameManager.player_b.player_name
	return GameManager.player_a.player_name


func _update_arena(stats_a: Dictionary, stats_b: Dictionary, current_attacker: String, last_result: Dictionary) -> void:
	if fighter_a == null or fighter_b == null:
		return
	_update_fighter_marker(fighter_a_mark, fighter_a_name, fighter_a_subtitle, fighter_a_power, GameManager.player_a.player_name, stats_a)
	_update_fighter_marker(fighter_b_mark, fighter_b_name, fighter_b_subtitle, fighter_b_power, GameManager.player_b.player_name, stats_b)
	fighter_a.add_theme_stylebox_override("panel", _make_fighter_style(current_attacker == "player_a", true))
	fighter_b.add_theme_stylebox_override("panel", _make_fighter_style(current_attacker == "player_b", false))
	if arena_action_label != null:
		if last_result.is_empty():
			arena_action_label.text = _duel_actor_name(current_attacker) + "蓄势起手，下一击即将落下。"
		else:
			arena_action_label.text = _format_arena_action(last_result)


func _update_fighter_marker(mark: Label, name_label: Label, subtitle: Label, power: Label, player_name: String, stats: Dictionary) -> void:
	var school: String = str(stats.get("流派", "散修"))
	if mark != null:
		mark.text = _school_mark(school)
	if name_label != null:
		name_label.text = player_name
	if subtitle != null:
		subtitle.text = str(stats.get("境界", "炼气期")) + " · " + school
	if power != null:
		var hp_now: int = int(stats.get("当前气血", stats.get("气血", 0)))
		var hp_max: int = maxi(1, int(stats.get("气血", 1)))
		power.text = "战" + str(int(stats.get("战力", 0))) + "  血" + str(hp_now) + "/" + str(hp_max)


func _school_mark(school: String) -> String:
	match school:
		"鬼修":
			return "鬼"
		"体修":
			return "体"
		"剑修":
			return "剑"
		"情修":
			return "情"
		"丹修":
			return "丹"
		"阵修":
			return "阵"
		"符修":
			return "符"
		"器修":
			return "器"
		_:
			return "道"


func _format_arena_action(result: Dictionary) -> String:
	var attacker: String = str(result.get("攻击方", "攻击方"))
	var defender: String = str(result.get("防守方", "防守方"))
	if bool(result.get("闪避", false)):
		return defender + "身形化影，避开" + attacker + "一击。"
	var damage: int = int(result.get("实际伤害", result.get("damage", 0)))
	var prefix: String = attacker + "击中" + defender + "，造成 " + str(damage) + " 伤害"
	if bool(result.get("暴击", false)):
		prefix += "，暴击！"
	var effects: Array = result.get("特殊效果触发列表", []) as Array
	var effect_text := _format_effects_limited(effects, 2)
	if effect_text != "":
		prefix += "（" + effect_text + "）"
	return prefix


func _format_effects_limited(effects: Array, limit: int) -> String:
	if effects.is_empty():
		return ""
	var names: Array[String] = []
	for effect in effects:
		names.append(str(effect))
		if names.size() >= limit:
			break
	if effects.size() > names.size():
		names.append("等")
	return "、".join(names)


func _format_opening_compare(stats_a: Dictionary, stats_b: Dictionary) -> String:
	var power_a: int = int(stats_a.get("战力", 0))
	var power_b: int = int(stats_b.get("战力", 0))
	var realm_a: String = str(stats_a.get("境界", "炼气"))
	var realm_b: String = str(stats_b.get("境界", "炼气"))
	var route_a: String = str(stats_a.get("流派", "散修"))
	var route_b: String = str(stats_b.get("流派", "散修"))
	return GameManager.player_a.player_name + " " + realm_a + "·" + route_a + " 战力" + str(power_a) + "\n" + GameManager.player_b.player_name + " " + realm_b + "·" + route_b + " 战力" + str(power_b) + "\n每回合只看：谁出手、伤害、闪避/暴击、关键效果。"


func _format_last_action(result: Dictionary) -> String:
	if result.is_empty():
		return "等待出招：中间看本回合，下方只留最近战报。"
	var clean_attacker: String = str(result.get("攻击方", "攻击方"))
	var clean_defender: String = str(result.get("防守方", "防守方"))
	var clean_damage: int = int(result.get("实际伤害", result.get("damage", 0)))
	var clean_header: String = clean_attacker + " → " + clean_defender + "："
	if bool(result.get("闪避", false)):
		clean_header += "闪避成功"
	else:
		clean_header += "造成 " + str(clean_damage) + " 伤害"
		if bool(result.get("暴击", false)):
			clean_header += "（暴击）"
	var clean_lines: Array[String] = [clean_header]
	var clean_details: Array = result.get("明细", []) as Array
	var key_details: Array[String] = []
	for detail in clean_details:
		var detail_text: String = str(detail)
		if detail_text.contains("基础") or detail_text.contains("法宝") or detail_text.contains("境界") or detail_text.contains("暴击") or detail_text.contains("闪避") or detail_text.contains("防御") or detail_text.contains("最终"):
			key_details.append(detail_text)
		if key_details.size() >= 4:
			break
	if key_details.is_empty():
		for i in range(mini(2, clean_details.size())):
			key_details.append(str(clean_details[i]))
	for detail_text in key_details:
		clean_lines.append("· " + detail_text)
	return "\n".join(clean_lines)


func _format_duel_percent(value: float) -> String:
	return str(int(round(value * 100.0))) + "%"


func _update_panel(label: Label, hp_bar: ProgressBar, player_name: String, stats: Dictionary) -> void:
	var clean_hp_max: int = maxi(1, int(stats.get("气血", 1)))
	var clean_hp_now: int = int(stats.get("当前气血", clean_hp_max))
	hp_bar.max_value = clean_hp_max
	var clean_tween := create_tween()
	clean_tween.tween_property(hp_bar, "value", float(clampi(clean_hp_now, 0, clean_hp_max)), 0.18)
	var clean_treasure: Dictionary = stats.get("法宝", {}) as Dictionary
	var clean_treasure_text: String = "无法宝"
	if not clean_treasure.is_empty():
		clean_treasure_text = str(clean_treasure.get("name", "法宝")) + " " + str(int(stats.get("法宝成长", 0)))
	label.text = player_name + " · " + str(stats.get("境界", "炼气")) + " · " + str(stats.get("流派", "散修"))
	label.text += "\n战力 " + str(int(stats.get("战力", 0))) + "｜血 " + str(clean_hp_now) + "/" + str(clean_hp_max)
	label.text += "\n攻 " + str(stats.get("攻击力", 0)) + "  防 " + str(stats.get("防御力", 0)) + "  速 " + str(stats.get("速度", 0))
	label.text += "\n暴 " + _format_duel_percent(float(stats.get("暴击率", 0.0))) + "  闪 " + _format_duel_percent(float(stats.get("闪避率", 0.0))) + "｜" + clean_treasure_text
	return
	var hp_max: int = maxi(1, int(stats.get("气血", 1)))
	var hp_now: int = int(stats.get("当前气血", hp_max))
	hp_bar.max_value = hp_max
	var tween := create_tween()
	tween.tween_property(hp_bar, "value", float(clampi(hp_now, 0, hp_max)), 0.18)
	var treasure: Dictionary = stats.get("法宝", {}) as Dictionary
	var treasure_text: String = "无"
	if not treasure.is_empty():
		treasure_text = str(treasure.get("name", "法宝"))
		if bool(treasure.get("is_growth_sword", false)):
			treasure_text += " " + str(int(treasure.get("growth_level", 1))) + "阶"
	label.text = player_name + "｜" + str(stats.get("境界", "炼气期")) + "｜" + str(stats.get("流派", "散修"))
	label.text += "\n战力 " + str(int(stats.get("战力", 0))) + "｜修为 " + str(int(stats.get("修为", 0)))
	label.text += "\n攻 " + str(stats.get("攻击力", 0)) + " 防 " + str(stats.get("防御力", 0)) + " 血 " + str(hp_now) + "/" + str(hp_max) + " 速 " + str(stats.get("速度", 0))
	label.text += "\n暴 " + _format_duel_percent(float(stats.get("暴击率", 0.0))) + " 闪 " + _format_duel_percent(float(stats.get("闪避率", 0.0))) + " 破 " + _format_duel_percent(float(stats.get("破防", 0.0)))
	label.text += "\n法宝：" + treasure_text + "｜成长 " + str(int(stats.get("法宝成长", 0)))
	label.text += "\n构筑" + str(int(stats.get("构筑层级", 0))) + "层｜善" + str(int(stats.get("善因", 0))) + " 忍" + str(int(stats.get("隐忍", 0))) + " 魔" + str(int(stats.get("因果", 0)))
	if int(stats.get("鬼魂强度", 0)) > 0:
		label.text += " 鬼" + str(int(stats.get("鬼魂强度", 0)))
	if float(stats.get("炼体强度", 0.0)) > 0.0:
		label.text += " 体" + str(int(round(float(stats.get("炼体强度", 0.0)))))
	if float(stats.get("情修强度", 0.0)) > 0.0:
		label.text += " 情" + str(int(round(float(stats.get("情修强度", 0.0)))))
	var links: Array = stats.get("联动列表", []) as Array
	if not links.is_empty():
		label.text += "\n联动：" + _format_names_limited(links, 2)


func _update_duel_technique_grid(grid: GridContainer, player: PlayerData) -> void:
	if grid == null or player == null:
		return
	for child in grid.get_children():
		child.queue_free()
	for i in range(GameManager.MAX_EQUIPPED_TECHNIQUES):
		if i < player.techniques.size() and player.techniques[i] is Dictionary:
			var technique: Dictionary = player.techniques[i] as Dictionary
			var text: String = GameManager.quality_display_name(str(technique.get("quality", ""))) + "\n" + str(technique.get("name", "未知")) + "\n" + str(technique.get("technique_realm", "初窥"))
			grid.add_child(_make_duel_technique_card(text, true))
		else:
			grid.add_child(_make_duel_technique_card("空", false))


func _play_attack_motion(attacker_key: String) -> void:
	var panel: Control = fighter_a if attacker_key == "player_a" else fighter_b
	if panel == null:
		panel = panel_a if attacker_key == "player_a" else panel_b
	var target: Control = fighter_b if attacker_key == "player_a" else fighter_a
	var direction := 1.0 if attacker_key == "player_a" else -1.0
	var original_position := panel.position
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "position", original_position + Vector2(46.0 * direction, -4.0), 0.10)
	tween.tween_property(panel, "position", original_position, 0.16)
	_spawn_duel_slash(attacker_key)
	if target != null:
		_shake_fighter(target)
	UIEffects.screen_shake(self, 3.5, 0.16)


func _spawn_duel_slash(attacker_key: String) -> void:
	if arena_effect_layer == null or fighter_a == null or fighter_b == null:
		return
	var attacker := fighter_a if attacker_key == "player_a" else fighter_b
	var defender := fighter_b if attacker_key == "player_a" else fighter_a
	var from_pos: Vector2 = attacker.global_position + attacker.size * 0.5 - arena_effect_layer.global_position
	var to_pos: Vector2 = defender.global_position + defender.size * 0.5 - arena_effect_layer.global_position
	var direction: Vector2 = (to_pos - from_pos).normalized()
	var center: Vector2 = from_pos.lerp(to_pos, 0.55)

	var slash := ColorRect.new()
	slash.color = Color(1.0, 0.84, 0.28, 0.92)
	slash.size = Vector2(150.0, 8.0)
	slash.pivot_offset = slash.size * 0.5
	slash.rotation = direction.angle()
	slash.position = center - slash.size * 0.5
	slash.z_index = 40
	arena_effect_layer.add_child(slash)

	var glow := ColorRect.new()
	glow.color = Color(1.0, 0.96, 0.68, 0.50)
	glow.size = Vector2(104.0, 104.0)
	glow.pivot_offset = glow.size * 0.5
	glow.position = to_pos - glow.size * 0.5
	glow.rotation = 0.75
	glow.z_index = 39
	arena_effect_layer.add_child(glow)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(slash, "scale", Vector2(1.25, 1.8), 0.16)
	tween.tween_property(slash, "modulate:a", 0.0, 0.22)
	tween.tween_property(glow, "scale", Vector2(1.42, 1.42), 0.22)
	tween.tween_property(glow, "modulate:a", 0.0, 0.22)
	tween.set_parallel(false)
	tween.tween_callback(slash.queue_free)
	tween.tween_callback(glow.queue_free)


func _shake_fighter(target: Control) -> void:
	var original_position := target.position
	var tween := create_tween()
	tween.tween_property(target, "position", original_position + Vector2(8.0, 0.0), 0.045)
	tween.tween_property(target, "position", original_position + Vector2(-7.0, 0.0), 0.055)
	tween.tween_property(target, "position", original_position, 0.075)


func _spawn_damage_number(target_panel: Control, amount: int, crit: bool = false) -> void:
	if amount <= 0:
		return
	var damage_label := Label.new()
	damage_label.text = ("暴击！\n" if crit else "") + "-" + str(amount)
	damage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	damage_label.add_theme_font_size_override("font_size", 40 if crit else 30)
	damage_label.add_theme_color_override("font_color", DAMAGE_COLOR)
	damage_label.z_index = 200
	damage_label.scale = Vector2(1.12, 1.12) if crit else Vector2.ONE
	add_child(damage_label)
	await get_tree().process_frame
	var start_position := target_panel.global_position + target_panel.size * 0.5 - global_position - damage_label.size * 0.5
	damage_label.position = start_position
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(damage_label, "position", start_position + Vector2(0, -54), 0.6)
	tween.tween_property(damage_label, "modulate:a", 0.0, 0.6)
	tween.set_parallel(false)
	tween.tween_callback(damage_label.queue_free)


func _spawn_float_text(target_panel: Control, text: String, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 38)
	label.add_theme_color_override("font_color", color)
	label.z_index = 210
	add_child(label)
	await get_tree().process_frame
	var start_position := target_panel.global_position + target_panel.size * 0.5 - global_position - label.size * 0.5
	label.position = start_position
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position", start_position + Vector2(0, -48), 0.52)
	tween.tween_property(label, "modulate:a", 0.0, 0.52)
	tween.set_parallel(false)
	tween.tween_callback(label.queue_free)


func _spawn_final_banner(text: String, color: Color, line: String = "") -> void:
	var banner := Label.new()
	banner.text = text
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	banner.add_theme_font_size_override("font_size", 56)
	banner.add_theme_color_override("font_color", color)
	banner.z_index = 400
	banner.custom_minimum_size = Vector2(620.0, 110.0)
	add_child(banner)
	await get_tree().process_frame
	banner.global_position = get_viewport_rect().size * 0.5 - Vector2(310.0, 150.0)
	banner.scale = Vector2(0.82, 0.82)
	banner.modulate.a = 0.0

	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(banner, "scale", Vector2.ONE, 0.18)
	tween.tween_property(banner, "modulate:a", 1.0, 0.18)
	tween.chain().tween_interval(0.7)
	tween.chain().tween_property(banner, "global_position", banner.global_position + Vector2(0.0, -56.0), 0.42)
	tween.parallel().tween_property(banner, "modulate:a", 0.0, 0.42)
	tween.tween_callback(banner.queue_free)

	if line != "":
		var line_label := Label.new()
		line_label.text = line
		line_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		line_label.add_theme_font_size_override("font_size", 24)
		line_label.add_theme_color_override("font_color", TEXT_COLOR)
		line_label.z_index = 401
		line_label.custom_minimum_size = Vector2(660.0, 48.0)
		add_child(line_label)
		await get_tree().process_frame
		line_label.global_position = banner.global_position + Vector2(-20.0, 88.0)
		line_label.modulate.a = 0.0
		var line_tween := create_tween()
		line_tween.tween_property(line_label, "modulate:a", 1.0, 0.18)
		line_tween.tween_interval(0.76)
		line_tween.tween_property(line_label, "modulate:a", 0.0, 0.36)
		line_tween.tween_callback(line_label.queue_free)


func _flash_final_color(color: Color) -> void:
	var flash := ColorRect.new()
	flash.color = color
	flash.modulate.a = 0.0
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.z_index = 380
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(flash)
	var tween := create_tween()
	tween.tween_property(flash, "modulate:a", 1.0, 0.08)
	tween.tween_property(flash, "modulate:a", 0.0, 0.32)
	tween.tween_callback(flash.queue_free)


func _scroll_log_to_bottom() -> void:
	await get_tree().process_frame
	if log_scroll != null:
		log_scroll.scroll_vertical = int(log_scroll.get_v_scroll_bar().max_value)


func _format_recent_logs(logs: Array, limit: int = 4) -> String:
	if logs.is_empty():
		return "战斗尚未开始。"
	var start_index: int = maxi(0, logs.size() - limit)
	var lines: Array[String] = []
	for i in range(start_index, logs.size()):
		var line: String = str(logs[i])
		if line.length() > 56:
			line = line.substr(0, 54) + "..."
		lines.append(line)
	return "\n".join(lines)


func _format_techniques(player_name: String) -> String:
	var player := GameManager.player_a if player_name == GameManager.player_a.player_name else GameManager.player_b
	if player.techniques.is_empty():
		return "暂无"
	var names: Array[String] = []
	for technique in player.techniques:
		if technique is Dictionary:
			names.append(GameManager.quality_display_name(str(technique.get("quality", ""))) + "·" + str(technique.get("name", "")))
	return "，".join(names)


func _format_names(items: Array) -> String:
	if items.is_empty():
		return "暂无"
	var names: Array[String] = []
	for item in items:
		if item is Dictionary:
			names.append(str(item.get("name", "")))
	return "，".join(names)


func _format_names_limited(items: Array, limit: int) -> String:
	if items.is_empty():
		return "暂无"
	var names: Array[String] = []
	for item in items:
		if item is Dictionary:
			names.append(str(item.get("name", "")))
		if names.size() >= limit:
			break
	if items.size() > names.size():
		names.append("等" + str(items.size()) + "个")
	return "，".join(names)


func _highlight_first(first_attacker: String) -> void:
	panel_a.add_theme_stylebox_override("panel", _make_panel_style(first_attacker == "player_a"))
	panel_b.add_theme_stylebox_override("panel", _make_panel_style(first_attacker == "player_b"))


func _format_duel_finish_summary(data: Dictionary) -> String:
	var final_stats: Dictionary = data.get("final_stats", {}) as Dictionary
	var parts: Array[String] = []
	var last_result: Dictionary = final_stats.get("last_result", {}) as Dictionary
	if not last_result.is_empty():
		var action_lines := _format_last_action(last_result).split("\n")
		if not action_lines.is_empty():
			parts.append("终局：" + str(action_lines[0]))
	var logs: Array = final_stats.get("log", []) as Array
	for i in range(logs.size() - 1, -1, -1):
		var line: String = str(logs[i])
		if line.begins_with("胜负原因："):
			parts.append(line)
			break
	if parts.is_empty():
		parts.append("对战结束：胜负已分。")
	return "\n".join(parts)


func _on_duel_finished(data: Dictionary) -> void:
	if str(data.get("mode", "final")) == "sparring":
		sparring_finished = true
		btn_action.visible = true
		btn_action.disabled = false
		btn_action.text = "继续修行"
		final_choice_box.visible = false
		var winner_name: String = str(data.get("winner", "胜者"))
		var loser_name: String = str(data.get("loser", "败者"))
		label_result.text = winner_name + "在论道切磋中占得上风。\n" + loser_name + "败中有悟，双方点到为止。"
		var sparring_final_stats: Dictionary = data.get("final_stats", {}) as Dictionary
		var sparring_logs: Array = sparring_final_stats.get("log", []) as Array
		if not sparring_logs.is_empty():
			label_log.text = _format_recent_logs(sparring_logs, 5)
		if label_last_action != null:
			label_last_action.text = _format_duel_finish_summary(data)
		label_log.text += "\n论道切磋结束，确认后进入下一轮。"
		_spawn_final_banner("论道切磋", Color("#40c0a0"), "胜负只定一时，道心还在路上。")
		_scroll_log_to_bottom()
		return
	btn_action.disabled = true
	btn_action.visible = false
	var winner_key: String = str(data.get("winner_key", ""))
	var local_key: String = "player_a" if NetworkManager.is_host else "player_b"
	final_choice_box.visible = true
	var is_local_winner: bool = local_key == winner_key
	final_choice_buttons.visible = is_local_winner
	var finish_final_stats: Dictionary = data.get("final_stats", {}) as Dictionary
	var finish_logs: Array = finish_final_stats.get("log", []) as Array
	if not finish_logs.is_empty():
		label_log.text = _format_recent_logs(finish_logs, 5)
	if label_last_action != null:
		label_last_action.text = _format_duel_finish_summary(data)
	if is_local_winner:
		label_result.text = "你已胜过" + str(data.get("loser", "")) + "。\n仙门已开，最后一步由你决定。"
		label_log.text += "\n你赢下仙位之争：是独自飞升，还是放弃仙位成全对方？"
	else:
		label_result.text = "你败于" + str(data.get("winner", "")) + "。\n等待对方决定仙位归属。"
		label_log.text += "\n仙位未定，胜者正在抉择。"
	_scroll_log_to_bottom()
