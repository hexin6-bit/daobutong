extends Control

var label_title: Label
var label_result: Label
var label_my_hp: Label
var label_other_hp: Label
var button_kang: Button
var button_duo: Button
var red_flash: ColorRect
var last_my_hp: int = 0
var last_other_hp: int = 0


func _ready() -> void:
	UIEffects.add_background(self)
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	UIEffects.apply_button_press_tween(self)
	GameManager.tribulation_settled.connect(_on_tribulation_settled)


func _build_ui() -> void:
	var data: Dictionary = GameManager.pending_tribulation_data

	var background := ColorRect.new()
	background.color = Color(0.0, 0.0, 0.0, 0.0)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	_add_tribulation_mask()
	_add_lightning_particles(str(data.get("name", "")))
	_add_vignette_if_needed(str(data.get("name", "")))

	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 48
	root.offset_top = 160
	root.offset_right = -48
	root.offset_bottom = -120
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_theme_constant_override("separation", 28)
	add_child(root)

	label_title = Label.new()
	label_title.text = str(data.get("name", "天劫"))
	label_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_title.add_theme_font_size_override("font_size", 42)
	label_title.add_theme_color_override("font_color", Color("#ff3030"))
	root.add_child(label_title)
	_start_title_shake()

	var subtitle := Label.new()
	subtitle.text = str(data.get("player_name", "修士")) + "欲突破至" + str(data.get("next_realm", "下一境界"))
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 22)
	subtitle.add_theme_color_override("font_color", Color("#e0e0e0"))
	root.add_child(subtitle)

	var preview := Label.new()
	preview.text = "扛：共同分担 " + _pct(data.get("shared_pct", 0.0)) + "  躲：避险者获得灵力 " + str(int(data.get("dodge_reward", 0))) + "\n若无人承担，双方承受 " + _pct(data.get("damage_pct", 0.0)) + " 伤害"
	preview.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	preview.add_theme_font_size_override("font_size", 18)
	preview.add_theme_color_override("font_color", Color("#c8c8c8"))
	root.add_child(preview)

	var hp_row := HBoxContainer.new()
	hp_row.alignment = BoxContainer.ALIGNMENT_CENTER
	hp_row.add_theme_constant_override("separation", 40)
	root.add_child(hp_row)

	var my_player := _get_my_player()
	var other_player := _get_other_player()
	last_my_hp = my_player.qi_xue
	last_other_hp = other_player.qi_xue
	label_my_hp = _make_hp_label("HP " + str(last_my_hp))
	label_other_hp = _make_hp_label("OPP HP " + str(last_other_hp))
	hp_row.add_child(label_my_hp)
	hp_row.add_child(label_other_hp)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.add_theme_constant_override("separation", 46)
	root.add_child(button_row)

	button_kang = _make_button("扛", Color("#b04040"))
	button_duo = _make_button("躲", Color("#4040b0"))
	button_kang.pressed.connect(_on_choice.bind("扛"))
	button_duo.pressed.connect(_on_choice.bind("躲"))
	button_row.add_child(button_kang)
	button_row.add_child(button_duo)

	label_result = Label.new()
	label_result.text = ""
	label_result.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label_result.add_theme_font_size_override("font_size", 20)
	label_result.add_theme_color_override("font_color", Color("#f0c040"))
	root.add_child(label_result)


func _make_button(text: String, color: Color) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(220, 80)
	button.add_theme_font_size_override("font_size", 30)
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	return button


func _make_hp_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color("#e0e0e0"))
	return label


func _add_tribulation_mask() -> void:
	var mask := ColorRect.new()
	mask.color = Color(0.25098, 0.0, 0.0, 0.7)
	mask.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mask.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(mask)

	red_flash = ColorRect.new()
	red_flash.color = Color(1.0, 0.0, 0.0, 0.0)
	red_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	red_flash.z_index = 300
	red_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(red_flash)


func _add_lightning_particles(tribulation_name: String) -> void:
	var image := Image.create(3, 30, false, Image.FORMAT_RGBA8)
	image.fill(Color(1.0, 1.0, 1.0, 0.92))
	var texture := ImageTexture.create_from_image(image)

	var particles := CPUParticles2D.new()
	particles.texture = texture
	particles.position = Vector2(375.0, -20.0)
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2(375.0, 10.0)
	particles.direction = Vector2(0.0, 1.0)
	particles.spread = 4.0
	particles.gravity = Vector2(0.0, 2000.0)
	particles.initial_velocity_min = 720.0
	particles.initial_velocity_max = 1200.0
	particles.scale_amount_min = 0.8
	particles.scale_amount_max = 1.25
	particles.one_shot = false
	particles.emitting = true
	var secondary_color := Color(0.82, 0.94, 1.0, 0.68)
	var secondary_amount := 5

	if tribulation_name.find("金丹") != -1:
		particles.amount = 20
		particles.lifetime = 0.38
		particles.color = Color(1.0, 0.28, 0.08, 0.9)
		secondary_color = Color(1.0, 0.58, 0.06, 0.72)
		secondary_amount = 8
	elif tribulation_name.find("心魔") != -1:
		particles.amount = 24
		particles.lifetime = 0.46
		particles.color = Color(0.48, 0.12, 0.78, 0.82)
		secondary_color = Color(0.02, 0.0, 0.04, 0.68)
		secondary_amount = 10
	else:
		particles.amount = 10
		particles.lifetime = 0.34
		particles.color = Color(0.82, 0.94, 1.0, 0.92)
		secondary_color = Color(1.0, 1.0, 1.0, 0.86)
		secondary_amount = 5

	add_child(particles)
	var secondary_particles := particles.duplicate() as CPUParticles2D
	secondary_particles.amount = secondary_amount
	secondary_particles.color = secondary_color
	secondary_particles.initial_velocity_min *= 0.92
	secondary_particles.initial_velocity_max *= 1.08
	add_child(secondary_particles)


