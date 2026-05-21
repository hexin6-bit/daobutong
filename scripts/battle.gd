extends Control

const QUALITY_COLORS: Dictionary = {
	"炼气级": Color("#b0b0b0"),
	"筑基级": Color("#80c080"),
	"金丹级": Color("#6080d0"),
	"元婴级": Color("#c080e0"),
	"化神级": Color("#f0c040"),
	"合体级": Color("#ff80c0"),
}

var label_enemy_name: Label
var label_enemy_power: Label
var label_enemy_hp: Label
var label_log: Label
var label_my_hp: Label
var label_other_hp: Label
var enemy_bar: ProgressBar
var my_bar: ProgressBar
var other_bar: ProgressBar
var enemy_area: PanelContainer
var my_area: PanelContainer
var other_area: PanelContainer
var enemy_flash: ColorRect
var my_flash: ColorRect
var other_flash: ColorRect
var btn_attack: Button
var btn_circle: Button
var btn_escape: Button
var btn_continue: Button

var last_enemy_hp: int = -1
var last_enemy_power: int = -1
var last_my_hp: int = -1
var last_other_hp: int = -1
var my_hp_max: int = 100
var other_hp_max: int = 100


func _ready() -> void:
	var fallback := get_node_or_null("Fallback")
	if fallback is CanvasItem:
		(fallback as CanvasItem).visible = false
	UIEffects.add_background(self)
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	UIEffects.apply_button_press_tween(self)
	GameManager.battle_updated.connect(_on_battle_updated)
	GameManager.battle_ended.connect(_on_battle_ended)
	_update_battle_info({"enemy": GameManager.current_enemy, "battle_log": GameManager.battle_log}, false)
	GameManager.call_deferred("resume_loaded_state_after_scene_ready")


func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color(0.0, 0.0, 0.0, 0.0)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var root := VBoxContainer.new()
	UIEffects.apply_phone_safe_margins(root, 42.0, 74.0, 82.0)
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_theme_constant_override("separation", 22)
	add_child(root)

	enemy_area = _make_framed_area(Color("#201421"))
	enemy_area.custom_minimum_size = Vector2(1, 210)
	root.add_child(enemy_area)

	var enemy_box := VBoxContainer.new()
	enemy_box.add_theme_constant_override("separation", 10)
	enemy_area.add_child(enemy_box)

	label_enemy_name = _make_label("敌人", 28, Color("#ff5050"), HORIZONTAL_ALIGNMENT_CENTER)
	label_enemy_power = _make_label("战力估算：-", 18, Color("#f0c040"), HORIZONTAL_ALIGNMENT_CENTER)
	label_enemy_hp = _make_label("血量：-", 18, Color("#e0d5b7"), HORIZONTAL_ALIGNMENT_CENTER)
	enemy_box.add_child(label_enemy_name)
	enemy_box.add_child(label_enemy_power)
	enemy_box.add_child(_make_bar_frame(_make_hp_bar(Color("#c04040")), true))
	enemy_box.add_child(label_enemy_hp)
	enemy_flash = _add_flash_overlay(enemy_area)

	label_log = _make_label("战斗开始", 20, Color("#d8d8d8"), HORIZONTAL_ALIGNMENT_CENTER)
	label_log.custom_minimum_size = Vector2(1, 150)
	label_log.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(label_log)

	var player_row := HBoxContainer.new()
	player_row.custom_minimum_size = Vector2(1, 150)
	player_row.alignment = BoxContainer.ALIGNMENT_CENTER
	player_row.add_theme_constant_override("separation", 30)
	root.add_child(player_row)

	my_area = _make_framed_area(Color("#15261c"))
	my_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	other_area = _make_framed_area(Color("#15261c"))
	other_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	player_row.add_child(my_area)
	player_row.add_child(other_area)

	var my_box := VBoxContainer.new()
	my_box.add_theme_constant_override("separation", 8)
	my_area.add_child(my_box)
	label_my_hp = _make_label("我的气血：-", 18, Color("#80e090"), HORIZONTAL_ALIGNMENT_CENTER)
	my_bar = _make_hp_bar(Color("#40c060"))
	my_box.add_child(label_my_hp)
	my_box.add_child(_make_bar_frame(my_bar, false))
	my_flash = _add_flash_overlay(my_area)

	var other_box := VBoxContainer.new()
	other_box.add_theme_constant_override("separation", 8)
	other_area.add_child(other_box)
	label_other_hp = _make_label("对方气血：-", 18, Color("#80e090"), HORIZONTAL_ALIGNMENT_CENTER)
	other_bar = _make_hp_bar(Color("#40c060"))
	other_box.add_child(label_other_hp)
	other_box.add_child(_make_bar_frame(other_bar, false))
	other_flash = _add_flash_overlay(other_area)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.add_theme_constant_override("separation", 18)
	root.add_child(button_row)

	btn_attack = _make_button("⚔️ 抢攻", Color("#b04040"))
	btn_circle = _make_button("🛡️ 周旋", Color("#b09040"))
	btn_escape = _make_button("🏃 逃跑", Color("#4040b0"))
	btn_attack.pressed.connect(_on_action.bind("抢攻"))
	btn_circle.pressed.connect(_on_action.bind("周旋"))
	btn_escape.pressed.connect(_on_action.bind("逃跑"))
	button_row.add_child(btn_attack)
	button_row.add_child(btn_circle)
	button_row.add_child(btn_escape)

	btn_continue = _make_button("继续", Color("#3a3a5e"))
	btn_continue.visible = false
	btn_continue.custom_minimum_size = Vector2(280, 74)
	btn_continue.pressed.connect(_on_continue_pressed)
	root.add_child(btn_continue)


