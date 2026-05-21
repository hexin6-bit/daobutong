extends Control

var line_edit_ip: LineEdit
var button_host: Button
var button_join: Button
var button_scan: Button
var label_status: Label
var room_list: ItemList
var line_edit_name: LineEdit

var button_single: Button
var button_continue: Button
var button_records: Button
var button_multiplayer: Button
var button_back: Button
var records_dialog: AcceptDialog
var mode_nodes: Array[CanvasItem] = []
var multiplayer_nodes: Array[CanvasItem] = []
var npc_nodes: Array[CanvasItem] = []


func _ready() -> void:
	UIEffects.add_background(self)
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	UIEffects.apply_button_press_tween(self)

	button_single.pressed.connect(_show_single_player_menu)
	button_continue.pressed.connect(_on_continue_pressed)
	button_records.pressed.connect(_on_records_pressed)
	button_multiplayer.pressed.connect(_show_multiplayer_menu)
	button_back.pressed.connect(_show_mode_menu)
	button_host.pressed.connect(_on_host_pressed)
	button_scan.pressed.connect(_on_scan_pressed)
	button_join.pressed.connect(_on_join_pressed)
	if not NetworkManager.connection_success.is_connected(_on_connected):
		NetworkManager.connection_success.connect(_on_connected)
	if not NetworkManager.connection_failed.is_connected(_on_connect_failed):
		NetworkManager.connection_failed.connect(_on_connect_failed)
	_show_mode_menu()


func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color(0.0, 0.0, 0.0, 0.0)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var title := Label.new()
	title.text = "道不同"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 54)
	title.add_theme_color_override("font_color", Color("#f0c040"))
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_set_top_band(title, 116, 86)
	add_child(title)

	var subtitle := Label.new()
	subtitle.text = "一人问道，二人同行"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 24)
	subtitle.add_theme_color_override("font_color", Color("#e0d5b7"))
	subtitle.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_set_top_band(subtitle, 205, 42)
	add_child(subtitle)

	var sect_hint := Label.new()
	sect_hint.text = "修行流派由功法与法宝定型，宗门身份由伙伴定型"
	sect_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sect_hint.add_theme_font_size_override("font_size", 19)
	sect_hint.add_theme_color_override("font_color", Color("#8a8070"))
	sect_hint.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_set_top_band(sect_hint, 374, 44)
	add_child(sect_hint)
	mode_nodes.append(sect_hint)

	button_single = _make_button("单机模式", Vector2(340, 86), 450)
	add_child(button_single)
	mode_nodes.append(button_single)

	button_continue = _make_button("继续游戏", Vector2(340, 70), 546)
	add_child(button_continue)
	mode_nodes.append(button_continue)

	button_records = _make_button("仙册名录", Vector2(340, 70), 632)
	add_child(button_records)
	mode_nodes.append(button_records)

	button_multiplayer = _make_button("联机模式", Vector2(340, 86), 724)
	add_child(button_multiplayer)
	mode_nodes.append(button_multiplayer)

	var hint := Label.new()
	hint.text = "单机：选一位同道 NPC 陪你试局\n联机：进入现在的局域网双人模式"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 20)
	hint.add_theme_color_override("font_color", Color("#8a8070"))
	hint.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_set_top_band(hint, 830, 80)
	add_child(hint)
	mode_nodes.append(hint)

	_build_npc_menu()
	_build_multiplayer_menu()
	records_dialog = AcceptDialog.new()
	records_dialog.title = "仙册名录"
	records_dialog.min_size = Vector2i(620, 520)
	add_child(records_dialog)

	button_back = _make_button("返回", Vector2(220, 60), 1040)
	add_child(button_back)

	label_status = Label.new()
	label_status.text = ""
	label_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_status.add_theme_font_size_override("font_size", 20)
	label_status.add_theme_color_override("font_color", Color("#808080"))
	label_status.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_set_bottom_band(label_status, -118, 58)
	add_child(label_status)


func _build_npc_menu() -> void:
	var label := Label.new()
	label.text = "选择同道"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 30)
	label.add_theme_color_override("font_color", Color("#f0c040"))
	label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_set_top_band(label, 420, 56)
	add_child(label)
	npc_nodes.append(label)

	var profiles: Array = GameManager.NPC_PROFILES
	for i in range(profiles.size()):
		var profile: Dictionary = profiles[i] as Dictionary
		var button := _make_npc_button(profile, 485 + i * 122)
		button.pressed.connect(_on_npc_selected.bind(str(profile.get("id", ""))))
		add_child(button)
		npc_nodes.append(button)


func _build_multiplayer_menu() -> void:
	button_host = _make_button("创建房间", Vector2(320, 78), 450)
	add_child(button_host)
	multiplayer_nodes.append(button_host)

	var separator := Label.new()
	separator.text = "或"
	separator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	separator.add_theme_font_size_override("font_size", 22)
	separator.add_theme_color_override("font_color", Color("#e0e0e0"))
	separator.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_set_top_band(separator, 550, 40)
	add_child(separator)
	multiplayer_nodes.append(separator)

	button_scan = _make_button("扫描局域网房间", Vector2(320, 78), 610)
	add_child(button_scan)
	multiplayer_nodes.append(button_scan)

	room_list = ItemList.new()
	room_list.custom_minimum_size = Vector2(500, 190)
	room_list.size = Vector2(500, 190)
	room_list.position = Vector2((750 - 500) * 0.5, 700)
	room_list.visible = false
	add_child(room_list)
	multiplayer_nodes.append(room_list)

	line_edit_ip = LineEdit.new()
	line_edit_ip.placeholder_text = "手动输入IP地址"
	line_edit_ip.text = "172.16.2.38"
	line_edit_ip.alignment = HORIZONTAL_ALIGNMENT_CENTER
	line_edit_ip.custom_minimum_size = Vector2(430, 64)
	line_edit_ip.size = Vector2(430, 64)
	line_edit_ip.position = Vector2((750 - 430) * 0.5, 830)
	line_edit_ip.visible = false
	line_edit_ip.add_theme_font_size_override("font_size", 22)
	add_child(line_edit_ip)
	multiplayer_nodes.append(line_edit_ip)

	button_join = _make_button("加入房间", Vector2(320, 78), 920)
	button_join.visible = false
	add_child(button_join)
	multiplayer_nodes.append(button_join)


