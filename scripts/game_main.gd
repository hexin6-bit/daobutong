extends Control

const CARD_SCENE: PackedScene = preload("res://scenes/Card.tscn")

var label_round_info: Label
var label_enemy_name: Label
var label_enemy_shouyuan: Label
var label_enemy_lingli: Label
var label_enemy_lingshi: Label
var label_enemy_qixue: Label
var label_enemy_realm: Label
var label_enemy_power: Label
var label_enemy_tech_count: Label
var label_enemy_comp_count: Label
var label_enemy_sect_badge: Label
var label_enemy_resonance_badge: Label
var label_npc_dialogue: Label
var lottery_card_area: Control
var lottery_container: Control
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
var contest_button_row: HBoxContainer
var btn_contest_yield: Button
var btn_contest_fight: Button
var btn_qiang: Button
var btn_rang: Button
var label_waiting: Label
var scroll_my_info: ScrollContainer
var label_my_name: Label
var label_my_sect_badge: Label
var label_my_resonance_badge: Label
var build_route_grid: GridContainer
var build_route_buttons: Dictionary = {}
var build_info_dialog: AcceptDialog
var label_my_stats: Label
var label_my_power: Label
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
var button_backpack: Button
var button_alchemy: Button
var button_refining: Button
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
var alchemy_menu: PopupMenu
var treasure_list: ItemList
var treasure_menu: PopupMenu
var backpack_overlay_layer: Control
var backpack_overlay_list: ItemList
var label_backpack_overlay_title: Label
var label_backpack_overlay_detail: Label
var backpack_action_grid: GridContainer
var button_backpack_overlay_sell: Button
var button_backpack_overlay_discard: Button
var backpack_overlay_selected_metadata: Dictionary = {}
var label_log: Label
var button_log_open: Button
var log_overlay_layer: Control
var label_log_overlay_body: RichTextLabel
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
var badge_effect_tweens: Dictionary = {}
var log_history: Array[String] = []
var last_log_text: String = ""
var treasure_growth_cache: Dictionary = {}
var last_my_power: int = -1
var last_enemy_power: int = -1
var crafting_layer: Control
var crafting_panel: PanelContainer
var crafting_title_label: Label
var crafting_status_label: Label
var crafting_art_panel: PanelContainer
var crafting_art_label: Label
var crafting_feedback_panel: PanelContainer
var crafting_feedback_label: Label
var crafting_feedback_detail_label: Label
var crafting_bar: Control
var crafting_good_zone: ColorRect
var crafting_perfect_zone: ColorRect
var crafting_pointer: ColorRect
var crafting_action_button: Button
var crafting_mode: String = ""
var crafting_recipe: String = "auto"
var crafting_pointer_value: float = 0.0
var crafting_pointer_dir: float = 1.0
var crafting_speed: float = 0.82
var crafting_running: bool = false
var crafting_good_left: float = 0.34
var crafting_good_right: float = 0.66
var crafting_perfect_left: float = 0.46
var crafting_perfect_right: float = 0.54
var sect_event_layer: Control
var sect_event_title_label: Label
var sect_event_desc_label: Label
var sect_event_countdown_label: Label
var sect_event_body_label: RichTextLabel
var sect_event_join_button: Button
var sect_event_skip_button: Button
var sect_event_continue_button: Button
var sect_event_choice_sent: bool = false
var sect_event_continue_sent: bool = false
var sect_event_countdown_remaining: float = 0.0
var sect_event_countdown_active: bool = false
var sect_event_current_id: int = -1


func _ready() -> void:
	UIEffects.add_background(self)
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_reset_fullscreen_layout()
	_build_ui()
	UIEffects.apply_button_press_tween(self)
	GameManager.lottery_generated.connect(_on_lottery_generated)
	GameManager.lottery_energy_updated.connect(_on_lottery_energy_updated)
	GameManager.lottery_energy_ready.connect(_on_lottery_energy_ready)
	GameManager.lottery_card_revealed.connect(_on_lottery_card_revealed)
	GameManager.bargain_ready.connect(_on_bargain_ready)
	GameManager.bargain_result.connect(_on_bargain_result)
	GameManager.contest_started.connect(_on_contest_started)
	GameManager.backpack_changed.connect(_on_backpack_changed)
	GameManager.market_changed.connect(_on_market_changed)
	GameManager.auction_started.connect(_on_auction_started)
	GameManager.auction_ended.connect(_on_auction_ended)
	GameManager.rest_started.connect(_on_rest_started)
	GameManager.rest_updated.connect(_on_rest_updated)
	GameManager.breakthrough_feedback.connect(_on_breakthrough_feedback)
	GameManager.npc_dialogue_changed.connect(_on_npc_dialogue_changed)
	GameManager.set_bonus_triggered.connect(_on_set_bonus_triggered)
	GameManager.sect_event_started.connect(_on_sect_event_started)
	GameManager.sect_event_updated.connect(_on_sect_event_updated)
	GameManager.sect_event_finished.connect(_on_sect_event_finished)
	btn_qiang.pressed.connect(_on_choice.bind("抢"))
	btn_rang.pressed.connect(_on_choice.bind("让"))

	_update_player_info()
	if not GameManager.current_lottery_results.is_empty():
		_on_lottery_generated(GameManager.current_lottery_results)
	_show_pending_battle_reward_feedback()
	GameManager.ensure_round_started()
	GameManager.call_deferred("resume_loaded_state_after_scene_ready")


func _process(_delta: float) -> void:
	if position != Vector2.ZERO or scale != Vector2.ONE or not is_zero_approx(offset_left) or not is_zero_approx(offset_top) or not is_zero_approx(offset_right) or not is_zero_approx(offset_bottom):
		_reset_fullscreen_layout()
	if label_log != null and label_log.text != last_log_text:
		_capture_log_change(label_log.text)
	if crafting_running:
		_update_crafting_minigame(_delta)
	if sect_event_countdown_active:
		_update_sect_event_countdown(_delta)


func _reset_fullscreen_layout() -> void:
	position = Vector2.ZERO
	scale = Vector2.ONE
	offset_left = 0.0
	offset_top = 0.0
	offset_right = 0.0
	offset_bottom = 0.0


