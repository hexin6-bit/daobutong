extends Control

var transitioning: bool = false


func _ready() -> void:
	UIEffects.add_background(self)
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	UIEffects.apply_button_press_tween(self)
	NetworkManager.player_connected.connect(_on_player_connected)

	if NetworkManager.connected and not NetworkManager.is_host:
		call_deferred("_on_player_connected", 1)


func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color(0.0, 0.0, 0.0, 0.0)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var spinner := Label.new()
	spinner.text = "⏳"
	spinner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	spinner.add_theme_font_size_override("font_size", 48)
	spinner.add_theme_color_override("font_color", Color("#f0c040"))
	spinner.set_anchors_preset(Control.PRESET_TOP_WIDE)
	spinner.position.y = 440
	spinner.size.y = 70
	add_child(spinner)

	var title := Label.new()
	title.text = "等待对手加入..."
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color("#e0e0e0"))
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.position.y = 530
	title.size.y = 60
	add_child(title)

	var ip_label := Label.new()
	ip_label.text = "本机IP：" + NetworkManager.local_ip
	ip_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ip_label.add_theme_font_size_override("font_size", 20)
	ip_label.add_theme_color_override("font_color", Color("#808080"))
	ip_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	ip_label.position.y = 610
	ip_label.size.y = 40
	add_child(ip_label)

	var tip_a := Label.new()
	tip_a.text = "将你的IP告诉对方"
	tip_a.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tip_a.add_theme_font_size_override("font_size", 16)
	tip_a.add_theme_color_override("font_color", Color("#808080"))
	tip_a.set_anchors_preset(Control.PRESET_TOP_WIDE)
	tip_a.position.y = 670
	tip_a.size.y = 32
	add_child(tip_a)

	var tip_b := Label.new()
	tip_b.text = "或让对方扫描局域网"
	tip_b.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tip_b.add_theme_font_size_override("font_size", 16)
	tip_b.add_theme_color_override("font_color", Color("#808080"))
	tip_b.set_anchors_preset(Control.PRESET_TOP_WIDE)
	tip_b.position.y = 710
	tip_b.size.y = 32
	add_child(tip_b)


func _on_player_connected(peer_id: int) -> void:
	if transitioning:
		return

	transitioning = true
	if NetworkManager.is_host:
		GameManager.player_a.peer_id = 1
		GameManager.player_a.player_name = GameManager.local_player_name
		GameManager.player_a.sect = GameManager.local_player_sect
		GameManager.player_b.peer_id = peer_id
	else:
		GameManager.player_a.peer_id = 1
		GameManager.player_b.peer_id = multiplayer.get_unique_id()
		GameManager.player_b.player_name = GameManager.local_player_name
		GameManager.player_b.sect = GameManager.local_player_sect

	GameManager.change_state(GameManager.GameState.STAT_ALLOCATION)
	GameManager.transition_to_scene("res://scenes/stat_alloc.tscn")
