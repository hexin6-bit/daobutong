extends Control

const PAPER_COLOR: Color = Color("#f0e6d0")
const WOOD_COLOR: Color = Color("#5a3a2a")
const INK_COLOR: Color = Color("#2a2a2a")
const GOLD_COLOR: Color = Color("#c09030")
const CALAMITY_COLOR: Color = Color("#a03030")
const COMPANION_COLOR: Color = Color("#6f6256")

var scroll_container: ScrollContainer
var content: VBoxContainer
var sections: Array[CanvasItem] = []


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	_render_scroll(GameManager.ending_scroll_data)
	UIEffects.apply_button_press_tween(self)
	call_deferred("_play_scroll_open")


func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = PAPER_COLOR
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var top_axis := ColorRect.new()
	top_axis.color = WOOD_COLOR
	top_axis.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_axis.size.y = 30
	add_child(top_axis)

	var bottom_axis := ColorRect.new()
	bottom_axis.color = WOOD_COLOR
	bottom_axis.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom_axis.position.y = -30
	bottom_axis.size.y = 30
	add_child(bottom_axis)

	scroll_container = ScrollContainer.new()
	UIEffects.apply_phone_safe_margins(scroll_container, 58.0, 64.0, 64.0)
	scroll_container.scale.y = 0.0
	add_child(scroll_container)

	content = VBoxContainer.new()
	content.add_theme_constant_override("separation", 24)
	scroll_container.add_child(content)


