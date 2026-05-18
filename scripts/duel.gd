extends Control

const BG_COLOR: Color = Color("#0a0a1e")
const GOLD_COLOR: Color = Color("#f0c040")
const PANEL_COLOR: Color = Color(0.08, 0.08, 0.16, 0.72)
const TEXT_COLOR: Color = Color("#e0d5b7")
const DAMAGE_COLOR: Color = Color("#ff6060")

var label_round: Label
var label_log: Label
var log_scroll: ScrollContainer
var btn_action: Button
var panel_a: PanelContainer
var panel_b: PanelContainer
var label_a: Label
var label_b: Label
var hp_a: ProgressBar
var hp_b: ProgressBar
var label_result: Label
var final_choice_box: VBoxContainer
var final_choice_buttons: HBoxContainer
var btn_ascend: Button
var btn_yield: Button

var last_hp_a: int = -1
var last_hp_b: int = -1
var last_current_attacker: String = ""


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	UIEffects.apply_button_press_tween(self)
	GameManager.duel_prepared.connect(_on_duel_data)
	GameManager.duel_updated.connect(_on_duel_data)
	GameManager.duel_finished.connect(_on_duel_finished)
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
	root.add_theme_constant_override("separation", 14)
	add_child(root)

	var title := _make_label("仙位之争", 36, GOLD_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
	root.add_child(title)

	var mid := HBoxContainer.new()
	mid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mid.add_theme_constant_override("separation", 12)
	root.add_child(mid)

	panel_a = _make_panel()
	label_a = _make_label("玩家A", 14, TEXT_COLOR)
	hp_a = _make_hp_bar()
	var box_a := VBoxContainer.new()
	box_a.add_theme_constant_override("separation", 8)
	box_a.add_child(label_a)
	box_a.add_child(hp_a)
	panel_a.add_child(box_a)
	mid.add_child(panel_a)

	var vs := _make_label("VS", 48, GOLD_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
	vs.custom_minimum_size = Vector2(82, 1)
	vs.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	mid.add_child(vs)

	panel_b = _make_panel()
	label_b = _make_label("玩家B", 14, TEXT_COLOR)
	hp_b = _make_hp_bar()
	var box_b := VBoxContainer.new()
	box_b.add_theme_constant_override("separation", 8)
	box_b.add_child(label_b)
	box_b.add_child(hp_b)
	panel_b.add_child(box_b)
	mid.add_child(panel_b)

	label_round = _make_label("回合：-", 18, GOLD_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
	root.add_child(label_round)

	log_scroll = ScrollContainer.new()
	log_scroll.custom_minimum_size = Vector2(1, 130)
	log_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	root.add_child(log_scroll)

	label_log = _make_label("等待对决数据...", 16, TEXT_COLOR, HORIZONTAL_ALIGNMENT_LEFT)
	label_log.custom_minimum_size = Vector2(1, 130)
	label_log.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	log_scroll.add_child(label_log)

	label_result = _make_label("", 24, GOLD_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
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
	btn_action.custom_minimum_size = Vector2(420, 70)
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
	bar.custom_minimum_size = Vector2(1, 24)
	return bar


func _on_action_pressed() -> void:
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
	if NetworkManager.is_host:
		GameManager.on_duel_final_choice_received(1, {"choice": choice})
	else:
		NetworkManager.send_message("duel_final_choice", {"choice": choice})


func _on_duel_data(data: Dictionary) -> void:
	var stats_a: Dictionary = data.get("player_a_stats", {}) as Dictionary
	var stats_b: Dictionary = data.get("player_b_stats", {}) as Dictionary
	var hp_now_a: int = int(stats_a.get("当前气血", int(stats_a.get("气血", 1))))
	var hp_now_b: int = int(stats_b.get("当前气血", int(stats_b.get("气血", 1))))
	var previous_attacker := _previous_attacker_from_data(data)

	_update_panel(label_a, hp_a, GameManager.player_a.player_name, stats_a)
	_update_panel(label_b, hp_b, GameManager.player_b.player_name, stats_b)
	_highlight_first(str(data.get("current_attacker", data.get("first_attacker", "player_a"))))
	label_round.text = "回合：" + str(int(data.get("round", 1)))

	var logs: Array = data.get("log", []) as Array
	label_log.text = "\n".join(logs)
	_scroll_log_to_bottom()

	if last_hp_a >= 0 and hp_now_a < last_hp_a:
		_play_attack_motion(previous_attacker)
		_spawn_damage_number(panel_a, last_hp_a - hp_now_a)
	if last_hp_b >= 0 and hp_now_b < last_hp_b:
		_play_attack_motion(previous_attacker)
		_spawn_damage_number(panel_b, last_hp_b - hp_now_b)

	last_hp_a = hp_now_a
	last_hp_b = hp_now_b
	last_current_attacker = str(data.get("current_attacker", data.get("first_attacker", "player_a")))
	btn_action.disabled = false


func _previous_attacker_from_data(data: Dictionary) -> String:
	if last_current_attacker != "":
		return last_current_attacker
	var current := str(data.get("current_attacker", data.get("first_attacker", "player_a")))
	return "player_b" if current == "player_a" else "player_a"


func _update_panel(label: Label, hp_bar: ProgressBar, player_name: String, stats: Dictionary) -> void:
	var hp_max: int = maxi(1, int(stats.get("气血", 1)))
	var hp_now: int = int(stats.get("当前气血", hp_max))
	hp_bar.max_value = hp_max
	var tween := create_tween()
	tween.tween_property(hp_bar, "value", float(clampi(hp_now, 0, hp_max)), 0.18)
	label.text = player_name + "\n攻击 " + str(stats.get("攻击力", 0)) + "  防御 " + str(stats.get("防御力", 0)) + "\n气血 " + str(hp_now) + "/" + str(hp_max) + "  速度 " + str(stats.get("速度", 0))
	label.text += "\n\n功法：\n" + _format_techniques(player_name)
	label.text += "\n\n真意：\n" + _format_names(stats.get("真意列表", []) as Array)
	label.text += "\n\n联动：\n" + _format_names(stats.get("联动列表", []) as Array)


func _play_attack_motion(attacker_key: String) -> void:
	var panel := panel_a if attacker_key == "player_a" else panel_b
	var direction := 1.0 if attacker_key == "player_a" else -1.0
	var original_position := panel.position
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "position", original_position + Vector2(30.0 * direction, 0.0), 0.12)
	tween.tween_property(panel, "position", original_position, 0.16)


func _spawn_damage_number(target_panel: Control, amount: int) -> void:
	if amount <= 0:
		return
	var damage_label := Label.new()
	damage_label.text = "-" + str(amount)
	damage_label.add_theme_font_size_override("font_size", 30)
	damage_label.add_theme_color_override("font_color", DAMAGE_COLOR)
	damage_label.z_index = 200
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


func _scroll_log_to_bottom() -> void:
	await get_tree().process_frame
	if log_scroll != null:
		log_scroll.scroll_vertical = int(log_scroll.get_v_scroll_bar().max_value)


func _format_techniques(player_name: String) -> String:
	var player := GameManager.player_a if player_name == GameManager.player_a.player_name else GameManager.player_b
	if player.techniques.is_empty():
		return "暂无"
	var names: Array[String] = []
	for technique in player.techniques:
		if technique is Dictionary:
			names.append(str(technique.get("quality", "")) + "·" + str(technique.get("name", "")))
	return "，".join(names)


func _format_names(items: Array) -> String:
	if items.is_empty():
		return "暂无"
	var names: Array[String] = []
	for item in items:
		if item is Dictionary:
			names.append(str(item.get("name", "")))
	return "，".join(names)


func _highlight_first(first_attacker: String) -> void:
	panel_a.add_theme_stylebox_override("panel", _make_panel_style(first_attacker == "player_a"))
	panel_b.add_theme_stylebox_override("panel", _make_panel_style(first_attacker == "player_b"))


func _on_duel_finished(data: Dictionary) -> void:
	btn_action.disabled = true
	btn_action.visible = false
	var winner_key: String = str(data.get("winner_key", ""))
	var local_key: String = "player_a" if NetworkManager.is_host else "player_b"
	final_choice_box.visible = true
	var is_local_winner: bool = local_key == winner_key
	final_choice_buttons.visible = is_local_winner
	if is_local_winner:
		label_result.text = "你已胜过" + str(data.get("loser", "")) + "。\n仙门已开，最后一步由你决定。"
		label_log.text += "\n你赢下仙位之争：是独自飞升，还是放弃仙位成全对方？"
	else:
		label_result.text = "你败于" + str(data.get("winner", "")) + "。\n等待对方决定仙位归属。"
		label_log.text += "\n仙位未定，胜者正在抉择。"
	_scroll_log_to_bottom()
