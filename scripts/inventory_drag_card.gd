class_name InventoryDragCard
extends PanelContainer

var source: String = ""
var source_index: int = -1
var kind: String = ""
var entry: Dictionary = {}
var label: Label
var growth_label: Label
var tap_start_position: Vector2 = Vector2.ZERO
var tap_tracking: bool = false
var tap_moved: bool = false

const TAP_MOVE_TOLERANCE := 30.0


func _ready() -> void:
	custom_minimum_size = Vector2(136, 78)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_apply_style(Color("#f5e6c8"), Color("#f0c040"))
	if label == null:
		label = Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_size_override("font_size", UIEffects.mobile_font_size(18))
		label.add_theme_color_override("font_color", Color("#2a2a2a"))
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(label)
	_ensure_growth_label()


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
		label.add_theme_font_size_override("font_size", UIEffects.mobile_font_size(18))
		label.add_theme_color_override("font_color", Color("#2a2a2a"))
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(label)
	label.text = card_text
	_apply_style(Color("#f5e6c8"), border_color)
	_ensure_growth_label()
	_update_growth_badge()


func animate_growth(new_val: int) -> void:
	_ensure_growth_label()
	var data: Dictionary = entry.get("data", {}) as Dictionary
	data["growth_value"] = new_val
	entry["data"] = data
	_update_growth_badge()
	if growth_label == null or not growth_label.visible:
		return
	var old_color: Color = growth_label.modulate
	var tween: Tween = create_tween()
	tween.tween_property(growth_label, "scale", Vector2(1.35, 1.35), 0.14)
	tween.parallel().tween_property(growth_label, "modulate", Color.WHITE, 0.14)
	tween.tween_property(growth_label, "scale", Vector2.ONE, 0.16)
	tween.parallel().tween_property(growth_label, "modulate", old_color, 0.16)
	for i in range(3):
		_spawn_growth_spark(i)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse_event.pressed:
			tap_tracking = true
			tap_moved = false
			tap_start_position = mouse_event.position
			accept_event()
			return
		if tap_tracking and not tap_moved:
			tap_tracking = false
			_show_details()
			accept_event()
			return
		tap_tracking = false
	elif event is InputEventMouseMotion:
		var motion_event: InputEventMouseMotion = event as InputEventMouseMotion
		if tap_tracking and tap_start_position.distance_to(motion_event.position) > TAP_MOVE_TOLERANCE:
			tap_moved = true
	elif event is InputEventScreenTouch:
		var touch_event: InputEventScreenTouch = event as InputEventScreenTouch
		if touch_event.pressed:
			tap_tracking = true
			tap_moved = false
			tap_start_position = touch_event.position
			accept_event()
			return
		if tap_tracking and not tap_moved:
			tap_tracking = false
			_show_details()
			accept_event()
			return
		tap_tracking = false
	elif event is InputEventScreenDrag:
		var drag_event: InputEventScreenDrag = event as InputEventScreenDrag
		if tap_tracking and tap_start_position.distance_to(drag_event.position) > TAP_MOVE_TOLERANCE:
			tap_moved = true


func _show_details() -> void:
	var scene := get_tree().current_scene
	if scene != null and scene.has_method("show_inventory_item_details"):
		scene.call("show_inventory_item_details", entry.duplicate(true), source, source_index)


func _get_drag_data(_at_position: Vector2) -> Variant:
	if source == "":
		return null
	tap_moved = true

	var preview := PanelContainer.new()
	preview.custom_minimum_size = Vector2(220, 118)
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
	hint_label.add_theme_font_size_override("font_size", UIEffects.mobile_font_size(22))
	hint_label.add_theme_color_override("font_color", Color("#c04040"))
	preview_box.add_child(hint_label)

	var preview_label := Label.new()
	preview_label.text = label.text
	preview_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	preview_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	preview_label.add_theme_font_size_override("font_size", UIEffects.mobile_font_size(26))
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
	style.content_margin_left = 8
	style.content_margin_top = 6
	style.content_margin_right = 8
	style.content_margin_bottom = 6
	add_theme_stylebox_override("panel", style)


func _ensure_growth_label() -> void:
	if growth_label != null:
		return
	growth_label = Label.new()
	growth_label.visible = false
	growth_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	growth_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	growth_label.add_theme_font_size_override("font_size", UIEffects.mobile_font_size(18))
	growth_label.add_theme_color_override("font_color", Color("#f0c040"))
	growth_label.anchor_left = 1.0
	growth_label.anchor_top = 1.0
	growth_label.anchor_right = 1.0
	growth_label.anchor_bottom = 1.0
	growth_label.offset_left = -56.0
	growth_label.offset_top = -28.0
	growth_label.offset_right = -6.0
	growth_label.offset_bottom = -4.0
	growth_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(growth_label)


func _update_growth_badge() -> void:
	if growth_label == null:
		return
	var data: Dictionary = entry.get("data", {}) as Dictionary
	if kind != "treasure" or not data.has("growth_value"):
		growth_label.visible = false
		return
	growth_label.visible = true
	growth_label.text = str(data.get("growth_icon", "道")) + str(int(data.get("growth_value", 0)))


func _spawn_growth_spark(index: int) -> void:
	if growth_label == null:
		return
	var spark := Label.new()
	spark.text = "*"
	spark.add_theme_font_size_override("font_size", UIEffects.mobile_font_size(16))
	spark.add_theme_color_override("font_color", Color("#f0c040"))
	spark.position = growth_label.position + Vector2(20.0 + float(index) * 8.0, -4.0)
	spark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(spark)
	var tween: Tween = create_tween()
	tween.tween_property(spark, "position", spark.position + Vector2(0.0, -18.0 - float(index) * 4.0), 0.34)
	tween.parallel().tween_property(spark, "modulate:a", 0.0, 0.34)
	tween.tween_callback(spark.queue_free)