func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color(0.0, 0.0, 0.0, 0.0)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var root := VBoxContainer.new()
	UIEffects.apply_phone_safe_margins(root, 34.0, 22.0, 86.0)
	root.add_theme_constant_override("separation", 8)
	root.clip_contents = false
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(root)

	root.add_child(_build_enemy_panel())
	root.add_child(_build_lottery_panel())
	root.add_child(_build_my_info_panel())

	floating_layer = Control.new()
	floating_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	floating_layer.z_index = 320
	floating_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(floating_layer)

	backpack_overlay_layer = _build_backpack_overlay()
	add_child(backpack_overlay_layer)

	crafting_layer = _build_crafting_overlay()
	add_child(crafting_layer)

	sect_event_layer = _build_sect_event_overlay()
	add_child(sect_event_layer)

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
	panel.custom_minimum_size = Vector2(1, 128)
	_apply_panel_style(panel, Color("#22223f"))

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	panel.add_child(box)

	var enemy_name_row := HBoxContainer.new()
	enemy_name_row.alignment = BoxContainer.ALIGNMENT_CENTER
	enemy_name_row.add_theme_constant_override("separation", 6)
	box.add_child(enemy_name_row)

	label_enemy_name = _make_label("对手", 22, Color("#f0c040"), HORIZONTAL_ALIGNMENT_CENTER)
	label_enemy_name.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	label_enemy_name.custom_minimum_size = Vector2(104, 30)
	label_enemy_name.clip_text = false
	label_enemy_name.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	enemy_name_row.add_child(label_enemy_name)
	label_enemy_sect_badge = _make_label("【剑】", 20, Color("#f0c040"), HORIZONTAL_ALIGNMENT_CENTER)
	label_enemy_sect_badge.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	label_enemy_sect_badge.clip_text = false
	label_enemy_sect_badge.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	enemy_name_row.add_child(label_enemy_sect_badge)
	label_enemy_resonance_badge = _make_label("", 18, Color("#d8d8e8"), HORIZONTAL_ALIGNMENT_CENTER)
	enemy_name_row.add_child(label_enemy_resonance_badge)

	label_enemy_realm = _make_label("炼气一层", 16, Color("#8a8070"), HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(label_enemy_realm)
	label_enemy_power = _make_label("战力：0", 18, Color("#f0c040"), HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(label_enemy_power)

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
	label_npc_dialogue = _make_label("", 18, Color("#e0d5b7"), HORIZONTAL_ALIGNMENT_CENTER)
	label_npc_dialogue.visible = false
	box.add_child(label_npc_dialogue)
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

	lottery_card_area = Control.new()
	lottery_card_area.custom_minimum_size = Vector2(1, 330)
	lottery_card_area.clip_contents = false
	box.add_child(lottery_card_area)

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
	lottery_card_area.add_child(taiji_rect)
	_build_taiji_animation(lottery_card_area)

	lottery_scroll = null

	lottery_container = Control.new()
	lottery_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	lottery_container.clip_contents = false
	lottery_card_area.add_child(lottery_container)

	var build_sidebar := VBoxContainer.new()
	build_sidebar.anchor_left = 0.0
	build_sidebar.anchor_top = 0.5
	build_sidebar.anchor_bottom = 0.5
	build_sidebar.offset_left = 8.0
	build_sidebar.offset_right = 92.0
	build_sidebar.offset_top = -150.0
	build_sidebar.offset_bottom = 150.0
	build_sidebar.add_theme_constant_override("separation", 5)
	lottery_card_area.add_child(build_sidebar)
	lottery_card_area.resized.connect(func() -> void:
		_position_build_sidebar(build_sidebar, lottery_card_area)
	)
	_position_build_sidebar(build_sidebar, lottery_card_area)

	build_sidebar.add_child(_build_route_visualizer())

	btn_inject_shouyuan = Button.new()
	btn_inject_shouyuan.text = "注入能量"
	btn_inject_shouyuan.custom_minimum_size = Vector2(180, 48)
	btn_inject_shouyuan.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn_inject_shouyuan.pressed.connect(_on_inject_shouyuan_pressed)
	btn_inject_shouyuan.visible = false
	box.add_child(btn_inject_shouyuan)

	label_current_ji_yuan = _make_label("本张：等待翻牌", 24, Color("#f0c040"), HORIZONTAL_ALIGNMENT_CENTER)
	label_current_calamity = _make_label("选择提示：翻开后再决定", 24, Color("#c04040"), HORIZONTAL_ALIGNMENT_CENTER)
	_make_mobile_safe_line(label_current_ji_yuan)
	_make_mobile_safe_line(label_current_calamity)
	box.add_child(label_current_ji_yuan)
	box.add_child(label_current_calamity)
	box.add_child(_build_auction_panel())

	result_toast = PanelContainer.new()
	result_toast.visible = false
	result_toast.custom_minimum_size = Vector2(1, 204)
	result_toast.mouse_filter = Control.MOUSE_FILTER_STOP
	_apply_panel_style(result_toast, Color(0.08, 0.08, 0.16, 0.94))
	box.add_child(result_toast)

	var result_box := VBoxContainer.new()
	result_box.alignment = BoxContainer.ALIGNMENT_CENTER
	result_box.add_theme_constant_override("separation", 4)
	result_toast.add_child(result_box)
	label_result_title = _make_label("", 30, Color("#f0c040"), HORIZONTAL_ALIGNMENT_CENTER)
	label_result_detail = _make_label("", 19, Color("#e0d5b7"), HORIZONTAL_ALIGNMENT_LEFT)
	label_result_detail.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
	label_result_detail.clip_text = false
	label_result_detail.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	label_result_detail.custom_minimum_size = Vector2(1, 84)
	result_box.add_child(label_result_title)
	result_box.add_child(label_result_detail)
	contest_button_row = HBoxContainer.new()
	contest_button_row.visible = false
	contest_button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	contest_button_row.add_theme_constant_override("separation", 18)
	result_box.add_child(contest_button_row)

	btn_contest_yield = Button.new()
	btn_contest_yield.text = "放弃保底"
	btn_contest_yield.custom_minimum_size = Vector2(168, 52)
	btn_contest_yield.add_theme_font_size_override("font_size", 21)
	btn_contest_yield.pressed.connect(_on_contest_decision_pressed.bind("yield"))
	contest_button_row.add_child(btn_contest_yield)

	btn_contest_fight = Button.new()
	btn_contest_fight.text = "反击一手"
	btn_contest_fight.custom_minimum_size = Vector2(168, 52)
	btn_contest_fight.add_theme_font_size_override("font_size", 21)
	btn_contest_fight.pressed.connect(_on_contest_decision_pressed.bind("fight"))
	contest_button_row.add_child(btn_contest_fight)
	btn_continue_result = Button.new()
	btn_continue_result.text = "继续"
	btn_continue_result.custom_minimum_size = Vector2(270, 50)
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


func _position_build_sidebar(sidebar: Control, card_area: Control) -> void:
	if sidebar == null or card_area == null:
		return
	var sidebar_width: float = 84.0
	var sidebar_height: float = 300.0
	var card_width: float = 232.0
	var gap: float = 12.0
	var margin: float = 8.0
	var area_width: float = maxf(card_area.size.x, card_area.custom_minimum_size.x)
	var left: float = area_width * 0.5 - card_width * 0.5 - sidebar_width - gap
	if left < margin:
		var right_left: float = area_width * 0.5 + card_width * 0.5 + gap
		if right_left + sidebar_width <= area_width - margin:
			left = right_left
		else:
			left = margin
	sidebar.anchor_left = 0.0
	sidebar.anchor_right = 0.0
	sidebar.anchor_top = 0.5
	sidebar.anchor_bottom = 0.5
	sidebar.offset_left = left
	sidebar.offset_right = left + sidebar_width
	sidebar.offset_top = -sidebar_height * 0.5
	sidebar.offset_bottom = sidebar_height * 0.5


func _build_auction_panel() -> PanelContainer:
	auction_panel = PanelContainer.new()
	auction_panel.visible = false
	auction_panel.custom_minimum_size = Vector2(1, 252)
	_apply_panel_style(auction_panel, Color("#2c210d"))

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	auction_panel.add_child(box)

	label_auction_title = _make_label("坊市", 32, Color("#f0c040"), HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(label_auction_title)

	label_auction_status = _make_label("选择一件货品：经商降低花费，讲价更便宜，出价更优先。", 20, Color("#e0d5b7"), HORIZONTAL_ALIGNMENT_CENTER)
	label_auction_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(label_auction_status)

	auction_lot_labels.clear()
	auction_bid_buttons.clear()
	auction_haggle_buttons.clear()
	for i in range(3):
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		box.add_child(row)

		var lot_label := _make_label("货品", 19, Color("#e0d5b7"))
		lot_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lot_label.custom_minimum_size = Vector2(330, 54)
		lot_label.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
		lot_label.clip_text = false
		lot_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
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

	var auction_bottom_row: HBoxContainer = HBoxContainer.new()
	auction_bottom_row.alignment = BoxContainer.ALIGNMENT_CENTER
	auction_bottom_row.add_theme_constant_override("separation", 12)
	box.add_child(auction_bottom_row)

	button_auction_pass = Button.new()
	button_auction_pass.text = "不买，离场"
	button_auction_pass.custom_minimum_size = Vector2(220, 48)
	button_auction_pass.add_theme_font_size_override("font_size", 22)
	button_auction_pass.pressed.connect(_on_auction_action_pressed.bind(-1, "pass"))
	auction_bottom_row.add_child(button_auction_pass)
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

	scroll_my_info = null

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_child(box)

	var my_name_row := HBoxContainer.new()
	my_name_row.alignment = BoxContainer.ALIGNMENT_CENTER
	my_name_row.add_theme_constant_override("separation", 4)
	box.add_child(my_name_row)

	label_my_name = _make_label("我", 24, Color("#f0c040"), HORIZONTAL_ALIGNMENT_CENTER)
	label_my_name.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	label_my_name.custom_minimum_size = Vector2(88, 34)
	label_my_name.clip_text = false
	label_my_name.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	my_name_row.add_child(label_my_name)
	label_my_sect_badge = _make_label("未定", 24, Color("#8a8070"), HORIZONTAL_ALIGNMENT_LEFT)
	label_my_sect_badge.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	label_my_sect_badge.custom_minimum_size = Vector2(0, 36)
	label_my_sect_badge.clip_text = false
	label_my_sect_badge.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	my_name_row.add_child(label_my_sect_badge)
	label_my_resonance_badge = _make_label("", 20, Color("#d8d8e8"), HORIZONTAL_ALIGNMENT_CENTER)
	label_my_resonance_badge.custom_minimum_size = Vector2(70, 42)
	my_name_row.add_child(label_my_resonance_badge)

	label_my_stats = _make_label("寿 10  灵 0  石 0  血 100  炼气一层", 21, Color("#e0d5b7"), HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(label_my_stats)
	label_my_power = _make_label("战力：0", 20, Color("#f0c040"), HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(label_my_power)

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
	label_backpack = _make_label("背包：0 / 8", 20, Color("#e0d5b7"))
	label_backpack_block = _make_label("", 20, Color("#c04040"), HORIZONTAL_ALIGNMENT_CENTER)
	label_my_techniques.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label_my_companions.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label_my_treasures.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	var resource_row := HBoxContainer.new()
	resource_row.alignment = BoxContainer.ALIGNMENT_CENTER
	resource_row.add_theme_constant_override("separation", 6)
	box.add_child(resource_row)

	button_backpack = Button.new()
	button_backpack.text = "背包 0/8\n灵石 0"
	button_backpack.custom_minimum_size = Vector2(122, 58)
	button_backpack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_backpack.add_theme_font_size_override("font_size", 18)
	button_backpack.pressed.connect(_on_backpack_button_pressed)
	resource_row.add_child(button_backpack)

	button_alchemy = Button.new()
	button_alchemy.text = "炼丹"
	button_alchemy.custom_minimum_size = Vector2(76, 58)
	button_alchemy.add_theme_font_size_override("font_size", 18)
	button_alchemy.pressed.connect(_on_alchemy_pressed)
	resource_row.add_child(button_alchemy)

	button_refining = Button.new()
	button_refining.text = "炼器"
	button_refining.custom_minimum_size = Vector2(76, 58)
	button_refining.add_theme_font_size_override("font_size", 18)
	button_refining.pressed.connect(_on_refining_pressed)
	resource_row.add_child(button_refining)

	resource_row.add_child(_build_log_panel())

	button_market = Button.new()
	button_market.text = "坊市"
	button_market.custom_minimum_size = Vector2(150, 58)
	button_market.add_theme_font_size_override("font_size", 24)
	button_market.pressed.connect(_on_market_pressed)
	button_market.visible = false
	resource_row.add_child(button_market)

	box.add_child(label_backpack_block)

	var equip_hint := _make_label("新牌先进背包；点背包管理；装备后才计入构筑。", 18, Color("#8a8070"), HORIZONTAL_ALIGNMENT_CENTER)
	_make_mobile_safe_line(equip_hint)
	box.add_child(equip_hint)

	var equipment_area := HBoxContainer.new()
	equipment_area.alignment = BoxContainer.ALIGNMENT_CENTER
	equipment_area.add_theme_constant_override("separation", 12)
	box.add_child(equipment_area)

	var technique_grid := GridContainer.new()
	technique_grid.columns = 2
	technique_grid.add_theme_constant_override("h_separation", 8)
	technique_grid.add_theme_constant_override("v_separation", 8)
	equipment_area.add_child(technique_grid)
	technique_slot_nodes.clear()
	for i in range(GameManager.MAX_EQUIPPED_TECHNIQUES):
		var technique_slot := InventoryDropSlot.new()
		technique_slot.setup(self, "technique", i, "空", Color("#6080d0"), Vector2(150, 86))
		technique_grid.add_child(technique_slot)
		technique_slot_nodes.append(technique_slot)

	var utility_grid := GridContainer.new()
	utility_grid.columns = 2
	utility_grid.add_theme_constant_override("h_separation", 8)
	utility_grid.add_theme_constant_override("v_separation", 8)
	equipment_area.add_child(utility_grid)

	treasure_slot_node = InventoryDropSlot.new()
	treasure_slot_node.setup(self, "treasure", 0, "法宝", Color("#f0c040"), Vector2(150, 86))
	utility_grid.add_child(treasure_slot_node)

	discard_slot = InventoryDropSlot.new()
	discard_slot.setup(self, "discard", 0, "弃置", Color("#c04040"), Vector2(150, 86))
	utility_grid.add_child(discard_slot)

	var companion_row := HBoxContainer.new()
	companion_row.alignment = BoxContainer.ALIGNMENT_CENTER
	companion_row.add_theme_constant_override("separation", 10)
	box.add_child(companion_row)
	companion_slot_nodes.clear()
	for i in range(3):
		var companion_slot := InventoryDropSlot.new()
		companion_slot.setup(self, "companion", i, "同伴" + str(i + 1), Color("#c080e0"))
		companion_row.add_child(companion_slot)
		companion_slot_nodes.append(companion_slot)

	backpack_slots_container = GridContainer.new()
	backpack_slots_container.columns = 5
	backpack_slots_container.add_theme_constant_override("h_separation", 6)
	backpack_slots_container.add_theme_constant_override("v_separation", 8)
	backpack_slots_container.visible = false
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
	treasure_menu.id_pressed.connect(_on_treasure_menu_pressed)
	add_child(treasure_menu)

	backpack_menu = PopupMenu.new()
	backpack_menu.id_pressed.connect(_on_backpack_menu_pressed)
	add_child(backpack_menu)

	market_menu = PopupMenu.new()
	market_menu.id_pressed.connect(_on_market_menu_pressed)
	add_child(market_menu)

	alchemy_menu = PopupMenu.new()
	alchemy_menu.id_pressed.connect(_on_alchemy_menu_pressed)
	add_child(alchemy_menu)

	build_info_dialog = AcceptDialog.new()
	build_info_dialog.title = "词条说明"
	build_info_dialog.min_size = Vector2i(620, 520)
	add_child(build_info_dialog)

	return panel


func _build_backpack_overlay() -> Control:
	var layer: Control = Control.new()
	layer.visible = false
	layer.mouse_filter = Control.MOUSE_FILTER_STOP
	layer.z_index = 360
	layer.set_anchors_preset(Control.PRESET_FULL_RECT)

	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.0, 0.0, 0.0, 0.54)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.gui_input.connect(_on_backpack_overlay_dim_gui_input)
	layer.add_child(dim)

	var center: CenterContainer = CenterContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(center)

	var panel: PanelContainer = PanelContainer.new()
	var panel_width: float = _safe_overlay_width(690.0)
	var panel_height: float = minf(820.0, maxf(560.0, get_viewport_rect().size.y - 190.0))
	panel.custom_minimum_size = Vector2(panel_width, panel_height)
	_apply_panel_style(panel, Color("#22223f"))
	center.add_child(panel)

	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	panel.add_child(box)

	var title_row: HBoxContainer = HBoxContainer.new()
	title_row.alignment = BoxContainer.ALIGNMENT_CENTER
	title_row.add_theme_constant_override("separation", 10)
	box.add_child(title_row)

	label_backpack_overlay_title = _make_label("背包", 28, Color("#f0c040"), HORIZONTAL_ALIGNMENT_CENTER)
	label_backpack_overlay_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(label_backpack_overlay_title)

	var content_row: HBoxContainer = HBoxContainer.new()
	content_row.add_theme_constant_override("separation", 12)
	content_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(content_row)

	var left_box: VBoxContainer = VBoxContainer.new()
	left_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_row.add_child(left_box)

	var right_box: VBoxContainer = VBoxContainer.new()
	right_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_box.add_theme_constant_override("separation", 10)
	content_row.add_child(right_box)

	backpack_overlay_list = ItemList.new()
	backpack_overlay_list.custom_minimum_size = Vector2(1, 240)
	backpack_overlay_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	backpack_overlay_list.max_columns = 1
	backpack_overlay_list.fixed_icon_size = Vector2i(54, 54)
	backpack_overlay_list.add_theme_font_size_override("font_size", 25)
	backpack_overlay_list.add_theme_constant_override("v_separation", 10)
	backpack_overlay_list.add_theme_constant_override("icon_margin", 12)
	backpack_overlay_list.item_selected.connect(_on_backpack_overlay_item_selected)
	backpack_overlay_list.item_activated.connect(_on_backpack_overlay_item_selected)
	backpack_overlay_list.gui_input.connect(_on_backpack_overlay_list_gui_input)
	left_box.add_child(backpack_overlay_list)

	var detail_panel: PanelContainer = PanelContainer.new()
	detail_panel.custom_minimum_size = Vector2(1, 246)
	detail_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_apply_panel_style(detail_panel, Color("#18182d"))
	right_box.add_child(detail_panel)

	var detail_scroll: ScrollContainer = ScrollContainer.new()
	detail_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_panel.add_child(detail_scroll)

	label_backpack_overlay_detail = _make_label("点选一张牌查看效果。", 22, Color("#e0d5b7"))
	label_backpack_overlay_detail.clip_text = false
	label_backpack_overlay_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label_backpack_overlay_detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label_backpack_overlay_detail.custom_minimum_size = Vector2(1, 220)
	detail_scroll.add_child(label_backpack_overlay_detail)

	backpack_action_grid = GridContainer.new()
	backpack_action_grid.columns = 2
	backpack_action_grid.add_theme_constant_override("h_separation", 10)
	backpack_action_grid.add_theme_constant_override("v_separation", 10)
	right_box.add_child(backpack_action_grid)

	var bottom_action_row: HBoxContainer = HBoxContainer.new()
	bottom_action_row.alignment = BoxContainer.ALIGNMENT_CENTER
	bottom_action_row.add_theme_constant_override("separation", 10)
	right_box.add_child(bottom_action_row)

	button_backpack_overlay_sell = Button.new()
	button_backpack_overlay_sell.text = "倒卖"
	button_backpack_overlay_sell.custom_minimum_size = Vector2(1, 64)
	button_backpack_overlay_sell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_backpack_overlay_sell.add_theme_font_size_override("font_size", 24)
	button_backpack_overlay_sell.disabled = true
	button_backpack_overlay_sell.pressed.connect(_on_backpack_overlay_sell_pressed)
	bottom_action_row.add_child(button_backpack_overlay_sell)

	button_backpack_overlay_discard = Button.new()
	button_backpack_overlay_discard.text = "丢弃"
	button_backpack_overlay_discard.custom_minimum_size = Vector2(1, 64)
	button_backpack_overlay_discard.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_backpack_overlay_discard.add_theme_font_size_override("font_size", 24)
	button_backpack_overlay_discard.disabled = true
	button_backpack_overlay_discard.pressed.connect(_on_backpack_overlay_discard_pressed)
	bottom_action_row.add_child(button_backpack_overlay_discard)
	return layer


func _build_crafting_overlay() -> Control:
	var layer: Control = Control.new()
	layer.visible = false
	layer.mouse_filter = Control.MOUSE_FILTER_STOP
	layer.z_index = 365
	layer.set_anchors_preset(Control.PRESET_FULL_RECT)

	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.0, 0.0, 0.0, 0.62)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.gui_input.connect(_on_crafting_overlay_dim_gui_input)
	layer.add_child(dim)

	var center: CenterContainer = CenterContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(center)

	crafting_panel = PanelContainer.new()
	crafting_panel.custom_minimum_size = Vector2(_safe_overlay_width(620.0), 360.0)
	_apply_panel_style(crafting_panel, Color("#18182d"))
	center.add_child(crafting_panel)

	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	crafting_panel.add_child(box)

	crafting_title_label = _make_label("开炉", 32, Color("#f0c040"), HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(crafting_title_label)

	crafting_status_label = _make_label("看准火候点收火，点空白处停手。", 22, Color("#e0d5b7"), HORIZONTAL_ALIGNMENT_CENTER)
	crafting_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(crafting_status_label)

	crafting_art_panel = PanelContainer.new()
	crafting_art_panel.custom_minimum_size = Vector2(1, 92)
	crafting_art_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	crafting_art_panel.add_theme_stylebox_override("panel", _make_crafting_art_style(Color("#2a1b10"), Color("#f0c040")))
	box.add_child(crafting_art_panel)

	crafting_art_label = _make_label("丹炉", 38, Color("#f0c040"), HORIZONTAL_ALIGNMENT_CENTER)
	crafting_art_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	crafting_art_label.custom_minimum_size = Vector2(1, 82)
	crafting_art_panel.add_child(crafting_art_label)

	crafting_bar = Control.new()
	crafting_bar.custom_minimum_size = Vector2(1, 58)
	crafting_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(crafting_bar)

	var bar_bg := ColorRect.new()
	bar_bg.color = Color("#111126")
	bar_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	crafting_bar.add_child(bar_bg)
	crafting_good_zone = _make_crafting_zone(0.34, 0.66, Color("#4040c0"))
	crafting_bar.add_child(crafting_good_zone)
	crafting_perfect_zone = _make_crafting_zone(0.46, 0.54, Color("#f0c040"))
	crafting_bar.add_child(crafting_perfect_zone)

	crafting_pointer = ColorRect.new()
	crafting_pointer.color = Color.WHITE
	crafting_pointer.anchor_top = 0.0
	crafting_pointer.anchor_bottom = 1.0
	crafting_pointer.offset_left = 0.0
	crafting_pointer.offset_right = 6.0
	crafting_bar.add_child(crafting_pointer)

	crafting_feedback_panel = PanelContainer.new()
	crafting_feedback_panel.visible = false
	crafting_feedback_panel.custom_minimum_size = Vector2(1, 88)
	crafting_feedback_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	crafting_feedback_panel.add_theme_stylebox_override("panel", _make_crafting_art_style(Color("#261604"), Color("#f0c040")))
	box.add_child(crafting_feedback_panel)

	var feedback_box := VBoxContainer.new()
	feedback_box.alignment = BoxContainer.ALIGNMENT_CENTER
	feedback_box.add_theme_constant_override("separation", 2)
	crafting_feedback_panel.add_child(feedback_box)

	crafting_feedback_label = _make_label("火候已成", 28, Color("#f0c040"), HORIZONTAL_ALIGNMENT_CENTER)
	feedback_box.add_child(crafting_feedback_label)
	crafting_feedback_detail_label = _make_label("收火及时，灵机入炉。", 18, Color("#e0d5b7"), HORIZONTAL_ALIGNMENT_CENTER)
	crafting_feedback_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_box.add_child(crafting_feedback_detail_label)

	var hint_label: Label = _make_label("蓝区成功，金区完美；失手也会有少量残火收益。", 19, Color("#8a8070"), HORIZONTAL_ALIGNMENT_CENTER)
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(hint_label)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.add_theme_constant_override("separation", 14)
	box.add_child(button_row)

	crafting_action_button = Button.new()
	crafting_action_button.text = "收火"
	crafting_action_button.custom_minimum_size = Vector2(220, 58)
	crafting_action_button.add_theme_font_size_override("font_size", 24)
	crafting_action_button.pressed.connect(_on_crafting_action_pressed)
	button_row.add_child(crafting_action_button)
	return layer


func _build_sect_event_overlay() -> Control:
	var layer: Control = Control.new()
	layer.visible = false
	layer.mouse_filter = Control.MOUSE_FILTER_STOP
	layer.z_index = 380
	layer.set_anchors_preset(Control.PRESET_FULL_RECT)

	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.0, 0.0, 0.0, 0.72)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(dim)

	var center: CenterContainer = CenterContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(center)

	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(_safe_overlay_width(680.0), 560.0)
	_apply_panel_style(panel, Color("#18182d"))
	center.add_child(panel)

	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	panel.add_child(box)

	sect_event_title_label = _make_label("宗门事件", 34, Color("#f0c040"), HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(sect_event_title_label)

	sect_event_desc_label = _make_label("", 22, Color("#e0d5b7"), HORIZONTAL_ALIGNMENT_CENTER)
	sect_event_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sect_event_desc_label.custom_minimum_size = Vector2(1, 80)
	box.add_child(sect_event_desc_label)

	sect_event_countdown_label = _make_label("10秒后默认不参加", 24, Color("#c080e0"), HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(sect_event_countdown_label)

	sect_event_body_label = RichTextLabel.new()
	sect_event_body_label.custom_minimum_size = Vector2(1, 230)
	sect_event_body_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sect_event_body_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sect_event_body_label.bbcode_enabled = false
	sect_event_body_label.scroll_active = true
	sect_event_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sect_event_body_label.add_theme_font_size_override("normal_font_size", 22)
	sect_event_body_label.add_theme_color_override("default_color", Color("#e0d5b7"))
	box.add_child(sect_event_body_label)

	var button_row: HBoxContainer = HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.add_theme_constant_override("separation", 18)
	box.add_child(button_row)

	sect_event_join_button = _make_choice_button("参加", Color("#3c8a5a"))
	sect_event_join_button.custom_minimum_size = Vector2(240, 76)
	sect_event_join_button.add_theme_font_size_override("font_size", 30)
	sect_event_join_button.pressed.connect(_on_sect_event_choice_pressed.bind(true))
	button_row.add_child(sect_event_join_button)

	sect_event_skip_button = _make_choice_button("不参加", Color("#444472"))
	sect_event_skip_button.custom_minimum_size = Vector2(240, 76)
	sect_event_skip_button.add_theme_font_size_override("font_size", 30)
	sect_event_skip_button.pressed.connect(_on_sect_event_choice_pressed.bind(false))
	button_row.add_child(sect_event_skip_button)

	sect_event_continue_button = Button.new()
	sect_event_continue_button.text = "继续修行"
	sect_event_continue_button.visible = false
	sect_event_continue_button.custom_minimum_size = Vector2(280, 64)
	sect_event_continue_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	sect_event_continue_button.add_theme_font_size_override("font_size", 26)
	sect_event_continue_button.pressed.connect(_on_sect_event_continue_pressed)
	box.add_child(sect_event_continue_button)
	return layer


func _make_crafting_art_style(fill_color: Color, border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = border_color
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 10
	style.content_margin_top = 6
	style.content_margin_right = 10
	style.content_margin_bottom = 6
	return style


func _make_crafting_zone(left_ratio: float, right_ratio: float, color: Color) -> ColorRect:
	var zone := ColorRect.new()
	zone.color = color
	zone.anchor_left = left_ratio
	zone.anchor_right = right_ratio
	zone.anchor_top = 0.0
	zone.anchor_bottom = 1.0
	zone.offset_left = 0.0
	zone.offset_right = 0.0
	zone.offset_top = 0.0
	zone.offset_bottom = 0.0
	return zone


func _build_log_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(92, 58)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#18182d")
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 8
	style.content_margin_top = 5
	style.content_margin_right = 6
	style.content_margin_bottom = 5
	panel.add_theme_stylebox_override("panel", style)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	panel.add_child(row)

	label_log = _make_label("日志：等待本轮抽牌", 24, Color("#e0e0e0"))
	label_log.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label_log.custom_minimum_size = Vector2(1, 46)
	label_log.add_theme_font_size_override("font_size", 16)
	label_log.autowrap_mode = TextServer.AUTOWRAP_OFF
	label_log.clip_text = true
	label_log.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label_log.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(label_log)

	button_log_open = Button.new()
	button_log_open.text = "录"
	button_log_open.tooltip_text = "查看完整记录"
	button_log_open.custom_minimum_size = Vector2(42, 46)
	button_log_open.add_theme_font_size_override("font_size", 18)
	button_log_open.pressed.connect(_show_log_overlay)
	row.add_child(button_log_open)
	return panel


func _capture_log_change(text: String) -> void:
	last_log_text = text
	var cleaned: String = _clean_log_text(text)
	if cleaned == "":
		return
	if not log_history.is_empty() and log_history[log_history.size() - 1] == cleaned:
		return
	log_history.append(cleaned)
	while log_history.size() > 80:
		log_history.pop_front()
	if label_log_overlay_body != null:
		label_log_overlay_body.text = _full_log_text()


func _clean_log_text(text: String) -> String:
	var cleaned: String = text.strip_edges()
	if cleaned.begins_with("日志："):
		cleaned = cleaned.substr(3).strip_edges()
	if cleaned.begins_with("日志:"):
		cleaned = cleaned.substr(3).strip_edges()
	cleaned = _rewrite_log_text(cleaned)
	if _is_mechanical_log(cleaned):
		return ""
	return cleaned


func _is_mechanical_log(text: String) -> bool:
	var patterns: Array[String] = [
		"等待对方",
		"点按钮继续",
		"结果停在面板",
		"你已确认结果",
		"你已确认整备",
		"你选择了「",
		"你选择「",
		"你暂时躲开了",
		"你气势更盛",
		"你已注入能量",
		"能量注入",
		"战利品已收入囊中",
		"已收起",
		"正在尝试突破",
		"斩妖结算已显示",
	]
	for pattern in patterns:
		if text.contains(pattern):
			return true
	return false


func _rewrite_log_text(text: String) -> String:
	var cleaned: String = text
	cleaned = cleaned.replace("；结果停在面板里，点按钮继续", "")
	cleaned = cleaned.replace("，点按钮继续", "")
	cleaned = cleaned.replace("看完结果后点按钮继续", "")
	cleaned = cleaned.replace("，等待对手选择", "")
	cleaned = cleaned.replace("，等待对方抉择", "")
	cleaned = cleaned.replace("，等待对方", "")
	cleaned = cleaned.replace("等待对方", "")
	if cleaned.contains("你选「") and cleaned.contains("对方选「"):
		cleaned = cleaned.replace("你选", "抉择")
		cleaned = cleaned.replace("，对方选", "，对手")
	return cleaned.strip_edges()


func _show_log_overlay() -> void:
	if log_overlay_layer == null:
		log_overlay_layer = _build_log_overlay()
		add_child(log_overlay_layer)
	if label_log != null:
		_capture_log_change(label_log.text)
	label_log_overlay_body.text = _full_log_text()
	log_overlay_layer.visible = true
	log_overlay_layer.move_to_front()


func _hide_log_overlay() -> void:
	if log_overlay_layer != null:
		log_overlay_layer.visible = false


func _on_log_overlay_dim_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_hide_log_overlay()
	elif event is InputEventScreenTouch and event.pressed:
		_hide_log_overlay()


func _build_log_overlay() -> Control:
	var layer := Control.new()
	layer.visible = false
	layer.mouse_filter = Control.MOUSE_FILTER_STOP
	layer.z_index = 390
	layer.set_anchors_preset(Control.PRESET_FULL_RECT)

	var dim := ColorRect.new()
	dim.color = Color(0.0, 0.0, 0.0, 0.58)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.gui_input.connect(_on_log_overlay_dim_gui_input)
	layer.add_child(dim)

	var center := CenterContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(center)

	var panel := PanelContainer.new()
	var panel_height: float = minf(920.0, maxf(520.0, get_viewport_rect().size.y - 190.0))
	panel.custom_minimum_size = Vector2(_safe_overlay_width(680.0), panel_height)
	_apply_panel_style(panel, Color("#20203a"))
	center.add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)

	var title_row := HBoxContainer.new()
	title_row.alignment = BoxContainer.ALIGNMENT_CENTER
	title_row.add_theme_constant_override("separation", 10)
	box.add_child(title_row)

	var title := _make_label("事件记录", 32, Color("#f0c040"), HORIZONTAL_ALIGNMENT_CENTER)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(title)

	label_log_overlay_body = RichTextLabel.new()
	label_log_overlay_body.custom_minimum_size = Vector2(1, maxf(360.0, panel_height - 116.0))
	label_log_overlay_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	label_log_overlay_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label_log_overlay_body.bbcode_enabled = false
	label_log_overlay_body.scroll_active = true
	label_log_overlay_body.selection_enabled = true
	label_log_overlay_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label_log_overlay_body.add_theme_font_size_override("normal_font_size", 24)
	label_log_overlay_body.add_theme_color_override("default_color", Color("#e0d5b7"))
	box.add_child(label_log_overlay_body)
	return layer


func _full_log_text() -> String:
	if log_history.is_empty():
		return "暂无记录。"
	var lines: Array[String] = []
	var start_index: int = maxi(0, log_history.size() - 40)
	for i in range(start_index, log_history.size()):
		var cleaned_line: String = _clean_log_text(str(log_history[i]))
		if cleaned_line == "":
			continue
		lines.append(str(lines.size() + 1) + ". " + cleaned_line)
	if lines.is_empty():
		return "暂无记录。"
	return "\n\n".join(lines)


func _add_stat_chip(parent: GridContainer, stat_name: String) -> void:
	var chip := PanelContainer.new()
	chip.custom_minimum_size = Vector2(96, 50)
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
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.clip_text = true
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _make_mobile_safe_line(label: Label) -> void:
	if label == null:
		return
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.clip_text = true
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.autowrap_mode = TextServer.AUTOWRAP_OFF


func _safe_overlay_width(max_width: float) -> float:
	return minf(max_width, maxf(260.0, get_viewport_rect().size.x - 68.0))


func _overlay_position(width: float, y_offset_from_center: float) -> Vector2:
	var viewport_size: Vector2 = get_viewport_rect().size
	return Vector2((viewport_size.x - width) * 0.5, viewport_size.y * 0.5 - y_offset_from_center)


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
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.clip_contents = true
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


func _lottery_card_panel_color(card: Dictionary, active: bool) -> Color:
	if bool(card.get("identity_special", false)):
		var sect_color: Color = _special_card_sect_color(card)
		var strength: float = 0.28 if active else 0.16
		return Color(sect_color.r * strength, sect_color.g * strength, sect_color.b * strength, 1.0)
	return Color("#3a3a6e") if active else Color("#151527")


func _special_card_sect_color(card: Dictionary) -> Color:
	var raw_color: String = str(card.get("sect_color", ""))
	if raw_color.begins_with("#"):
		return Color(raw_color)
	return Color("#f0c040")


func _on_lottery_generated(results: Array) -> void:
	if backpack_slots_container != null:
		backpack_slots_container.visible = false
	_hide_backpack_overlay()
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
	if bool(card.get("identity_special", false)):
		var sect_color: Color = _special_card_sect_color(card)
		_flash_overlay(Color(sect_color.r, sect_color.g, sect_color.b, 0.22), 0.34)
		_spawn_center_banner(str(card.get("identity_sect", "宗门")) + "专属", sect_color)
	if quality == "合体级":
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


func _flash_overlay(color: Color, fade_time: float = 0.3) -> void:
	if rainbow_flash == null:
		return
	var clear_color := Color(color.r, color.g, color.b, 0.0)
	var tween := create_tween()
	tween.tween_property(rainbow_flash, "color", color, 0.08)
	tween.tween_property(rainbow_flash, "color", clear_color, fade_time)


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


func _set_result_card_mode(_active: bool) -> void:
	if lottery_container != null:
		lottery_container.visible = true


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
	panel.size = Vector2(232, 312)
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -116.0
	panel.offset_top = -156.0
	panel.offset_right = 116.0
	panel.offset_bottom = 156.0
	_apply_lottery_card_panel_style(panel, _lottery_card_panel_color(card, false))
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
		label_current_ji_yuan.text = "本轮已结束"
		label_current_calamity.text = "看完结果后进入下一轮"
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
	if not card.has("effect_type"):
		label_round_info.text = "第 " + str(GameManager.round_number) + " 轮 · 第 " + str(index + 1) + " / 10 张"
		label_current_ji_yuan.text = "本张：等待显化"
		label_current_calamity.text = "正在续接存档..."
		_set_choice_enabled(false)
		label_waiting.visible = true
		label_waiting.text = "牌阵重启中"
		return
	if _visible_card_source_index() != index:
		_render_single_lottery_card(index, card, true)
	if not lottery_panels.is_empty():
		_apply_lottery_card_panel_style(lottery_panels[0], _lottery_card_panel_color(card, true))
	_focus_card(index)
	label_round_info.text = "第 " + str(GameManager.round_number) + " 轮 · 第 " + str(index + 1) + " / 10 张"
	if str(card.get("type", "")) == "机缘":
		label_current_ji_yuan.text = "本张：" + _card_summary(card)
		label_current_calamity.text = "等待双方选择"
		_set_bargain_button_mode(false)
	else:
		label_current_ji_yuan.text = "本张：" + _card_summary(card)
		label_current_calamity.text = "等待双方选择"
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
	var contest_result: Dictionary = data.get("contest_result", {}) as Dictionary
	label_log.text = "日志：你选「" + my_choice + "」，对方选「" + enemy_choice + "」；结果停在面板里，点按钮继续"
	latest_result_round_finished = bool(data.get("round_finished", false))
	result_continue_sent = false
	_show_card_face(settled_index, group)
	_show_result_feedback(my_result, enemy_result, group, contest_result)
	_spawn_result_float(settled_index, my_result, group)
	if str(group.get("effect_type", "")) == "enemy":
		label_log.text += "；遭遇敌人，战斗模块暂未开启，本次先跳过"

	label_current_ji_yuan.text = "本张已结算"
	label_current_calamity.text = "看完结果后点按钮继续"
	_set_choice_enabled(false)
	label_waiting.visible = false


func _on_contest_started(data: Dictionary) -> void:
	_update_player_info()
	_set_choice_enabled(false)
	_hide_auction_panel()
	if result_toast == null:
		return
	_set_result_card_mode(true)

	var card: Dictionary = data.get("card", {}) as Dictionary
	var weak_key: String = str(data.get("weak_key", "a"))
	var strong_key: String = str(data.get("strong_key", "b"))
	var my_key: String = "a" if NetworkManager.is_host else "b"
	var power_a: int = int(round(float(data.get("power_a", 0.0))))
	var power_b: int = int(round(float(data.get("power_b", 0.0))))
	var counter_chance_pct: int = int(round(float(data.get("counter_chance", 0.0)) * 100.0))
	var weak_name: String = GameManager.player_a.player_name if weak_key == "a" else GameManager.player_b.player_name
	var strong_name: String = GameManager.player_a.player_name if strong_key == "a" else GameManager.player_b.player_name
	var is_weak_side: bool = my_key == weak_key
	var is_calamity: bool = str(card.get("type", "")) == "灾厄"
	var title_text: String = "劫气缠身" if is_calamity else "争道压境"
	var title_color: Color = Color("#c04040") if is_calamity else Color("#f0c040")
	var main_line: String = "你：抢｜对方：抢"
	var role_hint: String = strong_name + "气势更盛，暂时压住了" + weak_name
	var rule_hint: String = "放弃拿保底；搏命反扑约" + str(counter_chance_pct) + "%，成功收益翻倍" if is_weak_side else "等待对方抉择"
	if is_calamity:
		main_line = "你：躲避｜对方：躲避"
		role_hint = strong_name + "暂避劫气，祸事缠向" + weak_name
		rule_hint = "承劫可减伤；转劫约" + str(counter_chance_pct) + "%，胜出可避劫" if is_weak_side else "等待对方抉择"

	_apply_panel_style(result_toast, Color(0.18, 0.12, 0.03, 0.97))
	label_result_title.text = title_text
	label_result_title.add_theme_color_override("font_color", title_color)
	label_result_detail.text = "本张：" + _card_summary(card) + "\n" + main_line + "\n" + role_hint + "\n" + rule_hint + "\n战力 " + GameManager.player_a.player_name + " " + str(power_a) + " / " + GameManager.player_b.player_name + " " + str(power_b)
	result_toast.visible = true
	result_toast.z_index = 240
	result_toast.move_to_front()
	result_toast.modulate.a = 1.0
	result_toast.scale = Vector2.ONE
	btn_continue_result.visible = false
	if contest_button_row != null:
		contest_button_row.visible = true
	if btn_contest_yield != null:
		btn_contest_yield.text = _contest_yield_text(is_calamity, is_weak_side)
		btn_contest_yield.disabled = not is_weak_side
	if btn_contest_fight != null:
		btn_contest_fight.text = _contest_fight_text(is_calamity, is_weak_side, counter_chance_pct)
		btn_contest_fight.disabled = not is_weak_side

	if is_weak_side:
		label_waiting.visible = false
		label_log.text = "日志：" + _contest_card_hint(card)
	else:
		label_waiting.visible = true
		label_waiting.text = "对方被劫气锁住，等待他承劫或转劫" if is_calamity else "对方被压住，等待他放弃或继续抢"
		label_waiting.add_theme_color_override("font_color", title_color)
		label_log.text = "日志：你暂时躲开了，等待对方抉择" if is_calamity else "日志：你气势更盛，等待对方抉择"
	UIEffects.screen_shake(self, 4.0, 0.18)
	_spawn_center_banner(title_text, title_color)


func _contest_card_hint(card: Dictionary) -> String:
	if str(card.get("type", "")) == "灾厄":
		return "劫气缠身：双方都躲，被缠住的一方抉择"
	return "争道压境：双方都抢，弱势一方抉择"


func _contest_yield_text(is_calamity: bool, is_weak_side: bool) -> String:
	if is_calamity:
		return "自己承劫" if is_weak_side else "暂避劫气"
	return "放弃这张" if is_weak_side else "你已压制"


func _contest_fight_text(is_calamity: bool, is_weak_side: bool, counter_chance_pct: int = -1) -> String:
	if is_calamity:
		return ("强行转劫 " + str(counter_chance_pct) + "%") if is_weak_side and counter_chance_pct >= 0 else ("强行转劫" if is_weak_side else "等对方抉择")
	return ("搏命反扑 " + str(counter_chance_pct) + "%") if is_weak_side and counter_chance_pct >= 0 else ("继续抢" if is_weak_side else "等对方抉择")


func _on_contest_decision_pressed(mode: String) -> void:
	if btn_contest_yield != null:
		btn_contest_yield.disabled = true
		btn_contest_yield.text = "已选择"
	if btn_contest_fight != null:
		btn_contest_fight.disabled = true
		btn_contest_fight.text = "等待结算"
	var is_calamity: bool = str(_current_visible_card().get("type", "")) == "灾厄"
	var text: String = ("自己承劫" if mode == "yield" else "强行转劫") if is_calamity else ("放弃这张" if mode == "yield" else "搏命反扑")
	var settle_name: String = "结算"
	label_log.text = "日志：你选择「" + text + "」，等待" + settle_name
	label_result_detail.text += "\n你选择：" + text
	if NetworkManager.is_host:
		GameManager.on_contest_choice_received(1, {"mode": mode})
	else:
		NetworkManager.send_message("contest_choice", {"mode": mode})


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
	_update_identity_labels(label_enemy_name, label_enemy_sect_badge, label_enemy_resonance_badge, enemy_player, true)
	label_enemy_shouyuan.text = _format_int_value(enemy_player.shou_yuan)
	label_enemy_lingli.text = _format_int_value(enemy_player.ling_li)
	label_enemy_lingshi.text = _format_int_value(enemy_player.ling_shi)
	label_enemy_qixue.text = _format_int_value(enemy_player.qi_xue)
	label_enemy_realm.text = GameManager.get_cultivation_stage_name(enemy_player)
	_update_power_label(label_enemy_power, enemy_player, true)
	label_enemy_tech_count.text = _format_int_value(enemy_player.techniques.size()) + "/" + str(GameManager.MAX_EQUIPPED_TECHNIQUES)
	label_enemy_comp_count.text = _format_int_value(enemy_player.companions.size())
	if GameManager.single_player_mode and label_npc_dialogue != null:
		label_npc_dialogue.visible = true
		if GameManager.npc_last_dialogue != "":
			label_npc_dialogue.text = enemy_player.player_name + "：「" + GameManager.npc_last_dialogue + "」"

	for stat in GameManager.BASE_STATS:
		if stat_chip_labels.has(stat):
			var value_label: Label = stat_chip_labels[stat] as Label
			value_label.text = _format_int_value(my_player.stats.get(stat, 0))
	_update_identity_labels(label_my_name, label_my_sect_badge, label_my_resonance_badge, my_player, false)
	label_my_stats.text = "寿 " + _format_int_value(my_player.shou_yuan) + "   灵 " + _format_int_value(my_player.ling_li) + "   石 " + _format_int_value(my_player.ling_shi) + "   血 " + _format_int_value(my_player.qi_xue) + "   " + GameManager.get_cultivation_stage_name(my_player)
	_update_power_label(label_my_power, my_player, false)
	_update_build_route_visualizer(my_player)
	_update_cultivation_bars(my_player)
	_update_breakthrough_button(my_player)
	label_my_techniques.text = "功法(" + str(my_player.techniques.size()) + "/" + str(GameManager.MAX_EQUIPPED_TECHNIQUES) + ") " + _format_short_named_list(my_player.techniques, "暂无", GameManager.MAX_EQUIPPED_TECHNIQUES)
	label_my_companions.text = "伙伴(" + str(my_player.companions.size()) + ") " + _format_short_companion_list(my_player.companions, "暂无", 3)
	label_my_treasures.text = "法宝(" + str(my_player.treasures.size()) + "/1) " + _format_short_named_list(my_player.treasures, "暂无", 1)
	label_backpack.text = "背包：" + str(my_player.backpack.size()) + " / " + str(my_player.backpack_capacity) + "    灵石：" + _format_int_value(my_player.ling_shi)
	if button_backpack != null:
		var pending_mark: String = "!" if GameManager.has_pending_backpack_item(my_player.peer_id) else ""
		button_backpack.text = "背包" + pending_mark + " " + str(my_player.backpack.size()) + "/" + str(my_player.backpack_capacity) + "\n灵石 " + _format_int_value(my_player.ling_shi)
	var backpack_counts_text: String = GameManager.get_backpack_counts_text(my_player)
	label_backpack.text = "背包：" + backpack_counts_text + "    灵石：" + _format_int_value(my_player.ling_shi)
	if button_backpack != null:
		var fixed_pending_mark: String = "!" if GameManager.has_pending_backpack_item(my_player.peer_id) else ""
		var counts: Dictionary = GameManager.get_backpack_counts(my_player)
		var short_counts: String = "功" + str(int(counts.get("technique", 0))) + "/" + str(GameManager.MAX_BACKPACK_TECHNIQUES) + " 法" + str(int(counts.get("treasure", 0))) + "/" + str(GameManager.MAX_BACKPACK_TREASURES) + " 伴" + str(int(counts.get("companion", 0))) + "/" + str(GameManager.MAX_BACKPACK_COMPANIONS) + " 材" + str(int(counts.get("material", 0))) + "/" + str(GameManager.MAX_BACKPACK_MATERIALS)
		button_backpack.text = "背包" + fixed_pending_mark + " " + str(my_player.backpack.size()) + "/" + str(GameManager.get_total_backpack_capacity()) + "\n" + short_counts
	_update_alchemy_button(my_player)
	_update_refining_button(my_player)
	_update_backpack_block_label(my_player)
	_update_treasure_list(my_player)
	_update_backpack_list(my_player)
	_update_drag_inventory(my_player)
	if backpack_overlay_layer != null and backpack_overlay_layer.visible:
		_update_backpack_overlay_list(my_player)


func _update_power_label(label: Label, player: PlayerData, is_enemy: bool) -> void:
	if label == null or player == null:
		return
	var power: int = int(round(GameManager.get_visible_combat_power(player)))
	var previous: int = last_enemy_power if is_enemy else last_my_power
	var arrow: String = ""
	if previous >= 0 and power != previous:
		arrow = " ↑" if power > previous else " ↓"
	label.text = "战力：" + _format_int_value(power) + arrow
	label.tooltip_text = GameManager.get_visible_combat_power_formula_text()
	label.add_theme_color_override("font_color", Color("#80c080") if arrow == " ↑" else (Color("#ff8080") if arrow == " ↓" else Color("#f0c040")))
	if is_enemy:
		last_enemy_power = power
	else:
		last_my_power = power


func _format_build_progress(player: PlayerData, vertical: bool = false) -> String:
	var progress: Dictionary = GameManager.get_cultivation_build_progress(player)
	var cultivation_type: String = str(progress.get("cultivation", "散修"))
	var count: int = int(progress.get("count", 0))
	var level: int = int(progress.get("level", 0))
	var level_name: String = str(progress.get("level_name", "未成"))
	var next_count: int = int(progress.get("next_count", 2))
	var target_count: int = 2 if level <= 0 else next_count
	var short_goal: String = "差" + str(maxi(0, target_count - count)) + "件"
	if level <= 0:
		if count <= 0:
			return ""
		if vertical:
			return cultivation_type + "\n" + str(count) + "/2"
		return "修行羁绊：" + cultivation_type + " " + str(count) + "/2｜差" + str(maxi(0, 2 - count)) + "件质变"
	if vertical:
		return cultivation_type + "\n" + str(count) + "/" + ("满" if level >= 4 else str(next_count)) + "\n" + level_name
	return "修行羁绊：" + cultivation_type + " " + str(count) + "/" + ("满" if level >= 4 else str(next_count)) + "｜" + level_name + ("｜已归一" if level >= 4 else "｜" + short_goal)


func _build_route_visualizer() -> GridContainer:
	var grid: GridContainer = GridContainer.new()
	build_route_grid = grid
	grid.columns = 1
	grid.visible = false
	grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	grid.add_theme_constant_override("h_separation", 0)
	grid.add_theme_constant_override("v_separation", 4)
	build_route_buttons.clear()
	for cultivation_value in GameManager.CULTIVATION_TYPES:
		var sect_name: String = str(cultivation_value)
		var button: Button = Button.new()
		button.text = _sect_short_name(sect_name) + "\n0/" + str(GameManager.MAX_CULTIVATION_SET_COUNT)
		button.custom_minimum_size = Vector2(84, 32)
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		button.tooltip_text = "点击查看" + sect_name + "修行羁绊"
		button.add_theme_font_size_override("font_size", 12)
		button.pressed.connect(_on_build_route_pressed.bind(sect_name))
		_apply_build_route_button_style(button, sect_name, 0)
		grid.add_child(button)
		build_route_buttons[sect_name] = button
	return grid


func _update_build_route_visualizer(player: PlayerData) -> void:
	if build_route_buttons.is_empty():
		return
	var routes: Dictionary = GameManager.get_affix_build_routes(player)
	var locked_sect: String = str(player.final_attributes.get("cultivation_bond_type", "")) if player != null else ""
	var active_count: int = 0
	for cultivation_value in GameManager.CULTIVATION_TYPES:
		var sect_name: String = str(cultivation_value)
		if not build_route_buttons.has(sect_name):
			continue
		var button: Button = build_route_buttons[sect_name] as Button
		var route: Dictionary = routes.get(sect_name, {}) as Dictionary
		var count: int = int(route.get("count", 0))
		var active: bool = count > 0
		button.visible = active
		if not active:
			continue
		active_count += 1
		var level: int = int(route.get("level", 0))
		var next_count: int = int(route.get("next_count", 2))
		var next_text: String = "满" if level >= 4 else str(next_count)
		var prefix: String = "★" if locked_sect == sect_name else ""
		button.text = prefix + _sect_short_name(sect_name) + "\n" + str(count) + "/" + next_text
		_apply_build_route_button_style(button, sect_name, count)
	if build_route_grid != null:
		build_route_grid.visible = active_count > 0


func _build_route_next_count(total: int, technique_count: int) -> int:
	if total >= 4 or technique_count >= 4:
		return GameManager.MAX_CULTIVATION_SET_COUNT
	if total >= 3:
		return 4
	if total >= 2:
		return 3
	return 2


func _build_route_affix_summary(route: Dictionary) -> String:
	var affix_counts: Dictionary = route.get("affixes", {}) as Dictionary
	if affix_counts.is_empty():
		return ""
	var parts: Array[String] = []
	for affix_name in affix_counts:
		parts.append(str(affix_name) + str(int(affix_counts[affix_name])))
		if parts.size() >= 2:
			break
	return " " + " ".join(parts)


func _apply_build_route_button_style(button: Button, sect_name: String, _total: int) -> void:
	var border_color: Color = _sect_badge_color(sect_name)
	var fill_alpha: float = 0.70
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.17, fill_alpha)
	style.border_color = Color(border_color.r, border_color.g, border_color.b, 0.88)
	style.set_border_width_all(2)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 4
	style.content_margin_top = 3
	style.content_margin_right = 4
	style.content_margin_bottom = 3
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	button.add_theme_stylebox_override("pressed", style)
	button.add_theme_color_override("font_color", border_color)


func _on_build_route_pressed(sect_name: String) -> void:
	if build_info_dialog == null:
		build_info_dialog = AcceptDialog.new()
		add_child(build_info_dialog)
	var player: PlayerData = _get_my_player()
	build_info_dialog.title = "修行羁绊"
	build_info_dialog.dialog_text = GameManager.get_affix_guide_text(sect_name, player)
	build_info_dialog.min_size = Vector2i(640, 430)
	build_info_dialog.add_theme_font_size_override("font_size", 22)
	build_info_dialog.popup_centered(Vector2i(640, 430))


func _sect_short_name(sect_name: String) -> String:
	match sect_name:
		"万魂殿":
			return "万魂"
		"金刚寺":
			return "金刚"
		"天剑阁":
			return "天剑"
		"百花谷":
			return "百花"
		"丹霞山":
			return "丹霞"
		"阵宗":
			return "阵宗"
		"符箓门":
			return "符箓"
		"器府":
			return "器府"
		"鬼修":
			return "鬼修"
		"体修":
			return "体修"
		"剑修":
			return "剑修"
		"情修":
			return "情修"
		"丹修":
			return "丹修"
		"阵修":
			return "阵修"
		"符修":
			return "符修"
		"器修":
			return "器修"
		_:
			return sect_name


func _update_identity_labels(name_label: Label, sect_label: Label, resonance_label: Label, player: PlayerData, compact: bool) -> void:
	if player == null:
		return
	var name_font_size: int = 20 if compact else 24
	var badge_font_size: int = name_font_size
	name_label.visible = true
	name_label.text = player.player_name
	name_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	name_label.add_theme_font_size_override("font_size", name_font_size)
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.clip_text = false
	name_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	var identity_level: int = int(player.final_attributes.get("identity_level", 0))
	var identity_sect: String = str(player.final_attributes.get("identity_sect", ""))
	var show_identity: bool = identity_level > 0 and GameManager.SECT_TYPES.has(identity_sect)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT if show_identity else HORIZONTAL_ALIGNMENT_CENTER
	name_label.custom_minimum_size = Vector2(_text_min_width(player.player_name, name_font_size, 78.0 if compact else 88.0), 30 if compact else 34)
	sect_label.visible = show_identity
	if not show_identity:
		if resonance_label != null:
			resonance_label.visible = false
		return
	sect_label.text = _identity_badge_text(player, compact)
	sect_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var identity_color: Color = Color(GameManager.get_identity_color_hex(player)).lerp(Color("#f0c040"), 0.35)
	sect_label.add_theme_color_override("font_color", identity_color)
	sect_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	sect_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	sect_label.add_theme_font_size_override("font_size", badge_font_size)
	sect_label.clip_text = false
	sect_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	sect_label.custom_minimum_size = Vector2(_text_min_width(sect_label.text, badge_font_size, 92.0 if compact else 118.0), 34 if compact else 38)
	if resonance_label != null:
		resonance_label.visible = false


func _text_min_width(text: String, font_size: int, fallback: float) -> float:
	var char_count: int = maxi(1, text.length())
	return maxf(fallback, float(char_count) * float(font_size) + 22.0)


func _identity_badge_text(player: PlayerData, compact: bool) -> String:
	var sect_name: String = str(player.final_attributes.get("identity_sect", ""))
	var title: String = str(player.final_attributes.get("identity_title_short", ""))
	if not GameManager.SECT_TYPES.has(sect_name) or title == "":
		return ""
	var sect_text: String = _sect_short_name(sect_name) if compact else sect_name
	return sect_text + "·" + title


func _sect_badge_text(sect_name: String, _compact: bool = false) -> String:
	match sect_name:
		"万魂殿", "金刚寺", "天剑阁", "百花谷", "丹霞山", "阵宗", "符箓门", "器府":
			return sect_name
		"鬼修":
			return "鬼修"
		"体修":
			return "体修"
		"剑修":
			return "剑修"
		"情修":
			return "情修"
		"丹修":
			return "丹修"
		"阵修":
			return "阵修"
		"符修":
			return "符修"
		"器修":
			return "器修"
		_:
			return "【未定】"


func _sect_badge_color(sect_name: String) -> Color:
	match sect_name:
		"万魂殿":
			return Color("#c080e0")
		"金刚寺":
			return Color("#c04040")
		"天剑阁":
			return Color("#f0c040")
		"百花谷":
			return Color("#40c0a0")
		"丹霞山":
			return Color("#f08040")
		"阵宗":
			return Color("#6080d0")
		"符箓门":
			return Color("#80c080")
		"器府":
			return Color("#d0a060")
		"鬼修":
			return Color("#c080e0")
		"体修":
			return Color("#c04040")
		"剑修":
			return Color("#f0c040")
		"情修":
			return Color("#40c0a0")
		"丹修":
			return Color("#f08040")
		"阵修":
			return Color("#6080d0")
		"符修":
			return Color("#80c080")
		"器修":
			return Color("#d0a060")
		_:
			return Color("#8a8070")


func _resonance_suffix_text(level: int) -> String:
	match level:
		1:
			return "·初悟"
		2:
			return "·大成"
		3:
			return "·飞升"
		_:
			return ""


func _resonance_suffix_color(level: int) -> Color:
	match level:
		1:
			return Color("#d8d8e8")
		2:
			return Color("#f0c040")
		3:
			return Color("#ff80c0")
		_:
			return Color("#d8d8e8")


func _resonance_suffix_size(level: int, compact: bool) -> int:
	match level:
		1:
			return 13 if compact else 14
		2:
			return 15 if compact else 16
		3:
			return 17 if compact else 18
		_:
			return 14


func _restart_resonance_badge_effect(label: Label, level: int) -> void:
	if label == null:
		return
	var key: int = label.get_instance_id()
	if int(label.get_meta("effect_level", -1)) == level:
		return
	label.set_meta("effect_level", level)
	if badge_effect_tweens.has(key):
		var old_tween: Variant = badge_effect_tweens[key]
		if old_tween is Tween and (old_tween as Tween).is_valid():
			(old_tween as Tween).kill()
		badge_effect_tweens.erase(key)
	label.modulate = Color.WHITE
	label.scale = Vector2.ONE
	if level < 2:
		return
	var tween: Tween = create_tween()
	tween.set_loops()
	if level == 2:
		tween.tween_property(label, "modulate:a", 0.55, 0.8)
		tween.tween_property(label, "modulate:a", 1.0, 0.8)
	else:
		tween.tween_property(label, "modulate", Color("#ff80c0"), 0.35)
		tween.tween_property(label, "modulate", Color("#f0c040"), 0.35)
		tween.tween_property(label, "modulate", Color("#40c0a0"), 0.35)
	badge_effect_tweens[key] = tween


func _get_my_player() -> PlayerData:
	return GameManager.player_a if NetworkManager.is_host else GameManager.player_b


func _get_enemy_player() -> PlayerData:
	return GameManager.player_b if NetworkManager.is_host else GameManager.player_a


func _on_npc_dialogue_changed(line: String) -> void:
	if label_npc_dialogue == null:
		return
	label_npc_dialogue.visible = true
	label_npc_dialogue.text = GameManager.player_b.player_name + "：「" + line + "」"
	label_log.text = "日志：" + GameManager.player_b.player_name + "说：" + line


func _on_set_bonus_triggered(data: Dictionary) -> void:
	var title: String = str(data.get("title", "构筑觉醒"))
	_update_player_info()
	label_log.text = "日志：" + title
	_spawn_set_bonus_announcement(
		title,
		str(data.get("player_name", "")),
		Color(str(data.get("color", "#f0c040"))),
		float(data.get("duration", 2.0)),
		int(data.get("level", 1))
	)


func _spawn_set_bonus_announcement(title: String, player_name: String, color: Color, duration: float, level: int) -> void:
	if floating_layer == null:
		return
	var panel := PanelContainer.new()
	panel.z_index = 390
	var panel_width: float = _safe_overlay_width(680.0)
	panel.custom_minimum_size = Vector2(panel_width, 168.0)
	panel.size = panel.custom_minimum_size
	_apply_announcement_panel_style(panel, Color(0.05, 0.04, 0.08, 0.94), color)
	floating_layer.add_child(panel)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)

	var title_label := _make_label(title, 40 if level < 3 else 44, color, HORIZONTAL_ALIGNMENT_CENTER)
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	box.add_child(title_label)

	var line := "身份晋升"
	if player_name != "":
		line = player_name + "的" + line
	var line_label := _make_label(line, 24, Color("#e0d5b7"), HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(line_label)

	panel.global_position = _overlay_position(panel_width, 116.0)
	panel.scale = Vector2(0.86, 0.86)
	panel.modulate.a = 0.0

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "scale", Vector2.ONE, 0.20)
	tween.tween_property(panel, "modulate:a", 1.0, 0.20)
	if level >= 3:
		tween.parallel().tween_property(title_label, "modulate", Color("#f0c040"), 0.32)
		tween.chain().tween_property(title_label, "modulate", Color("#40c0a0"), 0.32)
		tween.chain().tween_property(title_label, "modulate", Color("#ff80c0"), 0.32)
	tween.chain().tween_interval(duration)
	tween.chain().tween_property(panel, "global_position", panel.global_position + Vector2(0.0, -70.0), 0.38)
	tween.parallel().tween_property(panel, "modulate:a", 0.0, 0.38)
	tween.tween_callback(panel.queue_free)


func _apply_announcement_panel_style(panel: PanelContainer, bg_color: Color, border_color: Color) -> void:
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.clip_contents = true
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(3)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 18
	style.content_margin_top = 14
	style.content_margin_right = 18
	style.content_margin_bottom = 14
	panel.add_theme_stylebox_override("panel", style)


func _format_int_value(value: Variant) -> String:
	return str(int(round(float(value))))


func _format_score(value: float) -> String:
	if is_equal_approx(value, round(value)):
		return str(int(round(value)))
	return "%0.1f" % value


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


func _choice_full_text(choice: String, card: Dictionary) -> String:
	if choice == "":
		return "未选择"
	if str(card.get("type", "")) == "灾厄":
		if choice == "抢":
			return "抢（躲开）"
		if choice == "让":
			return "让（承担）"
	if choice == "抢":
		return "抢（拿下这张）"
	if choice == "让":
		return "让（退让保全）"
	return choice


func _update_cultivation_bars(player: PlayerData) -> void:
	if bar_my_lingli == null or bar_my_hp == null:
		return

	var current_req: int = GameManager.get_current_stage_floor_req(player)
	var next_req: int = GameManager.get_next_breakthrough_req(player)
	var span: int = maxi(1, next_req - current_req)
	var progress_value: int = clampi(player.ling_li - current_req, 0, span)
	bar_my_lingli.max_value = span
	bar_my_lingli.value = progress_value
	label_my_realm_progress.text = GameManager.get_cultivation_stage_name(player) + "  灵力 " + str(player.ling_li) + "/" + str(next_req)

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
	var chance_suffix: String = ""
	if breakthrough_type == "minor" or breakthrough_type == "major":
		chance_suffix = " " + str(int(round(float(status.get("success_chance", 0.0)) * 100.0))) + "%"
	var blocked_state: bool = GameManager.current_state == GameManager.GameState.REST or GameManager.current_state == GameManager.GameState.AUCTION or GameManager.current_state == GameManager.GameState.TRIBULATION or GameManager.current_state == GameManager.GameState.BATTLE or GameManager.current_state == GameManager.GameState.DUEL or GameManager.current_state == GameManager.GameState.SECT_EVENT or GameManager.current_state == GameManager.GameState.ENDING
	if target_name == "":
		button_breakthrough.text = "圆满"
		button_breakthrough.disabled = true
		button_breakthrough.modulate = Color(0.55, 0.55, 0.55, 1.0)
		return

	if breakthrough_type == "minor":
		button_breakthrough.text = ("突破！" if can_breakthrough else "突破") + chance_suffix
	elif breakthrough_type == "duel":
		button_breakthrough.text = "争仙！" if can_breakthrough else "争仙"
	else:
		button_breakthrough.text = ("突破！" if can_breakthrough else "突破") + chance_suffix
	button_breakthrough.disabled = blocked_state
	button_breakthrough.modulate = Color("#f0c040") if can_breakthrough else Color(0.85, 0.85, 0.9, 1.0)


func _update_alchemy_button(player: PlayerData) -> void:
	if button_alchemy == null or player == null:
		return
	var status: Dictionary = GameManager.get_alchemy_status(player)
	var label: String = str(status.get("label", "炼丹"))
	var material_count: int = int(status.get("material_count", 0))
	var button_label: String = label.replace("炼", "") if label != "炼丹" else "炼丹"
	if not bool(status.get("can", false)) and material_count <= 0:
		button_label = "缺灵草"
	button_alchemy.text = button_label + "\n草 " + str(material_count)
	button_alchemy.disabled = not bool(status.get("can", false))
	button_alchemy.tooltip_text = "消耗灵草开炉炼丹：气感+机缘会放宽火候并提升成色。"
	button_alchemy.modulate = Color("#f0c040") if bool(status.get("can", false)) else Color(0.65, 0.65, 0.7, 1.0)


func _update_refining_button(player: PlayerData) -> void:
	if button_refining == null or player == null:
		return
	var status: Dictionary = GameManager.get_refining_status(player)
	var material_count: int = int(status.get("material_count", 0))
	var refine_label: String = "炼器"
	if not bool(status.get("can", false)):
		var reason: String = str(status.get("reason", ""))
		if reason == "先装备法宝":
			refine_label = "先法宝"
		elif material_count <= 0:
			refine_label = "缺矿材"
	button_refining.text = refine_label + "\n矿 " + str(material_count)
	button_refining.disabled = not bool(status.get("can", false))
	button_refining.tooltip_text = "消耗矿材开炉炼器：体魄+经商会放宽火候并提升成色。"
	button_refining.modulate = Color("#f0c040") if bool(status.get("can", false)) else Color(0.65, 0.65, 0.7, 1.0)


func _realm_ling_li_req(realm: String) -> int:
	return GameManager.get_realm_ling_li_req(realm)


func _estimate_player_max_hp(player: PlayerData) -> int:
	if player == null:
		return 1
	return maxi(player.qi_xue, GameManager.get_player_max_hp(player))


func _update_backpack_block_label(player: PlayerData) -> void:
	if label_backpack_block == null:
		return

	var pending: Dictionary = GameManager.get_pending_backpack_item(player.peer_id)
	if pending.is_empty():
		for kind in ["technique", "treasure", "companion", "material"]:
			var count: int = int(GameManager.get_backpack_counts(player).get(kind, 0))
			var limit: int = GameManager.get_backpack_kind_limit(kind)
			if count > limit:
				label_backpack_block.visible = true
				label_backpack_block.text = "背包超出上限：" + GameManager.get_backpack_counts_text(player) + "，请打开背包清理"
				return
		label_backpack_block.text = ""
		label_backpack_block.visible = false
		return

	label_backpack_block.visible = true
	label_backpack_block.text = "背包已满，先清理：" + _format_backpack_entry(pending)


func _format_ji_yuan(data: Dictionary) -> String:
	if data.is_empty():
		return "-"
	var fallback: String = str(data.get("type", ""))
	if _card_should_show_quality(data):
		fallback = _quality_display_name(str(data.get("quality", ""))) + "·" + fallback
	return str(data.get("desc", fallback))


func _format_calamity(data: Dictionary) -> String:
	if data.is_empty():
		return "-"
	var fallback: String = str(data.get("type", ""))
	return str(data.get("desc", fallback))


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
		"炼气级":
			return Color("#b0b0b0")
		"筑基级":
			return Color("#80c080")
		"金丹级":
			return Color("#6080d0")
		"元婴级":
			return Color("#c080e0")
		"化神级":
			return Color("#f0c040")
		"合体级":
			return Color("#ff80c0")
		_:
			return Color("#2a2a55")


func _quality_display_name(quality: String) -> String:
	return GameManager.quality_display_name(quality)


func _card_should_show_quality(card: Dictionary) -> bool:
	if bool(card.get("identity_special", false)):
		return false
	var effect_type: String = str(card.get("effect_type", ""))
	var kind: String = str(card.get("kind", card.get("card_kind", "")))
	return effect_type in ["technique", "treasure", "alchemy_material", "craft_material"] or kind in ["technique", "treasure", "material"]


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
	tween.chain().tween_callback(_finish_mark_card_settled.bind(panel.get_instance_id()))


func _finish_mark_card_settled(panel_id: int) -> void:
	var panel_object: Object = instance_from_id(panel_id)
	if panel_object is Node:
		(panel_object as Node).queue_free()
	lottery_panels.clear()
	lottery_cards.clear()


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
		if result_toast.has_meta("local_only"):
			result_toast.remove_meta("local_only")
		if result_toast.has_meta("local_log_message"):
			result_toast.remove_meta("local_log_message")
	_set_result_card_mode(false)
	if btn_continue_result != null:
		btn_continue_result.disabled = false
	if contest_button_row != null:
		contest_button_row.visible = false
	result_continue_sent = false
	latest_result_round_finished = false


func _show_pending_battle_reward_feedback() -> void:
	if result_toast == null:
		return
	var data: Dictionary = GameManager.pop_battle_reward_feedback()
	if data.is_empty():
		return
	_set_result_card_mode(true)
	var title: String = str(data.get("battle_reward_title", "斩妖得胜"))
	var detail: String = _format_battle_reward_detail(data)
	_apply_panel_style(result_toast, Color(0.18, 0.12, 0.03, 0.97))
	label_result_title.text = title
	label_result_title.add_theme_color_override("font_color", Color("#f0c040"))
	label_result_detail.text = detail
	if contest_button_row != null:
		contest_button_row.visible = false
	if btn_continue_result != null:
		btn_continue_result.text = "继续"
		btn_continue_result.visible = true
		btn_continue_result.disabled = false
	result_toast.visible = true
	result_toast.z_index = 240
	result_toast.mouse_filter = Control.MOUSE_FILTER_STOP
	result_toast.set_meta("local_only", true)
	result_toast.move_to_front()
	result_toast.modulate.a = 1.0
	result_toast.scale = Vector2(0.98, 0.98)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(result_toast, "modulate:a", 1.0, 0.16)
	tween.tween_property(result_toast, "scale", Vector2.ONE, 0.2)
	if str(data.get("message", "")).contains("以弱胜强") or detail.contains("以弱胜强"):
		_spawn_event_cut_in("以弱胜强", "收益翻倍！", Color("#f0c040"))
	else:
		_spawn_event_cut_in("斩妖得胜", "妖丹入袋，战利品已经分好。", Color("#f0c040"))
	label_log.text = "日志：斩妖结算已显示"


func _format_battle_reward_detail(data: Dictionary) -> String:
	var lines: Array[String] = []
	var enemy: Dictionary = data.get("enemy", {}) as Dictionary
	if not enemy.is_empty():
		lines.append("妖兽：" + str(enemy.get("name", "妖兽")) + " 已伏诛")
	var reward_lines: Array = data.get("reward_lines", []) as Array
	for reward_line in reward_lines:
		lines.append("· " + str(reward_line))
	if lines.is_empty():
		lines.append(str(data.get("message", "战斗结束")))
	return "\n".join(lines)
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


func _show_result_feedback(my_result: Dictionary, enemy_result: Dictionary, card: Dictionary, contest_result: Dictionary = {}) -> void:
	if result_toast == null:
		return
	_set_result_card_mode(true)

	var my_choice_raw: String = str(my_result.get("choice", ""))
	var enemy_choice_raw: String = str(enemy_result.get("choice", ""))
	var my_choice: String = _choice_display(my_choice_raw, card)
	var enemy_choice: String = _choice_display(enemy_choice_raw, card)
	var story_override: Dictionary = _result_story_override(my_result, enemy_result, card, my_choice, enemy_choice)
	var title: String = str(story_override.get("title", _build_result_title(my_result, card)))
	var detail: String = _build_result_detail(my_result, enemy_result, card, my_choice_raw, enemy_choice_raw, contest_result)
	var drama_kind: String = str(story_override.get("kind", _result_drama_kind(my_result, card)))
	var result_color: Color = _result_color(my_result, card)
	if story_override.has("color"):
		result_color = story_override["color"] as Color
	var panel_color: Color = Color(0.08, 0.08, 0.16, 0.96)
	if float(my_result.get("gain", 0.0)) > 0.0:
		panel_color = Color(0.18, 0.13, 0.03, 0.96)
	elif float(my_result.get("lose", 0.0)) > 0.0:
		panel_color = Color(0.18, 0.04, 0.05, 0.96)
	_apply_panel_style(result_toast, panel_color)
	label_result_title.text = title
	label_result_title.add_theme_color_override("font_color", result_color)
	label_result_detail.text = detail
	if contest_button_row != null:
		contest_button_row.visible = false
	btn_continue_result.text = "继续"
	btn_continue_result.visible = true
	btn_continue_result.disabled = false
	btn_continue_result.mouse_filter = Control.MOUSE_FILTER_STOP
	result_toast.visible = true
	result_toast.z_index = 240
	result_toast.mouse_filter = Control.MOUSE_FILTER_STOP
	result_toast.move_to_front()
	result_toast.modulate.a = 1.0
	result_toast.scale = Vector2(0.98, 0.98)

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(result_toast, "modulate:a", 1.0, 0.16)
	tween.tween_property(result_toast, "scale", Vector2.ONE, 0.2)
	_pulse_player_summary(result_color)
	_play_dramatic_result_effect(drama_kind, result_color)


func _on_continue_result_pressed() -> void:
	if result_continue_sent:
		return

	if result_toast != null and bool(result_toast.get_meta("local_only", false)):
		var local_log_message: String = str(result_toast.get_meta("local_log_message", "战利品已收入囊中"))
		result_toast.remove_meta("local_only")
		if result_toast.has_meta("local_log_message"):
			result_toast.remove_meta("local_log_message")
		_hide_result_toast()
		label_log.text = "日志：" + local_log_message
		return

	if GameManager.current_state == GameManager.GameState.REST:
		_on_rest_confirm_pressed()
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
	var message: String = _result_combined_message(result)
	if bool(card.get("identity_special", false)):
		if bool(result.get("sect_special_backlash", false)) or message.contains("天道反噬"):
			return "天道反噬！"
		match str(result.get("sect_special_role", "none")):
			"enhanced":
				return "宗门显化！"
			"half":
				return "退让承缘！"
			"weakened":
				return "强夺折损！"
			_:
				return "宗门专属"
	if message.contains("养成鬼魂"):
		return "吞魂养鬼！"
	if message.contains("本命飞剑升至"):
		return "飞剑破境！"
	if message.contains("本命飞剑"):
		return "飞剑认主！"
	if message.contains("炼体熔炉"):
		return "血肉成炉！"
	if _is_emotion_message(message):
		return "红尘入道！"
	if message.contains("争道胜出") or message.contains("争道落败") or message.contains("争道"):
		if gain > 0.0:
			return "争道胜出！"
		if lose > 0.0:
			return "争道受挫！"
		return "争道分胜！"
	if message.contains("功法《"):
		return "功法入命！"
	if message.contains("法宝【"):
		return "法宝认主！"
	if gain > 0.0:
		return "到手！"
	if lose > 0.0:
		return "遭灾！"
	if str(card.get("type", "")) == "机缘":
		return "机缘消散"
	return "无事发生"


func _result_story_override(my_result: Dictionary, enemy_result: Dictionary, card: Dictionary, my_choice: String, enemy_choice: String) -> Dictionary:
	if str(card.get("type", "")) != "灾厄":
		return {}

	var my_lose: float = float(my_result.get("lose", 0.0))
	var enemy_lose: float = float(enemy_result.get("lose", 0.0))
	if str(my_result.get("special", "")).contains("小灾临身") or str(enemy_result.get("special", "")).contains("小灾临身"):
		return {}
	var enemy_player: PlayerData = _get_enemy_player()
	var enemy_hp_text: String = ""
	var enemy_low_hp: bool = false
	if enemy_player != null:
		var enemy_max_hp: int = maxi(1, _estimate_player_max_hp(enemy_player))
		enemy_hp_text = "对方气血 " + str(enemy_player.qi_xue) + "/" + str(enemy_max_hp)
		enemy_low_hp = float(enemy_player.qi_xue) / float(enemy_max_hp) <= 0.25

	if my_lose > 0.0 and enemy_lose <= 0.0:
		return {
			"title": "替他挡劫！",
			"detail": "你：" + my_choice + "    对方：" + enemy_choice + "\n这一下落在你身上，对方躲过一劫",
			"kind": "save",
			"color": Color("#80c080"),
		}
	if enemy_lose > 0.0 and my_lose <= 0.0:
		if enemy_low_hp:
			return {
				"title": "差点害死他！",
				"detail": "你：" + my_choice + "    对方：" + enemy_choice + "\n劫气转到对方身上，" + enemy_hp_text,
				"kind": "near_death",
				"color": Color("#ff6060"),
			}
		return {
			"title": "移劫成功！",
			"detail": "你：" + my_choice + "    对方：" + enemy_choice + "\n你以法诀牵走劫气",
			"kind": "betray",
			"color": Color("#c04040"),
		}
	if my_lose > 0.0 and enemy_lose > 0.0:
		return {
			"title": "同舟扛灾！",
			"detail": "你：" + my_choice + "    对方：" + enemy_choice + "\n二人共同承担，至少谁都没被单独丢下",
			"kind": "together",
			"color": Color("#f0c040"),
		}
	return {}


func _build_result_detail(result: Dictionary, _enemy_result: Dictionary, card: Dictionary, my_choice: String, enemy_choice: String, _contest_result: Dictionary = {}) -> String:
	var lines: Array[String] = []
	lines.append("本张：" + _card_summary(card))
	var choice_line: String = _choice_pair_display(my_choice, enemy_choice, card, _contest_result)
	if choice_line != "":
		lines.append("选择：" + choice_line)
	lines.append("结果：" + _result_panel_line(result, card))
	return "\n".join(lines)


func _choice_pair_display(my_choice: String, enemy_choice: String, card: Dictionary, contest_result: Dictionary = {}) -> String:
	if not contest_result.is_empty():
		return ""
	if str(card.get("type", "")) == "灾厄":
		if my_choice == "抢" and enemy_choice == "让":
			return "你躲避｜对方承担"
		if my_choice == "让" and enemy_choice == "抢":
			return "你承担｜对方躲避"
		if my_choice == "抢" and enemy_choice == "抢":
			return "你躲避｜对方也躲避"
		if my_choice == "让" and enemy_choice == "让":
			return "你承担｜对方也承担"
	return "你 " + _choice_display(my_choice, card) + "｜对方 " + _choice_display(enemy_choice, card)


func _contest_result_plain_text(contest_result: Dictionary, card: Dictionary) -> String:
	var mode: String = str(contest_result.get("mode", "yield"))
	var message: String = str(contest_result.get("message", "争夺已分"))
	if str(card.get("type", "")) == "灾厄":
		if mode == "fight":
			return "转劫斗法：" + _shorten_result_message(message, 32)
		return "劫气压身：有人选择承担，少受一点"
	if mode == "fight":
		return "争道斗法：" + _shorten_result_message(message, 32)
	return "争道压境：有人选择放弃，避开损伤"


func _bargain_judgement_text(my_choice: String, enemy_choice: String, card: Dictionary, contest_result: Dictionary = {}) -> String:
	var card_type: String = str(card.get("type", "机缘"))
	if not contest_result.is_empty():
		var mode: String = str(contest_result.get("mode", "yield"))
		var message: String = str(contest_result.get("message", "争道已分"))
		if mode == "fight":
			return "双方先抢，强行争夺 → " + _shorten_result_message(message, 34)
		if card_type == "灾厄":
			return "双方先避，弱势方承劫 → 损失降低，并获得承劫感悟"
		return "双方先抢，弱势方放弃 → 止损并获得保底"
	if card_type == "机缘":
		if my_choice == "抢" and enemy_choice == "抢":
			return "双方都抢 → 这张牌破碎，谁也拿不到"
		if my_choice == "让" and enemy_choice == "让":
			if str(card.get("effect_type", "")) in ["technique", "treasure", "companion", "dan", "alchemy_material", "craft_material"]:
				return "双方都让 → 无法平分，机缘消散，各得灵石补偿"
			return "双方都让 → 天道酬和，各得一半，魅力高者多得"
		if my_choice == "抢" and enemy_choice == "让":
			return "你抢，对方让 → 你拿走全部效果"
		if my_choice == "让" and enemy_choice == "抢":
			return "你让，对方抢 → 对方拿走全部效果"
	else:
		if my_choice == "抢" and enemy_choice == "抢":
			return "双方都躲 → 灾厄反噬，双方各承担100%"
		if my_choice == "让" and enemy_choice == "让":
			return "双方都承担 → 同舟共济，双方各承担50%"
		if my_choice == "抢" and enemy_choice == "让":
			return "你躲避，对方承担 → 你0%，对方100%"
		if my_choice == "让" and enemy_choice == "抢":
			return "你承担，对方躲避 → 你100%，对方0%"
	return "按双方选择结算"


func _result_panel_line(result: Dictionary, card: Dictionary) -> String:
	var parts: Array[String] = []
	var gain: float = float(result.get("gain", 0.0))
	var lose: float = float(result.get("lose", 0.0))
	var message: String = _result_combined_message(result)
	message = _remove_result_filler_message(message)
	if str(card.get("type", "")) == "灾厄":
		return _calamity_result_panel_line(result, card, message)
	var primary_text: String = ""
	if gain > 0.0:
		if str(card.get("effect_type", "")) == "ling_li":
			var ling_li_detail: Dictionary = _format_ling_li_gain_result(gain, message)
			primary_text = str(ling_li_detail.get("primary", ""))
			message = str(ling_li_detail.get("message", message))
			parts.append(primary_text)
		else:
			primary_text = _effect_text(card, gain, true)
			parts.append("获得 " + primary_text)
	if lose > 0.0:
		primary_text = _effect_text(card, lose, false)
		parts.append("承受 " + primary_text)
	if parts.is_empty():
		return _empty_result_text(card, message)
	message = _remove_duplicate_primary_message(message, primary_text)
	message = _simplify_opportunity_extra_message(message)
	if message != "":
		parts.append(_shorten_result_message(message, 56))
	return "，".join(parts)


func _remove_result_filler_message(message: String) -> String:
	var kept: Array[String] = []
	for raw_part in message.split("；", false):
		var part: String = str(raw_part).strip_edges()
		if part == "" or part == "你拿下这张" or part == "他拿下这张":
			continue
		kept.append(part)
	return "；".join(kept)


func _calamity_result_panel_line(result: Dictionary, card: Dictionary, message: String) -> String:
	var parts: Array[String] = []
	var lose: float = float(result.get("lose", 0.0))
	var choice: String = str(result.get("choice", ""))
	var effect_type: String = str(card.get("effect_type", ""))
	var is_contest_fight: bool = message.contains("强行转劫") or message.contains("双方斗法")
	var primary_text: String = ""
	if lose > 0.0:
		primary_text = _calamity_primary_loss_text(card, lose, message)
		if message.contains("劫气入体"):
			parts.append("劫气入体，" + primary_text)
		elif choice == "抢" or is_contest_fight:
			parts.append("转劫失败，" + primary_text)
		elif choice == "让":
			parts.append("承劫入体，" + primary_text)
		else:
			parts.append("劫气入体，" + primary_text)
	else:
		if choice == "抢":
			primary_text = "避劫成功"
			parts.append("避劫成功")
		else:
			primary_text = "未受灾"
			parts.append(primary_text)
	message = _remove_duplicate_primary_message(message, primary_text)
	if effect_type in ["hp_percent_loss", "hp_damage"] and primary_text.begins_with("气血-"):
		var hp_loss: int = _extract_first_amount_after(primary_text, "气血-")
		if hp_loss > 0:
			message = _remove_first_message_prefix(message, "气血 -" + str(hp_loss))
			message = _remove_first_message_prefix(message, "气血-" + str(hp_loss))
	if primary_text == "避劫成功":
		message = _remove_duplicate_primary_message(message, "躲避成功")
	message = _simplify_calamity_extra_message(message)
	if message != "":
		parts.append(_shorten_result_message(message, 34))
	return "，".join(parts)


func _calamity_primary_loss_text(card: Dictionary, lose: float, message: String) -> String:
	var effect_type: String = str(card.get("effect_type", ""))
	if effect_type in ["hp_percent_loss", "hp_damage"]:
		var hp_loss: int = _extract_first_amount_after(message, "气血 -")
		if hp_loss <= 0:
			hp_loss = _extract_first_amount_after(message, "气血-")
		if hp_loss > 0:
			return "气血-" + str(hp_loss)
	return _effect_text(card, lose, false)


func _simplify_calamity_extra_message(message: String) -> String:
	var extras: Array[String] = []
	for raw_part in message.split("；", false):
		var part: String = str(raw_part).strip_edges()
		if part == "":
			continue
		if part in ["避劫成功", "躲避成功", "未受灾", "劫气入体，运功承受"]:
			continue
		if part.contains("修为 +"):
			var amount: int = _extract_first_amount_after(part, "修为 +")
			if amount > 0:
				extras.append("承劫感悟：修为+" + str(amount))
		elif part.contains("气血 +"):
			var heal: int = _extract_first_amount_after(part, "气血 +")
			if heal > 0:
				extras.append("气血+" + str(heal))
		elif part.contains("气血 -"):
			var hurt: int = _extract_first_amount_after(part, "气血 -")
			if hurt > 0:
				extras.append("气血-" + str(hurt))
		elif _looks_like_companion_bond_story(part):
			extras.append(_compact_companion_bond_story(part))
		elif part.contains("同伴羁绊 +") or part.contains("羁绊 +"):
			var bond_prefix: String = "同伴羁绊 +" if part.contains("同伴羁绊 +") else "羁绊 +"
			var bond: int = _extract_first_amount_after(part, bond_prefix)
			if bond > 0:
				extras.append("同伴情义加深")
		elif part.contains("羁绊 -"):
			var bond_loss: int = _extract_first_amount_after(part, "羁绊 -")
			if bond_loss > 0:
				extras.append("同伴略有疏离")
		elif part.contains("伤害减轻"):
			extras.append(part)
		elif part.contains("胜出") or part.contains("落败") or part.contains("斗法"):
			continue
		else:
			extras.append(part)
	return "，".join(extras)


func _simplify_opportunity_extra_message(message: String) -> String:
	var extras: Array[String] = []
	for raw_part in message.split("；", false):
		var part: String = str(raw_part).strip_edges()
		if part == "":
			continue
		if part.contains("鬼修构筑："):
			var amount: int = _extract_first_amount_after(part, "鬼魂+")
			extras.append("鬼修：鬼魂+" + str(amount) + "（助战/护魂）" if amount > 0 else part)
		elif part.contains("役鬼吞缘"):
			var ghost_amount: int = _extract_first_amount_after(part, "鬼魂+")
			extras.append("鬼修：鬼魂+" + str(ghost_amount) + "（助战/护魂）" if ghost_amount > 0 else "鬼修构筑增强")
		elif part.contains("情修构筑："):
			var heart_amount: int = _extract_first_amount_after(part, "护心+")
			extras.append("情修：护心+" + str(heart_amount) + "（抵伤）" if heart_amount > 0 else part)
		elif part.contains("红尘护心"):
			var old_heart_amount: int = _extract_first_amount_after(part, "红尘护心+")
			extras.append("情修：护心+" + str(old_heart_amount) + "（抵伤）" if old_heart_amount > 0 else "情修护心增强")
		elif part.contains("丹修构筑："):
			extras.append(part.replace("丹修构筑：", "丹修："))
		elif part.contains("丹炉蓄火"):
			var reserve: int = _extract_first_amount_after(part, "丹炉蓄火+")
			extras.append("丹修：丹息储量" + str(reserve) + "（濒危续命）" if reserve > 0 else "丹修丹息增强")
		elif part.contains("万魂殿夺机缘"):
			var ling_li: int = _extract_first_amount_after(part, "灵力 +")
			extras.append("宗门：灵力+" + str(ling_li) if ling_li > 0 else part)
		elif _looks_like_companion_bond_story(part):
			extras.append(_compact_companion_bond_story(part))
		elif part.contains("功法《"):
			extras.append(part)
		else:
			extras.append(part)
	return "，".join(extras)


func _looks_like_companion_bond_story(part: String) -> bool:
	return part.contains("·") and (part.contains(" +") or part.contains(" -")) and (part.contains("萍水") or part.contains("同袍") or part.contains("知己") or part.contains("生死契") or part.contains("萍水同行") or part.contains("同道相契") or part.contains("莫逆知己") or part.contains("生死之交"))


func _compact_companion_bond_story(part: String) -> String:
	var name_source: String = str(part.split("（", false)[0]).strip_edges()
	if name_source.contains(" +"):
		name_source = str(name_source.split(" +", false)[0]).strip_edges()
		if name_source.contains("·"):
			name_source = str(name_source.split("·", false)[0]).strip_edges()
		return name_source + "情义加深"
	if name_source.contains(" -"):
		name_source = str(name_source.split(" -", false)[0]).strip_edges()
		if name_source.contains("·"):
			name_source = str(name_source.split("·", false)[0]).strip_edges()
		return name_source + "略有疏离"
	return name_source


func _format_ling_li_gain_result(base_gain: float, message: String) -> Dictionary:
	var base_amount: int = int(round(base_gain))
	var absorbed_amount: int = _extract_first_amount_after(message, "灵力 +")
	if absorbed_amount <= 0:
		absorbed_amount = base_amount
	var primary: String = "经过你的刻苦修炼最终吸收+" + str(absorbed_amount)
	if message != "":
		message = _remove_first_message_prefix(message, "灵力 +" + str(absorbed_amount))
	return {
		"primary": primary,
		"message": message,
	}


func _extract_first_amount_after(text: String, marker: String) -> int:
	var start: int = text.find(marker)
	if start < 0:
		return -1
	start += marker.length()
	var digits: String = ""
	for i in range(start, text.length()):
		var ch: String = text.substr(i, 1)
		var code: int = ch.unicode_at(0)
		if code < 48 or code > 57:
			break
		digits += ch
	if digits == "":
		return -1
	return int(digits)


func _remove_first_message_prefix(message: String, prefix: String) -> String:
	if message == prefix:
		return ""
	if message.begins_with(prefix + "；"):
		return message.substr(prefix.length() + 1)
	if message.begins_with(prefix + "，"):
		return message.substr(prefix.length() + 1)
	return message


func _remove_duplicate_primary_message(message: String, primary_text: String) -> String:
	if message == "" or primary_text == "":
		return message
	if message == primary_text:
		return ""
	if message.begins_with(primary_text + "；"):
		return message.substr(primary_text.length() + 1)
	return message


func _empty_result_text(card: Dictionary, message: String) -> String:
	var effect_type: String = str(card.get("effect_type", ""))
	if message.contains("机缘消散"):
		match effect_type:
			"companion":
				return "伙伴离去，无人结识"
			"technique":
				return "功法失散，无人获得"
			"treasure":
				return "法宝遁走，无人获得"
			"dan":
				return "丹药毁去，无人获得"
			"auction":
				return "坊市收摊，无人入手"
			_:
				return "机缘消散，无人获得"
	if message != "":
		return _shorten_result_message(message, 44)
	if str(card.get("type", "")) == "灾厄":
		return "劫气散去，无人受损"
	return "无事发生"


func _card_summary(card: Dictionary) -> String:
	if bool(card.get("identity_special", false)):
		return _shorten_result_message(str(card.get("identity_sect", "宗门")) + " · 宗门专属卡", 30)
	var quality: String = str(card.get("quality", "炼气级"))
	var quality_text: String = _quality_display_name(quality)
	var effect_name: String = str(card.get("type", card.get("effect_type", "")))
	if card.has("desc"):
		effect_name = str(card.get("desc", effect_name))
	effect_name = _clean_card_display_text(effect_name)
	if effect_name == "":
		effect_name = _effect_text(card, float(card.get("effect_value", 0.0)), str(card.get("type", "")) == "机缘")
	if _card_should_show_quality(card) and not effect_name.begins_with(quality_text):
		effect_name = quality_text + " · " + effect_name
	return _shorten_result_message(effect_name, 30)


func _clean_card_display_text(text: String) -> String:
	var cleaned: String = text.strip_edges()
	for quality in ["炼气级", "筑基级", "金丹级", "元婴级", "化神级", "合体级"]:
		cleaned = cleaned.replace(quality + "机缘：", quality + " · ")
		cleaned = cleaned.replace(quality + "灾厄：", quality + " · ")
		cleaned = cleaned.replace(quality, _quality_display_name(quality))
	cleaned = cleaned.replace("机缘：", "")
	cleaned = cleaned.replace("灾厄：", "")
	cleaned = cleaned.replace("机缘", "")
	cleaned = cleaned.replace("灾厄", "")
	return cleaned.strip_edges()


func _is_build_related_card(card: Dictionary) -> bool:
	var effect_type: String = str(card.get("effect_type", ""))
	return effect_type in ["technique", "treasure", "companion", "alchemy_material", "craft_material", "adventure"]


func _result_combined_message(result: Dictionary) -> String:
	var parts: Array[String] = []
	for key in ["gain_message", "lose_message", "special"]:
		var value: String = str(result.get(key, ""))
		if value != "":
			parts.append(value)
	return "；".join(parts)


func _is_emotion_message(message: String) -> bool:
	return message.contains("情修") or message.contains("红尘") or message.contains("合欢") or message.contains("同心") or message.contains("桃花") or message.contains("情丝") or message.contains("三生") or message.contains("欲海")


func _shorten_result_message(message: String, max_chars: int) -> String:
	if message.length() <= max_chars:
		return message
	return message.substr(0, max_chars - 1) + "…"


func _result_drama_kind(result: Dictionary, card: Dictionary) -> String:
	var message: String = _result_combined_message(result)
	if bool(card.get("identity_special", false)):
		return "sect_special_backlash" if bool(result.get("sect_special_backlash", false)) else "sect_special"
	if message.contains("养成鬼魂"):
		return "ghost"
	if message.contains("本命飞剑"):
		return "sword"
	if message.contains("炼体熔炉"):
		return "body"
	if _is_emotion_message(message):
		return "emotion"
	if message.contains("争道"):
		return "contest"
	if message.contains("功法《") or message.contains("法宝【"):
		return "build"
	if float(result.get("lose", 0.0)) > 0.0 or str(card.get("type", "")) == "灾厄":
		return "calamity"
	return "normal"


func _play_dramatic_result_effect(kind: String, color: Color) -> void:
	match kind:
		"save":
			_flash_rainbow()
			UIEffects.screen_shake(self, 3.5, 0.18)
			_spawn_event_cut_in("救他一命", "这道劫，你替他挡了。", Color("#80c080"))
		"betray":
			_flash_edges()
			UIEffects.screen_shake(self, 5.0, 0.22)
			_spawn_event_cut_in("移劫成功", "你以法诀牵走这一缕劫气。", Color("#c04040"))
		"near_death":
			_flash_edges()
			UIEffects.screen_shake(self, 8.0, 0.32)
			_spawn_event_cut_in("命悬一线", "差一点，他就死在你手里。", Color("#ff6060"))
		"together":
			_flash_rainbow()
			_spawn_event_cut_in("同舟扛灾", "这一劫，两个人一起咽下。", Color("#f0c040"))
		"ghost":
			_flash_edges()
			UIEffects.screen_shake(self, 5.0, 0.22)
			_spawn_event_cut_in("阴魂入幡", "旧友入魂幡，从此替你杀人。", Color("#c080e0"))
		"sword":
			_flash_rainbow()
			UIEffects.screen_shake(self, 4.0, 0.18)
			_spawn_event_cut_in("剑鸣三尺", "飞剑认主，这一剑会越养越凶。", Color("#f0c040"))
		"body":
			_flash_rainbow()
			UIEffects.screen_shake(self, 4.5, 0.2)
			_spawn_event_cut_in("筋骨轰鸣", "血肉成炉，硬扛也是杀招。", Color("#f0c040"))
		"emotion":
			_flash_rainbow()
			UIEffects.screen_shake(self, 4.0, 0.18)
			_spawn_event_cut_in("红尘入道", "情债也是道债，欠下就会生根。", Color("#ff80c0"))
		"contest":
			UIEffects.screen_shake(self, 6.0, 0.24)
			_spawn_event_cut_in("大道相争", "退一步止损，进一步见血。", color)
		"sect_special":
			_flash_rainbow()
			UIEffects.screen_shake(self, 4.0, 0.18)
			_spawn_event_cut_in("宗门专属", "宗门印记显化，双方都看得分明。", color)
		"sect_special_backlash":
			_flash_edges()
			UIEffects.screen_shake(self, 7.0, 0.26)
			_spawn_event_cut_in("天道反噬", "宗门专属卡毁去，只余削弱灵机。", color)
		"build":
			_flash_rainbow()
			_spawn_event_cut_in("道基成形", "这一张，开始像一套牌了。", color)
		"calamity":
			_flash_edges()


func _spawn_center_banner(text: String, color: Color) -> void:
	if floating_layer == null:
		return
	var label := Label.new()
	label.text = text
	label.z_index = 360
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 46)
	label.add_theme_color_override("font_color", color)
	var label_width: float = _safe_overlay_width(520.0)
	label.custom_minimum_size = Vector2(label_width, 70.0)
	label.size = label.custom_minimum_size
	floating_layer.add_child(label)
	label.global_position = _overlay_position(label_width, 130.0)
	label.scale = Vector2(0.86, 0.86)
	label.modulate.a = 0.0

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "scale", Vector2.ONE, 0.16)
	tween.tween_property(label, "modulate:a", 1.0, 0.16)
	tween.chain().tween_interval(1.6)
	tween.chain().tween_property(label, "global_position", label.global_position + Vector2(0.0, -42.0), 0.55)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.55)
	tween.tween_callback(label.queue_free)