func _make_label(text: String, size: int, color: Color, alignment: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = alignment
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label


func _make_button(text: String, color: Color) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(190, 70)
	button.add_theme_font_size_override("font_size", 24)
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	return button


func _make_framed_area(color: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color("#f0c040")
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.content_margin_left = 18
	style.content_margin_top = 14
	style.content_margin_right = 18
	style.content_margin_bottom = 14
	panel.add_theme_stylebox_override("panel", style)
	return panel


func _make_bar_frame(bar: ProgressBar, is_enemy: bool) -> PanelContainer:
	if is_enemy:
		enemy_bar = bar
	var frame := PanelContainer.new()
	frame.custom_minimum_size = Vector2(1, 34)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#0f0e16")
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color("#f0c040")
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 3
	style.content_margin_top = 3
	style.content_margin_right = 3
	style.content_margin_bottom = 3
	frame.add_theme_stylebox_override("panel", style)
	frame.add_child(bar)
	return frame


func _make_hp_bar(fill_color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.min_value = 0.0
	bar.max_value = 100.0
	bar.value = 100.0
	bar.custom_minimum_size = Vector2(1, 26)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.show_percentage = false

	var background_style := StyleBoxFlat.new()
	background_style.bg_color = Color("#161420")
	background_style.corner_radius_top_left = 6
	background_style.corner_radius_top_right = 6
	background_style.corner_radius_bottom_left = 6
	background_style.corner_radius_bottom_right = 6
	bar.add_theme_stylebox_override("background", background_style)

	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = fill_color
	fill_style.corner_radius_top_left = 6
	fill_style.corner_radius_top_right = 6
	fill_style.corner_radius_bottom_left = 6
	fill_style.corner_radius_bottom_right = 6
	bar.add_theme_stylebox_override("fill", fill_style)
	return bar


func _solid_texture(color: Color) -> ImageTexture:
	var image := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	image.fill(color)
	return ImageTexture.create_from_image(image)


func _add_flash_overlay(parent: Control) -> ColorRect:
	var flash := ColorRect.new()
	flash.color = Color(1.0, 0.0, 0.0, 0.0)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(flash)
	return flash


func _on_action(action: String) -> void:
	_set_buttons_enabled(false)
	label_log.text = "你选择了「" + action + "」，等待对方..."
	if NetworkManager.is_host:
		var host_peer_id: int = GameManager.player_a.peer_id if GameManager.player_a != null and GameManager.player_a.peer_id > 0 else 1
		GameManager.settle_battle_action(host_peer_id, action)
	else:
		NetworkManager.send_message("battle_action", {"action": action})


func _on_battle_updated(data: Dictionary) -> void:
	_update_battle_info(data, true)
	var my_player: PlayerData = GameManager.player_a if NetworkManager.is_host else GameManager.player_b
	if my_player == null:
		_set_buttons_enabled(false)
		return
	_set_buttons_enabled(not _is_peer_escaped(data, my_player.peer_id))


func _on_battle_ended(data: Dictionary) -> void:
	_update_battle_info(data, true)
	var reward_lines: Array = data.get("reward_lines", []) as Array
	if reward_lines.is_empty():
		label_log.text = str(data.get("message", "战斗结束"))
	else:
		var lines: Array[String] = [str(data.get("battle_reward_title", "斩妖得胜"))]
		for reward_line in reward_lines:
			lines.append("· " + str(reward_line))
		label_log.text = "\n".join(lines)
	_set_buttons_enabled(false)

	var message := str(data.get("message", ""))
	var enemy: Dictionary = data.get("enemy", {}) as Dictionary
	if message.find("双方逃跑") != -1:
		_play_double_escape_elite_animation()
	elif not enemy.is_empty() and int(enemy.get("hp", 0)) <= 0:
		_play_enemy_death_effect(enemy)

	if btn_continue != null:
		btn_continue.visible = true
		btn_continue.disabled = false
		btn_continue.text = "看完了，继续"


func _on_continue_pressed() -> void:
	if btn_continue == null or btn_continue.disabled:
		return
	btn_continue.disabled = true
	btn_continue.text = "等待对方..."
	if NetworkManager.is_host:
		var host_peer_id: int = GameManager.player_a.peer_id if GameManager.player_a != null and GameManager.player_a.peer_id > 0 else 1
		GameManager.on_battle_continue_received(host_peer_id, {})
	else:
		NetworkManager.send_message("battle_continue", {})
	GameManager.pop_battle_reward_feedback()
	GameManager.transition_to_scene("res://scenes/game_main.tscn")


func _update_battle_info(data: Dictionary, animate: bool) -> void:
	var enemy: Dictionary = data.get("enemy", GameManager.current_enemy) as Dictionary
	if not enemy.is_empty():
		var enemy_hp: int = int(enemy.get("hp", 0))
		var enemy_max: int = maxi(1, int(enemy.get("max_hp", enemy.get("hp", 1))))
		var quality := str(enemy.get("quality", ""))
		label_enemy_name.text = str(enemy.get("name", "敌人"))
		label_enemy_name.add_theme_color_override("font_color", _quality_color(quality))
		var enemy_power: int = int(round(GameManager.get_enemy_visible_combat_power(enemy)))
		var power_arrow: String = ""
		if last_enemy_power >= 0 and enemy_power != last_enemy_power:
			power_arrow = " ↑" if enemy_power > last_enemy_power else " ↓"
		var pack_text: String = str(enemy.get("pack_text", ""))
		var pack_suffix: String = ("｜" + pack_text) if pack_text != "" else ""
		label_enemy_power.text = "战力估算：" + str(enemy_power) + power_arrow + "｜攻" + str(int(enemy.get("attack", 0))) + pack_suffix
		label_enemy_hp.text = "血量：" + str(enemy_hp) + " / " + str(enemy_max)
		_set_bar(enemy_bar, enemy_hp, enemy_max)
		if animate and last_enemy_hp >= 0 and enemy_hp < last_enemy_hp:
			var enemy_was_crit: bool = bool(data.get("crit_a", false)) or bool(data.get("crit_b", false))
			_play_hit_feedback(enemy_area, enemy_flash, last_enemy_hp - enemy_hp, Color("#ff6060"), enemy_was_crit)
			UIEffects.screen_shake(self, 3.5, 0.18)
		last_enemy_hp = enemy_hp
		last_enemy_power = enemy_power

	var my_player: PlayerData = GameManager.player_a if NetworkManager.is_host else GameManager.player_b
	var other_player: PlayerData = GameManager.player_b if NetworkManager.is_host else GameManager.player_a
	if my_player == null or other_player == null:
		label_log.text = "战斗数据同步中..."
		_set_buttons_enabled(false)
		return
	my_hp_max = maxi(my_hp_max, my_player.qi_xue)
	other_hp_max = maxi(other_hp_max, other_player.qi_xue)

	label_my_hp.text = "我的气血：" + str(my_player.qi_xue)
	label_other_hp.text = "对方气血：" + str(other_player.qi_xue)
	if not enemy.is_empty():
		var escape_chance: int = int(round(GameManager.get_escape_success_chance(my_player) * 100.0))
		label_my_hp.text += "｜逃跑 " + str(escape_chance) + "%"
	if _is_peer_escaped(data, my_player.peer_id):
		label_my_hp.text += "｜已脱离"
	if _is_peer_escaped(data, other_player.peer_id):
		label_other_hp.text += "｜已脱离"
	_set_bar(my_bar, my_player.qi_xue, my_hp_max)
	_set_bar(other_bar, other_player.qi_xue, other_hp_max)

	if animate and last_my_hp >= 0 and my_player.qi_xue < last_my_hp:
		_play_hit_feedback(my_area, my_flash, last_my_hp - my_player.qi_xue, Color("#ff7070"))
	if animate and last_other_hp >= 0 and other_player.qi_xue < last_other_hp:
		_play_hit_feedback(other_area, other_flash, last_other_hp - other_player.qi_xue, Color("#ff7070"))
	if animate:
		var my_key: String = "a" if my_player == GameManager.player_a else "b"
		var other_key: String = "b" if my_key == "a" else "a"
		var enemy_attack_mode: String = str(data.get("enemy_attack_mode", ""))
		var enemy_attack_target: String = str(data.get("enemy_attack_target", ""))
		if enemy_attack_mode == "group":
			_spawn_float_text(my_area, "横扫！", Color("#ffb060"))
			_spawn_float_text(other_area, "横扫！", Color("#ffb060"))
		elif enemy_attack_mode == "single":
			if enemy_attack_target == my_key:
				_spawn_float_text(my_area, "点名！", Color("#ffb060"))
			elif enemy_attack_target == other_key:
				_spawn_float_text(other_area, "点名！", Color("#ffb060"))
		if bool(data.get("dodge_" + my_key, false)):
			_spawn_float_text(my_area, "闪避！", Color("#80e0ff"))
		if bool(data.get("dodge_" + other_key, false)):
			_spawn_float_text(other_area, "闪避！", Color("#80e0ff"))
	last_my_hp = my_player.qi_xue
	last_other_hp = other_player.qi_xue

	var logs: Array = data.get("battle_log", GameManager.battle_log) as Array
	if not logs.is_empty():
		label_log.text = "\n".join(logs.slice(maxi(0, logs.size() - 4), logs.size()))


func _is_peer_escaped(data: Dictionary, peer_id: int) -> bool:
	var escaped: Dictionary = data.get("battle_escaped_peers", GameManager.battle_escaped_peers) as Dictionary
	return escaped.has(str(peer_id)) or escaped.has(peer_id)


func _set_bar(bar: ProgressBar, value: int, max_value: int) -> void:
	if bar == null:
		return
	bar.max_value = float(maxi(1, max_value))
	if bar.value <= 0.0 and value > 0:
		bar.value = float(maxi(1, max_value))
	var tween := create_tween()
	tween.tween_property(bar, "value", float(clampi(value, 0, max_value)), 0.18)


func _play_hit_feedback(area: Control, flash: ColorRect, amount: int, color: Color, crit: bool = false) -> void:
	_flash_area(flash)
	_spawn_damage_number(area, amount, color, crit)


func _flash_area(flash: ColorRect) -> void:
	if flash == null:
		return
	var tween := create_tween()
	tween.tween_property(flash, "color", Color(1.0, 0.0, 0.0, 0.4), 0.08)
	tween.tween_property(flash, "color", Color(1.0, 0.0, 0.0, 0.0), 0.22)


func _spawn_damage_number(area: Control, amount: int, color: Color, crit: bool = false) -> void:
	if amount <= 0:
		return
	var damage_label := Label.new()
	damage_label.text = ("暴击！\n" if crit else "") + "-" + str(amount)
	damage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	damage_label.add_theme_font_size_override("font_size", 36 if crit else 28)
	damage_label.add_theme_color_override("font_color", color)
	damage_label.z_index = 250
	damage_label.scale = Vector2(1.12, 1.12) if crit else Vector2.ONE
	add_child(damage_label)
	await get_tree().process_frame
	var start_position := area.global_position + area.size * 0.5 - global_position - damage_label.size * 0.5
	damage_label.position = start_position
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(damage_label, "position", start_position + Vector2(0.0, -54.0), 0.55)
	tween.tween_property(damage_label, "modulate:a", 0.0, 0.55)
	tween.set_parallel(false)
	tween.tween_callback(damage_label.queue_free)


func _spawn_float_text(area: Control, text: String, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 34)
	label.add_theme_color_override("font_color", color)
	label.z_index = 260
	add_child(label)
	await get_tree().process_frame
	var start_position := area.global_position + area.size * 0.5 - global_position - label.size * 0.5
	label.position = start_position
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position", start_position + Vector2(0.0, -48.0), 0.5)
	tween.tween_property(label, "modulate:a", 0.0, 0.5)
	tween.set_parallel(false)
	tween.tween_callback(label.queue_free)


func _play_enemy_death_effect(enemy: Dictionary) -> void:
	var quality := str(enemy.get("quality", ""))
	var color := _quality_color(quality)
	var particles := CPUParticles2D.new()
	particles.texture = _solid_texture(color)
	particles.amount = 38
	particles.lifetime = 1.0
	particles.one_shot = true
	particles.explosiveness = 0.95
	particles.direction = Vector2(0.0, -1.0)
	particles.spread = 180.0
	particles.gravity = Vector2(0.0, 180.0)
	particles.initial_velocity_min = 120.0
	particles.initial_velocity_max = 260.0
	particles.scale_amount_min = 1.4
	particles.scale_amount_max = 3.0
	particles.color = Color(color.r, color.g, color.b, 0.9)
	particles.position = enemy_area.global_position + enemy_area.size * 0.5 - global_position
	add_child(particles)
	particles.emitting = true
	UIEffects.screen_shake(self, 6.0, 0.32)


func _play_double_escape_elite_animation() -> void:
	var style := enemy_area.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	style.bg_color = Color("#08080c")
	enemy_area.add_theme_stylebox_override("panel", style)
	enemy_area.pivot_offset = enemy_area.size * 0.5
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(enemy_area, "scale", Vector2(1.5, 1.5), 0.32)
	tween.tween_property(enemy_area, "scale", Vector2.ONE, 0.28)


func _quality_color(quality: String) -> Color:
	return QUALITY_COLORS.get(quality, Color("#ff5050")) as Color


func _set_buttons_enabled(enabled: bool) -> void:
	btn_attack.disabled = not enabled
	btn_circle.disabled = not enabled
	btn_escape.disabled = not enabled
