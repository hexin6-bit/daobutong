class_name DaoCard
extends TextureRect

const CARD_SIZE: Vector2 = Vector2(200.0, 280.0)
const BACK_COLOR: Color = Color("#1a1a2e")
const GOLD_COLOR: Color = Color("#f0c040")
const PAPER_COLOR: Color = Color("#f5e6c8")
const INK_COLOR: Color = Color("#332418")
const CALAMITY_COLOR: Color = Color("#c04040")
const QUALITY_COLORS: Dictionary = {
	"炼气级": Color("#b0b0b0"),
	"筑基级": Color("#80c080"),
	"金丹级": Color("#6080d0"),
	"元婴级": Color("#c080e0"),
	"化神级": Color("#f0c040"),
	"合体级": Color("#ff80c0"),
}

@onready var glow_rect: ColorRect = $Glow
@onready var back_panel: Panel = $Back
@onready var back_glyph: Label = $Back/BackGlyph
@onready var face_panel: Panel = $Face
@onready var face_label: Label = $Face/FaceLabel
@onready var burst_particles: CPUParticles2D = $QualityBurst

var card_data: Dictionary = {}
var display_size: Vector2 = CARD_SIZE
var face_up: bool = false
var flipping: bool = false
var growth_label: Label
var sect_label: Label


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	face_label.add_theme_color_override("font_color", INK_COLOR)
	face_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	face_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	face_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	set_display_size(CARD_SIZE, 30)
	_apply_back_style(GOLD_COLOR)
	_apply_face_style(GOLD_COLOR)
	_ensure_growth_label()
	_ensure_sect_label()
	_setup_particles()
	_show_back()


func set_display_size(new_size: Vector2, font_size: int = 20) -> void:
	display_size = new_size
	custom_minimum_size = display_size
	size = display_size
	pivot_offset = display_size * 0.5
	if face_label != null:
		face_label.add_theme_font_size_override("font_size", font_size)
	if back_glyph != null:
		back_glyph.add_theme_font_size_override("font_size", int(display_size.y * 0.42))
	if burst_particles != null:
		burst_particles.position = display_size * 0.5
	if growth_label != null:
		growth_label.offset_left = display_size.x - 70.0
		growth_label.offset_top = display_size.y - 40.0
		growth_label.offset_right = display_size.x - 10.0
		growth_label.offset_bottom = display_size.y - 10.0
	if sect_label != null:
		sect_label.offset_left = display_size.x - 54.0
		sect_label.offset_top = 12.0
		sect_label.offset_right = display_size.x - 12.0
		sect_label.offset_bottom = 46.0


func setup_card(data: Dictionary, revealed: bool = false) -> void:
	card_data = data.duplicate(true)
	_update_face_text()
	_update_growth_badge()
	_update_sect_badge()
	if revealed:
		_show_face()
		set_quality(str(card_data.get("quality", "")))
	else:
		_show_back()


func set_quality(quality: String) -> void:
	var quality_color: Color = _card_border_color(quality)
	_apply_back_style(quality_color)
	_apply_face_style(quality_color)
	glow_rect.color = Color(quality_color.r, quality_color.g, quality_color.b, 0.28)
	glow_rect.visible = true

	if quality == "化神级":
		_burst_quality_particles(quality_color)
	elif quality == "合体级":
		_burst_rainbow_particles()
		_shake_screen()


func flip_card() -> void:
	if flipping:
		return

	flipping = true
	var target_scale_x: float = maxf(0.01, absf(scale.x))
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale:x", 0.0, 0.15)
	tween.tween_callback(_show_face)
	tween.tween_property(self, "scale:x", target_scale_x, 0.15)
	tween.tween_callback(_on_flip_finished)


func mark_settled() -> void:
	modulate = Color(0.70, 0.70, 0.70, 0.82)
	glow_rect.visible = false


func animate_growth(new_val: int) -> void:
	card_data["growth_value"] = new_val
	_update_growth_badge()
	if growth_label == null or not growth_label.visible:
		return
	var old_color: Color = growth_label.modulate
	var tween: Tween = create_tween()
	tween.tween_property(growth_label, "scale", Vector2(1.3, 1.3), 0.14)
	tween.parallel().tween_property(growth_label, "modulate", Color.WHITE, 0.14)
	tween.tween_property(growth_label, "scale", Vector2.ONE, 0.16)
	tween.parallel().tween_property(growth_label, "modulate", old_color, 0.16)
	for i in range(3):
		_spawn_growth_spark(i)


func play_calamity_reveal_effect() -> void:
	_burst_quality_particles(CALAMITY_COLOR)


func play_dao_reveal_effect() -> void:
	_burst_rainbow_particles()


