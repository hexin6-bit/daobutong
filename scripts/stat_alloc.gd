extends Control

const STAT_EFFECTS := {
	"体魄": "提升防御与气血",
	"气感": "提升攻击与灵力",
	"经商": "降低拍卖花费",
	"身法": "影响速度与闪避",
	"魅力": "影响伙伴与机缘",
	"机缘": "影响奇遇与宝物",
}

var year_gan: String = "甲"
var month_zhi: String = "子"
var day_gan: String = "甲"
var hour_zhi: String = "子"
var current_stats: Dictionary = {}
var current_hour_bonus: Dictionary = {}

var birth_year_edit: LineEdit
var birth_month_edit: LineEdit
var year_value_label: Label
var month_value_label: Label
var day_value_label: Label
var hour_value_label: Label
var stat_value_labels: Dictionary = {}
var total_points_label: Label
var status_label: Label
var confirm_button: Button


func _ready() -> void:
	UIEffects.add_background(self)
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	UIEffects.apply_button_press_tween(self)
	_randomize_all()
	if GameManager.single_player_mode:
		status_label.text = GameManager.player_b.player_name + "已在山门外等你。"


func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color(0.0, 0.0, 0.0, 0.0)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 18)
	root.offset_left = 50
	root.offset_top = 70
	root.offset_right = -50
	root.offset_bottom = -60
	add_child(root)

	var title := Label.new()
	title.text = "天道筑基"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 40)
	title.add_theme_color_override("font_color", Color("#f0c040"))
	root.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "输入你的生辰八字"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 18)
	subtitle.add_theme_color_override("font_color", Color("#e0e0e0"))
	root.add_child(subtitle)

	var spacer_top := Control.new()
	spacer_top.custom_minimum_size = Vector2(1, 8)
	root.add_child(spacer_top)

	var birth_row := HBoxContainer.new()
	birth_row.custom_minimum_size = Vector2(1, 52)
	birth_row.alignment = BoxContainer.ALIGNMENT_CENTER
	birth_row.add_theme_constant_override("separation", 10)
	root.add_child(birth_row)

	birth_year_edit = LineEdit.new()
	birth_year_edit.placeholder_text = "出生年"
	birth_year_edit.text = "2000"
	birth_year_edit.custom_minimum_size = Vector2(150, 46)
	birth_year_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	birth_row.add_child(birth_year_edit)

	birth_month_edit = LineEdit.new()
	birth_month_edit.placeholder_text = "出生月"
	birth_month_edit.text = "1"
	birth_month_edit.custom_minimum_size = Vector2(110, 46)
	birth_month_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	birth_row.add_child(birth_month_edit)

	var birth_button := Button.new()
	birth_button.text = "按年月生成"
	birth_button.custom_minimum_size = Vector2(170, 46)
	birth_button.pressed.connect(_apply_birth_input)
	birth_row.add_child(birth_button)

	year_value_label = _add_pillar_row(root, "年柱", "甲年", _randomize_year)
	month_value_label = _add_pillar_row(root, "月柱", "子月", _randomize_month)
	day_value_label = _add_pillar_row(root, "日柱", "甲日", _randomize_day)
	hour_value_label = _add_pillar_row(root, "时柱", "子时", _randomize_hour)

	var random_all_button := Button.new()
	random_all_button.text = "随机全部八字"
	random_all_button.custom_minimum_size = Vector2(300, 50)
	random_all_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	random_all_button.pressed.connect(_randomize_all)
	root.add_child(random_all_button)

	var separator := HSeparator.new()
	separator.custom_minimum_size = Vector2(1, 16)
	root.add_child(separator)

	var destiny_label := Label.new()
	destiny_label.text = "—— 天命所归 ——"
	destiny_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	destiny_label.add_theme_font_size_override("font_size", 18)
	destiny_label.add_theme_color_override("font_color", Color("#f0c040"))
	root.add_child(destiny_label)

	for stat in BaziCalculator.BASE_STATS:
		_add_stat_row(root, stat, STAT_EFFECTS.get(stat, ""))

	total_points_label = Label.new()
	total_points_label.text = "天赋总点：0 / 12"
	total_points_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	total_points_label.add_theme_font_size_override("font_size", 20)
	total_points_label.add_theme_color_override("font_color", Color("#e0e0e0"))
	root.add_child(total_points_label)

	status_label = Label.new()
	status_label.text = ""
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.add_theme_color_override("font_color", Color("#808080"))
	root.add_child(status_label)

	var bottom_spacer := Control.new()
	bottom_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(bottom_spacer)

	confirm_button = Button.new()
	confirm_button.text = "天命已定，踏入仙途"
	confirm_button.custom_minimum_size = Vector2(400, 60)
	confirm_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	confirm_button.pressed.connect(_on_confirm_pressed)
	root.add_child(confirm_button)


func _add_pillar_row(parent: VBoxContainer, title: String, value: String, callback: Callable) -> Label:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(1, 68)
	row.add_theme_constant_override("separation", 18)
	parent.add_child(row)

	var name_label := Label.new()
	name_label.text = title
	name_label.custom_minimum_size = Vector2(110, 48)
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 22)
	name_label.add_theme_color_override("font_color", Color("#e0e0e0"))
	row.add_child(name_label)

	var value_label := Label.new()
	value_label.text = value
	value_label.custom_minimum_size = Vector2(260, 48)
	value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value_label.add_theme_font_size_override("font_size", 26)
	value_label.add_theme_color_override("font_color", Color("#f0c040"))
	row.add_child(value_label)

	var button := Button.new()
	button.text = "随机"
	button.custom_minimum_size = Vector2(130, 48)
	button.pressed.connect(callback)
	row.add_child(button)

	return value_label


