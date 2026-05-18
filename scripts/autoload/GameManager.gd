extends Node

enum GameState {STAT_ALLOCATION, ROUND_START, LOTTERY, BARGAIN, AUCTION, BATTLE, BREAKTHROUGH, TRIBULATION, DUEL, ENDING}

signal game_state_changed(new_state: int)
signal lottery_generated(results: Array)
signal lottery_energy_updated(count: int, total: int)
signal lottery_energy_ready()
signal lottery_card_revealed(index: int, card: Dictionary)
signal bargain_ready(index: int)
signal bargain_result(result: Dictionary)
signal backpack_changed(data: Dictionary)
signal market_changed(data: Dictionary)
signal auction_started(data: Dictionary)
signal auction_ended(data: Dictionary)
signal breakthrough_feedback(data: Dictionary)
signal tribulation_triggered(data: Dictionary)
signal tribulation_settled(result: Dictionary)
signal battle_started(enemy_data: Dictionary)
signal battle_updated(data: Dictionary)
signal battle_ended(data: Dictionary)
signal duel_triggered()
signal duel_prepared(data: Dictionary)
signal duel_updated(data: Dictionary)
signal duel_finished(data: Dictionary)

const QUALITY_PROBS := {
	"凡品": 0.30,
	"良品": 0.25,
	"上品": 0.20,
	"极品": 0.15,
	"仙品": 0.07,
	"道品": 0.03,
}

const QUALITY_MULTIPLIER := {
	"凡品": 0.5,
	"良品": 0.8,
	"上品": 1.0,
	"极品": 1.5,
	"仙品": 2.0,
	"道品": 3.0,
}

const JI_YUAN_TYPES := [
	{"name": "修行", "base_effect": 60, "effect_type": "ling_li"},
	{"name": "治疗", "base_effect": 30, "effect_type": "heal_percent"},
	{"name": "灵石", "base_effect": 500, "effect_type": "ling_shi"},
	{"name": "功法", "base_effect": 0, "effect_type": "technique"},
	{"name": "法宝", "base_effect": 0, "effect_type": "treasure"},
	{"name": "丹药", "base_effect": 0, "effect_type": "dan"},
	{"name": "属性", "base_effect": 1, "effect_type": "stat_up"},
	{"name": "寿元", "base_effect": 2, "effect_type": "shou_yuan"},
	{"name": "伙伴", "base_effect": 0, "effect_type": "companion"},
	{"name": "拍卖会", "base_effect": 0, "effect_type": "auction"},
]

const JI_YUAN_TYPE_WEIGHTS := {
	"ling_li": 2.4,
	"dan": 1.8,
	"stat_up": 2.3,
	"shou_yuan": 1.4,
	"technique": 2.4,
	"treasure": 2.0,
	"companion": 1.8,
	"auction": 1.3,
	"heal_percent": 0.9,
	"ling_shi": 0.8,
}

const JI_YUAN_CARD_CHANCE := 0.68
const MIN_CULTIVATION_CARDS_PER_ROUND := 2
const BASE_SHOU_YUAN := 10
const SHOU_YUAN_PER_TI_PO := 2
const MARKET_CULTIVATION_COST := 100
const MARKET_CULTIVATION_GAIN := 20
const MARKET_HEAL_COST := 200
const MARKET_HEAL_PCT := 0.30
const MARKET_BACKPACK_COST := 500
const MARKET_DAN_COSTS := {"筑基丹": 300, "金丹": 800, "元婴丹": 1600}
const DUEL_LING_LI_REQ := 900
const MINOR_STAGE_NAMES := ["一层", "二层", "三层", "四层", "五层", "六层", "七层", "八层", "九层"]
const MINOR_BREAKTHROUGH_BASE_CHANCE := 0.78
const MAJOR_BREAKTHROUGH_BASE_CHANCE := 0.62
const BREAKTHROUGH_QI_GAN_CHANCE := 0.025
const BREAKTHROUGH_JI_YUAN_CHANCE := 0.012
const MINOR_BREAKTHROUGH_FAIL_LOSS_RATE := 0.35
const MAJOR_BREAKTHROUGH_FAIL_LOSS_RATE := 0.45
const MINOR_BREAKTHROUGH_FAIL_DAMAGE := 0.05
const MAJOR_BREAKTHROUGH_FAIL_DAMAGE := 0.12
const ESCAPE_BASE_CHANCE := 0.55
const ESCAPE_SHEN_FA_CHANCE := 0.035
const ESCAPE_SPEED_CHANCE := 0.003
const ESCAPE_ELITE_PENALTY := 0.15
const ESCAPE_FAIL_HURT_MULTIPLIER := 1.25

const CALAMITY_TYPES := {
	"凡品": {"name": "灵力流失", "base_effect": 20, "effect_type": "ling_li_loss"},
	"良品": {"name": "灵力流失", "base_effect": 40, "effect_type": "ling_li_loss"},
	"上品": {"name": "气血损伤", "base_effect": 25, "effect_type": "hp_percent_loss"},
	"极品": {"name": "遭遇敌人", "base_effect": 0, "effect_type": "enemy"},
	"仙品": {"name": "寿元折损", "base_effect": 3, "effect_type": "shou_yuan_loss"},
	"道品": {"name": "古妖拦路", "base_effect": 0, "effect_type": "enemy"},
}

const BASE_STATS := ["体魄", "气感", "经商", "身法", "魅力", "机缘"]

const REALMS := {
	"炼气期": {"ling_li_req": 0, "attack_bonus": 0.0, "defense_bonus": 0.0, "hp_bonus": 0.0, "speed_base": 10, "dan": ""},
	"筑基期": {"ling_li_req": 160, "attack_bonus": 0.20, "defense_bonus": 0.20, "hp_bonus": 0.20, "speed_base": 20, "dan": "筑基丹"},
	"金丹期": {"ling_li_req": 420, "attack_bonus": 0.50, "defense_bonus": 0.40, "hp_bonus": 0.40, "speed_base": 30, "dan": "金丹"},
	"元婴期": {"ling_li_req": 760, "attack_bonus": 1.00, "defense_bonus": 0.80, "hp_bonus": 0.80, "speed_base": 40, "dan": "元婴丹"},
}

const TRIBULATIONS := {
	"筑基期": {"name": "筑基雷劫", "damage_pct": 0.25, "shared_pct": 0.10, "dodge_reward": 20},
	"金丹期": {"name": "金丹火劫", "damage_pct": 0.35, "shared_pct": 0.15, "dodge_reward": 40},
	"元婴期": {"name": "元婴心魔劫", "damage_pct": 0.45, "shared_pct": 0.20, "dodge_reward": 70},
}

const ENEMIES := {
	"上品": {"hp": 25, "attack": 8, "drop_desc": "灵石/灵力"},
	"极品": {"hp": 35, "attack": 12, "drop_desc": "随机功法(上品)"},
	"仙品": {"hp": 50, "attack": 18, "drop_desc": "随机功法(极品)+灵石"},
	"道品": {"hp": 80, "attack": 25, "drop_desc": "随机功法(仙品)+寿元"},
}

const TECHNIQUE_POOL := [
	{"name": "吐纳术", "quality": "良品", "bonuses": {"灵力获取": 0.10}},
	{"name": "淬体诀", "quality": "良品", "bonuses": {"气血上限": 0.15}},
	{"name": "太虚步", "quality": "上品", "bonuses": {"攻击力": 0.10, "防御力": 0.10, "速度": 10}},
	{"name": "回春诀", "quality": "上品", "bonuses": {"每轮回血": 0.05}},
	{"name": "诛仙剑气", "quality": "极品", "bonuses": {"攻击力": 0.20}},
	{"name": "金刚不坏", "quality": "极品", "bonuses": {"防御力": 0.30}},
	{"name": "吸星大法", "quality": "极品", "bonuses": {"攻击力": 0.15, "对方防御": -0.10}},
	{"name": "雷霆万钧", "quality": "仙品", "bonuses": {"攻击力": 0.30}},
	{"name": "天罡正气", "quality": "仙品", "bonuses": {"气血上限": 0.25}},
	{"name": "万魂幡", "quality": "仙品", "bonuses": {"攻击力": 0.15, "气血上限": 0.15}},
	{"name": "九转玄功", "quality": "道品", "bonuses": {"全属性": 0.10}},
	{"name": "云游手札", "quality": "上品", "bonuses": {"灵力获取": 0.15}},
]

const RESONANCE_POOL := {
	"良品": [
		{"name": "吐纳", "desc": "+10%灵力"},
		{"name": "淬体", "desc": "+10%气血"},
		{"name": "锐气", "desc": "+8%攻击"},
		{"name": "铁壁", "desc": "+10%防御"},
		{"name": "轻身", "desc": "+5%闪避+5速度"},
	],
	"上品": [
		{"name": "回春", "desc": "每轮回5%"},
		{"name": "蓄力", "desc": "第3回合起+20%攻击"},
		{"name": "龟息", "desc": "残血+30%防御"},
		{"name": "灵嗅", "desc": "+5%机缘品质"},
		{"name": "避劫", "desc": "-5%灾厄品质"},
	],
	"极品": [
		{"name": "破军", "desc": "15%1.5倍伤"},
		{"name": "逍遥游", "desc": "15%闪避"},
		{"name": "嗜血", "desc": "20%吸血"},
		{"name": "碎甲", "desc": "无视20%防御"},
		{"name": "荆棘", "desc": "反弹15%"},
	],
	"仙品": [
		{"name": "斩天", "desc": "残血伤害翻倍"},
		{"name": "涅槃", "desc": "复活1次30%血"},
		{"name": "清心", "desc": "免疫控制"},
		{"name": "天眷", "desc": "寿元消耗减半"},
		{"name": "夺运", "desc": "抢到机缘额外+15%灵力"},
	],
	"道品": [
		{"name": "先机", "desc": "必定先手"},
		{"name": "洞天", "desc": "所有功法+5%"},
		{"name": "道心", "desc": "扛时天劫-20%伤害"},
	],
}

const TECHNIQUE_RESONANCE_COUNT := {"良品": 1, "上品": 1, "极品": 2, "仙品": 2, "道品": 3}
const TECHNIQUE_RESONANCE_RANGE := {
	"良品": ["良品"],
	"上品": ["上品", "极品"],
	"极品": ["上品", "极品", "仙品"],
	"仙品": ["极品", "仙品", "道品"],
	"道品": ["仙品", "道品"],
}

const RESONANCE_LINKS := [
	{"requires": ["破军", "嗜血"], "name": "血战", "desc": "暴击回血翻倍"},
	{"requires": ["破军", "碎甲"], "name": "摧枯拉朽", "desc": "暴击额外无视10%防御"},
	{"requires": ["逍遥游", "轻身"], "name": "踏雪无痕", "desc": "闪避后下回合攻击+30%"},
	{"requires": ["荆棘", "龟息"], "name": "铜墙铁壁", "desc": "残血反弹翻倍"},
	{"requires": ["回春", "淬体"], "name": "生生不息", "desc": "每轮回血+5%气血上限"},
	{"requires": ["嗜血", "荆棘"], "name": "以战养战", "desc": "反弹也触发吸血"},
	{"requires": ["斩天", "破军"], "name": "一剑封喉", "desc": "对残血暴击率+25%"},
	{"requires": ["涅槃", "龟息"], "name": "向死而生", "desc": "复活后首回合攻击+50%"},
	{"requires": ["蓄力", "碎甲"], "name": "蓄势待发", "desc": "第3回合起无视防御翻倍"},
	{"requires": ["清心", "逍遥游"], "name": "空明", "desc": "闪避后解除负面"},
	{"requires": ["天眷", "夺运"], "name": "天命所归", "desc": "抢到机缘额外寿元+1年"},
	{"requires": ["先机", "破军"], "name": "先发制人", "desc": "首回合暴击率+30%"},
	{"requires": ["道心", "涅槃"], "name": "我道不灭", "desc": "复活气血50%"},
]

const TREASURE_POOL := [
	{"name": "护体金钟", "use_effect": "本次扛伤害减免50%", "refine_bonus": {"防御力": 0.15}},
	{"name": "破甲锥", "use_effect": "本次抢伤害+50%", "refine_bonus": {"攻击力": 0.15}},
	{"name": "替身符", "use_effect": "代受一次伤害", "refine_bonus": {"气血上限": 0.15}},
	{"name": "窥心镜", "use_effect": "可看对方选择", "refine_bonus": {"被预判概率": -0.30}},
	{"name": "缚仙索", "use_effect": "强制对方下回选让", "refine_bonus": {"对方防御": -0.10}},
	{"name": "爆灵珠", "use_effect": "伤害+100%自己受50%反噬", "refine_bonus": {"攻击力": 0.25, "气血上限": -0.10}},
	{"name": "聚灵幡", "use_effect": "本次机缘灵力+100%", "refine_bonus": {"灵力获取": 0.20}},
	{"name": "定魂钟", "use_effect": "天劫伤害减免50%", "refine_bonus": {"气血上限": 0.20}},
	{"name": "飞仙羽", "use_effect": "战斗无条件逃跑", "refine_bonus": {"速度": 20}},
]

const COMPANION_POOL := [
	{"name": "沈霜雁", "title": "散修药师", "quality": "上品", "bonus_type": "round_heal", "bonus_value": 0.05, "effect_desc": "每轮结束回血5%"},
	{"name": "铁无涯", "title": "铸器学徒", "quality": "上品", "bonus_type": "treasure_refine", "bonus_value": 0.05, "effect_desc": "法宝炼化效果+5%"},
	{"name": "柳青荇", "title": "灵田看守", "quality": "上品", "bonus_type": "灵力获取", "bonus_value": 0.08, "effect_desc": "灵力获取+8%"},
	{"name": "燕小七", "title": "消息贩子", "quality": "上品", "bonus_type": "calamity_quality", "bonus_value": -0.05, "effect_desc": "灾厄品质-5%"},
	{"name": "楚星河", "title": "剑宗弃徒", "quality": "极品", "bonus_type": "攻击力", "bonus_value": 0.12, "effect_desc": "战斗攻击+12%"},
	{"name": "温如玉", "title": "丹鼎阁外门", "quality": "极品", "bonus_type": "dan_discount", "bonus_value": -0.20, "effect_desc": "丹药材料-20%"},
	{"name": "霍千山", "title": "御兽宗传人", "quality": "极品", "bonus_type": "enemy_opening_damage", "bonus_value": 0.08, "effect_desc": "遇敌先造成8%气血伤害"},
	{"name": "云秋水", "title": "符箓世家", "quality": "极品", "bonus_type": "treasure_extra_use", "bonus_value": 1.0, "effect_desc": "法宝可用两次"},
	{"name": "殷破军", "title": "征北将军", "quality": "仙品", "bonus_type": "攻击力", "bonus_value": 0.15, "effect_desc": "攻击+15%对决首击+20%"},
	{"name": "洛清商", "title": "天机阁护法", "quality": "仙品", "bonus_type": "速度", "bonus_value": 15.0, "effect_desc": "速度+15预览1组机缘"},
	{"name": "花弄影", "title": "百花谷主", "quality": "仙品", "bonus_type": "round_heal", "bonus_value": 0.08, "effect_desc": "回血8%免疫陨落1次"},
	{"name": "司徒墨", "title": "商会会长", "quality": "仙品", "bonus_type": "round_ling_shi", "bonus_value": 300.0, "effect_desc": "每轮额外灵石+300"},
	{"name": "顾长生", "title": "守墓人", "quality": "道品", "bonus_type": "tribulation_damage", "bonus_value": -0.15, "effect_desc": "寿元消耗减半天劫伤害-15%"},
	{"name": "叶倾仙", "title": "半步飞升", "quality": "道品", "bonus_type": "全属性", "bonus_value": 0.08, "effect_desc": "全属性+8%联动概率+20%"},
]

const COMPANION_LAST_WORDS := {
	"沈霜雁": "跟了你一路，本以为你能飞升。罢了，丹炉已凉，我随你去。",
	"楚星河": "当年在宗门被逐，无人信我。只有你将我招入麾下。剑已断，不悔。",
	"花弄影": "我替你挡了一次陨落。可惜，挡不了第二次。",
	"顾长生": "守了一辈子的墓，最后要守的是你的。",
	"叶倾仙": "只差半步……你只差半步就能飞升。我这一生，又看走眼了。",
	"铁无涯": "你炼化的每一件法宝，都有我的火印。",
	"柳青荇": "灵田里的草还没收呢……算了。",
	"燕小七": "消息是卖给你了，可你没能用到最后。",
	"温如玉": "那炉丹，终究没等到出炉。",
	"霍千山": "我的灵兽还在等你……",
	"云秋水": "符纸还没用完，你就……",
	"殷破军": "将军百战死，仙路亦战场。",
	"洛清商": "天机已尽，我看到了你的结局……也看到了自己的。",
	"司徒墨": "商会可以不要，但你不能死啊。",
}

const NEXT_REALM_MAP := {
	"炼气期": "筑基期",
	"筑基期": "金丹期",
	"金丹期": "元婴期",
}

var current_state: int = GameState.STAT_ALLOCATION
var round_number: int = 0
var player_a: PlayerData
var player_b: PlayerData
var current_lottery_results: Array = []
var current_lottery_cards: Array = []
var current_card_index: int = 0
var lottery_energy_injections: Dictionary = {}
var lottery_energy_started: bool = false
var current_bargain_index: int = 0
var current_enemy: Dictionary = {}
var enemy_elite: bool = false
var current_auction: Dictionary = {}
var auction_choices: Dictionary = {}
var battle_contributions: Dictionary = {}
var battle_choices: Dictionary = {}
var battle_log: Array = []
var stat_allocation_started: bool = false
var bargain_choices: Dictionary = {}
var bargain_continue_votes: Dictionary = {}
var pending_continue_next_index: int = -1
var pending_continue_round_finished: bool = false
var pending_backpack_items: Dictionary = {}
var round_started: bool = false
var bargain_direction: int = 1
var rng := RandomNumberGenerator.new()
var pending_breakthrough_player: PlayerData = null
var tribulation_next_realm: String = ""
var pending_tribulation_data: Dictionary = {}
var tribulation_choices: Dictionary = {}
var duel_data: Dictionary = {}
var duel_round_number: int = 0
var pending_duel_winner_key: String = ""
var pending_duel_loser_key: String = ""
var ending_scroll_data: Dictionary = {}
var transition_layer: CanvasLayer = null
var transition_rect: ColorRect = null
var transition_active: bool = false
var pending_transition_path: String = ""
var last_transition_path: String = ""


