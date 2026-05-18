extends Control

const CARD_SCENE: PackedScene = preload("res://scenes/Card.tscn")

var label_round_info: Label
var label_enemy_name: Label
var label_enemy_shouyuan: Label
var label_enemy_lingli: Label
var label_enemy_lingshi: Label
var label_enemy_qixue: Label
var label_enemy_realm: Label
var label_enemy_tech_count: Label
var label_enemy_comp_count: Label
var lottery_container: CenterContainer
var lottery_scroll: ScrollContainer
var taiji_rect: TextureRect
var taiji_animation: AnimationPlayer
var btn_inject_shouyuan: Button
var label_current_ji_yuan: Label
var label_current_calamity: Label
var auction_panel: PanelContainer
var label_auction_title: Label
var label_auction_status: Label
var auction_lot_labels: Array[Label] = []
var auction_bid_buttons: Array[Button] = []
var auction_haggle_buttons: Array[Button] = []
var button_auction_pass: Button
var result_toast: PanelContainer
var label_result_title: Label
var label_result_detail: Label
var btn_continue_result: Button
var btn_qiang: Button
var btn_rang: Button
var label_waiting: Label
var scroll_my_info: ScrollContainer
var label_my_stats: Label
var label_my_realm_progress: Label
var bar_my_lingli: ProgressBar
var label_my_hp_progress: Label
var bar_my_hp: ProgressBar
var label_my_techniques: Label
var label_my_companions: Label
var label_my_treasures: Label
var label_backpack: Label
var label_backpack_block: Label
var button_breakthrough: Button
var button_market: Button
var technique_slot_nodes: Array[InventoryDropSlot] = []
var treasure_slot_node: InventoryDropSlot
var companion_slot_nodes: Array[InventoryDropSlot] = []
var backpack_slots_container: GridContainer
var pending_item_slot: InventoryDropSlot
var discard_slot: InventoryDropSlot
var backpack_list: ItemList
var backpack_menu: PopupMenu
var market_menu: PopupMenu
var treasure_list: ItemList
var treasure_menu: PopupMenu
var label_log: Label
var rainbow_flash: ColorRect
var edge_flash_top: ColorRect
var edge_flash_bottom: ColorRect
var edge_flash_left: ColorRect
var edge_flash_right: ColorRect
var floating_layer: Control

var lottery_panels: Array[PanelContainer] = []
var lottery_cards: Array[DaoCard] = []
var stat_chip_labels: Dictionary = {}
var pending_card_reveals: Array[Dictionary] = []
var revealed_visual_indices: Dictionary = {}
var cards_dealt: bool = false
var deal_animation_started: bool = false
var reveal_playback_active: bool = false
var local_choice_sent: bool = false
var result_continue_sent: bool = false
var latest_result_round_finished: bool = false
var latest_settled_index: int = -1


func _ready() -> void:
	UIEffects.add_background(self)
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	UIEffects.apply_button_press_tween(self)
	GameManager.lottery_generated.connect(_on_lottery_generated)
	GameManager.lottery_energy_updated.connect(_on_lottery_energy_updated)
	GameManager.lottery_energy_ready.connect(_on_lottery_energy_ready)
	GameManager.lottery_card_revealed.connect(_on_lottery_card_revealed)
	GameManager.bargain_ready.connect(_on_bargain_ready)
	GameManager.bargain_result.connect(_on_bargain_result)
	GameManager.backpack_changed.connect(_on_backpack_changed)
	GameManager.market_changed.connect(_on_market_changed)
	GameManager.auction_started.connect(_on_auction_started)
	GameManager.auction_ended.connect(_on_auction_ended)
	GameManager.breakthrough_feedback.connect(_on_breakthrough_feedback)
	btn_qiang.pressed.connect(_on_choice.bind("抢"))
	btn_rang.pressed.connect(_on_choice.bind("让"))

	_update_player_info()
	if not GameManager.current_lottery_results.is_empty():
		_on_lottery_generated(GameManager.current_lottery_results)
	GameManager.ensure_round_started()


func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color(0.0, 0.0, 0.0, 0.0)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var root := VBoxContainer.new()
	UIEffects.apply_phone_safe_margins(root, 34.0, 22.0, 34.0)
	root.add_theme_constant_override("separation", 8)
	add_child(root)

	root.add_child(_build_enemy_panel())
	root.add_child(_build_lottery_panel())
	root.add_child(_build_my_info_panel())
	root.add_child(_build_log_panel())

	floating_layer = Control.new()
	floating_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	floating_layer.z_index = 320
	floating_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(floating_layer)

	_build_screen_effect_layers()


func _build_screen_effect_layers() -> void:
	rainbow_flash = ColorRect.new()
	rainbow_flash.color = Color(1.0, 1.0, 1.0, 0.0)
	rainbow_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rainbow_flash.z_index = 400
	rainbow_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(rainbow_flash)

	edge_flash_top = _make_edge_flash_rect()
	edge_flash_top.anchor_right = 1.0
	edge_flash_top.offset_bottom = 72.0
	add_child(edge_flash_top)

	edge_flash_bottom = _make_edge_flash_rect()
	edge_flash_bottom.anchor_top = 1.0
	edge_flash_bottom.anchor_right = 1.0
	edge_flash_bottom.anchor_bottom = 1.0
	edge_flash_bottom.offset_top = -72.0
	add_child(edge_flash_bottom)

	edge_flash_left = _make_edge_flash_rect()
	edge_flash_left.anchor_bottom = 1.0
	edge_flash_left.offset_right = 72.0
	add_child(edge_flash_left)

	edge_flash_right = _make_edge_flash_rect()
	edge_flash_right.anchor_left = 1.0
	edge_flash_right.anchor_right = 1.0
	edge_flash_right.anchor_bottom = 1.0
	edge_flash_right.offset_left = -72.0
	add_child(edge_flash_right)


func _make_edge_flash_rect() -> ColorRect:
	var rect := ColorRect.new()
	rect.color = Color(0.752941, 0.25098, 0.25098, 0.0)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.z_index = 401
	return rect


func _make_taiji_texture(size_px: int) -> ImageTexture:
	var image: Image = Image.create(size_px, size_px, false, Image.FORMAT_RGBA8)
	var gold := Color("#f0c040")
	var ink := Color("#1a1a2e")
	var center := Vector2(float(size_px) * 0.5, float(size_px) * 0.5)
	var radius := float(size_px) * 0.47
	var upper_center := center + Vector2(0.0, -radius * 0.5)
	var lower_center := center + Vector2(0.0, radius * 0.5)

	for y in size_px:
		for x in size_px:
			var point := Vector2(float(x) + 0.5, float(y) + 0.5)
			var distance := point.distance_to(center)
			if distance > radius:
				image.set_pixel(x, y, Color(0.0, 0.0, 0.0, 0.0))
				continue

			var local := point - center
			var pixel_color := gold if local.x <= 0.0 else ink
			if point.distance_to(upper_center) <= radius * 0.5:
				pixel_color = ink
			if point.distance_to(lower_center) <= radius * 0.5:
				pixel_color = gold
			if point.distance_to(upper_center) <= radius * 0.11:
				pixel_color = gold
			if point.distance_to(lower_center) <= radius * 0.11:
				pixel_color = ink
			if distance >= radius - 2.0:
				pixel_color = gold
			image.set_pixel(x, y, pixel_color)

	return ImageTexture.create_from_image(image)


func _build_taiji_animation(parent: Node) -> void:
	taiji_animation = AnimationPlayer.new()
	taiji_animation.name = "TaijiAnimation"
	parent.add_child(taiji_animation)

	var animation := Animation.new()
	animation.length = 3.0
	animation.loop_mode = Animation.LOOP_LINEAR
	var track_index := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, NodePath("TaijiWheel:rotation"))
	animation.track_insert_key(track_index, 0.0, 0.0)
	animation.track_insert_key(track_index, 3.0, TAU)

	var library := AnimationLibrary.new()
	library.add_animation("rotate", animation)
	taiji_animation.add_animation_library("", library)
	taiji_animation.stop()