func _spawn_event_cut_in(title: String, line: String, color: Color) -> void:
	if floating_layer == null:
		return

	var panel := PanelContainer.new()
	panel.z_index = 370
	var panel_width: float = _safe_overlay_width(640.0)
	panel.custom_minimum_size = Vector2(panel_width, 132.0)
	panel.size = panel.custom_minimum_size
	_apply_panel_style(panel, Color(0.05, 0.04, 0.08, 0.92))
	floating_layer.add_child(panel)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)

	var title_label := Label.new()
	title_label.text = title
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 52)
	title_label.add_theme_color_override("font_color", color)
	box.add_child(title_label)

	var line_label := Label.new()
	line_label.text = line
	line_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	line_label.add_theme_font_size_override("font_size", 25)
	line_label.add_theme_color_override("font_color", Color("#e0d5b7"))
	box.add_child(line_label)

	panel.global_position = _overlay_position(panel_width, 160.0)
	panel.scale = Vector2(0.9, 0.9)
	panel.modulate.a = 0.0

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "scale", Vector2.ONE, 0.18)
	tween.tween_property(panel, "modulate:a", 1.0, 0.18)
	tween.chain().tween_interval(2.25)
	tween.chain().tween_property(panel, "global_position", panel.global_position + Vector2(0.0, -54.0), 0.55)
	tween.parallel().tween_property(panel, "modulate:a", 0.0, 0.55)
	tween.tween_callback(panel.queue_free)