func _ready() -> void:
	rng.randomize()
	player_a = PlayerData.new()
	player_a.player_name = "玩家A"

	player_b = PlayerData.new()
	player_b.player_name = "玩家B"


func transition_to_scene(scene_path: String) -> void:
	if scene_path == "":
		return
	if transition_active:
		pending_transition_path = scene_path
		return

	transition_active = true
	last_transition_path = scene_path
	_ensure_transition_layer()
	transition_rect.visible = true
	transition_rect.color = Color(0.0, 0.0, 0.0, 0.0)

	var tween := create_tween()
	tween.tween_property(transition_rect, "color:a", 1.0, 0.3)
	tween.tween_callback(func() -> void:
		get_tree().change_scene_to_file(scene_path)
	)
	tween.tween_interval(0.05)
	tween.tween_property(transition_rect, "color:a", 0.0, 0.3)
	tween.tween_callback(_finish_scene_transition)


func _ensure_transition_layer() -> void:
	if transition_layer != null and is_instance_valid(transition_layer):
		return

	transition_layer = CanvasLayer.new()
	transition_layer.layer = 128
	transition_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(transition_layer)

	transition_rect = ColorRect.new()
	transition_rect.color = Color(0.0, 0.0, 0.0, 0.0)
	transition_rect.visible = false
	transition_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transition_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	transition_layer.add_child(transition_rect)


func _finish_scene_transition() -> void:
	if transition_rect != null:
		transition_rect.visible = false
	transition_active = false
	var next_path := pending_transition_path
	pending_transition_path = ""
	if next_path != "" and next_path != last_transition_path:
		transition_to_scene(next_path)


func change_state(new_state: int) -> void:
	current_state = new_state
	game_state_changed.emit(current_state)

	if current_state == GameState.ROUND_START and NetworkManager.is_host:
		start_round()


func get_player_by_peer(peer_id: int) -> PlayerData:
	if player_a != null and player_a.peer_id == peer_id:
		return player_a
	if player_b != null and player_b.peer_id == peer_id:
		return player_b
	return null


func _normalize_stats(stats: Dictionary) -> Dictionary:
	var normalized: Dictionary = {}
	for stat in BASE_STATS:
		normalized[stat] = int(round(float(stats.get(stat, 0))))
	if stats.has("悟性") and not stats.has("经商"):
		normalized["经商"] = int(round(float(stats.get("悟性", 0))))
	return normalized


func calculate_initial_shou_yuan(player: PlayerData) -> int:
	if player == null:
		return BASE_SHOU_YUAN
	return BASE_SHOU_YUAN + int(player.stats.get("体魄", 0)) * SHOU_YUAN_PER_TI_PO


func initialize_player_life(player: PlayerData) -> void:
	if player == null:
		return
	player.shou_yuan = calculate_initial_shou_yuan(player)
	player.final_attributes["initial_shou_yuan"] = player.shou_yuan
	player.qi_xue = _get_player_max_hp(player)


func on_stat_allocation_received(peer_id: int, data: Dictionary) -> void:
	var player: PlayerData = get_player_by_peer(peer_id)
	if player == null:
		return

	var stats: Dictionary = data.get("stats", {}) as Dictionary
	var hour_bonus: Dictionary = data.get("hour_bonus", {}) as Dictionary
	player.stats = _normalize_stats(stats)
	player.minor_stage = 1
	player.remain_points = 0
	player.final_attributes["hour_bonus"] = hour_bonus.duplicate(true)
	apply_hour_bonus_to_player(player, hour_bonus)
	initialize_player_life(player)
	start_game_main_if_stats_ready()


func apply_hour_bonus_to_player(player: PlayerData, hour_bonus: Dictionary) -> void:
	if bool(player.final_attributes.get("hour_bonus_applied", false)):
		return
	for bonus_name in hour_bonus:
		var refined_name := _get_refined_bonus_name(str(bonus_name))
		player.refined_bonuses[refined_name] = float(player.refined_bonuses.get(refined_name, 0.0)) + float(hour_bonus[bonus_name])
	player.final_attributes["hour_bonus_applied"] = true


func start_game_main_if_stats_ready() -> void:
	if stat_allocation_started:
		return
	if not _player_stats_complete(player_a) or not _player_stats_complete(player_b):
		return
	if NetworkManager.connected and not NetworkManager.is_host:
		return

	stat_allocation_started = true
	player_a.qi_xue = _get_player_max_hp(player_a)
	player_b.qi_xue = _get_player_max_hp(player_b)
	await get_tree().create_timer(1.0).timeout
	change_state(GameState.ROUND_START)
	_change_scene_to_game_main.rpc()


func _player_stats_complete(player: PlayerData) -> bool:
	if player == null:
		return false

	var total := 0
	for value in player.stats.values():
		total += int(value)
	return total == 12


func _get_refined_bonus_name(bonus_name: String) -> String:
	match bonus_name:
		"攻击":
			return "攻击力"
		"防御":
			return "防御力"
		"气血":
			return "气血上限"
		_:
			return bonus_name


@rpc("any_peer", "reliable", "call_local")
func _change_scene_to_game_main() -> void:
	transition_to_scene("res://scenes/game_main.tscn")


@rpc("authority", "call_remote", "reliable")
func _start_duel() -> void:
	transition_to_scene("res://scenes/duel.tscn")


func check_duel_trigger() -> bool:
	if not NetworkManager.is_host:
		return false
	if current_state == GameState.DUEL or current_state == GameState.ENDING:
		return true
	if _can_player_trigger_duel(player_a) or _can_player_trigger_duel(player_b):
		_trigger_final_duel()
		return true
	return false


func _can_player_trigger_duel(player: PlayerData) -> bool:
	return player != null and player.realm == "元婴期" and _get_minor_stage(player) >= MINOR_STAGE_NAMES.size() and player.ling_li >= DUEL_LING_LI_REQ


func get_cultivation_stage_name(player: PlayerData) -> String:
	if player == null:
		return ""
	var root_name: String = _realm_stage_root(player.realm)
	var stage: int = _get_minor_stage(player)
	return root_name + str(MINOR_STAGE_NAMES[stage - 1])


func get_cultivation_stage_name_for(realm: String, ling_li: int) -> String:
	if realm == "":
		return ""

	var root_name: String = _realm_stage_root(realm)
	var current_req: int = get_realm_ling_li_req(realm)
	var next_req: int = get_next_major_realm_req(realm, ling_li)
	if next_req <= current_req:
		return root_name

	var span: int = maxi(1, next_req - current_req)
	var progress: int = clampi(ling_li - current_req, 0, span)
	if progress >= span:
		return root_name + "圆满"

	var stage_index: int = int(floor(float(progress) / float(span) * float(MINOR_STAGE_NAMES.size())))
	stage_index = clampi(stage_index, 0, MINOR_STAGE_NAMES.size() - 1)
	return root_name + str(MINOR_STAGE_NAMES[stage_index])


func get_next_major_realm_req(realm: String, current_ling_li: int = 0) -> int:
	var next_realm: String = str(NEXT_REALM_MAP.get(realm, ""))
	if next_realm != "":
		return get_realm_ling_li_req(next_realm)
	if realm == "元婴期":
		return DUEL_LING_LI_REQ
	return maxi(current_ling_li, get_realm_ling_li_req(realm) + 1)


func get_current_stage_floor_req(player: PlayerData) -> int:
	if player == null:
		return 0
	var stage: int = _get_minor_stage(player)
	if stage <= 1:
		return get_realm_ling_li_req(player.realm)
	return _minor_stage_req(player, stage)


func get_next_breakthrough_req(player: PlayerData) -> int:
	if player == null:
		return 0
	var stage: int = _get_minor_stage(player)
	if stage < MINOR_STAGE_NAMES.size():
		return _minor_stage_req(player, stage + 1)
	return get_next_major_realm_req(player.realm, player.ling_li)


func get_next_breakthrough_name(player: PlayerData) -> String:
	if player == null:
		return ""
	var stage: int = _get_minor_stage(player)
	var root_name: String = _realm_stage_root(player.realm)
	if stage < MINOR_STAGE_NAMES.size():
		return root_name + str(MINOR_STAGE_NAMES[stage])
	var next_realm: String = str(NEXT_REALM_MAP.get(player.realm, ""))
	if next_realm != "":
		return next_realm
	if player.realm == "元婴期":
		return "仙位之争"
	return ""


func _get_minor_stage(player: PlayerData) -> int:
	if player == null:
		return 1
	player.minor_stage = clampi(player.minor_stage, 1, MINOR_STAGE_NAMES.size())
	return player.minor_stage


func _minor_stage_req(player: PlayerData, target_stage: int) -> int:
	var stage: int = clampi(target_stage, 1, MINOR_STAGE_NAMES.size())
	var current_req: int = get_realm_ling_li_req(player.realm)
	var next_req: int = get_next_major_realm_req(player.realm, player.ling_li)
	var span: int = maxi(1, next_req - current_req)
	var step_index: int = maxi(0, stage - 1)
	return current_req + int(ceil(float(span) * float(step_index) / float(MINOR_STAGE_NAMES.size())))


func get_breakthrough_success_chance(player: PlayerData, breakthrough_type: String) -> float:
	if player == null:
		return 0.0
	var base_chance: float = MAJOR_BREAKTHROUGH_BASE_CHANCE if breakthrough_type == "major" else MINOR_BREAKTHROUGH_BASE_CHANCE
	var qi_gan_bonus: float = float(player.stats.get("气感", 0)) * BREAKTHROUGH_QI_GAN_CHANCE
	var ji_yuan_bonus: float = float(player.stats.get("机缘", 0)) * BREAKTHROUGH_JI_YUAN_CHANCE
	return clamp(base_chance + qi_gan_bonus + ji_yuan_bonus, 0.20, 0.95)


func _apply_breakthrough_failure(player: PlayerData, breakthrough_type: String) -> Dictionary:
	var floor_req: int = get_current_stage_floor_req(player)
	var target_req: int = get_next_breakthrough_req(player)
	var span: int = maxi(1, target_req - floor_req)
	var loss_rate: float = MAJOR_BREAKTHROUGH_FAIL_LOSS_RATE if breakthrough_type == "major" else MINOR_BREAKTHROUGH_FAIL_LOSS_RATE
	var damage_rate: float = MAJOR_BREAKTHROUGH_FAIL_DAMAGE if breakthrough_type == "major" else MINOR_BREAKTHROUGH_FAIL_DAMAGE
	var loss: int = maxi(3, int(round(float(span) * loss_rate)))
	var before_ling_li: int = player.ling_li
	player.ling_li = maxi(floor_req, player.ling_li - loss)
	loss = before_ling_li - player.ling_li

	var max_hp: int = _get_player_max_hp(player)
	var damage: int = maxi(1, int(round(float(max_hp) * damage_rate)))
	player.qi_xue = maxi(1, player.qi_xue - damage)
	return {"ling_li_loss": loss, "hp_damage": damage}


func get_realm_ling_li_req(realm: String) -> int:
	if realm == "":
		return 0
	var realm_data: Dictionary = REALMS.get(realm, {}) as Dictionary
	return int(realm_data.get("ling_li_req", 0))


func _realm_stage_root(realm: String) -> String:
	if realm.ends_with("期"):
		return realm.left(realm.length() - 1)
	return realm


func _trigger_final_duel() -> void:
	duel_data.clear()
	change_state(GameState.DUEL)
	duel_triggered.emit()
	_start_duel.rpc()
	transition_to_scene("res://scenes/duel.tscn")


@rpc("authority", "call_remote", "reliable")
func _show_ending(data: Dictionary) -> void:
	ending_scroll_data = _select_ending_scroll_data(data)
	transition_to_scene("res://scenes/ending.tscn")


@rpc("authority", "call_remote", "reliable")
func _change_scene_to_ending(data: Dictionary) -> void:
	ending_scroll_data = _select_ending_scroll_data(data)
	transition_to_scene("res://scenes/ending.tscn")


@rpc("authority", "call_remote", "reliable")
func _show_battle(data: Dictionary) -> void:
	current_enemy = data.duplicate(true)
	transition_to_scene("res://scenes/battle.tscn")


@rpc("authority", "call_remote", "reliable")
func _update_battle(data: Dictionary) -> void:
	on_battle_update(data)


@rpc("authority", "call_remote", "reliable")
func _end_battle(data: Dictionary) -> void:
	battle_ended.emit(data)
	await get_tree().create_timer(1.2).timeout
	if current_card_index >= 0 and current_card_index < current_lottery_cards.size():
		change_state(GameState.BARGAIN)
	transition_to_scene("res://scenes/game_main.tscn")


func ensure_round_started() -> void:
	if NetworkManager.is_host and current_state == GameState.ROUND_START and not round_started:
		start_round()


func start_round() -> void:
	if round_started:
		return

	round_started = true
	round_number += 1
	player_a.shou_yuan = maxi(0, player_a.shou_yuan - 1)
	player_b.shou_yuan = maxi(0, player_b.shou_yuan - 1)
	player_a.final_attributes["last_round_cultivation"] = 0
	player_a.final_attributes["last_round_stage"] = ""
	player_b.final_attributes["last_round_cultivation"] = 0
	player_b.final_attributes["last_round_stage"] = ""
	if check_duel_trigger():
		return
	current_card_index = 0
	current_bargain_index = 0
	lottery_energy_injections.clear()
	lottery_energy_started = false
	bargain_continue_votes.clear()
	pending_continue_next_index = -1
	pending_continue_round_finished = false
	pending_backpack_items.clear()
	bargain_direction = 1
	bargain_choices.clear()
	current_lottery_cards = generate_lottery_cards()
	change_state(GameState.LOTTERY)
	var hidden_cards: Array = []
	for i in current_lottery_cards.size():
		hidden_cards.append({"revealed": false})
	current_lottery_results = hidden_cards.duplicate(true)
	var data: Dictionary = {
		"round_number": round_number,
		"results": hidden_cards,
		"index": current_bargain_index,
		"direction": bargain_direction,
		"player_a": _player_snapshot(player_a),
		"player_b": _player_snapshot(player_b),
	}
	NetworkManager.send_message("lottery_generated", data)
	lottery_generated.emit(hidden_cards)


func on_lottery_energy_injected(peer_id: int) -> void:
	if not NetworkManager.is_host:
		return
	if current_state != GameState.LOTTERY:
		return
	if lottery_energy_started:
		return

	var inject_peer_id: int = peer_id
	if inject_peer_id <= 0:
		inject_peer_id = 1
	lottery_energy_injections[inject_peer_id] = true

	var total_required: int = _lottery_energy_required_count()
	var injected_count: int = mini(lottery_energy_injections.size(), total_required)
	var update_data: Dictionary = {"count": injected_count, "total": total_required}
	NetworkManager.send_message("lottery_energy_updated", update_data)
	lottery_energy_updated.emit(injected_count, total_required)

	if injected_count >= total_required:
		lottery_energy_started = true
		NetworkManager.send_message("lottery_energy_ready", {})
		lottery_energy_ready.emit()


func on_lottery_energy_ready() -> void:
	lottery_energy_started = true
	lottery_energy_ready.emit()


func _lottery_energy_required_count() -> int:
	if player_a != null and player_b != null and player_a.peer_id > 0 and player_b.peer_id > 0:
		return 2
	return 1


func begin_lottery_reveal() -> void:
	if not NetworkManager.is_host:
		return
	if current_state != GameState.LOTTERY:
		return
	if not lottery_energy_started:
		return
	_reveal_card_for_bargain(current_card_index)


func _reveal_card_for_bargain(index: int) -> void:
	if index < 0 or index >= current_lottery_cards.size():
		return
	var card: Dictionary = current_lottery_cards[index] as Dictionary
	if not card.has("effect_type"):
		card = _generate_single_lottery_card()
		current_lottery_cards[index] = card
	var reveal_data: Dictionary = {"index": index, "card": card}
	NetworkManager.send_message("lottery_card_revealed", reveal_data)
	on_lottery_card_revealed(reveal_data)
	if str(card.get("effect_type", "")) == "enemy":
		await get_tree().create_timer(0.9).timeout
		_start_enemy_battle_from_card(index, card)
		return
	if str(card.get("effect_type", "")) == "auction":
		await get_tree().create_timer(0.9).timeout
		_start_auction_from_card(index, card)
		return
	var ready_data: Dictionary = {
		"index": index,
		"direction": bargain_direction,
		"results": current_lottery_results.duplicate(true),
	}
	NetworkManager.send_message("lottery_ready", ready_data)
	on_lottery_ready(ready_data)


func _start_enemy_battle_from_card(index: int, card: Dictionary) -> void:
	if not NetworkManager.is_host:
		return
	card["settled"] = true
	if index >= 0 and index < current_lottery_cards.size():
		current_lottery_cards[index] = card
	if index >= 0 and index < current_lottery_results.size():
		current_lottery_results[index] = card
	current_card_index = index + 1
	current_bargain_index = current_card_index
	pending_continue_next_index = current_card_index
	pending_continue_round_finished = current_card_index < 0 or current_card_index >= current_lottery_cards.size()
	bargain_choices.clear()
	bargain_continue_votes.clear()
	start_battle(str(card.get("quality", "极品")))


func _start_auction_from_card(index: int, card: Dictionary) -> void:
	if not NetworkManager.is_host:
		return

	current_auction = {
		"index": index,
		"card": card.duplicate(true),
		"lots": generate_auction_lots(str(card.get("quality", "良品"))),
	}
	auction_choices.clear()
	current_card_index = index
	current_bargain_index = index
	change_state(GameState.AUCTION)

	var data: Dictionary = {
		"index": index,
		"card": card.duplicate(true),
		"lots": (current_auction.get("lots", []) as Array).duplicate(true),
		"player_a": _player_snapshot(player_a),
		"player_b": _player_snapshot(player_b),
	}
	NetworkManager.send_message("auction_started", data)
	on_auction_started(data)


