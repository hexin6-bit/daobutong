class_name InventoryDragCard
extends PanelContainer

var source: String = ""
var source_index: int = -1
var kind: String = ""
var entry: Dictionary = {}
var label: Label


func _ready() -> void:
	custom_minimum_size = Vector2(116, 54)
	mouse_filter = Control.MOUSE_FILTER_PASS
	_apply_style(Color("#f5e6c8"), Color("#f0c040"))
	if label == null:
		label = Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_size_override("font_size", UIEffects.mobile_font_size(16))
		label.add_theme_color_override("font_color", Color("#2a2a2a"))
		add_child(label)


func setup(card_text: String, drag_source: String, index: int, item_kind: String, item_entry: Dictionary, border_color: Color = Color("#f0c040")) -> void:
	source = drag_source
	source_index = index
	kind = item_kind
	entry = item_entry.duplicate(true)
	if label == null:
		label = Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_size_override("font_size", UIEffects.mobile_font_size(16))
		label.add_theme_color_override("font_color", Color("#2a2a2a"))
		add_child(label)
	label.text = card_text
	_apply_style(Color("#f5e6c8"), border_color)


func _gui_input(event: InputEvent) -> void:
	var should_show: bool = false
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		should_show = mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.double_click
	elif event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		should_show = touch_event.pressed and touch_event.double_tap

	if not should_show:
		return

	var scene := get_tree().current_scene
	if scene != null and scene.has_method("show_inventory_item_details"):
		scene.call("show_inventory_item_details", entry.duplicate(true), source, source_index)


func _get_drag_data(_at_position: Vector2) -> Variant:
	if source == "":
		return null

	var preview := PanelContainer.new()
	preview.custom_minimum_size = Vector2(176, 92)
	preview.z_index = 1000
	preview.modulate = Color(1.0, 1.0, 1.0, 0.96)
	var preview_style := StyleBoxFlat.new()
	preview_style.bg_color = Color("#f5e6c8")
	preview_style.border_color = Color("#f0c040")
	preview_style.border_width_left = 4
	preview_style.border_width_top = 4
	preview_style.border_width_right = 4
	preview_style.border_width_bottom = 4
	preview_style.corner_radius_top_left = 12
	preview_style.corner_radius_top_right = 12
	preview_style.corner_radius_bottom_left = 12
	preview_style.corner_radius_bottom_right = 12
	preview_style.content_margin_left = 10
	preview_style.content_margin_top = 8
	preview_style.content_margin_right = 10
	preview_style.content_margin_bottom = 8
	preview.add_theme_stylebox_override("panel", preview_style)

	var preview_box := VBoxContainer.new()
	preview_box.alignment = BoxContainer.ALIGNMENT_CENTER
	preview_box.add_theme_constant_override("separation", 0)
	preview.add_child(preview_box)

	var hint_label := Label.new()
	hint_label.text = "拖动中"
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.add_theme_font_size_override("font_size", UIEffects.mobile_font_size(18))
	hint_label.add_theme_color_override("font_color", Color("#c04040"))
	preview_box.add_child(hint_label)

	var preview_label := Label.new()
	preview_label.text = label.text
	preview_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	preview_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	preview_label.add_theme_font_size_override("font_size", UIEffects.mobile_font_size(22))
	preview_label.add_theme_color_override("font_color", Color("#2a2a2a"))
	preview_box.add_child(preview_label)
	set_drag_preview(preview)

	return {
		"source": source,
		"index": source_index,
		"kind": kind,
		"entry": entry.duplicate(true),
	}


func _apply_style(fill_color: Color, border_color: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_color = border_color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 6
	style.content_margin_top = 4
	style.content_margin_right = 6
	style.content_margin_bottom = 4
	add_theme_stylebox_override("panel", style)