func _add_stat_row(parent: VBoxContainer, stat_name: String, effect_text: String) -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(1, 52)
	row.add_theme_constant_override("separation", 12)
	parent.add_child(row)

	var name_label := Label.new()
	name_label.text = stat_name
	name_label.custom_minimum_size = Vector2(90, 44)
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 22)
	name_label.add_theme_color_override("font_color", Color("#e0e0e0"))
	row.add_child(name_label)

	var effect_label := Label.new()
	effect_label.text = effect_text
	effect_label.custom_minimum_size = Vector2(360, 44)
	effect_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	effect_label.add_theme_font_size_override("font_size", 14)
	effect_label.add_theme_color_override("font_color", Color("#808080"))
	row.add_child(effect_label)

	var value_label := Label.new()
	value_label.text = "0"
	value_label.custom_minimum_size = Vector2(80, 44)
	value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.add_theme_font_size_override("font_size", 24)
	value_label.add_theme_color_override("font_color", Color("#f0c040"))
	row.add_child(value_label)
	stat_value_labels[stat_name] = value_label


func _randomize_year() -> void:
	year_gan = _pick(BaziCalculator.TIANGAN)
	_update_bazi()


func _randomize_month() -> void:
	month_zhi = _pick(BaziCalculator.DIZHI)
	_update_bazi()


func _randomize_day() -> void:
	day_gan = _pick(BaziCalculator.TIANGAN)
	_update_bazi()


func _randomize_hour() -> void:
	hour_zhi = _pick(BaziCalculator.DIZHI)
	_update_bazi()


func _apply_birth_input() -> void:
	var year: int = int(birth_year_edit.text.strip_edges())
	var month: int = clampi(int(birth_month_edit.text.strip_edges()), 1, 12)
	if year <= 0:
		status_label.text = "请输入正确出生年份"
		return

	year_gan = BaziCalculator.TIANGAN[posmod(year - 4, BaziCalculator.TIANGAN.size())]
	month_zhi = BaziCalculator.DIZHI[posmod(month + 1, BaziCalculator.DIZHI.size())]
	day_gan = BaziCalculator.TIANGAN[posmod(year + month, BaziCalculator.TIANGAN.size())]
	hour_zhi = _pick(BaziCalculator.DIZHI)
	status_label.text = "已按出生年月生成八字"
	_update_bazi()


func _randomize_all() -> void:
	var bazi := BaziCalculator.random_bazi()
	year_gan = bazi["year"]
	month_zhi = bazi["month"]
	day_gan = bazi["day"]
	hour_zhi = bazi["hour"]
	current_stats = bazi["stats"]
	current_hour_bonus = bazi["hour_bonus"]
	_update_labels()


func _update_bazi() -> void:
	current_stats = BaziCalculator.calculate_stats(year_gan, month_zhi, day_gan)
	current_hour_bonus = BaziCalculator.get_hour_bonus(hour_zhi)
	_update_labels()


func _update_labels() -> void:
	year_value_label.text = year_gan + "年"
	month_value_label.text = month_zhi + "月"
	day_value_label.text = day_gan + "日"
	hour_value_label.text = hour_zhi + "时"

	var total := 0
	for stat in BaziCalculator.BASE_STATS:
		var value := int(current_stats.get(stat, 0))
		total += value
		stat_value_labels[stat].text = str(value)

	total_points_label.text = "天赋总点：" + str(total) + " / 12"


func _pick(values: Array[String]) -> String:
	return values[BaziCalculator.rng.randi_range(0, values.size() - 1)]


func _on_confirm_pressed() -> void:
	confirm_button.disabled = true
	status_label.text = "已确认，等待对方..."

	var player: PlayerData = GameManager.player_a if GameManager.single_player_mode or NetworkManager.is_host else GameManager.player_b
	player.player_name = GameManager.local_player_name
	player.sect = ""
	_apply_data_to_player(player, current_stats, current_hour_bonus, _current_bazi_data())

	if GameManager.single_player_mode:
		status_label.text = GameManager.player_b.player_name + "点头同行，正在入局..."
		GameManager.start_game_main_if_stats_ready()
		return

	NetworkManager.send_message("stat_allocation", {
		"player_name": player.player_name,
		"stats": current_stats,
		"hour_bonus": current_hour_bonus,
	})

	if not NetworkManager.connected:
		GameManager.start_game_main_if_stats_ready()
	elif NetworkManager.is_host:
		GameManager.start_game_main_if_stats_ready()


func _apply_data_to_player(player: PlayerData, stats: Dictionary, hour_bonus: Dictionary, bazi: Dictionary) -> void:
	player.stats = GameManager._normalize_stats(stats)
	player.remain_points = 0
	player.minor_stage = 1
	player.final_attributes["bazi"] = bazi.duplicate(true)
	player.final_attributes["hour_bonus"] = hour_bonus.duplicate(true)
	GameManager.apply_hour_bonus_to_player(player, hour_bonus)
	GameManager.initialize_player_life(player)


func _current_bazi_data() -> Dictionary:
	return {
		"year": year_gan,
		"month": month_zhi,
		"day": day_gan,
		"hour": hour_zhi,
	}