func on_auction_started(data: Dictionary) -> void:
	current_auction = {
		"index": int(data.get("index", current_card_index)),
		"card": (data.get("card", {}) as Dictionary).duplicate(true),
		"lots": (data.get("lots", []) as Array).duplicate(true),
	}
	_apply_player_snapshot(player_a, data.get("player_a", {}) as Dictionary)
	_apply_player_snapshot(player_b, data.get("player_b", {}) as Dictionary)
	current_card_index = int(current_auction.get("index", current_card_index))
	current_bargain_index = current_card_index
	auction_choices.clear()
	change_state(GameState.AUCTION)
	auction_started.emit(current_auction.duplicate(true))


func on_lottery_generated(data: Dictionary) -> void:
	round_number = int(data.get("round_number", round_number))
	current_lottery_results = (data.get("results", []) as Array).duplicate(true)
	if not NetworkManager.is_host:
		current_lottery_cards = current_lottery_results.duplicate(true)
	current_bargain_index = int(data.get("index", 0))
	bargain_direction = int(data.get("direction", 1))
	_apply_player_snapshot(player_a, data.get("player_a", {}) as Dictionary)
	_apply_player_snapshot(player_b, data.get("player_b", {}) as Dictionary)
	bargain_choices.clear()
	change_state(GameState.LOTTERY)
	lottery_generated.emit(current_lottery_results)


func generate_lottery_cards() -> Array:
	var cards: Array = []
	var cultivation_count: int = 0
	for i in 10:
		var card: Dictionary = _generate_single_lottery_card()
		if str(card.get("effect_type", "")) == "ling_li":
			cultivation_count += 1
		cards.append(card)

	while cultivation_count < MIN_CULTIVATION_CARDS_PER_ROUND:
		var ji_yuan_stat: int = _current_lottery_luck_stat()
		var replace_index: int = rng.randi_range(0, cards.size() - 1)
		var cultivation_card: Dictionary = generate_cultivation_ji_yuan(ji_yuan_stat)
		cultivation_card["type"] = "机缘"
		cultivation_card["settled"] = false
		var old_card: Dictionary = cards[replace_index] as Dictionary
		if str(old_card.get("effect_type", "")) == "ling_li":
			continue
		cards[replace_index] = cultivation_card
		cultivation_count += 1
	return cards


func _current_lottery_luck_stat() -> int:
	return maxi(int(player_a.stats.get("机缘", 0)), int(player_b.stats.get("机缘", 0)))


func _generate_single_lottery_card() -> Dictionary:
	var ji_yuan_stat: int = _current_lottery_luck_stat()
	var is_ji_yuan: bool = rng.randf() < JI_YUAN_CARD_CHANCE
	var card: Dictionary = generate_ji_yuan(ji_yuan_stat) if is_ji_yuan else generate_calamity(ji_yuan_stat)
	card["type"] = "机缘" if is_ji_yuan else "灾厄"
	card["settled"] = false
	return card


func on_lottery_card_revealed(data: Dictionary) -> void:
	var index: int = int(data.get("index", 0))
	var card: Dictionary = data.get("card", {}) as Dictionary
	while current_lottery_cards.size() <= index:
		current_lottery_cards.append({"revealed": false})
	while current_lottery_results.size() <= index:
		current_lottery_results.append({"revealed": false})
	if not NetworkManager.is_host:
		current_lottery_cards[index] = card
	current_lottery_results[index] = card
	current_card_index = index
	lottery_card_revealed.emit(index, card)


func on_lottery_ready(data: Dictionary) -> void:
	current_card_index = int(data.get("index", 0))
	current_bargain_index = current_card_index
	bargain_direction = 1
	var incoming_results: Array = data.get("results", []) as Array
	if not incoming_results.is_empty():
		current_lottery_results = incoming_results.duplicate(true)
		if not NetworkManager.is_host:
			current_lottery_cards = incoming_results.duplicate(true)
	change_state(GameState.BARGAIN)
	bargain_ready.emit(current_bargain_index)


func settle_card_bargain(choice_a: String, choice_b: String, card: Dictionary) -> Dictionary:
	var result_a: Dictionary = _empty_bargain_result()
	var result_b: Dictionary = _empty_bargain_result()
	var card_type: String = str(card.get("type", ""))
	var effect_type: String = str(card.get("effect_type", ""))
	var base_value: float = float(card.get("effect_value", card.get("value", 0)))
	if effect_type in ["technique", "treasure", "dan", "companion", "auction", "enemy", "tribulation"] and base_value <= 0.0:
		base_value = 1.0
	result_a["card"] = card.duplicate(true)
	result_b["card"] = card.duplicate(true)

	if card_type == "机缘":
		if choice_a == "抢" and choice_b == "抢":
			result_a["special"] = "天道反噬！机缘消散"
			result_b["special"] = "天道反噬！机缘消散"
			result_a["log"] = result_a["special"]
			result_b["log"] = result_a["special"]
		elif choice_a == "让" and choice_b == "让":
			var gain_share_a: float = _get_charm_share(true)
			var gain_share_b: float = 1.0 - gain_share_a
			result_a["gain"] = base_value * 0.5 * gain_share_a
			result_b["gain"] = base_value * 0.5 * gain_share_b
			result_a["special"] = "天道酬和，各得一半"
			result_b["special"] = result_a["special"]
			result_a["log"] = result_a["special"]
			result_b["log"] = result_a["special"]
		elif choice_a == "抢" and choice_b == "让":
			result_a["gain"] = base_value
			result_a["special"] = "你抢得机缘"
			result_b["special"] = "他抢得机缘"
			result_a["log"] = "玩家A抢得机缘"
			result_b["log"] = result_a["log"]
		else:
			result_b["gain"] = base_value
			result_a["special"] = "他抢得机缘"
			result_b["special"] = "你抢得机缘"
			result_a["log"] = "玩家B抢得机缘"
			result_b["log"] = result_a["log"]
	else:
		if choice_a == "抢" and choice_b == "抢":
			result_a["lose"] = base_value
			result_b["lose"] = base_value
			result_a["special"] = "双双躲避，灾厄扩散"
			result_b["special"] = result_a["special"]
			result_a["log"] = result_a["special"]
			result_b["log"] = result_a["special"]
		elif choice_a == "让" and choice_b == "让":
			var penalty_share_a: float = _get_charm_share(false)
			var penalty_share_b: float = 1.0 - penalty_share_a
			result_a["lose"] = base_value * 0.5 * penalty_share_a
			result_b["lose"] = base_value * 0.5 * penalty_share_b
			result_a["special"] = "共同承担，灾厄减轻"
			result_b["special"] = result_a["special"]
			result_a["log"] = result_a["special"]
			result_b["log"] = result_a["special"]
		elif choice_a == "抢" and choice_b == "让":
			result_b["lose"] = base_value
			result_a["special"] = "你躲开灾厄"
			result_b["special"] = "你承担灾厄"
			result_a["log"] = "玩家A躲避，玩家B承担"
			result_b["log"] = result_a["log"]
		else:
			result_a["lose"] = base_value
			result_a["special"] = "你承担灾厄"
			result_b["special"] = "你躲开灾厄"
			result_a["log"] = "玩家B躲避，玩家A承担"
			result_b["log"] = result_a["log"]
	return {
		"player_a": result_a,
		"player_b": result_b,
		"player_a_result": result_a,
		"player_b_result": result_b,
	}


func apply_bargain_result(player: PlayerData, result: Dictionary) -> void:
	if player == null:
		return

	var card: Dictionary = result.get("card", {}) as Dictionary
	var gain: float = float(result.get("gain", 0.0))
	var lose: float = float(result.get("lose", 0.0))
	if str(card.get("type", "")) == "机缘" and gain > 0.0:
		result["gain_message"] = _apply_ji_yuan(player, card, gain)
	if str(card.get("type", "")) == "灾厄" and lose > 0.0:
		result["lose_message"] = _apply_calamity(player, card, lose)

	player.total_qiang_count += 1 if result.get("choice", "") == "抢" else 0
	player.total_rang_count += 1 if result.get("choice", "") == "让" else 0
	match str(result.get("special", "")):
		"天道反噬！机缘消散", "双双躲避，灾厄扩散":
			player.total_shuang_qiang += 1
		"天道酬和，各得一半", "共同承担，灾厄减轻":
			player.total_shuang_rang += 1


func _get_charm_share(for_gain: bool) -> float:
	var charm_a: int = int(player_a.stats.get("魅力", 0))
	var charm_b: int = int(player_b.stats.get("魅力", 0))
	var share_a: float = 0.5
	if charm_a > charm_b:
		share_a += (1.0 if for_gain else -1.0) * float(charm_a) * 0.05
	elif charm_b > charm_a:
		share_a -= (1.0 if for_gain else -1.0) * float(charm_b) * 0.05
	return clamp(share_a, 0.1, 0.9)


func on_bargain_choice_received(peer_id: int, data: Dictionary) -> void:
	if not NetworkManager.is_host:
		return
	if current_lottery_results.is_empty():
		return

	var choice: String = str(data.get("choice", ""))
	var index: int = int(data.get("index", current_card_index))
	if index != current_card_index or choice == "":
		return

	var player_key: String = "a" if peer_id == player_a.peer_id else "b"
	bargain_choices[player_key] = choice
	if not bargain_choices.has("a") or not bargain_choices.has("b"):
		return

	var card: Dictionary = current_lottery_cards[current_card_index]
	var settled: Dictionary = settle_card_bargain(str(bargain_choices["a"]), str(bargain_choices["b"]), card)
	settled["player_a"]["choice"] = bargain_choices["a"]
	settled["player_b"]["choice"] = bargain_choices["b"]
	settled["player_a_result"] = settled["player_a"]
	settled["player_b_result"] = settled["player_b"]
	apply_bargain_result(player_a, settled["player_a"])
	apply_bargain_result(player_b, settled["player_b"])
	card["settled"] = true
	current_lottery_cards[current_card_index] = card
	if current_card_index >= 0 and current_card_index < current_lottery_results.size():
		current_lottery_results[current_card_index] = card

	var next_index: int = current_card_index + 1
	bargain_continue_votes.clear()
	pending_continue_next_index = next_index
	pending_continue_round_finished = next_index < 0 or next_index >= current_lottery_cards.size()

	var data_out := {
		"index": current_card_index,
		"card": card,
		"choice_a": bargain_choices["a"],
		"choice_b": bargain_choices["b"],
		"settled": settled,
		"player_a": _player_snapshot(player_a),
		"player_b": _player_snapshot(player_b),
		"pending_backpack_items": pending_backpack_items.duplicate(true),
		"results": current_lottery_results.duplicate(true),
		"next_index": next_index,
		"round_finished": next_index < 0 or next_index >= current_lottery_cards.size(),
	}
	NetworkManager.send_message("bargain_settled", data_out)
	on_bargain_settled(data_out)


func on_bargain_settled(data: Dictionary) -> void:
	_apply_player_snapshot(player_a, data.get("player_a", {}))
	_apply_player_snapshot(player_b, data.get("player_b", {}))
	pending_backpack_items = (data.get("pending_backpack_items", pending_backpack_items) as Dictionary).duplicate(true)
	var incoming_results: Array = data.get("results", []) as Array
	if not incoming_results.is_empty():
		current_lottery_results = incoming_results.duplicate(true)
		if not NetworkManager.is_host:
			current_lottery_cards = incoming_results.duplicate(true)
	var settled_index: int = int(data.get("index", current_card_index))
	var settled_card: Dictionary = data.get("card", {}) as Dictionary
	if not settled_card.is_empty() and settled_index >= 0:
		while current_lottery_results.size() <= settled_index:
			current_lottery_results.append({"revealed": false})
		current_lottery_results[settled_index] = settled_card
	if not settled_card.is_empty() and settled_index >= 0 and settled_index < current_lottery_cards.size():
		current_lottery_cards[settled_index] = settled_card
	current_card_index = int(data.get("next_index", current_card_index + 1))
	current_bargain_index = current_card_index
	pending_continue_next_index = current_card_index
	pending_continue_round_finished = bool(data.get("round_finished", false))
	bargain_choices.clear()
	bargain_result.emit(data)


func on_bargain_continue_received(peer_id: int, _data: Dictionary = {}) -> void:
	if not NetworkManager.is_host:
		return
	if not pending_backpack_items.is_empty():
		var block_data: Dictionary = _backpack_update_data(peer_id, "背包已满，先清理背包")
		NetworkManager.send_message("backpack_updated", block_data)
		on_backpack_updated(block_data)
		return
	if pending_continue_next_index < 0 and not pending_continue_round_finished:
		return

	var continue_peer_id: int = peer_id
	if continue_peer_id <= 0:
		continue_peer_id = 1
	bargain_continue_votes[continue_peer_id] = true

	var total_required: int = _lottery_energy_required_count()
	if bargain_continue_votes.size() < total_required:
		return

	bargain_continue_votes.clear()
	if check_duel_trigger():
		return
	if pending_continue_round_finished:
		pending_continue_next_index = -1
		pending_continue_round_finished = false
		check_breakthrough()
		return

	var reveal_index: int = pending_continue_next_index
	pending_continue_next_index = -1
	pending_continue_round_finished = false
	_reveal_card_for_bargain(reveal_index)


func get_adjusted_quality_prob(ji_yuan_stat: int, is_calamity: bool = false) -> Dictionary:
	var probs: Dictionary = QUALITY_PROBS.duplicate(true)
	var shift: float = float(ji_yuan_stat) * (-0.01 if is_calamity else 0.02)
	var low_qualities: Array = ["凡品", "良品"]
	var high_qualities: Array = ["极品", "仙品", "道品"]
	var transfer: float = absf(shift)

	if shift > 0.0:
		var removed: float = _redistribute_from_group(probs, low_qualities, transfer)
		_redistribute_to_group(probs, high_qualities, removed)
	elif shift < 0.0:
		var removed: float = _redistribute_from_group(probs, high_qualities, transfer)
		_redistribute_to_group(probs, low_qualities, removed)

	_normalize_probs(probs)
	return probs


func roll_quality(probs: Dictionary) -> String:
	var roll: float = rng.randf()
	var cursor: float = 0.0
	for quality in QUALITY_PROBS.keys():
		cursor += float(probs.get(quality, 0.0))
		if roll <= cursor:
			return str(quality)
	return "凡品"


func generate_ji_yuan(stat: int) -> Dictionary:
	return _build_ji_yuan_data(stat, _roll_ji_yuan_type())


func generate_cultivation_ji_yuan(stat: int) -> Dictionary:
	return _build_ji_yuan_data(stat, {"name": "修行", "base_effect": 60, "effect_type": "ling_li"})


func _roll_ji_yuan_type() -> Dictionary:
	var total_weight: float = 0.0
	for ji_yuan in JI_YUAN_TYPES:
		var ji_yuan_data: Dictionary = ji_yuan as Dictionary
		total_weight += float(JI_YUAN_TYPE_WEIGHTS.get(str(ji_yuan_data.get("effect_type", "")), 1.0))

	var roll: float = rng.randf() * total_weight
	var cursor: float = 0.0
	for ji_yuan in JI_YUAN_TYPES:
		var ji_yuan_data: Dictionary = ji_yuan as Dictionary
		cursor += float(JI_YUAN_TYPE_WEIGHTS.get(str(ji_yuan_data.get("effect_type", "")), 1.0))
		if roll <= cursor:
			return ji_yuan_data
	return JI_YUAN_TYPES[0] as Dictionary


func _build_ji_yuan_data(stat: int, ji_yuan_type: Dictionary) -> Dictionary:
	var quality: String = roll_quality(get_adjusted_quality_prob(stat))
	var multiplier: float = float(QUALITY_MULTIPLIER[quality])
	var effect_value: float = float(ji_yuan_type["base_effect"]) * multiplier
	if effect_value > 0.0 and ji_yuan_type["effect_type"] != "heal_percent":
		effect_value = max(1.0, round(effect_value))

	var data: Dictionary = {
		"quality": quality,
		"type": str(ji_yuan_type["name"]),
		"effect_type": str(ji_yuan_type["effect_type"]),
		"base_effect": ji_yuan_type["base_effect"],
		"effect_value": effect_value,
		"value": effect_value,
		"multiplier": multiplier,
	}
	if data["effect_type"] == "stat_up":
		data["stat"] = BASE_STATS[rng.randi_range(0, BASE_STATS.size() - 1)]
	elif data["effect_type"] == "companion":
		data["companion"] = generate_companion()
	data["desc"] = generate_desc(data)
	return data


func generate_calamity(stat: int) -> Dictionary:
	var quality: String = roll_quality(get_adjusted_quality_prob(stat, true))
	var calamity_type: Dictionary = _roll_calamity_type_for_quality(quality)
	var multiplier: float = float(QUALITY_MULTIPLIER[quality])
	var effect_value: float = float(calamity_type["base_effect"]) * multiplier
	if effect_value > 0.0:
		effect_value = max(1.0, round(effect_value))

	var data: Dictionary = {
		"quality": quality,
		"type": str(calamity_type["name"]),
		"effect_type": str(calamity_type["effect_type"]),
		"base_effect": calamity_type["base_effect"],
		"effect_value": effect_value,
		"value": effect_value,
		"multiplier": multiplier,
	}
	data["desc"] = generate_desc(data, true)
	return data


func generate_auction_lots(card_quality: String) -> Array:
	var lots: Array = []
	lots.append(_make_auction_lot("cultivation", card_quality))
	lots.append(_make_auction_lot("heal", card_quality))

	var special_kinds: Array[String] = ["technique", "treasure", "companion", "dan", "backpack"]
	while lots.size() < 3:
		var kind: String = special_kinds[rng.randi_range(0, special_kinds.size() - 1)]
		var lot: Dictionary = _make_auction_lot(kind, card_quality)
		lots.append(lot)
	return lots