func _make_npc_button(profile: Dictionary, y: float) -> Button:
	var button := Button.new()
	var name_text: String = str(profile.get("name", "同道"))
	var route_text: String = str(profile.get("route", "散修"))
	var intro_text: String = str(profile.get("intro", "愿与你同行一程。"))
	button.text = name_text + " · " + route_text + "\n" + intro_text
	button.custom_minimum_size = Vector2(570, 108)
	button.size = Vector2(570, 108)
	button.position = Vector2((750 - 570) * 0.5, y)
	button.add_theme_font_size_override("font_size", 22)
	return button


func _make_button(text: String, button_size: Vector2, y: float) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = button_size
	button.size = button_size
	button.position = Vector2((750 - button_size.x) * 0.5, y)
	button.add_theme_font_size_override("font_size", 24)
	return button


func _show_mode_menu() -> void:
	_set_nodes_visible(mode_nodes, true)
	_set_nodes_visible(multiplayer_nodes, false)
	_set_nodes_visible(npc_nodes, false)
	if line_edit_name != null:
		line_edit_name.visible = false
	button_continue.visible = GameManager.has_save_game()
	button_back.visible = false
	label_status.text = ""


func _show_single_player_menu() -> void:
	_set_nodes_visible(mode_nodes, false)
	_set_nodes_visible(multiplayer_nodes, false)
	_set_nodes_visible(npc_nodes, true)
	if line_edit_name != null:
		line_edit_name.visible = false
	button_back.visible = true
	label_status.text = "先选一位同道，入局后再立道号与天命。你的流派会在局内成形。"


func _show_multiplayer_menu() -> void:
	_set_nodes_visible(mode_nodes, false)
	_set_nodes_visible(npc_nodes, false)
	_set_nodes_visible(multiplayer_nodes, true)
	if line_edit_name != null:
		line_edit_name.visible = false
	button_back.visible = true
	room_list.visible = false
	line_edit_ip.visible = false
	button_join.visible = false
	label_status.text = "局域网模式保持原来的联机流程。"


func _set_top_band(control: Control, y: float, height: float) -> void:
	control.offset_left = 0.0
	control.offset_top = y
	control.offset_right = 0.0
	control.offset_bottom = y + height


func _set_bottom_band(control: Control, y: float, height: float) -> void:
	control.offset_left = 0.0
	control.offset_top = y
	control.offset_right = 0.0
	control.offset_bottom = y + height


func _set_nodes_visible(nodes: Array[CanvasItem], is_visible: bool) -> void:
	for node in nodes:
		if node != null and is_instance_valid(node):
			node.visible = is_visible


func _on_npc_selected(npc_id: String) -> void:
	label_status.text = "同道已至，正在入局..."
	GameManager.start_single_player_mode(npc_id, _get_entered_name())


func _on_continue_pressed() -> void:
	label_status.text = "正在读取存档..."
	if NetworkManager.has_method("prepare_offline_host_resume"):
		NetworkManager.prepare_offline_host_resume()
	if not GameManager.load_game_from_disk(true):
		label_status.text = "没有找到可继续的存档"
		button_continue.visible = false


func _on_records_pressed() -> void:
	var records: Array = GameManager.load_immortal_records()
	var lines: Array[String] = []
	if records.is_empty():
		lines.append("仙册尚空。")
	else:
		for i in range(records.size()):
			if not records[i] is Dictionary:
				continue
			var record: Dictionary = records[i] as Dictionary
			lines.append(str(i + 1) + ". " + str(record.get("name", "无名")) + "｜" + str(record.get("sect", "散修")) + "·" + str(record.get("cultivation", "散修")) + "·" + str(record.get("identity", "散修")))
			lines.append("   最强功法：" + str(record.get("strongest_technique", "无")) + "｜觉醒法宝：" + str(record.get("awakened_treasure", "无")))
			lines.append("   生死之交：" + str(record.get("closest_companion", "无")) + "｜最后一击：" + str(record.get("final_blow", "无")))
	if records_dialog != null:
		records_dialog.dialog_text = "\n".join(lines)
		records_dialog.popup_centered()


func _on_host_pressed() -> void:
	GameManager.start_multiplayer_mode(_get_entered_name())
	GameManager.player_a.player_name = GameManager.local_player_name
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

	GameManager.start_multiplayer_mode(_get_entered_name())
	GameManager.player_b.player_name = GameManager.local_player_name
	button_join.disabled = true
	label_status.text = "正在连接到 " + ip + "..."
	NetworkManager.join_host(ip)


func _on_connected() -> void:
	if GameManager.single_player_mode:
		return
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


func _get_entered_name() -> String:
	if line_edit_name == null:
		return GameManager.local_player_name
	return GameManager.local_player_name if line_edit_name.text.strip_edges() == "" else line_edit_name.text.strip_edges()