func _build_enemy_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(1, 148)
	_apply_panel_style(panel, Color("#22223f"))

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	panel.add_child(box)

	label_enemy_name = _make_label("对手", 22, Color("#f0c040"), HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(label_enemy_name)

	label_enemy_realm = _make_label("炼气一层", 16, Color("#8a8070"), HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(label_enemy_realm)

	var grid := GridContainer.new()
	grid.columns = 6
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 6)
	box.add_child(grid)

	_add_enemy_chip(grid, "寿", "label_enemy_shouyuan", Color("#f0c040"))
	_add_enemy_chip(grid, "灵", "label_enemy_lingli", Color("#80c080"))
	_add_enemy_chip(grid, "血", "label_enemy_qixue", Color("#c04040"))
	_add_enemy_chip(grid, "石", "label_enemy_lingshi", Color("#f0c040"))
	_add_enemy_chip(grid, "功", "label_enemy_tech_count", Color("#6080d0"))
	_add_enemy_chip(grid, "伴", "label_enemy_comp_count", Color("#c080e0"))
	return panel


func _build_lottery_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(1, 500)
	_apply_panel_style(panel, Color("#202038"))

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)

	label_round_info = _make_label("第 1 轮", 28, Color("#e0e0e0"), HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(label_round_info)

	var card_area := Control.new()
	card_area.custom_minimum_size = Vector2(1, 330)
	card_area.clip_contents = false
	box.add_child(card_area)

	taiji_rect = TextureRect.new()
	taiji_rect.name = "TaijiWheel"
	taiji_rect.texture = _make_taiji_texture(112)
	taiji_rect.custom_minimum_size = Vector2(112, 112)
	taiji_rect.size = Vector2(112, 112)
	taiji_rect.anchor_left = 0.5
	taiji_rect.anchor_right = 0.5
	taiji_rect.anchor_top = 0.5
	taiji_rect.anchor_bottom = 0.5
	taiji_rect.offset_left = -56
	taiji_rect.offset_right = 56
	taiji_rect.offset_top = -56
	taiji_rect.offset_bottom = 56
	taiji_rect.pivot_offset = Vector2(56, 56)
	taiji_rect.modulate.a = 0.55
	taiji_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_area.add_child(taiji_rect)
	_build_taiji_animation(card_area)

	lottery_scroll = null

	lottery_container = CenterContainer.new()
	lottery_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	card_area.add_child(lottery_container)

	btn_inject_shouyuan = Button.new()
	btn_inject_shouyuan.text = "注入能量"
	btn_inject_shouyuan.custom_minimum_size = Vector2(180, 48)
	btn_inject_shouyuan.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn_inject_shouyuan.pressed.connect(_on_inject_shouyuan_pressed)
	btn_inject_shouyuan.visible = false
	box.add_child(btn_inject_shouyuan)

	label_current_ji_yuan = _make_label("当前机缘：等待天命显化", 24, Color("#f0c040"), HORIZONTAL_ALIGNMENT_CENTER)
	label_current_calamity = _make_label("当前灾厄：等待天命显化", 24, Color("#c04040"), HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(label_current_ji_yuan)
	box.add_child(label_current_calamity)
	box.add_child(_build_auction_panel())

	result_toast = PanelContainer.new()
	result_toast.visible = false
	result_toast.custom_minimum_size = Vector2(1, 138)
	_apply_panel_style(result_toast, Color(0.08, 0.08, 0.16, 0.94))
	box.add_child(result_toast)

	var result_box := VBoxContainer.new()
	result_box.alignment = BoxContainer.ALIGNMENT_CENTER
	result_box.add_theme_constant_override("separation", 4)
	result_toast.add_child(result_box)
	label_result_title = _make_label("", 36, Color("#f0c040"), HORIZONTAL_ALIGNMENT_CENTER)
	label_result_detail = _make_label("", 24, Color("#e0d5b7"), HORIZONTAL_ALIGNMENT_CENTER)
	label_result_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_box.add_child(label_result_title)
	result_box.add_child(label_result_detail)
	btn_continue_result = Button.new()
	btn_continue_result.text = "看完了，翻下一张"
	btn_continue_result.custom_minimum_size = Vector2(320, 54)
	btn_continue_result.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn_continue_result.add_theme_font_size_override("font_size", 24)
	btn_continue_result.pressed.connect(_on_continue_result_pressed)
	result_box.add_child(btn_continue_result)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.add_theme_constant_override("separation", 40)
	box.add_child(button_row)

	btn_qiang = _make_choice_button("抢", Color("#c04040"))
	btn_rang = _make_choice_button("让", Color("#4040c0"))
	button_row.add_child(btn_qiang)
	button_row.add_child(btn_rang)

	label_waiting = _make_label("对手思考中...", 22, Color("#f0c040"), HORIZONTAL_ALIGNMENT_CENTER)
	label_waiting.visible = false
	box.add_child(label_waiting)
	return panel


func _build_auction_panel() -> PanelContainer:
	auction_panel = PanelContainer.new()
	auction_panel.visible = false
	auction_panel.custom_minimum_size = Vector2(1, 252)
	_apply_panel_style(auction_panel, Color("#2c210d"))

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	auction_panel.add_child(box)

	label_auction_title = _make_label("拍卖会", 32, Color("#f0c040"), HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(label_auction_title)

	label_auction_status = _make_label("选择一件拍品：经商降低花费，讲价更便宜，出价竞拍优先。", 20, Color("#e0d5b7"), HORIZONTAL_ALIGNMENT_CENTER)
	label_auction_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(label_auction_status)

	auction_lot_labels.clear()
	auction_bid_buttons.clear()
	auction_haggle_buttons.clear()
	for i in range(3):
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		box.add_child(row)

		var lot_label := _make_label("拍品", 19, Color("#e0d5b7"))
		lot_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lot_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.add_child(lot_label)
		auction_lot_labels.append(lot_label)

		var haggle_button := _make_auction_button("讲价")
		haggle_button.pressed.connect(_on_auction_action_pressed.bind(i, "haggle"))
		row.add_child(haggle_button)
		auction_haggle_buttons.append(haggle_button)

		var bid_button := _make_auction_button("出价")
		bid_button.pressed.connect(_on_auction_action_pressed.bind(i, "bid"))
		row.add_child(bid_button)
		auction_bid_buttons.append(bid_button)

	button_auction_pass = Button.new()
	button_auction_pass.text = "不买，离场"
	button_auction_pass.custom_minimum_size = Vector2(260, 48)
	button_auction_pass.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button_auction_pass.add_theme_font_size_override("font_size", 22)
	button_auction_pass.pressed.connect(_on_auction_action_pressed.bind(-1, "pass"))
	box.add_child(button_auction_pass)
	return auction_panel


func _make_auction_button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(92, 46)
	button.add_theme_font_size_override("font_size", 20)
	return button


func _build_my_info_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(1, 500)
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_apply_panel_style(panel, Color("#22223f"))

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_child(box)

	label_my_stats = _make_label("我 · 寿 10  灵 0  石 0  血 100  炼气一层", 24, Color("#e0d5b7"))
	box.add_child(label_my_stats)

	var realm_row := HBoxContainer.new()
	realm_row.alignment = BoxContainer.ALIGNMENT_CENTER
	realm_row.add_theme_constant_override("separation", 10)
	box.add_child(realm_row)

	label_my_realm_progress = _make_label("境界：炼气一层   修为 0 / 160", 20, Color("#f0c040"))
	label_my_realm_progress.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	realm_row.add_child(label_my_realm_progress)
	button_breakthrough = Button.new()
	button_breakthrough.text = "突破"
	button_breakthrough.custom_minimum_size = Vector2(122, 46)
	button_breakthrough.add_theme_font_size_override("font_size", 22)
	button_breakthrough.pressed.connect(_on_breakthrough_pressed)
	realm_row.add_child(button_breakthrough)
	bar_my_lingli = _make_status_bar(Color("#f0c040"), Color(0.08, 0.08, 0.16, 0.95))
	box.add_child(bar_my_lingli)

	label_my_hp_progress = _make_label("气血：100 / 100", 20, Color("#c04040"))
	box.add_child(label_my_hp_progress)
	bar_my_hp = _make_status_bar(Color("#c04040"), Color(0.08, 0.08, 0.16, 0.95))
	box.add_child(bar_my_hp)

	var stat_grid := GridContainer.new()
	stat_grid.columns = 6
	stat_grid.add_theme_constant_override("h_separation", 6)
	stat_grid.add_theme_constant_override("v_separation", 4)
	box.add_child(stat_grid)
	stat_chip_labels.clear()
	for stat in GameManager.BASE_STATS:
		_add_stat_chip(stat_grid, stat)

	label_my_techniques = _make_label("功法：暂无", 20, Color("#e0e0e0"))
	label_my_companions = _make_label("伙伴：暂无", 20, Color("#e0e0e0"))
	label_my_treasures = _make_label("法宝：暂无", 20, Color("#e0e0e0"))
	label_backpack = _make_label("背包：0 / 5", 20, Color("#e0d5b7"))
	label_backpack_block = _make_label("", 20, Color("#c04040"), HORIZONTAL_ALIGNMENT_CENTER)
	label_my_techniques.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label_my_companions.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label_my_treasures.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	var resource_row := HBoxContainer.new()
	resource_row.alignment = BoxContainer.ALIGNMENT_CENTER
	resource_row.add_theme_constant_override("separation", 12)
	box.add_child(resource_row)
	label_backpack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	resource_row.add_child(label_backpack)

	button_market = Button.new()
	button_market.text = "拍卖会"
	button_market.custom_minimum_size = Vector2(160, 54)
	button_market.add_theme_font_size_override("font_size", 24)
	button_market.pressed.connect(_on_market_pressed)
	button_market.visible = false
	resource_row.add_child(button_market)

	box.add_child(label_backpack_block)

	var equipment_row := HBoxContainer.new()
	equipment_row.alignment = BoxContainer.ALIGNMENT_CENTER
	equipment_row.add_theme_constant_override("separation", 8)
	box.add_child(equipment_row)
	technique_slot_nodes.clear()
	for i in range(3):
		var technique_slot := InventoryDropSlot.new()
		technique_slot.setup(self, "technique", i, "功法" + str(i + 1), Color("#6080d0"))
		equipment_row.add_child(technique_slot)
		technique_slot_nodes.append(technique_slot)

	treasure_slot_node = InventoryDropSlot.new()
	treasure_slot_node.setup(self, "treasure", 0, "法宝", Color("#f0c040"))
	equipment_row.add_child(treasure_slot_node)

	discard_slot = InventoryDropSlot.new()
	discard_slot.setup(self, "discard", 0, "弃置", Color("#c04040"))
	equipment_row.add_child(discard_slot)

	var companion_row := HBoxContainer.new()
	companion_row.alignment = BoxContainer.ALIGNMENT_CENTER
	companion_row.add_theme_constant_override("separation", 8)
	box.add_child(companion_row)
	companion_slot_nodes.clear()
	for i in range(3):
		var companion_slot := InventoryDropSlot.new()
		companion_slot.setup(self, "companion", i, "同伴" + str(i + 1), Color("#c080e0"))
		companion_row.add_child(companion_slot)
		companion_slot_nodes.append(companion_slot)

	backpack_slots_container = GridContainer.new()
	backpack_slots_container.columns = 5
	backpack_slots_container.add_theme_constant_override("h_separation", 8)
	backpack_slots_container.add_theme_constant_override("v_separation", 6)
	box.add_child(backpack_slots_container)

	treasure_list = ItemList.new()
	treasure_list.custom_minimum_size = Vector2(1, 46)
	treasure_list.item_selected.connect(_on_treasure_selected)
	treasure_list.visible = false
	box.add_child(treasure_list)

	backpack_list = ItemList.new()
	backpack_list.custom_minimum_size = Vector2(1, 72)
	backpack_list.item_selected.connect(_on_backpack_selected)
	backpack_list.visible = false
	box.add_child(backpack_list)

	treasure_menu = PopupMenu.new()
	treasure_menu.add_item("使用", 0)
	treasure_menu.add_item("炼化", 1)
	treasure_menu.id_pressed.connect(_on_treasure_menu_pressed)
	add_child(treasure_menu)

	backpack_menu = PopupMenu.new()
	backpack_menu.id_pressed.connect(_on_backpack_menu_pressed)
	add_child(backpack_menu)

	market_menu = PopupMenu.new()
	market_menu.id_pressed.connect(_on_market_menu_pressed)
	add_child(market_menu)
	return panel


func _build_log_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(1, 76)
	_apply_panel_style(panel, Color("#18182d"))
	label_log = _make_label("日志：等待本轮机缘生成", 20, Color("#e0e0e0"))
	label_log.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(label_log)
	return panel


func _add_stat_chip(parent: GridContainer, stat_name: String) -> void:
	var chip := PanelContainer.new()
	chip.custom_minimum_size = Vector2(104, 50)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.10, 0.20, 0.92)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color("#3a3a6e")
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 6
	style.content_margin_top = 4
	style.content_margin_right = 6
	style.content_margin_bottom = 4
	chip.add_theme_stylebox_override("panel", style)
	parent.add_child(chip)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 0)
	chip.add_child(box)

	var name_label := _make_label(stat_name, 14, Color("#8a8070"), HORIZONTAL_ALIGNMENT_CENTER)
	var value_label := _make_label("0", 24, Color("#f0c040"), HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(name_label)
	box.add_child(value_label)
	stat_chip_labels[stat_name] = value_label


func _add_enemy_stat(grid: GridContainer, title: String, value_label_name: String) -> void:
	grid.add_child(_make_label(title, 18, Color("#808080")))
	var value_label := _make_label("-", 20, Color("#e0e0e0"))
	grid.add_child(value_label)
	match value_label_name:
		"label_enemy_shouyuan":
			label_enemy_shouyuan = value_label
		"label_enemy_lingli":
			label_enemy_lingli = value_label
		"label_enemy_qixue":
			label_enemy_qixue = value_label
		"label_enemy_realm":
			label_enemy_realm = value_label


func _add_enemy_chip(parent: GridContainer, title: String, value_label_name: String, color: Color) -> void:
	var chip := PanelContainer.new()
	chip.custom_minimum_size = Vector2(88, 44)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.17, 0.96)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(color.r, color.g, color.b, 0.45)
	style.corner_radius_top_left = 7
	style.corner_radius_top_right = 7
	style.corner_radius_bottom_left = 7
	style.corner_radius_bottom_right = 7
	style.content_margin_left = 4
	style.content_margin_top = 4
	style.content_margin_right = 4
	style.content_margin_bottom = 4
	chip.add_theme_stylebox_override("panel", style)
	parent.add_child(chip)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 0)
	chip.add_child(box)

	var title_label := _make_label(title, 12, Color("#8a8070"), HORIZONTAL_ALIGNMENT_CENTER)
	var value_label := _make_label("0", 18, color, HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(title_label)
	box.add_child(value_label)

	match value_label_name:
		"label_enemy_shouyuan":
			label_enemy_shouyuan = value_label
		"label_enemy_lingli":
			label_enemy_lingli = value_label
		"label_enemy_lingshi":
			label_enemy_lingshi = value_label
		"label_enemy_qixue":
			label_enemy_qixue = value_label
		"label_enemy_tech_count":
			label_enemy_tech_count = value_label
		"label_enemy_comp_count":
			label_enemy_comp_count = value_label


func _make_choice_button(text: String, color: Color) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(210, 92)
	button.add_theme_font_size_override("font_size", 40)
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	return button


func _make_label(text: String, font_size: int, color: Color, alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = alignment
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _make_status_bar(fill_color: Color, background_color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(1, 26)
	bar.show_percentage = false
	bar.min_value = 0.0
	bar.max_value = 100.0
	bar.value = 0.0

	var background_style := StyleBoxFlat.new()
	background_style.bg_color = background_color
	background_style.border_width_left = 1
	background_style.border_width_top = 1
	background_style.border_width_right = 1
	background_style.border_width_bottom = 1
	background_style.border_color = Color(fill_color.r, fill_color.g, fill_color.b, 0.42)
	background_style.corner_radius_top_left = 9
	background_style.corner_radius_top_right = 9
	background_style.corner_radius_bottom_left = 9
	background_style.corner_radius_bottom_right = 9
	bar.add_theme_stylebox_override("background", background_style)

	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = fill_color
	fill_style.corner_radius_top_left = 9
	fill_style.corner_radius_top_right = 9
	fill_style.corner_radius_bottom_left = 9
	fill_style.corner_radius_bottom_right = 9
	bar.add_theme_stylebox_override("fill", fill_style)
	return bar


func _apply_panel_style(panel: PanelContainer, color: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 16
	style.content_margin_top = 12
	style.content_margin_right = 16
	style.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", style)


func _apply_lottery_card_panel_style(panel: PanelContainer, color: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 3
	style.content_margin_top = 3
	style.content_margin_right = 3
	style.content_margin_bottom = 3
	panel.add_theme_stylebox_override("panel", style)


func _on_lottery_generated(results: Array) -> void:
	_render_lottery(results)
	_prepare_lottery_visuals(results)
	_hide_result_toast()
	if GameManager.current_state == GameManager.GameState.BARGAIN:
		_update_current_group()
	else:
		_set_choice_enabled(false)
	_update_player_info()
	label_log.text = "日志：第 " + str(GameManager.round_number) + " 轮抽卡开始，双方各耗一年寿元；修为只来自本轮翻出的卡牌"


func _prepare_lottery_visuals(results: Array) -> void:
	if GameManager.current_state == GameManager.GameState.BARGAIN:
		cards_dealt = true
		deal_animation_started = true
		pending_card_reveals.clear()
		if btn_inject_shouyuan != null:
			btn_inject_shouyuan.visible = false
		if taiji_rect != null:
			taiji_rect.modulate.a = 0.0
		if taiji_animation != null:
			taiji_animation.speed_scale = 1.0
			taiji_animation.stop()
		return

	var has_hidden_cards := _has_hidden_lottery_cards(results)
	if not has_hidden_cards:
		cards_dealt = true
		deal_animation_started = false
		pending_card_reveals.clear()
		revealed_visual_indices.clear()
		for i in lottery_cards.size():
			revealed_visual_indices[i] = true
		if btn_inject_shouyuan != null:
			btn_inject_shouyuan.visible = false
		if taiji_animation != null:
			taiji_animation.speed_scale = 1.0
			taiji_animation.stop()
		return

	cards_dealt = false
	deal_animation_started = false
	reveal_playback_active = false
	pending_card_reveals.clear()
	revealed_visual_indices.clear()
	if taiji_rect != null:
		taiji_rect.visible = true
		taiji_rect.modulate.a = 0.55
		taiji_rect.rotation = 0.0
	if taiji_animation != null:
		taiji_animation.speed_scale = 1.0
		taiji_animation.stop()
	if btn_inject_shouyuan != null:
		btn_inject_shouyuan.text = "注入能量"
		btn_inject_shouyuan.visible = true
		btn_inject_shouyuan.disabled = false
	label_round_info.text = "第 " + str(GameManager.round_number) + " 轮 · 等待双方注入能量"


func _has_hidden_lottery_cards(results: Array) -> bool:
	for item in results:
		if item is Dictionary:
			var card: Dictionary = item
			if not card.has("effect_type"):
				return true
	return false


func _on_inject_shouyuan_pressed() -> void:
	if btn_inject_shouyuan != null:
		btn_inject_shouyuan.disabled = true
		btn_inject_shouyuan.text = "已注入，等待对方"
	label_log.text = "日志：你已注入能量，等待对方回应"
	if NetworkManager.is_host:
		GameManager.on_lottery_energy_injected(1)
	else:
		NetworkManager.send_message("lottery_energy")


func _on_lottery_energy_updated(count: int, total: int) -> void:
	label_log.text = "日志：能量注入 " + str(count) + " / " + str(total)
	if btn_inject_shouyuan != null and not btn_inject_shouyuan.disabled:
		btn_inject_shouyuan.text = "注入能量（" + str(count) + "/" + str(total) + "）"


func _on_lottery_energy_ready() -> void:
	label_log.text = "日志：双方能量汇入，八卦阵启动"
	_start_lottery_visual_sequence()


func _start_lottery_visual_sequence() -> void:
	if deal_animation_started or cards_dealt:
		return

	deal_animation_started = true
	if btn_inject_shouyuan != null:
		btn_inject_shouyuan.disabled = true
		btn_inject_shouyuan.text = "寿元入局"
	if taiji_rect != null:
		taiji_rect.visible = true
		taiji_rect.modulate.a = 0.7
	if taiji_animation != null:
		taiji_animation.play("rotate")
		var speed_tween := create_tween()
		speed_tween.tween_property(taiji_animation, "speed_scale", 3.0, 1.5)

	_play_card_deal_sequence()


func _play_card_deal_sequence() -> void:
	await get_tree().create_timer(1.5).timeout

	if taiji_rect != null:
		var fade_out_tween := create_tween()
		fade_out_tween.tween_property(taiji_rect, "modulate:a", 0.0, 0.25)
		await fade_out_tween.finished
	if taiji_animation != null:
		taiji_animation.speed_scale = 1.0
		taiji_animation.stop()

	if lottery_cards.is_empty():
		_render_lottery(GameManager.current_lottery_results, true)
		await get_tree().process_frame
	await get_tree().process_frame

	var taiji_center := _get_taiji_center_global()
	var final_positions: Array[Vector2] = []
	for card: DaoCard in lottery_cards:
		var parent_control: Control = card.get_parent() as Control
		var base_scale: Vector2 = card.get_meta("base_scale", Vector2.ONE) as Vector2
		if parent_control == null:
			final_positions.append(Vector2.ZERO)
			continue
		final_positions.append(card.position)
		var start_position := taiji_center - parent_control.global_position - card.size * base_scale * 0.5
		card.position = start_position
		card.modulate.a = 0.0
		card.scale = base_scale * 0.72

	for i in lottery_cards.size():
		var card := lottery_cards[i]
		var base_scale: Vector2 = card.get_meta("base_scale", Vector2.ONE) as Vector2
		var tween := create_tween()
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_ease(Tween.EASE_OUT)
		tween.set_parallel(true)
		tween.tween_property(card, "position", final_positions[i], 0.3)
		tween.tween_property(card, "scale", base_scale, 0.3)
		tween.tween_property(card, "modulate:a", 1.0, 0.3)
		await get_tree().create_timer(0.05).timeout

	await get_tree().create_timer(0.35).timeout
	cards_dealt = true
	if btn_inject_shouyuan != null:
		btn_inject_shouyuan.visible = false
	if taiji_animation != null:
		var speed_tween := create_tween()
		speed_tween.tween_property(taiji_animation, "speed_scale", 1.0, 0.45)
	if taiji_rect != null:
		taiji_rect.modulate.a = 0.0
	if NetworkManager.is_host:
		GameManager.begin_lottery_reveal()
	_flush_pending_card_reveals()


func _get_taiji_center_global() -> Vector2:
	if taiji_rect == null:
		return get_viewport_rect().size * 0.5
	return taiji_rect.global_position + taiji_rect.size * 0.5


func _flush_pending_card_reveals() -> void:
	if reveal_playback_active:
		return

	reveal_playback_active = true
	while not pending_card_reveals.is_empty():
		var payload: Dictionary = pending_card_reveals.pop_front()
		_play_card_reveal(int(payload.get("index", 0)), payload.get("card", {}) as Dictionary)
		await get_tree().create_timer(0.5).timeout
	reveal_playback_active = false


func _play_card_reveal(index: int, card: Dictionary) -> void:
	if index < 0:
		return
	if revealed_visual_indices.has(index):
		return
	if _visible_card_source_index() != index:
		_render_single_lottery_card(index, card, false)
	if lottery_cards.is_empty():
		return

	revealed_visual_indices[index] = true
	var card_node: DaoCard = lottery_cards[0]
	card_node.setup_card(card, false)
	card_node.flip_card()
	_play_card_reveal_effects(card_node, card)
	label_log.text = "日志：第 " + str(index + 1) + " 张显化：" + str(card.get("desc", ""))
	_focus_card(index)

func _play_card_reveal_effects(card_node: DaoCard, card: Dictionary) -> void:
	await get_tree().create_timer(0.32).timeout
	var quality := str(card.get("quality", ""))
	var card_type := str(card.get("type", ""))
	if quality == "道品":
		card_node.play_dao_reveal_effect()
		_flash_rainbow()
	if card_type == "灾厄":
		card_node.play_calamity_reveal_effect()
		_flash_edges()


func _flash_rainbow() -> void:
	if rainbow_flash == null:
		return
	var tween := create_tween()
	tween.tween_property(rainbow_flash, "color", Color(1.0, 0.82, 1.0, 0.3), 0.08)
	tween.tween_property(rainbow_flash, "color", Color(0.72, 0.88, 1.0, 0.22), 0.08)
	tween.tween_property(rainbow_flash, "color", Color(1.0, 1.0, 1.0, 0.0), 0.2)


func _flash_edges() -> void:
	var edge_rects: Array[ColorRect] = [edge_flash_top, edge_flash_bottom, edge_flash_left, edge_flash_right]
	for rect: ColorRect in edge_rects:
		if rect == null:
			continue
		var tween := create_tween()
		tween.tween_property(rect, "color", Color(0.752941, 0.25098, 0.25098, 0.34), 0.08)
		tween.tween_property(rect, "color", Color(0.752941, 0.25098, 0.25098, 0.0), 0.24)


func _clear_lottery_visuals() -> void:
	for child in lottery_container.get_children():
		child.queue_free()
	lottery_panels.clear()
	lottery_cards.clear()


func _visible_card_source_index() -> int:
	if lottery_cards.is_empty():
		return -1
	var card_node: DaoCard = lottery_cards[0]
	if card_node == null or not is_instance_valid(card_node):
		return -1
	return int(card_node.get_meta("source_index", -1))


func _find_lottery_display_index(results: Array) -> int:
	var preferred_index: int = GameManager.current_bargain_index
	if preferred_index < 0 or preferred_index >= results.size():
		preferred_index = GameManager.current_card_index
	if preferred_index >= 0 and preferred_index < results.size():
		return preferred_index

	for i in range(results.size()):
		var item: Variant = results[i]
		if item is Dictionary:
			var card: Dictionary = item as Dictionary
			if card.has("effect_type") and not bool(card.get("settled", false)):
				return i
	return 0 if not results.is_empty() else -1


func _render_single_lottery_card(source_index: int, card: Dictionary, show_face: bool, start_transparent: bool = false) -> void:
	_clear_lottery_visuals()
	if source_index < 0:
		return

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(232, 312)
	_apply_lottery_card_panel_style(panel, Color("#151527"))
	lottery_container.add_child(panel)
	lottery_panels.append(panel)

	var card_holder := CenterContainer.new()
	card_holder.custom_minimum_size = DaoCard.CARD_SIZE
	panel.add_child(card_holder)

	var card_node: DaoCard = CARD_SCENE.instantiate() as DaoCard
	card_holder.add_child(card_node)
	card_node.set_display_size(DaoCard.CARD_SIZE, 30)
	card_node.set_meta("source_index", source_index)
	card_node.set_meta("base_scale", Vector2.ONE)
	card_node.setup_card(card, show_face)
	if start_transparent:
		card_node.modulate.a = 0.0
	lottery_cards.append(card_node)


func _render_lottery(results: Array, force_hidden_cards: bool = false) -> void:
	for child in lottery_container.get_children():
		child.queue_free()
	lottery_panels.clear()
	lottery_cards.clear()

	if results.is_empty():
		return
	if _has_hidden_lottery_cards(results) and GameManager.current_state == GameManager.GameState.LOTTERY and not force_hidden_cards:
		return

	var display_index: int = _find_lottery_display_index(results)
	if display_index < 0 or display_index >= results.size():
		return
	var card: Dictionary = results[display_index] as Dictionary
	var show_face: bool = bool(card.get("revealed", false)) or card.has("effect_type")
	if force_hidden_cards and not cards_dealt:
		show_face = false
	_render_single_lottery_card(display_index, card, show_face, force_hidden_cards and not show_face)


func _on_lottery_card_revealed(index: int, card: Dictionary) -> void:
	if index < 0:
		return
	if lottery_cards.is_empty() and not GameManager.current_lottery_results.is_empty():
		_render_single_lottery_card(index, card, false)
		cards_dealt = true
		deal_animation_started = true
	elif _visible_card_source_index() != index:
		_render_single_lottery_card(index, card, false)
	if not cards_dealt or reveal_playback_active:
		pending_card_reveals.append({"index": index, "card": card})
		return
	_play_card_reveal(index, card)


func _on_bargain_ready(_index: int) -> void:
	_ensure_lottery_visuals_for_sync()
	_update_current_group()


func _update_current_group() -> void:
	var index := GameManager.current_bargain_index

	if index < 0 or index >= GameManager.current_lottery_results.size():
		label_round_info.text = "第 " + str(GameManager.round_number) + " 轮完成"
		label_current_ji_yuan.text = "当前机缘：本轮已结束"
		label_current_calamity.text = "当前灾厄：本轮已结束"
		_hide_auction_panel()
		_set_choice_enabled(false)
		label_waiting.visible = false
		return

	if GameManager.current_state != GameManager.GameState.BARGAIN:
		if GameManager.current_state != GameManager.GameState.AUCTION:
			_hide_auction_panel()
		_set_choice_enabled(false)
		return

	var card: Dictionary = GameManager.current_lottery_results[index]
	if _visible_card_source_index() != index:
		_render_single_lottery_card(index, card, true)
	if not lottery_panels.is_empty():
		_apply_lottery_card_panel_style(lottery_panels[0], Color("#3a3a6e"))
	_focus_card(index)
	label_round_info.text = "第 " + str(GameManager.round_number) + " 轮 · 第 " + str(index + 1) + " / 10 张"
	if str(card.get("type", "")) == "机缘":
		label_current_ji_yuan.text = "当前机缘：" + _format_ji_yuan(card)
		label_current_calamity.text = "当前灾厄：无"
		_set_bargain_button_mode(false)
	else:
		label_current_ji_yuan.text = "当前机缘：无"
		label_current_calamity.text = "当前灾厄：" + _format_calamity(card)
		_set_bargain_button_mode(true)
	local_choice_sent = false
	_hide_auction_panel()
	_hide_result_toast()
	_set_choice_enabled(true)
	label_waiting.visible = false


func _on_choice(choice: String) -> void:
	if local_choice_sent:
		return

	local_choice_sent = true
	_set_choice_enabled(false)
	label_waiting.visible = true
	var card: Dictionary = _current_visible_card()
	var choice_text: String = _choice_display(choice, card)
	label_waiting.text = "你已选择：「" + choice_text + "」  等待对手"
	var choice_color := Color("#c04040") if choice == "抢" else Color("#6080d0")
	if str(card.get("type", "")) == "灾厄":
		choice_color = Color("#6080d0") if choice == "抢" else Color("#c04040")
	label_waiting.add_theme_color_override("font_color", choice_color)
	label_log.text = "日志：你选择了「" + choice_text + "」，等待对手选择"
	_show_choice_pulse(choice)

	var data := {"index": GameManager.current_bargain_index, "choice": choice}
	if NetworkManager.is_host:
		GameManager.on_bargain_choice_received(1, data)
	else:
		NetworkManager.send_message("bargain_choice", data)


func _on_bargain_result(data: Dictionary) -> void:
	_update_player_info()
	_ensure_lottery_visuals_for_sync()
	var settled: Dictionary = data.get("settled", {}) as Dictionary
	var result_a: Dictionary = settled.get("player_a_result", {}) as Dictionary
	var result_b: Dictionary = settled.get("player_b_result", {}) as Dictionary
	var my_result: Dictionary = result_a if NetworkManager.is_host else result_b
	var enemy_result: Dictionary = result_b if NetworkManager.is_host else result_a
	var settled_index: int = int(data.get("index", 0))
	latest_settled_index = settled_index
	var group: Dictionary = GameManager.current_lottery_results[max(0, settled_index)]
	var my_choice: String = _choice_display(str(my_result.get("choice", "")), group)
	var enemy_choice: String = _choice_display(str(enemy_result.get("choice", "")), group)
	label_log.text = "日志：你「" + my_choice + "」，对方「" + enemy_choice + "」；" + str(my_result.get("special", "结算完成"))
	latest_result_round_finished = bool(data.get("round_finished", false))
	result_continue_sent = false
	_show_card_face(settled_index, group)
	_show_result_feedback(my_result, enemy_result, group)
	_spawn_result_float(settled_index, my_result, group)
	if str(group.get("effect_type", "")) == "enemy":
		label_log.text += "；遭遇敌人，战斗模块暂未开启，本次先跳过"

	label_current_ji_yuan.text = "本张已结算"
	label_current_calamity.text = "点击结果按钮继续"
	_set_choice_enabled(false)
	label_waiting.visible = false


func _ensure_lottery_visuals_for_sync() -> void:
	if GameManager.current_lottery_results.is_empty():
		return
	var target_index: int = GameManager.current_bargain_index
	if target_index < 0 or target_index >= GameManager.current_lottery_results.size():
		target_index = GameManager.current_card_index
	if target_index < 0 or target_index >= GameManager.current_lottery_results.size():
		target_index = 0
	if _visible_card_source_index() == target_index:
		return
	var card: Dictionary = GameManager.current_lottery_results[target_index] as Dictionary
	_render_single_lottery_card(target_index, card, card.has("effect_type"))
	cards_dealt = true
	deal_animation_started = true
	if btn_inject_shouyuan != null:
		btn_inject_shouyuan.visible = false
	if taiji_rect != null:
		taiji_rect.modulate.a = 0.0
	if taiji_animation != null:
		taiji_animation.stop()


func _set_choice_enabled(enabled: bool) -> void:
	if btn_qiang == null or btn_rang == null:
		return
	if not is_instance_valid(btn_qiang) or not is_instance_valid(btn_rang):
		return
	btn_qiang.visible = enabled
	btn_rang.visible = enabled
	btn_qiang.disabled = not enabled
	btn_rang.disabled = not enabled


func _set_bargain_button_mode(is_calamity: bool) -> void:
	if btn_qiang == null or btn_rang == null:
		return
	if is_calamity:
		btn_qiang.text = "躲避"
		btn_rang.text = "承担"
		_apply_button_color(btn_qiang, Color("#4040c0"))
		_apply_button_color(btn_rang, Color("#c04040"))
	else:
		btn_qiang.text = "抢"
		btn_rang.text = "让"
		_apply_button_color(btn_qiang, Color("#c04040"))
		_apply_button_color(btn_rang, Color("#4040c0"))


func _apply_button_color(button: Button, color: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	button.add_theme_stylebox_override("pressed", style)


func _update_player_info() -> void:
	var my_player := _get_my_player()
	var enemy_player := _get_enemy_player()
	if my_player == null or enemy_player == null:
		return

	label_enemy_name.text = enemy_player.player_name
	label_enemy_shouyuan.text = _format_int_value(enemy_player.shou_yuan)
	label_enemy_lingli.text = _format_int_value(enemy_player.ling_li)
	label_enemy_lingshi.text = _format_int_value(enemy_player.ling_shi)
	label_enemy_qixue.text = _format_int_value(enemy_player.qi_xue)
	label_enemy_realm.text = GameManager.get_cultivation_stage_name(enemy_player)
	label_enemy_tech_count.text = _format_int_value(enemy_player.techniques.size()) + "/3"
	label_enemy_comp_count.text = _format_int_value(enemy_player.companions.size())

	for stat in GameManager.BASE_STATS:
		if stat_chip_labels.has(stat):
			var value_label: Label = stat_chip_labels[stat] as Label
			value_label.text = _format_int_value(my_player.stats.get(stat, 0))
	label_my_stats.text = "我 · 寿 " + _format_int_value(my_player.shou_yuan) + "   灵 " + _format_int_value(my_player.ling_li) + "   石 " + _format_int_value(my_player.ling_shi) + "   血 " + _format_int_value(my_player.qi_xue) + "   " + GameManager.get_cultivation_stage_name(my_player)
	_update_cultivation_bars(my_player)
	_update_breakthrough_button(my_player)
	label_my_techniques.text = "功法(" + str(my_player.techniques.size()) + "/3) " + _format_short_named_list(my_player.techniques, "暂无", 3)
	label_my_companions.text = "伙伴(" + str(my_player.companions.size()) + ") " + _format_short_companion_list(my_player.companions, "暂无", 3)
	label_my_treasures.text = "法宝(" + str(my_player.treasures.size()) + "/1) " + _format_short_named_list(my_player.treasures, "暂无", 1)
	label_backpack.text = "背包：" + str(my_player.backpack.size()) + " / " + str(my_player.backpack_capacity) + "    灵石：" + _format_int_value(my_player.ling_shi)
	_update_backpack_block_label(my_player)
	_update_treasure_list(my_player)
	_update_backpack_list(my_player)
	_update_drag_inventory(my_player)


func _get_my_player() -> PlayerData:
	return GameManager.player_a if NetworkManager.is_host else GameManager.player_b


func _get_enemy_player() -> PlayerData:
	return GameManager.player_b if NetworkManager.is_host else GameManager.player_a


func _format_int_value(value: Variant) -> String:
	return str(int(round(float(value))))


func _current_visible_card() -> Dictionary:
	var index: int = GameManager.current_bargain_index
	if index < 0 or index >= GameManager.current_lottery_results.size():
		return {}
	return GameManager.current_lottery_results[index] as Dictionary


func _choice_display(choice: String, card: Dictionary) -> String:
	if str(card.get("type", "")) == "灾厄":
		if choice == "抢":
			return "躲避"
		if choice == "让":
			return "承担"
	return choice


func _update_cultivation_bars(player: PlayerData) -> void:
	if bar_my_lingli == null or bar_my_hp == null:
		return

	var current_req: int = GameManager.get_current_stage_floor_req(player)
	var next_req: int = GameManager.get_next_breakthrough_req(player)
	var target_name: String = GameManager.get_next_breakthrough_name(player)
	var status: Dictionary = GameManager.get_breakthrough_status(player)
	var span: int = maxi(1, next_req - current_req)
	var progress_value: int = clampi(player.ling_li - current_req, 0, span)
	bar_my_lingli.max_value = span
	bar_my_lingli.value = progress_value
	var chance_text: String = ""
	var breakthrough_type: String = str(status.get("type", ""))
	if breakthrough_type == "minor" or breakthrough_type == "major":
		chance_text = "   成功率 " + str(int(round(float(status.get("success_chance", 0.0)) * 100.0))) + "%"
	label_my_realm_progress.text = "境界：" + GameManager.get_cultivation_stage_name(player) + " → " + target_name + "   修为 " + str(player.ling_li) + " / " + str(next_req) + chance_text

	var max_hp: int = _estimate_player_max_hp(player)
	bar_my_hp.max_value = max_hp
	bar_my_hp.value = clampi(player.qi_xue, 0, max_hp)
	label_my_hp_progress.text = "气血：" + str(player.qi_xue) + " / " + str(max_hp)


func _update_breakthrough_button(player: PlayerData) -> void:
	if button_breakthrough == null or player == null:
		return

	var status: Dictionary = GameManager.get_breakthrough_status(player)
	var target_name: String = str(status.get("target_name", ""))
	var breakthrough_type: String = str(status.get("type", ""))
	var can_breakthrough: bool = bool(status.get("can", false))
	var blocked_state: bool = GameManager.current_state == GameManager.GameState.AUCTION or GameManager.current_state == GameManager.GameState.TRIBULATION or GameManager.current_state == GameManager.GameState.BATTLE or GameManager.current_state == GameManager.GameState.DUEL or GameManager.current_state == GameManager.GameState.ENDING
	if target_name == "":
		button_breakthrough.text = "圆满"
		button_breakthrough.disabled = true
		button_breakthrough.modulate = Color(0.55, 0.55, 0.55, 1.0)
		return

	if breakthrough_type == "minor":
		button_breakthrough.text = "升层！" if can_breakthrough else "升层"
	elif breakthrough_type == "duel":
		button_breakthrough.text = "争仙！" if can_breakthrough else "争仙"
	else:
		button_breakthrough.text = "突破！" if can_breakthrough else "突破"
	button_breakthrough.disabled = blocked_state
	button_breakthrough.modulate = Color("#f0c040") if can_breakthrough else Color(0.85, 0.85, 0.9, 1.0)


func _realm_ling_li_req(realm: String) -> int:
	return GameManager.get_realm_ling_li_req(realm)


func _estimate_player_max_hp(player: PlayerData) -> int:
	var hp_bonus: float = float(player.refined_bonuses.get("气血上限", 0.0))
	return maxi(1, int(round(100.0 * (1.0 + float(player.stats.get("体魄", 0)) * 0.04 + hp_bonus))))


func _update_backpack_block_label(player: PlayerData) -> void:
	if label_backpack_block == null:
		return

	var pending: Dictionary = GameManager.get_pending_backpack_item(player.peer_id)
	if pending.is_empty():
		label_backpack_block.text = ""
		label_backpack_block.visible = false
		return

	label_backpack_block.visible = true
	label_backpack_block.text = "背包已满，先清理：" + _format_backpack_entry(pending)


func _format_ji_yuan(data: Dictionary) -> String:
	if data.is_empty():
		return "-"
	return str(data.get("desc", str(data.get("quality", "")) + "·" + str(data.get("type", ""))))


func _format_calamity(data: Dictionary) -> String:
	if data.is_empty():
		return "-"
	return str(data.get("desc", str(data.get("quality", "")) + "·" + str(data.get("type", ""))))


func _show_card_face(index: int, card: Dictionary) -> void:
	if index < 0:
		return
	revealed_visual_indices[index] = true
	if _visible_card_source_index() != index:
		_render_single_lottery_card(index, card, true)
		return
	if lottery_cards.is_empty():
		return
	lottery_cards[0].setup_card(card, true)


func _quality_color(quality: String) -> Color:
	match quality:
		"凡品":
			return Color("#666666")
		"良品":
			return Color("#3a8f4a")
		"上品":
			return Color("#3a62b8")
		"极品":
			return Color("#9b45d9")
		"仙品":
			return Color("#d59a35")
		"道品":
			return Color("#f0d86a")
		_:
			return Color("#2a2a55")


func _mark_card_settled(index: int) -> void:
	if index < 0 or _visible_card_source_index() != index:
		return
	if lottery_cards.is_empty() or lottery_cards[0] == null or not is_instance_valid(lottery_cards[0]):
		return
	lottery_cards[0].mark_settled()
	if lottery_panels.is_empty():
		return
	if lottery_panels[0] == null or not is_instance_valid(lottery_panels[0]):
		return

	var panel: PanelContainer = lottery_panels[0]
	var card: DaoCard = lottery_cards[0]
	var base_scale: Vector2 = card.get_meta("base_scale", Vector2.ONE) as Vector2
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(card, "scale", base_scale * 0.2, 0.28)
	tween.tween_property(card, "modulate:a", 0.0, 0.22)
	tween.tween_property(panel, "scale", Vector2(0.2, 0.2), 0.32)
	tween.tween_property(panel, "modulate:a", 0.0, 0.26)
	tween.chain().tween_callback(func() -> void:
		if panel != null and is_instance_valid(panel):
			panel.queue_free()
		lottery_panels.clear()
		lottery_cards.clear()
	)


func _focus_card(index: int) -> void:
	if lottery_scroll == null:
		return
	if index < 0 or _visible_card_source_index() != index or lottery_panels.is_empty():
		return

	var panel_node: Variant = lottery_panels[0]
	if panel_node == null or not is_instance_valid(panel_node):
		return
	var panel: PanelContainer = panel_node as PanelContainer
	if panel == null or not panel.visible:
		return
	await get_tree().process_frame
	var target_scroll: int = int(maxf(0.0, panel.position.x + panel.size.x * 0.5 - lottery_scroll.size.x * 0.5))
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(lottery_scroll, "scroll_horizontal", target_scroll, 0.25)


func _hide_result_toast() -> void:
	if result_toast != null:
		result_toast.visible = false
	if btn_continue_result != null:
		btn_continue_result.disabled = false
	result_continue_sent = false
	latest_result_round_finished = false
	latest_settled_index = -1


func _show_choice_pulse(choice: String) -> void:
	var target_button: Button = btn_qiang if choice == "抢" else btn_rang
	target_button.visible = true
	target_button.disabled = true
	target_button.modulate = Color.WHITE
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(target_button, "scale", Vector2(1.12, 1.12), 0.12)
	tween.tween_property(target_button, "scale", Vector2.ONE, 0.14)


func _show_result_feedback(my_result: Dictionary, enemy_result: Dictionary, card: Dictionary) -> void:
	if result_toast == null:
		return

	var title: String = _build_result_title(my_result, card)
	var my_choice: String = _choice_display(str(my_result.get("choice", "")), card)
	var enemy_choice: String = _choice_display(str(enemy_result.get("choice", "")), card)
	var special: String = str(my_result.get("special", ""))
	var result_color: Color = _result_color(my_result, card)
	var panel_color: Color = Color(0.08, 0.08, 0.16, 0.96)
	if float(my_result.get("gain", 0.0)) > 0.0:
		panel_color = Color(0.18, 0.13, 0.03, 0.96)
	elif float(my_result.get("lose", 0.0)) > 0.0:
		panel_color = Color(0.18, 0.04, 0.05, 0.96)
	_apply_panel_style(result_toast, panel_color)
	label_result_title.text = title
	label_result_title.add_theme_color_override("font_color", result_color)
	label_result_detail.text = "你：" + my_choice + "    对方：" + enemy_choice + "\n" + special
	btn_continue_result.text = "看完了，结束本轮" if latest_result_round_finished else "看完了，翻下一张"
	btn_continue_result.visible = true
	btn_continue_result.disabled = false
	btn_continue_result.mouse_filter = Control.MOUSE_FILTER_STOP
	result_toast.visible = true
	result_toast.z_index = 240
	result_toast.mouse_filter = Control.MOUSE_FILTER_STOP
	result_toast.move_to_front()
	result_toast.modulate.a = 0.0
	result_toast.scale = Vector2(0.94, 0.94)

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(result_toast, "modulate:a", 1.0, 0.16)
	tween.tween_property(result_toast, "scale", Vector2.ONE, 0.2)
	_pulse_player_summary(result_color)


func _on_continue_result_pressed() -> void:
	if result_continue_sent:
		return

	var my_player: PlayerData = _get_my_player()
	if my_player != null and GameManager.has_pending_backpack_item(my_player.peer_id):
		label_log.text = "日志：背包已满，先丢弃背包物品或放弃新物品"
		_update_backpack_block_label(my_player)
		if btn_continue_result != null:
			btn_continue_result.text = "先清理背包"
		return

	result_continue_sent = true
	if latest_settled_index >= 0:
		_mark_card_settled(latest_settled_index)
		latest_settled_index = -1
	if btn_continue_result != null:
		btn_continue_result.disabled = true
		btn_continue_result.text = "等待对方确认..."
	label_waiting.visible = true
	label_waiting.text = "等待对方看完结果"
	label_waiting.add_theme_color_override("font_color", Color("#f0c040"))
	label_log.text = "日志：你已确认结果，等待对方"

	var data: Dictionary = {"index": GameManager.current_bargain_index}
	if NetworkManager.is_host:
		GameManager.on_bargain_continue_received(1, data)
	else:
		NetworkManager.send_message("bargain_continue", data)


func _build_result_title(result: Dictionary, card: Dictionary) -> String:
	var gain: float = float(result.get("gain", 0.0))
	var lose: float = float(result.get("lose", 0.0))
	if gain > 0.0:
		var gain_message: String = str(result.get("gain_message", ""))
		return "到手！" + (gain_message if gain_message != "" else _effect_text(card, gain, true))
	if lose > 0.0:
		var lose_message: String = str(result.get("lose_message", ""))
		return "遭灾！" + (lose_message if lose_message != "" else _effect_text(card, lose, false))
	if str(card.get("type", "")) == "机缘":
		return "机缘消散"
	return "无事发生"


func _effect_text(card: Dictionary, value: float, is_gain: bool) -> String:
	var effect_type: String = str(card.get("effect_type", ""))
	var amount: int = int(round(value))
	match effect_type:
		"ling_li":
			return "灵力 +" + str(amount)
		"heal_percent":
			return "气血回复 " + str(amount) + "%"
		"ling_shi":
			return "灵石 +" + str(amount)
		"stat_up":
			return str(card.get("stat", "属性")) + " +1"
		"shou_yuan":
			return "寿元 +" + str(amount)
		"technique":
			return "功法入手"
		"treasure":
			return "法宝入手"
		"dan":
			return "丹药入手"
		"companion":
			return "伙伴同行"
		"auction":
			return "进入拍卖会"
		"ling_li_loss":
			return "灵力 -" + str(amount)
		"hp_percent_loss":
			return "气血 -" + str(amount) + "%"
		"shou_yuan_loss":
			return "寿元 -" + str(amount)
		"enemy":
			return "遭遇敌人"
		"tribulation":
			return "天劫征兆"
		_:
			if is_gain:
				return str(card.get("desc", "机缘")) + " +" + str(amount)
			return str(card.get("desc", "灾厄")) + " -" + str(amount)


func _result_color(result: Dictionary, card: Dictionary) -> Color:
	if float(result.get("gain", 0.0)) > 0.0:
		return Color("#f0c040")
	if float(result.get("lose", 0.0)) > 0.0:
		return Color("#c04040")
	if str(card.get("type", "")) == "机缘":
		return Color("#8a8070")
	return Color("#e0d5b7")


func _pulse_player_summary(color: Color) -> void:
	if label_my_stats == null:
		return

	var original_color: Color = Color.WHITE
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label_my_stats, "scale", Vector2(1.06, 1.06), 0.12)
	tween.tween_property(label_my_stats, "modulate", color, 0.12)
	tween.chain().tween_property(label_my_stats, "scale", Vector2.ONE, 0.16)
	tween.parallel().tween_property(label_my_stats, "modulate", original_color, 0.16)


func _spawn_result_float(index: int, result: Dictionary, card: Dictionary) -> void:
	if floating_layer == null:
		return
	if index < 0 or _visible_card_source_index() != index or lottery_cards.is_empty():
		return

	var gain: float = float(result.get("gain", 0.0))
	var lose: float = float(result.get("lose", 0.0))
	var text: String = ""
	var color: Color = Color("#f0c040")
	if gain > 0.0:
		text = "+" + _effect_text(card, gain, true)
		color = Color("#f0c040")
	elif lose > 0.0:
		text = "-" + _effect_text(card, lose, false).replace("-", "")
		color = Color("#c04040")
	else:
		text = "无收益"
		color = Color("#8a8070")

	var label := Label.new()
	label.text = text
	label.z_index = 350
	label.add_theme_font_size_override("font_size", 30)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(360.0, 48.0)
	floating_layer.add_child(label)

	var visible_card: DaoCard = lottery_cards[0]
	var card_center: Vector2 = visible_card.global_position + visible_card.size * visible_card.scale * 0.5
	label.global_position = card_center - Vector2(180.0, 48.0)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "global_position", label.global_position + Vector2(0.0, -72.0), 0.75)
	tween.tween_property(label, "modulate:a", 0.0, 0.75)
	tween.chain().tween_callback(label.queue_free)


func _format_named_list(items: Array, empty_text: String) -> String:
	if items.is_empty():
		return empty_text
	var names: Array[String] = []
	for item in items:
		if item is Dictionary:
			if item.has("amount"):
				names.append(str(item.get("name", "未知")) + " x" + str(item.get("amount", 0)))
			else:
				names.append(str(item.get("name", "未知")))
		else:
			names.append(str(item))
	return "，".join(names)


func _format_short_named_list(items: Array, empty_text: String, limit: int) -> String:
	if items.is_empty():
		return empty_text
	var names: Array[String] = []
	for item in items.slice(0, mini(items.size(), limit)):
		if item is Dictionary:
			names.append(str(item.get("name", "未知")))
		else:
			names.append(str(item))
	if items.size() > limit:
		names.append("+" + str(items.size() - limit))
	return "、".join(names)


func _format_short_companion_list(items: Array, empty_text: String, limit: int) -> String:
	if items.is_empty():
		return empty_text
	var names: Array[String] = []
	for item in items.slice(0, mini(items.size(), limit)):
		if item is Dictionary:
			var companion: Dictionary = item
			names.append(str(companion.get("name", "未知")) + "·" + str(companion.get("title", "")))
		else:
			names.append(str(item))
	if items.size() > limit:
		names.append("+" + str(items.size() - limit))
	return "、".join(names)


func _format_companion_list(items: Array, empty_text: String) -> String:
	if items.is_empty():
		return empty_text
	var names: Array[String] = []
	for item in items:
		if item is Dictionary:
			var companion: Dictionary = item
			var status := "在队" if bool(companion.get("alive", true)) else "离队"
			names.append(str(companion.get("name", "未知伙伴")) + "·" + str(companion.get("title", "无名")) + "：" + str(companion.get("effect_desc", "无加成")) + "（" + status + "）")
		else:
			names.append(str(item))
	return "，".join(names)


func _update_treasure_list(player: PlayerData) -> void:
	treasure_list.clear()
	for treasure in player.treasures:
		if not treasure is Dictionary:
			continue
		var treasure_data: Dictionary = treasure
		var status := "可使用"
		if bool(treasure_data.get("refined", false)):
			status = "已炼化"
		elif bool(treasure_data.get("used", false)):
			status = "已使用"
		var text := str(treasure_data.get("name", "未知法宝")) + "（" + status + "）"
		var index := treasure_list.add_item(text)
		treasure_list.set_item_metadata(index, treasure_data)


func _update_backpack_list(player: PlayerData) -> void:
	if backpack_list == null:
		return

	backpack_list.clear()
	for i in range(player.backpack.size()):
		var entry: Dictionary = player.backpack[i] as Dictionary
		var text: String = _format_backpack_entry(entry)
		var index: int = backpack_list.add_item(text)
		backpack_list.set_item_metadata(index, {"index": i, "entry": entry})

	var pending: Dictionary = GameManager.get_pending_backpack_item(player.peer_id)
	if not pending.is_empty():
		var pending_index: int = backpack_list.add_item("待处理 · " + _format_backpack_entry(pending))
		backpack_list.set_item_custom_fg_color(pending_index, Color("#c04040"))
		backpack_list.set_item_metadata(pending_index, {"index": -1, "entry": pending, "pending": true})


func _update_drag_inventory(player: PlayerData) -> void:
	for i in range(technique_slot_nodes.size()):
		var slot: InventoryDropSlot = technique_slot_nodes[i]
		if i < player.techniques.size():
			var technique: Dictionary = player.techniques[i] as Dictionary
			slot.set_card(_make_inventory_card("功法\n" + str(technique.get("name", "未知")), "equipped", i, "technique", {"kind": "technique", "data": technique}, Color("#6080d0")))
		else:
			slot.set_card(null)

	if treasure_slot_node != null:
		if player.treasures.size() > 0:
			var treasure: Dictionary = player.treasures[0] as Dictionary
			treasure_slot_node.set_card(_make_inventory_card("法宝\n" + str(treasure.get("name", "未知")), "equipped", 0, "treasure", {"kind": "treasure", "data": treasure}, Color("#f0c040")))
		else:
			treasure_slot_node.set_card(null)

	for i in range(companion_slot_nodes.size()):
		var companion_slot: InventoryDropSlot = companion_slot_nodes[i]
		if i < player.companions.size():
			var companion: Dictionary = player.companions[i] as Dictionary
			companion_slot.set_card(_make_inventory_card("同伴\n" + str(companion.get("name", "未知")), "equipped", i, "companion", {"kind": "companion", "data": companion}, Color("#c080e0")))
		else:
			companion_slot.set_card(null)

	if backpack_slots_container == null:
		return
	for child in backpack_slots_container.get_children():
		child.queue_free()

	for i in range(player.backpack_capacity):
		var slot := InventoryDropSlot.new()
		slot.setup(self, "backpack", i, "背包" + str(i + 1), Color("#3a3a6e"))
		backpack_slots_container.add_child(slot)
		if i < player.backpack.size():
			var entry: Dictionary = player.backpack[i] as Dictionary
			slot.set_card(_make_inventory_card(_format_backpack_entry_short(entry), "backpack", i, str(entry.get("kind", "")), entry, Color("#80c080")))

	var pending: Dictionary = GameManager.get_pending_backpack_item(player.peer_id)
	if not pending.is_empty():
		pending_item_slot = InventoryDropSlot.new()
		pending_item_slot.setup(self, "pending", -1, "待处理", Color("#c04040"))
		backpack_slots_container.add_child(pending_item_slot)
		pending_item_slot.set_card(_make_inventory_card("待处理\n" + _format_backpack_entry_short(pending), "pending", -1, str(pending.get("kind", "")), pending, Color("#c04040")))
	else:
		pending_item_slot = null


func _make_inventory_card(text: String, source: String, index: int, kind: String, entry: Dictionary, border_color: Color) -> InventoryDragCard:
	var card := InventoryDragCard.new()
	card.setup(text, source, index, kind, entry, border_color)
	return card


func _format_backpack_entry_short(entry: Dictionary) -> String:
	var kind: String = str(entry.get("kind", ""))
	var data: Dictionary = entry.get("data", {}) as Dictionary
	var kind_name: String = _item_kind_name(kind)
	return kind_name + "\n" + str(data.get("name", "未知"))


func _format_backpack_entry(entry: Dictionary) -> String:
	var kind: String = str(entry.get("kind", ""))
	var data: Dictionary = entry.get("data", {}) as Dictionary
	var kind_name: String = _item_kind_name(kind)
	return kind_name + " · " + str(data.get("name", "未知"))


func _item_kind_name(kind: String) -> String:
	match kind:
		"technique":
			return "功法"
		"treasure":
			return "法宝"
		"companion":
			return "同伴"
		_:
			return "物品"


func _on_treasure_selected(index: int) -> void:
	var treasure: Dictionary = treasure_list.get_item_metadata(index) as Dictionary
	if treasure.is_empty() or not treasure.has("use_effect"):
		return
	treasure_menu.set_meta("treasure_name", str(treasure.get("name", "")))
	treasure_menu.position = get_viewport().get_mouse_position()
	treasure_menu.popup()


func _on_treasure_menu_pressed(id: int) -> void:
	var player := _get_my_player()
	var treasure_name := str(treasure_menu.get_meta("treasure_name", ""))
	if player == null or treasure_name == "":
		return

	var message := ""
	if id == 0:
		message = GameManager.use_treasure(player, treasure_name)
	else:
		message = GameManager.refine_treasure(player, treasure_name)

	label_log.text = "日志：" + message
	_update_player_info()


func _on_backpack_selected(index: int) -> void:
	var metadata: Dictionary = backpack_list.get_item_metadata(index) as Dictionary
	if metadata.is_empty():
		return
	var my_player: PlayerData = _get_my_player()
	if my_player == null:
		return

	backpack_menu.clear()
	backpack_menu.set_meta("backpack_index", int(metadata.get("index", -1)))
	if bool(metadata.get("pending", false)):
		backpack_menu.add_item("放弃新物品", 2)
	else:
		backpack_menu.add_item("装备", 0)
		backpack_menu.add_item("丢弃", 1)
	if not bool(metadata.get("pending", false)) and GameManager.has_pending_backpack_item(my_player.peer_id):
		backpack_menu.add_item("放弃待处理新物品", 2)
	backpack_menu.position = get_viewport().get_mouse_position()
	backpack_menu.popup()


func _on_backpack_menu_pressed(id: int) -> void:
	var action: String = ""
	match id:
		0:
			action = "equip"
		1:
			action = "discard"
		2:
			action = "discard_pending"
		_:
			return

	_send_backpack_action(action, int(backpack_menu.get_meta("backpack_index", -1)))


func _on_breakthrough_pressed() -> void:
	var player: PlayerData = _get_my_player()
	if player == null:
		return

	var status: Dictionary = GameManager.get_breakthrough_status(player)
	label_log.text = "日志：正在尝试突破至" + str(status.get("target_name", "下一境界"))
	if button_breakthrough != null:
		button_breakthrough.disabled = true
	if NetworkManager.is_host:
		GameManager.request_breakthrough(1)
	else:
		NetworkManager.send_message("breakthrough_request", {})


func _on_breakthrough_feedback(data: Dictionary) -> void:
	_update_player_info()
	var peer_id: int = int(data.get("peer_id", 0))
	var my_player: PlayerData = _get_my_player()
	if my_player != null and peer_id == my_player.peer_id:
		label_log.text = "日志：" + str(data.get("message", "暂时无法突破"))


func _on_auction_started(data: Dictionary) -> void:
	_update_player_info()
	_hide_result_toast()
	_set_choice_enabled(false)
	label_waiting.visible = false
	auction_panel.visible = true
	_set_auction_buttons_enabled(true)

	var lots: Array = data.get("lots", []) as Array
	for i in range(auction_lot_labels.size()):
		var lot_label: Label = auction_lot_labels[i] as Label
		if i < lots.size():
			var lot: Dictionary = lots[i] as Dictionary
			lot_label.text = _auction_lot_text(lot)
		else:
			lot_label.text = "暂无拍品"
			auction_bid_buttons[i].disabled = true
			auction_haggle_buttons[i].disabled = true

	label_round_info.text = "第 " + str(GameManager.round_number) + " 轮 · 拍卖会"
	label_current_ji_yuan.text = "当前机缘：拍卖会开张"
	label_current_calamity.text = "当前灾厄：无"
	label_auction_status.text = "选择一件拍品：经商降低花费，讲价更便宜，出价竞拍优先。"
	label_log.text = "日志：拍卖会开张，灵石终于有地方花了"


func _auction_lot_text(lot: Dictionary) -> String:
	return str(lot.get("name", "拍品")) + "｜" + str(lot.get("desc", "")) + "｜起价 " + str(int(lot.get("price", 0))) + " 灵石"


func _on_auction_action_pressed(lot_index: int, mode: String) -> void:
	_set_auction_buttons_enabled(false)
	if mode == "pass":
		label_auction_status.text = "你选择观望，等待对方..."
	else:
		var mode_text: String = "讲价" if mode == "haggle" else "出价竞拍"
		label_auction_status.text = "已选择" + mode_text + "，等待对方..."
	_send_auction_action({"lot_index": lot_index, "mode": mode})


func _send_auction_action(data: Dictionary) -> void:
	if NetworkManager.is_host:
		GameManager.on_auction_action_received(1, data)
	else:
		NetworkManager.send_message("auction_action", data)


func _on_auction_ended(data: Dictionary) -> void:
	_update_player_info()
	_hide_auction_panel()
	var my_player: PlayerData = _get_my_player()
	var messages: Dictionary = data.get("messages", {}) as Dictionary
	var message: String = "拍卖会散场"
	if my_player != null:
		message = str(messages.get(str(my_player.peer_id), message))
	label_result_title.text = "拍卖会散场"
	label_result_detail.text = message
	result_toast.visible = true
	latest_settled_index = int(data.get("index", -1))
	latest_result_round_finished = bool(data.get("round_finished", false))
	result_continue_sent = false
	btn_continue_result.disabled = false
	btn_continue_result.text = "看完了，结束本轮" if latest_result_round_finished else "看完了，翻下一张"
	label_log.text = "日志：" + message


func _hide_auction_panel() -> void:
	if auction_panel == null:
		return
	auction_panel.visible = false
	_set_auction_buttons_enabled(false)


func _set_auction_buttons_enabled(enabled: bool) -> void:
	for button in auction_bid_buttons:
		var bid_button: Button = button as Button
		bid_button.disabled = not enabled
	for button in auction_haggle_buttons:
		var haggle_button: Button = button as Button
		haggle_button.disabled = not enabled
	if button_auction_pass != null:
		button_auction_pass.disabled = not enabled


func _on_market_pressed() -> void:
	var player: PlayerData = _get_my_player()
	if player == null or market_menu == null:
		return

	market_menu.clear()
	_add_market_item("吐纳丹：修为 +" + str(GameManager.MARKET_CULTIVATION_GAIN) + " / " + str(GameManager.MARKET_CULTIVATION_COST) + "灵石", 0, player.ling_shi < GameManager.MARKET_CULTIVATION_COST)
	_add_market_item("疗伤：回复30%气血 / " + str(GameManager.MARKET_HEAL_COST) + "灵石", 1, player.ling_shi < GameManager.MARKET_HEAL_COST)

	var dan_name: String = _next_market_dan_name(player)
	var dan_cost: int = int(GameManager.MARKET_DAN_COSTS.get(dan_name, 0))
	var dan_text: String = "突破丹：暂无需求"
	var dan_disabled: bool = true
	if dan_name != "":
		dan_text = dan_name + " / " + str(dan_cost) + "灵石"
		dan_disabled = GameManager.has_dan(player, dan_name) or player.ling_shi < dan_cost
		if GameManager.has_dan(player, dan_name):
			dan_text += "（已有）"
	_add_market_item(dan_text, 2, dan_disabled)

	_add_market_item("扩充背包：容量 +1 / " + str(GameManager.MARKET_BACKPACK_COST) + "灵石", 3, player.ling_shi < GameManager.MARKET_BACKPACK_COST)
	market_menu.position = get_viewport().get_mouse_position()
	market_menu.popup()


func _add_market_item(text: String, id: int, disabled: bool) -> void:
	market_menu.add_item(text, id)
	var index: int = market_menu.item_count - 1
	market_menu.set_item_disabled(index, disabled)


func _on_market_menu_pressed(id: int) -> void:
	var action: String = ""
	match id:
		0:
			action = "cultivation"
		1:
			action = "heal"
		2:
			action = "dan"
		3:
			action = "backpack"
		_:
			return
	_send_market_action(action)


func _send_market_action(action: String) -> void:
	var data: Dictionary = {"action": action}
	if NetworkManager.is_host:
		GameManager.on_market_action_received(1, data)
	else:
		NetworkManager.send_message("market_action", data)


func _on_market_changed(data: Dictionary) -> void:
	_update_player_info()
	var peer_id: int = int(data.get("peer_id", 0))
	var my_player: PlayerData = _get_my_player()
	if my_player != null and peer_id == my_player.peer_id:
		label_log.text = "日志：" + str(data.get("message", "坊市交易完成"))
	if btn_continue_result != null and result_toast != null and result_toast.visible:
		if my_player != null and GameManager.has_pending_backpack_item(my_player.peer_id):
			btn_continue_result.text = "先清理背包"
		elif result_continue_sent:
			btn_continue_result.text = "等待对方确认..."
		else:
			btn_continue_result.text = "看完了，结束本轮" if latest_result_round_finished else "看完了，翻下一张"


func _next_market_dan_name(player: PlayerData) -> String:
	var next_realm: String = str(GameManager.NEXT_REALM_MAP.get(player.realm, ""))
	if next_realm == "":
		return ""
	var realm_data: Dictionary = GameManager.REALMS.get(next_realm, {}) as Dictionary
	return str(realm_data.get("dan", ""))


func _on_backpack_changed(data: Dictionary) -> void:
	_update_player_info()
	var peer_id: int = int(data.get("peer_id", 0))
	var my_player: PlayerData = _get_my_player()
	if my_player != null and peer_id == my_player.peer_id:
		label_log.text = "日志：" + str(data.get("message", "背包已更新"))
	if btn_continue_result != null and result_toast != null and result_toast.visible:
		if my_player != null and GameManager.has_pending_backpack_item(my_player.peer_id):
			btn_continue_result.text = "先清理背包"
			btn_continue_result.disabled = false
		elif result_continue_sent:
			btn_continue_result.text = "等待对方确认..."
		else:
			btn_continue_result.text = "看完了，结束本轮" if latest_result_round_finished else "看完了，翻下一张"


func can_drop_inventory_data(data: Dictionary, target_type: String, target_index: int) -> bool:
	var source: String = str(data.get("source", ""))
	var kind: String = str(data.get("kind", ""))
	var player: PlayerData = _get_my_player()
	if player == null:
		return false

	match target_type:
		"technique":
			return kind == "technique" and (source == "backpack" or source == "pending") and target_index >= 0 and target_index < 3
		"treasure":
			return kind == "treasure" and (source == "backpack" or source == "pending")
		"companion":
			return kind == "companion" and (source == "backpack" or source == "pending") and target_index >= 0 and target_index < 3
		"discard":
			return source == "backpack" or source == "pending" or source == "equipped"
		_:
			return false


func handle_inventory_drop(data: Dictionary, target_type: String, target_index: int) -> void:
	var source: String = str(data.get("source", ""))
	var source_index: int = int(data.get("index", -1))
	var kind: String = str(data.get("kind", ""))
	var action: String = ""

	match target_type:
		"technique", "treasure", "companion":
			action = "equip_pending" if source == "pending" else "equip"
		"discard":
			if source == "pending":
				action = "discard_pending"
			elif source == "equipped":
				action = "discard_equipped"
			else:
				action = "discard"
		_:
			return

	_send_backpack_action(action, source_index, source, kind, target_type, target_index)


func _send_backpack_action(action: String, index: int, source: String = "", kind: String = "", target_type: String = "", target_index: int = -1) -> void:
	var data: Dictionary = {
		"action": action,
		"index": index,
		"source": source,
		"kind": kind,
		"target_type": target_type,
		"target_index": target_index,
	}
	if NetworkManager.is_host:
		GameManager.on_backpack_action_received(1, data)
	else:
		NetworkManager.send_message("backpack_action", data)


func show_inventory_item_details(entry: Dictionary, source: String = "", index: int = -1) -> void:
	var dialog := AcceptDialog.new()
	dialog.title = _format_backpack_entry(entry)
	dialog.dialog_text = _describe_inventory_entry(entry, source, index)
	dialog.min_size = Vector2i(560, 420)
	add_child(dialog)
	dialog.confirmed.connect(func() -> void:
		dialog.queue_free()
	)
	dialog.close_requested.connect(func() -> void:
		dialog.queue_free()
	)
	dialog.popup_centered(Vector2i(560, 420))


func _describe_inventory_entry(entry: Dictionary, source: String, index: int) -> String:
	var kind: String = str(entry.get("kind", ""))
	var data: Dictionary = entry.get("data", {}) as Dictionary
	var lines: Array[String] = []
	lines.append(_item_kind_name(kind) + "：" + str(data.get("name", "未知")))
	if data.has("quality"):
		lines.append("品质：" + str(data.get("quality", "")))
	if data.has("title"):
		lines.append("身份：" + str(data.get("title", "")))

	match kind:
		"technique":
			var bonuses: Dictionary = data.get("bonuses", {}) as Dictionary
			lines.append("效果：" + _format_bonus_dict(bonuses))
			var resonances: Array = data.get("resonances", []) as Array
			lines.append("真意：" + _format_resonance_list(resonances))
			lines.append("操作：拖到功法槽装备；拖到已有功法上可替换；拖到弃置可丢弃。")
		"treasure":
			lines.append("使用：" + str(data.get("use_effect", "无")))
			lines.append("炼化：" + _format_bonus_dict(data.get("refine_bonus", {}) as Dictionary))
			lines.append("状态：" + ("已使用" if bool(data.get("used", false)) else "可使用"))
			lines.append("操作：拖到法宝槽装备或替换；拖到弃置可丢弃。")
		"companion":
			lines.append("加成：" + str(data.get("effect_desc", str(data.get("bonus_type", "")) + " " + str(data.get("bonus_value", "")))))
			lines.append("状态：" + ("同行中" if bool(data.get("alive", true)) else "离队"))
			lines.append("操作：拖到同伴槽入队或替换；拖到弃置可请离。")
		_:
			lines.append("暂未记录详细效果。")

	if source != "":
		lines.append("")
		lines.append("位置：" + _inventory_source_name(source, index))
	return "\n".join(lines)


func _format_bonus_dict(bonuses: Dictionary) -> String:
	if bonuses.is_empty():
		return "无"
	var parts: Array[String] = []
	for bonus_name in bonuses:
		var value: float = float(bonuses[bonus_name])
		var suffix: String = "%" if absf(value) < 2.0 else ""
		var shown: String = str(int(round(value * 100.0))) if suffix == "%" else str(int(round(value)))
		parts.append(str(bonus_name) + ("+" if value >= 0.0 else "") + shown + suffix)
	return "，".join(parts)


func _format_resonance_list(resonances: Array) -> String:
	if resonances.is_empty():
		return "无"
	var names: Array[String] = []
	for resonance in resonances:
		if resonance is Dictionary:
			names.append(str(resonance.get("name", "未知")))
		else:
			names.append(str(resonance))
	return "，".join(names)


func _inventory_source_name(source: String, index: int) -> String:
	match source:
		"equipped":
			return "已装备第 " + str(index + 1) + " 格"
		"backpack":
			return "背包第 " + str(index + 1) + " 格"
		"pending":
			return "待处理新物品"
		_:
			return "未知位置"