func _make_auction_lot(kind: String, quality: String) -> Dictionary:
	var multiplier: float = float(QUALITY_MULTIPLIER.get(quality, 1.0))
	match kind:
		"cultivation":
			return {
				"kind": kind,
				"name": "吐纳丹",
				"quality": quality,
				"desc": "修为 +" + str(MARKET_CULTIVATION_GAIN),
				"price": maxi(80, int(round(float(MARKET_CULTIVATION_COST) * multiplier))),
				"value": MARKET_CULTIVATION_GAIN,
			}
		"heal":
			return {
				"kind": kind,
				"name": "回春药",
				"quality": quality,
				"desc": "回复30%气血",
				"price": maxi(120, int(round(float(MARKET_HEAL_COST) * multiplier))),
				"value": MARKET_HEAL_PCT,
			}
		"dan":
			return {
				"kind": kind,
				"name": "突破丹匣",
				"quality": quality,
				"desc": "获得当前境界所需突破丹",
				"price": maxi(260, int(round(320.0 * multiplier))),
				"value": 1,
			}
		"backpack":
			return {
				"kind": kind,
				"name": "储物袋",
				"quality": quality,
				"desc": "背包容量 +1",
				"price": maxi(320, int(round(float(MARKET_BACKPACK_COST) * multiplier))),
				"value": 1,
			}
		"technique":
			return {
				"kind": kind,
				"name": quality + "功法残卷",
				"quality": quality,
				"desc": "获得随机" + quality + "功法",
				"price": maxi(220, int(round(280.0 * multiplier))),
				"value": 1,
			}
		"treasure":
			return {
				"kind": kind,
				"name": quality + "法宝匣",
				"quality": quality,
				"desc": "获得随机法宝",
				"price": maxi(260, int(round(320.0 * multiplier))),
				"value": 1,
			}
		"companion":
			return {
				"kind": kind,
				"name": quality + "招贤帖",
				"quality": quality,
				"desc": "招募随机同伴",
				"price": maxi(260, int(round(340.0 * multiplier))),
				"value": 1,
			}
	return {
		"kind": "cultivation",
		"name": "吐纳丹",
		"quality": quality,
		"desc": "修为 +" + str(MARKET_CULTIVATION_GAIN),
		"price": MARKET_CULTIVATION_COST,
		"value": MARKET_CULTIVATION_GAIN,
	}


func _roll_calamity_type_for_quality(quality: String) -> Dictionary:
	var base_type: Dictionary = (CALAMITY_TYPES.get(quality, CALAMITY_TYPES["凡品"]) as Dictionary).duplicate(true)
	match quality:
		"上品":
			if rng.randf() < 0.35:
				return {"name": "妖兽袭扰", "base_effect": 0, "effect_type": "enemy"}
		"仙品":
			if rng.randf() < 0.55:
				return {"name": "大妖拦路", "base_effect": 0, "effect_type": "enemy"}
		"道品":
			return base_type
	return base_type


func generate_technique(quality: String) -> Dictionary:
	var candidates: Array = []
	for technique in TECHNIQUE_POOL:
		var technique_data: Dictionary = technique as Dictionary
		if str(technique_data.get("quality", "")) == quality:
			candidates.append(technique_data)
	if candidates.is_empty():
		for technique in TECHNIQUE_POOL:
			candidates.append(technique)

	var selected: Dictionary = (candidates[rng.randi_range(0, candidates.size() - 1)] as Dictionary).duplicate(true)
	var resonance_count: int = int(TECHNIQUE_RESONANCE_COUNT.get(str(selected.get("quality", quality)), 1))
	var quality_range: Array = TECHNIQUE_RESONANCE_RANGE.get(str(selected.get("quality", quality)), ["良品"]) as Array
	var resonances: Array = []
	var used_names: Dictionary = {}

	while resonances.size() < resonance_count:
		var resonance_quality: String = str(quality_range[rng.randi_range(0, quality_range.size() - 1)])
		var pool: Array = RESONANCE_POOL.get(resonance_quality, []) as Array
		if pool.is_empty():
			break

		var resonance: Dictionary = (pool[rng.randi_range(0, pool.size() - 1)] as Dictionary).duplicate(true)
		var resonance_name: String = str(resonance.get("name", ""))
		if used_names.has(resonance_name):
			continue

		resonance["quality"] = resonance_quality
		used_names[resonance_name] = true
		resonances.append(resonance)

	selected["resonances"] = resonances
	return selected


func check_resonance(player: PlayerData) -> Array:
	var resonance_names: Dictionary = {}
	for technique in player.techniques:
		if not technique is Dictionary:
			continue
		var resonances: Array = technique.get("resonances", []) as Array
		for resonance in resonances:
			if resonance is Dictionary:
				resonance_names[str(resonance.get("name", ""))] = true

	var active_links: Array = []
	for link in RESONANCE_LINKS:
		var link_data: Dictionary = link as Dictionary
		var requires: Array = link_data.get("requires", []) as Array
		var active := true
		for required in requires:
			if not resonance_names.has(str(required)):
				active = false
				break
		if active:
			active_links.append(link_data.duplicate(true))
	return active_links


func prepare_duel() -> Dictionary:
	var player_a_stats: Dictionary = calculate_duel_stats(player_a)
	var player_b_stats: Dictionary = calculate_duel_stats(player_b)
	var speed_a: float = float(player_a_stats.get("速度", 0)) * rng.randf_range(0.95, 1.05)
	var speed_b: float = float(player_b_stats.get("速度", 0)) * rng.randf_range(0.95, 1.05)
	var first_attacker: String = "player_a" if speed_a >= speed_b else "player_b"
	duel_round_number = 1
	duel_data = {
		"player_a_stats": player_a_stats,
		"player_b_stats": player_b_stats,
		"first_attacker": first_attacker,
		"current_attacker": first_attacker,
		"round": duel_round_number,
		"log": ["仙位之争开启，" + ("玩家A" if first_attacker == "player_a" else "玩家B") + "占得先机"],
	}
	return duel_data.duplicate(true)


func calculate_duel_stats(player: PlayerData) -> Dictionary:
	var realm_data: Dictionary = REALMS.get(player.realm, REALMS["炼气期"]) as Dictionary
	var final_stats: Dictionary = player.calculate_final_stats(
		1.0 + float(realm_data.get("attack_bonus", 0.0)),
		1.0 + float(realm_data.get("defense_bonus", 0.0)),
		1.0 + float(realm_data.get("hp_bonus", 0.0))
	)
	var final_speed: int = int(realm_data.get("speed_base", 10)) + int(player.stats.get("身法", 0)) * 6 + int(player.refined_bonuses.get("速度", 0))
	var resonances: Array = []
	for technique in player.techniques:
		if not technique is Dictionary:
			continue
		var technique_data: Dictionary = technique
		var technique_resonances: Array = technique_data.get("resonances", []) as Array
		for resonance in technique_resonances:
			if resonance is Dictionary:
				resonances.append((resonance as Dictionary).duplicate(true))

	var active_links: Array = check_resonance(player)
	return {
		"攻击力": int(final_stats.get("攻击力", 0)),
		"防御力": int(final_stats.get("防御力", 0)),
		"气血": int(final_stats.get("气血", 0)),
		"速度": final_speed,
		"真意列表": resonances,
		"联动列表": active_links,
		"伙伴列表": player.companions.duplicate(true),
	}


func execute_duel_round(attacker: PlayerData, defender: PlayerData, attack_stats: Dictionary, defense_stats: Dictionary) -> Dictionary:
	var effects: Array = []
	var attack_value: float = float(attack_stats.get("攻击力", 0))
	var defense_value: float = float(defense_stats.get("防御力", 0))
	var defense_rate: float = minf(0.70, defense_value / (defense_value + 50.0))
	var ignore_defense: float = _get_duel_effect_value(attack_stats, "碎甲", 0.0)
	if _has_link(attack_stats, "摧枯拉朽"):
		ignore_defense += 0.10
	if _has_link(attack_stats, "蓄势待发"):
		ignore_defense += 0.20
	defense_rate = maxf(0.0, defense_rate * (1.0 - ignore_defense))

	var dodge_chance: float = _get_duel_effect_value(defense_stats, "逍遥游", 0.0)
	if _has_link(defense_stats, "踏雪无痕"):
		dodge_chance += 0.05
	if rng.randf() < dodge_chance:
		effects.append("逍遥游闪避")
		var dodge_log: String = defender.player_name + "身形一晃，避开了攻击"
		return {"damage": attack_value, "实际伤害": 0, "特殊效果触发列表": effects, "日志文字": dodge_log}

	var damage: float = maxf(1.0, attack_value * (1.0 - defense_rate))
	var crit_chance: float = _get_duel_effect_value(attack_stats, "破军", 0.0)
	if _has_link(attack_stats, "先发制人"):
		crit_chance += 0.30
	if _has_link(attack_stats, "一剑封喉") and defender.qi_xue <= int(defense_stats.get("气血", 1)) * 0.35:
		crit_chance += 0.25
	if rng.randf() < crit_chance:
		damage *= 1.5
		effects.append("破军暴击")

	var actual_damage: int = max(1, int(round(damage)))
	defender.qi_xue = maxi(0, defender.qi_xue - actual_damage)
	var heal_rate: float = _get_duel_effect_value(attack_stats, "嗜血", 0.0)
	if _has_link(attack_stats, "血战") and effects.has("破军暴击"):
		heal_rate *= 2.0
	if heal_rate > 0.0:
		var heal_value: int = int(round(float(actual_damage) * heal_rate))
		attacker.qi_xue = mini(int(attack_stats.get("气血", attacker.qi_xue)), attacker.qi_xue + heal_value)
		effects.append("嗜血回血" + str(heal_value))

	var thorn_rate: float = _get_duel_effect_value(defense_stats, "荆棘", 0.0)
	if thorn_rate > 0.0:
		if _has_link(defense_stats, "铜墙铁壁") and defender.qi_xue <= int(defense_stats.get("气血", 1)) * 0.35:
			thorn_rate *= 2.0
		var reflected: int = int(round(float(actual_damage) * thorn_rate))
		attacker.qi_xue = maxi(0, attacker.qi_xue - reflected)
		effects.append("荆棘反弹" + str(reflected))

	var log_text: String = attacker.player_name + "造成" + str(actual_damage) + "点伤害"
	if not effects.is_empty():
		log_text += "（" + "，".join(effects) + "）"
	return {"damage": damage, "实际伤害": actual_damage, "特殊效果触发列表": effects, "日志文字": log_text}


func start_duel_if_host() -> void:
	if not NetworkManager.is_host:
		return
	if duel_data.is_empty():
		var data: Dictionary = prepare_duel()
		NetworkManager.send_message("duel_data", data)
		on_duel_data(data)


func on_duel_data(data: Dictionary) -> void:
	duel_data = data.duplicate(true)
	duel_round_number = int(duel_data.get("round", 1))
	duel_prepared.emit(duel_data)


func settle_duel_action() -> void:
	if not NetworkManager.is_host or duel_data.is_empty():
		return

	var attacker_key: String = str(duel_data.get("current_attacker", duel_data.get("first_attacker", "player_a")))
	var defender_key: String = "player_b" if attacker_key == "player_a" else "player_a"
	var attacker: PlayerData = player_a if attacker_key == "player_a" else player_b
	var defender: PlayerData = player_b if attacker_key == "player_a" else player_a
	var attack_stats: Dictionary = duel_data.get(attacker_key + "_stats", {}) as Dictionary
	var defense_stats: Dictionary = duel_data.get(defender_key + "_stats", {}) as Dictionary
	var round_result: Dictionary = execute_duel_round(attacker, defender, attack_stats, defense_stats)
	attack_stats["当前气血"] = attacker.qi_xue
	defense_stats["当前气血"] = defender.qi_xue
	duel_data[attacker_key + "_stats"] = attack_stats
	duel_data[defender_key + "_stats"] = defense_stats

	var logs: Array = duel_data.get("log", []) as Array
	var round_log: String = "第" + str(duel_round_number) + "回合：" + str(round_result.get("日志文字", ""))
	logs.append(round_log)
	duel_data["log"] = logs
	duel_data["last_result"] = round_result
	var round_record: Dictionary = {
		"round": duel_round_number,
		"log": round_log,
		"attacker": attacker.player_name,
		"defender": defender.player_name,
		"damage": int(round_result.get("实际伤害", 0)),
	}
	player_a.duel_rounds.append(round_record.duplicate(true))
	player_b.duel_rounds.append(round_record.duplicate(true))

	if player_a.qi_xue <= 0 or player_b.qi_xue <= 0:
		var winner_key: String = "player_b" if player_a.qi_xue <= 0 else "player_a"
		var loser_key: String = "player_a" if winner_key == "player_b" else "player_b"
		var winner: PlayerData = player_a if winner_key == "player_a" else player_b
		var loser: PlayerData = player_b if winner_key == "player_a" else player_a
		pending_duel_winner_key = winner_key
		pending_duel_loser_key = loser_key
		var ending_data: Dictionary = {
			"winner": winner.player_name,
			"loser": loser.player_name,
			"winner_key": winner_key,
			"loser_key": loser_key,
			"winner_peer_id": winner.peer_id,
			"loser_peer_id": loser.peer_id,
			"awaiting_final_choice": true,
			"final_stats": duel_data,
		}
		duel_data["ending"] = ending_data
		NetworkManager.send_message("duel_finished", ending_data)
		on_duel_finished(ending_data)
		return

	duel_round_number += 1
	duel_data["round"] = duel_round_number
	duel_data["current_attacker"] = defender_key
	NetworkManager.send_message("duel_update", duel_data)
	on_duel_update(duel_data)


func on_duel_update(data: Dictionary) -> void:
	duel_data = data.duplicate(true)
	duel_round_number = int(duel_data.get("round", duel_round_number))
	duel_updated.emit(duel_data)


func on_duel_finished(data: Dictionary) -> void:
	pending_duel_winner_key = str(data.get("winner_key", pending_duel_winner_key))
	pending_duel_loser_key = str(data.get("loser_key", pending_duel_loser_key))
	duel_finished.emit(data)


func on_duel_final_choice_received(peer_id: int, data: Dictionary) -> void:
	if not NetworkManager.is_host:
		return
	if current_state != GameState.DUEL:
		return
	if pending_duel_winner_key == "" or pending_duel_loser_key == "":
		return

	var winner: PlayerData = player_a if pending_duel_winner_key == "player_a" else player_b
	var loser: PlayerData = player_b if pending_duel_winner_key == "player_a" else player_a
	var choice_peer_id: int = peer_id
	if choice_peer_id <= 0:
		choice_peer_id = 1
	if winner == null or choice_peer_id != winner.peer_id:
		return

	var choice: String = str(data.get("choice", "ascend"))
	var ascender: PlayerData = winner
	var fallen: PlayerData = loser
	if choice == "yield":
		ascender = loser
		fallen = winner
		winner.final_attributes["final_choice"] = "放弃仙位"
		loser.final_attributes["final_choice"] = "受让成仙"
	else:
		winner.final_attributes["final_choice"] = "踏入仙门"
		loser.final_attributes["final_choice"] = "败于仙争"

	var result_data: Dictionary = {
		"choice": choice,
		"ascender": ascender.player_name,
		"fallen": fallen.player_name,
		"ascender_peer_id": ascender.peer_id,
		"fallen_peer_id": fallen.peer_id,
	}
	NetworkManager.send_message("duel_final_choice_result", result_data)
	on_duel_final_choice_result(result_data)
	trigger_ending(ascender, fallen)
	await get_tree().create_timer(1.0).timeout
	transition_to_scene("res://scenes/ending.tscn")


func on_duel_final_choice_result(data: Dictionary) -> void:
	var logs: Array = duel_data.get("log", []) as Array
	var choice: String = str(data.get("choice", "ascend"))
	if choice == "yield":
		logs.append(str(data.get("fallen", "")) + "放弃仙位，亲手送" + str(data.get("ascender", "")) + "飞升。")
	else:
		logs.append(str(data.get("ascender", "")) + "踏入仙门，成就仙位。")
	duel_data["log"] = logs
	duel_updated.emit(duel_data)


func _get_duel_effect_value(stats: Dictionary, resonance_name: String, default_value: float) -> float:
	var resonances: Array = stats.get("真意列表", []) as Array
	for resonance in resonances:
		if resonance is Dictionary and str(resonance.get("name", "")) == resonance_name:
			match resonance_name:
				"破军":
					return 0.15
				"逍遥游":
					return 0.15
				"嗜血":
					return 0.20
				"碎甲":
					return 0.20
				"荆棘":
					return 0.15
				_:
					return default_value
	return default_value


func _has_link(stats: Dictionary, link_name: String) -> bool:
	var links: Array = stats.get("联动列表", []) as Array
	for link in links:
		if link is Dictionary and str(link.get("name", "")) == link_name:
			return true
	return false


func generate_treasure() -> Dictionary:
	var treasure: Dictionary = (TREASURE_POOL[rng.randi_range(0, TREASURE_POOL.size() - 1)] as Dictionary).duplicate(true)
	treasure["used"] = false
	treasure["refined"] = false
	return treasure


func generate_companion() -> Dictionary:
	var companion: Dictionary = (COMPANION_POOL[rng.randi_range(0, COMPANION_POOL.size() - 1)] as Dictionary).duplicate(true)
	companion["alive"] = true
	return companion


func apply_companion_bonus(player: PlayerData) -> void:
	if player == null:
		return

	for companion in player.companions:
		if not companion is Dictionary:
			continue
		var companion_data: Dictionary = companion
		if bool(companion_data.get("bonus_applied", false)):
			continue

		var bonus_type: String = str(companion_data.get("bonus_type", ""))
		var bonus_value: float = float(companion_data.get("bonus_value", 0.0))
		match bonus_type:
			"攻击力", "防御力", "气血上限", "灵力获取", "全属性":
				player.refined_bonuses[bonus_type] = float(player.refined_bonuses.get(bonus_type, 0.0)) + bonus_value
			"速度":
				player.speed += int(round(bonus_value))
			_:
				player.final_attributes[bonus_type] = float(player.final_attributes.get(bonus_type, 0.0)) + bonus_value

		companion_data["bonus_applied"] = true


