class_name InventoryDropSlot
extends PanelContainer

var game_main: Node = null
var slot_type: String = ""
var slot_index: int = -1
var placeholder_text: String = ""
var holder: CenterContainer
var placeholder_label: Label
var normal_border_color: Color = Color("#3a3a6e")


func _ready() -> void:
	custom_minimum_size = Vector2(120, 58)
	_ensure_nodes()
	_apply_style(Color(0.08, 0.08, 0.17, 0.94), Color("#3a3a6e"))


func setup(owner_node: Node, target_type: String, index: int, text: String, border_color: Color = Color("#3a3a6e")) -> void:
	game_main = owner_node
	slot_type = target_type
	slot_index = index
	placeholder_text = text
	normal_border_color = border_color
	_ensure_nodes()
	placeholder_label.text = placeholder_text
	_apply_style(Color(0.08, 0.08, 0.17, 0.94), border_color)


func set_card(card: Control) -> void:
	_ensure_nodes()
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
		_apply_style(Color(0.18, 0.14, 0.06, 0.98), Color("#f0c040"), 4)
	else:
		_apply_style(Color(0.08, 0.08, 0.17, 0.94), normal_border_color, 2)
	return can_drop


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if game_main == null or not data is Dictionary:
		return
	_apply_style(Color(0.08, 0.08, 0.17, 0.94), normal_border_color, 2)
	if game_main.has_method("handle_inventory_drop"):
		game_main.call("handle_inventory_drop", data, slot_type, slot_index)


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
	placeholder_label.add_theme_font_size_override("font_size", UIEffects.mobile_font_size(15))
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
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 4
	style.content_margin_top = 4
	style.content_margin_right = 4
	style.content_margin_bottom = 4
	add_theme_stylebox_override("panel", style)