func _on_flip_finished() -> void:
	flipping = false
	set_quality(str(card_data.get("quality", "")))


func _show_back() -> void:
	face_up = false
	back_panel.visible = true
	face_panel.visible = false
	glow_rect.visible = false
	if growth_label != null:
		growth_label.visible = false
	if sect_label != null:
		sect_label.visible = false
	modulate = Color.WHITE


func _show_face() -> void:
	face_up = true
	back_panel.visible = false
	face_panel.visible = true
	_update_growth_badge()
	_update_sect_badge()


func _update_face_text() -> void:
	var quality: String = str(card_data.get("quality", ""))
	var desc: String = _short_card_desc()
	if _should_show_quality_label():
		face_label.text = _quality_display_name(quality) + "\n\n" + desc
	else:
		face_label.text = desc


func _should_show_quality_label() -> bool:
	if bool(card_data.get("identity_special", false)):
		return false
	var effect_type: String = str(card_data.get("effect_type", ""))
	var kind: String = str(card_data.get("card_kind", card_data.get("kind", "")))
	return effect_type in ["technique", "treasure"] or kind in ["technique", "treasure"]


func _quality_display_name(quality: String) -> String:
	if Engine.has_singleton("GameManager"):
		return GameManager.quality_display_name(quality)
	return str({
		"炼气级": "炼气级",
		"筑基级": "筑基级",
		"金丹级": "金丹级",
		"元婴级": "元婴级",
		"化神级": "化神级",
		"合体级": "合体级",
	}.get(quality, quality))


func _ensure_growth_label() -> void:
	if growth_label != null:
		return
	growth_label = Label.new()
	growth_label.visible = false
	growth_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	growth_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	growth_label.add_theme_font_size_override("font_size", 18)
	growth_label.add_theme_color_override("font_color", GOLD_COLOR)
	growth_label.offset_left = display_size.x - 70.0
	growth_label.offset_top = display_size.y - 40.0
	growth_label.offset_right = display_size.x - 10.0
	growth_label.offset_bottom = display_size.y - 10.0
	growth_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(growth_label)


func _ensure_sect_label() -> void:
	if sect_label != null:
		return
	sect_label = Label.new()
	sect_label.visible = false
	sect_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sect_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	sect_label.add_theme_font_size_override("font_size", 20)
	sect_label.add_theme_color_override("font_color", GOLD_COLOR)
	sect_label.offset_left = display_size.x - 54.0
	sect_label.offset_top = 12.0
	sect_label.offset_right = display_size.x - 12.0
	sect_label.offset_bottom = 46.0
	sect_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(sect_label)


func _update_growth_badge() -> void:
	if growth_label == null:
		return
	var is_treasure: bool = str(card_data.get("card_kind", card_data.get("kind", ""))) == "treasure" or str(card_data.get("type", "")) == "法宝"
	if not is_treasure or not card_data.has("growth_value"):
		growth_label.visible = false
		return
	growth_label.visible = true
	growth_label.text = str(card_data.get("growth_icon", "道")) + str(int(card_data.get("growth_value", 0)))


func _update_sect_badge() -> void:
	if sect_label == null:
		return
	if not face_up or not bool(card_data.get("identity_special", false)):
		sect_label.visible = false
		return
	sect_label.visible = true
	sect_label.text = str(card_data.get("sect_mark", "宗"))
	sect_label.add_theme_color_override("font_color", _sect_color())


func _spawn_growth_spark(index: int) -> void:
	var spark := Label.new()
	spark.text = "*"
	spark.add_theme_font_size_override("font_size", 16)
	spark.add_theme_color_override("font_color", GOLD_COLOR)
	spark.position = Vector2(display_size.x - 38.0 + float(index) * 8.0, display_size.y - 36.0)
	spark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(spark)
	var tween: Tween = create_tween()
	tween.tween_property(spark, "position", spark.position + Vector2(0.0, -22.0 - float(index) * 3.0), 0.34)
	tween.parallel().tween_property(spark, "modulate:a", 0.0, 0.34)
	tween.tween_callback(spark.queue_free)