func _effect_text(card: Dictionary, value: float, is_gain: bool) -> String:
	var effect_type: String = str(card.get("effect_type", ""))
	var amount: int = int(round(value))
	match effect_type:
		"sect_special":
			return str(card.get("identity_sect", "宗门")) + "宗门专属卡"
		"ling_li":
			return "灵力 +" + str(amount)
		"heal_percent":
			return "气血回复 " + str(amount) + "%"
		"ling_shi":
			return "灵石 +" + str(amount)
		"stat_up":
			return str(card.get("stat", "属性")) + " +1"
		"shou_yuan":
			return "寿元 +" + str(maxi(1, amount))
		"technique":
			return "功法入手"
		"treasure":
			return "法宝入手"
		"dan":
			return "丹药入手"
		"alchemy_material":
			return "灵草入手"
		"craft_material":
			return "矿材入手"
		"companion":
			return "伙伴同行"
		"auction":
			return "进入坊市"
		"adventure":
			return "秘境探索"
		"body_tempering":
			return "炼体淬骨"
		"sword_tempering":
			return "剑冢悟剑"
		"ghost_altar":
			return "招魂养鬼"
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
				return _clean_card_display_text(str(card.get("desc", "获得效果"))) + " +" + str(amount)
			return _clean_card_display_text(str(card.get("desc", "承受负面"))) + " -" + str(amount)


