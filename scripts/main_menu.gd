extends Control

var line_edit_ip: LineEdit
var button_host: Button
var button_join: Button
var button_scan: Button
var label_status: Label
var room_list: ItemList


func _ready() -> void:
	UIEffects.add_background(self)
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	UIEffects.apply_button_press_tween(self)

	button_host.pressed.connect(_on_host_pressed)
	button_scan.pressed.connect(_on_scan_pressed)
	button_join.pressed.connect(_on_join_pressed)
	NetworkManager.connection_success.connect(_on_connected)
	NetworkManager.connection_failed.connect(_on_connect_failed)


func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color(0.0, 0.0, 0.0, 0.0)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var title := Label.new()
	title.text = "道不同"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color("#f0c040"))
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.position.y = 120
	title.size.y = 80
	add_child(title)

	var subtitle := Label.new()
	subtitle.text = "双人修仙博弈"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 20)
	subtitle.add_theme_color_override("font_color", Color("#e0e0e0"))
	subtitle.set_anchors_preset(Control.PRESET_TOP_WIDE)
	subtitle.position.y = 200
	subtitle.size.y = 40
	add_child(subtitle)

	button_host = _make_button("创建房间", Vector2(300, 80), 320)
	add_child(button_host)

	var separator := Label.new()
	separator.text = "或"
	separator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	separator.add_theme_font_size_override("font_size", 20)
	separator.add_theme_color_override("font_color", Color("#e0e0e0"))
	separator.set_anchors_preset(Control.PRESET_TOP_WIDE)
	separator.position.y = 420
	separator.size.y = 40
	add_child(separator)

	button_scan = _make_button("扫描局域网房间", Vector2(300, 80), 480)
	add_child(button_scan)

	room_list = ItemList.new()
	room_list.custom_minimum_size = Vector2(500, 200)
	room_list.size = Vector2(500, 200)
	room_list.position = Vector2((750 - 500) * 0.5, 580)
	room_list.visible = false
	add_child(room_list)

	line_edit_ip = LineEdit.new()
	line_edit_ip.placeholder_text = "手动输入IP地址"
	line_edit_ip.text = "172.16.2.38"
	line_edit_ip.alignment = HORIZONTAL_ALIGNMENT_CENTER
	line_edit_ip.custom_minimum_size = Vector2(400, 60)
	line_edit_ip.size = Vector2(400, 60)
	line_edit_ip.position = Vector2((750 - 400) * 0.5, 800)
	line_edit_ip.visible = false
	add_child(line_edit_ip)

	button_join = _make_button("加入房间", Vector2(300, 80), 880)
	button_join.visible = false
	add_child(button_join)

	label_status = Label.new()
	label_status.text = ""
	label_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_status.add_theme_font_size_override("font_size", 16)
	label_status.add_theme_color_override("font_color", Color("#808080"))
	label_status.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	label_status.position.y = -100
	label_status.size.y = 40
	add_child(label_status)


func _make_button(text: String, button_size: Vector2, y: float) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = button_size
	button.size = button_size
	button.position = Vector2((750 - button_size.x) * 0.5, y)
	return button


func _on_host_pressed() -> void:
	button_host.disabled = true
	label_status.text = "正在创建房间..."
	NetworkManager.start_host()


func _on_scan_pressed() -> void:
	label_status.text = "正在扫描局域网..."
	_scan_lan()


func _on_join_pressed() -> void:
	var ip := line_edit_ip.text.strip_edges()
	if ip == "":
		return

	button_join.disabled = true
	label_status.text = "正在连接到 " + ip + "..."
	NetworkManager.join_host(ip)


func _on_connected() -> void:
	label_status.text = "连接成功！"
	await get_tree().create_timer(0.5).timeout
	GameManager.transition_to_scene("res://scenes/lobby.tscn")


func _on_connect_failed() -> void:
	label_status.text = "连接失败，请重试"
	button_host.disabled = false
	button_join.disabled = false


func _scan_lan() -> void:
	label_status.text = "请手动输入对方IP地址"
	line_edit_ip.visible = true
	button_join.visible = true
	line_edit_ip.text = "172.16.2.38"
	line_edit_ip.placeholder_text = "例如：172.16.2.38"