func _remove_companion_bonus(player: PlayerData, companion_data: Dictionary) -> void:
	if player == null or companion_data.is_empty():
		return
	if not bool(companion_data.get("bonus_applied", false)):
		return

	var bonus_type: String = str(companion_data.get("bonus_type", ""))
	var bonus_value: float = float(companion_data.get("bonus_value", 0.0))
	match bonus_type:
		"攻击力", "防御力", "气血上限", "灵力获取", "全属性":
			player.refined_bonuses[bonus_type] = float(player.refined_bonuses.get(bonus_type, 0.0)) - bonus_value
		"速度":
			player.speed -= int(round(bonus_value))
		_:
			player.final_attributes[bonus_type] = float(player.final_attributes.get(bonus_type, 0.0)) - bonus_value
	companion_data["bonus_applied"] = false


func _make_backpack_entry(kind: String, item_data: Dictionary) -> Dictionary:
	return {"kind": kind, "data": item_data.duplicate(true)}


func _backpack_item_label(entry: Dictionary) -> String:
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


func _store_equipment_item(player: PlayerData, kind: String, item_data: Dictionary) -> String:
	if kind == "technique" and player.techniques.size() < 3:
		player.techniques.append(item_data)
		return "功法《" + str(item_data.get("name", "未知")) + "》已装备"
	if kind == "treasure" and player.treasures.size() < 1:
		player.treasures.append(item_data)
		return "法宝【" + str(item_data.get("name", "未知")) + "】已装备"
	if kind == "companion" and player.companions.size() < 3:
		player.companions.append(item_data)
		apply_companion_bonus(player)
		return "同伴「" + str(item_data.get("name", "未知")) + "」已入队"

	var entry: Dictionary = _make_backpack_entry(kind, item_data)
	if player.backpack.size() < player.backpack_capacity:
		player.backpack.append(entry)
		return _backpack_item_label(entry) + "收入背包"

	pending_backpack_items[str(player.peer_id)] = entry
	return "背包已满：" + _backpack_item_label(entry) + "暂未收入，请先清理"


func _try_store_pending_backpack_item(player: PlayerData) -> String:
	if player == null:
		return ""
	var key: String = str(player.peer_id)
	if not pending_backpack_items.has(key):
		return ""

	var entry: Dictionary = pending_backpack_items[key] as Dictionary
	var kind: String = str(entry.get("kind", ""))
	var item_data: Dictionary = entry.get("data", {}) as Dictionary
	if kind == "technique" and player.techniques.size() < 3:
		player.techniques.append(item_data)
		pending_backpack_items.erase(key)
		return _backpack_item_label(entry) + "已装备"
	if kind == "treasure" and player.treasures.size() < 1:
		player.treasures.append(item_data)
		pending_backpack_items.erase(key)
		return _backpack_item_label(entry) + "已装备"
	if kind == "companion" and player.companions.size() < 3:
		player.companions.append(item_data)
		apply_companion_bonus(player)
		pending_backpack_items.erase(key)
		return _backpack_item_label(entry) + "已入队"
	if player.backpack.size() < player.backpack_capacity:
		player.backpack.append(entry)
		pending_backpack_items.erase(key)
		return _backpack_item_label(entry) + "已收入背包"
	return ""


func has_pending_backpack_item(peer_id: int) -> bool:
	return pending_backpack_items.has(str(peer_id))


func get_pending_backpack_item(peer_id: int) -> Dictionary:
	return (pending_backpack_items.get(str(peer_id), {}) as Dictionary).duplicate(true)


func on_backpack_action_received(peer_id: int, data: Dictionary) -> void:
	if not NetworkManager.is_host:
		return

	var player: PlayerData = get_player_by_peer(peer_id)
	if player == null:
		return

	var action: String = str(data.get("action", ""))
	var index: int = int(data.get("index", -1))
	var kind: String = str(data.get("kind", ""))
	var target_type: String = str(data.get("target_type", ""))
	var target_index: int = int(data.get("target_index", -1))
	var message: String = ""
	match action:
		"discard":
			message = discard_backpack_item(player, index)
		"equip":
			message = equip_from_backpack(player, index, target_type, target_index)
		"discard_pending":
			message = discard_pending_backpack_item(player)
		"discard_equipped":
			message = discard_equipped_item(player, kind, index)
		"equip_pending":
			message = equip_pending_item(player, target_type, target_index)
		_:
			message = "未知背包操作"

	var update_data: Dictionary = _backpack_update_data(peer_id, message)
	NetworkManager.send_message("backpack_updated", update_data)
	on_backpack_updated(update_data)


func _backpack_update_data(peer_id: int, message: String) -> Dictionary:
	return {
		"peer_id": peer_id,
		"message": message,
		"player_a": _player_snapshot(player_a),
		"player_b": _player_snapshot(player_b),
		"pending_backpack_items": pending_backpack_items.duplicate(true),
	}


func on_backpack_updated(data: Dictionary) -> void:
	_apply_player_snapshot(player_a, data.get("player_a", {}) as Dictionary)
	_apply_player_snapshot(player_b, data.get("player_b", {}) as Dictionary)
	pending_backpack_items = (data.get("pending_backpack_items", pending_backpack_items) as Dictionary).duplicate(true)
	backpack_changed.emit(data)


func on_market_action_received(peer_id: int, data: Dictionary) -> void:
	if not NetworkManager.is_host:
		return

	var player: PlayerData = get_player_by_peer(peer_id)
	if player == null:
		return

	var action: String = str(data.get("action", ""))
	var message: String = ""
	match action:
		"cultivation":
			message = buy_market_cultivation(player)
		"heal":
			message = buy_market_heal(player)
		"dan":
			message = buy_market_dan(player)
		"backpack":
			message = buy_market_backpack(player)
		_:
			message = "未知坊市交易"

	var update_data: Dictionary = _market_update_data(peer_id, message)
	NetworkManager.send_message("market_updated", update_data)
	on_market_updated(update_data)
	check_duel_trigger()


func _market_update_data(peer_id: int, message: String) -> Dictionary:
	return {
		"peer_id": peer_id,
		"message": message,
		"player_a": _player_snapshot(player_a),
		"player_b": _player_snapshot(player_b),
		"pending_backpack_items": pending_backpack_items.duplicate(true),
	}


func on_market_updated(data: Dictionary) -> void:
	_apply_player_snapshot(player_a, data.get("player_a", {}) as Dictionary)
	_apply_player_snapshot(player_b, data.get("player_b", {}) as Dictionary)
	pending_backpack_items = (data.get("pending_backpack_items", pending_backpack_items) as Dictionary).duplicate(true)
	market_changed.emit(data)


func on_auction_action_received(peer_id: int, data: Dictionary) -> void:
	if not NetworkManager.is_host:
		return
	if current_state != GameState.AUCTION or current_auction.is_empty():
		return

	var action_peer_id: int = peer_id
	if action_peer_id <= 0:
		action_peer_id = 1
	auction_choices[str(action_peer_id)] = data.duplicate(true)

	var total_required: int = _lottery_energy_required_count()
	if auction_choices.size() < total_required:
		return
	_settle_current_auction()


func _settle_current_auction() -> void:
	var auction_index: int = int(current_auction.get("index", current_card_index))
	var card: Dictionary = (current_auction.get("card", {}) as Dictionary).duplicate(true)
	var lots: Array = (current_auction.get("lots", []) as Array).duplicate(true)
	var messages: Dictionary = {}
	var lot_claims: Dictionary = {}
	var peer_ids: Array[int] = _auction_peer_ids()

	for peer_id in peer_ids:
		var choice: Dictionary = (auction_choices.get(str(peer_id), {"mode": "pass", "lot_index": -1}) as Dictionary).duplicate(true)
		var mode: String = str(choice.get("mode", "pass"))
		var lot_index: int = int(choice.get("lot_index", -1))
		if mode == "pass" or lot_index < 0 or lot_index >= lots.size():
			messages[str(peer_id)] = "你在拍卖会观望了一轮"
			continue
		if not lot_claims.has(lot_index):
			lot_claims[lot_index] = []
		var claims: Array = lot_claims[lot_index] as Array
		claims.append({"peer_id": peer_id, "choice": choice})

	for lot_index in lot_claims.keys():
		var lot: Dictionary = lots[int(lot_index)] as Dictionary
		var claims: Array = lot_claims[lot_index] as Array
		var winner: Dictionary = _choose_auction_winner(claims)
		var winner_peer_id: int = int(winner.get("peer_id", 0))
		for claim in claims:
			var claim_data: Dictionary = claim as Dictionary
			var claim_peer_id: int = int(claim_data.get("peer_id", 0))
			if claim_peer_id != winner_peer_id:
				messages[str(claim_peer_id)] = "竞价失败：" + str(lot.get("name", "拍品")) + "被对方拍走"
		messages[str(winner_peer_id)] = _complete_auction_purchase(winner_peer_id, lot, winner.get("choice", {}) as Dictionary, claims.size() > 1)

	card["settled"] = true
	if auction_index >= 0 and auction_index < current_lottery_cards.size():
		current_lottery_cards[auction_index] = card
	if auction_index >= 0 and auction_index < current_lottery_results.size():
		current_lottery_results[auction_index] = card

	var next_index: int = auction_index + 1
	pending_continue_next_index = next_index
	pending_continue_round_finished = next_index < 0 or next_index >= current_lottery_cards.size()
	current_card_index = next_index
	current_bargain_index = current_card_index
	bargain_continue_votes.clear()
	auction_choices.clear()

	var data_out: Dictionary = {
		"index": auction_index,
		"card": card,
		"lots": lots,
		"messages": messages,
		"player_a": _player_snapshot(player_a),
		"player_b": _player_snapshot(player_b),
		"pending_backpack_items": pending_backpack_items.duplicate(true),
		"results": current_lottery_results.duplicate(true),
		"next_index": next_index,
		"round_finished": pending_continue_round_finished,
	}
	NetworkManager.send_message("auction_ended", data_out)
	on_auction_ended(data_out)


func on_auction_ended(data: Dictionary) -> void:
	_apply_player_snapshot(player_a, data.get("player_a", {}) as Dictionary)
	_apply_player_snapshot(player_b, data.get("player_b", {}) as Dictionary)
	pending_backpack_items = (data.get("pending_backpack_items", pending_backpack_items) as Dictionary).duplicate(true)
	var incoming_results: Array = data.get("results", []) as Array
	if not incoming_results.is_empty():
		current_lottery_results = incoming_results.duplicate(true)
		if not NetworkManager.is_host:
			current_lottery_cards = incoming_results.duplicate(true)
	current_card_index = int(data.get("next_index", current_card_index + 1))
	current_bargain_index = current_card_index
	pending_continue_next_index = current_card_index
	pending_continue_round_finished = bool(data.get("round_finished", false))
	current_auction.clear()
	auction_choices.clear()
	auction_ended.emit(data)


func _auction_peer_ids() -> Array[int]:
	var peer_ids: Array[int] = []
	peer_ids.append(player_a.peer_id if player_a != null and player_a.peer_id > 0 else 1)
	if _lottery_energy_required_count() > 1 and player_b != null:
		peer_ids.append(player_b.peer_id)
	return peer_ids


func _choose_auction_winner(claims: Array) -> Dictionary:
	var winner: Dictionary = {}
	var best_score: float = -999999.0
	for claim in claims:
		var claim_data: Dictionary = claim as Dictionary
		var peer_id: int = int(claim_data.get("peer_id", 0))
		var player: PlayerData = get_player_by_peer(peer_id)
		var choice: Dictionary = claim_data.get("choice", {}) as Dictionary
		var mode: String = str(choice.get("mode", "bid"))
		var score: float = float(player.ling_shi if player != null else 0)
		score += float(player.stats.get("经商", 0)) * 30.0 if player != null else 0.0
		if mode == "bid":
			score += 1000.0
		if score > best_score:
			best_score = score
			winner = claim_data
	return winner


func _complete_auction_purchase(peer_id: int, lot: Dictionary, choice: Dictionary, contested: bool) -> String:
	var player: PlayerData = get_player_by_peer(peer_id)
	if player == null:
		return "拍卖失败：未找到买家"

	var price: int = int(lot.get("price", 0))
	var mode: String = str(choice.get("mode", "bid"))
	if mode == "haggle":
		price = _auction_haggled_price(player, price)
	elif contested:
		price = int(round(float(price) * 1.20))
		price = _auction_business_price(player, price)
	else:
		price = _auction_business_price(player, price)

	if not _spend_ling_shi(player, price):
		return "拍卖失败：灵石不足，" + str(lot.get("name", "拍品")) + "需要 " + str(price)

	var effect_message: String = _apply_auction_lot(player, lot)
	var verb: String = "讲价购得" if mode == "haggle" else "竞拍得手"
	player.ji_yuan_list.append({
		"desc": "拍卖会：" + str(lot.get("name", "拍品")),
		"quality": str(lot.get("quality", "")),
		"type": "拍卖会",
		"effect_value": price,
	})
	return verb + "【" + str(lot.get("name", "拍品")) + "】，花费 " + str(price) + " 灵石；" + effect_message


func _auction_haggled_price(player: PlayerData, price: int) -> int:
	var business: int = int(player.stats.get("经商", 0))
	var discount: float = clamp(0.75 - float(business) * 0.04, 0.35, 0.75)
	return maxi(1, int(round(float(price) * discount)))


func _auction_business_price(player: PlayerData, price: int) -> int:
	var business: int = int(player.stats.get("经商", 0))
	var discount: float = clamp(1.0 - float(business) * 0.05, 0.55, 1.0)
	return maxi(1, int(round(float(price) * discount)))


func _apply_auction_lot(player: PlayerData, lot: Dictionary) -> String:
	var kind: String = str(lot.get("kind", ""))
	var quality: String = str(lot.get("quality", "良品"))
	match kind:
		"cultivation":
			var before_stage: String = get_cultivation_stage_name(player)
			var amount: int = int(lot.get("value", MARKET_CULTIVATION_GAIN))
			player.ling_li += amount
			return _append_stage_change_to_message(player, before_stage, "修为 +" + str(amount))
		"heal":
			var max_hp: int = _get_player_max_hp(player)
			var heal_amount: int = maxi(1, int(round(float(max_hp) * MARKET_HEAL_PCT)))
			player.qi_xue = mini(max_hp, player.qi_xue + heal_amount)
			return "气血 +" + str(heal_amount)
		"dan":
			return _grant_breakthrough_dan(player)
		"backpack":
			player.backpack_capacity += 1
			var pending_message: String = _try_store_pending_backpack_item(player)
			return "背包容量 +1" if pending_message == "" else "背包容量 +1；" + pending_message
		"technique":
			return _store_equipment_item(player, "technique", generate_technique(quality))
		"treasure":
			return _store_equipment_item(player, "treasure", generate_treasure())
		"companion":
			return _store_equipment_item(player, "companion", generate_companion())
	return "拍品无事发生"


func buy_market_cultivation(player: PlayerData) -> String:
	if not _spend_ling_shi(player, MARKET_CULTIVATION_COST):
		return "灵石不足，修为兑换需要 " + str(MARKET_CULTIVATION_COST)
	var before_stage: String = get_cultivation_stage_name(player)
	player.ling_li += MARKET_CULTIVATION_GAIN
	return _append_stage_change_to_message(player, before_stage, "坊市吐纳丹：修为 +" + str(MARKET_CULTIVATION_GAIN))


func buy_market_heal(player: PlayerData) -> String:
	if not _spend_ling_shi(player, MARKET_HEAL_COST):
		return "灵石不足，疗伤需要 " + str(MARKET_HEAL_COST)
	var max_hp: int = _get_player_max_hp(player)
	var heal_amount: int = maxi(1, int(round(float(max_hp) * MARKET_HEAL_PCT)))
	player.qi_xue = mini(max_hp, player.qi_xue + heal_amount)
	return "坊市疗伤：气血 +" + str(heal_amount)


func buy_market_dan(player: PlayerData) -> String:
	var dan_name: String = _next_required_dan_name(player)
	if dan_name == "":
		return "已无当前境界所需突破丹"
	if has_dan(player, dan_name):
		return "你已拥有" + dan_name

	var cost: int = int(MARKET_DAN_COSTS.get(dan_name, 9999))
	if not _spend_ling_shi(player, cost):
		return "灵石不足，" + dan_name + "需要 " + str(cost)

	var dans: Array = player.final_attributes.get("dans", []) as Array
	if not dans.has(dan_name):
		dans.append(dan_name)
	player.final_attributes["dans"] = dans
	return "坊市购得" + dan_name


func buy_market_backpack(player: PlayerData) -> String:
	if not _spend_ling_shi(player, MARKET_BACKPACK_COST):
		return "灵石不足，扩充背包需要 " + str(MARKET_BACKPACK_COST)
	player.backpack_capacity += 1
	var pending_message: String = _try_store_pending_backpack_item(player)
	if pending_message != "":
		return "背包容量 +1；" + pending_message
	return "背包容量 +1"


func _spend_ling_shi(player: PlayerData, cost: int) -> bool:
	if player == null or player.ling_shi < cost:
		return false
	player.ling_shi -= cost
	return true


func discard_backpack_item(player: PlayerData, index: int) -> String:
	if index < 0 or index >= player.backpack.size():
		return "未选择背包物品"
	var entry: Dictionary = player.backpack[index] as Dictionary
	var label: String = _backpack_item_label(entry)
	player.backpack.remove_at(index)
	var pending_message: String = _try_store_pending_backpack_item(player)
	if pending_message != "":
		return "丢弃" + label + "；" + pending_message
	return "丢弃" + label


func discard_pending_backpack_item(player: PlayerData) -> String:
	var key: String = str(player.peer_id)
	if not pending_backpack_items.has(key):
		return "没有待处理物品"
	var entry: Dictionary = pending_backpack_items[key] as Dictionary
	pending_backpack_items.erase(key)
	return "放弃" + _backpack_item_label(entry)