func _result_color(result: Dictionary, card: Dictionary) -> Color:
	if bool(card.get("identity_special", false)):
		return _special_card_sect_color(card)
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
	tween.tween_property(label, "global_position", label.global_position + Vector2(0.0, -72.0), 1.45)
	tween.tween_property(label, "modulate:a", 0.0, 1.45)
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
			names.append(str(companion.get("name", "未知")) + "·" + GameManager.get_companion_sect(companion) + " " + str(int(companion.get("bond", 0))) + "/" + str(GameManager.get_companion_bond_max(companion)))
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
			var bond_text: String = str(int(companion.get("bond", 0))) + "/" + str(GameManager.get_companion_bond_max(companion))
			names.append(str(companion.get("name", "未知伙伴")) + "·" + GameManager.get_companion_sect(companion) + "：" + str(companion.get("effect_desc", "无加成")) + "（羁绊" + bond_text + "）")
		else:
			names.append(str(item))
	return "，".join(names)


func _update_treasure_list(player: PlayerData) -> void:
	treasure_list.clear()
	for treasure in player.treasures:
		if not treasure is Dictionary:
			continue
		var treasure_data: Dictionary = treasure
		var threshold: int = int(treasure_data.get("awaken_threshold", treasure_data.get("growth_max", 0)))
		var growth_text: String = str(treasure_data.get("growth_icon", "道")) + str(int(treasure_data.get("growth_value", 0))) + "/" + str(threshold)
		var awaken_text: String = "已觉醒" if int(treasure_data.get("awakening_level", 0)) > 0 else "未觉醒"
		var text := str(treasure_data.get("name", "未知法宝")) + "（攻+" + str(int(treasure_data.get("battle_damage", 0))) + "｜" + str(treasure_data.get("attack_effect", "特效")) + "｜" + growth_text + "｜" + awaken_text + "）"
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


