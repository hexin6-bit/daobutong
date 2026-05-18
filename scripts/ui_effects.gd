class_name UIEffects
extends RefCounted

const BACKGROUND_SCENE: PackedScene = preload("res://scenes/background.tscn")
const MOBILE_FONT_SCALE: float = 1.16
const MOBILE_MIN_FONT_SIZE: int = 18
const PHONE_SAFE_MARGIN_X: float = 34.0
const PHONE_SAFE_MARGIN_TOP: float = 24.0
const PHONE_SAFE_MARGIN_BOTTOM: float = 30.0


static func add_background(parent: Node) -> void:
	var background: Node = BACKGROUND_SCENE.instantiate()
	if background is CanvasItem:
		var canvas_background: CanvasItem = background as CanvasItem
		canvas_background.z_index = -100
	parent.add_child(background)
	parent.move_child(background, 0)


static func apply_button_press_tween(root: Node) -> void:
	_apply_to_buttons(root)
	apply_mobile_font_scale(root)


static func mobile_font_size(base_size: int) -> int:
	if base_size <= 0:
		return base_size
	return maxi(MOBILE_MIN_FONT_SIZE, int(ceil(float(base_size) * MOBILE_FONT_SCALE)))


static func apply_mobile_font_scale(root: Node) -> void:
	_apply_font_scale(root)


static func apply_phone_safe_margins(control: Control, horizontal: float = PHONE_SAFE_MARGIN_X, top: float = PHONE_SAFE_MARGIN_TOP, bottom: float = PHONE_SAFE_MARGIN_BOTTOM) -> void:
	if control == null:
		return
	control.set_anchors_preset(Control.PRESET_FULL_RECT)
	control.offset_left = horizontal
	control.offset_top = top
	control.offset_right = -horizontal
	control.offset_bottom = -bottom


static func _apply_font_scale(node: Node) -> void:
	if node is Control:
		_scale_control_font(node as Control)

	for child: Node in node.get_children():
		_apply_font_scale(child)


static func _scale_control_font(control: Control) -> void:
	if bool(control.get_meta("dao_mobile_font_scaled", false)):
		return

	if control is RichTextLabel:
		_scale_font_key(control, "normal_font_size")
		_scale_font_key(control, "bold_font_size")
		_scale_font_key(control, "italics_font_size")
		_scale_font_key(control, "bold_italics_font_size")
		_scale_font_key(control, "mono_font_size")
	elif control is Label or control is Button or control is LineEdit or control is ItemList or control is TextEdit or control is OptionButton or control is CheckBox:
		_scale_font_key(control, "font_size")

	control.set_meta("dao_mobile_font_scaled", true)


static func _scale_font_key(control: Control, key: String) -> void:
	var base_size: int = 0
	if control.has_theme_font_size_override(key):
		base_size = control.get_theme_font_size(key)
	else:
		base_size = control.get_theme_font_size(key)
	if base_size <= 0:
		return

	control.add_theme_font_size_override(key, mobile_font_size(base_size))


static func _apply_to_buttons(node: Node) -> void:
	if node is Button:
		_connect_button(node as Button)

	for child: Node in node.get_children():
		_apply_to_buttons(child)


static func _connect_button(button: Button) -> void:
	if bool(button.get_meta("dao_press_tween", false)):
		return

	button.set_meta("dao_press_tween", true)
	button.pivot_offset = button.size * 0.5
	button.resized.connect(func() -> void:
		button.pivot_offset = button.size * 0.5
	)
	button.button_down.connect(func() -> void:
		_tween_button(button, Vector2(0.95, 0.95))
	)
	button.button_up.connect(func() -> void:
		_tween_button(button, Vector2.ONE)
	)
	button.mouse_exited.connect(func() -> void:
		_tween_button(button, Vector2.ONE)
	)


static func _tween_button(button: Button, target_scale: Vector2) -> void:
	if not is_instance_valid(button):
		return

	var tween: Tween = button.create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", target_scale, 0.08)


static func screen_shake(node: Node, intensity: float = 3.0, duration: float = 0.3) -> void:
	if not is_instance_valid(node):
		return
	if not (node is Control or node is Node2D):
		return

	var original_position := Vector2.ZERO
	if node is Control:
		original_position = (node as Control).position
	else:
		original_position = (node as Node2D).position

	var steps: int = maxi(2, int(duration / 0.04))
	var step_time: float = duration / float(steps)
	var tween: Tween = node.create_tween()
	for i in steps:
		var offset := Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		tween.tween_property(node, "position", original_position + offset, step_time)
	tween.tween_property(node, "position", original_position, 0.04)