func discard_equipped_item(player: PlayerData, kind: String, index: int) -> String:
	var label: String = ""
	match kind:
		"technique":
			if index < 0 or index >= player.techniques.size():
				return "未选择已装备功法"
			var technique: Dictionary = player.techniques[index] as Dictionary
			label = "功法 · " + str(technique.get("name", "未知"))
			player.techniques.remove_at(index)
		"treasure":
			if player.treasures.is_empty():
				return "未选择已装备法宝"
			var treasure: Dictionary = player.treasures[0] as Dictionary
			label = "法宝 · " + str(treasure.get("name", "未知"))
			player.treasures.remove_at(0)
		"companion":
			if index < 0 or index >= player.companions.size():
				return "未选择同行同伴"
			var companion: Dictionary = player.companions[index] as Dictionary
			_remove_companion_bonus(player, companion)
			label = "同伴 · " + str(companion.get("name", "未知"))
			player.companions.remove_at(index)
		_:
			return "不能丢弃此物品"
	var pending_message: String = _try_store_pending_backpack_item(player)
	if pending_message != "":
		return "丢弃" + label + "；" + pending_message
	return "丢弃" + label


func equip_from_backpack(player: PlayerData, index: int, target_kind: String = "", target_index: int = -1) -> String:
	if index < 0 or index >= player.backpack.size():
		return "未选择背包物品"
	var entry: Dictionary = player.backpack[index] as Dictionary
	var kind: String = str(entry.get("kind", ""))
	var item_data: Dictionary = entry.get("data", {}) as Dictionary
	if target_kind != "" and target_kind != kind:
		return _backpack_item_label(entry) + "不能放入" + _item_kind_name(target_kind) + "槽"

	if kind == "technique":
		if target_index >= 0 and target_index < player.techniques.size():
			var old_technique: Dictionary = player.techniques[target_index] as Dictionary
			player.techniques[target_index] = item_data
			player.backpack[index] = _make_backpack_entry("technique", old_technique)
			return _backpack_item_label(entry) + "已替换功法《" + str(old_technique.get("name", "未知")) + "》"
		if player.techniques.size() >= 3:
			return "功法已装备 3 本，请拖到已有功法上替换"
		player.backpack.remove_at(index)
		player.techniques.append(item_data)
	elif kind == "treasure":
		if player.treasures.size() > 0:
			var old_treasure: Dictionary = player.treasures[0] as Dictionary
			player.treasures[0] = item_data
			player.backpack[index] = _make_backpack_entry("treasure", old_treasure)
			return _backpack_item_label(entry) + "已替换法宝【" + str(old_treasure.get("name", "未知")) + "】"
		player.backpack.remove_at(index)
		player.treasures.append(item_data)
	elif kind == "companion":
		if target_index >= 0 and target_index < player.companions.size():
			var old_companion: Dictionary = player.companions[target_index] as Dictionary
			_remove_companion_bonus(player, old_companion)
			player.companions[target_index] = item_data
			player.backpack[index] = _make_backpack_entry("companion", old_companion)
			apply_companion_bonus(player)
			return _backpack_item_label(entry) + "已替换同伴「" + str(old_companion.get("name", "未知")) + "」"
		if player.companions.size() >= 3:
			return "同伴区已满，请拖到已有同伴上替换"
		player.backpack.remove_at(index)
		player.companions.append(item_data)
		apply_companion_bonus(player)
	else:
		return "此物品暂不能装备"

	var pending_message: String = _try_store_pending_backpack_item(player)
	if pending_message != "":
		return _backpack_item_label(entry) + "已装备；" + pending_message
	return _backpack_item_label(entry) + "已装备"


func equip_pending_item(player: PlayerData, target_kind: String, target_index: int) -> String:
	var key: String = str(player.peer_id)
	if not pending_backpack_items.has(key):
		return "没有待处理物品"

	var entry: Dictionary = pending_backpack_items[key] as Dictionary
	var kind: String = str(entry.get("kind", ""))
	var item_data: Dictionary = entry.get("data", {}) as Dictionary
	if target_kind != kind:
		return _backpack_item_label(entry) + "不能放入" + _item_kind_name(target_kind) + "槽"

	var replaced_label: String = ""
	match kind:
		"technique":
			if target_index >= 0 and target_index < player.techniques.size():
				var old_technique: Dictionary = player.techniques[target_index] as Dictionary
				replaced_label = "，替换并丢弃功法《" + str(old_technique.get("name", "未知")) + "》"
				player.techniques[target_index] = item_data
			elif player.techniques.size() < 3:
				player.techniques.append(item_data)
			else:
				return "功法已满，请拖到已有功法上替换"
		"treasure":
			if player.treasures.size() > 0:
				var old_treasure: Dictionary = player.treasures[0] as Dictionary
				replaced_label = "，替换并丢弃法宝【" + str(old_treasure.get("name", "未知")) + "】"
				player.treasures[0] = item_data
			else:
				player.treasures.append(item_data)
		"companion":
			if target_index >= 0 and target_index < player.companions.size():
				var old_companion: Dictionary = player.companions[target_index] as Dictionary
				_remove_companion_bonus(player, old_companion)
				replaced_label = "，替换并请离同伴「" + str(old_companion.get("name", "未知")) + "」"
				player.companions[target_index] = item_data
				apply_companion_bonus(player)
			elif player.companions.size() < 3:
				player.companions.append(item_data)
				apply_companion_bonus(player)
			else:
				return "同伴区已满，请拖到已有同伴上替换"
		_:
			return "此物品暂不能装备"

	pending_backpack_items.erase(key)
	return _backpack_item_label(entry) + "已装备" + replaced_label


func use_treasure(player: PlayerData, treasure_name: String) -> String:
	for treasure in player.treasures:
		if not treasure is Dictionary:
			continue
		if str(treasure.get("name", "")) != treasure_name:
			continue
		if bool(treasure.get("refined", false)):
			return treasure_name + "已炼化，无法使用"
		if bool(treasure.get("used", false)):
			return treasure_name + "已使用"

		treasure["used"] = true
		return treasure_name + "发动：" + str(treasure.get("use_effect", "效果待定"))
	return "未找到法宝：" + treasure_name


func refine_treasure(player: PlayerData, treasure_name: String) -> String:
	for i in range(player.treasures.size()):
		var treasure = player.treasures[i]
		if not treasure is Dictionary:
			continue
		if str(treasure.get("name", "")) != treasure_name:
			continue
		if bool(treasure.get("refined", false)):
			return treasure_name + "已炼化"

		treasure["refined"] = true
		var refine_bonus: Dictionary = treasure.get("refine_bonus", {}) as Dictionary
		for bonus_name in refine_bonus:
			player.refined_bonuses[str(bonus_name)] = float(player.refined_bonuses.get(str(bonus_name), 0.0)) + float(refine_bonus[bonus_name])
		player.treasures.remove_at(i)
		return treasure_name + "已炼化"
	return "未找到法宝：" + treasure_name


func generate_desc(data: Dictionary, is_calamity: bool = false) -> String:
	var quality: String = str(data.get("quality", ""))
	var type_name: String = str(data.get("type", ""))
	var value: float = float(data.get("effect_value", data.get("value", 0)))
	var effect_type: String = str(data.get("effect_type", ""))

	if is_calamity:
		match effect_type:
			"ling_li_loss":
				return quality + "灾厄：" + type_name + "，损失灵力 " + str(int(value))
			"hp_percent_loss", "hp_damage":
				return quality + "灾厄：" + type_name + "，损失气血 " + str(int(value))
			"enemy":
				return quality + "灾厄：" + type_name + "，战斗即将触发"
			"shou_yuan_loss":
				return quality + "灾厄：" + type_name + "，损失寿元 " + str(int(value))
			"tribulation":
				return quality + "灾厄：" + type_name + "，天劫暗涌"
			_:
				return quality + "灾厄：" + type_name

	match effect_type:
		"ling_li":
			return quality + "机缘：" + type_name + "，获得灵力 " + str(int(value))
		"heal_percent":
			return quality + "机缘：" + type_name + "，回复气血 " + str(int(value)) + "%"
		"ling_shi":
			return quality + "机缘：" + type_name + "，获得灵石 " + str(int(value))
		"auction":
			return quality + "机缘：拍卖会开张，讲价或竞拍"
		"technique", "treasure", "dan", "companion":
			return quality + "机缘：" + type_name + "，获得" + type_name
		"stat_up":
			return quality + "机缘：" + type_name + "，" + str(data.get("stat", "属性")) + " +" + str(int(value))
		"shou_yuan":
			return quality + "机缘：" + type_name + "，寿元 +" + str(int(value))
		_:
			return quality + "机缘：" + type_name


func _redistribute_from_group(probs: Dictionary, qualities: Array, amount: float) -> float:
	var removed: float = 0.0
	var remaining: float = amount
	for quality in qualities:
		if remaining <= 0.0:
			break
		var available: float = maxf(0.0, float(probs[quality]) - 0.01)
		var take: float = minf(available, remaining / float(qualities.size()))
		probs[quality] = float(probs[quality]) - take
		removed += take
		remaining -= take
	return removed


func _redistribute_to_group(probs: Dictionary, qualities: Array, amount: float) -> void:
	if amount <= 0.0:
		return
	var each: float = amount / float(qualities.size())
	for quality in qualities:
		probs[quality] = float(probs[quality]) + each


func _normalize_probs(probs: Dictionary) -> void:
	var total: float = 0.0
	for quality in probs:
		probs[quality] = max(0.0, float(probs[quality]))
		total += float(probs[quality])
	if total <= 0.0:
		probs.merge(QUALITY_PROBS, true)
		return
	for quality in probs:
		probs[quality] = float(probs[quality]) / total


func _empty_bargain_result() -> Dictionary:
	return {
		"ji_yuan_scale": 0.0,
		"calamity_scale": 0.0,
		"log": "",
		"special": "",
	}


func _append_stage_change_to_message(player: PlayerData, before_stage: String, message: String) -> String:
	var after_stage: String = get_cultivation_stage_name(player)
	if before_stage != "" and after_stage != before_stage:
		return message + "，升至" + after_stage
	return message


func _apply_ji_yuan(player: PlayerData, ji_yuan: Dictionary, ji_yuan_value: float) -> String:
	var value: float = ji_yuan_value
	var message: String = ""
	match str(ji_yuan.get("effect_type", "")):
		"ling_li":
			var before_stage: String = get_cultivation_stage_name(player)
			var qi_gan_bonus: float = 1.0 + float(player.stats.get("气感", 0)) * 0.05 + float(player.refined_bonuses.get("灵力获取", 0.0))
			var amount: int = int(round(value * qi_gan_bonus))
			player.ling_li += amount
			message = "灵力 +" + str(amount)
			message = _append_stage_change_to_message(player, before_stage, message)
		"heal_percent":
			var max_hp: int = _get_player_max_hp(player)
			var heal_amount: int = int(round(max_hp * value / 100.0))
			player.qi_xue = min(max_hp, player.qi_xue + heal_amount)
			message = "气血 +" + str(heal_amount)
		"ling_shi":
			var stone_amount: int = int(round(value))
			player.ling_shi += stone_amount
			message = "灵石 +" + str(stone_amount)
		"technique":
			var technique: Dictionary = generate_technique(str(ji_yuan.get("quality", "良品")))
			message = _store_equipment_item(player, "technique", technique)
			value = 1.0
		"treasure":
			var treasure: Dictionary = generate_treasure()
			message = _store_equipment_item(player, "treasure", treasure)
			value = 1.0
		"dan":
			if value >= 0.2:
				message = _grant_breakthrough_dan(player)
			else:
				var before_dan_stage: String = get_cultivation_stage_name(player)
				var dan_li: int = int(round(45.0 * maxf(0.25, value)))
				player.ling_li += dan_li
				message = "残丹炼化，修为 +" + str(dan_li)
				message = _append_stage_change_to_message(player, before_dan_stage, message)
			value = 1.0
		"stat_up":
			var stat: String = str(BASE_STATS[rng.randi_range(0, BASE_STATS.size() - 1)])
			player.stats[stat] = int(player.stats.get(stat, 0)) + 1
			value = 1.0
			message = stat + " +1"
		"shou_yuan":
			var years: int = int(round(value))
			player.shou_yuan += years
			message = "寿元 +" + str(years)
		"companion":
			var companion: Dictionary = ji_yuan.get("companion", {}) as Dictionary
			if companion.is_empty():
				companion = generate_companion()
			companion = companion.duplicate(true)
			if value < 1.0:
				companion["bonus_value"] = float(companion.get("bonus_value", 0.0)) * value
				companion["effect_desc"] = str(companion.get("effect_desc", "")) + "（半效果）"
			message = _store_equipment_item(player, "companion", companion)
			value = 1.0
	player.total_ji_yuan_gained += int(round(value))
	player.ji_yuan_list.append(ji_yuan.duplicate(true))
	return message


func _apply_calamity(player: PlayerData, calamity: Dictionary, calamity_value: float) -> String:
	var value: float = calamity_value
	var message: String = ""
	match str(calamity.get("effect_type", "")):
		"ling_li_loss":
			var amount: int = int(round(value))
			player.ling_li = max(0, player.ling_li - amount)
			message = "灵力 -" + str(amount)
		"hp_percent_loss", "hp_damage":
			var max_hp: int = _get_player_max_hp(player)
			var damage: int = int(round(max_hp * value / 100.0))
			player.qi_xue = max(1, player.qi_xue - damage)
			message = "气血 -" + str(damage)
		"enemy":
			start_battle(str(calamity.get("quality", "极品")))
			value = 1.0
			message = "遭遇敌人"
		"shou_yuan_loss":
			var years: int = int(round(value))
			player.shou_yuan = max(1, player.shou_yuan - years)
			message = "寿元 -" + str(years)
		"tribulation":
			tribulation_triggered.emit(calamity)
			value = 1.0
			message = "天劫征兆"
	player.total_calamity_taken += int(round(value))
	player.calamity_list.append(calamity.duplicate(true))
	return message


func start_battle(enemy_quality: String) -> void:
	if not NetworkManager.is_host:
		return
	if current_state == GameState.BATTLE:
		return

	var template: Dictionary = ENEMIES.get(enemy_quality, ENEMIES["极品"]) as Dictionary
	current_enemy = template.duplicate(true)
	if enemy_elite:
		current_enemy["hp"] = int(round(float(current_enemy.get("hp", 0)) * 1.5))
		current_enemy["attack"] = int(round(float(current_enemy.get("attack", 0)) * 1.5))

	current_enemy["max_hp"] = int(current_enemy.get("hp", 0))
	current_enemy["quality"] = enemy_quality
	current_enemy["name"] = enemy_quality + ("精英妖兽" if enemy_elite else "妖兽")
	battle_contributions.clear()
	battle_choices.clear()
	battle_log.clear()
	change_state(GameState.BATTLE)
	battle_started.emit(current_enemy)
	_show_battle.rpc(current_enemy)
	transition_to_scene("res://scenes/battle.tscn")


func settle_battle_action(peer_id: int, action: String) -> void:
	if not NetworkManager.is_host:
		return
	if current_enemy.is_empty():
		return

	battle_choices[peer_id] = action
	if not battle_choices.has(player_a.peer_id) or not battle_choices.has(player_b.peer_id):
		return

	var action_a: String = str(battle_choices[player_a.peer_id])
	var action_b: String = str(battle_choices[player_b.peer_id])
	var enemy_attack: int = int(current_enemy.get("attack", 0))
	var enemy_damage_a: int = 0
	var enemy_damage_b: int = 0
	var hurt_a: int = 0
	var hurt_b: int = 0
	var escaped_a: bool = false
	var escaped_b: bool = false
	var tried_escape_a: bool = action_a == "逃跑"
	var tried_escape_b: bool = action_b == "逃跑"
	var escape_success_a: bool = _roll_escape_success(player_a) if tried_escape_a else false
	var escape_success_b: bool = _roll_escape_success(player_b) if tried_escape_b else false
	var escape_chance_a: float = get_escape_success_chance(player_a)
	var escape_chance_b: float = get_escape_success_chance(player_b)

	if action_a == "抢攻" and action_b == "抢攻":
		enemy_damage_a = 3
		enemy_damage_b = 3
		hurt_a = enemy_attack
		hurt_b = enemy_attack
		battle_log.append("双方抢攻，各受全额反击")
	elif action_a == "抢攻" and action_b == "周旋":
		enemy_damage_a = 3
		enemy_damage_b = 2
		hurt_a = enemy_attack
		hurt_b = int(round(float(enemy_attack) * 0.5))
		battle_log.append("一方抢攻，一方周旋")
	elif action_a == "周旋" and action_b == "抢攻":
		enemy_damage_a = 2
		enemy_damage_b = 3
		hurt_a = int(round(float(enemy_attack) * 0.5))
		hurt_b = enemy_attack
		battle_log.append("一方周旋，一方抢攻")
	elif action_a == "抢攻" and action_b == "逃跑":
		enemy_damage_a = 3
		hurt_a = enemy_attack * 2
		if escape_success_b:
			escaped_b = true
			battle_log.append("玩家A抢攻，玩家B逃脱成功")
		else:
			hurt_b = _escape_fail_hurt(enemy_attack)
			battle_log.append("玩家A抢攻，玩家B逃跑失败")
	elif action_a == "逃跑" and action_b == "抢攻":
		enemy_damage_b = 3
		hurt_b = enemy_attack * 2
		if escape_success_a:
			escaped_a = true
			battle_log.append("玩家B抢攻，玩家A逃脱成功")
		else:
			hurt_a = _escape_fail_hurt(enemy_attack)
			battle_log.append("玩家B抢攻，玩家A逃跑失败")
	elif action_a == "周旋" and action_b == "周旋":
		hurt_a = int(round(float(enemy_attack) * 0.25))
		hurt_b = int(round(float(enemy_attack) * 0.25))
		battle_log.append("双方周旋，少量受伤")
	elif action_a == "周旋" and action_b == "逃跑":
		enemy_damage_a = 2
		hurt_a = enemy_attack
		if escape_success_b:
			escaped_b = true
			battle_log.append("玩家A周旋，玩家B逃脱成功")
		else:
			hurt_b = _escape_fail_hurt(enemy_attack)
			battle_log.append("玩家A周旋，玩家B逃跑失败")
	elif action_a == "逃跑" and action_b == "周旋":
		enemy_damage_b = 2
		hurt_b = enemy_attack
		if escape_success_a:
			escaped_a = true
			battle_log.append("玩家B周旋，玩家A逃脱成功")
		else:
			hurt_a = _escape_fail_hurt(enemy_attack)
			battle_log.append("玩家B周旋，玩家A逃跑失败")
	else:
		if escape_success_a and escape_success_b:
			handle_double_escape()
			return
		if escape_success_a:
			escaped_a = true
			hurt_b = _escape_fail_hurt(enemy_attack)
			battle_log.append("玩家A逃脱成功，玩家B逃跑失败")
		elif escape_success_b:
			escaped_b = true
			hurt_a = _escape_fail_hurt(enemy_attack)
			battle_log.append("玩家B逃脱成功，玩家A逃跑失败")
		else:
			hurt_a = _escape_fail_hurt(enemy_attack)
			hurt_b = _escape_fail_hurt(enemy_attack)
			battle_log.append("双方逃跑失败，各受反击")

	current_enemy["hp"] = maxi(0, int(current_enemy.get("hp", 0)) - enemy_damage_a - enemy_damage_b)
	player_a.qi_xue = maxi(0, player_a.qi_xue - hurt_a)
	player_b.qi_xue = maxi(0, player_b.qi_xue - hurt_b)
	if not escaped_a:
		battle_contributions[player_a.peer_id] = float(battle_contributions.get(player_a.peer_id, 0.0)) + float(enemy_damage_a)
	if not escaped_b:
		battle_contributions[player_b.peer_id] = float(battle_contributions.get(player_b.peer_id, 0.0)) + float(enemy_damage_b)
	battle_choices.clear()

	var update_data: Dictionary = _battle_state_data({
		"action_a": action_a,
		"action_b": action_b,
		"hurt_a": hurt_a,
		"hurt_b": hurt_b,
		"enemy_damage": enemy_damage_a + enemy_damage_b,
		"escaped_a": escaped_a,
		"escaped_b": escaped_b,
		"escape_chance_a": escape_chance_a,
		"escape_chance_b": escape_chance_b,
	})
	NetworkManager.send_message("battle_update", update_data)
	on_battle_update(update_data)

	if current_enemy.is_empty():
		return
	if int(current_enemy.get("hp", 0)) <= 0:
		distribute_loot()
		return
	if player_a.qi_xue <= 0:
		handle_player_death(player_a)
		return
	if player_b.qi_xue <= 0:
		handle_player_death(player_b)
		return