func _on_backpack_button_pressed() -> void:
	var player: PlayerData = _get_my_player()
	if player == null or backpack_overlay_layer == null:
		return
	_update_backpack_overlay_list(player)
	backpack_overlay_layer.visible = true
	backpack_overlay_layer.move_to_front()


func _hide_backpack_overlay() -> void:
	if backpack_overlay_layer != null:
		backpack_overlay_layer.visible = false
	backpack_overlay_selected_metadata.clear()


func _on_backpack_overlay_dim_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			_hide_backpack_overlay()
			accept_event()
	elif event is InputEventScreenTouch:
		var touch_event: InputEventScreenTouch = event as InputEventScreenTouch
		if touch_event.pressed:
			_hide_backpack_overlay()
			accept_event()


func _update_backpack_overlay_list(player: PlayerData) -> void:
	if backpack_overlay_list == null or player == null:
		return
	backpack_overlay_selected_metadata.clear()
	backpack_overlay_list.clear()
	if label_backpack_overlay_title != null:
		label_backpack_overlay_title.text = "背包 " + str(player.backpack.size()) + "/" + str(player.backpack_capacity) + "｜灵石 " + _format_int_value(player.ling_shi)

	if label_backpack_overlay_title != null:
		label_backpack_overlay_title.text = "背包｜" + GameManager.get_backpack_counts_text(player) + "｜灵石 " + _format_int_value(player.ling_shi)

	var added_count: int = 0
	var pending: Dictionary = GameManager.get_pending_backpack_item(player.peer_id)
	if not pending.is_empty():
		backpack_overlay_list.add_item("待处理 · " + _format_backpack_entry(pending), _make_backpack_row_icon(pending, true))
		var pending_index: int = backpack_overlay_list.get_item_count() - 1
		backpack_overlay_list.set_item_custom_fg_color(pending_index, Color("#c04040"))
		backpack_overlay_list.set_item_metadata(pending_index, {"index": -1, "entry": pending, "pending": true})
		added_count += 1

	for i in range(player.backpack.size()):
		var entry: Dictionary = player.backpack[i] as Dictionary
		var text: String = str(i + 1) + ". " + _format_backpack_entry(entry) + _format_backpack_affix_tail(entry)
		backpack_overlay_list.add_item(text, _make_backpack_row_icon(entry, false))
		var item_index: int = backpack_overlay_list.get_item_count() - 1
		backpack_overlay_list.set_item_metadata(item_index, {"index": i, "entry": entry, "pending": false})
		added_count += 1

	if added_count == 0:
		backpack_overlay_list.add_item("背包空空", _make_backpack_empty_icon())
		var empty_index: int = backpack_overlay_list.get_item_count() - 1
		backpack_overlay_list.set_item_disabled(empty_index, true)
		_clear_backpack_overlay_selection("背包里还没有牌。抽到功法、法宝、伙伴、材料后会先进这里。")
	else:
		_clear_backpack_overlay_selection("点选一张牌，然后选择装备、倒卖或丢弃。")


func _on_backpack_overlay_list_gui_input(event: InputEvent) -> void:
	if backpack_overlay_list == null:
		return
	if event is InputEventScreenTouch:
		var touch_event: InputEventScreenTouch = event as InputEventScreenTouch
		if touch_event.pressed:
			_select_backpack_overlay_item_at(touch_event.position)
	elif event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			_select_backpack_overlay_item_at(mouse_event.position)


func _select_backpack_overlay_item_at(position_in_list: Vector2) -> void:
	if backpack_overlay_list == null:
		return
	var item_index: int = backpack_overlay_list.get_item_at_position(position_in_list, true)
	if item_index < 0:
		item_index = backpack_overlay_list.get_item_at_position(position_in_list, false)
	if item_index < 0 or item_index >= backpack_overlay_list.get_item_count():
		return
	backpack_overlay_list.select(item_index)
	_on_backpack_overlay_item_selected(item_index)
	backpack_overlay_list.accept_event()


func _make_backpack_row_icon(entry: Dictionary, pending: bool) -> Texture2D:
	var data: Dictionary = entry.get("data", {}) as Dictionary
	var quality: String = str(data.get("quality", ""))
	var color: Color = _quality_color(quality)
	if quality == "":
		color = _backpack_kind_color(str(entry.get("kind", "")))
	if pending:
		color = Color("#c04040")
	return _make_backpack_icon_texture(color)


func _make_backpack_empty_icon() -> Texture2D:
	return _make_backpack_icon_texture(Color("#3a3a6e"))


func _backpack_kind_color(kind: String) -> Color:
	match kind:
		"technique":
			return Color("#6080d0")
		"treasure":
			return Color("#f0c040")
		"companion":
			return Color("#c080e0")
		"material":
			return Color("#80c080")
		_:
			return Color("#8a8070")


func _make_backpack_icon_texture(color: Color) -> Texture2D:
	var image: Image = Image.create(54, 54, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.0, 0.0, 0.0, 0.0))
	for y in range(5, 49):
		for x in range(5, 49):
			var edge: bool = x <= 8 or x >= 45 or y <= 8 or y >= 45
			image.set_pixel(x, y, Color(color.r, color.g, color.b, 0.92 if edge else 0.32))
	return ImageTexture.create_from_image(image)


func _format_backpack_affix_tail(entry: Dictionary) -> String:
	var kind: String = str(entry.get("kind", ""))
	if not (kind in ["technique", "treasure", "companion"]):
		return ""
	var data: Dictionary = entry.get("data", {}) as Dictionary
	var affix_tags: String = _short_affix_tags(data)
	if affix_tags == "":
		return ""
	return "｜词条 " + affix_tags


func _clear_backpack_overlay_selection(message: String) -> void:
	backpack_overlay_selected_metadata.clear()
	if label_backpack_overlay_detail != null:
		label_backpack_overlay_detail.text = message
	_rebuild_backpack_action_buttons({})
	if button_backpack_overlay_sell != null:
		button_backpack_overlay_sell.visible = true
		button_backpack_overlay_sell.disabled = true
		button_backpack_overlay_sell.text = "倒卖"
	if button_backpack_overlay_discard != null:
		button_backpack_overlay_discard.disabled = true
		button_backpack_overlay_discard.text = "丢弃"


func _on_backpack_overlay_item_selected(index: int) -> void:
	if backpack_overlay_list == null:
		return
	var metadata: Dictionary = backpack_overlay_list.get_item_metadata(index) as Dictionary
	if metadata.is_empty():
		_clear_backpack_overlay_selection("点选一张牌查看效果。")
		return
	backpack_overlay_selected_metadata = metadata.duplicate(true)
	var entry: Dictionary = metadata.get("entry", {}) as Dictionary
	var source: String = "pending" if bool(metadata.get("pending", false)) else "backpack"
	if label_backpack_overlay_detail != null:
		label_backpack_overlay_detail.text = _describe_inventory_entry(entry, source, int(metadata.get("index", -1)))
	_rebuild_backpack_action_buttons(metadata)
	if button_backpack_overlay_sell != null:
		button_backpack_overlay_sell.visible = true
		var can_sell: bool = _can_sell_backpack_overlay_entry(metadata)
		button_backpack_overlay_sell.disabled = not can_sell
		button_backpack_overlay_sell.text = "倒卖 +" + str(_estimate_sell_value(entry)) if can_sell else "不能倒卖"
	if button_backpack_overlay_discard != null:
		button_backpack_overlay_discard.disabled = false
		button_backpack_overlay_discard.text = "放弃新牌" if bool(metadata.get("pending", false)) else "丢弃"


func _rebuild_backpack_action_buttons(metadata: Dictionary) -> void:
	if backpack_action_grid == null:
		return
	for child in backpack_action_grid.get_children():
		child.queue_free()
	if metadata.is_empty():
		return
	var entry: Dictionary = metadata.get("entry", {}) as Dictionary
	var kind: String = str(entry.get("kind", ""))
	match kind:
		"technique":
			_add_backpack_target_button("装备功法", "technique", -1)
			for i in range(GameManager.MAX_EQUIPPED_TECHNIQUES):
				_add_backpack_target_button("功法" + str(i + 1), "technique", i)
		"treasure":
			_add_backpack_target_button("装备法宝", "treasure", -1)
		"companion":
			_add_backpack_target_button("同伴入队", "companion", -1)
			for i in range(GameManager.MAX_COMPANIONS):
				_add_backpack_target_button("同伴" + str(i + 1), "companion", i)


func _add_backpack_target_button(text: String, target_type: String, target_index: int) -> void:
	var button: Button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(1, 64)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 24)
	button.pressed.connect(_on_backpack_overlay_equip_pressed.bind(target_type, target_index))
	backpack_action_grid.add_child(button)


func _can_sell_backpack_overlay_entry(metadata: Dictionary) -> bool:
	var entry: Dictionary = metadata.get("entry", {}) as Dictionary
	var kind: String = str(entry.get("kind", ""))
	return kind in ["technique", "treasure", "companion", "material"]


func _is_auction_active() -> bool:
	return false


func _estimate_sell_value(entry: Dictionary) -> int:
	var player: PlayerData = _get_my_player()
	return GameManager.get_market_sell_value_for_entry(player, entry)


func _on_backpack_overlay_equip_pressed(target_type: String, target_index: int) -> void:
	if backpack_overlay_selected_metadata.is_empty():
		return
	var is_pending: bool = bool(backpack_overlay_selected_metadata.get("pending", false))
	var source: String = "pending" if is_pending else "backpack"
	var action: String = "equip_pending" if is_pending else "equip"
	var entry: Dictionary = backpack_overlay_selected_metadata.get("entry", {}) as Dictionary
	var kind: String = str(entry.get("kind", ""))
	_send_backpack_action(action, int(backpack_overlay_selected_metadata.get("index", -1)), source, kind, target_type, target_index)
	if label_backpack_overlay_detail != null:
		label_backpack_overlay_detail.text = "正在整理背包..."


func _on_backpack_overlay_discard_pressed() -> void:
	if backpack_overlay_selected_metadata.is_empty():
		return
	var is_pending: bool = bool(backpack_overlay_selected_metadata.get("pending", false))
	var action: String = "discard_pending" if is_pending else "discard"
	var entry: Dictionary = backpack_overlay_selected_metadata.get("entry", {}) as Dictionary
	_send_backpack_action(action, int(backpack_overlay_selected_metadata.get("index", -1)), "pending" if is_pending else "backpack", str(entry.get("kind", "")))
	if label_backpack_overlay_detail != null:
		label_backpack_overlay_detail.text = "正在整理背包..."


func _on_backpack_overlay_sell_pressed() -> void:
	if backpack_overlay_selected_metadata.is_empty():
		return
	var is_pending: bool = bool(backpack_overlay_selected_metadata.get("pending", false))
	var action: String = "sell_pending" if is_pending else "sell"
	var entry: Dictionary = backpack_overlay_selected_metadata.get("entry", {}) as Dictionary
	_send_backpack_action(action, int(backpack_overlay_selected_metadata.get("index", -1)), "pending" if is_pending else "backpack", str(entry.get("kind", "")))
	if label_backpack_overlay_detail != null:
		label_backpack_overlay_detail.text = "正在倒卖换灵石..."


func _update_drag_inventory(player: PlayerData) -> void:
	for i in range(technique_slot_nodes.size()):
		var slot: InventoryDropSlot = technique_slot_nodes[i]
		if i < player.techniques.size():
			var technique: Dictionary = player.techniques[i] as Dictionary
			var technique_line: String = str(technique.get("technique_realm", "初窥"))
			var technique_tags: String = _short_affix_tags(technique)
			if technique_tags != "":
				technique_line += "｜" + technique_tags
			slot.set_card(_make_inventory_card("功法\n" + str(technique.get("name", "未知")) + "\n" + technique_line, "equipped", i, "technique", {"kind": "technique", "data": technique}, Color("#6080d0")))
		else:
			slot.set_card(null)

	if treasure_slot_node != null:
		if player.treasures.size() > 0:
			var treasure: Dictionary = player.treasures[0] as Dictionary
			var treasure_growth: String = "\n" + str(treasure.get("growth_icon", "道")) + str(int(treasure.get("growth_value", 0))) if treasure.has("growth_value") else ""
			var treasure_tags: String = _short_affix_tags(treasure)
			if treasure_tags != "":
				treasure_growth += "｜" + treasure_tags
			var treasure_card: InventoryDragCard = _make_inventory_card("法宝\n" + str(treasure.get("name", "未知")) + treasure_growth, "equipped", 0, "treasure", {"kind": "treasure", "data": treasure}, Color("#f0c040"))
			treasure_slot_node.set_card(treasure_card)
			_maybe_animate_treasure_card(treasure_card, "equipped", 0, {"kind": "treasure", "data": treasure})
		else:
			treasure_slot_node.set_card(null)

	for i in range(companion_slot_nodes.size()):
		var companion_slot: InventoryDropSlot = companion_slot_nodes[i]
		if i < player.companions.size():
			var companion: Dictionary = player.companions[i] as Dictionary
			var bond_value: int = int(companion.get("bond", 0))
			var bond_stage: String = GameManager.get_companion_bond_stage_text_for_data(companion)
			var companion_sect: String = str(companion.get("sect_support", GameManager.get_companion_sect(companion)))
			companion_slot.set_card(_make_inventory_card("同伴\n" + str(companion.get("name", "未知")) + "\n" + companion_sect + "｜" + bond_stage + " " + str(bond_value) + "/" + str(GameManager.get_companion_bond_max(companion)), "equipped", i, "companion", {"kind": "companion", "data": companion}, Color("#c080e0")))
		else:
			companion_slot.set_card(null)

	if backpack_slots_container == null or not backpack_slots_container.visible:
		pending_item_slot = null
		return
	for child in backpack_slots_container.get_children():
		child.queue_free()

	for i in range(player.backpack_capacity):
		var slot := InventoryDropSlot.new()
		slot.setup(self, "backpack", i, "背包" + str(i + 1), Color("#3a3a6e"))
		backpack_slots_container.add_child(slot)
		if i < player.backpack.size():
			var entry: Dictionary = player.backpack[i] as Dictionary
			var backpack_card: InventoryDragCard = _make_inventory_card(_format_backpack_entry_short(entry), "backpack", i, str(entry.get("kind", "")), entry, Color("#80c080"))
			slot.set_card(backpack_card)
			_maybe_animate_treasure_card(backpack_card, "backpack", i, entry)

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


func _maybe_animate_treasure_card(card: InventoryDragCard, source: String, index: int, entry: Dictionary) -> void:
	if card == null or str(entry.get("kind", "")) != "treasure":
		return
	var data: Dictionary = entry.get("data", {}) as Dictionary
	if not data.has("growth_value"):
		return
	var key: String = source + ":" + str(index) + ":" + str(data.get("name", "未知法宝"))
	var value: int = int(data.get("growth_value", 0))
	if treasure_growth_cache.has(key) and int(treasure_growth_cache[key]) != value:
		card.call_deferred("animate_growth", value)
	treasure_growth_cache[key] = value


func _format_backpack_entry_short(entry: Dictionary) -> String:
	var kind: String = str(entry.get("kind", ""))
	var data: Dictionary = entry.get("data", {}) as Dictionary
	var kind_name: String = _item_kind_name(kind)
	var suffix: String = ""
	if kind == "technique":
		suffix = "\n" + str(data.get("technique_realm", "初窥"))
		var technique_tags: String = _short_affix_tags(data)
		if technique_tags != "":
			suffix += "｜" + technique_tags
	elif kind == "treasure" and data.has("growth_value"):
		suffix = "\n" + str(data.get("growth_icon", "道")) + str(int(data.get("growth_value", 0)))
		var treasure_tags: String = _short_affix_tags(data)
		if treasure_tags != "":
			suffix += "｜" + treasure_tags
	elif kind == "companion":
		var bond_value: int = int(data.get("bond", 0))
		suffix = "\n" + GameManager.get_companion_sect(data) + "｜" + GameManager.get_companion_bond_stage_text_for_data(data) + " " + str(bond_value) + "/" + str(GameManager.get_companion_bond_max(data))
	elif kind == "material":
		suffix = "\n" + ("炼器" if str(data.get("material_type", "")) == "craft" else "炼丹")
	return kind_name + "\n" + str(data.get("name", "未知")) + suffix


func _short_affix_tags(data: Dictionary) -> String:
	var tags: Array[String] = []
	var affixes: Array = data.get("affixes", []) as Array
	for affix in affixes:
		if not affix is Dictionary:
			continue
		var tag: String = str((affix as Dictionary).get("tag", ""))
		var short_tag: String = tag.left(1)
		if short_tag != "" and not tags.has(short_tag):
			tags.append(short_tag)
	return "".join(tags)