func _add_vignette_if_needed(tribulation_name: String) -> void:
	if tribulation_name.find("心魔") == -1:
		return

	var top := _make_vignette_rect()
	top.anchor_right = 1.0
	top.offset_bottom = 180.0
	add_child(top)

	var bottom := _make_vignette_rect()
	bottom.anchor_top = 1.0
	bottom.anchor_right = 1.0
	bottom.anchor_bottom = 1.0
	bottom.offset_top = -180.0
	add_child(bottom)

	var left := _make_vignette_rect()
	left.anchor_bottom = 1.0
	left.offset_right = 110.0
	add_child(left)

	var right := _make_vignette_rect()
	right.anchor_left = 1.0
	right.anchor_right = 1.0
	right.anchor_bottom = 1.0
	right.offset_left = -110.0
	add_child(right)


func _make_vignette_rect() -> ColorRect:
	var rect := ColorRect.new()
	rect.color = Color(0.0, 0.0, 0.0, 0.36)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect


func _start_title_shake() -> void:
	if label_title == null:
		return
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(label_title, "position:x", 3.0, 0.045)
	tween.tween_property(label_title, "position:x", -3.0, 0.045)
	tween.tween_property(label_title, "position:x", 0.0, 0.045)


func _on_choice(choice: String) -> void:
	button_kang.disabled = true
	button_duo.disabled = true
	label_result.text = "已选择「" + choice + "」，等待对方..."

	if NetworkManager.is_host:
		GameManager.settle_tribulation(multiplayer.get_unique_id(), choice)
	else:
		NetworkManager.send_message("tribulation_choice", {"choice": choice})


func _on_tribulation_settled(result: Dictionary) -> void:
	var message: String = str(result.get("message", "天劫结算完成"))
	label_result.text = message + "\n突破者选择：" + str(result.get("breakthrough_choice", "-")) + "，另一方选择：" + str(result.get("other_choice", "-"))
	if bool(result.get("failed", false)):
		_spawn_tribulation_cut_in("突破失败", "雷火过身，境界未开。", Color("#ff3030"))
		UIEffects.screen_shake(self, 8.0, 0.35)
	elif bool(result.get("success", false)):
		_spawn_tribulation_cut_in("渡劫成功", "天门开了一线。", Color("#f0c040"))
		UIEffects.screen_shake(self, 5.0, 0.22)
	_update_hp_feedback()


func _update_hp_feedback() -> void:
	var my_player := _get_my_player()
	var other_player := _get_other_player()
	var current_my_hp := my_player.qi_xue
	var current_other_hp := other_player.qi_xue

	label_my_hp.text = "HP " + str(current_my_hp)
	label_other_hp.text = "OPP HP " + str(current_other_hp)

	var damaged := false
	if current_my_hp < last_my_hp:
		_flash_hp_label(label_my_hp)
		damaged = true
	if current_other_hp < last_other_hp:
		_flash_hp_label(label_other_hp)
		damaged = true
	if damaged:
		_flash_red_screen()

	last_my_hp = current_my_hp
	last_other_hp = current_other_hp


func _flash_hp_label(label: Label) -> void:
	var tween := create_tween()
	for i in 3:
		tween.tween_property(label, "modulate", Color("#ff3030"), 0.08)
		tween.tween_property(label, "modulate", Color.WHITE, 0.08)


func _flash_red_screen() -> void:
	if red_flash == null:
		return
	UIEffects.screen_shake(self, 4.0, 0.24)
	var tween := create_tween()
	tween.tween_property(red_flash, "color", Color(1.0, 0.0, 0.0, 0.3), 0.08)
	tween.tween_property(red_flash, "color", Color(1.0, 0.0, 0.0, 0.0), 0.24)


func _spawn_tribulation_cut_in(title: String, line: String, color: Color) -> void:
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.z_index = 300
	box.custom_minimum_size = Vector2(620.0, 130.0)
	add_child(box)

	var title_label := Label.new()
	title_label.text = title
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 54)
	title_label.add_theme_color_override("font_color", color)
	box.add_child(title_label)

	var line_label := Label.new()
	line_label.text = line
	line_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	line_label.add_theme_font_size_override("font_size", 25)
	line_label.add_theme_color_override("font_color", Color("#e0d5b7"))
	box.add_child(line_label)

	box.global_position = get_viewport_rect().size * 0.5 - Vector2(310.0, 150.0)
	box.scale = Vector2(0.86, 0.86)
	box.modulate.a = 0.0
	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(box, "scale", Vector2.ONE, 0.18)
	tween.tween_property(box, "modulate:a", 1.0, 0.18)
	tween.chain().tween_interval(0.8)
	tween.chain().tween_property(box, "global_position", box.global_position + Vector2(0.0, -52.0), 0.38)
	tween.parallel().tween_property(box, "modulate:a", 0.0, 0.38)
	tween.tween_callback(box.queue_free)


func _get_my_player() -> PlayerData:
	return GameManager.player_a if NetworkManager.is_host else GameManager.player_b


func _get_other_player() -> PlayerData:
	return GameManager.player_b if NetworkManager.is_host else GameManager.player_a


func _pct(value: Variant) -> String:
	return str(int(float(value) * 100.0)) + "%"