func get_escape_success_chance(player: PlayerData) -> float:
	if player == null:
		return 0.0
	var quality: String = str(current_enemy.get("quality", "极品"))
	var quality_penalty: float = _escape_quality_penalty(quality)
	var chance: float = ESCAPE_BASE_CHANCE
	chance += float(player.stats.get("身法", 0)) * ESCAPE_SHEN_FA_CHANCE
	chance += float(player.speed) * ESCAPE_SPEED_CHANCE
	chance -= quality_penalty
	if enemy_elite:
		chance -= ESCAPE_ELITE_PENALTY
	return clamp(chance, 0.15, 0.92)


func _roll_escape_success(player: PlayerData) -> bool:
	return rng.randf() <= get_escape_success_chance(player)


func _escape_fail_hurt(enemy_attack: int) -> int:
	return maxi(1, int(round(float(enemy_attack) * ESCAPE_FAIL_HURT_MULTIPLIER)))


func _escape_quality_penalty(quality: String) -> float:
	match quality:
		"凡品":
			return 0.0
		"良品":
			return 0.04
		"上品":
			return 0.08
		"极品":
			return 0.13
		"仙品":
			return 0.18
		"道品":
			return 0.24
		_:
			return 0.12


func handle_double_escape() -> void:
	enemy_elite = true
	battle_log.append("双方逃跑，敌人记住了这份因果，下次更强")
	var data: Dictionary = _battle_state_data({"message": "双方逃跑，敌人下次将变为精英"})
	NetworkManager.send_message("battle_end", data)
	battle_ended.emit(data)
	_end_battle.rpc(data)
	change_state(GameState.BARGAIN)
	transition_to_scene("res://scenes/game_main.tscn")
	_resume_lottery_after_battle()


func distribute_loot() -> void:
	var total_contribution: float = maxf(1.0, float(battle_contributions.get(player_a.peer_id, 0.0)) + float(battle_contributions.get(player_b.peer_id, 0.0)))
	var share_a: float = float(battle_contributions.get(player_a.peer_id, 0.0)) / total_contribution
	var share_b: float = float(battle_contributions.get(player_b.peer_id, 0.0)) / total_contribution
	var drop_desc: String = str(current_enemy.get("drop_desc", "掉落"))
	var reward_ling_li: int = _enemy_ling_li_reward(str(current_enemy.get("quality", "极品")))
	var reward_a: int = int(round(float(reward_ling_li) * share_a))
	var reward_b: int = int(round(float(reward_ling_li) * share_b))
	player_a.ling_li += reward_a
	player_b.ling_li += reward_b
	var message: String = "敌人被击败，掉落：" + drop_desc + "，修为 A +" + str(reward_a) + " / B +" + str(reward_b) + "。贡献 A " + str(int(share_a * 100.0)) + "% / B " + str(int(share_b * 100.0)) + "%"
	if enemy_elite:
		message += "；精英额外掉落"
		player_a.ling_li += int(round(20.0 * share_a))
		player_b.ling_li += int(round(20.0 * share_b))

	enemy_elite = false
	battle_log.append(message)
	var data: Dictionary = _battle_state_data({"message": message, "loot": drop_desc, "share_a": share_a, "share_b": share_b})
	current_enemy.clear()
	NetworkManager.send_message("battle_end", data)
	battle_ended.emit(data)
	_end_battle.rpc(data)
	change_state(GameState.BARGAIN)
	transition_to_scene("res://scenes/game_main.tscn")
	_resume_lottery_after_battle()


func _enemy_ling_li_reward(quality: String) -> int:
	match quality:
		"上品":
			return 80
		"极品":
			return 120
		"仙品":
			return 180
		"道品":
			return 260
		_:
			return 100


func on_battle_update(data: Dictionary) -> void:
	current_enemy = data.get("enemy", current_enemy) as Dictionary
	_apply_player_snapshot(player_a, data.get("player_a", {}) as Dictionary)
	_apply_player_snapshot(player_b, data.get("player_b", {}) as Dictionary)
	battle_log = data.get("battle_log", battle_log) as Array
	battle_updated.emit(data)


func on_battle_end(data: Dictionary) -> void:
	on_battle_update(data)
	battle_ended.emit(data)
	await get_tree().create_timer(1.2).timeout
	if current_card_index >= 0 and current_card_index < current_lottery_cards.size():
		change_state(GameState.BARGAIN)
	transition_to_scene("res://scenes/game_main.tscn")


func _resume_lottery_after_battle() -> void:
	await get_tree().create_timer(1.6).timeout
	if not NetworkManager.is_host:
		return
	if current_state != GameState.BARGAIN:
		return
	if current_card_index >= 0 and current_card_index < current_lottery_cards.size():
		_reveal_card_for_bargain(current_card_index)
	else:
		check_breakthrough()


func _battle_state_data(extra: Dictionary = {}) -> Dictionary:
	var data: Dictionary = {
		"enemy": current_enemy,
		"player_a": _player_snapshot(player_a),
		"player_b": _player_snapshot(player_b),
		"battle_contributions": battle_contributions,
		"battle_log": battle_log,
	}
	data.merge(extra, true)
	return data


func _get_player_max_hp(player: PlayerData) -> int:
	var hp_bonus: float = float(player.refined_bonuses.get("气血上限", 0.0))
	return maxi(1, int(round(100.0 * (1.0 + float(player.stats.get("体魄", 0)) * 0.04 + hp_bonus))))


func _grant_breakthrough_dan(player: PlayerData) -> String:
	if player == null:
		return "丹药入手"

	var dan_name: String = _next_required_dan_name(player)
	if dan_name == "":
		var before_stage: String = get_cultivation_stage_name(player)
		var amount: int = 80
		player.ling_li += amount
		return _append_stage_change_to_message(player, before_stage, "丹力化为修为 +" + str(amount))

	var dans: Array = player.final_attributes.get("dans", []) as Array
	if not dans.has(dan_name):
		dans.append(dan_name)
	player.final_attributes["dans"] = dans
	return dan_name + "入手"


func _next_required_dan_name(player: PlayerData) -> String:
	if player == null:
		return ""
	var next_realm: String = str(NEXT_REALM_MAP.get(player.realm, ""))
	if next_realm == "":
		return ""
	var realm_data: Dictionary = REALMS.get(next_realm, {}) as Dictionary
	return str(realm_data.get("dan", ""))


func has_dan(player: PlayerData, dan_name: String) -> bool:
	if dan_name == "":
		return true
	if player == null:
		return false

	var dans: Array = player.final_attributes.get("dans", []) as Array
	if dans.has(dan_name):
		return true

	for treasure in player.treasures:
		if treasure is Dictionary and str(treasure.get("name", "")) == dan_name:
			return true

	for entry in player.backpack:
		if not entry is Dictionary:
			continue
		var item: Dictionary = entry as Dictionary
		var item_data: Dictionary = item.get("data", {}) as Dictionary
		if str(item_data.get("name", "")) == dan_name:
			return true

	var next_realm: String = str(NEXT_REALM_MAP.get(player.realm, ""))
	if next_realm != "":
		var realm_data: Dictionary = REALMS.get(next_realm, {}) as Dictionary
		var req: int = int(realm_data.get("ling_li_req", 0))
		if req > 0 and player.ling_li >= req + 80:
			return true
	return false


func get_breakthrough_status(player: PlayerData) -> Dictionary:
	var result: Dictionary = {
		"can": false,
		"type": "",
		"reason": "无法突破",
		"target_name": "",
		"next_realm": "",
		"ling_li_req": 0,
		"dan": "",
	}
	if player == null:
		result["reason"] = "未找到玩家"
		return result

	var stage: int = _get_minor_stage(player)
	if stage < MINOR_STAGE_NAMES.size():
		var next_stage_name: String = get_next_breakthrough_name(player)
		var minor_req: int = get_next_breakthrough_req(player)
		result["type"] = "minor"
		result["target_name"] = next_stage_name
		result["ling_li_req"] = minor_req
		result["success_chance"] = get_breakthrough_success_chance(player, "minor")
		if player.ling_li < minor_req:
			result["reason"] = "小境界修为不足：" + str(player.ling_li) + " / " + str(minor_req)
			return result
		result["can"] = true
		result["reason"] = "可突破至" + next_stage_name
		return result

	if player.realm == "元婴期":
		result["type"] = "duel"
		result["target_name"] = "仙位之争"
		result["ling_li_req"] = DUEL_LING_LI_REQ
		if player.ling_li < DUEL_LING_LI_REQ:
			result["reason"] = "仙位之争修为不足：" + str(player.ling_li) + " / " + str(DUEL_LING_LI_REQ)
			return result
		result["can"] = true
		result["reason"] = "可开启仙位之争"
		return result

	var next_realm: String = str(NEXT_REALM_MAP.get(player.realm, ""))
	if next_realm == "":
		result["reason"] = "当前境界暂无后续突破"
		return result

	var realm_data: Dictionary = REALMS.get(next_realm, {}) as Dictionary
	var ling_li_req: int = int(realm_data.get("ling_li_req", 0))
	var dan_name: String = str(realm_data.get("dan", ""))
	result["type"] = "major"
	result["target_name"] = next_realm
	result["next_realm"] = next_realm
	result["ling_li_req"] = ling_li_req
	result["dan"] = dan_name
	result["success_chance"] = get_breakthrough_success_chance(player, "major")

	if player.ling_li < ling_li_req:
		result["reason"] = "修为不足：" + str(player.ling_li) + " / " + str(ling_li_req)
		return result
	if not has_dan(player, dan_name):
		result["reason"] = "缺少" + dan_name + "，可在坊市购买"
		return result

	result["can"] = true
	result["reason"] = "可突破至" + next_realm
	return result


func request_breakthrough(peer_id: int) -> void:
	if not NetworkManager.is_host:
		return

	if current_state == GameState.AUCTION or current_state == GameState.TRIBULATION or current_state == GameState.BATTLE or current_state == GameState.DUEL or current_state == GameState.ENDING:
		var busy_data: Dictionary = _breakthrough_feedback_data(peer_id, "当前状态无法突破")
		NetworkManager.send_message("breakthrough_feedback", busy_data)
		on_breakthrough_feedback(busy_data)
		return

	var player: PlayerData = get_player_by_peer(peer_id)
	var status: Dictionary = get_breakthrough_status(player)
	if bool(status.get("can", false)):
		match str(status.get("type", "")):
			"minor":
				_start_minor_breakthrough(player, peer_id, str(status.get("target_name", "")))
			"duel":
				_trigger_final_duel()
			_:
				_start_breakthrough(player, str(status.get("next_realm", "")))
		return

	var feedback_data: Dictionary = _breakthrough_feedback_data(peer_id, str(status.get("reason", "无法突破")))
	NetworkManager.send_message("breakthrough_feedback", feedback_data)
	on_breakthrough_feedback(feedback_data)


func _start_minor_breakthrough(player: PlayerData, peer_id: int, target_name: String) -> void:
	if player == null:
		return

	var chance: float = get_breakthrough_success_chance(player, "minor")
	if rng.randf() > chance:
		var fail_data: Dictionary = _apply_breakthrough_failure(player, "minor")
		var fail_message: String = player.player_name + "冲击" + target_name + "失败，修为 -" + str(int(fail_data.get("ling_li_loss", 0))) + "，气血 -" + str(int(fail_data.get("hp_damage", 0)))
		var fail_feedback: Dictionary = _breakthrough_feedback_data(peer_id, fail_message)
		NetworkManager.send_message("breakthrough_feedback", fail_feedback)
		on_breakthrough_feedback(fail_feedback)
		return

	player.minor_stage = clampi(player.minor_stage + 1, 1, MINOR_STAGE_NAMES.size())
	var reached_name: String = get_cultivation_stage_name(player)
	var message: String = player.player_name + "突破至" + (target_name if target_name != "" else reached_name) + "，成功率 " + str(int(round(chance * 100.0))) + "%"
	var data: Dictionary = _breakthrough_feedback_data(peer_id, message)
	NetworkManager.send_message("breakthrough_feedback", data)
	on_breakthrough_feedback(data)
	check_duel_trigger()


func _breakthrough_feedback_data(peer_id: int, message: String) -> Dictionary:
	return {
		"peer_id": peer_id,
		"message": message,
		"player_a": _player_snapshot(player_a),
		"player_b": _player_snapshot(player_b),
	}


func on_breakthrough_feedback(data: Dictionary) -> void:
	_apply_player_snapshot(player_a, data.get("player_a", {}) as Dictionary)
	_apply_player_snapshot(player_b, data.get("player_b", {}) as Dictionary)
	breakthrough_feedback.emit(data)


func check_breakthrough() -> void:
	if not NetworkManager.is_host:
		return
	if check_duel_trigger():
		return

	_start_new_round.rpc()
	_start_new_round()


func _start_breakthrough(player: PlayerData, next_realm: String) -> void:
	if player == null or next_realm == "":
		return

	pending_breakthrough_player = player
	tribulation_next_realm = next_realm
	pending_tribulation_data = (TRIBULATIONS[next_realm] as Dictionary).duplicate(true)
	pending_tribulation_data["player_name"] = player.player_name
	pending_tribulation_data["player_peer_id"] = player.peer_id
	pending_tribulation_data["next_realm"] = next_realm
	bargain_choices.clear()
	bargain_continue_votes.clear()
	tribulation_choices.clear()
	change_state(GameState.TRIBULATION)
	tribulation_triggered.emit(pending_tribulation_data)
	_show_tribulation.rpc(pending_tribulation_data)
	transition_to_scene("res://scenes/tribulation.tscn")


@rpc("authority", "call_remote", "reliable")
func _show_tribulation(data: Dictionary) -> void:
	pending_tribulation_data = data.duplicate(true)
	tribulation_next_realm = str(data.get("next_realm", ""))
	change_state(GameState.TRIBULATION)
	tribulation_triggered.emit(pending_tribulation_data)
	transition_to_scene("res://scenes/tribulation.tscn")


@rpc("authority", "call_remote", "reliable")
func _start_new_round() -> void:
	round_started = false
	transition_to_scene("res://scenes/game_main.tscn")
	change_state(GameState.ROUND_START)