func _affix_names(data: Dictionary) -> String:
	var names: Array[String] = []
	var affixes: Array = data.get("affixes", []) as Array
	for affix in affixes:
		if not affix is Dictionary:
			continue
		var affix_data: Dictionary = affix as Dictionary
		var affix_name: String = str(affix_data.get("name", ""))
		var tag: String = str(affix_data.get("tag", ""))
		if affix_name != "":
			names.append(affix_name + "(" + tag + ")")
	return "、".join(names)


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
		"material":
			return "材料"
		_:
			return "物品"


func _on_treasure_selected(index: int) -> void:
	var treasure: Dictionary = treasure_list.get_item_metadata(index) as Dictionary
	if treasure.is_empty():
		return
	show_inventory_item_details({"kind": "treasure", "data": treasure}, "equipped", 0)


func _on_treasure_menu_pressed(_id: int) -> void:
	pass


func _on_backpack_selected(index: int) -> void:
	var metadata: Dictionary = backpack_list.get_item_metadata(index) as Dictionary
	if metadata.is_empty():
		return
	var my_player: PlayerData = _get_my_player()
	if my_player == null:
		return

	backpack_menu.clear()
	backpack_menu.set_meta("backpack_index", int(metadata.get("index", -1)))
	backpack_menu.set_meta("pending", bool(metadata.get("pending", false)))
	var selected_entry: Dictionary = metadata.get("entry", {}) as Dictionary
	var selected_kind: String = str(selected_entry.get("kind", ""))
	backpack_menu.set_meta("kind", selected_kind)
	if bool(metadata.get("pending", false)):
		backpack_menu.add_item("放弃新物品", 2)
	else:
		backpack_menu.add_item("装备", 0)
		backpack_menu.add_item("丢弃", 1)
	if selected_kind == "technique":
		backpack_menu.add_separator("选择功法槽")
		for slot_index in range(GameManager.MAX_EQUIPPED_TECHNIQUES):
			var slot_label: String = "装备到空槽 " + str(slot_index + 1)
			if slot_index < my_player.techniques.size() and my_player.techniques[slot_index] is Dictionary:
				var technique: Dictionary = my_player.techniques[slot_index] as Dictionary
				slot_label = "替换 " + str(slot_index + 1) + "：" + str(technique.get("name", "未知功法"))
			backpack_menu.add_item(slot_label, 10 + slot_index)
	if not bool(metadata.get("pending", false)) and GameManager.has_pending_backpack_item(my_player.peer_id):
		backpack_menu.add_item("放弃待处理新物品", 2)
	backpack_menu.position = get_viewport().get_mouse_position()
	backpack_menu.popup()


func _on_backpack_menu_pressed(id: int) -> void:
	if id >= 10 and id < 10 + GameManager.MAX_EQUIPPED_TECHNIQUES:
		var is_pending: bool = bool(backpack_menu.get_meta("pending", false))
		var source: String = "pending" if is_pending else "backpack"
		var action_for_slot: String = "equip_pending" if is_pending else "equip"
		_send_backpack_action(action_for_slot, int(backpack_menu.get_meta("backpack_index", -1)), source, str(backpack_menu.get_meta("kind", "")), "technique", id - 10)
		return

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
	_reset_fullscreen_layout()
	_update_player_info()
	var peer_id: int = int(data.get("peer_id", 0))
	var my_player: PlayerData = _get_my_player()
	var is_my_feedback: bool = my_player != null and peer_id == my_player.peer_id
	var is_known_feedback: bool = peer_id == GameManager.player_a.peer_id or peer_id == GameManager.player_b.peer_id
	if not is_my_feedback and not is_known_feedback:
		return
	var message: String = str(data.get("message", "暂时无法突破"))
	label_log.text = "日志：" + message
	if message.contains("失败"):
		_flash_edges()
		UIEffects.screen_shake(self, 7.0 if is_my_feedback else 4.0, 0.28)
		_spawn_event_cut_in("突破失败" if is_my_feedback else "同道受挫", "灵气逆冲，破境未成。", Color("#c04040"))
	elif message.contains("突破至"):
		if is_my_feedback:
			_flash_rainbow()
		UIEffects.screen_shake(self, 4.0, 0.18)
		_spawn_event_cut_in("破境成功" if is_my_feedback else "同道破境", "境界一开，道途又远一程。", Color("#f0c040"))


func _on_auction_started(data: Dictionary) -> void:
	_update_player_info()
	_hide_result_toast()
	if btn_inject_shouyuan != null:
		btn_inject_shouyuan.visible = false
	cards_dealt = true
	reveal_playback_active = false
	pending_card_reveals.clear()
	_set_choice_enabled(false)
	label_waiting.visible = false
	auction_panel.visible = true
	_set_auction_buttons_enabled(true)
	var card: Dictionary = data.get("card", {}) as Dictionary
	_force_show_current_lottery_card(int(data.get("index", GameManager.current_bargain_index)), card)

	var lots: Array = data.get("lots", []) as Array
	if lots.is_empty():
		var card_for_lots: Dictionary = data.get("card", {}) as Dictionary
		lots = GameManager.generate_auction_lots(str(card_for_lots.get("quality", "筑基级")))
	for i in range(auction_lot_labels.size()):
		var lot_label: Label = auction_lot_labels[i] as Label
		if i < lots.size():
			var lot: Dictionary = lots[i] as Dictionary
			lot_label.text = _auction_lot_text(lot)
			auction_bid_buttons[i].disabled = false
			auction_haggle_buttons[i].disabled = false
		else:
			lot_label.text = "暂无货品"
			auction_bid_buttons[i].disabled = true
			auction_haggle_buttons[i].disabled = true

	label_round_info.text = "第 " + str(GameManager.round_number) + " 轮 · 坊市"
	label_current_ji_yuan.text = "本张：坊市开张"
	label_current_calamity.text = "选择货品，讲价或出价"
	var entry_message: String = str(card.get("auction_entry_message", "坊市开张，灵石终于有地方花了"))
	label_auction_status.text = entry_message
	label_log.text = "日志：" + entry_message


func _force_show_current_lottery_card(index: int, card: Dictionary) -> void:
	if index < 0 or card.is_empty():
		return
	if _visible_card_source_index() != index:
		_render_single_lottery_card(index, card, true)
	elif not lottery_cards.is_empty():
		var card_node: DaoCard = lottery_cards[0]
		card_node.flipping = false
		card_node.scale = card_node.get_meta("base_scale", Vector2.ONE) as Vector2
		card_node.setup_card(card, true)
	revealed_visual_indices[index] = true
	_focus_card(index)


func _auction_lot_text(lot: Dictionary) -> String:
	var lot_name: String = str(lot.get("name", "货品"))
	var desc: String = _shorten_result_message(str(lot.get("desc", "")), 18)
	var price: int = int(lot.get("price", 0))
	return lot_name + "\n" + desc + "｜" + str(price) + "灵石"


func _on_auction_action_pressed(lot_index: int, mode: String) -> void:
	_set_auction_buttons_enabled(false)
	if mode == "pass":
		label_auction_status.text = "你选择观望，等待对方..."
	else:
		var mode_text: String = "讲价" if mode == "haggle" else "出价"
		label_auction_status.text = "已选择" + mode_text + "，等待对方..."
	_send_auction_action({"lot_index": lot_index, "mode": mode})


func _send_auction_action(data: Dictionary) -> void:
	var my_player: PlayerData = _get_my_player()
	var peer_id: int = my_player.peer_id if my_player != null and my_player.peer_id > 0 else 1
	if NetworkManager.is_host:
		GameManager.on_auction_action_received(peer_id, data)
	else:
		NetworkManager.send_message("auction_action", data)


func _on_auction_ended(data: Dictionary) -> void:
	_update_player_info()
	_hide_auction_panel()
	_set_result_card_mode(true)
	var my_player: PlayerData = _get_my_player()
	var messages: Dictionary = data.get("messages", {}) as Dictionary
	var message: String = "坊市收摊"
	if my_player != null:
		message = str(messages.get(str(my_player.peer_id), message))
	label_result_title.text = "坊市收摊"
	label_result_detail.text = message
	result_toast.visible = true
	latest_settled_index = int(data.get("index", -1))
	latest_result_round_finished = bool(data.get("round_finished", false))
	result_continue_sent = false
	btn_continue_result.disabled = false
	btn_continue_result.text = "继续"
	label_log.text = "日志：" + message


func _on_rest_started(data: Dictionary) -> void:
	_update_player_info()
	_hide_auction_panel()
	_set_choice_enabled(false)
	label_waiting.visible = false
	result_continue_sent = false
	if backpack_slots_container != null:
		backpack_slots_container.visible = true
	_update_drag_inventory(_get_my_player())
	_refresh_rest_panel(data)
	if backpack_overlay_layer != null:
		_on_backpack_button_pressed()


func _on_rest_updated(data: Dictionary) -> void:
	_update_player_info()
	var player: PlayerData = _get_my_player()
	var votes: Dictionary = data.get("rest_confirm_votes", {}) as Dictionary
	result_continue_sent = player != null and (votes.has(player.peer_id) or votes.has(str(player.peer_id)))
	_refresh_rest_panel(data)
	var message: String = str(data.get("message", "整备已更新"))
	if message != "":
		label_log.text = "日志：" + message


func _refresh_rest_panel(data: Dictionary = {}) -> void:
	var player: PlayerData = _get_my_player()
	if player == null or result_toast == null:
		return
	var final_duel: bool = bool(data.get("final_duel", false))
	_apply_panel_style(result_toast, Color(0.08, 0.12, 0.18, 0.97))
	label_round_info.text = "第 " + str(GameManager.round_number) + " 轮 · " + ("最终整备" if final_duel else "整备")
	label_current_ji_yuan.text = "背包：" + GameManager.get_backpack_counts_text(player)
	label_current_calamity.text = _format_build_progress(player)
	label_result_title.text = "最终整备" if final_duel else "整备"
	label_result_title.add_theme_color_override("font_color", Color("#f0c040"))
	var message: String = str(data.get("message", "整理背包与上场阵容，确认后继续"))
	var detail_lines: Array[String] = [
		message,
		"背包：" + GameManager.get_backpack_counts_text(player),
		"上场：功法 " + str(player.techniques.size()) + "/" + str(GameManager.MAX_EQUIPPED_TECHNIQUES) + "  法宝 " + str(player.treasures.size()) + "/1  伙伴 " + str(player.companions.size()) + "/" + str(GameManager.MAX_COMPANIONS),
		_format_build_progress(player),
		GameManager.get_cultivation_build_hint(player),
	]
	label_result_detail.text = "\n".join(detail_lines)
	result_toast.visible = true
	result_toast.z_index = 240
	result_toast.mouse_filter = Control.MOUSE_FILTER_STOP
	result_toast.move_to_front()
	if btn_continue_result != null:
		btn_continue_result.visible = true
		btn_continue_result.disabled = result_continue_sent
		btn_continue_result.text = "已确认，等待对方" if result_continue_sent else ("锁定阵容" if final_duel else "继续")


func _on_rest_confirm_pressed() -> void:
	var player: PlayerData = _get_my_player()
	if player == null:
		return
	if GameManager.has_pending_backpack_item(player.peer_id):
		label_log.text = "日志：还有待处理组件，请先装备或丢弃"
		_update_backpack_block_label(player)
		if btn_continue_result != null:
			btn_continue_result.text = "先清理背包"
		return
	result_continue_sent = true
	if btn_continue_result != null:
		btn_continue_result.disabled = true
		btn_continue_result.text = "等待对方确认..."
	label_waiting.visible = true
	label_waiting.text = "等待对方完成整备"
	label_log.text = "日志：你已确认整备"
	var payload: Dictionary = {}
	if NetworkManager.is_host:
		GameManager.on_rest_confirm_received(1, payload)
	else:
		NetworkManager.send_message("rest_confirm", payload)


func _on_sect_event_started(data: Dictionary) -> void:
	_show_sect_event_overlay(data)


func _on_sect_event_updated(data: Dictionary) -> void:
	_show_sect_event_overlay(data)


func _on_sect_event_finished(_data: Dictionary) -> void:
	sect_event_countdown_active = false
	sect_event_choice_sent = false
	sect_event_continue_sent = false
	if sect_event_layer != null:
		sect_event_layer.visible = false


func _show_sect_event_overlay(data: Dictionary) -> void:
	if sect_event_layer == null:
		return
	_update_player_info()
	_hide_auction_panel()
	_hide_result_toast()
	_set_choice_enabled(false)
	if backpack_overlay_layer != null:
		backpack_overlay_layer.visible = false
	if crafting_layer != null:
		crafting_layer.visible = false
	var phase: String = str(data.get("phase", "choice"))
	var incoming_id: int = int(data.get("id", -1))
	if incoming_id != sect_event_current_id:
		sect_event_current_id = incoming_id
		sect_event_countdown_remaining = float(data.get("choice_seconds", 10.0))
	sect_event_layer.visible = true
	sect_event_layer.move_to_front()
	if label_round_info != null:
		label_round_info.text = "第 " + str(GameManager.round_number) + " 轮 · " + str(data.get("title", "宗门事件"))
	if sect_event_title_label != null:
		sect_event_title_label.text = str(data.get("title", "宗门事件"))
	if sect_event_desc_label != null:
		sect_event_desc_label.text = str(data.get("desc", "宗门风云忽起。"))
	var my_player: PlayerData = _get_my_player()
	var choices: Dictionary = data.get("choices", {}) as Dictionary
	var my_key: String = str(my_player.peer_id) if my_player != null else ""
	if phase == "choice":
		sect_event_choice_sent = my_key != "" and choices.has(my_key)
		sect_event_continue_sent = false
		sect_event_countdown_active = not sect_event_choice_sent
		_set_sect_event_choice_buttons(not sect_event_choice_sent)
		if sect_event_continue_button != null:
			sect_event_continue_button.visible = false
		if sect_event_body_label != null:
			var body_lines: Array[String] = []
			body_lines.append(str(data.get("rules", "")))
			body_lines.append("")
			body_lines.append("双方有10秒选择；超时默认不参加。")
			if sect_event_choice_sent:
				body_lines.append("你已选择：" + ("参加" if bool(choices.get(my_key, false)) else "不参加") + "，等待对方。")
			sect_event_body_label.text = "\n".join(body_lines)
		_update_sect_event_countdown(0.0)
	else:
		sect_event_countdown_active = false
		_set_sect_event_choice_buttons(false)
		if sect_event_join_button != null:
			sect_event_join_button.visible = false
		if sect_event_skip_button != null:
			sect_event_skip_button.visible = false
		var votes: Dictionary = data.get("continue_votes", {}) as Dictionary
		sect_event_continue_sent = my_key != "" and votes.has(my_key)
		if sect_event_continue_button != null:
			sect_event_continue_button.visible = true
			sect_event_continue_button.disabled = sect_event_continue_sent
			sect_event_continue_button.text = "已确认，等待对方" if sect_event_continue_sent else "继续修行"
		if sect_event_countdown_label != null:
			sect_event_countdown_label.text = "宗门战报"
		if sect_event_body_label != null:
			var result: Dictionary = data.get("result", {}) as Dictionary
			var lines: Array = result.get("lines", []) as Array
			var body: Array[String] = [str(result.get("summary", data.get("message", "宗门事件已结算。")))]
			for line in lines:
				body.append("· " + str(line))
			sect_event_body_label.text = "\n".join(body)
	if label_log != null:
		label_log.text = "日志：" + str(data.get("message", str(data.get("title", "宗门事件"))))


func _set_sect_event_choice_buttons(enabled: bool) -> void:
	if sect_event_join_button != null:
		sect_event_join_button.visible = true
		sect_event_join_button.disabled = not enabled
	if sect_event_skip_button != null:
		sect_event_skip_button.visible = true
		sect_event_skip_button.disabled = not enabled


func _update_sect_event_countdown(delta: float) -> void:
	if not sect_event_countdown_active:
		return
	sect_event_countdown_remaining = maxf(0.0, sect_event_countdown_remaining - delta)
	if sect_event_countdown_label != null:
		sect_event_countdown_label.text = str(int(ceil(sect_event_countdown_remaining))) + "秒后默认不参加"
	if sect_event_countdown_remaining <= 0.0:
		_on_sect_event_choice_pressed(false, true)


func _on_sect_event_choice_pressed(participate: bool, timed_out: bool = false) -> void:
	if sect_event_choice_sent:
		return
	sect_event_choice_sent = true
	sect_event_countdown_active = false
	_set_sect_event_choice_buttons(false)
	if sect_event_countdown_label != null:
		sect_event_countdown_label.text = "已选择：" + ("参加" if participate else "不参加")
	if label_log != null:
		label_log.text = "日志：你选择" + ("参加宗门事件" if participate else "暂不参加宗门事件")
	var payload: Dictionary = {"participate": participate, "timeout": timed_out}
	if NetworkManager.is_host:
		GameManager.on_sect_event_choice_received(1, payload)
	else:
		NetworkManager.send_message("sect_event_choice", payload)


func _on_sect_event_continue_pressed() -> void:
	if sect_event_continue_sent:
		return
	sect_event_continue_sent = true
	if sect_event_continue_button != null:
		sect_event_continue_button.disabled = true
		sect_event_continue_button.text = "等待对方确认..."
	if label_log != null:
		label_log.text = "日志：你已读完宗门战报"
	if NetworkManager.is_host:
		GameManager.on_sect_event_continue_received(1, {})
	else:
		NetworkManager.send_message("sect_event_continue", {})


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
	_add_market_item("吸收灵石：修为 +" + str(GameManager.MARKET_CULTIVATION_GAIN) + " / " + str(GameManager.MARKET_CULTIVATION_COST) + "灵石", 0, player.ling_shi < GameManager.MARKET_CULTIVATION_COST)
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

	var backpack_full: bool = player.backpack_capacity >= GameManager.MAX_BACKPACK_CAPACITY
	var backpack_text: String = "背包已达上限 " + str(GameManager.MAX_BACKPACK_CAPACITY) if backpack_full else "扩充背包：容量 +1 / " + str(GameManager.MARKET_BACKPACK_COST) + "灵石"
	backpack_full = true
	backpack_text = "背包固定：功法8 / 法宝4 / 伙伴6 / 材料8"
	_add_market_item(backpack_text, 3, backpack_full or player.ling_shi < GameManager.MARKET_BACKPACK_COST)
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


func _on_alchemy_pressed() -> void:
	var player: PlayerData = _get_my_player()
	if player == null:
		return
	if alchemy_menu == null:
		_start_crafting_minigame("alchemy")
		return
	alchemy_menu.clear()
	var options: Array[Dictionary] = GameManager.get_alchemy_recipe_options(player)
	for i in range(options.size()):
		var option: Dictionary = options[i] as Dictionary
		alchemy_menu.add_item(str(option.get("text", option.get("label", "炼丹"))), i)
		alchemy_menu.set_item_metadata(i, str(option.get("id", "heal")))
		alchemy_menu.set_item_disabled(i, not bool(option.get("can", false)))
	alchemy_menu.position = get_viewport().get_mouse_position()
	alchemy_menu.popup()


func _on_alchemy_menu_pressed(id: int) -> void:
	if alchemy_menu == null:
		return
	var recipe: String = str(alchemy_menu.get_item_metadata(id))
	_start_crafting_minigame("alchemy", recipe)


func _on_refining_pressed() -> void:
	var player: PlayerData = _get_my_player()
	if player != null:
		var status: Dictionary = GameManager.get_refining_status(player)
		if not bool(status.get("can", false)):
			label_log.text = "日志：" + str(status.get("reason", "暂时不能炼器"))
			_update_refining_button(player)
			return
	_start_crafting_minigame("refining")


func _send_market_action(action: String, extra_data: Dictionary = {}) -> void:
	var data: Dictionary = {"action": action}
	for key in extra_data:
		data[key] = extra_data[key]
	if NetworkManager.is_host:
		GameManager.on_market_action_received(1, data)
	else:
		NetworkManager.send_message("market_action", data)


func _start_crafting_minigame(mode: String, recipe: String = "auto") -> void:
	var player: PlayerData = _get_my_player()
	if player == null or crafting_layer == null:
		return
	var status: Dictionary = GameManager.get_alchemy_status(player, recipe) if mode == "alchemy" else GameManager.get_refining_status(player)
	if not bool(status.get("can", false)):
		label_log.text = "日志：" + str(status.get("reason", "暂时不能开炉"))
		return
	crafting_mode = mode
	crafting_recipe = str(status.get("recipe", recipe)) if mode == "alchemy" else "auto"
	crafting_pointer_value = randf()
	crafting_pointer_dir = 1.0 if randf() >= 0.5 else -1.0
	var stat_score: int = int(status.get("stat_score", 0))
	_update_crafting_windows(stat_score)
	crafting_speed = maxf(0.52, 0.90 - float(stat_score) * 0.018) + randf() * 0.18
	crafting_running = true
	crafting_layer.visible = true
	crafting_layer.move_to_front()
	if crafting_title_label != null:
		crafting_title_label.text = str(status.get("label", "开炉炼丹")) if mode == "alchemy" else "开炉炼器"
	if crafting_status_label != null:
		var material_name: String = str(status.get("material_name", "灵草" if mode == "alchemy" else "矿材"))
		var cost_text: String = "，灵石-" + str(int(status.get("cost", 0))) if int(status.get("cost", 0)) > 0 else ""
		crafting_status_label.text = "投入" + material_name + cost_text + "。相关六维：" + str(status.get("stat_text", "")) + "=" + str(stat_score) + "，看准火候点「收火」，点空白处停手。"
	if crafting_action_button != null:
		crafting_action_button.text = "收火"
		crafting_action_button.disabled = false
	if crafting_art_label != null:
		crafting_art_label.text = "丹炉" if mode == "alchemy" else "锻炉"
		crafting_art_label.add_theme_color_override("font_color", Color("#f0c040"))
	if crafting_art_panel != null:
		crafting_art_panel.add_theme_stylebox_override("panel", _make_crafting_art_style(Color("#2a1b10") if mode == "alchemy" else Color("#101c26"), Color("#f0c040")))
		crafting_art_panel.scale = Vector2.ONE
	if crafting_feedback_panel != null:
		crafting_feedback_panel.visible = false
	_update_crafting_pointer_visual()