func _short_card_desc() -> String:
	if bool(card_data.get("identity_special", false)):
		return str(card_data.get("identity_sect", "宗门")) + "\n宗门专属"
	var effect_type: String = str(card_data.get("effect_type", ""))
	var value: int = int(round(float(card_data.get("effect_value", 0.0))))
	match effect_type:
		"ling_li":
			return "获得灵力\n+" + str(value)
		"heal_percent":
			return "回复气血\n" + str(value) + "%"
		"ling_shi":
			return "获得灵石\n+" + str(value)
		"stat_up":
			return str(card_data.get("stat", "属性")) + "\n+1"
		"shou_yuan":
			return "偶得延寿丹\n寿元+" + str(value)
		"technique":
			return "获得功法"
		"treasure":
			return "获得法宝"
		"dan":
			return "获得丹药"
		"companion":
			return "结识伙伴"
		"auction":
			return "拍卖会\n灵石+" + str(value)
		"quest":
			var quest: Dictionary = card_data.get("quest", {}) as Dictionary
			return "悬赏令\n" + str(quest.get("name", "接任务"))
		"adventure":
			return "秘境探索"
		"body_tempering":
			return "炼体熔炉"
		"sword_tempering":
			return "剑冢悟剑"
		"ghost_altar":
			return "招魂坛"
		"ling_li_loss":
			return "灵力流失\n-" + str(value)
		"hp_percent_loss":
			return "气血损伤\n-" + str(value) + "%"
		"shou_yuan_loss":
			return "寿元折损\n-" + str(value)
		"enemy":
			return "遭遇敌人"
		"tribulation":
			return "天劫征兆"
		_:
			return str(card_data.get("desc", "天命未明"))


func _apply_back_style(border_color: Color) -> void:
	back_panel.add_theme_stylebox_override("panel", _make_style(BACK_COLOR, border_color, 2))


func _apply_face_style(border_color: Color) -> void:
	face_panel.add_theme_stylebox_override("panel", _make_style(PAPER_COLOR, border_color, 3))


func _make_style(fill_color: Color, border_color: Color, border_width: int) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_color = border_color
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = 14
	style.corner_radius_top_right = 14
	style.corner_radius_bottom_right = 14
	style.corner_radius_bottom_left = 14
	style.content_margin_left = 14.0
	style.content_margin_top = 14.0
	style.content_margin_right = 14.0
	style.content_margin_bottom = 14.0
	return style


func _quality_color(quality: String) -> Color:
	return QUALITY_COLORS.get(quality, GOLD_COLOR) as Color


func _card_border_color(quality: String) -> Color:
	if bool(card_data.get("identity_special", false)):
		return _sect_color()
	return _quality_color(quality)


func _sect_color() -> Color:
	var raw_color: String = str(card_data.get("sect_color", ""))
	if raw_color.begins_with("#"):
		return Color(raw_color)
	return GOLD_COLOR


func _setup_particles() -> void:
	var image: Image = Image.create(3, 3, false, Image.FORMAT_RGBA8)
	image.fill(Color(1.0, 0.86, 0.28, 0.9))
	var particle_texture: ImageTexture = ImageTexture.create_from_image(image)
	burst_particles.texture = particle_texture
	burst_particles.amount = 28
	burst_particles.lifetime = 1.25
	burst_particles.one_shot = true
	burst_particles.explosiveness = 0.9
	burst_particles.emitting = false
	burst_particles.position = display_size * 0.5
	burst_particles.direction = Vector2(0.0, -1.0)
	burst_particles.spread = 180.0
	burst_particles.gravity = Vector2(0.0, 60.0)
	burst_particles.initial_velocity_min = 80.0
	burst_particles.initial_velocity_max = 150.0
	burst_particles.scale_amount_min = 1.0
	burst_particles.scale_amount_max = 2.2
	burst_particles.color = Color(1.0, 0.78, 0.22, 0.72)


func _burst_quality_particles(color: Color) -> void:
	burst_particles.color = Color(color.r, color.g, color.b, 0.76)
	burst_particles.emitting = false
	burst_particles.emitting = true


func _burst_rainbow_particles() -> void:
	var colors: Array[Color] = [
		Color("#ff80c0"),
		Color("#f0c040"),
		Color("#6080d0"),
	]
	var tween: Tween = create_tween()
	for color: Color in colors:
		tween.tween_callback(_burst_quality_particles.bind(color))
		tween.tween_interval(0.08)


func _shake_screen() -> void:
	var scene_root: CanvasItem = get_tree().current_scene as CanvasItem
	if scene_root == null:
		return

	var original_position: Vector2 = Vector2.ZERO
	if scene_root is Control:
		original_position = (scene_root as Control).position
	elif scene_root is Node2D:
		original_position = (scene_root as Node2D).position

	var tween: Tween = create_tween()
	tween.tween_property(scene_root, "position", original_position + Vector2(4.0, 0.0), 0.035)
	tween.tween_property(scene_root, "position", original_position + Vector2(-4.0, 0.0), 0.035)
	tween.tween_property(scene_root, "position", original_position + Vector2(2.0, 0.0), 0.035)
	tween.tween_property(scene_root, "position", original_position, 0.04)