func settle_tribulation(peer_id: int, choice: String) -> void:
	if not NetworkManager.is_host:
		return
	if pending_breakthrough_player == null:
		return

	tribulation_choices[peer_id] = choice
	if not tribulation_choices.has(player_a.peer_id) or not tribulation_choices.has(player_b.peer_id):
		return

	var other_player: PlayerData = player_b if pending_breakthrough_player == player_a else player_a
	var breakthrough_choice: String = str(tribulation_choices[pending_breakthrough_player.peer_id])
	var other_choice: String = str(tribulation_choices[other_player.peer_id])
	var damage_pct: float = float(pending_tribulation_data.get("damage_pct", 0.0))
	var shared_pct: float = float(pending_tribulation_data.get("shared_pct", 0.0))
	var dodge_reward: int = int(pending_tribulation_data.get("dodge_reward", 0))
	var breakthrough_damage_pct: float = 0.0
	var other_damage_pct: float = 0.0
	var breakthrough_reward: int = 0
	var other_reward: int = 0

	if breakthrough_choice == "扛" and other_choice == "扛":
		breakthrough_damage_pct = shared_pct
		other_damage_pct = shared_pct
	elif breakthrough_choice == "躲" and other_choice == "躲":
		breakthrough_damage_pct = damage_pct
		other_damage_pct = damage_pct
	elif breakthrough_choice == "扛" and other_choice == "躲":
		breakthrough_damage_pct = damage_pct
		other_reward = dodge_reward
	else:
		other_damage_pct = damage_pct
		breakthrough_reward = dodge_reward

	_apply_tribulation_damage(pending_breakthrough_player, breakthrough_damage_pct)
	_apply_tribulation_damage(other_player, other_damage_pct)
	pending_breakthrough_player.ling_li += breakthrough_reward
	other_player.ling_li += other_reward
	pending_breakthrough_player.tribulation_choices.append(tribulation_choices.duplicate(true))
	other_player.tribulation_choices.append(tribulation_choices.duplicate(true))

	var result: Dictionary = {
		"breakthrough_peer_id": pending_breakthrough_player.peer_id,
		"other_peer_id": other_player.peer_id,
		"breakthrough_choice": breakthrough_choice,
		"other_choice": other_choice,
		"breakthrough_damage_pct": breakthrough_damage_pct,
		"other_damage_pct": other_damage_pct,
		"breakthrough_reward": breakthrough_reward,
		"other_reward": other_reward,
		"next_realm": tribulation_next_realm,
		"player_a": _player_snapshot(player_a),
		"player_b": _player_snapshot(player_b),
	}

	if pending_breakthrough_player.qi_xue <= 0:
		result["death_peer_id"] = pending_breakthrough_player.peer_id
		handle_player_death(pending_breakthrough_player, result)
		return
	if other_player.qi_xue <= 0:
		result["death_peer_id"] = other_player.peer_id
		handle_player_death(other_player, result)
		return

	var breakthrough_chance: float = get_breakthrough_success_chance(pending_breakthrough_player, "major")
	if rng.randf() > breakthrough_chance:
		var fail_data: Dictionary = _apply_breakthrough_failure(pending_breakthrough_player, "major")
		result["success"] = false
		result["failed"] = true
		result["success_chance"] = breakthrough_chance
		result["message"] = pending_breakthrough_player.player_name + "渡过天劫，却突破失败，修为 -" + str(int(fail_data.get("ling_li_loss", 0))) + "，气血 -" + str(int(fail_data.get("hp_damage", 0)))
		result["player_a"] = _player_snapshot(player_a)
		result["player_b"] = _player_snapshot(player_b)
		NetworkManager.send_message("tribulation_result", result)
		on_tribulation_result(result)
		pending_breakthrough_player = null

		await get_tree().create_timer(2.0).timeout
		_start_new_round.rpc()
		_start_new_round()
		return

	var realm_data: Dictionary = REALMS[tribulation_next_realm] as Dictionary
	pending_breakthrough_player.realm = tribulation_next_realm
	pending_breakthrough_player.minor_stage = 1
	pending_breakthrough_player.speed = int(realm_data.get("speed_base", 10)) + int(pending_breakthrough_player.stats.get("身法", 0)) * 6
	result["success"] = true
	result["success_chance"] = breakthrough_chance
	result["message"] = pending_breakthrough_player.player_name + "突破至" + tribulation_next_realm + "，成功率 " + str(int(round(breakthrough_chance * 100.0))) + "%"
	result["player_a"] = _player_snapshot(player_a)
	result["player_b"] = _player_snapshot(player_b)
	NetworkManager.send_message("tribulation_result", result)
	on_tribulation_result(result)

	await get_tree().create_timer(2.0).timeout
	if check_duel_trigger():
		return
	_start_new_round.rpc()
	_start_new_round()


func on_tribulation_result(data: Dictionary) -> void:
	_apply_player_snapshot(player_a, data.get("player_a", {}) as Dictionary)
	_apply_player_snapshot(player_b, data.get("player_b", {}) as Dictionary)
	tribulation_settled.emit(data)


func handle_player_death(dead_player: PlayerData, result: Dictionary = {}) -> void:
	var alive_player: PlayerData = player_b if dead_player == player_a else player_a
	alive_player.ling_li += int(dead_player.ling_li / 2)
	result["message"] = dead_player.player_name + "陨落，" + alive_player.player_name + "承其半数灵力"
	result["player_a"] = _player_snapshot(player_a)
	result["player_b"] = _player_snapshot(player_b)
	NetworkManager.send_message("tribulation_result", result)
	on_tribulation_result(result)

	if alive_player.realm == "元婴期":
		change_state(GameState.ENDING)
		var ending_data: Dictionary = {"winner": alive_player.player_name}
		_change_scene_to_ending.rpc(ending_data)
		transition_to_scene("res://scenes/ending.tscn")
	else:
		change_state(GameState.ROUND_START)
		_start_new_round.rpc()
		_start_new_round()


func _apply_tribulation_damage(player: PlayerData, pct: float) -> void:
	if pct <= 0.0:
		return
	player.qi_xue = maxi(0, player.qi_xue - int(player.qi_xue * pct))


func _player_snapshot(player: PlayerData) -> Dictionary:
	return {
		"player_name": player.player_name,
		"stats": player.stats,
		"shou_yuan": player.shou_yuan,
		"ling_li": player.ling_li,
		"ling_shi": player.ling_shi,
		"qi_xue": player.qi_xue,
		"realm": player.realm,
		"minor_stage": player.minor_stage,
		"techniques": player.techniques,
		"treasures": player.treasures,
		"backpack": player.backpack,
		"backpack_capacity": player.backpack_capacity,
		"companions": player.companions,
		"final_attributes": player.final_attributes,
		"total_ji_yuan_gained": player.total_ji_yuan_gained,
		"total_calamity_taken": player.total_calamity_taken,
	}


func _apply_player_snapshot(player: PlayerData, data: Dictionary) -> void:
	if player == null or data.is_empty():
		return
	player.player_name = str(data.get("player_name", player.player_name))
	var incoming_stats: Dictionary = data.get("stats", player.stats) as Dictionary
	player.stats = _normalize_stats(incoming_stats)
	player.shou_yuan = int(data.get("shou_yuan", player.shou_yuan))
	player.ling_li = int(data.get("ling_li", player.ling_li))
	player.ling_shi = int(data.get("ling_shi", player.ling_shi))
	player.qi_xue = int(data.get("qi_xue", player.qi_xue))
	player.realm = str(data.get("realm", player.realm))
	player.minor_stage = clampi(int(data.get("minor_stage", player.minor_stage)), 1, MINOR_STAGE_NAMES.size())
	player.techniques = data.get("techniques", player.techniques).duplicate(true)
	player.treasures = data.get("treasures", player.treasures).duplicate(true)
	player.backpack = data.get("backpack", player.backpack).duplicate(true)
	player.backpack_capacity = int(data.get("backpack_capacity", player.backpack_capacity))
	player.companions = data.get("companions", player.companions).duplicate(true)
	player.final_attributes = data.get("final_attributes", player.final_attributes).duplicate(true)
	player.total_ji_yuan_gained = int(data.get("total_ji_yuan_gained", player.total_ji_yuan_gained))
	player.total_calamity_taken = int(data.get("total_calamity_taken", player.total_calamity_taken))


func generate_scroll_data(player: PlayerData, is_winner: bool, opponent: PlayerData) -> Dictionary:
	var title: String = _get_life_title(player)
	var opponent_title: String = _get_life_title(opponent)
	var final_stats: Dictionary = calculate_duel_stats(player)
	var techniques_with_resonances: Array = _get_techniques_with_resonances(player)
	var key_rounds: String = _get_key_duel_rounds(player)
	var final_blow: String = _get_final_blow(player)
	var final_choice_desc: String = _get_final_choice_desc(player, is_winner)
	return {
		"is_winner": is_winner,
		"verdict": _get_life_verdict(player, is_winner),
		"凡躯": {
			"stats": player.stats.duplicate(true),
			"shou_yuan": int(player.final_attributes.get("initial_shou_yuan", calculate_initial_shou_yuan(player))),
			"desc": _get_mortal_desc(player),
		},
		"机缘录": {
			"total_gained": player.total_ji_yuan_gained,
			"qiang_count": player.total_qiang_count,
			"rang_count": player.total_rang_count,
			"best_ji_yuan": _get_best_record_desc(player.ji_yuan_list),
			"techniques": player.techniques.duplicate(true),
			"treasures": player.treasures.duplicate(true),
		},
		"灾厄簿": {
			"total_taken": player.total_calamity_taken,
			"kang_count": player.total_rang_count,
			"tui_count": player.total_qiang_count,
			"worst_calamity": _get_best_record_desc(player.calamity_list),
			"shuang_kang": player.total_shuang_rang,
		},
		"天劫记": {
			"tribulations": player.tribulation_choices.duplicate(true),
			"worst_tribulation": _get_worst_tribulation_desc(player),
		},
		"对决录": {
			"final_stats": final_stats,
			"techniques_with_resonances": techniques_with_resonances,
			"key_rounds": key_rounds,
			"final_blow": final_blow,
			"final_choice": final_choice_desc,
		},
		"红尘录": {
			"companions": _get_companion_fates(player, is_winner),
		},
		"盖棺定论": {
			"title": title,
			"opponent_summary": _get_opponent_summary(opponent_title, opponent),
		},
	}


func trigger_ending(winner: PlayerData, loser: PlayerData) -> void:
	var winner_scroll: Dictionary = generate_scroll_data(winner, true, loser)
	var loser_scroll: Dictionary = generate_scroll_data(loser, false, winner)
	var data: Dictionary = {
		"winner_peer_id": winner.peer_id,
		"loser_peer_id": loser.peer_id,
		"scrolls": {
			str(winner.peer_id): winner_scroll,
			str(loser.peer_id): loser_scroll,
		},
	}
	change_state(GameState.ENDING)
	_show_ending.rpc(data)
	ending_scroll_data = _select_ending_scroll_data(data)


func _select_ending_scroll_data(data: Dictionary) -> Dictionary:
	if data.has("verdict"):
		return data.duplicate(true)
	var scrolls: Dictionary = data.get("scrolls", {}) as Dictionary
	var local_peer_id: int = multiplayer.get_unique_id()
	var key: String = str(local_peer_id)
	if scrolls.has(key):
		return (scrolls[key] as Dictionary).duplicate(true)
	if NetworkManager.is_host and scrolls.has(str(player_a.peer_id)):
		return (scrolls[str(player_a.peer_id)] as Dictionary).duplicate(true)
	if not scrolls.is_empty():
		var first_key: String = str(scrolls.keys()[0])
		return (scrolls[first_key] as Dictionary).duplicate(true)
	return {}


func reset_game() -> void:
	current_state = GameState.STAT_ALLOCATION
	round_number = 0
	player_a = PlayerData.new()
	player_a.player_name = "玩家A"
	player_b = PlayerData.new()
	player_b.player_name = "玩家B"
	current_lottery_results.clear()
	current_lottery_cards.clear()
	current_card_index = 0
	lottery_energy_injections.clear()
	lottery_energy_started = false
	current_bargain_index = 0
	current_enemy.clear()
	enemy_elite = false
	current_auction.clear()
	auction_choices.clear()
	battle_contributions.clear()
	battle_choices.clear()
	battle_log.clear()
	stat_allocation_started = false
	bargain_choices.clear()
	bargain_continue_votes.clear()
	pending_continue_next_index = -1
	pending_continue_round_finished = false
	pending_backpack_items.clear()
	round_started = false
	bargain_direction = 1
	pending_breakthrough_player = null
	tribulation_next_realm = ""
	pending_tribulation_data.clear()
	tribulation_choices.clear()
	duel_data.clear()
	duel_round_number = 0
	pending_duel_winner_key = ""
	pending_duel_loser_key = ""
	ending_scroll_data.clear()
	change_state(GameState.STAT_ALLOCATION)


func _get_life_verdict(player: PlayerData, is_winner: bool) -> String:
	var final_choice: String = str(player.final_attributes.get("final_choice", ""))
	if final_choice == "受让成仙":
		return "你本已败在仙门之前，却得故人一念相让。飞升之路从此多了一道还不清的人情。"
	if final_choice == "放弃仙位":
		return "你胜过最后一局，却在仙门前停步。你把成仙让给故人，自留人间一身风雪。"

	var ratios: Dictionary = _get_choice_ratios(player)
	var qiang_ratio: float = float(ratios["qiang"])
	var rang_ratio: float = float(ratios["rang"])
	if is_winner:
		if qiang_ratio > 0.70:
			return "你以杀证道，踏故人而上。仙路漫漫，自此孤影独行。"
		if rang_ratio > 0.70:
			return "你步步为营，以让为进。天道酬和，终成正果。"
		return "你顺势而为，不争不避。天命所归，实至名归。"

	if qiang_ratio > 0.70:
		return "你夺尽机缘，却输了最后一局。成也贪念，败也贪念。"
	if rang_ratio > 0.70:
		return "你以身为盾，护他周全。陨落之时，可曾后悔？"
	return "你机关算尽，终差一着。仙路无情，非战之罪。"


func _get_life_title(player: PlayerData) -> String:
	var final_choice: String = str(player.final_attributes.get("final_choice", ""))
	var ratios: Dictionary = _get_choice_ratios(player)
	var titles: Array[String] = []
	if final_choice == "放弃仙位":
		titles.append("让仙者")
	elif final_choice == "受让成仙":
		titles.append("承仙者")
	elif final_choice == "踏入仙门":
		titles.append("飞升者")
	elif float(ratios["qiang"]) > 0.70:
		titles.append("夺运者")
	elif float(ratios["rang"]) > 0.70:
		titles.append("守道人")
	else:
		titles.append("天命客")
	if player.total_shuang_rang > 5:
		titles.append("至诚者")
	if player.total_shuang_qiang > 5:
		titles.append("枭雄")
	return "·".join(titles)


func _get_choice_ratios(player: PlayerData) -> Dictionary:
	var total: int = max(1, player.total_qiang_count + player.total_rang_count)
	return {
		"qiang": float(player.total_qiang_count) / float(total),
		"rang": float(player.total_rang_count) / float(total),
	}


func _get_opponent_summary(opponent_title: String, opponent: PlayerData = null) -> String:
	if opponent != null:
		var final_choice: String = str(opponent.final_attributes.get("final_choice", ""))
		if final_choice == "放弃仙位":
			return "他胜过最后一局，却在仙门前停步，将飞升之位让给了你。"
		if final_choice == "受让成仙":
			return "他本已败落，却因你的相让得登仙门。"
		if final_choice == "踏入仙门":
			return "他没有回头，踏入仙门，成了最后的飞升者。"
		if final_choice == "败于仙争":
			return "他败在最后一局，仙路止于此处。"

	if opponent_title.contains("夺运者"):
		return "他夺尽机缘，终成仙位。你败于此人之手。"
	if opponent_title.contains("守道人"):
		return "他让了一世，最后一劫让出了仙位。"
	if opponent_title.contains("至诚者"):
		return "他曾真心待你，只是仙路无情。"
	return "他顺势而为，不争不避。"


func _get_final_choice_desc(player: PlayerData, is_winner: bool) -> String:
	var final_choice: String = str(player.final_attributes.get("final_choice", ""))
	match final_choice:
		"踏入仙门":
			return "最后一战既胜，你没有回头，踏入仙门。"
		"放弃仙位":
			return "最后一战既胜，你却放弃仙位，让对方飞升。"
		"受让成仙":
			return "你虽败于最后一战，却因对方相让，承其仙位而飞升。"
		"败于仙争":
			return "你败于最后一战，仙位与你擦肩而过。"
		_:
			return "你成就仙位。" if is_winner else "你止步仙门。"


func _get_mortal_desc(player: PlayerData) -> String:
	var strongest_stat: String = "体魄"
	var strongest_value: int = -1
	for stat in BASE_STATS:
		var value: int = int(player.stats.get(stat, 0))
		if value > strongest_value:
			strongest_stat = str(stat)
			strongest_value = value
	return "此身初入仙途，以" + strongest_stat + "见长，命数由此偏转。"


func _get_best_record_desc(records: Array) -> String:
	if records.is_empty():
		return "无"
	var best: Dictionary = {}
	var best_value: float = -1.0
	for record in records:
		if not record is Dictionary:
			continue
		var data: Dictionary = record
		var value: float = float(data.get("effect_value", data.get("value", 0.0))) * float(data.get("multiplier", 1.0))
		if value > best_value:
			best = data
			best_value = value
	if best.is_empty():
		return "无"
	return str(best.get("desc", str(best.get("quality", "")) + "·" + str(best.get("type", ""))))


func _get_worst_tribulation_desc(player: PlayerData) -> String:
	if player.tribulation_choices.is_empty():
		return "未历天劫"
	var latest: Variant = player.tribulation_choices.back()
	if latest is Dictionary:
		var choices: Array[String] = []
		var record: Dictionary = latest as Dictionary
		for key in record.keys():
			choices.append(str(record[key]))
		return "最近一劫：" + "、".join(choices)
	return "最近一劫：" + str(latest)


func _get_techniques_with_resonances(player: PlayerData) -> Array:
	var result: Array = []
	var active_links: Array = check_resonance(player)
	for technique in player.techniques:
		if not technique is Dictionary:
			continue
		var data: Dictionary = (technique as Dictionary).duplicate(true)
		data["active_links"] = active_links
		result.append(data)
	return result


func _get_key_duel_rounds(player: PlayerData) -> String:
	if player.duel_rounds.is_empty():
		return "终局未留下可考回合。"
	var lines: Array[String] = []
	for round_data in player.duel_rounds.slice(maxi(0, player.duel_rounds.size() - 3), player.duel_rounds.size()):
		if round_data is Dictionary:
			lines.append(str((round_data as Dictionary).get("log", "回合失载")))
		else:
			lines.append(str(round_data))
	return "；".join(lines)


func _get_final_blow(player: PlayerData) -> String:
	if player.duel_rounds.is_empty():
		return "最后一击湮没于天光之中。"
	var final_round: Variant = player.duel_rounds.back()
	if final_round is Dictionary:
		return str((final_round as Dictionary).get("log", "最后一击湮没于天光之中。"))
	return str(final_round)


func _get_companion_fates(player: PlayerData, is_winner: bool) -> Array:
	var result: Array = []
	for companion in player.companions:
		if not companion is Dictionary:
			continue
		var data: Dictionary = companion.duplicate(true)
		var name: String = str(data.get("name", ""))
		data["fate"] = "随主飞升" if is_winner else "随主陨落"
		data["last_words"] = str(COMPANION_LAST_WORDS.get(name, "仙路至此，各安天命。"))
		result.append(data)
	return result