func _update_crafting_windows(stat_score: int) -> void:
	var good_half: float = clampf(0.16 + float(stat_score) * 0.006, 0.16, 0.29)
	var perfect_half: float = clampf(0.04 + float(stat_score) * 0.0025, 0.04, 0.095)
	crafting_good_left = 0.5 - good_half
	crafting_good_right = 0.5 + good_half
	crafting_perfect_left = 0.5 - perfect_half
	crafting_perfect_right = 0.5 + perfect_half
	if crafting_good_zone != null:
		crafting_good_zone.anchor_left = crafting_good_left
		crafting_good_zone.anchor_right = crafting_good_right
	if crafting_perfect_zone != null:
		crafting_perfect_zone.anchor_left = crafting_perfect_left
		crafting_perfect_zone.anchor_right = crafting_perfect_right


func _update_crafting_minigame(delta: float) -> void:
	crafting_pointer_value += crafting_pointer_dir * crafting_speed * delta
	if crafting_pointer_value >= 1.0:
		crafting_pointer_value = 1.0
		crafting_pointer_dir = -1.0
	elif crafting_pointer_value <= 0.0:
		crafting_pointer_value = 0.0
		crafting_pointer_dir = 1.0
	_update_crafting_pointer_visual()


func _update_crafting_pointer_visual() -> void:
	if crafting_pointer == null or crafting_bar == null:
		return
	var width: float = maxf(1.0, crafting_bar.size.x)
	crafting_pointer.offset_left = crafting_pointer_value * width - 3.0
	crafting_pointer.offset_right = crafting_pointer.offset_left + 6.0


func _on_crafting_overlay_dim_gui_input(event: InputEvent) -> void:
	if crafting_layer == null or not crafting_layer.visible or not crafting_running:
		return
	var should_stop: bool = false
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		should_stop = mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT
	elif event is InputEventScreenTouch:
		should_stop = (event as InputEventScreenTouch).pressed
	if not should_stop:
		return
	_hide_crafting_overlay()
	if label_log != null:
		label_log.text = "日志：暂且停火，材料尚未投入。"
	get_viewport().set_input_as_handled()


func _on_crafting_action_pressed() -> void:
	if not crafting_running:
		return
	var grade: String = _crafting_grade_from_pointer()
	var action: String = "alchemy" if crafting_mode == "alchemy" else "refining"
	var player: PlayerData = _get_my_player()
	var status: Dictionary = GameManager.get_alchemy_status(player, crafting_recipe) if action == "alchemy" else GameManager.get_refining_status(player)
	var material_name: String = str(status.get("material_name", "灵草" if action == "alchemy" else "矿材"))
	crafting_running = false
	if crafting_action_button != null:
		crafting_action_button.disabled = true
	label_log.text = "日志：" + ("炉火正妙" if grade == "perfect" else ("火候已成" if grade == "good" else "炉火失衡"))
	await _play_crafting_grade_feedback(grade, action)
	_hide_crafting_overlay()
	_send_market_action(action, {"grade": grade, "recipe": crafting_recipe, "material_name": material_name})


func _play_crafting_grade_feedback(grade: String, action: String) -> void:
	var grade_color: Color = _crafting_grade_color(grade)
	if crafting_feedback_panel != null:
		crafting_feedback_panel.visible = true
		crafting_feedback_panel.modulate.a = 0.0
		crafting_feedback_panel.scale = Vector2(0.92, 0.92)
		crafting_feedback_panel.add_theme_stylebox_override("panel", _make_crafting_art_style(Color("#261604"), grade_color))
	if crafting_feedback_label != null:
		crafting_feedback_label.text = _crafting_grade_display(grade)
		crafting_feedback_label.add_theme_color_override("font_color", grade_color)
	if crafting_feedback_detail_label != null:
		crafting_feedback_detail_label.text = _crafting_grade_detail(grade, action)
	if crafting_art_label != null:
		crafting_art_label.text = _crafting_art_result_text(grade, action)
		crafting_art_label.add_theme_color_override("font_color", grade_color)
	if crafting_art_panel != null:
		crafting_art_panel.add_theme_stylebox_override("panel", _make_crafting_art_style(_crafting_art_fill_color(grade, action), grade_color))
		crafting_art_panel.pivot_offset = crafting_art_panel.size * 0.5
		var art_tween := create_tween()
		art_tween.set_trans(Tween.TRANS_BACK)
		art_tween.set_ease(Tween.EASE_OUT)
		art_tween.tween_property(crafting_art_panel, "scale", Vector2(1.08, 1.08), 0.12)
		art_tween.tween_property(crafting_art_panel, "scale", Vector2.ONE, 0.18)
	if crafting_feedback_panel != null:
		var feedback_tween := create_tween()
		feedback_tween.set_parallel(true)
		feedback_tween.set_trans(Tween.TRANS_BACK)
		feedback_tween.set_ease(Tween.EASE_OUT)
		feedback_tween.tween_property(crafting_feedback_panel, "modulate:a", 1.0, 0.12)
		feedback_tween.tween_property(crafting_feedback_panel, "scale", Vector2.ONE, 0.16)
	UIEffects.screen_shake(self, 4.5 if grade == "perfect" else (2.2 if grade == "good" else 6.0), 0.18)
	await get_tree().create_timer(0.72).timeout


func _crafting_grade_color(grade: String) -> Color:
	match grade:
		"perfect":
			return Color("#f0c040")
		"miss":
			return Color("#c04040")
		_:
			return Color("#80c0ff")


func _crafting_grade_detail(grade: String, action: String) -> String:
	var target_name: String = "丹成" if action == "alchemy" else "器鸣"
	match grade:
		"perfect":
			return "收火极准，" + target_name + "上品。"
		"miss":
			return "火势偏乱，只留残火收益。"
		_:
			return "收火稳当，" + target_name + "可用。"


func _crafting_art_result_text(grade: String, action: String) -> String:
	if action == "alchemy":
		match grade:
			"perfect":
				return "丹光大盛"
			"miss":
				return "炉烟散乱"
			_:
				return "丹气成形"
	match grade:
		"perfect":
			return "器纹鸣响"
		"miss":
			return "火星四散"
		_:
			return "淬火成器"


func _crafting_art_fill_color(grade: String, action: String) -> Color:
	if grade == "miss":
		return Color("#2a0909")
	if action == "refining":
		return Color("#102432") if grade == "good" else Color("#30240a")
	return Color("#2a1b10") if grade == "good" else Color("#332106")


func _crafting_grade_from_pointer() -> String:
	if crafting_pointer_value >= crafting_perfect_left and crafting_pointer_value <= crafting_perfect_right:
		return "perfect"
	if crafting_pointer_value >= crafting_good_left and crafting_pointer_value <= crafting_good_right:
		return "good"
	return "miss"


func _hide_crafting_overlay() -> void:
	crafting_running = false
	if crafting_layer != null:
		crafting_layer.visible = false
	if crafting_feedback_panel != null:
		crafting_feedback_panel.visible = false
	if crafting_art_panel != null:
		crafting_art_panel.scale = Vector2.ONE


func _on_market_changed(data: Dictionary) -> void:
	_update_player_info()
	var peer_id: int = int(data.get("peer_id", 0))
	var my_player: PlayerData = _get_my_player()
	if my_player != null and peer_id == my_player.peer_id:
		label_log.text = "日志：" + str(data.get("message", "坊市交易完成"))
		var action: String = str(data.get("action", ""))
		if action == "alchemy" or action == "refining":
			_show_crafting_result(data)
	if btn_continue_result != null and result_toast != null and result_toast.visible and not bool(result_toast.get_meta("local_only", false)):
		if my_player != null and GameManager.has_pending_backpack_item(my_player.peer_id):
			btn_continue_result.text = "先清理背包"
		elif result_continue_sent:
			btn_continue_result.text = "等待对方确认..."
		else:
			btn_continue_result.text = "继续"


func _show_crafting_result(data: Dictionary) -> void:
	if result_toast == null:
		return
	var action: String = str(data.get("action", "alchemy"))
	var recipe: String = str(data.get("recipe", ""))
	var title: String = _alchemy_result_title(recipe) if action == "alchemy" else "炼器完成"
	var material_name: String = str(data.get("material_name", "灵草" if action == "alchemy" else "矿材"))
	var grade_text: String = _crafting_grade_display(str(data.get("grade", "good")))
	var message: String = str(data.get("message", "开炉完成"))
	_apply_panel_style(result_toast, Color(0.18, 0.13, 0.03, 0.97))
	label_result_title.text = title
	label_result_title.add_theme_color_override("font_color", Color("#f0c040"))
	label_result_detail.text = "投入：" + material_name + "\n火候：" + grade_text + "\n收获：" + message
	if contest_button_row != null:
		contest_button_row.visible = false
	if btn_continue_result != null:
		btn_continue_result.text = "继续"
		btn_continue_result.visible = true
		btn_continue_result.disabled = false
	result_toast.visible = true
	result_toast.z_index = 240
	result_toast.mouse_filter = Control.MOUSE_FILTER_STOP
	result_toast.set_meta("local_only", true)
	result_toast.set_meta("local_log_message", title + "已收起")
	result_toast.move_to_front()
	result_toast.modulate.a = 1.0
	result_toast.scale = Vector2(0.98, 0.98)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(result_toast, "modulate:a", 1.0, 0.16)
	tween.tween_property(result_toast, "scale", Vector2.ONE, 0.2)


func _alchemy_result_title(recipe: String) -> String:
	match recipe:
		"breakthrough":
			return "突破丹成"
		"qi_gathering":
			return "聚气丹成"
		"longevity":
			return "延寿丹成"
		"heal":
			return "回春丹成"
		_:
			return "炼丹完成"


func _crafting_grade_display(grade: String) -> String:
	match grade:
		"perfect":
			return "炉火正妙"
		"miss":
			return "炉火失衡"
		_:
			return "火候已成"


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
	if GameManager.current_state == GameManager.GameState.REST:
		_refresh_rest_panel({"message": str(data.get("message", "整备已更新")), "final_duel": GameManager.final_duel_after_rest})
		return
	if btn_continue_result != null and result_toast != null and result_toast.visible and not bool(result_toast.get_meta("local_only", false)):
		if my_player != null and GameManager.has_pending_backpack_item(my_player.peer_id):
			btn_continue_result.text = "先清理背包"
			btn_continue_result.disabled = false
		elif result_continue_sent:
			btn_continue_result.text = "等待对方确认..."
		else:
			btn_continue_result.text = "继续"


func can_drop_inventory_data(data: Dictionary, target_type: String, target_index: int) -> bool:
	var source: String = str(data.get("source", ""))
	var kind: String = str(data.get("kind", ""))
	var player: PlayerData = _get_my_player()
	if player == null:
		return false

	match target_type:
		"technique":
			return kind == "technique" and (source == "backpack" or source == "pending") and target_index >= 0 and target_index < GameManager.MAX_EQUIPPED_TECHNIQUES
		"treasure":
			return kind == "treasure" and (source == "backpack" or source == "pending")
		"companion":
			return kind == "companion" and (source == "backpack" or source == "pending") and target_index >= 0 and target_index < GameManager.MAX_COMPANIONS
		"backpack":
			return source == "equipped"
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
		"backpack":
			if source == "equipped":
				action = "unequip"
			else:
				return
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
	var dialog_id: int = dialog.get_instance_id()
	dialog.confirmed.connect(_free_dialog_by_id.bind(dialog_id))
	dialog.close_requested.connect(_free_dialog_by_id.bind(dialog_id))
	dialog.popup_centered(Vector2i(560, 420))


func _free_dialog_by_id(dialog_id: int) -> void:
	var dialog_object: Object = instance_from_id(dialog_id)
	if dialog_object is Node:
		(dialog_object as Node).queue_free()


func _describe_inventory_entry(entry: Dictionary, source: String, index: int) -> String:
	var kind: String = str(entry.get("kind", ""))
	var data: Dictionary = entry.get("data", {}) as Dictionary
	var lines: Array[String] = []
	lines.append(_item_kind_name(kind) + "：" + str(data.get("name", "未知")))
	if data.has("quality") and kind in ["technique", "treasure", "companion", "material"]:
		lines.append("品质：" + _quality_display_name(str(data.get("quality", ""))))
	if kind in ["technique", "treasure", "companion"]:
		if kind in ["technique", "treasure"]:
			var affix_line: String = _inventory_affix_line(data)
			if affix_line != "":
				lines.append(affix_line)
	if data.has("title"):
		lines.append("身份：" + str(data.get("title", "")))

	match kind:
		"technique":
			var bonuses: Dictionary = data.get("bonuses", {}) as Dictionary
			var base_bonuses: Dictionary = data.get("base_bonuses", {}) as Dictionary
			var realm: String = str(data.get("technique_realm", "初窥"))
			var progress: int = int(data.get("realm_progress", 0))
			var req: int = int(GameManager.TECHNIQUE_REALM_FRAGMENT_REQ.get(realm, 0))
			var progress_text: String = "｜参悟 " + str(progress) + "/" + str(req) if req > 0 else "｜已大成"
			var stage_text: String = "｜功效" + GameManager.get_technique_stage_multiplier_text(realm)
			var effective_bonuses: Dictionary = GameManager.get_technique_effective_bonuses(data)
			if effective_bonuses.is_empty():
				effective_bonuses = bonuses if not bonuses.is_empty() else base_bonuses
			lines.append("定位：上场后提供1-2项专精属性")
			lines.append("修炼：" + realm + progress_text + stage_text)
			lines.append("效果：" + _format_bonus_dict(effective_bonuses))
			var next_realm: String = _next_technique_realm_name(realm)
			if next_realm != realm:
				lines.append("下境：" + next_realm + "后 " + _format_bonus_dict(GameManager.get_technique_effective_bonuses(data, next_realm)))
			else:
				lines.append("圆满：已发挥全部功效")
			lines.append("升级：" + _format_technique_growth_hint(str(data.get("primary_cultivation_tag", ""))))
		"treasure":
			lines.append("定位：抢攻自动出手")
			lines.append("攻击：+" + str(int(data.get("battle_damage", data.get("base_attack", 0)))) + "｜特效：" + _format_treasure_attack_effect(str(data.get("attack_effect", "未知"))))
			if data.has("growth_value"):
				lines.append("成长：" + str(data.get("growth_name", "成长")) + " " + str(int(data.get("growth_value", 0))) + " / " + str(int(data.get("awaken_threshold", data.get("growth_max", 0)))) + "｜" + ("已觉醒" if int(data.get("awakening_level", 0)) > 0 else "未觉醒"))
			var awaken_skill: Dictionary = data.get("awakening_skill", {}) as Dictionary
			if not awaken_skill.is_empty():
				lines.append("觉醒：" + _format_treasure_awaken_skill(awaken_skill))
			var extra_effects: Array = data.get("extra_attack_effects", []) as Array
			if not extra_effects.is_empty():
				var extra_names: Array[String] = []
				for effect in extra_effects:
					extra_names.append(str(effect))
				lines.append("附加：" + "，".join(extra_names))
			var treasure_primary_tag: String = str(data.get("primary_cultivation_tag", ""))
			var treasure_growth: Dictionary = GameManager.TREASURE_GROWTH.get(treasure_primary_tag, {}) as Dictionary
			lines.append("升级：" + str(treasure_growth.get("trigger", _format_growth_behavior_hint(treasure_primary_tag))))
		"companion":
			var bond_value: int = int(data.get("bond", 0))
			var bond_max: int = GameManager.get_companion_bond_max(data)
			lines.append("定位：被动加成 + 宗门身份")
			lines.append("门派：" + GameManager.get_companion_sect(data) + "｜阵营：" + GameManager.get_companion_alignment(data))
			lines.append("被动：" + str(data.get("effect_desc", str(data.get("bonus_type", "")) + " " + str(data.get("bonus_value", "")))))
			lines.append("羁绊：" + GameManager.get_companion_bond_stage_text_for_data(data) + " " + str(bond_value) + "/" + str(bond_max))
			lines.append("满羁绊：" + str(data.get("full_effect_desc", "解锁专属被动")))
		"material":
			var material_type: String = str(data.get("material_type", "alchemy"))
			if material_type == "craft":
				lines.append("用途：炼器消耗，淬炼上场法宝")
				lines.append("相关六维：体魄 + 经商")
				lines.append("玩法：点炼器开炉，蓝区成功，金区完美")
				lines.append("成色：操作越准、相关六维越高，品质越好")
				lines.append("成长：高品质会提高法宝成长与器修功法收益")
			else:
				lines.append("用途：炼丹消耗，可炼突破丹/聚气丹/延寿丹/回春丹")
				lines.append("相关六维：气感 + 机缘")
				lines.append("玩法：点炼丹开炉，蓝区成功，金区完美")
				lines.append("成色：操作越准、相关六维越高，品质越好")
				lines.append("成长：高品质会提高药力与丹修成长")
		_:
			lines.append("暂未记录详细效果。")

	if source != "":
		lines.append("")
		lines.append("位置：" + _inventory_source_name(source, index))
	return "\n".join(lines)


func _inventory_affix_line(data: Dictionary) -> String:
	var affix_count: int = (data.get("affixes", []) as Array).size()
	var max_affix_count: int = GameManager.get_quality_affix_count(str(data.get("quality", "炼气级")))
	var affix_text: String = _affix_names(data)
	var primary_tag: String = str(data.get("primary_cultivation_tag", ""))
	var primary_text: String = "｜主修：" + primary_tag if primary_tag != "" else ""
	if affix_text == "":
		return "词条：" + str(affix_count) + "/" + str(max_affix_count) + primary_text
	return "词条：" + affix_text + "｜" + str(affix_count) + "/" + str(max_affix_count) + primary_text


func _format_technique_growth_hint(cultivation_tag: String) -> String:
	var behavior_text: String = _format_growth_behavior_hint(cultivation_tag)
	if behavior_text == "":
		return "同名残卷"
	return "同名残卷；" + behavior_text


func _next_technique_realm_name(current_realm: String) -> String:
	match current_realm:
		"初窥":
			return "小成"
		"小成":
			return "大成"
		_:
			return current_realm


func _format_growth_behavior_hint(cultivation_tag: String) -> String:
	match cultivation_tag:
		"鬼修":
			return "抢机缘、击杀敌人"
		"体修":
			return "承受伤害、承担灾厄、扛天劫"
		"剑修":
			return "抢攻、突破境界"
		"情修":
			return "让机缘、共担灾厄、护道承劫"
		"丹修":
			return "回血、炼丹、服丹"
		"阵修":
			return "周旋布阵、承担灾厄、扛天劫"
		"符修":
			return "周旋、闪避、避灾避劫"
		"器修":
			return "法宝成长、法宝觉醒、炼器"
		_:
			return ""


func _format_treasure_attack_effect(effect_name: String) -> String:
	match effect_name:
		"破甲":
			return "破甲（无视20%防御）"
		"吸血":
			return "吸血（伤害15%回血）"
		"连击":
			return "连击（追加50%伤害）"
		"暴击加成":
			return "暴击加成（本次暴击+20%）"
		_:
			return effect_name


func _format_treasure_awaken_skill(skill: Dictionary) -> String:
	var parts: Array[String] = [str(skill.get("name", "觉醒技"))]
	var damage_scale: float = float(skill.get("damage_scale", 0.0))
	if damage_scale > 0.0:
		parts.append("追加" + str(int(round(damage_scale * 100.0))) + "%伤害")
	var heal_rate: float = float(skill.get("heal_rate", 0.0))
	if heal_rate > 0.0:
		parts.append("吸血" + str(int(round(heal_rate * 100.0))) + "%")
	if parts.size() <= 1 and str(skill.get("desc", "")) != "":
		parts.append(str(skill.get("desc", "")))
	return "，".join(parts)


func _affix_detail_text(data: Dictionary) -> String:
	var lines: Array[String] = []
	var affixes: Array = data.get("affixes", []) as Array
	for affix in affixes:
		if not affix is Dictionary:
			continue
		var affix_data: Dictionary = affix as Dictionary
		var affix_name: String = str(affix_data.get("name", ""))
		var tag: String = str(affix_data.get("tag", ""))
		var desc: String = str(affix_data.get("desc", ""))
		if affix_name == "":
			continue
		lines.append("· " + affix_name + "（" + tag + "）：" + desc)
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