func _render_scroll(data: Dictionary) -> void:
	if data.is_empty():
		_add_section(_make_label("卷轴散佚，未能载入生平。", 34, GOLD_COLOR, HORIZONTAL_ALIGNMENT_CENTER))
		return

	var verdict := _make_label(str(data.get("verdict", "")), 34, GOLD_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
	verdict.custom_minimum_size = Vector2(600, 150)
	_add_section(verdict)

	_add_map_section("卷一·凡躯", data.get("凡躯", {}) as Dictionary, INK_COLOR)
	_add_map_section("卷二·机缘录", data.get("机缘录", {}) as Dictionary, GOLD_COLOR, ["best_ji_yuan", "techniques", "treasures"])
	_add_map_section("卷三·灾厄簿", data.get("灾厄簿", {}) as Dictionary, CALAMITY_COLOR, ["worst_calamity", "total_taken", "kang_count", "tui_count"])
	_add_map_section("卷四·天劫记", data.get("天劫记", {}) as Dictionary, INK_COLOR)
	_add_map_section("卷五·对决录", data.get("对决录", {}) as Dictionary, INK_COLOR)
	_add_companion_section(data.get("红尘录", {}) as Dictionary)
	_add_final_section(data.get("盖棺定论", {}) as Dictionary)

	var button := Button.new()
	button.text = "再来一局"
	button.custom_minimum_size = Vector2(300, 60)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.pressed.connect(_on_restart_pressed)
	_style_restart_button(button)
	_add_section(button)


func _add_map_section(title: String, data: Dictionary, accent: Color, accent_keys: Array[String] = []) -> void:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	box.add_child(_make_label(title, 26, GOLD_COLOR))
	for key in data.keys():
		var color := accent if accent_keys.has(str(key)) else INK_COLOR
		box.add_child(_make_label(_label_key(str(key)) + "：" + _format_value_for_key(str(key), data[key]), 20, color))
	_add_section(box)


func _add_companion_section(data: Dictionary) -> void:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	box.add_child(_make_label("卷六·红尘录", 26, GOLD_COLOR))
	var companions: Array = data.get("companions", []) as Array
	if companions.is_empty():
		box.add_child(_make_label("无人同行。", 20, INK_COLOR))
	else:
		for companion in companions:
			if companion is Dictionary:
				var c: Dictionary = companion
				var text := str(c.get("name", "")) + "：" + str(c.get("fate", "")) + "\n[i]“" + str(c.get("last_words", "")) + "”[/i]"
				box.add_child(_make_rich_label(text, 20, COMPANION_COLOR))
	_add_section(box)


func _add_final_section(data: Dictionary) -> void:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	box.add_child(_make_label("卷末·盖棺定论", 26, GOLD_COLOR))
	box.add_child(_make_label(str(data.get("title", "天命客")), 42, GOLD_COLOR, HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(_make_label(str(data.get("opponent_summary", "")), 22, INK_COLOR, HORIZONTAL_ALIGNMENT_CENTER))
	_add_section(box)


func _add_section(node: CanvasItem) -> void:
	node.modulate.a = 0.0
	content.add_child(node)
	sections.append(node)


func _make_label(text: String, font_size: int, color: Color, alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.text = text
	label.custom_minimum_size = Vector2(600, 1)
	label.horizontal_alignment = alignment
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _make_rich_label(text: String, font_size: int, color: Color) -> RichTextLabel:
	var label := RichTextLabel.new()
	label.bbcode_enabled = true
	label.text = text
	label.fit_content = true
	label.scroll_active = false
	label.custom_minimum_size = Vector2(600, 1)
	label.add_theme_font_size_override("normal_font_size", font_size)
	label.add_theme_color_override("default_color", color)
	return label


func _style_restart_button(button: Button) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = PAPER_COLOR
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = GOLD_COLOR
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	button.add_theme_color_override("font_color", INK_COLOR)


func _play_scroll_open() -> void:
	await get_tree().process_frame
	scroll_container.pivot_offset = Vector2(scroll_container.size.x * 0.5, 0.0)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(scroll_container, "scale:y", 1.0, 1.5)
	await tween.finished
	_play_reveal()


func _play_reveal() -> void:
	for i in sections.size():
		var tween := create_tween()
		tween.tween_interval(float(i) * 0.3)
		tween.tween_property(sections[i], "modulate:a", 1.0, 0.35)


func _format_value(value: Variant) -> String:
	if value is Dictionary:
		var parts: Array[String] = []
		for key in value.keys():
			parts.append(str(key) + " " + _format_simple_value(value[key]))
		return "，".join(parts)
	if value is Array:
		var parts: Array[String] = []
		for item in value:
			if item is Dictionary:
				parts.append(_format_named_dictionary(item as Dictionary))
			else:
				parts.append(str(item))
		return "，".join(parts) if not parts.is_empty() else "无"
	return _format_simple_value(value)


func _format_value_for_key(key: String, value: Variant) -> String:
	match key:
		"stats":
			return _format_stat_dictionary(value)
		"final_stats":
			return _format_final_stats(value)
		"tribulations":
			return _format_tribulations(value)
		"techniques", "treasures", "techniques_with_resonances":
			return _format_named_array(value)
		_:
			return _format_value(value)


func _format_simple_value(value: Variant) -> String:
	if value is float:
		var f: float = float(value)
		if is_equal_approx(f, roundf(f)):
			return str(int(roundf(f)))
		return str(snappedf(f, 0.01))
	return str(value)


func _format_stat_dictionary(value: Variant) -> String:
	if not value is Dictionary:
		return _format_value(value)
	var stats: Dictionary = value as Dictionary
	var order: Array[String] = ["体魄", "气感", "经商", "身法", "魅力", "机缘"]
	var parts: Array[String] = []
	for stat in order:
		if stats.has(stat):
			parts.append(stat + " " + str(int(round(float(stats[stat])))))
	return "，".join(parts) if not parts.is_empty() else "无"


func _format_final_stats(value: Variant) -> String:
	if not value is Dictionary:
		return _format_value(value)
	var stats: Dictionary = value as Dictionary
	var lines: Array[String] = []
	var core_parts: Array[String] = []
	for key in ["攻击力", "防御力", "气血", "速度"]:
		if stats.has(key):
			core_parts.append(str(key) + " " + str(int(round(float(stats[key])))))
	if not core_parts.is_empty():
		lines.append("属性：" + "，".join(core_parts))

	var resonances: Array = stats.get("真意列表", []) as Array
	var links: Array = stats.get("联动列表", []) as Array
	var companions: Array = stats.get("伙伴列表", []) as Array
	if not resonances.is_empty():
		lines.append("真意：" + _format_named_array(resonances))
	if not links.is_empty():
		lines.append("联动：" + _format_named_array(links))
	if not companions.is_empty():
		lines.append("伙伴：" + _format_named_array(companions))
	return "\n".join(lines) if not lines.is_empty() else "无"


func _format_tribulations(value: Variant) -> String:
	if not value is Array:
		return _format_value(value)
	var records: Array = value as Array
	if records.is_empty():
		return "未历天劫"
	var lines: Array[String] = []
	for i in range(records.size()):
		var item: Variant = records[i]
		if item is Dictionary:
			var choices: Array[String] = []
			var record: Dictionary = item as Dictionary
			for record_key in record.keys():
				choices.append(str(record[record_key]))
			lines.append("第" + str(i + 1) + "劫：" + "、".join(choices))
		else:
			lines.append("第" + str(i + 1) + "劫：" + str(item))
	return "\n".join(lines)


func _format_named_array(value: Variant) -> String:
	if not value is Array:
		return _format_value(value)
	var items: Array = value as Array
	if items.is_empty():
		return "无"
	var parts: Array[String] = []
	for item in items:
		if item is Dictionary:
			parts.append(_format_named_dictionary(item as Dictionary))
		else:
			parts.append(str(item))
	return "，".join(parts)


func _format_named_dictionary(data: Dictionary) -> String:
	if data.has("name"):
		var text: String = str(data.get("name", ""))
		if data.has("quality"):
			text = str(data.get("quality", "")) + "·" + text
		if data.has("resonances"):
			var resonances: Array = data.get("resonances", []) as Array
			if not resonances.is_empty():
				text += "（真意：" + _format_named_array(resonances) + "）"
		if data.has("active_links"):
			var links: Array = data.get("active_links", []) as Array
			if not links.is_empty():
				text += "（联动：" + _format_named_array(links) + "）"
		return text
	if data.has("desc"):
		return str(data.get("desc", ""))
	return "记录"


func _label_key(key: String) -> String:
	var names := {
		"stats": "六维",
		"shou_yuan": "寿元",
		"desc": "定调",
		"total_gained": "机缘总数",
		"qiang_count": "抢次数",
		"rang_count": "让次数",
		"best_ji_yuan": "最有价值机缘",
		"total_taken": "灾厄总数",
		"kang_count": "扛次数",
		"tui_count": "推次数",
		"worst_calamity": "最惨重灾厄",
		"shuang_kang": "双扛次数",
		"tribulations": "天劫记录",
		"worst_tribulation": "最惨烈天劫",
		"final_stats": "最终属性",
		"techniques_with_resonances": "功法真意联动",
		"key_rounds": "关键回合",
		"final_blow": "最后一击",
		"final_choice": "仙位抉择",
		"techniques": "功法",
		"treasures": "法宝",
	}
	return str(names.get(key, key))


func _on_restart_pressed() -> void:
	GameManager.reset_game()
	GameManager.transition_to_scene("res://scenes/main_menu.tscn")
