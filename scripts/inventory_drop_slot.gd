class_name InventoryDropSlot
extends PanelContainer

var game_main: Node = null
var slot_type: String = ""
var slot_index: int = -1
var placeholder_text: String = ""
var holder: CenterContainer
var placeholder_label: Label
var normal_border_color: Color = Color("#3a3a6e")
var slot_minimum_size: Vector2 = Vector2(116, 74)
var drag_highlighted: bool = false


func _ready() -> void:
	custom_minimum_size = slot_minimum_size
	_ensure_nodes()
	_apply_style(Color(0.08, 0.08, 0.17, 0.94), normal_border_color)
	if not mouse_exited.is_connected(_reset_drag_highlight):
		mouse_exited.connect(_reset_drag_highlight)


func setup(owner_node: Node, target_type: String, index: int, text: String, border_color: Color = Color("#3a3a6e"), min_size: Vector2 = Vector2.ZERO) -> void:
	game_main = owner_node
	slot_type = target_type
	slot_index = index
	placeholder_text = text
	normal_border_color = border_color
	if min_size != Vector2.ZERO:
		slot_minimum_size = min_size
	custom_minimum_size = slot_minimum_size
	_ensure_nodes()
	placeholder_label.text = placeholder_text
	_apply_style(Color(0.08, 0.08, 0.17, 0.94), border_color)


func set_card(card: Control) -> void:
	_ensure_nodes()
	_reset_drag_highlight()
	for child in holder.get_children():
		child.queue_free()

	if card == null:
		placeholder_label.visible = true
		return

	placeholder_label.visible = false
	holder.add_child(card)


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if game_main == null:
		return false
	if not data is Dictionary:
		return false
	if not game_main.has_method("can_drop_inventory_data"):
		return false
	var can_drop: bool = bool(game_main.call("can_drop_inventory_data", data, slot_type, slot_index))
	if can_drop:
		_set_drag_highlight(true)
	else:
		_set_drag_highlight(false)
	return can_drop


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if game_main == null or not data is Dictionary:
		return
	_reset_drag_highlight()
	if game_main.has_method("handle_inventory_drop"):
		game_main.call("handle_inventory_drop", data, slot_type, slot_index)


func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		_reset_drag_highlight()


func _ensure_nodes() -> void:
	if holder != null:
		return

	holder = CenterContainer.new()
	holder.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(holder)

	placeholder_label = Label.new()
	placeholder_label.text = placeholder_text
	placeholder_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	placeholder_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	placeholder_label.add_theme_font_size_override("font_size", UIEffects.mobile_font_size(17))
	placeholder_label.add_theme_color_override("font_color", Color("#8a8070"))
	add_child(placeholder_label)


func _apply_style(fill_color: Color, border_color: Color, border_width: int = 2) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_color = border_color
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.set_border_width_all(border_width)
	if slot_type == "technique" and holder != null and holder.get_child_count() == 0:
		style.border_blend = true
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 6
	style.content_margin_top = 6
	style.content_margin_right = 6
	style.content_margin_bottom = 6
	add_theme_stylebox_override("panel", style)


func _set_drag_highlight(can_drop: bool) -> void:
	drag_highlighted = true
	if can_drop:
		_apply_style(Color(0.07, 0.20, 0.16, 0.98), Color("#40c0a0"), 4)
		if placeholder_label != null:
			placeholder_label.add_theme_color_override("font_color", Color("#f0c040"))
	else:
		_apply_style(Color(0.22, 0.08, 0.08, 0.98), Color("#c04040"), 4)
		if placeholder_label != null:
			placeholder_label.add_theme_color_override("font_color", Color("#c04040"))


func _reset_drag_highlight() -> void:
	if not drag_highlighted:
		return
	drag_highlighted = false
	_apply_style(Color(0.08, 0.08, 0.17, 0.94), normal_border_color, 2)
	if placeholder_label != null:
		placeholder_label.add_theme_color_override("font_color", Color("#8a8070"))
