extends Node

enum GameState {STAT_ALLOCATION, ROUND_START, LOTTERY, BARGAIN, REST, CONTEST, AUCTION, BATTLE, BREAKTHROUGH, TRIBULATION, DUEL, ENDING, SECT_EVENT}

signal game_state_changed(new_state: int)
signal lottery_generated(results: Array)
signal lottery_energy_updated(count: int, total: int)
signal lottery_energy_ready()
signal lottery_card_revealed(index: int, card: Dictionary)
signal bargain_ready(index: int)
signal bargain_result(result: Dictionary)
signal contest_started(data: Dictionary)
signal backpack_changed(data: Dictionary)
signal market_changed(data: Dictionary)
signal auction_started(data: Dictionary)
signal auction_ended(data: Dictionary)
signal rest_started(data: Dictionary)
signal rest_updated(data: Dictionary)
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
signal sect_event_started(data: Dictionary)
signal sect_event_updated(data: Dictionary)
signal sect_event_finished(data: Dictionary)
signal npc_dialogue_changed(line: String)
signal set_bonus_triggered(data: Dictionary)

const QUALITY_PROBS := {
	"炼气级": 0.30,
	"筑基级": 0.25,
	"金丹级": 0.20,
	"元婴级": 0.15,
	"化神级": 0.07,
	"合体级": 0.03,
}

const QUALITY_ORDER := ["炼气级", "筑基级", "金丹级", "元婴级", "化神级", "合体级"]

const QUALITY_REALM_NAMES := {
	"炼气级": "炼气级",
	"筑基级": "筑基级",
	"金丹级": "金丹级",
	"元婴级": "元婴级",
	"化神级": "化神级",
	"合体级": "合体级",
}

const REALM_REWARD_QUALITY_PROBS := {
	0: {"炼气级": 0.50, "筑基级": 0.34, "金丹级": 0.14, "元婴级": 0.02, "化神级": 0.0, "合体级": 0.0},
	1: {"炼气级": 0.10, "筑基级": 0.45, "金丹级": 0.32, "元婴级": 0.10, "化神级": 0.03, "合体级": 0.0},
	2: {"炼气级": 0.02, "筑基级": 0.12, "金丹级": 0.43, "元婴级": 0.30, "化神级": 0.10, "合体级": 0.03},
	3: {"炼气级": 0.01, "筑基级": 0.05, "金丹级": 0.14, "元婴级": 0.42, "化神级": 0.28, "合体级": 0.10},
}

const QUALITY_MULTIPLIER := {
	"炼气级": 0.5,
	"筑基级": 0.7,
	"金丹级": 1.0,
	"元婴级": 1.3,
	"化神级": 1.6,
	"合体级": 2.0,
}

const QUALITY_DATA := {
	"炼气级": {"technique_multiplier": 0.5, "treasure_base_attack": 3, "treasure_awaken_threshold": 10, "companion_initial_bond": 1, "quality_factor": 1, "color": "#b0b0b0"},
	"筑基级": {"technique_multiplier": 0.7, "treasure_base_attack": 5, "treasure_awaken_threshold": 15, "companion_initial_bond": 2, "quality_factor": 2, "color": "#80c080"},
	"金丹级": {"technique_multiplier": 1.0, "treasure_base_attack": 8, "treasure_awaken_threshold": 20, "companion_initial_bond": 3, "quality_factor": 3, "color": "#6080d0"},
	"元婴级": {"technique_multiplier": 1.3, "treasure_base_attack": 12, "treasure_awaken_threshold": 30, "companion_initial_bond": 4, "quality_factor": 4, "color": "#c080e0"},
	"化神级": {"technique_multiplier": 1.6, "treasure_base_attack": 15, "treasure_awaken_threshold": 40, "companion_initial_bond": 5, "quality_factor": 5, "color": "#f0c040"},
	"合体级": {"technique_multiplier": 2.0, "treasure_base_attack": 18, "treasure_awaken_threshold": 50, "companion_initial_bond": 6, "quality_factor": 6, "color": "#ff80c0"},
}

const JI_YUAN_TYPES := [
	{"name": "修行", "base_effect": 45, "effect_type": "ling_li"},
	{"name": "治疗", "base_effect": 30, "effect_type": "heal_percent"},
	{"name": "灵泉沐浴", "base_effect": 40, "effect_type": "heal_percent"},
	{"name": "灵石", "base_effect": 350, "effect_type": "ling_shi"},
	{"name": "坊市", "base_effect": 400, "effect_type": "auction"},
	{"name": "功法", "base_effect": 0, "effect_type": "technique"},
	{"name": "法宝", "base_effect": 0, "effect_type": "treasure"},
	{"name": "灵草", "base_effect": 0, "effect_type": "alchemy_material"},
	{"name": "灵草丛", "base_effect": 0, "effect_type": "alchemy_material"},
	{"name": "灵药圃", "base_effect": 0, "effect_type": "alchemy_material"},
	{"name": "矿材", "base_effect": 0, "effect_type": "craft_material"},
	{"name": "矿脉", "base_effect": 0, "effect_type": "craft_material"},
	{"name": "陨铁矿", "base_effect": 0, "effect_type": "craft_material"},
	{"name": "属性", "base_effect": 1, "effect_type": "stat_up"},
	{"name": "偶得延寿丹", "base_effect": 2, "effect_type": "shou_yuan"},
	{"name": "伙伴", "base_effect": 0, "effect_type": "companion"},
	{"name": "悬赏令", "base_effect": 0, "effect_type": "quest"},
	{"name": "秘境探索", "base_effect": 1, "effect_type": "adventure"},
]

const JI_YUAN_TYPE_WEIGHTS := {
	"ling_li": 2.2,
	"auction": 0.75,
	"alchemy_material": 1.05,
	"craft_material": 0.95,
	"stat_up": 1.2,
	"shou_yuan": 1.4,
	"technique": 1.45,
	"treasure": 1.05,
	"companion": 0.95,
	"quest": 1.2,
	"adventure": 0.95,
	"heal_percent": 1.1,
	"ling_shi": 1.0,
}

const JI_YUAN_CARD_CHANCE := 0.66
const MIN_CULTIVATION_CARDS_PER_ROUND := 2
const MIN_BUILD_CARDS_PER_ROUND := 1
const MIN_ENEMY_CARDS_PER_ROUND := 1
const MIN_AUCTION_CARDS_PER_ROUND := 1
const AUCTION_STONE_BASE := 400
const BUILD_EFFECT_TYPES := ["technique", "treasure", "companion", "alchemy_material", "craft_material", "adventure"]
const QUEST_EFFECT_TYPES := ["quest"]
const BASE_SHOU_YUAN := 10
const SHOU_YUAN_PER_TI_PO := 2
const MARKET_CULTIVATION_COST := 180
const MARKET_CULTIVATION_GAIN := 18
const MARKET_HEAL_COST := 200
const MARKET_HEAL_PCT := 0.30
const MARKET_BACKPACK_COST := 500
const MARKET_DAN_COSTS := {"筑基丹": 450, "金丹": 1200, "元婴丹": 2400}
const ALCHEMY_COMMON_COST := 180
const ALCHEMY_DAN_COST_RATE := 0.70
const ALCHEMY_HEAL_PCT := 0.18
const ALCHEMY_LING_LI_GAIN := 20
const ALCHEMY_RELATED_STATS := ["气感", "机缘"]
const REFINING_RELATED_STATS := ["体魄", "经商"]
const DUEL_LING_LI_REQ := 3200
const SECT_EVENT_ROUND_INTERVAL := 3
const SECT_EVENT_CHOICE_SECONDS := 10.0
const SECT_EVENT_PRIVATE_DRAW_COUNT := 5
const REALM_COMBAT_POWER_BONUS := [0, 60, 150, 280]
const REALM_DUEL_ADVANTAGE_DAMAGE := 0.22
const REALM_DUEL_SUPPRESSED_DAMAGE := 0.16
const SPARRING_MAX_ACTIONS := 3
const SPARRING_LOW_HP_RATE := 0.35
const MINOR_STAGE_NAMES := ["一层", "二层", "三层", "四层", "五层", "六层", "七层", "八层", "九层"]
const MINOR_BREAKTHROUGH_BASE_CHANCE := 0.70
const MAJOR_BREAKTHROUGH_BASE_CHANCE := 0.56
const BREAKTHROUGH_QI_GAN_CHANCE := 0.025
const BREAKTHROUGH_JI_YUAN_CHANCE := 0.012
const MINOR_BREAKTHROUGH_FAIL_LOSS_RATE := 0.35
const MAJOR_BREAKTHROUGH_FAIL_LOSS_RATE := 0.45
const MINOR_BREAKTHROUGH_FAIL_DAMAGE := 0.05
const MAJOR_BREAKTHROUGH_FAIL_DAMAGE := 0.12
const ESCAPE_BASE_CHANCE := 0.62
const ESCAPE_SHEN_FA_CHANCE := 0.065
const ESCAPE_SPEED_CHANCE := 0.0025
const ESCAPE_ELITE_PENALTY := 0.12
const ESCAPE_FAIL_HURT_MULTIPLIER := 1.25
const BATTLE_ATTACK_DAMAGE_SCALE := 0.16
const BATTLE_DEFENSE_REDUCTION_SCALE := 55.0
const BATTLE_DEFENSE_REDUCTION_CAP := 0.35
const ENEMY_SINGLE_ATTACK_CHANCE := 0.55
const ENEMY_SINGLE_ATTACK_MULTIPLIER := 1.35
const ENEMY_GROUP_ATTACK_MULTIPLIER := 0.82
const ENEMY_GROUP_ATTACK_PACK_BONUS := 0.16
const ENEMY_GROUP_ATTACK_ELITE_BONUS := 0.08
const ENEMY_GROUP_ATTACK_THREAT_BONUS := 0.04
const ENEMY_MIN_SURVIVE_ACTIONS := 2.4
const ENEMY_ELITE_SURVIVE_ACTIONS := 3.2
const ENEMY_ATTACK_HP_PRESSURE := 0.11
const ENEMY_BUILD_PRESSURE_DAMAGE_LOSS := 0.16
const ENEMY_BUILD_PRESSURE_HURT_GAIN := 0.18
const ENEMY_THREAT_DAMAGE_LOSS := 0.08
const ENEMY_THREAT_HURT_GAIN := 0.12
const ENEMY_THREAT_MAX_LEVEL := 4
const MULTI_ENEMY_MIN_REALM_RANK := 1
const MULTI_ENEMY_BASE_CHANCE := 0.18
const MULTI_ENEMY_REALM_CHANCE := 0.10
const MULTI_ENEMY_REWARD_SCALE := 0.55
const BASE_CRIT_CHANCE := 0.05
const CRIT_DAMAGE_MULTIPLIER := 1.5
const BASE_DODGE_CHANCE := 0.03
const DODGE_SHEN_FA_CHANCE := 0.01
const COMPANION_BOND_POSITIVE_MULTIPLIER := 2.0
const COMPANION_BOND_NEGATIVE_MULTIPLIER := 0.5
const TECHNIQUE_BEHAVIOR_GROWTH_MAX_MESSAGES := 2
const SAVE_PATH := "user://dao_save.json"
const IMMORTAL_RECORD_PATH := "user://immortal_records.json"
const AUTO_SAVE_ENABLED := true
const MAX_EQUIPPED_TECHNIQUES := 4
const MAX_EQUIPPED_TREASURES := 1
const MAX_CULTIVATION_SET_COUNT := 5
const MAX_COMPANIONS := 3
const MAX_BACKPACK_TECHNIQUES := 8
const MAX_BACKPACK_TREASURES := 4
const MAX_BACKPACK_COMPANIONS := 6
const MAX_BACKPACK_MATERIALS := 8
const MAX_BACKPACK_CAPACITY := MAX_BACKPACK_TECHNIQUES + MAX_BACKPACK_TREASURES + MAX_BACKPACK_COMPANIONS + MAX_BACKPACK_MATERIALS
const SCATTERED_POOL_REAPPEAR_RATE := 0.5
const MAX_SCATTERED_POOL_SIZE := 60
const COMPANION_BOND_STAGE_REQS := [0, 3, 6, 10]
const COMPANION_PASSIVE_KEYS := ["攻击力", "防御力", "气血上限", "灵力获取", "全属性", "速度", "暴击率", "破防", "战斗减伤", "每轮回血"]
const COMPANION_BONUS_TYPE_MAP := {
	"round_heal": "气血上限",
	"calamity_quality": "防御力",
	"dan_discount": "灵力获取",
	"enemy_opening_damage": "攻击力",
	"treasure_effect_chance": "暴击率",
	"treasure_growth_speed": "灵力获取",
	"tribulation_damage": "防御力",
	"round_ling_shi": "灵力获取",
}
const KARMA_BACKLASH_THRESHOLD := 3
const MAX_KARMIC_DEBT := 12
const MAX_FORBEARANCE := 8
const CALAMITY_CONTEST_MIN_VALUE := 20.0
const CONTEST_POWER_ADVANTAGE_MIN_RATIO := 1.08
const CONTEST_POWER_ADVANTAGE_MIN_DELTA := 6.0
const CONTEST_WEAK_COUNTER_MIN_CHANCE := 0.03
const CONTEST_WEAK_COUNTER_MAX_CHANCE := 0.24
const CONTEST_WEAK_COUNTER_PRESSURE_BONUS := 0.01
const CULTIVATION_TYPES := ["鬼修", "体修", "剑修", "情修", "丹修", "阵修", "符修", "器修"]
const SECT_TYPES := ["万魂殿", "金刚寺", "天剑阁", "百花谷", "丹霞山", "阵宗", "符箓门", "器府"]
const SECTS := ["鬼修", "体修", "剑修", "情修", "丹修", "阵修", "符修", "器修"]

const SECT_STATS := {
	"万魂殿": ["气感", "机缘"],
	"金刚寺": ["体魄", "悟性"],
	"天剑阁": ["身法", "气感"],
	"百花谷": ["魅力", "体魄"],
	"丹霞山": ["体魄", "机缘"],
	"阵宗": ["悟性", "身法"],
	"符箓门": ["身法", "魅力"],
	"器府": ["机缘", "悟性"],
}

const SECT_ALIGNMENT := {
	"万魂殿": "邪",
	"天剑阁": "邪",
	"符箓门": "邪",
	"器府": "邪",
	"金刚寺": "正",
	"百花谷": "正",
	"丹霞山": "正",
	"阵宗": "正",
}

const COMPANION_BOND_RULES := {
	"正": {
		"yield_fortune": 3,
		"bear_tribulation": 5,
		"double_yield": 3,
		"grab_fortune": -2,
		"dodge_tribulation": -1,
	},
	"邪": {
		"grab_fortune": 3,
		"battle_attack": 2,
		"enemy_kill": 5,
		"yield_fortune": -1,
		"bear_tribulation": -1,
	},
}

const SECT_PASSIVE := {
	"万魂殿": {"desc": "抢机缘额外灵力", "formula": "(气感+机缘)×2"},
	"金刚寺": {"desc": "扛天劫伤害减免", "formula": "(体魄+悟性)×1.5%"},
	"天剑阁": {"desc": "抢攻额外伤害", "formula": "(身法+气感)×0.5"},
	"百花谷": {"desc": "让机缘额外灵石", "formula": "(魅力+体魄)×50"},
	"丹霞山": {"desc": "每轮自动回血", "formula": "(体魄+机缘)×0.8%"},
	"阵宗": {"desc": "天劫双扛额外减伤", "formula": "(悟性+身法)×0.8%"},
	"符箓门": {"desc": "周旋额外减伤", "formula": "(身法+魅力)×0.8%"},
	"器府": {"desc": "法宝成长速度加成", "formula": "(机缘+悟性)×2%"},
}

const IDENTITY_LEVELS := [
	{"level": 0, "min": 0.0, "max": 3.0, "name": "散修", "short": "散修", "passive_multiplier": 0.0, "card_bonus": 0.0, "round_stones": 0, "transformation": false},
	{"level": 1, "min": 4.0, "max": 10.0, "name": "外门弟子", "short": "外门", "passive_multiplier": 1.0, "card_bonus": 0.0, "round_stones": 0, "transformation": false},
	{"level": 2, "min": 11.0, "max": 20.0, "name": "内门弟子", "short": "内门", "passive_multiplier": 1.5, "card_bonus": 0.0, "round_stones": 0, "transformation": false},
	{"level": 3, "min": 21.0, "max": 32.0, "name": "亲传弟子", "short": "亲传", "passive_multiplier": 2.0, "card_bonus": 0.05, "round_stones": 0, "transformation": false},
	{"level": 4, "min": 33.0, "max": 50.0, "name": "长老", "short": "长老", "passive_multiplier": 2.5, "card_bonus": 0.10, "round_stones": 200, "transformation": false},
	{"level": 5, "min": 51.0, "max": 9999.0, "name": "宗主", "short": "宗主", "passive_multiplier": 3.0, "card_bonus": 0.15, "round_stones": 200, "transformation": true},
]
const IDENTITY_SPECIAL_BASE_CHANCE := 0.05
const IDENTITY_SPECIAL_MATCH_GRAB_WEIGHT := 3.0
const IDENTITY_SPECIAL_MATCH_YIELD_WEIGHT := 1.4
const IDENTITY_SPECIAL_NONMATCH_GRAB_WEIGHT := 1.0
const IDENTITY_SPECIAL_NONMATCH_YIELD_WEIGHT := 0.35
const WEAK_COMEBACK_TEXT := "以弱胜强！收益翻倍！"

const TREASURE_GROWTH := {
	"鬼修": {"name": "魂魄", "trigger": "抢机缘+1，抢攻击杀+3"},
	"体修": {"name": "淬炼", "trigger": "每受10伤害+1，扛天劫额外+3"},
	"剑修": {"name": "剑意", "trigger": "抢攻+1，突破境界+5"},
	"情修": {"name": "善因", "trigger": "让+1，双让+2，扛+2"},
	"丹修": {"name": "丹气", "trigger": "回血时+1，炼丹+3"},
	"阵修": {"name": "阵纹", "trigger": "扛天劫+2，双扛+3"},
	"符修": {"name": "符印", "trigger": "周旋+1，闪避成功+2"},
	"器修": {"name": "器魂", "trigger": "法宝每涨5层+1，觉醒时+5"},
}
const CULTIVATION_BOND_DATA := {
	"鬼修": {"name": "役鬼临阵", "desc": "2件开局役鬼护身，3件小鬼挡刀会反噬，4件护魂更厚，5件役鬼归一。", "mechanic": "小鬼挡刀并助攻", "bonuses": {"灵力获取": 0.06, "吸血": 0.04}},
	"体修": {"name": "法相金身", "desc": "2件首次受重击显化法相，3件挡伤会反震，4件反震更猛，5件法相归一。", "mechanic": "重伤时法相变大减伤", "bonuses": {"气血上限": 0.08, "战斗减伤": 0.04, "反伤": 0.03}},
	"剑修": {"name": "剑影追斩", "desc": "2件抢攻追加剑影，3件追斩更强，4件有机会万剑再斩，5件剑心归一。", "mechanic": "抢攻连斩", "bonuses": {"攻击力": 0.07, "暴击率": 0.06, "破防": 0.04}},
	"情修": {"name": "红尘护心", "desc": "2件让机缘或承灾凝成护心，3件护心碎裂会回春，4件护心更厚，5件红尘归一。", "mechanic": "让与承劫转护心", "bonuses": {"防御力": 0.05, "灵力获取": 0.05, "每轮回血": 0.02}},
	"丹修": {"name": "九转丹息", "desc": "2件濒危时丹气续命，3件续命后回血，4件丹息储量更高，5件九转归一。", "mechanic": "濒危自动续命", "bonuses": {"气血上限": 0.06, "每轮回血": 0.04, "灵力获取": 0.03}},
	"阵修": {"name": "阵纹控场", "desc": "2件周旋铺阵纹减伤，3件阵纹更硬，4件阵纹绞杀，5件阵心归一。", "mechanic": "周旋布阵减伤", "bonuses": {"防御力": 0.07, "战斗减伤": 0.05}},
	"符修": {"name": "符步闪身", "desc": "2件周旋符步错身，3件闪避更稳，4件符剑回刺，5件符意归一。", "mechanic": "周旋触发闪避", "bonuses": {"闪避率": 0.06, "速度": 0.05}},
	"器修": {"name": "器魂共鸣", "desc": "2件法宝特效反哺成长，3件成长更快，4件有机会额外跳层，5件器魂归一。", "mechanic": "法宝特效带成长", "bonuses": {"攻击力": 0.04, "暴击率": 0.03}, "specials": {"treasure_growth_speed": 0.10, "treasure_effect_chance": 0.05}},
}
const CULTIVATION_BOND_MULTIPLIERS := {
	1: 0.65,
	2: 1.00,
	3: 1.45,
	4: 1.90,
}
const TREASURE_ATTACK_EFFECT_CHANCE := 0.35
const TREASURE_ATTACK_EFFECTS := ["破甲", "吸血", "连击", "暴击加成"]
const TREASURE_GROWTH_ICONS := {
	"鬼修": "魂",
	"体修": "体",
	"剑修": "⚔",
	"情修": "缘",
	"丹修": "丹",
	"阵修": "阵",
	"符修": "符",
	"器修": "器",
}
const TREASURE_AWAKEN_SKILLS := {
	"鬼修": {"name": "魂噬", "desc": "抢攻时追加魂噬，并按伤害少量回血", "damage_scale": 0.35, "heal_rate": 0.08},
	"体修": {"name": "金身震", "desc": "抢攻时以体魄震击追加伤害", "damage_scale": 0.30},
	"剑修": {"name": "剑光二段", "desc": "抢攻时追加一次剑光斩击", "damage_scale": 0.50},
	"情修": {"name": "同心回响", "desc": "抢攻时回血并追加伤害", "damage_scale": 0.25, "heal_rate": 0.10},
	"丹修": {"name": "丹火爆鸣", "desc": "抢攻时丹火爆发追加伤害", "damage_scale": 0.40},
	"阵修": {"name": "阵纹绞杀", "desc": "抢攻时阵纹锁敌追加伤害", "damage_scale": 0.38},
	"符修": {"name": "符印追击", "desc": "抢攻时符印追击追加伤害", "damage_scale": 0.42},
	"器修": {"name": "器魂共鸣", "desc": "抢攻时器魂共鸣追加伤害", "damage_scale": 0.45},
}

const TECHNIQUE_REALM_FRAGMENT_REQ := {"初窥": 3, "小成": 6}
const TECHNIQUE_STAGE_MULTIPLIERS := {"初窥": 0.6, "小成": 1.2, "大成": 2.0}
const TECHNIQUE_DUPLICATE_FRAGMENT_PROGRESS := 3
const TECHNIQUE_MAX_BASE_BONUS_KEYS := 2
const TECHNIQUE_MAX_AFFIX_BONUS_KEYS := 1
const TECHNIQUE_MAX_TOTAL_BONUS_KEYS := 2
const TECHNIQUE_AFFIX_BONUS_SCALE := 0.65
const TECHNIQUE_SPLIT_BONUS_CONVERSION := 0.35
const TECHNIQUE_ALL_ATTRIBUTE_CONVERSION := 2.4

const TECHNIQUE_BONUS_KEYS := [
	"攻击力", "防御力", "气血上限", "灵力获取", "全属性",
	"吸血", "破防", "反伤", "暴击率", "闪避率", "战斗减伤", "每轮回血", "速度",
]

const CULTIVATION_PRIMARY_BONUS_KEYS := {
	"鬼修": "吸血",
	"体修": "气血上限",
	"剑修": "攻击力",
	"情修": "灵力获取",
	"丹修": "每轮回血",
	"阵修": "战斗减伤",
	"符修": "闪避率",
	"器修": "暴击率",
}

const ITEM_AFFIX_POOL := [
	{"name": "淬体", "tag": "体修", "desc": "堆气血上限，体修成型的血肉根基。", "targets": ["technique", "treasure", "companion"], "bonuses": {"气血上限": 0.05}},
	{"name": "护体", "tag": "体修", "desc": "提高防御，适合扛灾、周旋和拖长战斗。", "targets": ["technique", "treasure", "companion"], "bonuses": {"防御力": 0.05}},
	{"name": "反震", "tag": "体修", "desc": "受击时反伤，血厚以后越打越赚。", "targets": ["technique", "treasure", "companion"], "bonuses": {"反伤": 0.03}},
	{"name": "剑意", "tag": "剑修", "desc": "提高攻击，剑修爆发路线的核心词条。", "targets": ["technique", "treasure", "companion"], "bonuses": {"攻击力": 0.05}},
	{"name": "破锋", "tag": "剑修", "desc": "提高破防，专门打高防御对手。", "targets": ["technique", "treasure", "companion"], "bonuses": {"破防": 0.03}},
	{"name": "迅影", "tag": "剑修", "desc": "提高速度，抢先手、逃跑和对决都更强。", "targets": ["technique", "treasure", "companion"], "bonuses": {"速度": 4}},
	{"name": "掠影", "tag": "符修", "desc": "提高闪避率，战斗与对决中更容易避开伤害。", "targets": ["technique", "treasure"], "bonuses": {"闪避率": 0.04}},
	{"name": "魂魄", "tag": "鬼修", "desc": "提高灵力获取，给养鬼和鬼修续航铺路。", "targets": ["technique", "treasure", "companion"], "bonuses": {"灵力获取": 0.04}},
	{"name": "噬血", "tag": "鬼修", "desc": "造成伤害时回血，鬼修越战越黏。", "targets": ["technique", "treasure", "companion"], "bonuses": {"吸血": 0.03}},
	{"name": "阴煞", "tag": "鬼修", "desc": "提高攻击，偏向阴狠爆发和役鬼补刀。", "targets": ["technique", "treasure", "companion"], "bonuses": {"攻击力": 0.04}},
	{"name": "红尘", "tag": "情修", "desc": "提高灵力获取，靠让、救人和羁绊慢慢滚起来。", "targets": ["technique", "treasure", "companion"], "bonuses": {"灵力获取": 0.04}},
	{"name": "同心", "tag": "情修", "desc": "提高防御，适合共担、救人和后期让仙路线。", "targets": ["technique", "treasure", "companion"], "bonuses": {"防御力": 0.04}},
	{"name": "回春", "tag": "情修", "desc": "提高气血上限，配合同伴和回血更稳。", "targets": ["technique", "treasure", "companion"], "bonuses": {"气血上限": 0.04}},
]

const CALAMITY_TYPES := {
	"炼气级": {"name": "灵力流失", "base_effect": 15, "effect_type": "ling_li_loss"},
	"筑基级": {"name": "灵力流失", "base_effect": 30, "effect_type": "ling_li_loss"},
	"金丹级": {"name": "气血损伤", "base_effect": 18, "effect_type": "hp_percent_loss"},
	"元婴级": {"name": "寿元折损", "base_effect": 2, "effect_type": "shou_yuan_loss"},
	"化神级": {"name": "寿元折损", "base_effect": 2, "effect_type": "shou_yuan_loss"},
	"合体级": {"name": "古妖拦路", "base_effect": 0, "effect_type": "enemy"},
}

const BASE_STATS := ["体魄", "气感", "经商", "身法", "魅力", "机缘"]

const REALMS := {
	"炼气期": {"ling_li_req": 0, "attack_bonus": 0.0, "defense_bonus": 0.0, "hp_bonus": 0.0, "speed_base": 10, "dan": ""},
	"筑基期": {"ling_li_req": 180, "attack_bonus": 0.45, "defense_bonus": 0.40, "hp_bonus": 0.45, "speed_base": 24, "dan": "筑基丹"},
	"金丹期": {"ling_li_req": 760, "attack_bonus": 1.10, "defense_bonus": 0.90, "hp_bonus": 1.00, "speed_base": 42, "dan": "金丹"},
	"元婴期": {"ling_li_req": 1800, "attack_bonus": 2.00, "defense_bonus": 1.60, "hp_bonus": 1.80, "speed_base": 64, "dan": "元婴丹"},
}

const TRIBULATIONS := {
	"筑基期": {"name": "筑基雷劫", "damage_pct": 0.22, "shared_pct": 0.08, "dodge_reward": 20},
	"金丹期": {"name": "金丹火劫", "damage_pct": 0.31, "shared_pct": 0.12, "dodge_reward": 40},
	"元婴期": {"name": "元婴心魔劫", "damage_pct": 0.40, "shared_pct": 0.16, "dodge_reward": 70},
}

const ENEMIES := {
	"炼气级": {"hp": 52, "attack": 6, "drop_desc": "灵石/灵力/材料"},
	"筑基级": {"hp": 78, "attack": 10, "drop_desc": "灵石/灵力/材料"},
	"金丹级": {"hp": 124, "attack": 15, "drop_desc": "灵石/灵力/材料"},
	"元婴级": {"hp": 190, "attack": 21, "drop_desc": "功法/法宝/材料"},
	"化神级": {"hp": 290, "attack": 29, "drop_desc": "功法/法宝/材料"},
	"合体级": {"hp": 430, "attack": 40, "drop_desc": "功法/法宝/材料"},
}

const BOUNTY_TASK_POOL := [
	{"id": "beast_core", "name": "抢夺妖兽灵核", "trigger": "enemy_kill", "desc": "击杀妖兽时额外获得灵石+500", "reward_ling_shi": 500},
	{"id": "spirit_herb", "name": "收集灵草", "trigger": "heal_gain", "desc": "获得治疗机缘时额外回复20%气血", "bonus_heal_pct": 0.20},
	{"id": "duel_trial", "name": "比试切磋", "trigger": "duel_win", "desc": "最终对决获胜后额外获得灵石+1000", "reward_ling_shi": 1000},
]

const TECHNIQUE_POOL := [
	{"name": "引气诀", "quality": "炼气级", "bonuses": {"灵力获取": 0.04}},
	{"name": "粗浅拳脚", "quality": "炼气级", "bonuses": {"气血上限": 0.05}},
	{"name": "基础剑诀", "quality": "炼气级", "bonuses": {"攻击力": 0.04}},
	{"name": "养魂小术", "quality": "炼气级", "bonuses": {"吸血": 0.02}},
	{"name": "红尘小令", "quality": "炼气级", "bonuses": {"防御力": 0.03, "灵力获取": 0.03}},
	{"name": "吐纳术", "quality": "筑基级", "bonuses": {"灵力获取": 0.10}},
	{"name": "淬体诀", "quality": "筑基级", "bonuses": {"气血上限": 0.15}},
	{"name": "铁骨功", "quality": "筑基级", "bonuses": {"气血上限": 0.10, "防御力": 0.08}},
	{"name": "御剑诀", "quality": "筑基级", "bonuses": {"攻击力": 0.08, "速度": 5}},
	{"name": "养魂术", "quality": "筑基级", "bonuses": {"灵力获取": 0.08, "吸血": 0.03}},
	{"name": "铜皮铁骨", "quality": "筑基级", "bonuses": {"防御力": 0.10, "战斗减伤": 0.03}},
	{"name": "藏剑式", "quality": "筑基级", "bonuses": {"攻击力": 0.06, "暴击率": 0.04}},
	{"name": "招魂幡术", "quality": "筑基级", "bonuses": {"灵力获取": 0.06, "吸血": 0.04}},
	{"name": "磐石桩", "quality": "筑基级", "bonuses": {"气血上限": 0.12, "战斗减伤": 0.03}},
	{"name": "熊罴劲", "quality": "筑基级", "bonuses": {"攻击力": 0.06, "气血上限": 0.10}},
	{"name": "养剑诀", "quality": "筑基级", "bonuses": {"攻击力": 0.07, "速度": 4}},
	{"name": "剑气初鸣", "quality": "筑基级", "bonuses": {"暴击率": 0.04, "速度": 5}},
	{"name": "引魂灯诀", "quality": "筑基级", "bonuses": {"吸血": 0.04, "灵力获取": 0.06}},
	{"name": "养鬼袋法", "quality": "筑基级", "bonuses": {"吸血": 0.05, "气血上限": 0.08}},
	{"name": "合欢心法", "quality": "筑基级", "bonuses": {"灵力获取": 0.06, "速度": 4}},
	{"name": "红尘引", "quality": "筑基级", "bonuses": {"防御力": 0.06, "气血上限": 0.08}},
	{"name": "同心诀", "quality": "筑基级", "bonuses": {"灵力获取": 0.08, "战斗减伤": 0.02}},
	{"name": "太虚步", "quality": "金丹级", "bonuses": {"攻击力": 0.10, "防御力": 0.10, "速度": 10}},
	{"name": "回春诀", "quality": "金丹级", "bonuses": {"每轮回血": 0.05}},
	{"name": "蛮牛劲", "quality": "金丹级", "bonuses": {"气血上限": 0.18, "战斗减伤": 0.06}},
	{"name": "青莲剑典", "quality": "金丹级", "bonuses": {"攻击力": 0.15, "暴击率": 0.06}},
	{"name": "阴魂咒", "quality": "金丹级", "bonuses": {"攻击力": 0.10, "吸血": 0.06}},
	{"name": "搬山劲", "quality": "金丹级", "bonuses": {"攻击力": 0.10, "气血上限": 0.16}},
	{"name": "惊鸿剑步", "quality": "金丹级", "bonuses": {"速度": 12, "暴击率": 0.05}},
	{"name": "尸阴经", "quality": "金丹级", "bonuses": {"气血上限": 0.14, "吸血": 0.06}},
	{"name": "铁衣横练", "quality": "金丹级", "bonuses": {"防御力": 0.16, "战斗减伤": 0.07}},
	{"name": "血炉呼吸", "quality": "金丹级", "bonuses": {"气血上限": 0.20, "每轮回血": 0.04}},
	{"name": "追风剑诀", "quality": "金丹级", "bonuses": {"速度": 16, "攻击力": 0.10}},
	{"name": "剑影分光", "quality": "金丹级", "bonuses": {"暴击率": 0.07, "破防": 0.05}},
	{"name": "魂契秘卷", "quality": "金丹级", "bonuses": {"攻击力": 0.08, "吸血": 0.08}},
	{"name": "阴兵借道", "quality": "金丹级", "bonuses": {"速度": 8, "吸血": 0.07}},
	{"name": "桃花障", "quality": "金丹级", "bonuses": {"防御力": 0.12, "战斗减伤": 0.05}},
	{"name": "牵丝步", "quality": "金丹级", "bonuses": {"速度": 14, "灵力获取": 0.08}},
	{"name": "鸳盟术", "quality": "金丹级", "bonuses": {"气血上限": 0.14, "每轮回血": 0.04}},
	{"name": "诛仙剑气", "quality": "元婴级", "bonuses": {"攻击力": 0.20}},
	{"name": "金刚不坏", "quality": "元婴级", "bonuses": {"防御力": 0.30}},
	{"name": "吸星大法", "quality": "元婴级", "bonuses": {"攻击力": 0.15, "对方防御": -0.10}},
	{"name": "血河炼体", "quality": "元婴级", "bonuses": {"气血上限": 0.28, "防御力": 0.16, "反伤": 0.08}},
	{"name": "剑心通明", "quality": "元婴级", "bonuses": {"攻击力": 0.24, "速度": 8, "暴击率": 0.08}},
	{"name": "百鬼夜行", "quality": "元婴级", "bonuses": {"攻击力": 0.18, "气血上限": 0.12, "吸血": 0.08}},
	{"name": "玄龟息", "quality": "元婴级", "bonuses": {"防御力": 0.22, "气血上限": 0.22, "反伤": 0.06}},
	{"name": "无回剑意", "quality": "元婴级", "bonuses": {"攻击力": 0.28, "破防": 0.08}},
	{"name": "鬼门借道", "quality": "元婴级", "bonuses": {"速度": 10, "吸血": 0.10, "破防": 0.06}},
	{"name": "山河霸体", "quality": "元婴级", "bonuses": {"气血上限": 0.30, "防御力": 0.18, "反伤": 0.10}},
	{"name": "玄甲真诀", "quality": "元婴级", "bonuses": {"防御力": 0.26, "战斗减伤": 0.09}},
	{"name": "七杀剑经", "quality": "元婴级", "bonuses": {"攻击力": 0.24, "暴击率": 0.10}},
	{"name": "剑骨铮鸣", "quality": "元婴级", "bonuses": {"速度": 14, "破防": 0.09}},
	{"name": "血祭鬼书", "quality": "元婴级", "bonuses": {"攻击力": 0.14, "吸血": 0.12}},
	{"name": "魂幡万转", "quality": "元婴级", "bonuses": {"气血上限": 0.16, "吸血": 0.12, "破防": 0.05}},
	{"name": "合欢秘典", "quality": "元婴级", "bonuses": {"攻击力": 0.14, "灵力获取": 0.12, "速度": 8}},
	{"name": "红尘劫火", "quality": "元婴级", "bonuses": {"攻击力": 0.16, "气血上限": 0.14}},
	{"name": "情丝缠心", "quality": "元婴级", "bonuses": {"防御力": 0.16, "速度": 10}},
	{"name": "雷霆万钧", "quality": "化神级", "bonuses": {"攻击力": 0.30}},
	{"name": "天罡正气", "quality": "化神级", "bonuses": {"气血上限": 0.25}},
	{"name": "万魂幡", "quality": "化神级", "bonuses": {"攻击力": 0.15, "气血上限": 0.15}},
	{"name": "不灭金身", "quality": "化神级", "bonuses": {"气血上限": 0.42, "防御力": 0.24, "反伤": 0.12}},
	{"name": "剑开天门", "quality": "化神级", "bonuses": {"攻击力": 0.40, "速度": 15, "破防": 0.12}},
	{"name": "黄泉引", "quality": "化神级", "bonuses": {"攻击力": 0.25, "灵力获取": 0.18, "吸血": 0.12}},
	{"name": "吞岳真身", "quality": "化神级", "bonuses": {"气血上限": 0.36, "战斗减伤": 0.10}},
	{"name": "天外飞剑", "quality": "化神级", "bonuses": {"攻击力": 0.34, "速度": 12, "暴击率": 0.12}},
	{"name": "十殿阴司录", "quality": "化神级", "bonuses": {"攻击力": 0.22, "气血上限": 0.18, "吸血": 0.14}},
	{"name": "金身不漏", "quality": "化神级", "bonuses": {"气血上限": 0.38, "防御力": 0.22, "战斗减伤": 0.10}},
	{"name": "万剑归宗", "quality": "化神级", "bonuses": {"攻击力": 0.36, "暴击率": 0.13, "破防": 0.08}},
	{"name": "阎罗敕令", "quality": "化神级", "bonuses": {"攻击力": 0.24, "吸血": 0.15, "破防": 0.08}},
	{"name": "三生契", "quality": "化神级", "bonuses": {"气血上限": 0.22, "灵力获取": 0.20, "战斗减伤": 0.07}},
	{"name": "欲海生莲", "quality": "化神级", "bonuses": {"攻击力": 0.26, "防御力": 0.18, "速度": 12}},
	{"name": "九转玄功", "quality": "合体级", "bonuses": {"全属性": 0.10}},
	{"name": "混元不灭体", "quality": "合体级", "bonuses": {"气血上限": 0.50, "防御力": 0.36, "反伤": 0.16}},
	{"name": "太上剑胎", "quality": "合体级", "bonuses": {"攻击力": 0.52, "速度": 24, "暴击率": 0.15}},
	{"name": "冥河真经", "quality": "合体级", "bonuses": {"攻击力": 0.36, "气血上限": 0.24, "吸血": 0.16}},
	{"name": "力破万法", "quality": "合体级", "bonuses": {"气血上限": 0.46, "防御力": 0.28, "反伤": 0.18}},
	{"name": "一剑飞升", "quality": "合体级", "bonuses": {"攻击力": 0.48, "暴击率": 0.18, "破防": 0.14}},
	{"name": "百鬼成城", "quality": "合体级", "bonuses": {"攻击力": 0.32, "气血上限": 0.26, "吸血": 0.18}},
	{"name": "红尘成仙", "quality": "合体级", "bonuses": {"攻击力": 0.30, "防御力": 0.24, "灵力获取": 0.24, "速度": 16}},
	{"name": "云游手札", "quality": "金丹级", "bonuses": {"灵力获取": 0.15}},
]

const TREASURE_POOL := [
	{"name": "旧皮甲", "quality": "炼气级", "school": "体修", "attack_name": "贴身硬撞", "battle_damage": 1, "duel_damage": 3, "battle_hurt_reduction": 0.04, "passive_bonus": {"气血上限": 0.04}, "use_effect": "入门护身法宝，略减伤"},
	{"name": "铁木剑", "quality": "炼气级", "school": "剑修", "attack_name": "铁木斩", "battle_damage": 1, "duel_damage": 3, "passive_bonus": {"攻击力": 0.04}, "use_effect": "入门飞剑，稳定补伤害"},
	{"name": "阴魂铃", "quality": "炼气级", "school": "鬼修", "attack_name": "铃音摄魂", "battle_damage": 1, "duel_damage": 3, "lifesteal": 0.03, "passive_bonus": {"灵力获取": 0.04}, "use_effect": "入门鬼器，伤敌时略吸血"},
	{"name": "同心结", "quality": "炼气级", "school": "情修", "attack_name": "红线牵扯", "battle_damage": 1, "duel_damage": 3, "battle_hurt_reduction": 0.03, "passive_bonus": {"防御力": 0.03}, "use_effect": "入门情修法宝，偏向保命"},
	{"name": "护体金钟", "quality": "金丹级", "school": "体修", "attack_name": "金钟震击", "battle_damage": 2, "duel_damage": 6, "battle_hurt_reduction": 0.10, "passive_bonus": {"防御力": 0.08}, "use_effect": "装备后以金钟震击敌人，受伤-10%"},
	{"name": "镇岳印", "quality": "元婴级", "school": "体修", "attack_name": "镇岳压顶", "battle_damage": 3, "duel_damage": 10, "battle_hurt_reduction": 0.12, "passive_bonus": {"气血上限": 0.12, "防御力": 0.10}, "use_effect": "装备后以镇岳印砸敌，兼具护体"},
	{"name": "血纹盾", "quality": "元婴级", "school": "体修", "attack_name": "血盾反冲", "battle_damage": 2, "duel_damage": 8, "reflect": 0.10, "passive_bonus": {"气血上限": 0.16}, "use_effect": "装备后反弹部分伤害"},
	{"name": "不动明王钟", "quality": "化神级", "school": "体修", "attack_name": "明王钟鸣", "battle_damage": 4, "duel_damage": 14, "battle_hurt_reduction": 0.18, "reflect": 0.12, "passive_bonus": {"防御力": 0.16, "气血上限": 0.16}, "use_effect": "装备后攻防一体，越打越稳"},
	{"name": "青锋剑", "quality": "筑基级", "school": "剑修", "attack_name": "青锋斩", "battle_damage": 2, "duel_damage": 5, "passive_bonus": {"攻击力": 0.06}, "use_effect": "装备后用飞剑攻击"},
	{"name": "破甲锥", "quality": "金丹级", "school": "剑修", "attack_name": "破甲穿刺", "battle_damage": 3, "duel_damage": 8, "ignore_defense": 0.12, "passive_bonus": {"攻击力": 0.08}, "use_effect": "装备后攻击会削弱防御"},
	{"name": "飞剑匣", "quality": "元婴级", "school": "剑修", "attack_name": "剑匣齐鸣", "battle_damage": 4, "duel_damage": 12, "crit_chance": 0.08, "passive_bonus": {"攻击力": 0.12, "速度": 8}, "use_effect": "装备后飞剑连发，暴击提高"},
	{"name": "斩仙葫芦", "quality": "化神级", "school": "剑修", "attack_name": "斩仙飞刃", "battle_damage": 5, "duel_damage": 18, "ignore_defense": 0.18, "crit_chance": 0.10, "passive_bonus": {"攻击力": 0.18, "速度": 12}, "use_effect": "装备后飞刃破防，爆发极高"},
	{"name": "摄魂铃", "quality": "筑基级", "school": "鬼修", "attack_name": "摄魂铃音", "battle_damage": 1, "duel_damage": 5, "lifesteal": 0.06, "passive_bonus": {"灵力获取": 0.06}, "use_effect": "装备后伤敌并吸取气血"},
	{"name": "白骨幡", "quality": "金丹级", "school": "鬼修", "attack_name": "白骨阴风", "battle_damage": 3, "duel_damage": 9, "lifesteal": 0.08, "passive_bonus": {"攻击力": 0.08, "气血上限": 0.06}, "use_effect": "装备后阴风伤敌，附带吸血"},
	{"name": "万魂幡", "quality": "元婴级", "school": "鬼修", "attack_name": "万魂噬心", "battle_damage": 4, "duel_damage": 13, "lifesteal": 0.12, "passive_bonus": {"攻击力": 0.12, "气血上限": 0.12}, "use_effect": "装备后万魂噬心，越战越凶"},
	{"name": "黄泉灯", "quality": "化神级", "school": "鬼修", "attack_name": "黄泉引路", "battle_damage": 5, "duel_damage": 16, "lifesteal": 0.15, "ignore_defense": 0.08, "passive_bonus": {"攻击力": 0.14, "灵力获取": 0.12}, "use_effect": "装备后黄泉灯引魂，伤害和吸血兼备"},
	{"name": "红尘绫", "quality": "金丹级", "school": "情修", "attack_name": "红绫缠心", "battle_damage": 2, "duel_damage": 7, "battle_hurt_reduction": 0.06, "passive_bonus": {"防御力": 0.06, "灵力获取": 0.08}, "use_effect": "装备后以红绫牵制敌人，适合情修拖局"},
	{"name": "同心佩", "quality": "元婴级", "school": "情修", "attack_name": "同心回响", "battle_damage": 2, "duel_damage": 9, "battle_hurt_reduction": 0.10, "passive_bonus": {"气血上限": 0.12, "速度": 8}, "use_effect": "装备后共担更稳，救人后更能续命"},
	{"name": "合欢铃", "quality": "化神级", "school": "情修", "attack_name": "铃音乱神", "battle_damage": 4, "duel_damage": 15, "crit_chance": 0.06, "battle_hurt_reduction": 0.08, "passive_bonus": {"攻击力": 0.14, "灵力获取": 0.14}, "use_effect": "装备后以铃音扰心，攻守都吃魅力路线"},
	{"name": "聚灵幡", "quality": "金丹级", "school": "散修", "attack_name": "聚灵冲击", "battle_damage": 2, "duel_damage": 6, "passive_bonus": {"灵力获取": 0.16}, "use_effect": "装备后聚灵成刃，修行更快"},
	{"name": "定魂钟", "quality": "元婴级", "school": "散修", "attack_name": "定魂钟波", "battle_damage": 2, "duel_damage": 8, "battle_hurt_reduction": 0.08, "passive_bonus": {"气血上限": 0.12}, "use_effect": "装备后稳住魂魄，天劫更稳"},
	{"name": "飞仙羽", "quality": "元婴级", "school": "散修", "attack_name": "飞羽切风", "battle_damage": 3, "duel_damage": 9, "passive_bonus": {"速度": 18}, "use_effect": "装备后身法大增，逃跑更稳"},
]

const COMPANION_POOL := [
	{"name": "沈霜雁", "title": "散修药师", "quality": "金丹级", "bonus_type": "气血上限", "bonus_value": 0.05, "effect_desc": "气血上限+5%"},
	{"name": "铁无涯", "title": "铸器学徒", "quality": "金丹级", "bonus_type": "灵力获取", "bonus_value": 0.05, "effect_desc": "灵力获取+5%"},
	{"name": "柳青荇", "title": "灵田看守", "quality": "金丹级", "bonus_type": "灵力获取", "bonus_value": 0.08, "effect_desc": "灵力获取+8%"},
	{"name": "燕小七", "title": "消息贩子", "quality": "金丹级", "bonus_type": "防御力", "bonus_value": 0.05, "effect_desc": "防御力+5%"},
	{"name": "楚星河", "title": "剑宗弃徒", "quality": "元婴级", "bonus_type": "攻击力", "bonus_value": 0.12, "effect_desc": "战斗攻击+12%"},
	{"name": "温如玉", "title": "丹鼎阁外门", "quality": "元婴级", "bonus_type": "灵力获取", "bonus_value": 0.12, "effect_desc": "灵力获取+12%"},
	{"name": "霍千山", "title": "御兽宗传人", "quality": "元婴级", "bonus_type": "攻击力", "bonus_value": 0.08, "effect_desc": "攻击力+8%"},
	{"name": "云秋水", "title": "符箓世家", "quality": "元婴级", "bonus_type": "暴击率", "bonus_value": 0.08, "effect_desc": "暴击率+8%"},
	{"name": "殷破军", "title": "征北将军", "quality": "化神级", "bonus_type": "攻击力", "bonus_value": 0.15, "effect_desc": "攻击力+15%"},
	{"name": "洛清商", "title": "天机阁护法", "quality": "化神级", "bonus_type": "速度", "bonus_value": 15.0, "effect_desc": "速度+15"},
	{"name": "花弄影", "title": "百花谷主", "quality": "化神级", "bonus_type": "气血上限", "bonus_value": 0.08, "effect_desc": "气血上限+8%"},
	{"name": "司徒墨", "title": "商会会长", "quality": "化神级", "bonus_type": "灵力获取", "bonus_value": 0.10, "effect_desc": "灵力获取+10%"},
	{"name": "顾长生", "title": "守墓人", "quality": "合体级", "bonus_type": "防御力", "bonus_value": 0.15, "effect_desc": "防御力+15%"},
	{"name": "叶倾仙", "title": "半步飞升", "quality": "合体级", "bonus_type": "全属性", "bonus_value": 0.08, "effect_desc": "全属性+8%"},
	{"name": "韩铁衣", "title": "铁骨武夫", "quality": "金丹级", "school": "体修", "bonus_type": "防御力", "bonus_value": 0.10, "effect_desc": "体修防御+10%"},
	{"name": "莫问剑", "title": "剑冢守人", "quality": "元婴级", "school": "剑修", "bonus_type": "攻击力", "bonus_value": 0.14, "effect_desc": "剑修攻击+14%"},
	{"name": "孟无魂", "title": "招魂道人", "quality": "元婴级", "school": "鬼修", "bonus_type": "灵力获取", "bonus_value": 0.12, "effect_desc": "鬼修灵力获取+12%"},
	{"name": "苏照影", "title": "合欢宗行走", "quality": "金丹级", "school": "情修", "bonus_type": "灵力获取", "bonus_value": 0.10, "effect_desc": "情修灵力获取+10%"},
	{"name": "秦无双", "title": "红尘客", "quality": "元婴级", "school": "情修", "bonus_type": "速度", "bonus_value": 12.0, "effect_desc": "情修速度+12"},
	{"name": "谢忘忧", "title": "三生契主", "quality": "化神级", "school": "情修", "bonus_type": "气血上限", "bonus_value": 0.16, "effect_desc": "情修气血上限+16%"},
]

const COMPANION_LAST_WORDS := {
	"沈霜雁": "跟了你一路，本以为你能飞升。罢了，丹炉已凉，我随你去。",
	"楚星河": "当年在宗门被逐，无人信我。只有你将我招入麾下。剑已断，不悔。",
	"花弄影": "我替你挡了一次陨落。可惜，挡不了第二次。",
	"顾长生": "守了一辈子的墓，最后要守的是你的。",
	"叶倾仙": "只差半步……你只差半步就能飞升。我这一生，又看走眼了。",
	"铁无涯": "你养成的每一件法宝，都有我的火印。",
	"柳青荇": "灵田里的草还没收呢……算了。",
	"燕小七": "消息是卖给你了，可你没能用到最后。",
	"温如玉": "那炉丹，终究没等到出炉。",
	"霍千山": "我的灵兽还在等你……",
	"云秋水": "符纸还没用完，你就……",
	"殷破军": "将军百战死，仙路亦战场。",
	"洛清商": "天机已尽，我看到了你的结局……也看到了自己的。",
	"司徒墨": "商会可以不要，但你不能死啊。",
	"韩铁衣": "我这一身铁骨，本想替你挡到最后。",
	"莫问剑": "剑冢有万剑，偏偏我只信你这一剑。",
	"孟无魂": "魂幡已冷，若有来世，别再走这条阴路。",
	"苏照影": "红尘一场，我本以为你会回头看我一眼。",
	"秦无双": "你说仙路无情，我偏不信。可现在，我信了。",
	"谢忘忧": "三生契还在，签契的人却不在了。",
}

const NEXT_REALM_MAP := {
	"炼气期": "筑基期",
	"筑基期": "金丹期",
	"金丹期": "元婴期",
}

const SECT_BUILD_DATA := {
	"鬼修": {
		"growth_name": "魂魄",
		"growth_icon": "魂",
		"growth_max": 10,
		"resonance": "噬魂",
		"transformation": "万魂之主",
		"complete": "万魂之主·飞升",
		"skill_2": "噬魂：抢夺养魂，抢攻吸血",
		"skill_4": "万魂之主：法宝觉醒，对决蚀血",
		"skill_6": "万魂飞升：首回合压血，抢时魂魄暴涨",
		"bonus_2": {"灵力获取": 0.08, "吸血": 0.10},
		"bonus_4": {"攻击力": 0.14, "对方每回合气血流失": 0.05, "双抢反噬": 0.10},
		"bonus_6": {"攻击力": 0.24, "首回合气血压制": 0.10, "抢成长": 2, "善因获取": -0.50},
		"techniques": [
			{"name": "万魂归宗", "quality": "元婴级", "bonuses": {"攻击力": 0.16, "灵力获取": 0.14, "吸血": 0.08}},
			{"name": "鬼影步", "quality": "金丹级", "bonuses": {"速度": 14, "闪避": 0.05}},
			{"name": "噬魂爪", "quality": "元婴级", "bonuses": {"攻击力": 0.22, "吸血": 0.10}},
			{"name": "魂甲术", "quality": "金丹级", "bonuses": {"防御力": 0.14, "气血上限": 0.10}},
		],
		"treasures": [
			{"name": "万魂幡", "quality": "化神级", "attack_name": "万魂噬身", "battle_damage": 4, "duel_damage": 16, "passive_bonus": {"攻击力": 0.16, "吸血": 0.08}, "use_effect": "魂魄越多，万魂幡越凶。"},
			{"name": "噬骨钉", "quality": "元婴级", "attack_name": "噬骨破甲", "battle_damage": 3, "duel_damage": 11, "ignore_defense": 0.12, "passive_bonus": {"攻击力": 0.12, "破防": 0.08}, "use_effect": "魂魄强化破甲。"},
			{"name": "血煞珠", "quality": "元婴级", "attack_name": "血煞爆裂", "battle_damage": 3, "duel_damage": 10, "passive_bonus": {"气血上限": 0.14, "吸血": 0.06}, "use_effect": "魂魄转为血煞护身。"},
		],
		"companions": ["霍千山", "云秋水"],
	},
	"体修": {
		"growth_name": "淬炼",
		"growth_icon": "体",
		"growth_max": 50,
		"resonance": "淬体",
		"transformation": "不灭金身",
		"complete": "不灭金身·飞升",
		"skill_2": "淬体：扛伤回血，受伤炼体",
		"skill_4": "不灭金身：半血自愈，法宝觉醒",
		"skill_6": "金身飞升：残血免伤，扛时淬炼暴涨",
		"bonus_2": {"气血回复": 0.20, "战斗减伤": 0.06},
		"bonus_4": {"气血上限": 0.22, "防御力": 0.18, "速度": -30.0},
		"bonus_6": {"气血上限": 0.34, "防御力": 0.28, "金身免伤": 1.0, "剑意获取": -0.50},
		"techniques": [
			{"name": "不灭真经", "quality": "化神级", "bonuses": {"气血上限": 0.30, "防御力": 0.18}},
			{"name": "磐石步", "quality": "金丹级", "bonuses": {"速度": 8, "战斗减伤": 0.06}},
			{"name": "崩山拳", "quality": "元婴级", "bonuses": {"攻击力": 0.20, "气血上限": 0.12}},
			{"name": "金钟罩", "quality": "化神级", "bonuses": {"防御力": 0.30, "气血上限": 0.20, "反伤": 0.08}},
		],
		"treasures": [
			{"name": "不灭金身", "quality": "化神级", "attack_name": "金身镇压", "battle_damage": 4, "duel_damage": 14, "battle_hurt_reduction": 0.16, "passive_bonus": {"防御力": 0.18, "气血上限": 0.18}, "use_effect": "淬炼越高，金身越硬。"},
			{"name": "玄龟甲", "quality": "元婴级", "attack_name": "玄龟反震", "battle_damage": 2, "duel_damage": 8, "reflect": 0.14, "passive_bonus": {"防御力": 0.16}, "use_effect": "淬炼强化反弹。"},
			{"name": "金刚镯", "quality": "元婴级", "attack_name": "金刚轰击", "battle_damage": 3, "duel_damage": 10, "passive_bonus": {"气血上限": 0.18, "攻击力": 0.08}, "use_effect": "淬炼转化为气血。"},
		],
		"companions": ["铁无涯", "顾长生"],
	},
	"剑修": {
		"growth_name": "剑意",
		"growth_icon": "剑",
		"growth_max": 15,
		"resonance": "剑意",
		"transformation": "剑心通明",
		"complete": "剑心通明·飞升",
		"skill_2": "剑意：抢攻暴击，突破养剑",
		"skill_4": "剑心通明：暴击质变，法宝觉醒",
		"skill_6": "剑心飞升：首击斩血，抢攻剑意暴涨",
		"bonus_2": {"暴击率": 0.10, "攻击力": 0.08},
		"bonus_4": {"攻击力": 0.20, "暴击伤害": 1.00, "气血上限": -0.20},
		"bonus_6": {"攻击力": 0.32, "首击当前气血": 0.15, "抢攻成长": 2, "淬炼获取": -0.50},
		"techniques": [
			{"name": "剑心通明", "quality": "化神级", "bonuses": {"攻击力": 0.24, "暴击率": 0.08}},
			{"name": "御剑术", "quality": "元婴级", "bonuses": {"速度": 20, "攻击力": 0.10}},
			{"name": "诛仙剑气", "quality": "化神级", "bonuses": {"攻击力": 0.34, "破防": 0.10}},
			{"name": "剑气护体", "quality": "金丹级", "bonuses": {"防御力": 0.12, "速度": 8}},
		],
		"treasures": [
			{"name": "诛仙剑", "quality": "化神级", "attack_name": "诛仙剑斩", "battle_damage": 5, "duel_damage": 18, "crit_chance": 0.10, "passive_bonus": {"攻击力": 0.20}, "use_effect": "剑意越高，斩击越凶。"},
			{"name": "青霜剑", "quality": "元婴级", "attack_name": "青霜快剑", "battle_damage": 4, "duel_damage": 13, "passive_bonus": {"速度": 16, "攻击力": 0.12}, "use_effect": "剑意强化速度。"},
			{"name": "碎星剑", "quality": "元婴级", "attack_name": "碎星破甲", "battle_damage": 4, "duel_damage": 12, "ignore_defense": 0.16, "passive_bonus": {"破防": 0.12, "攻击力": 0.10}, "use_effect": "剑意强化破甲。"},
		],
		"companions": ["楚星河", "洛清商"],
	},
	"情修": {
		"growth_name": "善因",
		"growth_icon": "缘",
		"growth_max": 20,
		"resonance": "善缘",
		"transformation": "红尘仙",
		"complete": "红尘仙·飞升",
		"skill_2": "善缘：让与扛增加善因，羁绊更快",
		"skill_4": "红尘仙：羁绊身份分提升，法宝觉醒",
		"skill_6": "红尘飞升：每回合回血，让时善因暴涨",
		"bonus_2": {"伙伴羁绊获取": 0.30, "灵力获取": 0.08},
		"bonus_4": {"防御力": 0.16, "气血上限": 0.18, "攻击力": -0.15},
		"bonus_6": {"每回合回血": 0.05, "让成长": 2, "魂魄获取": -0.50, "全属性": 0.06},
		"techniques": [
			{"name": "红尘炼心", "quality": "化神级", "bonuses": {"灵力获取": 0.18, "气血上限": 0.16}},
			{"name": "云水谣", "quality": "金丹级", "bonuses": {"速度": 14, "闪避": 0.06}},
			{"name": "断肠剑", "quality": "元婴级", "bonuses": {"攻击力": 0.18, "吸血": 0.06}},
			{"name": "情天恨海", "quality": "化神级", "bonuses": {"防御力": 0.22, "气血上限": 0.20}},
		],
		"treasures": [
			{"name": "同心锁", "quality": "化神级", "attack_name": "同心锁缚", "battle_damage": 3, "duel_damage": 12, "passive_bonus": {"防御力": 0.16, "气血上限": 0.16}, "use_effect": "善因越多，护心越稳。"},
			{"name": "护花铃", "quality": "元婴级", "attack_name": "护花铃音", "battle_damage": 2, "duel_damage": 9, "passive_bonus": {"灵力获取": 0.12, "速度": 8}, "use_effect": "善因强化伙伴羁绊。"},
			{"name": "续命灯", "quality": "化神级", "attack_name": "续命灯火", "battle_damage": 2, "duel_damage": 10, "passive_bonus": {"气血上限": 0.20, "每轮回血": 0.05}, "use_effect": "善因越多，越难陨落。"},
		],
		"companions": ["花弄影", "沈霜雁"],
	},
}

const NPC_PROFILES := [
	{
		"id": "lu_qingya",
		"name": "陆青崖",
		"route": "剑修",
		"temper": "bold",
		"intro": "剑宗旧友，爱争，也会护你一剑。",
		"meet": "山风正好，我陪你走这一程。若遇机缘，各凭本事。",
	},
	{
		"id": "shen_shuangyan",
		"name": "沈霜雁",
		"route": "体修",
		"temper": "kind",
		"intro": "散修药师，稳重护短，常会替你挡劫。",
		"meet": "丹炉先寄在你这儿。你别急着死，我也不急着飞升。",
	},
	{
		"id": "meng_wuhun",
		"name": "孟无魂",
		"route": "鬼修",
		"temper": "greedy",
		"intro": "招魂道人，贪机缘，也怕硬仗。",
		"meet": "同行可以，机缘可不能全让你拿。生死账，咱们慢慢算。",
	},
	{
		"id": "su_zhaoying",
		"name": "苏照影",
		"route": "情修",
		"temper": "soft",
		"intro": "合欢宗外门，擅长共担与反转。",
		"meet": "修行未必只靠争。你若肯让一步，我便陪你多走一程。",
	},
]

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
var loaded_game_pending_resume: bool = false
var current_auction: Dictionary = {}
var auction_choices: Dictionary = {}
var battle_contributions: Dictionary = {}
var battle_choices: Dictionary = {}
var battle_escaped_peers: Dictionary = {}
var battle_log: Array = []
var battle_continue_votes: Dictionary = {}
var pending_battle_reward_feedback: Dictionary = {}
var stat_allocation_started: bool = false
var bargain_choices: Dictionary = {}
var current_contest: Dictionary = {}
var bargain_continue_votes: Dictionary = {}
var pending_continue_next_index: int = -1
var pending_continue_round_finished: bool = false
var pending_backpack_items: Dictionary = {}
var rest_confirm_votes: Dictionary = {}
var final_duel_after_rest: bool = false
var lineup_locked: bool = false
var scattered_pool: Array[Dictionary] = []
var round_started: bool = false
var bargain_direction: int = 1
var rng := RandomNumberGenerator.new()
var pending_breakthrough_player: PlayerData = null
var tribulation_next_realm: String = ""
var pending_tribulation_data: Dictionary = {}
var tribulation_choices: Dictionary = {}
var duel_data: Dictionary = {}
var duel_round_number: int = 0
var duel_mode: String = "final"
var duel_continue_votes: Dictionary = {}
var pending_duel_winner_key: String = ""
var pending_duel_loser_key: String = ""
var current_sect_event: Dictionary = {}
var sect_event_choices: Dictionary = {}
var sect_event_continue_votes: Dictionary = {}
var ending_scroll_data: Dictionary = {}
var transition_layer: CanvasLayer = null
var transition_rect: ColorRect = null
var transition_active: bool = false
var pending_transition_path: String = ""
var last_transition_path: String = ""
var single_player_mode: bool = false
var selected_npc_profile: Dictionary = {}
var npc_last_dialogue: String = ""
var local_player_name: String = "无名散修"
var local_player_sect: String = ""


func _ready() -> void:
	rng.randomize()
	player_a = PlayerData.new()
	player_a.player_name = "道友甲"

	player_b = PlayerData.new()
	player_b.player_name = "道友乙"


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game(false)


func start_multiplayer_mode(display_name: String = "", _sect_name: String = "") -> void:
	if NetworkManager.has_method("stop_network"):
		NetworkManager.stop_network()
	set_local_player_name(display_name)
	set_local_player_sect("")
	reset_game()
	single_player_mode = false
	selected_npc_profile.clear()
	npc_last_dialogue = ""


func start_single_player_mode(npc_id: String, display_name: String = "", _sect_name: String = "") -> void:
	if NetworkManager.has_method("stop_network"):
		NetworkManager.stop_network()
	set_local_player_name(display_name)
	set_local_player_sect("")
	reset_game()
	single_player_mode = true
	NetworkManager.is_host = true
	NetworkManager.connected = false
	player_a.player_name = local_player_name
	player_a.sect = ""
	player_a.peer_id = 1
	player_b.peer_id = 2
	selected_npc_profile = _find_npc_profile(npc_id)
	_configure_npc_player(selected_npc_profile)
	push_npc_dialogue("meet")
	transition_to_scene("res://scenes/stat_alloc.tscn")


func is_single_player() -> bool:
	return single_player_mode


func set_local_player_name(display_name: String) -> void:
	var clean_name: String = display_name.strip_edges()
	if clean_name == "":
		clean_name = local_player_name.strip_edges()
	if clean_name == "":
		clean_name = "无名散修"
	if clean_name.length() > 8:
		clean_name = clean_name.left(8)
	local_player_name = clean_name


func set_local_player_sect(sect_name: String) -> void:
	var clean_sect: String = sect_name.strip_edges()
	if clean_sect != "" and not SECTS.has(clean_sect):
		clean_sect = ""
	local_player_sect = clean_sect


func _find_npc_profile(npc_id: String) -> Dictionary:
	for profile in NPC_PROFILES:
		var data: Dictionary = profile as Dictionary
		if str(data.get("id", "")) == npc_id:
			return data.duplicate(true)
	return (NPC_PROFILES[0] as Dictionary).duplicate(true)


func _configure_npc_player(profile: Dictionary) -> void:
	player_b.player_name = str(profile.get("name", "同道"))
	player_b.sect = str(profile.get("route", "散修"))
	player_b.stats = _npc_stats_for_route(str(profile.get("route", "剑修")))
	player_b.remain_points = 0
	player_b.minor_stage = 1
	player_b.final_attributes["npc"] = true
	player_b.final_attributes["npc_route"] = str(profile.get("route", "散修"))
	player_b.final_attributes["npc_temper"] = str(profile.get("temper", "bold"))
	player_b.final_attributes["bazi"] = {"npc": true, "route": str(profile.get("route", "散修"))}
	var hour_bonus: Dictionary = {"速度": 3} if str(profile.get("route", "")) == "剑修" else {"气血": 0.03}
	player_b.final_attributes["hour_bonus"] = hour_bonus.duplicate(true)
	apply_hour_bonus_to_player(player_b, hour_bonus)
	initialize_player_life(player_b)


func _npc_stats_for_route(route: String) -> Dictionary:
	match route:
		"剑修":
			return {"体魄": 1, "气感": 3, "经商": 0, "身法": 3, "魅力": 2, "机缘": 3}
		"体修":
			return {"体魄": 4, "气感": 1, "经商": 1, "身法": 2, "魅力": 2, "机缘": 2}
		"鬼修":
			return {"体魄": 2, "气感": 3, "经商": 0, "身法": 1, "魅力": 3, "机缘": 3}
		"情修":
			return {"体魄": 1, "气感": 2, "经商": 2, "身法": 2, "魅力": 4, "机缘": 1}
		_:
			return {"体魄": 2, "气感": 2, "经商": 1, "身法": 2, "魅力": 2, "机缘": 3}


func push_npc_dialogue(event: String, context: Dictionary = {}) -> void:
	if not single_player_mode:
		return
	var line: String = _npc_dialogue_for_event(event, context)
	if line == "":
		return
	npc_last_dialogue = line
	npc_dialogue_changed.emit(line)


func _npc_dialogue_for_event(event: String, context: Dictionary = {}) -> String:
	var temper: String = str(selected_npc_profile.get("temper", "bold"))
	match event:
		"meet":
			return str(selected_npc_profile.get("meet", "同行一程，生死自知。"))
		"inject":
			return "我也注入一年寿元。天命开牌，看它给不给脸。"
		"choice":
			var choice: String = str(context.get("choice", "让"))
			var card_desc: String = str(context.get("desc", "这张牌"))
			if choice == "抢":
				return "这张我想争：" + card_desc
			return "我先退一步：" + card_desc
		"contest_yield":
			return "此局我认，别把命赌在一口气上。"
		"contest_fight":
			return "不服。就这一手，看看天命站谁。"
		"auction":
			return "坊市今日人多，我先看一眼货品再说。"
		"battle":
			if temper == "greedy":
				return "能跑就跑，跑不了再咬它一口。"
			if temper == "kind":
				return "别慌，我在前面顶住。"
			return "妖兽当前，出手要快。"
		"tribulation":
			return "天劫落下时，人心比雷声更响。"
		"breakthrough":
			return "我修为已满，先试着破这一关。你替我看着点天象。"
		"result":
			var gain: float = float(context.get("gain", 0.0))
			var lose: float = float(context.get("lose", 0.0))
			var desc: String = str(context.get("desc", "这一张"))
			if gain > 0.0 and lose > 0.0:
				return "拿了" + desc + "，也吃了苦头。修仙哪有白赚。"
			if gain > 0.0:
				return "这份因果我收下了：" + desc
			if lose > 0.0:
				return "这道劫我记住了。下次未必还让它落在我身上。"
			return "天命擦肩而过，先记在账上。"
		"final_yield":
			return "仙门就在眼前，可我忽然想看看你进去是什么样。"
		"final_ascend":
			return "最后一局我赢了。别怪我，仙路本来就窄。"
		_:
			return ""


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
	tween.tween_callback(_change_scene_during_transition.bind(scene_path))
	tween.tween_interval(0.05)
	tween.tween_property(transition_rect, "color:a", 0.0, 0.3)
	tween.tween_callback(_finish_scene_transition)


func _change_scene_during_transition(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)


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
	_auto_save("state")


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
	var incoming_name: String = str(data.get("player_name", "")).strip_edges()
	if incoming_name != "":
		player.player_name = incoming_name.left(8)
	var incoming_sect: String = str(data.get("sect", "")).strip_edges()
	if SECTS.has(incoming_sect):
		player.sect = incoming_sect
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
	if single_player_mode:
		transition_to_scene("res://scenes/game_main.tscn")
	else:
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
	if _any_player_can_trigger_duel():
		_trigger_final_duel()
		return true
	return false


func _finish_round_without_rest() -> void:
	if not NetworkManager.is_host:
		return
	save_game(false)
	_advance_after_round_end(true)


func _advance_after_round_end(allow_sparring: bool = true) -> void:
	if not NetworkManager.is_host:
		return
	if current_state == GameState.ENDING:
		return
	if current_state != GameState.BARGAIN:
		change_state(GameState.BARGAIN)
	_apply_round_end_grace()
	if check_duel_trigger():
		return
	if allow_sparring and _should_trigger_sect_event():
		_trigger_sect_event()
		return
	if _try_queue_npc_breakthrough():
		return
	_start_next_round_for_all()


func _advance_after_sparring() -> void:
	if not NetworkManager.is_host:
		return
	duel_data.clear()
	duel_round_number = 0
	duel_mode = "final"
	pending_duel_winner_key = ""
	pending_duel_loser_key = ""
	_advance_after_round_end(false)


func _start_next_round_for_all() -> void:
	if not NetworkManager.is_host:
		return
	if not single_player_mode:
		_start_new_round.rpc()
	_start_new_round()


func _clear_pending_tribulation_state() -> void:
	pending_breakthrough_player = null
	tribulation_next_realm = ""
	pending_tribulation_data.clear()
	tribulation_choices.clear()


func _any_player_can_trigger_duel() -> bool:
	return _can_player_trigger_duel(player_a) or _can_player_trigger_duel(player_b)


func _can_player_trigger_duel(player: PlayerData) -> bool:
	return player != null and player.realm == "元婴期" and _get_minor_stage(player) >= MINOR_STAGE_NAMES.size() and player.ling_li >= DUEL_LING_LI_REQ


func _should_trigger_sect_event() -> bool:
	if not NetworkManager.is_host:
		return false
	if lineup_locked or current_state == GameState.DUEL or current_state == GameState.ENDING or current_state == GameState.SECT_EVENT:
		return false
	if round_number <= 0 or SECT_EVENT_ROUND_INTERVAL <= 0:
		return false
	if round_number % SECT_EVENT_ROUND_INTERVAL != 0:
		return false
	if player_a == null or player_b == null or player_a.qi_xue <= 0 or player_b.qi_xue <= 0:
		return false
	check_set_bonus(player_a)
	check_set_bonus(player_b)
	var sect_a: String = _player_event_sect(player_a)
	var sect_b: String = _player_event_sect(player_b)
	return SECT_TYPES.has(sect_a) and SECT_TYPES.has(sect_b)


func _player_event_sect(player: PlayerData) -> String:
	if player == null:
		return ""
	check_set_bonus(player)
	if int(player.final_attributes.get("identity_level", 0)) <= 0:
		return ""
	var sect_name: String = str(player.final_attributes.get("identity_sect", player.sect))
	if SECT_TYPES.has(sect_name):
		return sect_name
	return ""


func _trigger_sect_event() -> void:
	if not NetworkManager.is_host:
		return
	var sect_a: String = _player_event_sect(player_a)
	var sect_b: String = _player_event_sect(player_b)
	if not SECT_TYPES.has(sect_a) or not SECT_TYPES.has(sect_b):
		_start_next_round_for_all()
		return
	var event_type: String = "tournament" if sect_a == sect_b else "conflict"
	var title: String = "宗门大比" if event_type == "tournament" else "宗门争端"
	var desc: String = ""
	var rules: String = ""
	if event_type == "tournament":
		desc = sect_a + "三年一比，门内同道各凭本事登台。切磋不伤性命，胜者得宗门赏赐。"
		rules = "参加：连战3名同门NPC，逐场得奖励；双方全胜会师决赛。冠军得宗门奖品与身份分。不参加：潜修抽" + str(SECT_EVENT_PRIVATE_DRAW_COUNT) + "张。"
	else:
		desc = sect_a + "与" + sect_b + "道统相争，先破对方宗门高手，再论最后胜负。此为切磋，不会陨落。"
		rules = "参加：先打对方宗门NPC。胜者得灵石、功法与身份分；不参加：潜修抽" + str(SECT_EVENT_PRIVATE_DRAW_COUNT) + "张，争端中避战会损门派声望。"
	current_sect_event = {
		"id": Time.get_ticks_msec(),
		"phase": "choice",
		"type": event_type,
		"title": title,
		"desc": desc,
		"rules": rules,
		"round": round_number,
		"sect_a": sect_a,
		"sect_b": sect_b,
		"choice_seconds": SECT_EVENT_CHOICE_SECONDS,
	}
	sect_event_choices.clear()
	sect_event_continue_votes.clear()
	change_state(GameState.SECT_EVENT)
	var data: Dictionary = _sect_event_state_data("宗门事件触发，等待双方选择。")
	NetworkManager.send_message("sect_event_started", data)
	sect_event_started.emit(data)
	_queue_sect_event_choice_timeout(int(current_sect_event.get("id", 0)))
	save_game(false)


func _sect_event_state_data(message: String = "") -> Dictionary:
	var data: Dictionary = current_sect_event.duplicate(true)
	data["message"] = message
	data["choices"] = sect_event_choices.duplicate(true)
	data["continue_votes"] = sect_event_continue_votes.duplicate(true)
	data["player_a"] = _player_snapshot(player_a)
	data["player_b"] = _player_snapshot(player_b)
	return data


func on_sect_event_started(data: Dictionary) -> void:
	current_sect_event = data.duplicate(true)
	sect_event_choices = (data.get("choices", {}) as Dictionary).duplicate(true)
	sect_event_continue_votes = (data.get("continue_votes", {}) as Dictionary).duplicate(true)
	_apply_player_snapshot(player_a, data.get("player_a", {}) as Dictionary)
	_apply_player_snapshot(player_b, data.get("player_b", {}) as Dictionary)
	change_state(GameState.SECT_EVENT)
	sect_event_started.emit(data)


func on_sect_event_updated(data: Dictionary) -> void:
	current_sect_event = data.duplicate(true)
	sect_event_choices = (data.get("choices", sect_event_choices) as Dictionary).duplicate(true)
	sect_event_continue_votes = (data.get("continue_votes", sect_event_continue_votes) as Dictionary).duplicate(true)
	_apply_player_snapshot(player_a, data.get("player_a", {}) as Dictionary)
	_apply_player_snapshot(player_b, data.get("player_b", {}) as Dictionary)
	sect_event_updated.emit(data)


func on_sect_event_finished(data: Dictionary) -> void:
	current_sect_event.clear()
	sect_event_choices.clear()
	sect_event_continue_votes.clear()
	_apply_player_snapshot(player_a, data.get("player_a", {}) as Dictionary)
	_apply_player_snapshot(player_b, data.get("player_b", {}) as Dictionary)
	sect_event_finished.emit(data)


func _sect_event_peer_ids() -> Array[int]:
	var peer_ids: Array[int] = []
	if player_a != null:
		peer_ids.append(player_a.peer_id if player_a.peer_id > 0 else 1)
	if player_b != null:
		peer_ids.append(player_b.peer_id if player_b.peer_id > 0 else 2)
	return peer_ids


func _queue_sect_event_choice_timeout(event_id: int) -> void:
	await get_tree().create_timer(SECT_EVENT_CHOICE_SECONDS).timeout
	if not NetworkManager.is_host or current_state != GameState.SECT_EVENT:
		return
	if int(current_sect_event.get("id", -1)) != event_id or str(current_sect_event.get("phase", "")) != "choice":
		return
	for peer_id in _sect_event_peer_ids():
		if not sect_event_choices.has(str(peer_id)):
			sect_event_choices[str(peer_id)] = false
	_try_resolve_sect_event()


func on_sect_event_choice_received(peer_id: int, data: Dictionary) -> void:
	if not NetworkManager.is_host or current_state != GameState.SECT_EVENT:
		return
	if str(current_sect_event.get("phase", "")) != "choice":
		return
	var choice_peer_id: int = peer_id
	if choice_peer_id <= 0:
		choice_peer_id = 1
	var player: PlayerData = get_player_by_peer(choice_peer_id)
	if player == null:
		return
	var participate: bool = bool(data.get("participate", false))
	sect_event_choices[str(choice_peer_id)] = participate
	if str(current_sect_event.get("type", "")) == "conflict" and participate:
		_clear_sect_passive_penalty(player)
	if single_player_mode and choice_peer_id == player_a.peer_id and player_b != null and not sect_event_choices.has(str(player_b.peer_id)):
		sect_event_choices[str(player_b.peer_id)] = false if bool(data.get("timeout", false)) else _choose_npc_sect_event_participation()
	var update_data: Dictionary = _sect_event_state_data("已记录选择，等待同道回应。")
	NetworkManager.send_message("sect_event_updated", update_data)
	sect_event_updated.emit(update_data)
	_try_resolve_sect_event()


func _choose_npc_sect_event_participation() -> bool:
	if player_b == null:
		return false
	var max_hp: int = _get_player_max_hp(player_b)
	var hp_rate: float = float(player_b.qi_xue) / float(maxi(1, max_hp))
	var chance: float = 0.58
	if hp_rate < 0.35:
		chance -= 0.28
	if get_visible_combat_power(player_b) > get_visible_combat_power(player_a) * 0.95:
		chance += 0.16
	var temper: String = str(selected_npc_profile.get("temper", "bold"))
	if temper in ["bold", "greedy"]:
		chance += 0.10
	elif temper in ["kind", "soft"]:
		chance -= 0.04
	return rng.randf() < clampf(chance, 0.12, 0.86)


func _try_resolve_sect_event() -> void:
	if not NetworkManager.is_host or current_state != GameState.SECT_EVENT:
		return
	for peer_id in _sect_event_peer_ids():
		if not sect_event_choices.has(str(peer_id)):
			return
	var result: Dictionary = _resolve_sect_event()
	current_sect_event["phase"] = "result"
	current_sect_event["result"] = result
	current_sect_event["message"] = str(result.get("summary", "宗门事件已结算。"))
	sect_event_continue_votes.clear()
	check_set_bonus(player_a)
	check_set_bonus(player_b)
	var data: Dictionary = _sect_event_state_data(str(result.get("summary", "")))
	NetworkManager.send_message("sect_event_updated", data)
	sect_event_updated.emit(data)
	save_game(false)


func on_sect_event_continue_received(peer_id: int, _data: Dictionary = {}) -> void:
	if not NetworkManager.is_host or current_state != GameState.SECT_EVENT:
		return
	if str(current_sect_event.get("phase", "")) != "result":
		return
	var continue_peer_id: int = peer_id
	if continue_peer_id <= 0:
		continue_peer_id = 1
	sect_event_continue_votes[str(continue_peer_id)] = true
	if single_player_mode and player_b != null and continue_peer_id == player_a.peer_id:
		sect_event_continue_votes[str(player_b.peer_id)] = true
	var update_data: Dictionary = _sect_event_state_data("等待双方读完宗门战报。")
	NetworkManager.send_message("sect_event_updated", update_data)
	sect_event_updated.emit(update_data)
	for event_peer_id in _sect_event_peer_ids():
		if not sect_event_continue_votes.has(str(event_peer_id)):
			return
	_finish_sect_event()


func _finish_sect_event() -> void:
	if not NetworkManager.is_host:
		return
	var data: Dictionary = _sect_event_state_data("宗门事件结束。")
	NetworkManager.send_message("sect_event_finished", data)
	on_sect_event_finished(data)
	change_state(GameState.BARGAIN)
	_start_next_round_for_all()


func _resolve_sect_event() -> Dictionary:
	var join_a: bool = bool(sect_event_choices.get(str(player_a.peer_id), false))
	var join_b: bool = bool(sect_event_choices.get(str(player_b.peer_id), false))
	var event_type: String = str(current_sect_event.get("type", "tournament"))
	var lines: Array[String] = []
	var summary: String = ""
	if event_type == "tournament":
		summary = _resolve_sect_tournament(join_a, join_b, lines)
	else:
		summary = _resolve_sect_conflict(join_a, join_b, lines)
	return {
		"summary": summary,
		"lines": lines,
		"join_a": join_a,
		"join_b": join_b,
	}


func _resolve_sect_tournament(join_a: bool, join_b: bool, lines: Array[String]) -> String:
	var sect_name: String = str(current_sect_event.get("sect_a", "宗门"))
	if not join_a and not join_b:
		lines.append("两人皆未赴会，各自闭门潜修。")
		lines.append_array(_sect_event_private_cultivation(player_a, "潜心修炼") as Array)
		lines.append_array(_sect_event_private_cultivation(player_b, "潜心修炼") as Array)
		return "宗门大比无人登台，双方各自潜修。"
	var run_a: Dictionary = _sect_event_tournament_run(player_a) if join_a else {"wins": -1, "all_win": false, "lines": [player_a.player_name + "闭门潜修。"]}
	var run_b: Dictionary = _sect_event_tournament_run(player_b) if join_b else {"wins": -1, "all_win": false, "lines": [player_b.player_name + "闭门潜修。"]}
	lines.append_array(run_a.get("lines", []) as Array)
	lines.append_array(run_b.get("lines", []) as Array)
	if not join_a:
		lines.append_array(_sect_event_private_cultivation(player_a, "潜心修炼") as Array)
	if not join_b:
		lines.append_array(_sect_event_private_cultivation(player_b, "潜心修炼") as Array)
	var champion: PlayerData = null
	var runner_up: PlayerData = null
	if join_a and join_b and bool(run_a.get("all_win", false)) and bool(run_b.get("all_win", false)):
		var spar: Dictionary = _sect_event_pvp_spar(player_a, player_b, sect_name + "会师决赛")
		champion = spar.get("winner", null) as PlayerData
		runner_up = spar.get("loser", null) as PlayerData
		lines.append_array(spar.get("lines", []) as Array)
	elif join_a and (not join_b or int(run_a.get("wins", 0)) > int(run_b.get("wins", -1))):
		champion = player_a
		runner_up = player_b if join_b else null
	elif join_b and (not join_a or int(run_b.get("wins", 0)) > int(run_a.get("wins", -1))):
		champion = player_b
		runner_up = player_a if join_a else null
	elif join_a and join_b:
		var tie: Dictionary = _sect_event_pvp_spar(player_a, player_b, sect_name + "加试")
		champion = tie.get("winner", null) as PlayerData
		runner_up = tie.get("loser", null) as PlayerData
		lines.append_array(tie.get("lines", []) as Array)
	if champion != null:
		lines.append(_grant_sect_event_champion_reward(champion, sect_name, 5))
	if runner_up != null:
		lines.append(_grant_random_equipped_technique_fragment(runner_up, "宗门大比亚军"))
	elif join_a != join_b:
		var solo_player: PlayerData = player_a if join_a else player_b
		var solo_run: Dictionary = run_a if join_a else run_b
		if solo_player != null and not bool(solo_run.get("all_win", false)):
			var before_stage: String = get_cultivation_stage_name(solo_player)
			solo_player.ling_li += 50
			lines.append(_append_stage_change_to_message(solo_player, before_stage, solo_player.player_name + "虽败犹荣，修为 +50"))
	return champion.player_name + "夺得" + sect_name + "大比魁首。" if champion != null else sect_name + "大比已结算。"


func _sect_event_tournament_run(player: PlayerData) -> Dictionary:
	var lines: Array[String] = []
	var wins: int = 0
	var multipliers: Array[float] = [0.7, 0.9, 1.0]
	for i in range(multipliers.size()):
		var pve: Dictionary = _sect_event_pve_fight(player, float(multipliers[i]), "NPC" + str(i + 1))
		if bool(pve.get("win", false)):
			wins += 1
			match i:
				0:
					var before_stage: String = get_cultivation_stage_name(player)
					player.ling_li += 30
					lines.append(_append_stage_change_to_message(player, before_stage, player.player_name + "胜过首席弟子，修为 +30"))
				1:
					player.ling_shi += 200
					lines.append(player.player_name + "胜过执事师兄，灵石 +200")
				2:
					lines.append(_grant_random_equipped_technique_fragment(player, "宗门大比"))
		else:
			lines.append(player.player_name + "止步第" + str(i + 1) + "战：" + str(pve.get("detail", "惜败")))
			break
	return {"wins": wins, "all_win": wins >= 3, "lines": lines}


func _resolve_sect_conflict(join_a: bool, join_b: bool, lines: Array[String]) -> String:
	var sect_a: String = str(current_sect_event.get("sect_a", ""))
	var sect_b: String = str(current_sect_event.get("sect_b", ""))
	if not join_a and not join_b:
		lines.append("两宗都未出战，风波暂息，双方各自潜修。")
		lines.append_array(_sect_event_private_cultivation(player_a, "潜心修炼") as Array)
		lines.append_array(_sect_event_private_cultivation(player_b, "潜心修炼") as Array)
		return "宗门争端暂息，双方各自潜修。"
	if join_a and join_b:
		var pve_a: Dictionary = _sect_event_pve_fight(player_a, 1.1, sect_b + "高手")
		var pve_b: Dictionary = _sect_event_pve_fight(player_b, 1.1, sect_a + "高手")
		if bool(pve_a.get("win", false)):
			player_a.ling_li += 50
			player_a.ling_shi += 300
			lines.append(player_a.player_name + "破" + sect_b + "高手，修为 +50，灵石 +300")
		else:
			player_a.ling_li += 30
			lines.append(player_a.player_name + "败于" + sect_b + "高手，补偿修为 +30")
		if bool(pve_b.get("win", false)):
			player_b.ling_li += 50
			player_b.ling_shi += 300
			lines.append(player_b.player_name + "破" + sect_a + "高手，修为 +50，灵石 +300")
		else:
			player_b.ling_li += 30
			lines.append(player_b.player_name + "败于" + sect_a + "高手，补偿修为 +30")
		var winner: PlayerData = null
		var loser: PlayerData = null
		if bool(pve_a.get("win", false)) and bool(pve_b.get("win", false)):
			var spar: Dictionary = _sect_event_pvp_spar(player_a, player_b, "宗门争端终局")
			winner = spar.get("winner", null) as PlayerData
			loser = spar.get("loser", null) as PlayerData
			lines.append_array(spar.get("lines", []) as Array)
		elif bool(pve_a.get("win", false)):
			winner = player_a
			loser = player_b
		elif bool(pve_b.get("win", false)):
			winner = player_b
			loser = player_a
		if winner != null:
			lines.append(_grant_sect_conflict_winner_reward(winner))
		if loser != null:
			_grant_next_round_quality_bonus(loser)
			lines.append(loser.player_name + "知耻后勇，下一轮机缘品质 +5%")
		return winner.player_name + "赢下宗门争端。" if winner != null else "两宗争端未分胜负。"
	var participant: PlayerData = player_a if join_a else player_b
	var abstainer: PlayerData = player_b if join_a else player_a
	var target_sect: String = sect_b if join_a else sect_a
	var own_sect: String = sect_a if join_a else sect_b
	var solo: Dictionary = _sect_event_pve_fight(participant, 1.1, target_sect + "高手")
	if bool(solo.get("win", false)):
		participant.ling_shi += 500
		_add_sect_event_score(participant, own_sect, 5)
		_apply_sect_passive_penalty(abstainer, 2)
		lines.append(participant.player_name + "孤身破敌，灵石 +500，宗门身份分 +5；对方门派被动减半2轮")
	else:
		var before_stage: String = get_cultivation_stage_name(participant)
		participant.ling_li += 50
		lines.append(_append_stage_change_to_message(participant, before_stage, participant.player_name + "孤军奋战虽败犹荣，修为 +50"))
	_apply_sect_passive_penalty(abstainer, 2)
	_add_sect_event_score(abstainer, _player_event_sect(abstainer), -3)
	lines.append(abstainer.player_name + "避战潜修，宗门身份分 -3，门派被动减半2轮")
	lines.append_array(_sect_event_private_cultivation(abstainer, "潜心修炼") as Array)
	return participant.player_name + "代表" + own_sect + "出战宗门争端。"


func _sect_event_pve_fight(player: PlayerData, npc_multiplier: float, npc_name: String) -> Dictionary:
	if player == null:
		return {"win": false, "detail": "无人出战"}
	var player_power: float = maxf(1.0, get_visible_combat_power(player))
	var npc_power: float = maxf(1.0, player_power * npc_multiplier)
	var chance: float = clampf(0.50 + (player_power - npc_power) / maxf(player_power, npc_power) * 0.55, 0.18, 0.88)
	var win: bool = rng.randf() < chance
	return {
		"win": win,
		"chance": chance,
		"player_power": player_power,
		"npc_power": npc_power,
		"detail": npc_name + "战力约" + str(int(round(npc_power))) + "，胜率" + str(int(round(chance * 100.0))) + "%",
	}


func _sect_event_pvp_spar(first: PlayerData, second: PlayerData, title: String) -> Dictionary:
	var lines: Array[String] = []
	if first == null or second == null:
		return {"winner": first, "loser": second, "lines": lines}
	var power_a: float = maxf(1.0, get_visible_combat_power(first))
	var power_b: float = maxf(1.0, get_visible_combat_power(second))
	var chance_a: float = clampf(0.50 + (power_a - power_b) / maxf(power_a, power_b) * 0.45, 0.20, 0.80)
	var first_wins: bool = rng.randf() < chance_a
	var winner: PlayerData = first if first_wins else second
	var loser: PlayerData = second if first_wins else first
	lines.append(title + "：" + winner.player_name + "胜出（" + str(int(round(power_a))) + " vs " + str(int(round(power_b))) + "），切磋点到为止。")
	return {"winner": winner, "loser": loser, "lines": lines}


func _grant_random_equipped_technique_fragment(player: PlayerData, source: String) -> String:
	if player == null:
		return ""
	if player.techniques.is_empty():
		var before_stage: String = get_cultivation_stage_name(player)
		player.ling_li += 30
		return _append_stage_change_to_message(player, before_stage, player.player_name + "暂无上场功法，转为修为 +30")
	var candidates: Array[Dictionary] = []
	for technique in player.techniques:
		if technique is Dictionary:
			candidates.append(technique as Dictionary)
	if candidates.is_empty():
		return player.player_name + "未获得残卷"
	var target: Dictionary = candidates[rng.randi_range(0, candidates.size() - 1)]
	return player.player_name + "：" + _add_technique_fragment_progress(player, target, 1, source)


func _grant_sect_event_champion_reward(player: PlayerData, sect_name: String, score_bonus: int) -> String:
	if player == null:
		return ""
	_add_sect_event_score(player, sect_name, score_bonus)
	var min_rank: int = _quality_rank("元婴级")
	var prizes: Array[Dictionary] = []
	for i in range(3):
		var quality: String = _quality_by_rank(rng.randi_range(min_rank, QUALITY_ORDER.size() - 1))
		var kind: String = str(["technique", "treasure", "companion"][i])
		prizes.append({"kind": kind, "quality": quality})
	var chosen: Dictionary = prizes[rng.randi_range(0, prizes.size() - 1)] as Dictionary
	var quality: String = str(chosen.get("quality", "元婴级"))
	var chosen_kind: String = str(chosen.get("kind", "technique"))
	var reward_message: String = ""
	match chosen_kind:
		"treasure":
			reward_message = _store_equipment_item(player, "treasure", generate_treasure_for_player(player, quality))
		"companion":
			reward_message = _gain_companion_or_ghost(player, generate_companion_for_player(player, quality))
		_:
			reward_message = _grant_technique_reward(player, quality)
	return player.player_name + "获宗门魁首赏赐（三件宝物择一），" + reward_message + "；宗门身份分 +" + str(score_bonus)


func _grant_sect_conflict_winner_reward(player: PlayerData) -> String:
	if player == null:
		return ""
	var sect_name: String = _player_event_sect(player)
	player.ling_shi += 800
	_add_sect_event_score(player, sect_name, 8)
	var quality: String = _quality_by_rank(rng.randi_range(_quality_rank("元婴级"), QUALITY_ORDER.size() - 1))
	return player.player_name + "赢下争端，灵石 +800，" + _grant_technique_reward(player, quality) + "；宗门身份分 +8"


func _sect_event_private_cultivation(player: PlayerData, source: String) -> Array[String]:
	var lines: Array[String] = []
	if player == null:
		return lines
	var ji_yuan_stat: int = int(player.stats.get("机缘", 0))
	var good_count: int = 0
	var bad_count: int = 0
	var detail_lines: Array[String] = []
	for i in range(SECT_EVENT_PRIVATE_DRAW_COUNT):
		if rng.randf() < 0.68:
			var card: Dictionary = _sect_event_private_ji_yuan(ji_yuan_stat)
			var message: String = _apply_ji_yuan(player, card, float(card.get("effect_value", card.get("value", 1.0))), "修")
			if message != "":
				good_count += 1
			detail_lines.append(_sect_event_private_draw_line(i, card, message, false))
		else:
			var calamity: Dictionary = _sect_event_private_calamity(ji_yuan_stat)
			var calamity_message: String = _apply_calamity(player, calamity, float(calamity.get("effect_value", calamity.get("value", 1.0))))
			if calamity_message != "":
				bad_count += 1
			detail_lines.append(_sect_event_private_draw_line(i, calamity, calamity_message, true))
	lines.append(player.player_name + source + "抽到" + str(SECT_EVENT_PRIVATE_DRAW_COUNT) + "张：机缘" + str(good_count) + "张，灾厄" + str(bad_count) + "张。")
	lines.append_array(detail_lines)
	return lines


func _sect_event_private_draw_line(index: int, card: Dictionary, result_message: String, is_calamity: bool) -> String:
	var kind: String = "灾厄" if is_calamity else "机缘"
	var desc: String = str(card.get("desc", ""))
	if desc == "":
		desc = generate_desc(card, is_calamity)
	if desc == "":
		desc = str(card.get("type", kind))
	var result: String = result_message if result_message != "" else "无明显变化"
	return str(index + 1) + ". " + kind + "｜" + desc + " → " + result


func _sect_event_private_ji_yuan(stat: int) -> Dictionary:
	var choices: Array[String] = ["ling_li", "ling_shi", "heal_percent", "stat_up", "alchemy_material", "craft_material"]
	var effect_type: String = choices[rng.randi_range(0, choices.size() - 1)]
	return _generate_specific_ji_yuan(stat, effect_type) if effect_type != "heal_percent" else _build_ji_yuan_data(stat, {"name": "治疗", "base_effect": 30, "effect_type": "heal_percent"})


func _sect_event_private_calamity(stat: int) -> Dictionary:
	var quality: String = roll_quality(get_adjusted_quality_prob(stat, true))
	var effect_type: String = "ling_li_loss" if rng.randf() < 0.55 else "hp_percent_loss"
	var base_effect: int = 12 + _quality_rank(quality) * 6
	var data: Dictionary = {
		"quality": quality,
		"type": "闭关暗劫",
		"effect_type": effect_type,
		"base_effect": base_effect,
		"effect_value": base_effect,
		"value": base_effect,
	}
	data["desc"] = generate_desc(data, true)
	return data


func _add_sect_event_score(player: PlayerData, sect_name: String, amount: int) -> void:
	if player == null or not SECT_TYPES.has(sect_name) or amount == 0:
		return
	var scores: Dictionary = (player.final_attributes.get("sect_event_score_bonus", {}) as Dictionary).duplicate(true)
	scores[sect_name] = float(scores.get(sect_name, 0.0)) + float(amount)
	player.final_attributes["sect_event_score_bonus"] = scores


func _apply_sect_passive_penalty(player: PlayerData, rounds: int) -> void:
	if player == null:
		return
	player.final_attributes["sect_passive_halved_until"] = round_number + maxi(1, rounds)


func _clear_sect_passive_penalty(player: PlayerData) -> void:
	if player == null:
		return
	player.final_attributes.erase("sect_passive_halved_until")


func _grant_next_round_quality_bonus(player: PlayerData) -> void:
	if player == null:
		return
	player.final_attributes["sect_quality_bonus_round"] = round_number + 1


func _sect_event_quality_shift_active() -> float:
	var shift: float = 0.0
	for player in [player_a, player_b]:
		if player == null:
			continue
		if int(player.final_attributes.get("sect_quality_bonus_round", -1)) == round_number:
			shift = maxf(shift, 0.05)
	return shift


func _start_rest_phase(final_duel: bool = false) -> void:
	if not NetworkManager.is_host:
		return
	if current_state == GameState.REST and final_duel_after_rest == final_duel:
		return
	final_duel_after_rest = final_duel
	rest_confirm_votes.clear()
	check_set_bonus(player_a)
	check_set_bonus(player_b)
	change_state(GameState.REST)
	var data: Dictionary = _rest_state_data("最终整备：确认后阵容锁定" if final_duel else "整备：整理背包与上场阵容")
	NetworkManager.send_message("rest_started", data)
	rest_started.emit(data)
	save_game(false)


func _rest_state_data(message: String = "") -> Dictionary:
	return {
		"message": message,
		"final_duel": final_duel_after_rest,
		"lineup_locked": lineup_locked,
		"round_number": round_number,
		"player_a": _player_snapshot(player_a),
		"player_b": _player_snapshot(player_b),
		"pending_backpack_items": pending_backpack_items.duplicate(true),
		"rest_confirm_votes": rest_confirm_votes.duplicate(true),
		"scattered_count": scattered_pool.size(),
	}


func has_save_game() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func _can_auto_save() -> bool:
	if not AUTO_SAVE_ENABLED:
		return false
	if NetworkManager.connected and not NetworkManager.is_host:
		return false
	if player_a == null or player_b == null:
		return false
	if round_number <= 0 and current_state == GameState.STAT_ALLOCATION:
		return false
	return true


func _auto_save(_reason: String = "") -> void:
	if not _can_auto_save():
		return
	save_game(false)


func save_game(manual: bool = false) -> String:
	if NetworkManager.connected and not NetworkManager.is_host:
		return "联机中由房主自动存档"
	if player_a == null or player_b == null:
		return "暂无可保存进度"
	if not manual and round_number <= 0 and current_state == GameState.STAT_ALLOCATION:
		return "尚未进入可自动存档阶段"
	var payload: Dictionary = _save_payload(manual)
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return "存档失败"
	file.store_string(JSON.stringify(payload, "\t"))
	file.close()
	return "已存档：" + str(payload.get("timestamp", ""))


func load_game_from_disk(sync_network: bool = true) -> bool:
	if not has_save_game():
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var text: String = file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if not parsed is Dictionary:
		return false
	_restore_save_payload(parsed as Dictionary)
	if sync_network and NetworkManager.is_host:
		NetworkManager.send_message("save_sync", parsed as Dictionary)
	transition_to_scene(_scene_for_state(current_state))
	return true


func load_immortal_records() -> Array:
	if not FileAccess.file_exists(IMMORTAL_RECORD_PATH):
		return []
	var file := FileAccess.open(IMMORTAL_RECORD_PATH, FileAccess.READ)
	if file == null:
		return []
	var text: String = file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if parsed is Array:
		return (parsed as Array).duplicate(true)
	return []


func save_immortal_record_from_scroll(scroll_data: Dictionary) -> void:
	if scroll_data.is_empty() or not bool(scroll_data.get("is_winner", false)):
		return
	var record: Dictionary = scroll_data.get("仙册", {}) as Dictionary
	if record.is_empty():
		return
	var records: Array = load_immortal_records()
	records.append(record.duplicate(true))
	while records.size() > 50:
		records.remove_at(0)
	var file := FileAccess.open(IMMORTAL_RECORD_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(records, "\t"))
	file.close()


func on_save_sync(data: Dictionary) -> void:
	if data.is_empty():
		return
	_restore_save_payload(data)
	transition_to_scene(_scene_for_state(current_state))


func _save_payload(manual: bool) -> Dictionary:
	return {
		"version": 1,
		"manual": manual,
		"timestamp": Time.get_datetime_string_from_system(false, true),
		"round_number": round_number,
		"round_started": round_started,
		"current_state": current_state,
		"single_player_mode": single_player_mode,
		"selected_npc_profile": selected_npc_profile.duplicate(true),
		"npc_last_dialogue": npc_last_dialogue,
		"local_player_name": local_player_name,
		"player_a": _player_snapshot(player_a),
		"player_b": _player_snapshot(player_b),
		"current_lottery_results": current_lottery_results.duplicate(true),
		"current_lottery_cards": current_lottery_cards.duplicate(true),
		"current_card_index": current_card_index,
		"current_bargain_index": current_bargain_index,
		"lottery_energy_started": lottery_energy_started,
		"pending_continue_next_index": pending_continue_next_index,
		"pending_continue_round_finished": pending_continue_round_finished,
		"bargain_direction": bargain_direction,
		"current_enemy": current_enemy.duplicate(true),
		"enemy_elite": enemy_elite,
		"current_auction": current_auction.duplicate(true),
		"battle_contributions": battle_contributions.duplicate(true),
		"battle_escaped_peers": battle_escaped_peers.duplicate(true),
		"battle_log": battle_log.duplicate(true),
		"pending_backpack_items": pending_backpack_items.duplicate(true),
		"final_duel_after_rest": final_duel_after_rest,
		"lineup_locked": lineup_locked,
		"duel_mode": duel_mode,
		"duel_data": duel_data.duplicate(true),
		"duel_round_number": duel_round_number,
		"current_sect_event": current_sect_event.duplicate(true),
		"sect_event_choices": sect_event_choices.duplicate(true),
		"sect_event_continue_votes": sect_event_continue_votes.duplicate(true),
		"scattered_pool": scattered_pool.duplicate(true),
		"game_state": current_state,
	}


func _restore_save_payload(data: Dictionary) -> void:
	player_a = PlayerData.new()
	player_b = PlayerData.new()
	single_player_mode = bool(data.get("single_player_mode", false))
	selected_npc_profile = (data.get("selected_npc_profile", {}) as Dictionary).duplicate(true)
	npc_last_dialogue = str(data.get("npc_last_dialogue", ""))
	local_player_name = str(data.get("local_player_name", local_player_name))
	_apply_player_snapshot(player_a, data.get("player_a", {}) as Dictionary)
	_apply_player_snapshot(player_b, data.get("player_b", {}) as Dictionary)
	if player_a.peer_id <= 0:
		player_a.peer_id = 1
	if player_b.peer_id <= 0:
		player_b.peer_id = 2
	round_number = int(data.get("round_number", 0))
	round_started = bool(data.get("round_started", false))
	current_lottery_results = (data.get("current_lottery_results", []) as Array).duplicate(true)
	current_lottery_cards = (data.get("current_lottery_cards", []) as Array).duplicate(true)
	current_card_index = int(data.get("current_card_index", 0))
	current_bargain_index = int(data.get("current_bargain_index", current_card_index))
	lottery_energy_started = bool(data.get("lottery_energy_started", false))
	pending_continue_next_index = int(data.get("pending_continue_next_index", -1))
	pending_continue_round_finished = bool(data.get("pending_continue_round_finished", false))
	bargain_direction = int(data.get("bargain_direction", 1))
	current_enemy = (data.get("current_enemy", {}) as Dictionary).duplicate(true)
	enemy_elite = bool(data.get("enemy_elite", false))
	_refresh_enemy_pack_state()
	current_auction = (data.get("current_auction", {}) as Dictionary).duplicate(true)
	battle_contributions = (data.get("battle_contributions", {}) as Dictionary).duplicate(true)
	battle_escaped_peers = (data.get("battle_escaped_peers", {}) as Dictionary).duplicate(true)
	battle_log = (data.get("battle_log", []) as Array).duplicate(true)
	pending_backpack_items = (data.get("pending_backpack_items", {}) as Dictionary).duplicate(true)
	final_duel_after_rest = bool(data.get("final_duel_after_rest", false))
	lineup_locked = bool(data.get("lineup_locked", false))
	duel_mode = str(data.get("duel_mode", "final"))
	duel_data = (data.get("duel_data", {}) as Dictionary).duplicate(true)
	duel_round_number = int(data.get("duel_round_number", 0))
	current_sect_event = (data.get("current_sect_event", {}) as Dictionary).duplicate(true)
	sect_event_choices = (data.get("sect_event_choices", {}) as Dictionary).duplicate(true)
	sect_event_continue_votes = (data.get("sect_event_continue_votes", {}) as Dictionary).duplicate(true)
	scattered_pool.clear()
	var saved_scattered: Array = data.get("scattered_pool", []) as Array
	for scattered_entry in saved_scattered:
		if scattered_entry is Dictionary:
			scattered_pool.append((scattered_entry as Dictionary).duplicate(true))
	bargain_choices.clear()
	bargain_continue_votes.clear()
	lottery_energy_injections.clear()
	rest_confirm_votes.clear()
	auction_choices.clear()
	battle_choices.clear()
	battle_continue_votes.clear()
	current_contest.clear()
	duel_continue_votes.clear()
	pending_duel_winner_key = ""
	pending_duel_loser_key = ""
	ending_scroll_data.clear()
	if single_player_mode:
		NetworkManager.is_host = true
		NetworkManager.connected = false
	change_state(int(data.get("current_state", data.get("game_state", GameState.ROUND_START))))
	loaded_game_pending_resume = true


func resume_loaded_state_after_scene_ready() -> void:
	if not loaded_game_pending_resume:
		return
	loaded_game_pending_resume = false
	await get_tree().process_frame
	match current_state:
		GameState.LOTTERY:
			lottery_generated.emit(current_lottery_results)
			if lottery_energy_started:
				lottery_energy_ready.emit()
			else:
				var injected_count: int = mini(lottery_energy_injections.size(), _lottery_energy_required_count())
				lottery_energy_updated.emit(injected_count, _lottery_energy_required_count())
		GameState.BARGAIN:
			lottery_generated.emit(current_lottery_results)
			if _loaded_bargain_needs_resume():
				if NetworkManager.is_host:
					await get_tree().create_timer(0.2).timeout
					_resume_loaded_lottery_reveal()
			else:
				bargain_ready.emit(current_bargain_index)
		GameState.AUCTION:
			_ensure_current_auction_lots()
			auction_started.emit(current_auction.duplicate(true))
		GameState.REST:
			rest_started.emit(_rest_state_data("继续整备：整理背包与上场阵容"))
		GameState.BATTLE:
			battle_started.emit(current_enemy.duplicate(true))
			battle_updated.emit(_battle_state_data())
		GameState.DUEL:
			if duel_data.is_empty() and NetworkManager.is_host:
				start_duel_if_host()
			elif not duel_data.is_empty():
				duel_prepared.emit(duel_data.duplicate(true))
		GameState.SECT_EVENT:
			sect_event_started.emit(_sect_event_state_data(str(current_sect_event.get("message", "宗门事件继续。"))))
			if NetworkManager.is_host and str(current_sect_event.get("phase", "choice")) == "choice":
				var sect_event_ready_to_resolve: bool = true
				for event_peer_id in _sect_event_peer_ids():
					if not sect_event_choices.has(str(event_peer_id)):
						sect_event_ready_to_resolve = false
						break
				if sect_event_ready_to_resolve:
					_try_resolve_sect_event()
				else:
					_queue_sect_event_choice_timeout(int(current_sect_event.get("id", 0)))


func _loaded_bargain_points_to_hidden_card() -> bool:
	if current_bargain_index < 0 or current_bargain_index >= current_lottery_results.size():
		return false
	var card: Dictionary = current_lottery_results[current_bargain_index] as Dictionary
	return not card.has("effect_type")


func _loaded_bargain_needs_resume() -> bool:
	if pending_continue_round_finished:
		return true
	if current_lottery_cards.is_empty():
		return false
	if current_card_index < 0 or current_card_index >= current_lottery_cards.size():
		return true
	return _loaded_bargain_points_to_hidden_card()


func _resume_loaded_lottery_reveal() -> void:
	if not NetworkManager.is_host:
		return
	if current_card_index >= 0 and current_card_index < current_lottery_cards.size():
		_reveal_card_for_bargain(current_card_index)
		return
	if pending_continue_round_finished or current_card_index >= current_lottery_cards.size():
		_finish_round_without_rest()


func _scene_for_state(state: int) -> String:
	match state:
		GameState.STAT_ALLOCATION:
			return "res://scenes/stat_alloc.tscn"
		GameState.BATTLE:
			return "res://scenes/battle.tscn"
		GameState.DUEL:
			return "res://scenes/duel.tscn"
		GameState.ENDING:
			return "res://scenes/ending.tscn"
		_:
			return "res://scenes/game_main.tscn"


func on_rest_started(data: Dictionary) -> void:
	_apply_player_snapshot(player_a, data.get("player_a", {}) as Dictionary)
	_apply_player_snapshot(player_b, data.get("player_b", {}) as Dictionary)
	pending_backpack_items = (data.get("pending_backpack_items", pending_backpack_items) as Dictionary).duplicate(true)
	rest_confirm_votes = (data.get("rest_confirm_votes", rest_confirm_votes) as Dictionary).duplicate(true)
	final_duel_after_rest = bool(data.get("final_duel", final_duel_after_rest))
	lineup_locked = bool(data.get("lineup_locked", lineup_locked))
	change_state(GameState.REST)
	rest_started.emit(data)


func on_rest_updated(data: Dictionary) -> void:
	_apply_player_snapshot(player_a, data.get("player_a", {}) as Dictionary)
	_apply_player_snapshot(player_b, data.get("player_b", {}) as Dictionary)
	pending_backpack_items = (data.get("pending_backpack_items", pending_backpack_items) as Dictionary).duplicate(true)
	rest_confirm_votes = (data.get("rest_confirm_votes", rest_confirm_votes) as Dictionary).duplicate(true)
	final_duel_after_rest = bool(data.get("final_duel", final_duel_after_rest))
	lineup_locked = bool(data.get("lineup_locked", lineup_locked))
	rest_updated.emit(data)


func on_rest_confirm_received(peer_id: int, _data: Dictionary = {}) -> void:
	if not NetworkManager.is_host:
		return
	if current_state != GameState.REST:
		return
	var player: PlayerData = get_player_by_peer(peer_id)
	if player == null:
		return
	var pending_message: String = _try_store_pending_backpack_item(player)
	var issue: String = _player_backpack_issue(player)
	if issue != "":
		var blocked_data: Dictionary = _rest_state_data(issue)
		NetworkManager.send_message("rest_updated", blocked_data)
		on_rest_updated(blocked_data)
		return
	var confirm_peer_id: int = peer_id
	if confirm_peer_id <= 0:
		confirm_peer_id = 1
	rest_confirm_votes[confirm_peer_id] = true
	if single_player_mode and confirm_peer_id == player_a.peer_id and not rest_confirm_votes.has(player_b.peer_id):
		_auto_clear_npc_pending_backpack()
		var npc_issue: String = _player_backpack_issue(player_b)
		if npc_issue == "":
			rest_confirm_votes[player_b.peer_id] = true
	var total_required: int = _lottery_energy_required_count()
	if rest_confirm_votes.size() < total_required:
		var wait_message: String = "已确认整备，等待对方"
		if pending_message != "":
			wait_message = pending_message + "；" + wait_message
		var waiting_data: Dictionary = _rest_state_data(wait_message)
		NetworkManager.send_message("rest_updated", waiting_data)
		on_rest_updated(waiting_data)
		return
	rest_confirm_votes.clear()
	var should_start_duel: bool = final_duel_after_rest
	final_duel_after_rest = false
	if should_start_duel:
		lineup_locked = true
		_trigger_final_duel()
		return
	change_state(GameState.BARGAIN)
	check_breakthrough()


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
	var current_req: int = 0
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
	return 0


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
	var next_req: int = get_next_major_realm_req(player.realm, 0)
	var span: int = maxi(1, next_req)
	var step_index: int = maxi(0, stage - 1)
	return int(ceil(float(span) * float(step_index) / float(MINOR_STAGE_NAMES.size())))


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


func _spend_breakthrough_ling_li(player: PlayerData, cost: int) -> int:
	if player == null or cost <= 0:
		return 0
	var spent: int = mini(player.ling_li, cost)
	player.ling_li = maxi(0, player.ling_li - spent)
	return spent


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
	lineup_locked = true
	duel_mode = "final"
	duel_continue_votes.clear()
	duel_data.clear()
	change_state(GameState.DUEL)
	duel_triggered.emit()
	if not single_player_mode:
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


func ensure_round_started() -> void:
	if NetworkManager.is_host and current_state == GameState.ROUND_START and not round_started:
		start_round()


func start_round() -> void:
	if round_started:
		return
	if _try_trigger_death_ending():
		return

	round_started = true
	round_number += 1
	_expire_active_tasks(player_a)
	_expire_active_tasks(player_b)
	check_set_bonus(player_a)
	check_set_bonus(player_b)
	player_a.shou_yuan = maxi(0, player_a.shou_yuan - 1)
	player_b.shou_yuan = maxi(0, player_b.shou_yuan - 1)
	_apply_round_identity_passives(player_a)
	_apply_round_identity_passives(player_b)
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
	current_contest.clear()
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

	if single_player_mode and inject_peer_id != player_b.peer_id and not lottery_energy_injections.has(player_b.peer_id):
		_queue_npc_lottery_energy()

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
	start_battle(str(card.get("quality", "元婴级")))


func _start_auction_from_card(index: int, card: Dictionary) -> void:
	if not NetworkManager.is_host:
		return

	var auction_message: String = _grant_auction_entry_stones(card)
	card["auction_entry_message"] = auction_message
	current_auction = {
		"index": index,
		"card": card.duplicate(true),
		"lots": generate_auction_lots(str(card.get("quality", "筑基级"))),
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


func _ensure_current_auction_lots() -> void:
	if current_auction.is_empty():
		return
	var lots: Array = current_auction.get("lots", []) as Array
	if not lots.is_empty():
		return
	var card: Dictionary = current_auction.get("card", {}) as Dictionary
	if card.is_empty():
		var auction_index: int = int(current_auction.get("index", current_card_index))
		if auction_index >= 0 and auction_index < current_lottery_cards.size():
			card = (current_lottery_cards[auction_index] as Dictionary).duplicate(true)
			current_auction["card"] = card
	var quality: String = str(card.get("quality", "筑基级"))
	current_auction["lots"] = generate_auction_lots(quality)


func on_auction_started(data: Dictionary) -> void:
	var incoming_card: Dictionary = (data.get("card", {}) as Dictionary).duplicate(true)
	var incoming_lots: Array = (data.get("lots", []) as Array).duplicate(true)
	if incoming_lots.is_empty():
		incoming_lots = generate_auction_lots(str(incoming_card.get("quality", "筑基级")))
	current_auction = {
		"index": int(data.get("index", current_card_index)),
		"card": incoming_card,
		"lots": incoming_lots,
	}
	_apply_player_snapshot(player_a, data.get("player_a", {}) as Dictionary)
	_apply_player_snapshot(player_b, data.get("player_b", {}) as Dictionary)
	current_card_index = int(current_auction.get("index", current_card_index))
	current_bargain_index = current_card_index
	auction_choices.clear()
	change_state(GameState.AUCTION)
	auction_started.emit(current_auction.duplicate(true))


func _grant_auction_entry_stones(card: Dictionary) -> String:
	var amount: int = int(round(float(card.get("effect_value", card.get("value", AUCTION_STONE_BASE)))))
	if amount <= 0:
		amount = AUCTION_STONE_BASE
	player_a.ling_shi += amount
	player_b.ling_shi += amount
	var message: String = "坊市开张，双方各得周转灵石 +" + str(amount) + "；三件货任选其一"
	player_a.ji_yuan_list.append({"desc": message, "type": "坊市", "effect_value": amount})
	player_b.ji_yuan_list.append({"desc": message, "type": "坊市", "effect_value": amount})
	return message


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
	for i in 10:
		var card: Dictionary = _generate_single_lottery_card()
		cards.append(card)

	_ensure_lottery_composition(cards)
	return cards


func _ensure_lottery_composition(cards: Array) -> void:
	var protected_basics: Array = ["ling_li", "auction", "enemy"]
	_ensure_lottery_effect_cards(cards, ["auction"], MIN_AUCTION_CARDS_PER_ROUND, "auction", protected_basics)
	_ensure_lottery_effect_cards(cards, ["enemy"], MIN_ENEMY_CARDS_PER_ROUND, "enemy", protected_basics)
	_ensure_lottery_effect_cards(cards, ["ling_li"], MIN_CULTIVATION_CARDS_PER_ROUND, "cultivation", protected_basics)

	var protected_build: Array = protected_basics.duplicate(true)
	for effect_type_index in range(BUILD_EFFECT_TYPES.size()):
		protected_build.append(str(BUILD_EFFECT_TYPES[effect_type_index]))
	_ensure_lottery_effect_cards(cards, BUILD_EFFECT_TYPES, MIN_BUILD_CARDS_PER_ROUND, "build", protected_build)


func _ensure_lottery_effect_cards(cards: Array, effect_types: Array, target_count: int, replacement_type: String, avoid_effects: Array) -> void:
	var current_count: int = _count_lottery_effects(cards, effect_types)
	while current_count < target_count:
		var replacement: Dictionary = _make_lottery_replacement_card(replacement_type)
		var replace_index: int = _find_lottery_replace_index(cards, avoid_effects)
		if replace_index < 0:
			return

		cards[replace_index] = replacement
		current_count += 1


func _count_lottery_effects(cards: Array, effect_types: Array) -> int:
	var count: int = 0
	for card_item in cards:
		var card: Dictionary = card_item as Dictionary
		if effect_types.has(str(card.get("effect_type", ""))):
			count += 1
	return count


func _find_lottery_replace_index(cards: Array, avoid_effects: Array) -> int:
	if cards.is_empty():
		return -1

	var candidates: Array[int] = []
	for i in range(cards.size()):
		var card: Dictionary = cards[i] as Dictionary
		if bool(card.get("identity_special", false)):
			continue
		if avoid_effects.has(str(card.get("effect_type", ""))):
			continue
		candidates.append(i)

	if candidates.is_empty():
		return rng.randi_range(0, cards.size() - 1)
	return candidates[rng.randi_range(0, candidates.size() - 1)]


func _make_lottery_replacement_card(replacement_type: String) -> Dictionary:
	var ji_yuan_stat: int = _current_lottery_luck_stat()
	var card: Dictionary = {}
	match replacement_type:
		"cultivation":
			card = generate_cultivation_ji_yuan(ji_yuan_stat)
			card["type"] = "机缘"
		"build":
			card = _generate_build_ji_yuan(ji_yuan_stat)
			card["type"] = "机缘"
		"auction":
			card = _generate_specific_ji_yuan(ji_yuan_stat, "auction")
			card["type"] = "机缘"
		"enemy":
			card = generate_enemy_calamity(ji_yuan_stat)
			card["type"] = "灾厄"
		_:
			card = _generate_single_lottery_card()
	card["settled"] = false
	return card


func _current_lottery_luck_stat() -> int:
	return maxi(int(player_a.stats.get("机缘", 0)), int(player_b.stats.get("机缘", 0)))


func _generate_single_lottery_card() -> Dictionary:
	var ji_yuan_stat: int = _current_lottery_luck_stat()
	var identity_context: Dictionary = _identity_special_card_context()
	if not identity_context.is_empty() and rng.randf() < float(identity_context.get("chance", 0.0)):
		var identity_card: Dictionary = _generate_identity_specific_ji_yuan(ji_yuan_stat, str(identity_context.get("sect", "")), int(identity_context.get("peer_id", 0)))
		identity_card["type"] = "机缘"
		identity_card["settled"] = false
		return identity_card
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
	var name_a: String = player_a.player_name if player_a != null else "甲方"
	var name_b: String = player_b.player_name if player_b != null else "乙方"
	if effect_type in ["technique", "treasure", "dan", "alchemy_material", "craft_material", "companion", "auction", "quest", "enemy", "tribulation"] and base_value <= 0.0:
		base_value = 1.0
	result_a["card"] = card.duplicate(true)
	result_b["card"] = card.duplicate(true)
	if bool(card.get("identity_special", false)):
		return _settle_identity_special_card(choice_a, choice_b, card, result_a, result_b)

	if card_type == "机缘":
		if choice_a == "抢" and choice_b == "抢":
			result_a["special"] = "天道反噬！机缘消散"
			result_b["special"] = "天道反噬！机缘消散"
			result_a["log"] = result_a["special"]
			result_b["log"] = result_a["special"]
		elif choice_a == "让" and choice_b == "让":
			if _is_dissipating_shared_opportunity(effect_type):
				var compensation: Dictionary = _shared_dissolve_compensation(effect_type, str(card.get("quality", "炼气级")))
				result_a["compensation_ling_shi"] = int(compensation.get("a", 0))
				result_b["compensation_ling_shi"] = int(compensation.get("b", 0))
				result_a["special"] = "无法平分，机缘消散"
				result_b["special"] = result_a["special"]
			else:
				var split_gain: Dictionary = _split_shared_gain(card, base_value)
				result_a["gain"] = float(split_gain.get("a", 0.0))
				result_b["gain"] = float(split_gain.get("b", 0.0))
				result_a["special"] = "天道酬和，各得一半"
				result_b["special"] = result_a["special"]
			result_a["log"] = result_a["special"]
			result_b["log"] = result_a["special"]
		elif choice_a == "抢" and choice_b == "让":
			result_a["gain"] = base_value
			result_a["special"] = "你拿下这张"
			result_b["special"] = "他拿下这张"
			result_a["log"] = name_a + "拿下这张"
			result_b["log"] = result_a["log"]
		else:
			result_b["gain"] = base_value
			result_a["special"] = "他拿下这张"
			result_b["special"] = "你拿下这张"
			result_a["log"] = name_b + "拿下这张"
			result_b["log"] = result_a["log"]
	else:
		if choice_a == "抢" and choice_b == "抢":
			result_a["lose"] = base_value
			result_b["lose"] = base_value
			result_a["special"] = "劫气入体，运功承受" if not _should_contest_calamity(card) else "双双避劫，劫气反噬！"
			result_b["special"] = result_a["special"]
			result_a["log"] = result_a["special"]
			result_b["log"] = result_a["special"]
		elif choice_a == "让" and choice_b == "让":
			result_a["lose"] = base_value * 0.5
			result_b["lose"] = base_value * 0.5
			result_a["special"] = "同舟共济，共担灾厄"
			result_b["special"] = result_a["special"]
			result_a["log"] = result_a["special"]
			result_b["log"] = result_a["special"]
		elif choice_a == "抢" and choice_b == "让":
			result_b["lose"] = base_value
			result_a["special"] = "避劫成功"
			result_b["special"] = "独承劫气"
			result_a["log"] = name_a + "避开劫气，" + name_b + "独承劫气"
			result_b["log"] = result_a["log"]
		else:
			result_a["lose"] = base_value
			result_a["special"] = "独承劫气"
			result_b["special"] = "避劫成功"
			result_a["log"] = name_b + "避开劫气，" + name_a + "独承劫气"
			result_b["log"] = result_a["log"]
	return {
		"player_a": result_a,
		"player_b": result_b,
		"player_a_result": result_a,
		"player_b_result": result_b,
	}


func _settle_identity_special_card(choice_a: String, choice_b: String, card: Dictionary, result_a: Dictionary, result_b: Dictionary) -> Dictionary:
	var sect_name: String = str(card.get("identity_sect", "宗门"))
	var tier: String = _roll_identity_special_tier()
	result_a["sect_special_tier"] = tier
	result_b["sect_special_tier"] = tier
	result_a["sect_special_role"] = "none"
	result_b["sect_special_role"] = "none"
	result_a["sect_special_sect"] = sect_name
	result_b["sect_special_sect"] = sect_name
	if choice_a == "抢" and choice_b == "抢":
		var backlash_text: String = "天道反噬，" + sect_name + "专属卡毁去"
		_assign_identity_special_result(result_a, "weakened", tier, sect_name, backlash_text, false, true)
		_assign_identity_special_result(result_b, "weakened", tier, sect_name, backlash_text, false, true)
		return {
			"player_a": result_a,
			"player_b": result_b,
			"player_a_result": result_a,
			"player_b_result": result_b,
		}

	var matches_a: bool = _player_matches_identity_special(player_a, card)
	var matches_b: bool = _player_matches_identity_special(player_b, card)
	if matches_a != matches_b:
		var matching_choice: String = choice_a if matches_a else choice_b
		if matching_choice == "让":
			var matching_result: Dictionary = result_a if matches_a else result_b
			var other_result_for_yield: Dictionary = result_b if matches_a else result_a
			var matching_player: PlayerData = player_a if matches_a else player_b
			var matching_name: String = matching_player.player_name if matching_player != null else "修士"
			var yield_text: String = matching_name + "退让承缘，" + sect_name + "专属卡半效入手"
			_assign_identity_special_result(matching_result, "half", tier, sect_name, yield_text, true, false)
			other_result_for_yield["special"] = yield_text
			other_result_for_yield["log"] = yield_text
			return {
				"player_a": result_a,
				"player_b": result_b,
				"player_a_result": result_a,
				"player_b_result": result_b,
			}

	var receiver_key: String = _identity_special_receiver_key(choice_a, choice_b, card)
	var receiver_result: Dictionary = result_a if receiver_key == "a" else result_b
	var other_result: Dictionary = result_b if receiver_key == "a" else result_a
	var receiver_player: PlayerData = player_a if receiver_key == "a" else player_b
	var receiver_choice: String = choice_a if receiver_key == "a" else choice_b
	var receiver_name: String = receiver_player.player_name if receiver_player != null else ("甲方" if receiver_key == "a" else "乙方")
	var matches: bool = _player_matches_identity_special(receiver_player, card)
	var role: String = "weakened"
	if matches:
		role = "enhanced" if receiver_choice == "抢" else "half"
	var result_text: String = ""
	match role:
		"enhanced":
			result_text = receiver_name + "引动" + sect_name + "宗门专属卡"
		"half":
			result_text = receiver_name + "退让承缘，" + sect_name + "专属卡半效入手"
		_:
			result_text = receiver_name + "强夺" + sect_name + "专属卡，灵机折损"
	_assign_identity_special_result(receiver_result, role, tier, sect_name, result_text, true, false)
	other_result["special"] = result_text
	other_result["log"] = result_text
	return {
		"player_a": result_a,
		"player_b": result_b,
		"player_a_result": result_a,
		"player_b_result": result_b,
	}


func _assign_identity_special_result(result: Dictionary, role: String, tier: String, sect_name: String, text: String, receiver: bool, backlash: bool) -> void:
	result["gain"] = 1.0
	result["sect_special_role"] = role
	result["sect_special_tier"] = tier
	result["sect_special_sect"] = sect_name
	result["sect_special_receiver"] = receiver
	result["sect_special_backlash"] = backlash
	result["special"] = text
	result["log"] = text


func _identity_special_receiver_key(choice_a: String, choice_b: String, card: Dictionary) -> String:
	var weight_a: float = _identity_special_player_weight(player_a, choice_a, card)
	var weight_b: float = _identity_special_player_weight(player_b, choice_b, card)
	var total_weight: float = maxf(0.01, weight_a + weight_b)
	return "a" if rng.randf() * total_weight <= weight_a else "b"


func _identity_special_player_weight(player: PlayerData, choice: String, card: Dictionary) -> float:
	var matches: bool = _player_matches_identity_special(player, card)
	if matches and choice == "抢":
		return IDENTITY_SPECIAL_MATCH_GRAB_WEIGHT
	if matches:
		return IDENTITY_SPECIAL_MATCH_YIELD_WEIGHT
	if choice == "抢":
		return IDENTITY_SPECIAL_NONMATCH_GRAB_WEIGHT
	return IDENTITY_SPECIAL_NONMATCH_YIELD_WEIGHT


func _player_matches_identity_special(player: PlayerData, card: Dictionary) -> bool:
	if player == null:
		return false
	check_set_bonus(player)
	var sect_name: String = str(card.get("identity_sect", ""))
	var target_peer_id: int = int(card.get("identity_peer_id", 0))
	if target_peer_id > 0 and player.peer_id != target_peer_id:
		return false
	return SECT_TYPES.has(sect_name) and str(player.final_attributes.get("identity_sect", "")) == sect_name


func _roll_identity_special_tier() -> String:
	var roll: float = rng.randf()
	if roll < 0.50:
		return "ling_li"
	if roll < 0.80:
		return "growth"
	if roll < 0.95:
		return "resource"
	return "function"


func _normalize_shared_gain(card: Dictionary, value: float) -> float:
	if value <= 0.0:
		return 0.0
	var effect_type: String = str(card.get("effect_type", ""))
	if effect_type == "shou_yuan":
		return maxf(1.0, round(value))
	return value


func _is_indivisible_opportunity(effect_type: String) -> bool:
	return effect_type in ["technique", "treasure", "companion", "dan", "alchemy_material", "craft_material", "quest"]


func _is_dissipating_shared_opportunity(effect_type: String) -> bool:
	return effect_type in ["technique", "treasure", "companion", "dan", "alchemy_material", "craft_material"]


func _shared_dissolve_compensation(effect_type: String, quality: String) -> Dictionary:
	var base_by_type: Dictionary = {
		"technique": 200,
		"treasure": 150,
		"companion": 100,
		"dan": 100,
		"alchemy_material": 80,
		"craft_material": 80,
	}
	var base_amount: int = int(round(_quality_power(quality) * float(base_by_type.get(effect_type, 0))))
	var amount_a: int = base_amount
	var amount_b: int = base_amount
	var charm_a: int = _effective_charm(player_a)
	var charm_b: int = _effective_charm(player_b)
	if charm_a > charm_b:
		amount_a = int(round(float(base_amount) * 1.10))
	elif charm_b > charm_a:
		amount_b = int(round(float(base_amount) * 1.10))
	return {"a": amount_a, "b": amount_b}


func _shared_item_receiver_key() -> String:
	var charm_a: int = _effective_charm(player_a)
	var charm_b: int = _effective_charm(player_b)
	if charm_a == charm_b:
		return "a" if rng.randf() < 0.5 else "b"
	var total_charm: float = float(maxi(1, charm_a + charm_b))
	var chance_a: float = clampf(0.5 + float(charm_a - charm_b) / total_charm * 0.25, 0.25, 0.75)
	return "a" if rng.randf() < chance_a else "b"


func _split_shared_gain(card: Dictionary, base_value: float) -> Dictionary:
	var effect_type: String = str(card.get("effect_type", ""))
	if effect_type in ["shou_yuan", "stat_up"]:
		return _split_integer_amount(maxi(1, int(round(base_value))), _get_charm_share(true), true)
	var share_a: float = _get_charm_share(true)
	return {
		"a": maxf(0.0, base_value * share_a),
		"b": maxf(0.0, base_value * (1.0 - share_a)),
	}


func _split_shared_penalty(card: Dictionary, base_value: float) -> Dictionary:
	var effect_type: String = str(card.get("effect_type", ""))
	var reduced_value: float = base_value * 0.5
	if effect_type == "shou_yuan_loss":
		return _split_integer_amount(maxi(1, int(round(reduced_value))), _get_charm_share(false), true)
	var share_a: float = _get_charm_share(false)
	return {
		"a": maxf(0.0, reduced_value * share_a),
		"b": maxf(0.0, reduced_value * (1.0 - share_a)),
	}


func _split_integer_amount(total_amount: int, share_a: float, prefer_nonzero_both: bool) -> Dictionary:
	var total: int = maxi(0, total_amount)
	if total <= 0:
		return {"a": 0.0, "b": 0.0}
	if total == 1:
		return {"a": 1.0, "b": 0.0} if rng.randf() < share_a else {"a": 0.0, "b": 1.0}
	var clamped_share: float = clampf(share_a, 0.0, 1.0)
	var amount_a: int = int(floor(float(total) * clamped_share))
	if total % 2 == 1 and absf(clamped_share - 0.5) < 0.01:
		amount_a = int(floor(float(total) * 0.5)) + (1 if rng.randf() < 0.5 else 0)
	if prefer_nonzero_both:
		amount_a = clampi(amount_a, 1, total - 1)
	else:
		amount_a = clampi(amount_a, 0, total)
	return {"a": float(amount_a), "b": float(total - amount_a)}


func _apply_karmic_backlash(player: PlayerData, result: Dictionary, card: Dictionary, base_value: float, choice: String) -> void:
	if player == null or choice != "抢":
		return
	var effect_type: String = str(card.get("effect_type", ""))
	if effect_type in ["enemy", "tribulation"]:
		return
	if player.karmic_debt < KARMA_BACKLASH_THRESHOLD:
		return
	var backlash_rate: float = clampf(0.08 + float(player.karmic_debt) * 0.035, 0.0, 0.42)
	var backlash_value: float = maxf(1.0, base_value * backlash_rate)
	result["lose"] = float(result.get("lose", 0.0)) + backlash_value
	_append_result_message(result, "special", "因果缠身，躲灾也被反噬")


func apply_bargain_result(player: PlayerData, result: Dictionary) -> void:
	if player == null:
		return

	var card: Dictionary = result.get("card", {}) as Dictionary
	var gain: float = float(result.get("gain", 0.0))
	var lose: float = float(result.get("lose", 0.0))
	var compensation_ling_shi: int = int(result.get("compensation_ling_shi", 0))
	if bool(card.get("identity_special", false)):
		var special_message: String = _apply_identity_special_result(player, result, card)
		if special_message != "":
			result["gain_message"] = special_message
	else:
		if compensation_ling_shi > 0:
			player.ling_shi += compensation_ling_shi
			_append_result_message(result, "gain_message", "灵石补偿 +" + str(compensation_ling_shi))
		if str(card.get("type", "")) == "机缘" and gain > 0.0:
			_append_result_message(result, "gain_message", _apply_ji_yuan(player, card, gain, str(result.get("choice", ""))))
		if str(card.get("type", "")) == "灾厄" and lose > 0.0:
			var reduction_message: String = _apply_emotion_school_calamity_reduction(player, result)
			var formation_message: String = _apply_formation_calamity_reduction(player, result)
			lose = float(result.get("lose", lose))
			var hp_before_calamity: int = player.qi_xue
			result["lose_message"] = _apply_calamity(player, card, lose)
			var card_hp_damage: int = maxi(0, hp_before_calamity - player.qi_xue)
			if card_hp_damage > 0:
				result["hp_damage_taken"] = int(result.get("hp_damage_taken", 0)) + card_hp_damage
			if reduction_message != "":
				_append_result_message(result, "lose_message", reduction_message)
			if formation_message != "":
				_append_result_message(result, "lose_message", formation_message)
		var emotion_message: String = _apply_emotion_school_bargain_bonus(player, result, card)
		if emotion_message != "":
			var target_key: String = "gain_message" if str(card.get("type", "")) == "机缘" else "lose_message"
			_append_result_message(result, target_key, emotion_message)
		var identity_message: String = _apply_identity_bargain_passive(player, result, card)
		if identity_message != "":
			var identity_key: String = "gain_message" if str(card.get("type", "")) == "机缘" else "lose_message"
			_append_result_message(result, identity_key, identity_message)
		var growth_message: String = _apply_build_growth_from_bargain(player, result, card, gain, lose)
		if growth_message != "":
			var growth_key: String = "gain_message" if str(card.get("type", "")) == "机缘" else "lose_message"
			_append_result_message(result, growth_key, growth_message)

	player.total_qiang_count += 1 if result.get("choice", "") == "抢" else 0
	player.total_rang_count += 1 if result.get("choice", "") == "让" else 0
	_update_pressure_tracks(player, result, card, gain, lose)
	var special_text: String = str(result.get("special", ""))
	if special_text.contains("天道反噬") or special_text.contains("双双躲避"):
		player.total_shuang_qiang += 1
	elif special_text.contains("天道酬和") or special_text.contains("共同承担") or special_text.contains("同舟共济"):
		player.total_shuang_rang += 1


func _apply_identity_special_result(player: PlayerData, result: Dictionary, card: Dictionary) -> String:
	var role: String = str(result.get("sect_special_role", "none"))
	if role == "" or role == "none":
		return ""
	var tier: String = str(result.get("sect_special_tier", card.get("sect_special_tier", "ling_li")))
	var sect_name: String = str(card.get("identity_sect", result.get("sect_special_sect", "宗门")))
	var reward_multiplier: float = 2.0 if bool(result.get("sect_special_double", false)) else 1.0
	player.total_ji_yuan_gained += 1
	player.ji_yuan_list.append(card.duplicate(true))
	var message: String = ""
	match tier:
		"ling_li":
			message = _apply_identity_special_ling_li(player, role, sect_name, reward_multiplier)
		"growth":
			message = _apply_identity_special_growth(player, role, sect_name, reward_multiplier)
		"resource":
			message = _apply_identity_special_resource(player, role, sect_name, reward_multiplier)
		"function":
			message = _apply_identity_special_function(player, role, sect_name, reward_multiplier)
		_:
			message = _apply_identity_special_ling_li(player, role, sect_name, reward_multiplier)
	if reward_multiplier > 1.0:
		message += "；" + WEAK_COMEBACK_TEXT
	return message


func _identity_special_scale(role: String) -> float:
	if role == "half":
		return 0.5
	return 1.0


func _apply_identity_special_ling_li(player: PlayerData, role: String, sect_name: String, reward_multiplier: float = 1.0) -> String:
	var amount: int = 30 if role == "weakened" else int(round(80.0 * _identity_special_scale(role)))
	amount = maxi(1, int(round(float(amount) * reward_multiplier)))
	var before_stage: String = get_cultivation_stage_name(player)
	player.ling_li += amount
	var message: String = sect_name + "专属卡：灵力 +" + str(amount)
	message = _append_stage_change_to_message(player, before_stage, message)
	var sword_message: String = _add_growth_sword_exp(player, maxi(1, int(round(float(amount) / 20.0))), "宗门专属")
	if sword_message != "":
		message += "；" + sword_message
	return message


func _apply_identity_special_growth(player: PlayerData, role: String, sect_name: String, reward_multiplier: float = 1.0) -> String:
	if role == "weakened":
		var weak_treasure_message: String = grow_treasure(player, maxi(1, int(round(reward_multiplier))))
		if weak_treasure_message != "":
			return sect_name + "专属卡：" + weak_treasure_message
		return _apply_identity_special_ling_li(player, "weakened", sect_name, reward_multiplier)

	var amount: int = maxi(1, int(round(3.0 * _identity_special_scale(role) * reward_multiplier)))
	var technique: Dictionary = _find_first_upgradeable_technique(player)
	var prefer_treasure: bool = rng.randf() < 0.5 or technique.is_empty()
	if prefer_treasure:
		var treasure_message: String = grow_treasure(player, amount)
		if treasure_message != "":
			return sect_name + "专属卡：" + treasure_message
	if not technique.is_empty():
		return sect_name + "专属卡：" + _add_technique_fragment_progress(player, technique, maxi(1, int(round(reward_multiplier))), "宗门专属")
	var fallback_message: String = grow_treasure(player, amount)
	if fallback_message != "":
		return sect_name + "专属卡：" + fallback_message
	return _apply_identity_special_ling_li(player, role, sect_name, reward_multiplier)


func _apply_identity_special_resource(player: PlayerData, role: String, sect_name: String, reward_multiplier: float = 1.0) -> String:
	if role == "weakened":
		var weak_stones: int = maxi(1, int(round(200.0 * reward_multiplier)))
		player.ling_shi += weak_stones
		return sect_name + "专属卡：灵石 +" + str(weak_stones)
	var scale: float = _identity_special_scale(role) * reward_multiplier
	match rng.randi_range(0, 2):
		0:
			var stones: int = maxi(1, int(round(500.0 * scale)))
			var max_hp: int = _get_player_max_hp(player)
			var old_hp: int = player.qi_xue
			var heal_amount: int = maxi(1, int(round(float(max_hp) * 0.15 * scale)))
			player.ling_shi += stones
			player.qi_xue = mini(max_hp, player.qi_xue + heal_amount)
			var message: String = sect_name + "专属卡：灵石 +" + str(stones) + "，气血 +" + str(player.qi_xue - old_hp)
			if player.qi_xue > old_hp:
				var heal_growth_message: String = _grow_treasure_for_cultivation(player, "丹修", 1)
				if heal_growth_message != "":
					message += "；" + heal_growth_message
				var heal_technique_message: String = _grow_techniques_for_cultivation(player, "丹修", 1, "回春运功")
				if heal_technique_message != "":
					message += "；" + heal_technique_message
			return message
		1:
			var years: int = maxi(1, int(round(3.0 * scale)))
			player.shou_yuan += years
			return sect_name + "专属卡：寿元 +" + str(years)
		_:
			return sect_name + "专属卡：" + _grant_breakthrough_dan(player)


func _apply_identity_special_function(player: PlayerData, role: String, sect_name: String, reward_multiplier: float = 1.0) -> String:
	if role == "weakened":
		var before_stage: String = get_cultivation_stage_name(player)
		var weak_ling_li: int = maxi(1, int(round(80.0 * reward_multiplier)))
		player.ling_li += weak_ling_li
		return _append_stage_change_to_message(player, before_stage, sect_name + "专属卡：灵力 +" + str(weak_ling_li))
	if role == "half":
		var half_message: String = ""
		if rng.randf() < 0.5:
			half_message = _half_awaken_equipped_treasure(player)
			if half_message == "":
				half_message = _half_random_equipped_companion_bond(player)
		else:
			half_message = _half_random_equipped_companion_bond(player)
			if half_message == "":
				half_message = _half_awaken_equipped_treasure(player)
		if half_message != "":
			return sect_name + "专属卡：" + half_message
		return _apply_identity_special_ling_li(player, role, sect_name, reward_multiplier)
	var message: String = ""
	if rng.randf() < 0.5:
		message = _awaken_equipped_treasure_now(player)
		if message == "":
			message = _max_random_equipped_companion_bond(player)
	else:
		message = _max_random_equipped_companion_bond(player)
		if message == "":
			message = _awaken_equipped_treasure_now(player)
	if message != "":
		return sect_name + "专属卡：" + message
	return _apply_identity_special_ling_li(player, role, sect_name, reward_multiplier)


func _awaken_equipped_treasure_now(player: PlayerData) -> String:
	if player == null:
		return ""
	var treasure: Dictionary = _get_equipped_treasure(player)
	if treasure.is_empty():
		return ""
	_prepare_treasure(treasure, _player_sect(player))
	if int(treasure.get("awakening_level", 0)) > 0 or bool(treasure.get("awakened", false)):
		return ""
	var old_value: int = int(treasure.get("growth_value", 0))
	var threshold: int = int(treasure.get("awaken_threshold", treasure.get("growth_max", 10)))
	var growth_type: String = _treasure_growth_type(treasure)
	var new_value: int = maxi(old_value, threshold)
	if growth_type == "器修":
		new_value += 5
	treasure["growth_value"] = new_value
	treasure["awakening_level"] = 1
	treasure["awakened"] = true
	treasure["growth_changed"] = true
	if _quality_rank(str(treasure.get("quality", "炼气级"))) >= _quality_rank("化神级"):
		var extra_effect: String = _roll_treasure_extra_effect(treasure)
		if extra_effect != "":
			var extra_effects: Array = treasure.get("extra_attack_effects", []) as Array
			extra_effects.append(extra_effect)
			treasure["extra_attack_effects"] = extra_effects
	_refresh_treasure_growth_bonus(treasure)
	var awaken_skill: Dictionary = treasure.get("awakening_skill", {}) as Dictionary
	var message: String = "法宝【" + str(treasure.get("name", "法宝")) + "】立刻觉醒：" + str(awaken_skill.get("name", "觉醒技"))
	var extras: Array = treasure.get("extra_attack_effects", []) as Array
	if not extras.is_empty():
		message += "，附加" + str(extras[extras.size() - 1])
	return message


func _half_awaken_equipped_treasure(player: PlayerData) -> String:
	if player == null:
		return ""
	var treasure: Dictionary = _get_equipped_treasure(player)
	if treasure.is_empty():
		return ""
	_prepare_treasure(treasure, _player_sect(player))
	if int(treasure.get("awakening_level", 0)) > 0 or bool(treasure.get("awakened", false)):
		return ""
	var current_value: int = int(treasure.get("growth_value", 0))
	var threshold: int = int(treasure.get("awaken_threshold", treasure.get("growth_max", 10)))
	if current_value >= threshold:
		return _awaken_equipped_treasure_now(player)
	var amount: int = maxi(1, int(ceil(float(threshold - current_value) * 0.5)))
	var message: String = grow_treasure(player, amount)
	return message if message == "" else "半效助长，" + message


func _max_random_equipped_companion_bond(player: PlayerData) -> String:
	if player == null:
		return ""
	var candidates: Array[Dictionary] = []
	for companion in player.companions:
		if not companion is Dictionary:
			continue
		var companion_data: Dictionary = companion as Dictionary
		if int(companion_data.get("bond", 0)) < _companion_bond_max(companion_data):
			candidates.append(companion_data)
	if candidates.is_empty():
		return ""
	var target: Dictionary = candidates[rng.randi_range(0, candidates.size() - 1)]
	var target_name: String = str(target.get("name", "伙伴"))
	var amount: int = maxi(1, _companion_bond_max(target) - int(target.get("bond", 0)))
	return grow_bond(player, target_name, amount)


func _half_random_equipped_companion_bond(player: PlayerData) -> String:
	if player == null:
		return ""
	var candidates: Array[Dictionary] = []
	for companion in player.companions:
		if not companion is Dictionary:
			continue
		var companion_data: Dictionary = companion as Dictionary
		if int(companion_data.get("bond", 0)) < _companion_bond_max(companion_data):
			candidates.append(companion_data)
	if candidates.is_empty():
		return ""
	var target: Dictionary = candidates[rng.randi_range(0, candidates.size() - 1)]
	var target_name: String = str(target.get("name", "伙伴"))
	var remaining: int = maxi(1, _companion_bond_max(target) - int(target.get("bond", 0)))
	var amount: int = maxi(1, int(ceil(float(remaining) * 0.5)))
	var message: String = grow_bond(player, target_name, amount)
	return message if message == "" else "半效结缘，" + message


func _update_pressure_tracks(player: PlayerData, result: Dictionary, card: Dictionary, gain: float, lose: float) -> void:
	if player == null:
		return
	var choice: String = str(result.get("choice", ""))
	if choice == "抢":
		player.qiang_streak += 1
		var debt_gain: int = 1 + (1 if player.qiang_streak >= 3 else 0)
		player.karmic_debt = clampi(player.karmic_debt + debt_gain, 0, MAX_KARMIC_DEBT)
	else:
		player.qiang_streak = 0
		var patience_gain: int = 1
		if str(card.get("type", "")) == "灾厄" and lose > 0.0:
			patience_gain += 1
			player.karmic_debt = maxi(0, player.karmic_debt - 1)
		if str(card.get("type", "")) == "机缘" and gain <= 0.0:
			patience_gain += 1
		player.forbearance = clampi(player.forbearance + patience_gain, 0, MAX_FORBEARANCE)


func _apply_build_growth_from_bargain(player: PlayerData, result: Dictionary, card: Dictionary, gain: float, lose: float) -> String:
	if player == null:
		return ""
	var choice: String = str(result.get("choice", ""))
	var card_type: String = str(card.get("type", ""))
	var growth_amount: int = 0
	var treasure: Dictionary = _get_equipped_treasure(player)
	var growth_type: String = ""
	if not treasure.is_empty():
		_prepare_treasure(treasure, _player_sect(player))
		growth_type = _treasure_growth_type(treasure)
	match growth_type:
		"鬼修":
			if choice == "抢" and card_type == "机缘" and gain > 0.0:
				growth_amount += 1
		"情修":
			if choice == "让":
				var special_text: String = str(result.get("special", ""))
				if special_text.contains("天道酬和") or special_text.contains("共同承担"):
					growth_amount += 2
				elif card_type == "灾厄" and lose > 0.0:
					growth_amount += 2
				else:
					growth_amount += 1
		"体修":
			var card_hp_damage_taken: int = int(result.get("hp_damage_taken", 0))
			if card_type == "灾厄" and card_hp_damage_taken > 0:
				growth_amount += maxi(1, int(floor(float(card_hp_damage_taken) / 10.0)))
		"符修":
			if card_type == "灾厄" and choice == "抢":
				growth_amount += 1
	var effect_type: String = str(card.get("effect_type", ""))
	var messages: Array[String] = []
	var treasure_message: String = grow_treasure(player, growth_amount)
	if treasure_message != "":
		messages.append(treasure_message)
	var ghost_route_level: int = _cultivation_route_level(player, "鬼修")
	if ghost_route_level >= 1 and card_type == "机缘" and choice == "抢" and gain > 0.0:
		var ghost_gain: int = 2 + ghost_route_level
		player.final_attributes["ghost_power"] = int(player.final_attributes.get("ghost_power", 0)) + ghost_gain
		messages.append("役鬼吞缘，鬼魂+" + str(ghost_gain))
	var emotion_route_level: int = _cultivation_route_level(player, "情修")
	if emotion_route_level >= 1 and choice == "让":
		var heart_gain: int = 4 + emotion_route_level * 3 + int(round(_cultivation_route_strength(player, "情修") * 2.0))
		var current_heart: int = int(player.final_attributes.get("heart_guard", 0))
		var max_heart: int = 24 + emotion_route_level * 10
		player.final_attributes["heart_guard"] = clampi(current_heart + heart_gain, 0, max_heart)
		messages.append("红尘护心+" + str(heart_gain))
	var dan_route_level: int = _cultivation_route_level(player, "丹修")
	if dan_route_level >= 1 and effect_type == "dan" and gain > 0.0:
		var reserve: int = clampi(int(player.final_attributes.get("dan_life_reserve", 0)) + 1, 0, 3 + dan_route_level)
		player.final_attributes["dan_life_reserve"] = reserve
		messages.append("丹炉蓄火+" + str(reserve))
	var technique_growth_messages: Array[String] = []
	if card_type == "机缘" and choice == "抢" and gain > 0.0:
		technique_growth_messages.append(_grow_techniques_for_cultivation(player, "鬼修", 1, "夺机缘"))
	if card_type == "机缘" and choice == "让":
		technique_growth_messages.append(_grow_techniques_for_cultivation(player, "情修", 1, "让机缘"))
	if card_type == "灾厄" and choice == "让" and lose > 0.0:
		technique_growth_messages.append(_grow_techniques_for_cultivation(player, "体修", 1, "承厄炼体"))
		technique_growth_messages.append(_grow_techniques_for_cultivation(player, "阵修", 1, "布阵承厄"))
		technique_growth_messages.append(_grow_techniques_for_cultivation(player, "情修", 1, "护道承厄"))
	if card_type == "灾厄" and choice == "抢":
		technique_growth_messages.append(_grow_techniques_for_cultivation(player, "符修", 1, "遁符避厄"))
	if effect_type == "dan" and gain > 0.0:
		technique_growth_messages.append(_grow_techniques_for_cultivation(player, "丹修", 1, "炼丹"))
	for technique_message in technique_growth_messages:
		if technique_message != "":
			messages.append(technique_message)
	var bargain_special_text: String = str(result.get("special", ""))
	if bargain_special_text.contains("天道酬和") or bargain_special_text.contains("共同承担"):
		var double_yield_message: String = _grow_companion_bonds_for_event(player, "double_yield")
		if double_yield_message != "":
			messages.append(double_yield_message)
	if card_type == "机缘" and choice == "让":
		var yield_message: String = _grow_companion_bonds_for_event(player, "yield_fortune")
		if yield_message != "":
			messages.append(yield_message)
	elif card_type == "机缘" and choice == "抢" and gain > 0.0:
		var grab_message: String = _grow_companion_bonds_for_event(player, "grab_fortune")
		if grab_message != "":
			messages.append(grab_message)
	elif card_type == "灾厄" and choice == "让":
		var bear_message: String = _grow_companion_bonds_for_event(player, "bear_tribulation")
		if bear_message != "":
			messages.append(bear_message)
	elif card_type == "灾厄" and choice == "抢":
		var dodge_message: String = _grow_companion_bonds_for_event(player, "dodge_tribulation")
		if dodge_message != "":
			messages.append(dodge_message)
	return "；".join(messages)


func _grow_companion_bonds(player: PlayerData, amount: int) -> String:
	if player == null or amount == 0 or player.companions.is_empty():
		return ""
	var messages: Array[String] = []
	for companion in player.companions:
		if not companion is Dictionary:
			continue
		var companion_data: Dictionary = companion as Dictionary
		var companion_name: String = str(companion_data.get("name", ""))
		if companion_name == "":
			continue
		var message: String = grow_bond(player, companion_name, amount)
		if message != "":
			messages.append(message)
	return "；".join(messages)


func _grow_companion_bonds_for_event(player: PlayerData, event_name: String) -> String:
	if player == null or event_name == "" or player.companions.is_empty():
		return ""
	var messages: Array[String] = []
	for companion in player.companions:
		if not companion is Dictionary:
			continue
		var companion_data: Dictionary = companion as Dictionary
		_prepare_companion(companion_data, player)
		var alignment: String = _companion_alignment(companion_data)
		var rules: Dictionary = COMPANION_BOND_RULES.get(alignment, {}) as Dictionary
		var amount: int = int(rules.get(event_name, 0))
		if amount == 0:
			continue
		if amount > 0:
			amount = maxi(1, int(ceil(float(amount) * COMPANION_BOND_POSITIVE_MULTIPLIER)))
		else:
			amount = mini(-1, int(floor(float(amount) * COMPANION_BOND_NEGATIVE_MULTIPLIER)))
		var companion_name: String = str(companion_data.get("name", ""))
		var message: String = grow_bond_with_source(player, companion_name, amount, _companion_bond_event_label(event_name, alignment, amount))
		if message != "":
			messages.append(message)
	if messages.is_empty():
		return ""
	return "；".join(messages)


func _companion_bond_event_label(event_name: String, alignment: String, amount: int) -> String:
	if amount < 0:
		match event_name:
			"grab_fortune":
				return "生隙"
			"yield_fortune":
				return "离心"
			"bear_tribulation":
				return "疑心"
			"dodge_tribulation":
				return "失望"
			_:
				return "离契"
	match event_name:
		"yield_fortune":
			return "护缘" if alignment == "正" else "藏锋"
		"bear_tribulation":
			return "同劫"
		"double_yield":
			return "同享"
		"grab_fortune":
			return "夺缘"
		"battle_attack":
			return "并刃"
		"enemy_kill":
			return "血誓"
		"dodge_tribulation":
			return "遁劫"
		_:
			return "结缘"


func _append_result_message(result: Dictionary, key: String, message: String) -> void:
	if message == "":
		return
	var old_message: String = str(result.get(key, ""))
	result[key] = message if old_message == "" else old_message + "；" + message


func _apply_emotion_school_calamity_reduction(player: PlayerData, result: Dictionary) -> String:
	var power: float = _emotion_school_power(player)
	if power <= 0.0 or str(result.get("choice", "")) != "让":
		return ""
	var lose: float = float(result.get("lose", 0.0))
	if lose <= 0.0:
		return ""
	var reduction: float = clampf(power * 0.018 + float(player.stats.get("魅力", 0)) * 0.006, 0.0, 0.30)
	if reduction <= 0.0:
		return ""
	result["lose"] = lose * (1.0 - reduction)
	return "情修护心，伤害减轻" + str(int(round(reduction * 100.0))) + "%"


func _apply_formation_calamity_reduction(player: PlayerData, result: Dictionary) -> String:
	var level: int = _cultivation_route_level(player, "阵修")
	if level <= 0 or str(result.get("choice", "")) != "让":
		return ""
	var lose: float = float(result.get("lose", 0.0))
	if lose <= 0.0:
		return ""
	var reduction: float = clampf(0.10 + float(level) * 0.05, 0.0, 0.28)
	result["lose"] = lose * (1.0 - reduction)
	return "阵纹分劫，伤害减轻" + str(int(round(reduction * 100.0))) + "%"


func _apply_emotion_school_bargain_bonus(player: PlayerData, result: Dictionary, card: Dictionary) -> String:
	var power: float = _emotion_school_power(player)
	if power <= 0.0 or str(result.get("choice", "")) != "让":
		return ""
	var charm: int = int(player.stats.get("魅力", 0))
	if str(card.get("type", "")) == "机缘" and float(result.get("gain", 0.0)) > 0.0:
		var before_stage: String = get_cultivation_stage_name(player)
		var amount: int = maxi(1, int(round(power * 6.0 + float(charm) * 2.0)))
		player.ling_li += amount
		return _append_stage_change_to_message(player, before_stage, "情修同心，修为 +" + str(amount))
	if str(card.get("type", "")) == "灾厄" and float(result.get("lose", 0.0)) > 0.0:
		var heal: int = maxi(1, int(round(power * 2.0 + float(charm))))
		var max_hp: int = _get_player_max_hp(player)
		player.qi_xue = mini(max_hp, player.qi_xue + heal)
		return "红尘护念，气血 +" + str(heal)
	return ""


func _get_charm_share(for_gain: bool) -> float:
	var charm_a: int = _effective_charm(player_a)
	var charm_b: int = _effective_charm(player_b)
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
	if current_card_index < 0 or current_card_index >= current_lottery_cards.size():
		bargain_choices.clear()
		return

	var choice: String = str(data.get("choice", ""))
	var index: int = int(data.get("index", current_card_index))
	if index < 0 or index >= current_lottery_cards.size() or index != current_card_index or choice == "":
		return
	var choice_peer_id: int = peer_id
	if choice_peer_id <= 0:
		choice_peer_id = 1
	if has_pending_backpack_item(choice_peer_id):
		var block_data: Dictionary = _backpack_update_data(choice_peer_id, "先处理背包里的新物品")
		NetworkManager.send_message("backpack_updated", block_data)
		on_backpack_updated(block_data)
		return

	var player_key: String = "a" if choice_peer_id == player_a.peer_id else "b"
	bargain_choices[player_key] = choice
	var card: Dictionary = current_lottery_cards[current_card_index]
	if single_player_mode and player_key == "a" and not bargain_choices.has("b"):
		_queue_npc_bargain_choice(card)
	if not bargain_choices.has("a") or not bargain_choices.has("b"):
		return

	if _should_start_card_contest(str(bargain_choices["a"]), str(bargain_choices["b"]), card):
		_start_card_contest(card, str(bargain_choices["a"]), str(bargain_choices["b"]))
		return

	_settle_current_card_bargain(str(bargain_choices["a"]), str(bargain_choices["b"]), card)


func _settle_current_card_bargain(choice_a: String, choice_b: String, card: Dictionary, contest_result: Dictionary = {}) -> void:
	if current_card_index < 0 or current_card_index >= current_lottery_cards.size():
		bargain_choices.clear()
		return
	var settled: Dictionary = settle_card_bargain(choice_a, choice_b, card)
	if not contest_result.is_empty():
		settled = settle_card_bargain(choice_a, choice_b, card)
		_apply_contest_to_settlement(settled, contest_result, card)
		_apply_weak_counter_reward_multiplier(settled, contest_result, card)
	settled["player_a"]["choice"] = choice_a
	settled["player_b"]["choice"] = choice_b
	settled["player_a_result"] = settled["player_a"]
	settled["player_b_result"] = settled["player_b"]
	apply_bargain_result(player_a, settled["player_a"])
	apply_bargain_result(player_b, settled["player_b"])
	if not contest_result.is_empty():
		_apply_contest_after_effects(settled, contest_result, card)
	if single_player_mode:
		var npc_result: Dictionary = settled.get("player_b", {}) as Dictionary
		push_npc_dialogue("result", {
			"gain": float(npc_result.get("gain", 0.0)),
			"lose": float(npc_result.get("lose", 0.0)),
			"desc": str(card.get("desc", "这一张")),
		})
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
		"choice_a": choice_a,
		"choice_b": choice_b,
		"settled": settled,
		"contest_result": contest_result,
		"player_a": _player_snapshot(player_a),
		"player_b": _player_snapshot(player_b),
		"pending_backpack_items": pending_backpack_items.duplicate(true),
		"results": current_lottery_results.duplicate(true),
		"next_index": next_index,
		"round_finished": next_index < 0 or next_index >= current_lottery_cards.size(),
	}
	current_contest.clear()
	NetworkManager.send_message("bargain_settled", data_out)
	on_bargain_settled(data_out)


func _should_start_card_contest(choice_a: String, choice_b: String, card: Dictionary) -> bool:
	if choice_a != "抢" or choice_b != "抢":
		return false
	if bool(card.get("identity_special", false)):
		return false
	if not _has_clear_contest_pressure(card):
		return false
	var card_type: String = str(card.get("type", ""))
	var effect_type: String = str(card.get("effect_type", ""))
	var quality: String = str(card.get("quality", "炼气级"))
	if card_type == "灾厄":
		return _should_contest_calamity(card)
	if effect_type in ["technique", "treasure", "companion", "adventure", "auction", "quest"]:
		return true
	return _quality_rank(quality) >= _quality_rank("金丹级")


func _should_contest_calamity(card: Dictionary) -> bool:
	var effect_type: String = str(card.get("effect_type", ""))
	if effect_type in ["enemy", "tribulation"]:
		return true
	var value: float = absf(float(card.get("effect_value", card.get("value", card.get("base_effect", 0.0)))))
	var quality: String = str(card.get("quality", "炼气级"))
	return value >= CALAMITY_CONTEST_MIN_VALUE or _quality_rank(quality) >= _quality_rank("金丹级")


func _quality_rank(quality: String) -> int:
	match quality:
		"炼气级":
			return 0
		"筑基级":
			return 1
		"金丹级":
			return 2
		"元婴级":
			return 3
		"化神级":
			return 4
		"合体级":
			return 5
		_:
			return 1


func _quality_by_rank(rank: int) -> String:
	return str(QUALITY_ORDER[clampi(rank, 0, QUALITY_ORDER.size() - 1)])


func _contest_power(player: PlayerData, card: Dictionary) -> float:
	return get_visible_combat_power(player)


func _has_clear_contest_pressure(card: Dictionary) -> bool:
	var power_a: float = _contest_power(player_a, card)
	var power_b: float = _contest_power(player_b, card)
	var high_power: float = maxf(power_a, power_b)
	var low_power: float = minf(power_a, power_b)
	var delta: float = high_power - low_power
	var required_delta: float = maxf(CONTEST_POWER_ADVANTAGE_MIN_DELTA, high_power * (CONTEST_POWER_ADVANTAGE_MIN_RATIO - 1.0))
	return delta >= required_delta


func get_visible_combat_power(player: PlayerData) -> float:
	if player == null:
		return 0.0
	var stats: Dictionary = calculate_duel_stats(player)
	return float(stats.get("战力", 0))


func get_visible_combat_power_formula_text() -> String:
	return "战力 = 攻击×2 + 防御 + 当前气血×0.5 + 速度×0.2 + 法宝成长 + 境界战力"


func get_enemy_visible_combat_power(enemy: Dictionary = {}) -> float:
	var enemy_data: Dictionary = enemy if not enemy.is_empty() else current_enemy
	if enemy_data.is_empty():
		return 0.0
	var active_targets: int = 2
	if current_state == GameState.BATTLE:
		active_targets = maxi(1, _active_battle_player_count())
	var attack_value: float = float(enemy_data.get("attack", 0))
	var hp_value: float = float(enemy_data.get("hp", enemy_data.get("max_hp", 0)))
	return attack_value * 2.0 * float(active_targets) + hp_value * 0.5


func _combat_power_score(player: PlayerData) -> float:
	return get_visible_combat_power(player)


func _is_weaker_combatant(player: PlayerData, opponent: PlayerData) -> bool:
	if player == null or opponent == null:
		return false
	return _combat_power_score(player) + 0.01 < _combat_power_score(opponent)


func _start_card_contest(card: Dictionary, choice_a: String, choice_b: String) -> void:
	var power_a: float = _contest_power(player_a, card)
	var power_b: float = _contest_power(player_b, card)
	var weak_key: String = "a" if power_a < power_b else "b"
	var strong_key: String = "b" if weak_key == "a" else "a"
	current_contest = {
		"index": current_card_index,
		"card": card.duplicate(true),
		"choice_a": choice_a,
		"choice_b": choice_b,
		"weak_key": weak_key,
		"strong_key": strong_key,
		"power_a": power_a,
		"power_b": power_b,
	}
	current_contest["counter_chance"] = _contest_weak_counter_chance(card)
	var data: Dictionary = current_contest.duplicate(true)
	data["player_a"] = _player_snapshot(player_a)
	data["player_b"] = _player_snapshot(player_b)
	change_state(GameState.CONTEST)
	NetworkManager.send_message("contest_started", data)
	on_contest_started(data)


func _contest_pressure_stacks(player: PlayerData) -> int:
	if player == null:
		return 0
	return maxi(0, int(player.forbearance) - 2)


func on_contest_started(data: Dictionary) -> void:
	current_contest = data.duplicate(true)
	_apply_player_snapshot(player_a, data.get("player_a", {}) as Dictionary)
	_apply_player_snapshot(player_b, data.get("player_b", {}) as Dictionary)
	change_state(GameState.CONTEST)
	contest_started.emit(data)
	if single_player_mode and str(current_contest.get("weak_key", "")) == "b":
		_queue_npc_contest_decision()


func on_contest_choice_received(peer_id: int, data: Dictionary) -> void:
	if not NetworkManager.is_host:
		return
	if current_state != GameState.CONTEST or current_contest.is_empty():
		return
	var weak_key: String = str(current_contest.get("weak_key", "a"))
	var weak_player: PlayerData = player_a if weak_key == "a" else player_b
	var action_peer_id: int = peer_id
	if action_peer_id <= 0:
		action_peer_id = 1
	if weak_player == null or action_peer_id != weak_player.peer_id:
		return
	var mode: String = str(data.get("mode", "yield"))
	if mode != "fight":
		mode = "yield"
	_resolve_current_contest(mode)


func _resolve_current_contest(mode: String) -> void:
	var card: Dictionary = (current_contest.get("card", {}) as Dictionary).duplicate(true)
	var weak_key: String = str(current_contest.get("weak_key", "a"))
	var strong_key: String = str(current_contest.get("strong_key", "b"))
	var winner_key: String = strong_key
	var loser_key: String = weak_key
	var message: String = ""
	if mode == "fight":
		winner_key = _roll_contest_winner_key(card)
		loser_key = "b" if winner_key == "a" else "a"
		var winner_name: String = _player_by_key(winner_key).player_name
		var loser_name: String = _player_by_key(loser_key).player_name
		if str(card.get("type", "")) == "灾厄":
			message = loser_name + "强行转劫，双方斗法；" + winner_name + "胜出"
		else:
			message = loser_name + "不肯退让，双方争道；" + winner_name + "胜出"
	else:
		if str(card.get("type", "")) == "灾厄":
			message = _player_by_key(weak_key).player_name + "选择承担，少受一点"
		else:
			message = _player_by_key(weak_key).player_name + "选择放弃，避开一场恶斗"

	var card_type: String = str(card.get("type", ""))
	var choice_a: String = "抢"
	var choice_b: String = "抢"
	if card_type == "机缘":
		choice_a = "抢" if winner_key == "a" else "让"
		choice_b = "抢" if winner_key == "b" else "让"
	else:
		choice_a = "让" if loser_key == "a" else "抢"
		choice_b = "让" if loser_key == "b" else "抢"

	var contest_result: Dictionary = {
		"mode": mode,
		"weak_key": weak_key,
		"strong_key": strong_key,
		"winner_key": winner_key,
		"loser_key": loser_key,
		"message": message,
		"comeback": winner_key == weak_key,
		"power_a": float(current_contest.get("power_a", 0.0)),
		"power_b": float(current_contest.get("power_b", 0.0)),
		"counter_chance": float(current_contest.get("counter_chance", _contest_weak_counter_chance(card))),
	}
	_settle_current_card_bargain(choice_a, choice_b, card, contest_result)


func _roll_contest_winner_key(card: Dictionary) -> String:
	var weak_key: String = str(current_contest.get("weak_key", ""))
	var strong_key: String = str(current_contest.get("strong_key", ""))
	if weak_key in ["a", "b"] and strong_key in ["a", "b"]:
		return weak_key if rng.randf() <= _contest_weak_counter_chance(card) else strong_key
	var power_a: float = float(current_contest.get("power_a", _contest_power(player_a, card)))
	var power_b: float = float(current_contest.get("power_b", _contest_power(player_b, card)))
	var total: float = maxf(1.0, power_a + power_b)
	var chance_a: float = power_a / total
	chance_a = clampf(chance_a, 0.01, 0.99)
	return "a" if rng.randf() <= chance_a else "b"


func _contest_weak_counter_chance(card: Dictionary) -> float:
	var weak_key: String = str(current_contest.get("weak_key", "a"))
	var strong_key: String = str(current_contest.get("strong_key", "b"))
	if not (weak_key in ["a", "b"]) or not (strong_key in ["a", "b"]) or weak_key == strong_key:
		return 0.5
	var weak_power: float = float(current_contest.get("power_" + weak_key, 1.0))
	var strong_power: float = float(current_contest.get("power_" + strong_key, 1.0))
	if weak_power <= 0.0 or strong_power <= 0.0:
		return CONTEST_WEAK_COUNTER_MIN_CHANCE
	var ratio: float = clampf(weak_power / maxf(1.0, strong_power), 0.0, 1.0)
	var chance: float = 0.02 + pow(ratio, 3.0) * 0.22
	var weak_player: PlayerData = _player_by_key(weak_key)
	chance += minf(0.04, float(_contest_pressure_stacks(weak_player)) * CONTEST_WEAK_COUNTER_PRESSURE_BONUS)
	if str(card.get("type", "")) == "灾厄":
		chance *= 0.85
	return clampf(chance, CONTEST_WEAK_COUNTER_MIN_CHANCE, CONTEST_WEAK_COUNTER_MAX_CHANCE)


func _player_by_key(key: String) -> PlayerData:
	return player_a if key == "a" else player_b


func _queue_npc_lottery_energy() -> void:
	if not single_player_mode or player_b == null:
		return
	await get_tree().create_timer(0.55).timeout
	if not single_player_mode or current_state != GameState.LOTTERY or lottery_energy_started:
		return
	if lottery_energy_injections.has(player_b.peer_id):
		return
	push_npc_dialogue("inject")
	on_lottery_energy_injected(player_b.peer_id)


func _queue_npc_bargain_choice(card: Dictionary) -> void:
	if not single_player_mode:
		return
	var choice: String = _choose_npc_bargain_choice(card)
	push_npc_dialogue("choice", {"choice": choice, "desc": str(card.get("desc", "这张牌"))})
	await get_tree().create_timer(1.25).timeout
	if not single_player_mode or current_state != GameState.BARGAIN:
		return
	if bargain_choices.has("b"):
		return
	on_bargain_choice_received(player_b.peer_id, {"index": current_card_index, "choice": choice})


func _choose_npc_bargain_choice(card: Dictionary) -> String:
	var temper: String = str(selected_npc_profile.get("temper", "bold"))
	var card_type: String = str(card.get("type", "机缘"))
	var effect_type: String = str(card.get("effect_type", ""))
	var quality_rank: int = _quality_rank(str(card.get("quality", "筑基级")))
	var hp_rate: float = 1.0
	if player_b != null:
		hp_rate = float(player_b.qi_xue) / float(maxi(1, _get_player_max_hp(player_b)))

	if card_type == "灾厄":
		var danger: float = _npc_calamity_danger(card, hp_rate)
		if danger >= 0.78:
			return "抢"
		if _npc_target_route(player_b) in ["体修", "阵修", "情修"] and danger <= 0.42 and rng.randf() < 0.72:
			return "让"
		if temper == "kind" and quality_rank <= 1 and rng.randf() < 0.58:
			return "让"
		if temper == "soft" and quality_rank <= 2 and rng.randf() < 0.48:
			return "让"
		return "抢" if rng.randf() < clampf(0.54 + danger * 0.34, 0.48, 0.90) else "让"

	var grab_chance: float = _npc_opportunity_grab_chance(card, hp_rate)
	return "抢" if rng.randf() < grab_chance else "让"


func _npc_target_route(player: PlayerData) -> String:
	if player == null:
		return str(selected_npc_profile.get("route", "剑修"))
	var route: String = str(player.final_attributes.get("npc_route", selected_npc_profile.get("route", "")))
	return route if CULTIVATION_TYPES.has(route) else str(selected_npc_profile.get("route", "剑修"))


func _npc_is_behind() -> bool:
	if player_a == null or player_b == null:
		return false
	if get_visible_combat_power(player_b) + 8.0 < get_visible_combat_power(player_a) * 0.92:
		return true
	if _realm_rank(player_b.realm) < _realm_rank(player_a.realm):
		return true
	return player_b.ling_li + 60 < player_a.ling_li


func _npc_player_often_yields() -> bool:
	if player_a == null:
		return false
	var total: int = maxi(1, player_a.total_qiang_count + player_a.total_rang_count)
	return float(player_a.total_rang_count) / float(total) >= 0.48


func _npc_calamity_danger(card: Dictionary, hp_rate: float) -> float:
	var danger: float = 0.22 + float(_quality_rank(str(card.get("quality", "筑基级")))) * 0.10
	match str(card.get("effect_type", "")):
		"hp_percent_loss", "hp_damage", "enemy", "tribulation":
			danger += 0.24
		"shou_yuan_loss":
			danger += 0.16
		"ling_li_loss":
			danger += 0.08
	if hp_rate < 0.30:
		danger += 0.38
	elif hp_rate < 0.52:
		danger += 0.20
	return clampf(danger, 0.0, 1.0)


func _npc_opportunity_grab_chance(card: Dictionary, hp_rate: float) -> float:
	var effect_type: String = str(card.get("effect_type", ""))
	var quality_rank: int = _quality_rank(str(card.get("quality", "筑基级")))
	var route: String = _npc_target_route(player_b)
	var chance: float = 0.54
	match effect_type:
		"technique":
			chance = 0.90 if player_b != null and player_b.techniques.size() < MAX_EQUIPPED_TECHNIQUES else 0.78
		"treasure":
			chance = 0.92 if player_b != null and player_b.treasures.is_empty() else 0.74
		"companion":
			chance = 0.84 if player_b != null and player_b.companions.size() < MAX_COMPANIONS else 0.66
		"alchemy_material":
			chance = 0.88 if route == "丹修" else 0.66
		"craft_material":
			chance = 0.88 if route == "器修" else 0.66
		"ling_li":
			chance = 0.78 if _npc_is_behind() else 0.58
		"heal_percent":
			chance = 0.92 if hp_rate < 0.72 else 0.30
		"ling_shi":
			chance = 0.76 if player_b != null and player_b.ling_shi < MARKET_HEAL_COST else 0.58
		"stat_up", "shou_yuan", "adventure", "quest":
			chance = 0.68
		"auction":
			chance = 0.56
	if quality_rank >= _quality_rank("元婴级"):
		chance += 0.10
	if _npc_is_behind():
		chance += 0.12
	if _npc_player_often_yields() and effect_type in ["technique", "treasure", "companion", "alchemy_material", "craft_material", "ling_li"]:
		chance += 0.08
	match str(selected_npc_profile.get("temper", "bold")):
		"greedy":
			chance += 0.06
		"bold":
			chance += 0.03
		"kind":
			chance -= 0.03
		"soft":
			chance -= 0.02
	return clampf(chance, 0.18, 0.95)


func _queue_npc_continue() -> void:
	if not single_player_mode or player_b == null:
		return
	await get_tree().create_timer(0.7).timeout
	if not single_player_mode:
		return
	_auto_clear_npc_pending_backpack()
	if not bargain_continue_votes.has(player_b.peer_id):
		on_bargain_continue_received(player_b.peer_id, {})


func _queue_npc_contest_decision() -> void:
	if not single_player_mode or current_contest.is_empty():
		return
	await get_tree().create_timer(2.0).timeout
	if not single_player_mode or current_state != GameState.CONTEST or current_contest.is_empty():
		return
	var weak_key: String = str(current_contest.get("weak_key", "a"))
	if weak_key != "b":
		return
	var mode: String = _choose_npc_contest_mode()
	push_npc_dialogue("contest_fight" if mode == "fight" else "contest_yield")
	on_contest_choice_received(player_b.peer_id, {"mode": mode})


func _choose_npc_contest_mode() -> String:
	var temper: String = str(selected_npc_profile.get("temper", "bold"))
	var card: Dictionary = current_contest.get("card", {}) as Dictionary
	var counter_chance: float = _contest_weak_counter_chance(card)
	var pressure: int = _contest_pressure_stacks(player_b)
	var chance: float = 0.04 + counter_chance * 0.75 + float(pressure) * 0.02
	if temper == "bold":
		chance += 0.05
	elif temper == "greedy":
		chance += 0.03
	elif temper == "kind":
		chance -= 0.08
	return "fight" if rng.randf() < clampf(chance, 0.03, 0.30) else "yield"


func _queue_npc_auction_action() -> void:
	if not single_player_mode or current_auction.is_empty():
		return
	push_npc_dialogue("auction")
	await get_tree().create_timer(0.8).timeout
	if not single_player_mode or current_state != GameState.AUCTION:
		return
	if auction_choices.has(str(player_b.peer_id)):
		return
	on_auction_action_received(player_b.peer_id, _choose_npc_auction_action())


func _choose_npc_auction_action() -> Dictionary:
	var lots: Array = current_auction.get("lots", []) as Array
	var best_index: int = -1
	var best_score: float = -99999.0
	for i in range(lots.size()):
		var lot: Dictionary = lots[i] as Dictionary
		var price: int = int(lot.get("price", 0))
		if player_b == null or player_b.ling_shi < price:
			continue
		var kind: String = str(lot.get("kind", ""))
		var score: float = 0.0
		match kind:
			"cultivation":
				score = 80.0
			"technique":
				score = 72.0
			"treasure":
				score = 64.0
			"companion":
				score = 60.0
			"dan":
				score = 58.0
			"backpack":
				score = 44.0
			"heal":
				score = 34.0
			_:
				score = 20.0
		score += float(_quality_rank(str(lot.get("quality", "筑基级")))) * 12.0
		score -= float(price) * 0.06
		if score > best_score:
			best_score = score
			best_index = i
	if best_index < 0:
		return {"mode": "pass", "lot_index": -1}
	var mode: String = "bid" if str(selected_npc_profile.get("temper", "")) == "greedy" and rng.randf() < 0.45 else "haggle"
	return {"mode": mode, "lot_index": best_index}


func _queue_npc_battle_action() -> void:
	if not single_player_mode:
		return
	push_npc_dialogue("battle")
	await get_tree().create_timer(0.75).timeout
	if not single_player_mode or current_state != GameState.BATTLE or current_enemy.is_empty():
		return
	if battle_choices.has(player_b.peer_id) or battle_escaped_peers.has(player_b.peer_id):
		return
	settle_battle_action(player_b.peer_id, _choose_npc_battle_action())


func _choose_npc_battle_action() -> String:
	var hp_rate: float = 1.0
	if player_b != null:
		hp_rate = float(player_b.qi_xue) / float(maxi(1, _get_player_max_hp(player_b)))
	var enemy_hp: int = int(current_enemy.get("hp", 0))
	var estimated_damage: float = _estimate_battle_action_damage(player_b)
	if enemy_hp > 0 and estimated_damage >= float(enemy_hp) and hp_rate > 0.34:
		return "抢攻"
	if hp_rate < 0.22:
		return "逃跑" if get_escape_success_chance(player_b) >= 0.38 else "周旋"
	if hp_rate < 0.52:
		return "周旋" if rng.randf() < 0.82 else "逃跑"
	var temper: String = str(selected_npc_profile.get("temper", "bold"))
	var threat_level: int = _battle_enemy_threat_level()
	if threat_level >= 2 and hp_rate < 0.72:
		return "周旋" if rng.randf() < 0.72 else "抢攻"
	if temper == "bold":
		return "抢攻" if rng.randf() < 0.68 else "周旋"
	if temper == "greedy":
		return "逃跑" if hp_rate < 0.58 and rng.randf() < 0.34 else ("抢攻" if rng.randf() < 0.62 else "周旋")
	if temper == "kind":
		return "周旋" if rng.randf() < 0.62 else "抢攻"
	return "周旋" if rng.randf() < 0.55 else "抢攻"


func _queue_npc_tribulation_choice() -> void:
	if not single_player_mode:
		return
	push_npc_dialogue("tribulation")
	await get_tree().create_timer(0.75).timeout
	if not single_player_mode or current_state != GameState.TRIBULATION:
		return
	if tribulation_choices.has(player_b.peer_id):
		return
	settle_tribulation(player_b.peer_id, _choose_npc_tribulation_choice())


func _choose_npc_tribulation_choice() -> String:
	var hp_rate: float = 1.0
	if player_b != null:
		hp_rate = float(player_b.qi_xue) / float(maxi(1, _get_player_max_hp(player_b)))
	var temper: String = str(selected_npc_profile.get("temper", "bold"))
	if hp_rate < 0.50:
		return "躲"
	if pending_breakthrough_player == player_b:
		return "扛" if hp_rate > 0.74 else "躲"
	if temper == "kind" or temper == "soft":
		return "扛" if hp_rate > 0.66 and rng.randf() < 0.58 else "躲"
	return "躲" if rng.randf() < 0.62 else "扛"


func _queue_npc_final_choice() -> void:
	if not single_player_mode or pending_duel_winner_key != "player_b":
		return
	await get_tree().create_timer(1.0).timeout
	if not single_player_mode or current_state != GameState.DUEL or pending_duel_winner_key != "player_b":
		return
	var temper: String = str(selected_npc_profile.get("temper", "bold"))
	var choice: String = "yield" if (temper == "kind" or temper == "soft") and rng.randf() < 0.42 else "ascend"
	push_npc_dialogue("final_yield" if choice == "yield" else "final_ascend")
	on_duel_final_choice_received(player_b.peer_id, {"choice": choice})


func _auto_clear_npc_pending_backpack() -> void:
	if player_b == null:
		return
	var messages: Array[String] = []
	var had_pending: bool = pending_backpack_items.has(str(player_b.peer_id))
	var before_message: String = _npc_auto_manage_inventory(player_b)
	if before_message != "":
		messages.append(before_message)
	var message: String = ""
	if had_pending:
		message = _try_store_pending_backpack_item(player_b)
		if message != "":
			messages.append(message)
	var after_message: String = _npc_auto_manage_inventory(player_b)
	if after_message != "":
		messages.append(after_message)
	if pending_backpack_items.has(str(player_b.peer_id)):
		message = discard_pending_backpack_item(player_b)
		if message != "":
			messages.append(message)
	if messages.is_empty():
		return
	var update_data: Dictionary = _backpack_update_data(player_b.peer_id, player_b.player_name + "整理背包：" + "；".join(messages))
	NetworkManager.send_message("backpack_updated", update_data)
	on_backpack_updated(update_data)


func _npc_auto_manage_inventory(player: PlayerData) -> String:
	if player == null:
		return ""
	var messages: Array[String] = []
	_normalize_player_technique_inventory(player)
	var recover_message: String = _npc_auto_recover(player)
	if recover_message != "":
		messages.append(recover_message)
	for kind in ["technique", "treasure", "companion"]:
		var equip_message: String = _npc_auto_equip_best_kind(player, kind)
		if equip_message != "":
			messages.append(equip_message)
	var craft_message: String = _npc_auto_craft(player)
	if craft_message != "":
		messages.append(craft_message)
	var trim_message: String = _npc_trim_backpack_overflow(player)
	if trim_message != "":
		messages.append(trim_message)
	check_set_bonus(player)
	return "；".join(messages)


func _npc_auto_recover(player: PlayerData) -> String:
	if player == null:
		return ""
	if int(player.final_attributes.get("npc_recover_round", -999)) == round_number:
		return ""
	var max_hp: int = _get_player_max_hp(player)
	var hp_rate: float = float(player.qi_xue) / float(maxi(1, max_hp))
	if hp_rate >= 0.58:
		return ""
	if player.ling_shi >= MARKET_HEAL_COST:
		player.ling_shi -= MARKET_HEAL_COST
		var heal_amount: int = _heal_player_percent(player, MARKET_HEAL_PCT)
		player.final_attributes["npc_recover_round"] = round_number
		return "花" + str(MARKET_HEAL_COST) + "灵石疗伤，气血+" + str(heal_amount)
	if hp_rate < 0.26:
		var free_heal: int = _heal_player_percent(player, 0.12)
		player.final_attributes["npc_recover_round"] = round_number
		return "打坐护住心脉，气血+" + str(free_heal)
	return ""


func _npc_auto_craft(player: PlayerData) -> String:
	if player == null or _is_alchemy_blocked():
		return ""
	if int(player.final_attributes.get("npc_craft_round", -999)) == round_number:
		return ""
	var mode: String = _npc_choose_craft_mode(player)
	if mode == "":
		return ""
	var grade: String = _npc_roll_craft_grade(player, mode)
	var message: String = perform_alchemy(player, grade) if mode == "alchemy" else perform_refining(player, grade)
	if message == "" or message.begins_with("缺少") or message.contains("暂时不能") or message.contains("先备"):
		return ""
	player.final_attributes["npc_craft_round"] = round_number
	var title: String = "开炉炼丹" if mode == "alchemy" else "开炉炼器"
	return title + "：" + message


func _npc_choose_craft_mode(player: PlayerData) -> String:
	var alchemy_status: Dictionary = get_alchemy_status(player)
	var refining_status: Dictionary = get_refining_status(player)
	var can_alchemy: bool = bool(alchemy_status.get("can", false))
	var can_refining: bool = bool(refining_status.get("can", false))
	if not can_alchemy and not can_refining:
		return ""
	var route: String = _npc_target_route(player)
	var alchemy_score: float = -999.0
	if can_alchemy:
		alchemy_score = 25.0
		if route == "丹修":
			alchemy_score += 55.0
		if str(alchemy_status.get("dan_name", "")) != "":
			alchemy_score += 70.0
		var hp_rate: float = float(player.qi_xue) / float(maxi(1, _get_player_max_hp(player)))
		if hp_rate < 0.82:
			alchemy_score += (0.82 - hp_rate) * 70.0
		alchemy_score += minf(18.0, float(_material_count(player, "alchemy")) * 4.0)
	var refining_score: float = -999.0
	if can_refining:
		refining_score = 25.0
		if route == "器修":
			refining_score += 55.0
		var treasure: Dictionary = _get_equipped_treasure(player)
		if not treasure.is_empty():
			_prepare_treasure(treasure, _player_sect(player))
			if int(treasure.get("awakening_level", 0)) <= 0:
				refining_score += 36.0
			var threshold: int = maxi(1, int(treasure.get("awaken_threshold", treasure.get("growth_max", 10))))
			var growth_rate: float = float(int(treasure.get("growth_value", 0))) / float(threshold)
			refining_score += clampf(1.0 - growth_rate, 0.0, 1.0) * 24.0
		refining_score += minf(18.0, float(_material_count(player, "craft")) * 4.0)
	if alchemy_score < 32.0 and refining_score < 32.0:
		return ""
	if is_equal_approx(alchemy_score, refining_score):
		return "alchemy" if rng.randf() < 0.5 else "refining"
	return "alchemy" if alchemy_score > refining_score else "refining"


func _npc_roll_craft_grade(player: PlayerData, mode: String) -> String:
	var craft_mode: String = "refining" if mode == "refining" else "alchemy"
	var stat_score: int = _craft_stat_score(player, craft_mode)
	var route: String = _npc_target_route(player)
	var route_fit: bool = (mode == "alchemy" and route == "丹修") or (mode == "refining" and route == "器修")
	var perfect_chance: float = clampf(0.08 + float(stat_score) * 0.018 + (0.08 if route_fit else 0.0), 0.05, 0.46)
	var miss_chance: float = clampf(0.30 - float(stat_score) * 0.022 - (0.08 if route_fit else 0.0), 0.04, 0.30)
	var roll: float = rng.randf()
	if roll < perfect_chance:
		return "perfect"
	if roll < perfect_chance + miss_chance:
		return "miss"
	return "good"


func _npc_auto_equip_best_kind(player: PlayerData, kind: String) -> String:
	if player == null:
		return ""
	var changed_labels: Array[String] = []
	for _pass in range(8):
		var best_index: int = _npc_best_backpack_item_index(player, kind)
		if best_index < 0:
			break
		var best_entry: Dictionary = player.backpack[best_index] as Dictionary
		var best_data: Dictionary = best_entry.get("data", {}) as Dictionary
		var best_score: float = _npc_item_score(player, kind, best_data)
		var should_equip: bool = false
		var target_index: int = -1
		match kind:
			"technique":
				if player.techniques.size() < MAX_EQUIPPED_TECHNIQUES:
					should_equip = true
				else:
					target_index = _npc_worst_equipped_index(player, kind)
					should_equip = target_index >= 0 and best_score > _npc_item_score(player, kind, player.techniques[target_index] as Dictionary) + 12.0
			"treasure":
				if player.treasures.is_empty():
					should_equip = true
				else:
					target_index = 0
					should_equip = best_score > _npc_item_score(player, kind, player.treasures[0] as Dictionary) + 10.0
			"companion":
				if player.companions.size() < MAX_COMPANIONS:
					should_equip = true
				else:
					target_index = _npc_worst_equipped_index(player, kind)
					should_equip = target_index >= 0 and best_score > _npc_item_score(player, kind, player.companions[target_index] as Dictionary) + 10.0
		if not should_equip:
			break
		var label: String = _backpack_item_label(best_entry)
		var result: String = equip_from_backpack(player, best_index, kind, target_index)
		if result == "" or result.begins_with("未选择") or result.contains("不能"):
			break
		changed_labels.append(label)
	if changed_labels.is_empty():
		return ""
	return "换上" + "、".join(changed_labels)


func _npc_best_backpack_item_index(player: PlayerData, kind: String) -> int:
	var best_index: int = -1
	var best_score: float = -999999.0
	for i in range(player.backpack.size()):
		var entry: Dictionary = player.backpack[i] as Dictionary
		if str(entry.get("kind", "")) != kind:
			continue
		var score: float = _npc_item_score(player, kind, entry.get("data", {}) as Dictionary)
		if score > best_score:
			best_score = score
			best_index = i
	return best_index


func _npc_worst_backpack_item_index(player: PlayerData, kind: String) -> int:
	var worst_index: int = -1
	var worst_score: float = 999999.0
	for i in range(player.backpack.size()):
		var entry: Dictionary = player.backpack[i] as Dictionary
		if str(entry.get("kind", "")) != kind:
			continue
		var score: float = _npc_item_score(player, kind, entry.get("data", {}) as Dictionary)
		if score < worst_score:
			worst_score = score
			worst_index = i
	return worst_index


func _npc_worst_equipped_index(player: PlayerData, kind: String) -> int:
	var items: Array = []
	match kind:
		"technique":
			items = player.techniques
		"companion":
			items = player.companions
		"treasure":
			items = player.treasures
	var worst_index: int = -1
	var worst_score: float = 999999.0
	for i in range(items.size()):
		if not items[i] is Dictionary:
			continue
		var score: float = _npc_item_score(player, kind, items[i] as Dictionary)
		if score < worst_score:
			worst_score = score
			worst_index = i
	return worst_index


func _npc_item_score(player: PlayerData, kind: String, item_data: Dictionary) -> float:
	if item_data.is_empty():
		return -9999.0
	var quality: String = str(item_data.get("quality", "炼气级"))
	var score: float = float(_quality_rank(quality)) * 100.0
	var route: String = _npc_target_route(player)
	var tags: Array[String] = _item_cultivation_tags(item_data)
	if tags.has(route):
		score += 90.0
	if str(item_data.get("primary_cultivation_tag", "")) == route or str(item_data.get("growth_type", "")) == route:
		score += 35.0
	match kind:
		"technique":
			var bonuses: Dictionary = item_data.get("bonuses", item_data.get("base_bonuses", {})) as Dictionary
			for bonus_name in bonuses:
				score += minf(45.0, absf(float(bonuses[bonus_name])) * 180.0)
			score += _technique_stage_multiplier(item_data) * 22.0
		"treasure":
			var prepared: Dictionary = _prepare_treasure(item_data, _player_sect(player))
			score += float(prepared.get("battle_damage", prepared.get("base_attack", 0))) * 9.0
			score += float(prepared.get("growth_value", 0)) * 1.2
			if int(prepared.get("awakening_level", 0)) > 0 or bool(prepared.get("awakened", false)):
				score += 55.0
		"companion":
			_prepare_companion(item_data, player)
			score += float(item_data.get("bond", 0)) * 4.0
			score += absf(_companion_effective_bonus_value(item_data)) * 210.0
		"material":
			var material_type: String = str(item_data.get("material_type", "alchemy"))
			if route == "丹修" and material_type == "alchemy":
				score += 60.0
			if route == "器修" and material_type == "craft":
				score += 60.0
	return score


func _npc_trim_backpack_overflow(player: PlayerData) -> String:
	if player == null:
		return ""
	var removed: Array[String] = []
	for kind in ["technique", "treasure", "companion", "material"]:
		var limit: int = get_backpack_kind_limit(kind)
		while limit > 0 and _backpack_kind_count(player, kind) > limit:
			var remove_index: int = _npc_worst_backpack_item_index(player, kind)
			if remove_index < 0:
				break
			var entry: Dictionary = player.backpack[remove_index] as Dictionary
			removed.append(_backpack_item_label(entry))
			_add_to_scattered_pool(entry, player.peer_id, "npc_auto_discard")
			player.backpack.remove_at(remove_index)
	if removed.is_empty():
		return ""
	return "舍弃低阶" + "、".join(removed)


func _apply_contest_to_settlement(settled: Dictionary, contest_result: Dictionary, card: Dictionary) -> void:
	var message: String = str(contest_result.get("message", "争道已分"))
	var card_type: String = str(card.get("type", ""))
	for key in ["player_a", "player_b"]:
		var result: Dictionary = settled.get(key, {}) as Dictionary
		if card_type == "灾厄" and str(contest_result.get("mode", "")) == "yield" and float(result.get("lose", 0.0)) > 0.0:
			result["lose"] = float(result.get("lose", 0.0)) * 0.72
		result["special"] = message
		result["log"] = message
		settled[key] = result
	settled["player_a_result"] = settled["player_a"]
	settled["player_b_result"] = settled["player_b"]


func _apply_weak_counter_reward_multiplier(settled: Dictionary, contest_result: Dictionary, card: Dictionary) -> void:
	if str(contest_result.get("mode", "")) != "fight":
		return
	if str(contest_result.get("winner_key", "")) != str(contest_result.get("weak_key", "")):
		return
	var winner_key: String = str(contest_result.get("winner_key", ""))
	var result_key: String = "player_a" if winner_key == "a" else "player_b"
	var winner_result: Dictionary = settled.get(result_key, {}) as Dictionary
	var doubled: bool = false
	if str(card.get("type", "")) == "机缘" and float(winner_result.get("gain", 0.0)) > 0.0:
		winner_result["gain"] = float(winner_result.get("gain", 0.0)) * 2.0
		doubled = true
	if bool(card.get("identity_special", false)) and str(winner_result.get("sect_special_role", "none")) != "none":
		winner_result["sect_special_double"] = true
		doubled = true
	if doubled:
		winner_result["weak_counter_double"] = true
		if not bool(card.get("identity_special", false)):
			_append_result_message(winner_result, "special", WEAK_COMEBACK_TEXT)
		settled[result_key] = winner_result
		settled["player_a_result"] = settled["player_a"]
		settled["player_b_result"] = settled["player_b"]


func _apply_contest_after_effects(settled: Dictionary, contest_result: Dictionary, card: Dictionary) -> void:
	if str(contest_result.get("mode", "")) != "fight":
		_apply_contest_yield_reward(settled, contest_result, card)
		return
	if str(card.get("type", "")) == "灾厄":
		return
	var loser_key: String = str(contest_result.get("loser_key", ""))
	var loser: PlayerData = _player_by_key(loser_key)
	if loser == null:
		return
	var max_hp: int = _get_player_max_hp(loser)
	var wound_pct: float = 0.06 + float(_quality_rank(str(card.get("quality", "筑基级")))) * 0.02
	var damage: int = maxi(1, int(round(float(max_hp) * wound_pct)))
	loser.qi_xue = maxi(1, loser.qi_xue - damage)
	var loser_result_key: String = "player_a" if loser_key == "a" else "player_b"
	var loser_result: Dictionary = settled.get(loser_result_key, {}) as Dictionary
	var old_message: String = str(loser_result.get("lose_message", ""))
	loser_result["lose_message"] = (old_message + "；" if old_message != "" else "") + "争道落败，气血 -" + str(damage)
	settled[loser_result_key] = loser_result
	settled["player_a_result"] = settled["player_a"]
	settled["player_b_result"] = settled["player_b"]


func _apply_contest_yield_reward(settled: Dictionary, contest_result: Dictionary, card: Dictionary) -> void:
	var weak_key: String = str(contest_result.get("weak_key", ""))
	var weak_player: PlayerData = _player_by_key(weak_key)
	if weak_player == null:
		return
	var reward: int = _contest_yield_ling_li_reward(weak_player, card)
	weak_player.ling_li += reward
	weak_player.forbearance = clampi(weak_player.forbearance + 1, 0, MAX_FORBEARANCE)
	var result_key: String = "player_a" if weak_key == "a" else "player_b"
	var weak_result: Dictionary = settled.get(result_key, {}) as Dictionary
	var message: String = "承劫感悟，修为 +" + str(reward) if str(card.get("type", "")) == "灾厄" else "放弃保底，修为 +" + str(reward)
	var target_key: String = "lose_message" if str(card.get("type", "")) == "灾厄" else "gain_message"
	_append_result_message(weak_result, target_key, message)
	settled[result_key] = weak_result
	settled["player_a_result"] = settled["player_a"]
	settled["player_b_result"] = settled["player_b"]


func _contest_yield_ling_li_reward(player: PlayerData, card: Dictionary) -> int:
	if player == null:
		return 0
	var quality_rank: int = _quality_rank(str(card.get("quality", "筑基级")))
	var base_reward: int = 10 + quality_rank * 6
	base_reward += int(player.stats.get("机缘", 0)) * 2
	if str(card.get("type", "")) == "灾厄":
		base_reward += 6
	return maxi(8, base_reward)


func _contest_comeback_ling_li_reward(player: PlayerData, card: Dictionary) -> int:
	var base_reward: int = _contest_yield_ling_li_reward(player, card)
	var pressure: int = _contest_pressure_stacks(player)
	var multiplier: float = 0.55 + float(pressure) * 0.25
	return maxi(6, int(round(float(base_reward) * clampf(multiplier, 0.55, 1.35))))


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
	current_contest.clear()
	bargain_result.emit(data)
	_auto_save("bargain_settled")


func on_bargain_continue_received(peer_id: int, _data: Dictionary = {}) -> void:
	if not NetworkManager.is_host:
		return
	if _try_trigger_death_ending():
		return
	if single_player_mode:
		_auto_clear_npc_pending_backpack()
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
	if single_player_mode and continue_peer_id == player_a.peer_id and not bargain_continue_votes.has(player_b.peer_id):
		_queue_npc_continue()

	var total_required: int = _lottery_energy_required_count()
	if bargain_continue_votes.size() < total_required:
		return

	bargain_continue_votes.clear()
	if check_duel_trigger():
		return
	if pending_continue_round_finished:
		pending_continue_next_index = -1
		pending_continue_round_finished = false
		_finish_round_without_rest()
		return

	var reveal_index: int = pending_continue_next_index
	pending_continue_next_index = -1
	pending_continue_round_finished = false
	_reveal_card_for_bargain(reveal_index)


func get_adjusted_quality_prob(ji_yuan_stat: int, is_calamity: bool = false) -> Dictionary:
	if is_calamity:
		return _calamity_quality_probs_for_current_realm()
	var realm_rank: int = _highest_player_realm_rank()
	var probs: Dictionary = _reward_quality_probs_for_realm_rank(realm_rank)
	var shift: float = minf(0.12, float(ji_yuan_stat) * 0.012) + _sect_event_quality_shift_active()
	var low_qualities: Array = _quality_low_group_for_realm(realm_rank)
	var high_qualities: Array = _quality_high_group_for_realm(realm_rank)
	var transfer: float = absf(shift)

	if shift > 0.0:
		var removed: float = _redistribute_from_group(probs, low_qualities, transfer)
		_redistribute_to_group(probs, high_qualities, removed)
	elif shift < 0.0:
		var removed: float = _redistribute_from_group(probs, high_qualities, transfer)
		_redistribute_to_group(probs, low_qualities, removed)

	_normalize_probs(probs)
	return probs


func quality_display_name(quality: String) -> String:
	return str(QUALITY_REALM_NAMES.get(quality, quality))


func _reward_quality_probs_for_realm_rank(realm_rank: int) -> Dictionary:
	var key: int = clampi(realm_rank, 0, 3)
	var probs: Dictionary = (REALM_REWARD_QUALITY_PROBS.get(key, REALM_REWARD_QUALITY_PROBS[0]) as Dictionary).duplicate(true)
	_normalize_probs(probs)
	return probs


func _quality_low_group_for_realm(realm_rank: int) -> Array:
	match clampi(realm_rank, 0, 3):
		0:
			return ["炼气级"]
		1:
			return ["炼气级", "筑基级"]
		2:
			return ["炼气级", "筑基级", "金丹级"]
		_:
			return ["炼气级", "筑基级", "金丹级", "元婴级"]


func _quality_high_group_for_realm(realm_rank: int) -> Array:
	match clampi(realm_rank, 0, 3):
		0:
			return ["筑基级", "金丹级", "元婴级"]
		1:
			return ["金丹级", "元婴级", "化神级"]
		2:
			return ["元婴级", "化神级", "合体级"]
		_:
			return ["化神级", "合体级"]


func roll_quality(probs: Dictionary) -> String:
	var roll: float = rng.randf()
	var cursor: float = 0.0
	for quality in QUALITY_ORDER:
		cursor += float(probs.get(quality, 0.0))
		if roll <= cursor:
			return str(quality)
	return "炼气级"


func generate_ji_yuan(stat: int) -> Dictionary:
	var ji_yuan_type: Dictionary = _roll_ji_yuan_type()
	var scattered: Dictionary = _try_generate_scattered_ji_yuan(stat, str(ji_yuan_type.get("effect_type", "")))
	if not scattered.is_empty():
		return scattered
	return _build_ji_yuan_data(stat, ji_yuan_type)


func generate_cultivation_ji_yuan(stat: int) -> Dictionary:
	return _build_ji_yuan_data(stat, {"name": "修行", "base_effect": 45, "effect_type": "ling_li"})


func _generate_specific_ji_yuan(stat: int, effect_type: String) -> Dictionary:
	for ji_yuan in JI_YUAN_TYPES:
		var ji_yuan_data: Dictionary = ji_yuan as Dictionary
		if str(ji_yuan_data.get("effect_type", "")) == effect_type:
			var scattered: Dictionary = _try_generate_scattered_ji_yuan(stat, effect_type)
			if not scattered.is_empty():
				return scattered
			return _build_ji_yuan_data(stat, ji_yuan_data)
	return generate_ji_yuan(stat)


func _generate_build_ji_yuan(stat: int) -> Dictionary:
	var choices: Array[Dictionary] = []
	for ji_yuan in JI_YUAN_TYPES:
		var ji_yuan_data: Dictionary = ji_yuan as Dictionary
		if BUILD_EFFECT_TYPES.has(str(ji_yuan_data.get("effect_type", ""))):
			choices.append(ji_yuan_data)
	if choices.is_empty():
		return generate_ji_yuan(stat)
	var choice: Dictionary = choices[rng.randi_range(0, choices.size() - 1)]
	var scattered: Dictionary = _try_generate_scattered_ji_yuan(stat, str(choice.get("effect_type", "")))
	if not scattered.is_empty():
		return scattered
	return _build_ji_yuan_data(stat, choice)


func _identity_special_card_context() -> Dictionary:
	var candidates: Array[Dictionary] = []
	var entries: Array[Dictionary] = [
		{"player": player_a, "opponent": player_b},
		{"player": player_b, "opponent": player_a},
	]
	for entry in entries:
		var player_value: Variant = entry.get("player", null)
		var opponent_value: Variant = entry.get("opponent", null)
		if not player_value is PlayerData:
			continue
		var player: PlayerData = player_value as PlayerData
		var opponent: PlayerData = null
		if opponent_value is PlayerData:
			opponent = opponent_value as PlayerData
		if not _is_identity_special_weak_side(player, opponent):
			continue
		check_set_bonus(player)
		var chance: float = IDENTITY_SPECIAL_BASE_CHANCE + float(player.final_attributes.get("sect_card_bonus", 0.0))
		var sect_name: String = str(player.final_attributes.get("identity_sect", ""))
		if chance > 0.0 and SECT_TYPES.has(sect_name):
			candidates.append({"sect": sect_name, "chance": clampf(chance, 0.0, 1.0), "peer_id": player.peer_id})
	if candidates.is_empty():
		return {}
	var best_chance: float = 0.0
	for candidate in candidates:
		best_chance = maxf(best_chance, float(candidate.get("chance", 0.0)))
	var tied: Array[Dictionary] = []
	for candidate in candidates:
		if is_equal_approx(float(candidate.get("chance", 0.0)), best_chance):
			tied.append(candidate)
	return tied[rng.randi_range(0, tied.size() - 1)]


func _is_identity_special_weak_side(player: PlayerData, opponent: PlayerData) -> bool:
	if player == null or opponent == null:
		return false
	var hp_weak: bool = float(player.qi_xue) < float(opponent.qi_xue) * 0.70
	var ling_li_weak: bool = float(player.ling_li) < float(opponent.ling_li) * 0.50
	return hp_weak or ling_li_weak


func _generate_identity_specific_ji_yuan(stat: int, sect_name: String, target_peer_id: int = 0) -> Dictionary:
	var quality: String = roll_quality(get_adjusted_quality_prob(stat))
	var data: Dictionary = {
		"name": sect_name + "宗门专属卡",
		"quality": quality,
		"type": "机缘",
		"effect_type": "sect_special",
		"base_effect": 1,
		"effect_value": 1,
		"value": 1,
		"identity_special": true,
		"identity_sect": sect_name,
		"identity_peer_id": target_peer_id,
		"sect_mark": _sect_mark(sect_name),
		"sect_color": _sect_color_hex(sect_name),
		"desc": sect_name + "宗门专属卡",
	}
	return data


func _sect_mark(sect_name: String) -> String:
	match sect_name:
		"万魂殿":
			return "魂"
		"金刚寺":
			return "刚"
		"天剑阁":
			return "剑"
		"百花谷":
			return "花"
		"丹霞山":
			return "丹"
		"阵宗":
			return "阵"
		"符箓门":
			return "符"
		"器府":
			return "器"
		_:
			return "宗"


func _force_item_sect_affix(item: Dictionary, item_kind: String, sect_name: String) -> void:
	if item.is_empty() or not SECT_TYPES.has(sect_name):
		return
	var passive: Dictionary = SECT_PASSIVE.get(sect_name, {}) as Dictionary
	var alignment: String = str(SECT_ALIGNMENT.get(sect_name, "正"))
	var new_affixes: Array = [
		{
			"name": "门派·" + sect_name,
			"tag": sect_name,
			"affix_kind": "sect",
			"alignment": alignment,
			"desc": str(passive.get("desc", "契合" + sect_name + "门派身份")),
		},
	]
	var affixes: Array = item.get("affixes", []) as Array
	if item_kind != "companion":
		for affix in affixes:
			if not affix is Dictionary:
				continue
			var affix_data: Dictionary = affix as Dictionary
			if str(affix_data.get("affix_kind", "")) == "sect":
				continue
			new_affixes.append(affix_data.duplicate(true))
	item["affixes"] = new_affixes
	item["affixes_applied"] = false
	_refresh_item_build_tags(item)


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
	if effect_value > 0.0 and (ji_yuan_type["effect_type"] != "heal_percent" or str(ji_yuan_type.get("name", "")) == "灵泉沐浴"):
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
	elif data["effect_type"] == "quest":
		data["quest"] = _generate_bounty_task()
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


func generate_enemy_calamity(stat: int) -> Dictionary:
	var quality: String = _roll_enemy_card_quality(stat)
	var enemy_name: String = "古妖拦路" if quality == "合体级" else "遭遇敌人"
	var data: Dictionary = {
		"quality": quality,
		"type": enemy_name,
		"effect_type": "enemy",
		"base_effect": 0,
		"effect_value": 1,
		"value": 1,
		"multiplier": float(QUALITY_MULTIPLIER.get(quality, 1.0)),
	}
	data["desc"] = generate_desc(data, true)
	return data


func _roll_enemy_card_quality(stat: int) -> String:
	var allowed: Array[String] = _enemy_quality_pool_for_current_realm()
	var bonus: float = clampf(float(round_number - 1) * 0.03 - float(stat) * 0.005, -0.04, 0.12)
	var probs: Dictionary = {}
	for quality in allowed:
		probs[quality] = 1.0
	if allowed.size() >= 2:
		var low_quality: String = allowed[0]
		var high_quality: String = allowed[allowed.size() - 1]
		probs[low_quality] = maxf(0.25, 0.62 - bonus)
		probs[high_quality] = 0.38 + bonus
	_normalize_probs(probs)

	var roll: float = rng.randf()
	var cursor: float = 0.0
	for quality in allowed:
		cursor += float(probs.get(quality, 0.0))
		if roll <= cursor:
			return quality
	return allowed[0] if not allowed.is_empty() else "筑基级"


func _enemy_quality_pool_for_current_realm() -> Array[String]:
	match _average_player_realm_rank():
		0:
			return ["炼气级", "筑基级"]
		1:
			return ["筑基级", "金丹级"]
		2:
			return ["金丹级", "元婴级"]
		_:
			return ["元婴级", "化神级"]


func _clamp_enemy_quality_for_current_realm(enemy_quality: String) -> String:
	if enemy_quality == "合体级" and _highest_player_realm_rank() >= 3:
		return enemy_quality
	var allowed: Array[String] = _enemy_quality_pool_for_current_realm()
	if allowed.has(enemy_quality):
		return enemy_quality
	if allowed.is_empty():
		return enemy_quality
	var target_rank: int = _quality_rank(enemy_quality)
	var best_quality: String = allowed[0]
	var best_distance: int = 999
	for quality in allowed:
		var distance: int = absi(_quality_rank(quality) - target_rank)
		if distance < best_distance:
			best_distance = distance
			best_quality = quality
	return best_quality


func generate_auction_lots(card_quality: String) -> Array:
	var lots: Array = []
	var lot_count: int = 3
	var special_kinds: Array[String] = ["technique", "treasure", "companion", "alchemy_material", "craft_material", "dan"]
	var first_kind: String = "alchemy_material" if rng.randf() < 0.5 else "craft_material"
	lots.append(_make_auction_lot(first_kind, card_quality))
	while lots.size() < lot_count:
		var kind: String = special_kinds[rng.randi_range(0, special_kinds.size() - 1)]
		var lot: Dictionary = _make_auction_lot(kind, card_quality)
		lots.append(lot)
	return lots


func _make_auction_lot(kind: String, quality: String) -> Dictionary:
	match kind:
		"cultivation":
			var cultivation_gain: int = maxi(12, int(round(float(MARKET_CULTIVATION_GAIN) * _quality_power(quality))))
			return {
				"kind": kind,
				"name": quality_display_name(quality) + "吐纳丹",
				"quality": quality,
				"desc": "立即获得修为 +" + str(cultivation_gain),
				"price": _market_buy_price("cultivation", quality),
				"value": cultivation_gain,
			}
		"heal":
			return {
				"kind": kind,
				"name": quality_display_name(quality) + "回春散",
				"quality": quality,
				"desc": "立即回复30%气血",
				"price": _market_buy_price("heal", quality),
				"value": 1,
			}
		"dan":
			return {
				"kind": kind,
				"name": quality_display_name(quality) + "突破丹",
				"quality": quality,
				"desc": "补足当前境界所需突破丹",
				"price": _market_buy_price("dan", quality),
				"value": 1,
			}
		"technique":
			var technique: Dictionary = generate_technique(quality)
			return {
				"kind": kind,
				"name": "功法《" + str(technique.get("name", "未知功法")) + "》",
				"quality": str(technique.get("quality", quality)),
				"desc": "收入背包，装备后生效",
				"price": _market_buy_price("technique", str(technique.get("quality", quality))),
				"value": 1,
				"item_data": technique,
			}
		"treasure":
			var treasure: Dictionary = generate_treasure(quality)
			return {
				"kind": kind,
				"name": "法宝【" + str(treasure.get("name", "未知法宝")) + "】",
				"quality": str(treasure.get("quality", quality)),
				"desc": "收入背包，抢攻可用",
				"price": _market_buy_price("treasure", str(treasure.get("quality", quality))),
				"value": 1,
				"item_data": treasure,
			}
		"companion":
			var companion: Dictionary = generate_companion(quality)
			return {
				"kind": kind,
				"name": "伙伴「" + str(companion.get("name", "未知伙伴")) + "」",
				"quality": str(companion.get("quality", quality)),
				"desc": "收入背包，提供羁绊",
				"price": _market_buy_price("companion", str(companion.get("quality", quality))),
				"value": 1,
				"item_data": companion,
			}
		"alchemy_material":
			var herb: Dictionary = _make_material_item("alchemy", quality)
			return {
				"kind": kind,
				"name": "灵草「" + str(herb.get("name", "灵草")) + "」",
				"quality": quality,
				"desc": "炼丹材料，收入背包",
				"price": _market_buy_price("alchemy_material", quality),
				"value": 1,
				"item_data": herb,
			}
		"craft_material":
			var ore: Dictionary = _make_material_item("craft", quality)
			return {
				"kind": kind,
				"name": "矿材「" + str(ore.get("name", "矿材")) + "」",
				"quality": quality,
				"desc": "炼器材料，收入背包",
				"price": _market_buy_price("craft_material", quality),
				"value": 1,
				"item_data": ore,
			}
	return {
		"kind": "technique",
		"name": quality_display_name(quality) + "功法残卷",
		"quality": quality,
		"desc": "获得随机" + quality_display_name(quality) + "功法",
		"price": _market_buy_price("technique", quality),
		"value": 1,
		"item_data": generate_technique(quality),
	}


func _market_base_price(kind: String) -> int:
	match kind:
		"cultivation":
			return 230
		"heal":
			return 180
		"technique":
			return 620
		"treasure":
			return 520
		"companion":
			return 360
		"alchemy_material":
			return 180
		"craft_material":
			return 190
		"dan":
			return 420
		_:
			return 240


func _market_kind_for_entry_kind(kind: String, data: Dictionary = {}) -> String:
	if kind == "material":
		return "craft_material" if str(data.get("material_type", "")) == "craft" else "alchemy_material"
	return kind


func _market_buy_price(kind: String, quality: String) -> int:
	var base_value: int = _market_base_price(kind)
	var quality_rate: float = float(QUALITY_MULTIPLIER.get(quality, 1.0))
	var jitter: float = rng.randf_range(0.92, 1.12)
	return maxi(1, int(round(float(base_value) * quality_rate * jitter)))


func _roll_calamity_type_for_quality(quality: String) -> Dictionary:
	var base_type: Dictionary = (CALAMITY_TYPES.get(quality, CALAMITY_TYPES["炼气级"]) as Dictionary).duplicate(true)
	var realm_rank: int = _highest_player_realm_rank()
	match quality:
		"金丹级":
			if realm_rank > 0 and rng.randf() < 0.35:
				return {"name": "妖兽袭扰", "base_effect": 0, "effect_type": "enemy"}
		"元婴级":
			if realm_rank <= 0:
				return {"name": "气血损伤", "base_effect": 18, "effect_type": "hp_percent_loss"}
			if rng.randf() < 0.35:
				return {"name": "妖兽袭扰", "base_effect": 0, "effect_type": "enemy"}
		"化神级":
			if rng.randf() < 0.55:
				return {"name": "大妖拦路", "base_effect": 0, "effect_type": "enemy"}
		"合体级":
			if realm_rank >= 2 and rng.randf() < 0.28:
				return {"name": "天劫征兆", "base_effect": 0, "effect_type": "tribulation"}
			return base_type
	return base_type


func generate_technique(quality: String) -> Dictionary:
	var candidates: Array = []
	for technique in _all_technique_templates():
		var technique_data: Dictionary = technique as Dictionary
		if str(technique_data.get("quality", "")) == quality:
			candidates.append(technique_data)
	if candidates.is_empty():
		for technique in _all_technique_templates():
			candidates.append(technique)

	var selected: Dictionary = (candidates[rng.randi_range(0, candidates.size() - 1)] as Dictionary).duplicate(true)
	return _prepare_technique(selected)


func generate_unique_technique(player: PlayerData, quality: String) -> Dictionary:
	var candidates: Array = []
	for technique in _all_technique_templates():
		var technique_data: Dictionary = technique as Dictionary
		if str(technique_data.get("quality", "")) == quality:
			candidates.append(technique_data)

	if candidates.is_empty():
		for technique in _all_technique_templates():
			var fallback_data: Dictionary = technique as Dictionary
			candidates.append(fallback_data)

	if candidates.is_empty():
		return {}
	return _roll_technique_from_candidates(candidates, quality)


func _roll_technique_from_candidates(candidates: Array, quality: String) -> Dictionary:
	var selected: Dictionary = (candidates[rng.randi_range(0, candidates.size() - 1)] as Dictionary).duplicate(true)
	return _prepare_technique(selected)


func _all_technique_templates() -> Array:
	var templates: Array = []
	for technique in TECHNIQUE_POOL:
		templates.append(technique)
	return templates


func _prepare_technique(technique: Dictionary) -> Dictionary:
	var prepared: Dictionary = technique.duplicate(true)
	var raw_base_bonuses: Dictionary = prepared.get("base_bonuses", prepared.get("bonuses", {})) as Dictionary
	if not prepared.has("base_bonuses") and bool(prepared.get("affixes_applied", false)):
		raw_base_bonuses = _strip_affix_bonuses(prepared.get("bonuses", {}) as Dictionary, prepared.get("affixes", []) as Array)
	prepared.erase("sect")
	prepared.erase("school")
	prepared.erase("category")
	prepared.erase("combo_desc")
	prepared.erase("resonances")
	prepared.erase("is_core_technique")
	prepared["base_bonuses"] = _normalize_technique_bonuses(raw_base_bonuses, _item_cultivation_fallback(prepared))
	prepared["bonuses"] = (prepared["base_bonuses"] as Dictionary).duplicate(true)
	prepared["affixes_applied"] = false
	if not prepared.has("technique_realm"):
		prepared["technique_realm"] = "初窥"
	if not prepared.has("realm_progress"):
		prepared["realm_progress"] = 0
	prepared["quality_multiplier"] = _technique_quality_multiplier(prepared)
	prepared["realm_bonus"] = _technique_stage_multiplier(prepared)
	_ensure_item_affixes(prepared, "technique")
	return prepared


func _normalize_technique_bonuses(raw_bonuses: Dictionary, preferred_tag: String = "") -> Dictionary:
	var bonuses: Dictionary = {}
	for bonus_name in raw_bonuses:
		var key: String = str(bonus_name)
		if not TECHNIQUE_BONUS_KEYS.has(key):
			continue
		var value: float = float(raw_bonuses[bonus_name])
		if key == "全属性":
			var converted_key: String = _technique_preferred_bonus_key(preferred_tag)
			if converted_key == "":
				converted_key = "气血上限"
			bonuses[converted_key] = float(bonuses.get(converted_key, 0.0)) + value * TECHNIQUE_ALL_ATTRIBUTE_CONVERSION
			continue
		if key == "速度" and absf(value) > 1.0:
			value = value / 100.0
		bonuses[key] = float(bonuses.get(key, 0.0)) + value
	if bonuses.is_empty():
		var fallback_key: String = _technique_preferred_bonus_key(preferred_tag)
		var default_key: String = fallback_key if fallback_key != "" else "灵力获取"
		bonuses[default_key] = 0.06
	return _specialize_technique_bonus_dict(bonuses, preferred_tag, TECHNIQUE_MAX_BASE_BONUS_KEYS)


func _technique_preferred_bonus_key(cultivation_tag: String) -> String:
	return str(CULTIVATION_PRIMARY_BONUS_KEYS.get(cultivation_tag, ""))


func _technique_bonus_rank_score(bonus_name: String, value: float, preferred_tag: String) -> float:
	var score: float = absf(value)
	var preferred_key: String = _technique_preferred_bonus_key(preferred_tag)
	if bonus_name == preferred_key:
		score *= 1.8
	match bonus_name:
		"战斗减伤", "吸血", "破防", "反伤", "暴击率", "闪避率", "每轮回血":
			score *= 1.25
		"速度":
			score *= 1.05
	return score


func _specialize_technique_bonus_dict(raw_bonuses: Dictionary, preferred_tag: String, max_keys: int) -> Dictionary:
	var normalized: Dictionary = {}
	for bonus_name in raw_bonuses:
		var key: String = str(bonus_name)
		if key == "全属性":
			key = _technique_preferred_bonus_key(preferred_tag)
			if key == "":
				key = "气血上限"
		if not TECHNIQUE_BONUS_KEYS.has(key) or key == "全属性":
			continue
		var value: float = float(raw_bonuses[bonus_name])
		if key == "速度" and absf(value) > 1.0:
			value = value / 100.0
		if absf(value) < 0.0001:
			continue
		normalized[key] = float(normalized.get(key, 0.0)) + value
	if normalized.size() <= max_keys:
		return normalized

	var selected: Dictionary = {}
	var selected_order: Array[String] = []
	var candidates: Dictionary = normalized.duplicate(true)
	var forced_key: String = _technique_preferred_bonus_key(preferred_tag)
	if max_keys > 0 and forced_key != "" and candidates.has(forced_key):
		selected[forced_key] = float(candidates[forced_key])
		selected_order.append(forced_key)
		candidates.erase(forced_key)
	while selected_order.size() < max_keys and not candidates.is_empty():
		var best_key: String = ""
		var best_score: float = -1.0
		for bonus_name in candidates:
			var score: float = _technique_bonus_rank_score(str(bonus_name), float(candidates[bonus_name]), preferred_tag)
			if score > best_score:
				best_score = score
				best_key = str(bonus_name)
		if best_key == "":
			break
		selected[best_key] = float(candidates[best_key])
		selected_order.append(best_key)
		candidates.erase(best_key)

	if selected_order.is_empty():
		return normalized
	var primary_key: String = selected_order[0]
	for bonus_name in candidates:
		var value: float = float(candidates[bonus_name])
		if value > 0.0:
			selected[primary_key] = float(selected.get(primary_key, 0.0)) + value * TECHNIQUE_SPLIT_BONUS_CONVERSION
	return selected


func _technique_primary_affix_bonus(item: Dictionary) -> Dictionary:
	var affixes: Array = item.get("affixes", []) as Array
	var primary_tag: String = str(item.get("primary_cultivation_tag", ""))
	var selected_affix: Dictionary = {}
	for affix in affixes:
		if not affix is Dictionary:
			continue
		var affix_data: Dictionary = affix as Dictionary
		if str(affix_data.get("affix_kind", "")) != "cultivation":
			continue
		if selected_affix.is_empty():
			selected_affix = affix_data
		if str(affix_data.get("tag", "")) == primary_tag:
			selected_affix = affix_data
			break
	if selected_affix.is_empty():
		return {}
	var tag: String = str(selected_affix.get("tag", primary_tag))
	var raw_affix_bonuses: Dictionary = selected_affix.get("bonuses", {}) as Dictionary
	var focused: Dictionary = _specialize_technique_bonus_dict(raw_affix_bonuses, tag, TECHNIQUE_MAX_AFFIX_BONUS_KEYS)
	for bonus_name in focused.keys():
		focused[bonus_name] = float(focused[bonus_name]) * TECHNIQUE_AFFIX_BONUS_SCALE
	return focused


func _strip_affix_bonuses(raw_bonuses: Dictionary, affixes: Array) -> Dictionary:
	var bonuses: Dictionary = raw_bonuses.duplicate(true)
	for affix in affixes:
		if not affix is Dictionary:
			continue
		var affix_bonuses: Dictionary = (affix as Dictionary).get("bonuses", {}) as Dictionary
		for bonus_name in affix_bonuses:
			var key: String = str(bonus_name)
			bonuses[key] = float(bonuses.get(key, 0.0)) - float(affix_bonuses[bonus_name])
			if absf(float(bonuses[key])) < 0.0001:
				bonuses.erase(key)
	return bonuses


func _ensure_item_affixes(item: Dictionary, item_kind: String) -> void:
	if item.is_empty() or not (item_kind in ["technique", "treasure", "companion"]):
		return
	if item_kind in ["technique", "treasure"]:
		_normalize_cultivation_item_affixes(item)
		if item_kind == "treasure" and not item.has("affix_bonus"):
			item["affixes_applied"] = false
	elif item_kind == "companion" and not _companion_affixes_valid(item.get("affixes", []) as Array):
		item["affixes"] = _roll_companion_affixes()
		item["affixes_applied"] = false
	elif not item.has("affixes"):
		item["affixes"] = _roll_item_affixes(item, item_kind)
	if not bool(item.get("affixes_applied", false)):
		_apply_affixes_to_item(item, item_kind)
		item["affixes_applied"] = true
	_refresh_item_build_tags(item)


func _roll_item_affixes(item: Dictionary, item_kind: String) -> Array:
	if item_kind in ["technique", "treasure"]:
		return _roll_technique_affixes(item)
	if item_kind == "companion":
		return _roll_companion_affixes()
	var count: int = _quality_affix_count(str(item.get("quality", "筑基级")))
	var result: Array = []
	if count <= 0:
		return result

	var weighted_candidates: Array[Dictionary] = []
	var preferred_tag: String = _item_sect(item)
	for affix in ITEM_AFFIX_POOL:
		var affix_data: Dictionary = affix as Dictionary
		var targets: Array = affix_data.get("targets", []) as Array
		if not targets.has(item_kind):
			continue
		weighted_candidates.append(affix_data)
		if preferred_tag != "" and str(affix_data.get("tag", "")) == preferred_tag:
			weighted_candidates.append(affix_data)
			weighted_candidates.append(affix_data)
	if weighted_candidates.is_empty():
		return result

	var used: Dictionary = {}
	while result.size() < count and used.size() < ITEM_AFFIX_POOL.size():
		var selected: Dictionary = weighted_candidates[rng.randi_range(0, weighted_candidates.size() - 1)] as Dictionary
		var affix_name: String = str(selected.get("name", ""))
		if affix_name == "" or used.has(affix_name):
			continue
		used[affix_name] = true
		result.append(selected.duplicate(true))
	return result


func _companion_affixes_valid(affixes: Array) -> bool:
	var sect_count: int = 0
	for affix in affixes:
		if not affix is Dictionary:
			continue
		var affix_data: Dictionary = affix as Dictionary
		if str(affix_data.get("affix_kind", "")) != "sect":
			return false
		if not SECT_TYPES.has(str(affix_data.get("tag", ""))):
			return false
		sect_count += 1
	return sect_count == 1


func _roll_companion_affixes() -> Array:
	var sect_tag: String = str(SECT_TYPES[rng.randi_range(0, SECT_TYPES.size() - 1)])
	var passive: Dictionary = SECT_PASSIVE.get(sect_tag, {}) as Dictionary
	var alignment: String = str(SECT_ALIGNMENT.get(sect_tag, "正"))
	return [
		{
			"name": "门派·" + sect_tag,
			"tag": sect_tag,
			"affix_kind": "sect",
			"alignment": alignment,
			"desc": alignment + "道伙伴。" + str(passive.get("desc", "契合" + sect_tag + "门派身份")),
		},
	]


func _technique_affixes_valid(affixes: Array) -> bool:
	if affixes.is_empty():
		return false
	var used_tags: Dictionary = {}
	for affix in affixes:
		if not affix is Dictionary:
			return false
		var affix_data: Dictionary = affix as Dictionary
		var tag: String = str(affix_data.get("tag", ""))
		if str(affix_data.get("affix_kind", "")) != "cultivation":
			return false
		if not CULTIVATION_TYPES.has(tag):
			return false
		if used_tags.has(tag):
			return false
		if (affix_data.get("bonuses", {}) as Dictionary).is_empty():
			return false
		used_tags[tag] = true
	return true


func _roll_technique_affixes(item: Dictionary = {}) -> Array:
	var count: int = _quality_affix_count(str(item.get("quality", "筑基级")))
	var preferred_tag: String = _item_cultivation_fallback(item)
	if preferred_tag == "":
		preferred_tag = str(CULTIVATION_TYPES[rng.randi_range(0, CULTIVATION_TYPES.size() - 1)])
	return _make_cultivation_affix_set(preferred_tag, count, [])


func _make_cultivation_affix_set(primary_tag: String, count: int, existing_affixes: Array = []) -> Array:
	var result: Array = []
	var used: Dictionary = {}
	if not CULTIVATION_TYPES.has(primary_tag):
		primary_tag = str(CULTIVATION_TYPES[rng.randi_range(0, CULTIVATION_TYPES.size() - 1)])
	result.append(_make_cultivation_affix(primary_tag))
	used[primary_tag] = true
	for affix in existing_affixes:
		if result.size() >= count:
			break
		if not affix is Dictionary:
			continue
		var affix_data: Dictionary = affix as Dictionary
		var tag: String = str(affix_data.get("tag", ""))
		if str(affix_data.get("affix_kind", "")) != "cultivation" or not CULTIVATION_TYPES.has(tag) or used.has(tag):
			continue
		result.append(_make_cultivation_affix(tag))
		used[tag] = true
	var guard: int = 0
	while result.size() < count and used.size() < CULTIVATION_TYPES.size() and guard < 32:
		guard += 1
		var tag: String = str(CULTIVATION_TYPES[rng.randi_range(0, CULTIVATION_TYPES.size() - 1)])
		if used.has(tag):
			continue
		result.append(_make_cultivation_affix(tag))
		used[tag] = true
	return result


func _make_cultivation_affix(cultivation_tag: String) -> Dictionary:
	if not CULTIVATION_TYPES.has(cultivation_tag):
		cultivation_tag = str(CULTIVATION_TYPES[rng.randi_range(0, CULTIVATION_TYPES.size() - 1)])
	var growth: Dictionary = TREASURE_GROWTH.get(cultivation_tag, {}) as Dictionary
	var bond: Dictionary = CULTIVATION_BOND_DATA.get(cultivation_tag, {}) as Dictionary
	return {
		"name": str(bond.get("name", growth.get("name", cultivation_tag))),
		"tag": cultivation_tag,
		"affix_kind": "cultivation",
		"bonuses": (bond.get("bonuses", {}) as Dictionary).duplicate(true),
		"specials": (bond.get("specials", {}) as Dictionary).duplicate(true),
		"desc": str(bond.get("desc", "")) + " " + str(growth.get("trigger", "")),
	}


func _find_cultivation_affix_tag(affixes: Array) -> String:
	for affix in affixes:
		if not affix is Dictionary:
			continue
		var affix_data: Dictionary = affix as Dictionary
		var tag: String = str(affix_data.get("tag", ""))
		if str(affix_data.get("affix_kind", "")) == "cultivation" and CULTIVATION_TYPES.has(tag):
			return tag
	return ""


func _item_cultivation_fallback(item: Dictionary) -> String:
	var fallback_tags: Array[String] = [
		str(item.get("cultivation_affix", "")),
		str(item.get("growth_type", "")),
		str(item.get("school", "")),
		str(item.get("sect", "")),
	]
	for tag in fallback_tags:
		if CULTIVATION_TYPES.has(tag):
			return tag
	return ""


func _normalize_cultivation_item_affixes(item: Dictionary) -> void:
	var affixes: Array = item.get("affixes", []) as Array
	var quality: String = str(item.get("quality", "筑基级"))
	var target_count: int = _quality_affix_count(quality)
	var cultivation_tag: String = str(item.get("primary_cultivation_tag", ""))
	if not CULTIVATION_TYPES.has(cultivation_tag):
		cultivation_tag = _find_cultivation_affix_tag(affixes)
	if cultivation_tag == "":
		cultivation_tag = _item_cultivation_fallback(item)
	if cultivation_tag == "":
		cultivation_tag = str(CULTIVATION_TYPES[rng.randi_range(0, CULTIVATION_TYPES.size() - 1)])
	if _technique_affixes_valid(affixes) and affixes.size() == target_count and str(item.get("primary_cultivation_tag", cultivation_tag)) == cultivation_tag:
		item["affix_count"] = target_count
		item["primary_cultivation_tag"] = cultivation_tag
		return
	item["affixes"] = _make_cultivation_affix_set(cultivation_tag, target_count, affixes)
	item["affix_count"] = target_count
	item["primary_cultivation_tag"] = cultivation_tag
	item["affixes_applied"] = false


func _quality_affix_count(quality: String) -> int:
	match quality:
		"炼气级", "筑基级":
			return 1
		"金丹级", "元婴级":
			return 2
		"化神级":
			return 3
		"合体级":
			return 4
		_:
			return 1


func get_quality_affix_count(quality: String) -> int:
	return _quality_affix_count(quality)


func _apply_affixes_to_item(item: Dictionary, item_kind: String) -> void:
	if item_kind == "companion":
		var companion_bonuses: Dictionary = {}
		var companion_affixes: Array = item.get("affixes", []) as Array
		for companion_affix in companion_affixes:
			if not companion_affix is Dictionary:
				continue
			var companion_affix_bonuses: Dictionary = (companion_affix as Dictionary).get("bonuses", {}) as Dictionary
			for companion_bonus_name in companion_affix_bonuses:
				var companion_key: String = str(companion_bonus_name)
				companion_bonuses[companion_key] = float(companion_bonuses.get(companion_key, 0.0)) + float(companion_affix_bonuses[companion_bonus_name])
		item["affix_bonus"] = companion_bonuses
		return
	if item_kind == "technique":
		var primary_tag: String = str(item.get("primary_cultivation_tag", ""))
		var raw_base: Dictionary = item.get("base_bonuses", item.get("bonuses", {})) as Dictionary
		var base_bonuses: Dictionary = _specialize_technique_bonus_dict(raw_base, primary_tag, TECHNIQUE_MAX_BASE_BONUS_KEYS)
		var affix_bonus: Dictionary = _technique_primary_affix_bonus(item)
		var final_bonuses: Dictionary = base_bonuses.duplicate(true)
		for bonus_name in affix_bonus:
			var key: String = str(bonus_name)
			final_bonuses[key] = float(final_bonuses.get(key, 0.0)) + float(affix_bonus[bonus_name])
		item["base_bonuses"] = base_bonuses
		item["affix_bonus"] = affix_bonus
		item["bonuses"] = _specialize_technique_bonus_dict(final_bonuses, primary_tag, TECHNIQUE_MAX_TOTAL_BONUS_KEYS)
		return
	var bonus_key: String = "bonuses" if item_kind == "technique" else "passive_bonus"
	var bonuses: Dictionary = {}
	if item_kind != "treasure":
		bonuses = (item.get(bonus_key, {}) as Dictionary).duplicate(true)

	var affixes: Array = item.get("affixes", []) as Array
	for affix in affixes:
		if not affix is Dictionary:
			continue
		var affix_bonuses: Dictionary = (affix as Dictionary).get("bonuses", {}) as Dictionary
		for bonus_name in affix_bonuses:
			var key: String = str(bonus_name)
			bonuses[key] = float(bonuses.get(key, 0.0)) + float(affix_bonuses[bonus_name])

	if item_kind == "treasure":
		item["base_passive_bonus"] = bonuses.duplicate(true)
		item["affix_bonus"] = bonuses.duplicate(true)
	item[bonus_key] = bonuses


func _refresh_item_build_tags(item: Dictionary) -> void:
	var tags: Array[String] = []
	var item_sect: String = _item_sect(item)
	if item_sect != "":
		tags.append(item_sect)
	var affixes: Array = item.get("affixes", []) as Array
	for affix in affixes:
		if not affix is Dictionary:
			continue
		var tag: String = str((affix as Dictionary).get("tag", ""))
		if _is_build_tag(tag) and not tags.has(tag):
			tags.append(tag)
	item["build_tags"] = tags


func _is_build_tag(tag: String) -> bool:
	return CULTIVATION_TYPES.has(tag) or SECT_TYPES.has(tag)


func check_resonance(player: PlayerData) -> Array:
	return []


func _detect_player_school(player: PlayerData) -> String:
	return _best_cultivation_type(player)


func _player_has_school(player: PlayerData, school: String) -> bool:
	if player == null:
		return false
	for technique in player.techniques:
		if technique is Dictionary and _item_build_tags(technique as Dictionary).has(school):
			return true
	for treasure in player.treasures:
		if treasure is Dictionary and _item_build_tags(treasure as Dictionary).has(school):
			return true
	for entry in player.backpack:
		if entry is Dictionary:
			var entry_data: Dictionary = (entry as Dictionary).get("data", {}) as Dictionary
			if _item_build_tags(entry_data).has(school):
				return true
	return false


func _school_power(player: PlayerData, school: String) -> float:
	if player == null:
		return 0.0
	var routes: Dictionary = _calculate_cultivation_routes(player)
	var route: Dictionary = routes.get(school, {}) as Dictionary
	if int(route.get("level", 0)) <= 0:
		return 0.0
	return float(route.get("strength", 0.0))


func _cultivation_route_data(player: PlayerData, school: String) -> Dictionary:
	if player == null or school == "":
		return {}
	var routes: Dictionary = player.final_attributes.get("cultivation_routes", {}) as Dictionary
	if routes.has(school):
		return routes.get(school, {}) as Dictionary
	routes = _calculate_cultivation_routes(player)
	return routes.get(school, {}) as Dictionary


func _cultivation_route_level(player: PlayerData, school: String) -> int:
	var route: Dictionary = _cultivation_route_data(player, school)
	return int(route.get("level", 0))


func _cultivation_route_strength(player: PlayerData, school: String) -> float:
	var route: Dictionary = _cultivation_route_data(player, school)
	if int(route.get("level", 0)) <= 0:
		return 0.0
	return float(route.get("strength", 0.0))


func _has_cultivation_mechanic(player: PlayerData, school: String) -> bool:
	return _cultivation_route_level(player, school) >= 1


func _quality_power(quality: String) -> float:
	var data: Dictionary = QUALITY_DATA.get(quality, {}) as Dictionary
	return float(data.get("quality_factor", 1.0))


func _quality_data_value(quality: String, key: String, fallback: Variant) -> Variant:
	var data: Dictionary = QUALITY_DATA.get(quality, {}) as Dictionary
	return data.get(key, fallback)


func _technique_quality_multiplier(technique: Dictionary) -> float:
	var quality: String = str(technique.get("quality", "金丹级"))
	return float(QUALITY_MULTIPLIER.get(quality, 1.0))


func _technique_effect_multiplier_total(technique: Dictionary) -> float:
	return _technique_stage_multiplier(technique) * _technique_quality_multiplier(technique)


func get_technique_effective_bonuses(technique: Dictionary, stage_override: String = "") -> Dictionary:
	var bonuses: Dictionary = technique.get("bonuses", technique.get("base_bonuses", {})) as Dictionary
	var stage_copy: Dictionary = technique
	if stage_override != "":
		stage_copy = technique.duplicate(true)
		stage_copy["technique_realm"] = stage_override
	var multiplier: float = _technique_effect_multiplier_total(stage_copy)
	var result: Dictionary = {}
	for bonus_name in bonuses:
		result[str(bonus_name)] = float(bonuses[bonus_name]) * multiplier
	return result


func get_technique_stage_multiplier_text(stage_name: String) -> String:
	var value: float = float(TECHNIQUE_STAGE_MULTIPLIERS.get(stage_name, 1.2))
	var rounded: float = round(value * 10.0) / 10.0
	if absf(rounded - round(rounded)) < 0.01:
		return "×" + str(int(round(rounded)))
	return "×" + str(rounded)


func _technique_stage_multiplier(technique: Dictionary) -> float:
	return float(TECHNIQUE_STAGE_MULTIPLIERS.get(str(technique.get("technique_realm", "初窥")), 1.2))


func _equipped_identity_items(player: PlayerData) -> Array[Dictionary]:
	var items: Array[Dictionary] = []
	if player == null:
		return items
	for i in range(MAX_COMPANIONS):
		if i >= player.companions.size():
			continue
		if player.companions[i] is Dictionary:
			items.append({"kind": "companion", "data": player.companions[i] as Dictionary})
	return items


func _equipped_cultivation_items(player: PlayerData) -> Array[Dictionary]:
	var items: Array[Dictionary] = []
	if player == null:
		return items
	for i in range(MAX_EQUIPPED_TECHNIQUES):
		if i >= player.techniques.size():
			continue
		if player.techniques[i] is Dictionary:
			items.append({"kind": "technique", "data": player.techniques[i] as Dictionary})
	if not player.treasures.is_empty() and player.treasures[0] is Dictionary:
		items.append({"kind": "treasure", "data": player.treasures[0] as Dictionary})
	return items


func _item_sect_tag(item_data: Dictionary) -> String:
	var affixes: Array = item_data.get("affixes", []) as Array
	for affix in affixes:
		if not affix is Dictionary:
			continue
		var affix_data: Dictionary = affix as Dictionary
		var tag: String = str(affix_data.get("tag", ""))
		if str(affix_data.get("affix_kind", "")) == "sect" and SECT_TYPES.has(tag):
			return tag
	var direct_tags: Array[String] = [
		str(item_data.get("sect_affix", "")),
		str(item_data.get("sect_support", "")),
		str(item_data.get("sect", "")),
	]
	for tag in direct_tags:
		if SECT_TYPES.has(tag):
			return tag
	return ""


func _item_cultivation_tag(item_data: Dictionary) -> String:
	var primary_tag: String = str(item_data.get("primary_cultivation_tag", ""))
	if CULTIVATION_TYPES.has(primary_tag):
		return primary_tag
	var affixes: Array = item_data.get("affixes", []) as Array
	for affix in affixes:
		if not affix is Dictionary:
			continue
		var affix_data: Dictionary = affix as Dictionary
		var tag: String = str(affix_data.get("tag", ""))
		if str(affix_data.get("affix_kind", "")) == "cultivation" and CULTIVATION_TYPES.has(tag):
			return tag
	var fallback_tags: Array[String] = [
		str(item_data.get("cultivation_affix", "")),
		str(item_data.get("growth_type", "")),
		str(item_data.get("school", "")),
	]
	for tag in fallback_tags:
		if CULTIVATION_TYPES.has(tag):
			return tag
	return ""


func _item_cultivation_tags(item_data: Dictionary) -> Array[String]:
	var tags: Array[String] = []
	var primary_tag: String = _item_cultivation_tag(item_data)
	if primary_tag != "":
		tags.append(primary_tag)
	var affixes: Array = item_data.get("affixes", []) as Array
	for affix in affixes:
		if not affix is Dictionary:
			continue
		var affix_data: Dictionary = affix as Dictionary
		var tag: String = str(affix_data.get("tag", ""))
		if str(affix_data.get("affix_kind", "")) == "cultivation" and CULTIVATION_TYPES.has(tag) and not tags.has(tag):
			tags.append(tag)
	return tags


func _calculate_identity_routes(player: PlayerData) -> Dictionary:
	var routes: Dictionary = {}
	for sect_name in SECT_TYPES:
		routes[str(sect_name)] = {
			"sect": str(sect_name),
			"score": 0.0,
			"components": 0,
			"quality": 0.0,
			"bond": 0,
			"techniques": 0,
			"treasures": 0,
			"companions": 0,
		}
	if player == null:
		return routes
	for item in _equipped_identity_items(player):
		var item_kind: String = str(item.get("kind", ""))
		var data: Dictionary = item.get("data", {}) as Dictionary
		if item_kind == "technique":
			data = _prepare_technique(data)
		elif item_kind == "treasure":
			data = _prepare_treasure(data, _player_sect(player))
		elif item_kind == "companion":
			_prepare_companion(data, player)
		var sect_name: String = _item_sect_tag(data)
		if not routes.has(sect_name):
			continue
		var route: Dictionary = routes[sect_name] as Dictionary
		route["components"] = int(route.get("components", 0)) + 1
		route["quality"] = float(route.get("quality", 0.0)) + _quality_power(str(data.get("quality", "炼气级")))
		match item_kind:
			"technique":
				route["techniques"] = int(route.get("techniques", 0)) + 1
			"treasure":
				route["treasures"] = int(route.get("treasures", 0)) + 1
			"companion":
				route["companions"] = int(route.get("companions", 0)) + 1
				route["bond"] = int(route.get("bond", 0)) + int(data.get("bond", 0))
		route["score"] = float(route.get("components", 0)) + float(route.get("bond", 0)) * 0.5 + float(route.get("quality", 0.0))
		routes[sect_name] = route
	for sect_name in SECT_TYPES:
		var route_data: Dictionary = routes[str(sect_name)] as Dictionary
		var event_scores: Dictionary = player.final_attributes.get("sect_event_score_bonus", {}) as Dictionary
		var event_bonus: float = float(event_scores.get(str(sect_name), 0.0))
		if not is_zero_approx(event_bonus):
			route_data["event_bonus"] = event_bonus
			route_data["score"] = maxf(0.0, float(route_data.get("score", 0.0)) + event_bonus)
		var score: float = float(route_data.get("score", 0.0))
		var level: int = get_identity_level_for_score(score)
		route_data["level"] = level
		route_data["level_name"] = get_identity_level_short(level)
		route_data["next_score"] = _identity_next_score(level)
		routes[str(sect_name)] = route_data
	return routes


func _best_identity_route(routes: Dictionary) -> Dictionary:
	var best_route: Dictionary = {}
	var best_score: float = -1.0
	var best_components: int = -1
	var best_quality: float = -1.0
	for sect_name in SECT_TYPES:
		var route: Dictionary = routes.get(str(sect_name), {}) as Dictionary
		var score: float = float(route.get("score", 0.0))
		var components: int = int(route.get("components", 0))
		var quality: float = float(route.get("quality", 0.0))
		if score > best_score or (is_equal_approx(score, best_score) and (components > best_components or (components == best_components and quality > best_quality))):
			best_score = score
			best_components = components
			best_quality = quality
			best_route = route
	if best_score <= 0.0:
		return {"sect": "散修", "score": 0.0, "level": 0, "level_name": "散修"}
	return best_route


func _cultivation_bond_level(count: int) -> int:
	if count >= 5:
		return 4
	if count >= 4:
		return 3
	if count >= 3:
		return 2
	if count >= 2:
		return 1
	return 0


func _cultivation_next_count(level: int) -> int:
	match level:
		0:
			return 2
		1:
			return 3
		2:
			return 4
		3:
			return 5
		_:
			return MAX_CULTIVATION_SET_COUNT


func _cultivation_bond_multiplier(level: int) -> float:
	return float(CULTIVATION_BOND_MULTIPLIERS.get(level, 0.0))


func _calculate_cultivation_routes(player: PlayerData) -> Dictionary:
	var routes: Dictionary = {}
	for cultivation_type in CULTIVATION_TYPES:
		routes[str(cultivation_type)] = {
			"cultivation": str(cultivation_type),
			"count": 0,
			"quality": 0.0,
			"realm": 0.0,
			"techniques": 0,
			"treasures": 0,
			"level": 0,
			"strength": 0.0,
			"bonuses": {},
			"specials": {},
			"next_count": 2,
		}
	if player == null:
		return routes
	for item in _equipped_cultivation_items(player):
		var item_kind: String = str(item.get("kind", ""))
		var data: Dictionary = item.get("data", {}) as Dictionary
		if item_kind == "technique":
			data = _prepare_technique(data)
		elif item_kind == "treasure":
			data = _prepare_treasure(data, _player_sect(player))
		var cultivation_tags: Array[String] = _item_cultivation_tags(data)
		if cultivation_tags.is_empty():
			continue
		for cultivation_type in cultivation_tags:
			if not routes.has(cultivation_type):
				continue
			var route: Dictionary = routes[cultivation_type] as Dictionary
			route["count"] = int(route.get("count", 0)) + 1
			route["quality"] = float(route.get("quality", 0.0)) + _quality_power(str(data.get("quality", "炼气级")))
			if item_kind == "technique":
				route["techniques"] = int(route.get("techniques", 0)) + 1
				route["realm"] = float(route.get("realm", 0.0)) + _technique_stage_multiplier(data)
			elif item_kind == "treasure":
				route["treasures"] = int(route.get("treasures", 0)) + 1
				route["realm"] = float(route.get("realm", 0.0)) + 1.0
			routes[cultivation_type] = route
	for cultivation_type in CULTIVATION_TYPES:
		var route_data: Dictionary = routes[str(cultivation_type)] as Dictionary
		var count: int = int(route_data.get("count", 0))
		var level: int = _cultivation_bond_level(count)
		var strength: float = 0.0
		if level > 0:
			var avg_quality: float = float(route_data.get("quality", 0.0)) / float(maxi(1, count))
			var avg_realm: float = float(route_data.get("realm", 0.0)) / float(maxi(1, count))
			strength = _cultivation_bond_multiplier(level) * (0.75 + avg_quality * 0.12 + avg_realm * 0.12)
		route_data["level"] = level
		route_data["level_name"] = _cultivation_bond_level_name(level)
		route_data["strength"] = strength
		route_data["next_count"] = _cultivation_next_count(level)
		if level > 0:
			var bond_data: Dictionary = CULTIVATION_BOND_DATA.get(str(cultivation_type), {}) as Dictionary
			var route_bonuses: Dictionary = {}
			var bond_bonuses: Dictionary = bond_data.get("bonuses", {}) as Dictionary
			for bonus_name in bond_bonuses:
				route_bonuses[str(bonus_name)] = float(bond_bonuses[bonus_name]) * strength
			var route_specials: Dictionary = {}
			var bond_specials: Dictionary = bond_data.get("specials", {}) as Dictionary
			for special_name in bond_specials:
				route_specials[str(special_name)] = float(bond_specials[special_name]) * strength
			route_data["bonuses"] = route_bonuses
			route_data["specials"] = route_specials
		routes[str(cultivation_type)] = route_data
	return routes


func _cultivation_bond_level_name(level: int) -> String:
	match level:
		1:
			return "质变"
		2:
			return "强化"
		3:
			return "圆融"
		4:
			return "归一"
		_:
			return "未成"


func _best_cultivation_route(routes: Dictionary) -> Dictionary:
	var best_route: Dictionary = {}
	var best_count: int = 0
	var best_level: int = 0
	var best_strength: float = 0.0
	for cultivation_type in CULTIVATION_TYPES:
		var route: Dictionary = routes.get(str(cultivation_type), {}) as Dictionary
		var count: int = int(route.get("count", 0))
		var level: int = int(route.get("level", 0))
		var strength: float = float(route.get("strength", 0.0))
		if level > best_level or (level == best_level and (count > best_count or (count == best_count and strength > best_strength))):
			best_level = level
			best_count = count
			best_strength = strength
			best_route = route
	if best_count <= 0:
		return {"cultivation": "散修", "count": 0, "level": 0, "level_name": "未成", "strength": 0.0, "bonuses": {}, "specials": {}, "next_count": 2}
	return best_route


func _best_cultivation_type(player: PlayerData) -> String:
	if player == null:
		return "散修"
	var routes: Dictionary = _calculate_cultivation_routes(player)
	var best_route: Dictionary = _best_cultivation_route(routes)
	return str(best_route.get("cultivation", "散修"))


func _identity_level_data(level: int) -> Dictionary:
	for row in IDENTITY_LEVELS:
		var data: Dictionary = row as Dictionary
		if int(data.get("level", 0)) == level:
			return data
	return IDENTITY_LEVELS[0] as Dictionary


func get_identity_level_for_score(score: float) -> int:
	if score >= 51.0:
		return 5
	if score >= 33.0:
		return 4
	if score >= 21.0:
		return 3
	if score >= 11.0:
		return 2
	if score >= 4.0:
		return 1
	return 0


func get_identity_level_name(level: int) -> String:
	var data: Dictionary = _identity_level_data(level)
	return str(data.get("name", "散修"))


func get_identity_level_short(level: int) -> String:
	var data: Dictionary = _identity_level_data(level)
	return str(data.get("short", get_identity_level_name(level)))


func _identity_next_score(level: int) -> float:
	match level:
		0:
			return 4.0
		1:
			return 11.0
		2:
			return 21.0
		3:
			return 33.0
		4:
			return 51.0
		_:
			return 51.0


func _identity_passive_multiplier(level: int) -> float:
	var data: Dictionary = _identity_level_data(level)
	return float(data.get("passive_multiplier", 0.0))


func _identity_card_bonus(level: int) -> float:
	var data: Dictionary = _identity_level_data(level)
	return float(data.get("card_bonus", 0.0))


func _identity_round_stones(level: int) -> int:
	var data: Dictionary = _identity_level_data(level)
	return int(data.get("round_stones", 0))


func _refresh_identity_state(player: PlayerData, routes: Dictionary, best_route: Dictionary) -> void:
	if player == null:
		return
	var score: float = float(best_route.get("score", 0.0))
	var level: int = get_identity_level_for_score(score)
	var sect_name: String = str(best_route.get("sect", "散修"))
	if level <= 0 and score <= 0.0:
		sect_name = "散修"
	var cultivation_type: String = _best_cultivation_type(player)
	player.sect = sect_name if SECT_TYPES.has(sect_name) else ""
	player.resonance_level = level
	player.resonance_bonus = {}
	player.final_attributes["identity_routes"] = routes
	player.final_attributes["identity_score"] = score
	player.final_attributes["identity_level"] = level
	player.final_attributes["identity_title"] = get_identity_level_name(level)
	player.final_attributes["identity_title_short"] = get_identity_level_short(level)
	player.final_attributes["identity_sect"] = sect_name
	player.final_attributes["cultivation_type"] = cultivation_type
	player.final_attributes["resonance_name"] = get_identity_level_name(level)
	player.final_attributes["identity_passive_multiplier"] = _identity_passive_multiplier(level)
	player.final_attributes["sect_card_bonus"] = _identity_card_bonus(level)
	player.final_attributes["identity_round_stones"] = _identity_round_stones(level)
	player.final_attributes["identity_transformation_unlocked"] = bool(_identity_level_data(level).get("transformation", false))
	player.final_attributes["resonance_counts"] = {
		"组件": int(best_route.get("components", 0)),
		"功法": int(best_route.get("techniques", 0)),
		"法宝": int(best_route.get("treasures", 0)),
		"伙伴": int(best_route.get("companions", 0)),
	}
	player.final_attributes["treasure_growth_speed"] = _identity_passive_value(player, "器府")


func _refresh_cultivation_bond_state(player: PlayerData) -> void:
	if player == null:
		return
	var routes: Dictionary = _calculate_cultivation_routes(player)
	var best_route: Dictionary = _best_cultivation_route(routes)
	var cultivation_type: String = str(best_route.get("cultivation", "散修"))
	var level: int = int(best_route.get("level", 0))
	var bonuses: Dictionary = {}
	var specials: Dictionary = {}
	if level > 0:
		bonuses = (best_route.get("bonuses", {}) as Dictionary).duplicate(true)
		specials = (best_route.get("specials", {}) as Dictionary).duplicate(true)
	player.final_attributes["cultivation_routes"] = routes
	player.final_attributes["cultivation_type"] = cultivation_type
	player.final_attributes["identity_cultivation"] = cultivation_type
	player.final_attributes["cultivation_bond_type"] = cultivation_type
	player.final_attributes["cultivation_bond_level"] = level
	player.final_attributes["cultivation_bond_level_name"] = str(best_route.get("level_name", _cultivation_bond_level_name(level)))
	player.final_attributes["cultivation_bond_count"] = int(best_route.get("count", 0))
	player.final_attributes["cultivation_bond_strength"] = float(best_route.get("strength", 0.0))
	player.final_attributes["cultivation_bonus"] = bonuses
	player.final_attributes["cultivation_specials"] = specials
	player.final_attributes["treasure_effect_chance"] = float(specials.get("treasure_effect_chance", 0.0))
	player.final_attributes["treasure_growth_speed"] = _identity_passive_value(player, "器府") + float(specials.get("treasure_growth_speed", 0.0))


func _identity_stat_sum(player: PlayerData, sect_name: String) -> int:
	if player == null or not SECT_STATS.has(sect_name):
		return 0
	var stats: Array = SECT_STATS[sect_name] as Array
	var total: int = 0
	for stat_name in stats:
		total += int(player.stats.get(str(stat_name), 0))
	return total


func _identity_passive_value(player: PlayerData, sect_name: String) -> float:
	if player == null:
		return 0.0
	if str(player.final_attributes.get("identity_sect", "")) != sect_name:
		return 0.0
	var level: int = int(player.final_attributes.get("identity_level", player.resonance_level))
	var multiplier: float = _identity_passive_multiplier(level)
	if multiplier <= 0.0:
		return 0.0
	if int(player.final_attributes.get("sect_passive_halved_until", -1)) >= round_number:
		multiplier *= 0.5
	var stat_sum: float = float(_identity_stat_sum(player, sect_name))
	match sect_name:
		"万魂殿":
			return stat_sum * 2.0 * multiplier
		"金刚寺":
			return stat_sum * 0.015 * multiplier
		"天剑阁":
			return stat_sum * 0.5 * multiplier
		"百花谷":
			return stat_sum * 50.0 * multiplier
		"丹霞山":
			return stat_sum * 0.008 * multiplier
		"阵宗":
			return stat_sum * 0.008 * multiplier
		"符箓门":
			return stat_sum * 0.008 * multiplier
		"器府":
			return stat_sum * 0.02 * multiplier
		_:
			return 0.0


func _apply_identity_bargain_passive(player: PlayerData, result: Dictionary, card: Dictionary) -> String:
	if player == null or str(card.get("type", "")) != "机缘":
		return ""
	var choice: String = str(result.get("choice", ""))
	var messages: Array[String] = []
	var sect_name: String = str(player.final_attributes.get("identity_sect", ""))
	if sect_name == "万魂殿" and choice == "抢" and float(result.get("gain", 0.0)) > 0.0:
		var soul_value: float = _identity_passive_value(player, "万魂殿")
		if soul_value > 0.0:
			var before_stage: String = get_cultivation_stage_name(player)
			var ling_li: int = maxi(1, int(round(soul_value)))
			player.ling_li += ling_li
			messages.append(_append_stage_change_to_message(player, before_stage, "万魂殿夺机缘，灵力 +" + str(ling_li)))
	if sect_name == "百花谷" and choice == "让":
		var flower_value: float = _identity_passive_value(player, "百花谷")
		if flower_value > 0.0:
			var stones: int = maxi(1, int(round(flower_value)))
			player.ling_shi += stones
			messages.append("百花谷让机缘，灵石 +" + str(stones))
	return "；".join(messages)


func _apply_round_identity_passives(player: PlayerData) -> String:
	if player == null:
		return ""
	var messages: Array[String] = []
	var level: int = int(player.final_attributes.get("identity_level", player.resonance_level))
	var stone_income: int = _identity_round_stones(level)
	if stone_income > 0:
		player.ling_shi += stone_income
		messages.append(get_identity_level_short(level) + "俸禄，灵石 +" + str(stone_income))
	if str(player.final_attributes.get("identity_sect", "")) == "丹霞山":
		var heal_rate: float = _identity_passive_value(player, "丹霞山")
		if heal_rate > 0.0:
			var max_hp: int = _get_player_max_hp(player)
			var old_hp: int = player.qi_xue
			var heal: int = maxi(1, int(round(float(max_hp) * heal_rate)))
			player.qi_xue = mini(max_hp, player.qi_xue + heal)
			if player.qi_xue > old_hp:
				messages.append("丹霞山回春，气血 +" + str(player.qi_xue - old_hp))
	var cultivation_heal_rate: float = _sum_player_bonus(player, "每轮回血")
	if cultivation_heal_rate > 0.0:
		var cultivation_max_hp: int = _get_player_max_hp(player)
		var cultivation_old_hp: int = player.qi_xue
		var cultivation_heal: int = maxi(1, int(round(float(cultivation_max_hp) * clampf(cultivation_heal_rate, 0.0, 0.35))))
		player.qi_xue = mini(cultivation_max_hp, player.qi_xue + cultivation_heal)
		if player.qi_xue > cultivation_old_hp:
			messages.append("修行回春，气血 +" + str(player.qi_xue - cultivation_old_hp))
	var message: String = "；".join(messages)
	player.final_attributes["last_round_identity_message"] = message
	return message


func _identity_announcement_data(player: PlayerData, sect_name: String, old_level: int, new_level: int) -> Dictionary:
	var title: String = _identity_announcement_title(player, sect_name, old_level, new_level)
	return {
		"player_name": player.player_name if player != null else "",
		"peer_id": player.peer_id if player != null else 0,
		"sect": sect_name,
		"level": new_level,
		"old_level": old_level,
		"resonance_name": get_identity_level_name(new_level),
		"title": title,
		"duration": 2.0,
		"color": _sect_color_hex(sect_name, new_level),
	}


func _identity_announcement_title(player: PlayerData, sect_name: String, _old_level: int, new_level: int) -> String:
	var player_name: String = player.player_name if player != null else "修士"
	match new_level:
		1:
			return player_name + "加入" + sect_name + "，成为外门弟子"
		2:
			return player_name + "晋升" + sect_name + "内门弟子"
		3:
			return player_name + "被收为" + sect_name + "亲传弟子"
		4:
			return player_name + "成为" + sect_name + "长老"
		5:
			return player_name + "执掌" + sect_name + "，成为宗主！"
		_:
			return player_name + "身份变化"


func get_identity_display_text(player: PlayerData, _compact: bool = false) -> String:
	if player == null:
		return "【散修】"
	var sect_name: String = str(player.final_attributes.get("identity_sect", "散修"))
	var cultivation_type: String = str(player.final_attributes.get("cultivation_type", "散修"))
	var title: String = str(player.final_attributes.get("identity_title_short", get_identity_level_short(int(player.final_attributes.get("identity_level", 0)))))
	return "【" + sect_name + "·" + cultivation_type + "·" + title + "】"


func get_identity_color_hex(player: PlayerData) -> String:
	if player == null:
		return "#8a8070"
	return _sect_color_hex(str(player.final_attributes.get("identity_sect", player.sect)), int(player.final_attributes.get("identity_level", 0)))


func check_set_bonus(player: PlayerData) -> String:
	if player == null:
		return ""
	_refresh_companion_identity_scores(player)
	var old_level: int = int(player.final_attributes.get("identity_level", player.resonance_level))
	var routes: Dictionary = _calculate_identity_routes(player)
	var best_route: Dictionary = _best_identity_route(routes)
	var sect_name: String = str(best_route.get("sect", "散修"))
	var new_level: int = get_identity_level_for_score(float(best_route.get("score", 0.0)))
	_refresh_identity_state(player, routes, best_route)
	_refresh_cultivation_bond_state(player)
	_refresh_owned_treasure_growth_caps(player)

	if new_level > old_level and new_level > 0:
		var highest_announced_level: int = int(player.final_attributes.get("identity_highest_announced_level", old_level))
		if new_level <= highest_announced_level:
			return ""
		player.final_attributes["identity_highest_announced_level"] = new_level
		var announcement: Dictionary = _identity_announcement_data(player, sect_name, old_level, new_level)
		var message: String = str(announcement.get("title", "身份晋升"))
		player.final_attributes["set_bonus_message"] = message
		if NetworkManager.is_host and NetworkManager.connected and not single_player_mode:
			NetworkManager.send_message("set_bonus_triggered", announcement)
		set_bonus_triggered.emit(announcement)
		return message
	return ""


func get_set_bonus_progress(player: PlayerData) -> Dictionary:
	if player == null:
		return {"sect": "散修", "cultivation": "散修", "level": 0, "score": 0.0, "total": 0, "techniques": 0, "treasures": 0, "companions": 0, "next": 4.0, "routes": {}}
	var routes: Dictionary = _calculate_identity_routes(player)
	var best_route: Dictionary = _best_identity_route(routes)
	var cultivation_routes: Dictionary = _calculate_cultivation_routes(player)
	var best_cultivation: Dictionary = _best_cultivation_route(cultivation_routes)
	var score: float = float(best_route.get("score", 0.0))
	var level: int = get_identity_level_for_score(score)
	return {
		"sect": str(best_route.get("sect", "散修")),
		"cultivation": str(best_cultivation.get("cultivation", "散修")),
		"cultivation_level": int(best_cultivation.get("level", 0)),
		"cultivation_count": int(best_cultivation.get("count", 0)),
		"cultivation_next": int(best_cultivation.get("next_count", 2)),
		"cultivation_strength": float(best_cultivation.get("strength", 0.0)),
		"level": level,
		"level_name": get_identity_level_short(level),
		"score": score,
		"total": int(best_route.get("components", 0)),
		"techniques": int(best_route.get("techniques", 0)),
		"treasures": int(best_route.get("treasures", 0)),
		"companions": int(best_route.get("companions", 0)),
		"quality": float(best_route.get("quality", 0.0)),
		"bond": int(best_route.get("bond", 0)),
		"next": _identity_next_score(level),
		"routes": routes,
	}


func get_cultivation_build_progress(player: PlayerData) -> Dictionary:
	if player == null:
		return {"cultivation": "散修", "level": 0, "level_name": "未成", "count": 0, "next_count": 2, "strength": 0.0, "routes": {}}
	var routes: Dictionary = _calculate_cultivation_routes(player)
	var best_route: Dictionary = _best_cultivation_route(routes)
	return {
		"cultivation": str(best_route.get("cultivation", "散修")),
		"level": int(best_route.get("level", 0)),
		"level_name": str(best_route.get("level_name", "未成")),
		"count": int(best_route.get("count", 0)),
		"next_count": int(best_route.get("next_count", 2)),
		"strength": float(best_route.get("strength", 0.0)),
		"routes": routes,
	}


func get_cultivation_build_hint(player: PlayerData) -> String:
	var progress: Dictionary = get_cultivation_build_progress(player)
	var cultivation_type: String = str(progress.get("cultivation", "散修"))
	var count: int = int(progress.get("count", 0))
	var level: int = int(progress.get("level", 0))
	var level_name: String = str(progress.get("level_name", "未成"))
	var next_count: int = int(progress.get("next_count", 2))
	if count <= 0 or cultivation_type == "散修":
		return "构筑：先装备带同修词条的功法/法宝；4本功法+1件法宝共5件，任意同修2件开机制。"
	var bond: Dictionary = CULTIVATION_BOND_DATA.get(cultivation_type, {}) as Dictionary
	var growth: Dictionary = TREASURE_GROWTH.get(cultivation_type, {}) as Dictionary
	var target_text: String = "已归一"
	if level <= 0:
		target_text = "还差" + str(maxi(0, 2 - count)) + "件开质变"
	elif level < 4:
		target_text = "下一档还差" + str(maxi(0, next_count - count)) + "件"
	var mechanic: String = str(bond.get("mechanic", "同修词条触发机制"))
	var growth_text: String = str(growth.get("trigger", "按对应行为成长"))
	return "构筑：" + cultivation_type + " " + str(count) + "/" + str(MAX_CULTIVATION_SET_COUNT) + "｜" + level_name + "｜" + target_text + "\n机制：" + mechanic + "\n养成：" + growth_text


func get_affix_build_routes(player: PlayerData) -> Dictionary:
	return _calculate_cultivation_routes(player)


func get_affix_description_lines(sect_name: String) -> Array[String]:
	var lines: Array[String] = []
	if CULTIVATION_BOND_DATA.has(sect_name):
		var bond: Dictionary = CULTIVATION_BOND_DATA[sect_name] as Dictionary
		lines.append("质变：" + str(bond.get("name", sect_name)) + "，凑齐2件立即生效")
		lines.append(str(bond.get("desc", "")))
		if str(bond.get("mechanic", "")) != "":
			lines.append("机制：" + str(bond.get("mechanic", "")))
		var bonuses: Dictionary = bond.get("bonuses", {}) as Dictionary
		if not bonuses.is_empty():
			lines.append("基础加成：" + _set_bonus_effect_summary(bonuses))
		var growth: Dictionary = TREASURE_GROWTH.get(sect_name, {}) as Dictionary
		if not growth.is_empty():
			lines.append("成长方式：" + str(growth.get("trigger", "")))
		return lines
	if SECT_PASSIVE.has(sect_name):
		var passive: Dictionary = SECT_PASSIVE[sect_name] as Dictionary
		var stats: Array = SECT_STATS.get(sect_name, []) as Array
		var stat_names: Array[String] = []
		for stat_name in stats:
			stat_names.append(str(stat_name))
		lines.append("看重六维：" + "、".join(stat_names))
		lines.append("门派被动：" + str(passive.get("desc", "")) + "，" + str(passive.get("formula", "")))
	return lines


func get_affix_guide_text(sect_name: String, player: PlayerData = null) -> String:
	var lines: Array[String] = []
	var is_cultivation: bool = CULTIVATION_TYPES.has(sect_name)
	if is_cultivation:
		lines.append(sect_name + "构筑")
		var route: Dictionary = {}
		if player != null:
			route = get_affix_build_routes(player).get(sect_name, {}) as Dictionary
		var count: int = int(route.get("count", 0))
		var level: int = int(route.get("level", 0))
		var next_count: int = int(route.get("next_count", 2))
		var level_name: String = str(route.get("level_name", _cultivation_bond_level_name(level)))
		lines.append("当前：" + str(count) + "/" + str(MAX_CULTIVATION_SET_COUNT) + "｜" + level_name + "｜功法" + str(int(route.get("techniques", 0))) + " 法宝" + str(int(route.get("treasures", 0))))
		lines.append("下一步：" + ("已成套，换高品质/练大成" if level >= 4 else "再找" + str(maxi(0, next_count - count)) + "件" + sect_name))
		lines.append("")
		var bond: Dictionary = CULTIVATION_BOND_DATA.get(sect_name, {}) as Dictionary
		var mechanic: String = str(bond.get("mechanic", ""))
		if mechanic != "":
			lines.append("机制：" + mechanic)
		lines.append("阶段：")
		lines.append_array(_cultivation_bond_stage_lines(sect_name, route))
	else:
		lines.append(sect_name + "宗门")
		var identity_route: Dictionary = {}
		if player != null:
			identity_route = _calculate_identity_routes(player).get(sect_name, {}) as Dictionary
		var score: float = float(identity_route.get("score", 0.0))
		var identity_level: int = get_identity_level_for_score(score)
		lines.append("当前：" + _format_score(score) + "分｜" + get_identity_level_short(identity_level) + "｜伙伴" + str(int(identity_route.get("companions", 0))) + "位")
		lines.append("下一步：" + ("已满" if identity_level >= 5 else _format_score(_identity_next_score(identity_level)) + "分"))
		lines.append("")
		lines.append("成套：同门伙伴越多、羁绊越高，身份越高。")
		var passive: Dictionary = SECT_PASSIVE.get(sect_name, {}) as Dictionary
		if not passive.is_empty():
			lines.append("被动：" + str(passive.get("desc", "")))
	return "\n".join(lines)


func _cultivation_bond_stage_lines(cultivation_type: String, route: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	var current_level: int = int(route.get("level", 0))
	var count: int = int(route.get("count", 0))
	var avg_quality: float = 1.0
	var avg_realm: float = 1.0
	if count > 0:
		avg_quality = float(route.get("quality", 0.0)) / float(maxi(1, count))
		avg_realm = float(route.get("realm", 0.0)) / float(maxi(1, count))
	var bond_data: Dictionary = CULTIVATION_BOND_DATA.get(cultivation_type, {}) as Dictionary
	var bond_bonuses: Dictionary = bond_data.get("bonuses", {}) as Dictionary
	var bond_specials: Dictionary = bond_data.get("specials", {}) as Dictionary
	for level in range(1, 5):
		var need_count: int = level + 1
		var state: String = "未激活"
		if current_level == level:
			state = "当前"
		elif current_level > level:
			state = "已激活"
		var strength: float = _cultivation_bond_multiplier(level) * (0.75 + avg_quality * 0.12 + avg_realm * 0.12)
		var stage_bonuses: Dictionary = {}
		for bonus_name in bond_bonuses:
			stage_bonuses[str(bonus_name)] = float(bond_bonuses[bonus_name]) * strength
		var stage_specials: Dictionary = {}
		for special_name in bond_specials:
			stage_specials[str(special_name)] = float(bond_specials[special_name]) * strength
		var effect_text: String = _set_bonus_effect_summary(stage_bonuses)
		var special_text: String = _cultivation_special_summary(stage_specials)
		if special_text != "":
			effect_text += "、" + special_text
		lines.append(state + "｜" + str(need_count) + "件 " + _cultivation_bond_level_name(level) + "：" + effect_text)
	return lines


func _cultivation_special_summary(specials: Dictionary) -> String:
	if specials.is_empty():
		return ""
	var parts: Array[String] = []
	for special_name in specials:
		var label: String = str(special_name)
		match label:
			"treasure_growth_speed":
				label = "法宝成长速度"
			"treasure_effect_chance":
				label = "法宝特效概率"
		var value: float = float(specials[special_name])
		var suffix: String = "%" if absf(value) < 2.0 else ""
		var shown: String = str(int(round(value * 100.0))) if suffix == "%" else str(int(round(value)))
		parts.append(label + ("+" if value >= 0.0 else "") + shown + suffix)
	return "、".join(parts)


func get_set_bonus_effect_text(sect_name: String, level: int) -> String:
	if not SECT_TYPES.has(sect_name):
		return "尚未判定门派"
	var lines: Array[String] = []
	lines.append(sect_name + "宗门羁绊")
	lines.append("")
	if level <= 0:
		lines.append("尚未激活门派被动。")
	else:
		var passive: Dictionary = SECT_PASSIVE.get(sect_name, {}) as Dictionary
		lines.append("门派被动：" + str(passive.get("desc", "")))
		lines.append("公式：" + str(passive.get("formula", "")) + " × " + str(_identity_passive_multiplier(level)))
		var card_bonus: float = _identity_card_bonus(level)
		if card_bonus > 0.0:
			lines.append("弱势专属卡概率 +" + str(int(round(card_bonus * 100.0))) + "%")
		var stone_income: int = _identity_round_stones(level)
		if stone_income > 0:
			lines.append("每轮灵石 +" + str(stone_income))
		if bool(_identity_level_data(level).get("transformation", false)):
			lines.append("宗主质变已解锁")
	return "\n".join(lines)


func _format_score(value: float) -> String:
	if is_equal_approx(value, round(value)):
		return str(int(round(value)))
	return "%0.1f" % value


func _set_bonus_effect_summary(bonus: Dictionary) -> String:
	if bonus.is_empty():
		return "无"
	var parts: Array[String] = []
	for bonus_name in bonus:
		var value: float = float(bonus[bonus_name])
		var suffix: String = "%" if absf(value) < 2.0 else ""
		var shown: String = str(int(round(value * 100.0))) if suffix == "%" else str(int(round(value)))
		parts.append(str(bonus_name) + ("+" if value >= 0.0 else "") + shown + suffix)
	return "、".join(parts)


func _item_affix_names_for_tag(item_data: Dictionary, tag: String) -> Array[String]:
	var names: Array[String] = []
	var affixes: Array = item_data.get("affixes", []) as Array
	for affix in affixes:
		if not affix is Dictionary:
			continue
		var affix_data: Dictionary = affix as Dictionary
		if str(affix_data.get("tag", "")) != tag:
			continue
		var affix_name: String = str(affix_data.get("name", ""))
		if affix_name != "":
			names.append(affix_name)
	return names


func _best_owned_sect_name(player: PlayerData) -> String:
	var best_sect: String = ""
	var best_score: int = 0
	for sect_name in SECTS:
		var counts: Dictionary = _sect_owned_counts(player, sect_name)
		var score: int = int(counts.get("techniques", 0)) * 2 + int(counts.get("treasures", 0)) * 2 + int(counts.get("companions", 0))
		if score > best_score:
			best_score = score
			best_sect = sect_name
	return best_sect


func _sect_owned_counts(player: PlayerData, sect_name: String) -> Dictionary:
	var sect_data: Dictionary = SECT_BUILD_DATA.get(sect_name, {}) as Dictionary
	var core_techniques: Array[String] = _sect_core_technique_names(sect_name)
	var sect_treasures: Array[String] = _sect_treasure_names(sect_name)
	var sect_companions: Array = sect_data.get("companions", []) as Array
	var owned_techniques: Dictionary = {}
	var owned_treasures: Dictionary = {}
	var owned_companions: Dictionary = {}
	for item in _owned_collection_items(player):
		var item_data: Dictionary = item as Dictionary
		var item_kind: String = str(item_data.get("kind", ""))
		var data: Dictionary = item_data.get("data", {}) as Dictionary
		var item_name: String = str(data.get("name", ""))
		var build_tags: Array[String] = _item_build_tags(data)
		match item_kind:
			"technique":
				if core_techniques.has(item_name) or build_tags.has(sect_name):
					owned_techniques[item_name] = true
			"treasure":
				if sect_treasures.has(item_name) or build_tags.has(sect_name):
					owned_treasures[item_name] = true
			"companion":
				if sect_companions.has(item_name) or build_tags.has(sect_name):
					owned_companions[item_name] = true
	return {
		"techniques": owned_techniques.size(),
		"treasures": owned_treasures.size(),
		"companions": owned_companions.size(),
		"total": owned_techniques.size() + owned_treasures.size() + owned_companions.size(),
	}


func on_set_bonus_triggered(data: Dictionary) -> void:
	set_bonus_triggered.emit(data)


func _set_bonus_announcement_data(player: PlayerData, sect_name: String, level: int, resonance_name: String) -> Dictionary:
	var suffix: String = _resonance_level_suffix(level)
	var tail: String = resonance_name
	match level:
		1:
			tail = resonance_name + "已觉醒"
		2:
			tail = resonance_name + "降临"
		3:
			tail = resonance_name
	var title: String = sect_name + "·" + suffix + "——" + tail
	return {
		"player_name": player.player_name if player != null else "",
		"peer_id": player.peer_id if player != null else 0,
		"sect": sect_name,
		"level": level,
		"resonance_name": resonance_name,
		"title": title,
		"duration": _resonance_announcement_duration(level),
		"color": _sect_color_hex(sect_name, level),
	}


func _resonance_level_suffix(level: int) -> String:
	match level:
		1:
			return "初悟"
		2:
			return "大成"
		3:
			return "飞升"
		_:
			return ""


func _resonance_announcement_duration(level: int) -> float:
	match level:
		1:
			return 2.0
		2:
			return 3.0
		3:
			return 4.0
		_:
			return 2.0


func _sect_color_hex(sect_name: String, _level: int = 0) -> String:
	match sect_name:
		"万魂殿":
			return "#c080e0"
		"金刚寺":
			return "#c04040"
		"天剑阁":
			return "#f0c040"
		"百花谷":
			return "#40c0a0"
		"丹霞山":
			return "#f08040"
		"阵宗":
			return "#6080d0"
		"符箓门":
			return "#80c080"
		"器府":
			return "#d0a060"
		"鬼修":
			return "#c080e0"
		"体修":
			return "#c04040"
		"剑修":
			return "#f0c040"
		"情修":
			return "#40c0a0"
		_:
			return "#e0d5b7"


func grow_treasure(player: PlayerData, amount: int) -> String:
	if player == null or amount <= 0:
		return ""
	var treasure: Dictionary = _get_equipped_treasure(player)
	if treasure.is_empty():
		return ""
	_prepare_treasure(treasure, _player_sect(player))
	_apply_player_treasure_growth_cap(player, treasure)
	var growth_type: String = _treasure_growth_type(treasure)
	var growth_name: String = _treasure_growth_name(growth_type)
	var penalty_key: String = growth_name + "获取"
	var gain_multiplier: float = 1.0 + float(player.resonance_bonus.get(penalty_key, 0.0))
	gain_multiplier += float(player.final_attributes.get("treasure_growth_speed", 0.0))
	var actual_amount: int = maxi(0, int(round(float(amount) * gain_multiplier)))
	if actual_amount <= 0:
		return ""
	var old_value: int = int(treasure.get("growth_value", 0))
	if growth_type == "器修":
		var before_steps: int = int(floor(float(old_value) / 5.0))
		var after_steps: int = int(floor(float(old_value + actual_amount) / 5.0))
		actual_amount += maxi(0, after_steps - before_steps)
	var threshold: int = int(treasure.get("awaken_threshold", treasure.get("growth_max", 10)))
	var already_at_top: bool = (int(treasure.get("awakening_level", 0)) > 0 or bool(treasure.get("awakened", false))) and old_value >= threshold
	if already_at_top:
		if bool(treasure.get("max_conversion_done", false)):
			return ""
		var top_insight: int = maxi(10, int(round(float(actual_amount) * 8.0 * _quality_power(str(treasure.get("quality", "筑基级"))))))
		player.ling_li += top_insight
		treasure["max_conversion_done"] = true
		return str(treasure.get("name", "法宝")) + "已觉醒，余韵化为修为 +" + str(top_insight)
	var new_value: int = old_value + actual_amount
	var awakened_now: bool = old_value < threshold and new_value >= threshold and int(treasure.get("awakening_level", 0)) <= 0
	if awakened_now:
		new_value = threshold
		treasure["awakening_level"] = 1
		treasure["awakened"] = true
		if growth_type == "器修":
			new_value += 5
		if _quality_rank(str(treasure.get("quality", "炼气级"))) >= _quality_rank("化神级"):
			var extra_effect: String = _roll_treasure_extra_effect(treasure)
			if extra_effect != "":
				var extra_effects: Array = treasure.get("extra_attack_effects", []) as Array
				extra_effects.append(extra_effect)
				treasure["extra_attack_effects"] = extra_effects
	elif new_value > threshold:
		new_value = threshold
	treasure["growth_value"] = new_value
	treasure["growth_changed"] = true
	var message: String = str(treasure.get("name", "法宝")) + growth_name + " +" + str(new_value - old_value) + "（" + str(new_value) + "/" + str(threshold) + "）"
	if awakened_now:
		var awaken_skill: Dictionary = treasure.get("awakening_skill", {}) as Dictionary
		message += "，觉醒：" + str(awaken_skill.get("name", "觉醒技"))
		var extras: Array = treasure.get("extra_attack_effects", []) as Array
		if not extras.is_empty():
			message += "，附加" + str(extras[extras.size() - 1])
	_refresh_treasure_growth_bonus(treasure)
	var technique_steps: int = int(floor(float(new_value) / 5.0)) - int(floor(float(old_value) / 5.0))
	if awakened_now:
		technique_steps += 2
	if technique_steps > 0:
		var technique_message: String = _grow_techniques_for_cultivation(player, "器修", technique_steps, "炼器共鸣")
		if technique_message != "":
			message += "；" + technique_message
	return message


func _grow_treasure_for_cultivation(player: PlayerData, growth_type: String, amount: int) -> String:
	if player == null or growth_type == "" or amount <= 0:
		return ""
	var treasure: Dictionary = _get_equipped_treasure(player)
	if treasure.is_empty():
		return ""
	_prepare_treasure(treasure, _player_sect(player))
	if _treasure_growth_type(treasure) != growth_type:
		return ""
	return grow_treasure(player, amount)


func _grow_techniques_for_cultivation(player: PlayerData, cultivation_type: String, amount: int, source: String) -> String:
	if player == null or cultivation_type == "" or amount <= 0 or player.techniques.is_empty():
		return ""
	var messages: Array[String] = []
	for technique in player.techniques:
		if not technique is Dictionary:
			continue
		var technique_data: Dictionary = technique as Dictionary
		if not _item_cultivation_tags(technique_data).has(cultivation_type):
			continue
		var message: String = _add_technique_fragment_progress(player, technique_data, amount, source)
		if message != "":
			messages.append(message)
		if messages.size() >= TECHNIQUE_BEHAVIOR_GROWTH_MAX_MESSAGES:
			break
	if messages.is_empty():
		return ""
	return "；".join(messages)


func _companion_quality_base_bond(quality: String) -> int:
	return int(_quality_data_value(quality, "companion_initial_bond", 1))


func _companion_bond_max(companion: Dictionary) -> int:
	var quality: String = str(companion.get("quality", "炼气级"))
	return maxi(1, _companion_quality_base_bond(quality) * 8)


func _companion_sect_affix(companion: Dictionary) -> String:
	var affixes: Array = companion.get("affixes", []) as Array
	for affix in affixes:
		if not affix is Dictionary:
			continue
		var affix_data: Dictionary = affix as Dictionary
		if str(affix_data.get("affix_kind", "")) == "sect" and SECT_TYPES.has(str(affix_data.get("tag", ""))):
			return str(affix_data.get("tag", ""))
	var sect_name: String = str(companion.get("sect_support", ""))
	if SECT_TYPES.has(sect_name):
		return sect_name
	return str(SECT_TYPES[0])


func _companion_alignment(companion: Dictionary) -> String:
	return str(SECT_ALIGNMENT.get(_companion_sect_affix(companion), "正"))


func _normalize_companion_bonus(companion: Dictionary) -> void:
	var bonus_type: String = str(companion.get("bonus_type", ""))
	var normalized_type: String = str(COMPANION_BONUS_TYPE_MAP.get(bonus_type, bonus_type))
	if not COMPANION_PASSIVE_KEYS.has(normalized_type):
		normalized_type = "灵力获取"
	var value: float = absf(float(companion.get("bonus_value", 0.0)))
	if bonus_type == "round_ling_shi":
		value = clampf(value / 3000.0, 0.05, 0.18)
	if normalized_type == "速度":
		value = maxf(1.0, value)
	elif value > 1.0:
		value = value / 100.0
	companion["bonus_type"] = normalized_type
	companion["bonus_value"] = value
	companion["effect_desc"] = _format_companion_bonus_desc(normalized_type, value)


func _companion_full_bonus_value(companion: Dictionary) -> float:
	var quality: String = str(companion.get("quality", "炼气级"))
	var factor: float = _quality_power(quality)
	var bonus_type: String = str(companion.get("full_bonus_type", companion.get("bonus_type", "灵力获取")))
	if bonus_type == "速度":
		return factor * 4.0
	if bonus_type == "全属性":
		return factor * 0.02
	return factor * 0.04


func _companion_effective_bonus_value(companion: Dictionary) -> float:
	var value: float = float(companion.get("bonus_value", 0.0))
	if _companion_bond_is_full(companion):
		value += float(companion.get("full_bonus_value", _companion_full_bonus_value(companion)))
	return value


func _format_companion_bonus_desc(bonus_type: String, value: float) -> String:
	if bonus_type == "速度":
		return "速度+" + str(int(round(value)))
	var shown: int = int(round(value * 100.0))
	return bonus_type + "+" + str(shown) + "%"


func _companion_bond_is_full(companion: Dictionary) -> bool:
	return int(companion.get("bond", 0)) >= _companion_bond_max(companion)


func get_companion_bond_max(companion: Dictionary) -> int:
	return _companion_bond_max(companion)


func get_companion_alignment(companion: Dictionary) -> String:
	return _companion_alignment(companion)


func get_companion_sect(companion: Dictionary) -> String:
	return _companion_sect_affix(companion)


func get_companion_bond_stage_text_for_data(companion: Dictionary) -> String:
	if companion.is_empty():
		return "萍水"
	var max_bond: int = _companion_bond_max(companion)
	var bond_value: int = int(companion.get("bond", 0))
	if bond_value >= max_bond:
		return "生死契"
	var ratio: float = float(bond_value) / float(max_bond)
	if ratio >= 0.66:
		return "知己"
	if ratio >= 0.33:
		return "同袍"
	return "萍水"


func grow_bond(player: PlayerData, companion_name: String, amount: int) -> String:
	return grow_bond_with_source(player, companion_name, amount, "")


func grow_bond_with_source(player: PlayerData, companion_name: String, amount: int, source: String = "") -> String:
	if player == null or companion_name == "" or amount == 0:
		return ""
	var multiplier: float = 1.0 + float(player.resonance_bonus.get("伙伴羁绊获取", 0.0))
	var actual_amount: int = int(round(float(amount) * multiplier))
	if amount > 0:
		actual_amount = maxi(1, actual_amount)
	elif amount < 0:
		actual_amount = mini(-1, actual_amount)
	var companion_ref: Dictionary = {}
	for companion in player.companions:
		if companion is Dictionary and str((companion as Dictionary).get("name", "")) == companion_name:
			companion_ref = companion as Dictionary
			break
	var max_bond: int = _companion_bond_max(companion_ref) if not companion_ref.is_empty() else 99
	var stored_bond_default: int = int(companion_ref.get("bond", 0)) if not companion_ref.is_empty() else 0
	var old_value: int = int(player.companion_bond.get(companion_name, stored_bond_default))
	if actual_amount < 0 and old_value >= max_bond:
		player.companion_bond[companion_name] = max_bond
		if not companion_ref.is_empty():
			companion_ref["bond"] = max_bond
			companion_ref["bond_stage"] = 3
			companion_ref["bond_full_unlocked"] = true
		return ""
	if actual_amount > 0 and old_value >= max_bond:
		player.companion_bond[companion_name] = max_bond
		if not companion_ref.is_empty():
			companion_ref["bond"] = max_bond
			companion_ref["bond_stage"] = 3
			companion_ref["bond_full_unlocked"] = true
			if bool(companion_ref.get("max_conversion_done", false)):
				return ""
			companion_ref["max_conversion_done"] = true
		var companion_quality: String = str(companion_ref.get("quality", "筑基级")) if not companion_ref.is_empty() else "筑基级"
		var bond_insight: int = maxi(8, int(round(float(actual_amount) * 6.0 * _quality_power(companion_quality))))
		player.ling_li += bond_insight
		return companion_name + "情义已满，余缘化为修为 +" + str(bond_insight)
	var new_value: int = clampi(old_value + actual_amount, 0, max_bond)
	var old_stage: int = get_companion_bond_stage(old_value)
	var new_stage: int = get_companion_bond_stage(new_value)
	if old_value >= max_bond:
		old_stage = 3
	if new_value >= max_bond:
		new_stage = 3
	player.companion_bond[companion_name] = new_value
	if not companion_ref.is_empty():
		if bool(companion_ref.get("bonus_applied", false)):
			_remove_companion_bonus(player, companion_ref)
		companion_ref["bond"] = new_value
		companion_ref["bond_stage"] = new_stage
		companion_ref["bond_full_unlocked"] = _companion_bond_is_full(companion_ref)
		apply_companion_bonus(player)
		check_set_bonus(player)
	if new_value == old_value:
		return ""
	var delta_text: String = ("+" if new_value > old_value else "") + str(new_value - old_value)
	var source_text: String = source if source != "" else ("结缘" if new_value > old_value else "离契")
	var message: String = companion_name + "·" + source_text + " " + delta_text + "（" + get_companion_bond_stage_text_for_data(companion_ref) + " " + str(new_value) + "/" + str(max_bond) + "）"
	if not companion_ref.is_empty() and _companion_bond_is_full(companion_ref) and old_value < max_bond:
		message += "，结为" + get_companion_bond_stage_text_for_data(companion_ref) + "：" + _companion_bond_effect_text(new_stage)
	elif new_stage > old_stage:
		message += "，升至" + get_companion_bond_stage_text_for_data(companion_ref) + "：" + _companion_bond_effect_text(new_stage)
	return message


func get_companion_bond_stage(bond_value: int) -> int:
	var stage: int = 0
	for i in range(COMPANION_BOND_STAGE_REQS.size()):
		if bond_value >= int(COMPANION_BOND_STAGE_REQS[i]):
			stage = i
	return clampi(stage, 0, 3)


func get_companion_bond_stage_text(bond_value: int) -> String:
	match get_companion_bond_stage(bond_value):
		1:
			return "同袍"
		2:
			return "知己"
		3:
			return "生死契"
		_:
			return "萍水"


func _next_companion_bond_target(bond_value: int) -> int:
	for req in COMPANION_BOND_STAGE_REQS:
		var target: int = int(req)
		if bond_value < target:
			return target
	return int(COMPANION_BOND_STAGE_REQS[COMPANION_BOND_STAGE_REQS.size() - 1])


func _companion_bond_effect_text(stage: int) -> String:
	if stage <= 0:
		return "基础加成"
	if stage >= 3:
		return "专属被动全开"
	return "被动加成增强"


func _player_sect(player: PlayerData) -> String:
	if player == null:
		return ""
	if SECT_TYPES.has(player.sect):
		return player.sect
	return ""


func _sect_core_technique_names(sect_name: String) -> Array[String]:
	var names: Array[String] = []
	if not SECT_BUILD_DATA.has(sect_name):
		return names
	var sect_data: Dictionary = SECT_BUILD_DATA[sect_name] as Dictionary
	var techniques: Array = sect_data.get("techniques", []) as Array
	for technique in techniques:
		var data: Dictionary = technique as Dictionary
		names.append(str(data.get("name", "")))
	return names


func _sect_treasure_names(sect_name: String) -> Array[String]:
	var names: Array[String] = []
	if not SECT_BUILD_DATA.has(sect_name):
		return names
	var sect_data: Dictionary = SECT_BUILD_DATA[sect_name] as Dictionary
	var treasures: Array = sect_data.get("treasures", []) as Array
	for treasure in treasures:
		var data: Dictionary = treasure as Dictionary
		names.append(str(data.get("name", "")))
	return names


func _owned_collection_items(player: PlayerData) -> Array:
	var items: Array = []
	if player == null:
		return items
	for technique in player.techniques:
		if technique is Dictionary:
			items.append({"kind": "technique", "data": technique})
	for treasure in player.treasures:
		if treasure is Dictionary:
			items.append({"kind": "treasure", "data": treasure})
	for companion in player.companions:
		if companion is Dictionary:
			items.append({"kind": "companion", "data": companion})
	return items


func _refresh_companion_identity_scores(player: PlayerData) -> Dictionary:
	var sect_scores: Dictionary = {}
	var alignment_scores: Dictionary = {"正": 0, "邪": 0}
	if player == null:
		return {"sects": sect_scores, "alignments": alignment_scores}
	for companion in player.companions:
		if not companion is Dictionary:
			continue
		var companion_data: Dictionary = companion as Dictionary
		_prepare_companion(companion_data, player)
		var sect_name: String = _companion_sect_affix(companion_data)
		var alignment: String = _companion_alignment(companion_data)
		var score: int = int(companion_data.get("bond", 0))
		sect_scores[sect_name] = int(sect_scores.get(sect_name, 0)) + score
		alignment_scores[alignment] = int(alignment_scores.get(alignment, 0)) + score
	var best_sect: String = ""
	var best_score: int = 0
	for sect_name in sect_scores:
		var score: int = int(sect_scores[sect_name])
		if score > best_score:
			best_score = score
			best_sect = str(sect_name)
	var best_alignment: String = "正" if int(alignment_scores.get("正", 0)) >= int(alignment_scores.get("邪", 0)) else "邪"
	player.final_attributes["companion_identity_scores"] = sect_scores
	player.final_attributes["companion_alignment_scores"] = alignment_scores
	player.final_attributes["companion_identity_sect"] = best_sect
	player.final_attributes["companion_identity_alignment"] = best_alignment
	return {"sects": sect_scores, "alignments": alignment_scores, "best_sect": best_sect, "best_alignment": best_alignment, "best_score": best_score}


func _sect_resonance_bonus(sect_data: Dictionary, level: int) -> Dictionary:
	var bonus: Dictionary = {}
	for i in range(1, level + 1):
		var level_bonus: Dictionary = sect_data.get("bonus_" + str(i * 2), {}) as Dictionary
		for key in level_bonus:
			bonus[str(key)] = float(bonus.get(str(key), 0.0)) + float(level_bonus[key])
	return bonus


func _sect_resonance_name(sect_data: Dictionary, level: int) -> String:
	match level:
		1:
			return str(sect_data.get("resonance", "共鸣"))
		2:
			return str(sect_data.get("transformation", "质变"))
		3:
			return str(sect_data.get("complete", "完全体"))
		_:
			return ""


func _sect_growth_name(sect_name: String) -> String:
	if not SECT_BUILD_DATA.has(sect_name):
		return "成长"
	var sect_data: Dictionary = SECT_BUILD_DATA[sect_name] as Dictionary
	return str(sect_data.get("growth_name", "成长"))


func _sect_growth_icon(sect_name: String) -> String:
	if not SECT_BUILD_DATA.has(sect_name):
		return "道"
	var sect_data: Dictionary = SECT_BUILD_DATA[sect_name] as Dictionary
	return str(sect_data.get("growth_icon", "道"))


func _sect_growth_max(sect_name: String) -> int:
	if not SECT_BUILD_DATA.has(sect_name):
		return 10
	var sect_data: Dictionary = SECT_BUILD_DATA[sect_name] as Dictionary
	return int(sect_data.get("growth_max", 10))


func _refresh_owned_treasure_growth_caps(player: PlayerData) -> void:
	for treasure in player.treasures:
		if treasure is Dictionary:
			_prepare_treasure(treasure as Dictionary, _player_sect(player))
			_apply_player_treasure_growth_cap(player, treasure as Dictionary)
	for entry in player.backpack:
		if entry is Dictionary and str((entry as Dictionary).get("kind", "")) == "treasure":
			var data: Dictionary = (entry as Dictionary).get("data", {}) as Dictionary
			_prepare_treasure(data, _player_sect(player))
			_apply_player_treasure_growth_cap(player, data)


func _treasure_affix_tag_by_kind(treasure: Dictionary, affix_kind: String) -> String:
	var affixes: Array = treasure.get("affixes", []) as Array
	for affix in affixes:
		if not affix is Dictionary:
			continue
		var affix_data: Dictionary = affix as Dictionary
		if str(affix_data.get("affix_kind", "")) == affix_kind:
			return str(affix_data.get("tag", ""))
	return ""


func _treasure_growth_type(treasure: Dictionary) -> String:
	var growth_type: String = str(treasure.get("growth_type", ""))
	if CULTIVATION_TYPES.has(growth_type):
		return growth_type
	growth_type = _item_cultivation_tag(treasure)
	if CULTIVATION_TYPES.has(growth_type):
		return growth_type
	var legacy_type: String = str(treasure.get("sect", treasure.get("school", "")))
	if CULTIVATION_TYPES.has(legacy_type):
		return legacy_type
	return str(CULTIVATION_TYPES[0])


func _treasure_growth_name(growth_type: String) -> String:
	var data: Dictionary = TREASURE_GROWTH.get(growth_type, {}) as Dictionary
	return str(data.get("name", "成长"))


func _treasure_growth_icon(growth_type: String) -> String:
	return str(TREASURE_GROWTH_ICONS.get(growth_type, "道"))


func _roll_treasure_attack_effect() -> String:
	return str(TREASURE_ATTACK_EFFECTS[rng.randi_range(0, TREASURE_ATTACK_EFFECTS.size() - 1)])


func _treasure_attack_effect_desc(effect_name: String) -> String:
	match effect_name:
		"破甲":
			return "抢攻触发时无视对方20%防御"
		"吸血":
			return "抢攻触发时伤害的15%转为气血"
		"连击":
			return "抢攻触发时额外攻击一次，伤害为50%"
		"暴击加成":
			return "抢攻触发时本次暴击率+20%"
		_:
			return "抢攻时概率触发攻击特效"


func _treasure_awakening_skill(growth_type: String) -> Dictionary:
	return (TREASURE_AWAKEN_SKILLS.get(growth_type, {"name": "灵宝觉醒", "desc": "抢攻时追加觉醒伤害", "damage_scale": 0.35}) as Dictionary).duplicate(true)


func _treasure_effective_attack(treasure: Dictionary) -> int:
	var base_attack: int = int(treasure.get("base_attack", _quality_data_value(str(treasure.get("quality", "筑基级")), "treasure_base_attack", 5)))
	if int(treasure.get("awakening_level", 0)) > 0:
		return base_attack * 2
	return base_attack


func _roll_treasure_extra_effect(treasure: Dictionary) -> String:
	var used: Dictionary = {str(treasure.get("attack_effect", "")): true}
	var current_effects: Array = treasure.get("extra_attack_effects", []) as Array
	for effect in current_effects:
		used[str(effect)] = true
	var candidates: Array[String] = []
	for effect_name in TREASURE_ATTACK_EFFECTS:
		var effect_text: String = str(effect_name)
		if not used.has(effect_text):
			candidates.append(effect_text)
	if candidates.is_empty():
		return ""
	return candidates[rng.randi_range(0, candidates.size() - 1)]


func _prepare_treasure(treasure: Dictionary, _sect_name: String = "") -> Dictionary:
	if treasure.is_empty():
		return treasure
	var legacy_growth_type: String = _item_cultivation_fallback(treasure)
	var quality: String = str(treasure.get("quality", "筑基级"))
	treasure["base_attack"] = int(_quality_data_value(quality, "treasure_base_attack", int(treasure.get("base_attack", 0))))
	treasure["awaken_threshold"] = int(_quality_data_value(quality, "treasure_awaken_threshold", int(treasure.get("awaken_threshold", 10))))
	treasure.erase("used")
	treasure.erase("refined")
	treasure.erase("refine_bonus")
	treasure.erase("max_uses")
	treasure.erase("uses")
	treasure.erase("sect")
	treasure.erase("school")
	treasure.erase("battle_hurt_reduction")
	treasure.erase("lifesteal")
	treasure.erase("ignore_defense")
	treasure.erase("crit_chance")
	treasure.erase("reflect")
	treasure.erase("sect_affix")
	if legacy_growth_type != "":
		treasure["growth_type"] = legacy_growth_type
	_ensure_item_affixes(treasure, "treasure")
	var growth_type: String = _treasure_growth_type(treasure)
	treasure["growth_type"] = growth_type
	treasure["growth_name"] = _treasure_growth_name(growth_type)
	treasure["growth_icon"] = _treasure_growth_icon(growth_type)
	treasure["growth_max"] = int(treasure["awaken_threshold"])
	if not treasure.has("growth_value"):
		treasure["growth_value"] = 0
	if not treasure.has("awakening_level"):
		treasure["awakening_level"] = 0
	if not TREASURE_ATTACK_EFFECTS.has(str(treasure.get("attack_effect", ""))):
		treasure["attack_effect"] = _roll_treasure_attack_effect()
	treasure["attack_effect_desc"] = _treasure_attack_effect_desc(str(treasure.get("attack_effect", "")))
	treasure["awakening_skill"] = _treasure_awakening_skill(growth_type)
	_refresh_treasure_growth_bonus(treasure)
	return treasure


func _apply_player_treasure_growth_cap(player: PlayerData, treasure: Dictionary) -> void:
	if player == null or treasure.is_empty():
		return
	var quality: String = str(treasure.get("quality", "筑基级"))
	treasure["growth_max"] = int(_quality_data_value(quality, "treasure_awaken_threshold", int(treasure.get("growth_max", 10))))
	_refresh_treasure_growth_bonus(treasure)


func _refresh_treasure_growth_bonus(treasure: Dictionary) -> void:
	if treasure.is_empty():
		return
	var effective_attack: int = _treasure_effective_attack(treasure)
	treasure["battle_damage"] = effective_attack
	treasure["duel_damage"] = effective_attack
	treasure["passive_bonus"] = (treasure.get("affix_bonus", treasure.get("base_passive_bonus", {})) as Dictionary).duplicate(true)
	treasure["use_effect"] = "抢攻时自动攻击，基础攻击+" + str(int(treasure.get("base_attack", 0))) + "，特效：" + str(treasure.get("attack_effect", ""))


func _collection_message(player: PlayerData, message: String) -> String:
	var sect_message: String = _auto_lock_player_sect_from_owned(player)
	if sect_message != "":
		message += "；" + sect_message
	var bonus_message: String = check_set_bonus(player)
	if bonus_message != "":
		return message + "；" + bonus_message
	return message


func _auto_lock_player_sect_from_owned(player: PlayerData) -> String:
	return ""


func _item_build_tags(item_data: Dictionary) -> Array[String]:
	var tags: Array[String] = []
	var stored_tags: Array = item_data.get("build_tags", []) as Array
	for tag_value in stored_tags:
		var tag: String = str(tag_value)
		if _is_build_tag(tag) and not tags.has(tag):
			tags.append(tag)
	var affixes: Array = item_data.get("affixes", []) as Array
	for affix in affixes:
		if not affix is Dictionary:
			continue
		var affix_tag: String = str((affix as Dictionary).get("tag", ""))
		if _is_build_tag(affix_tag) and not tags.has(affix_tag):
			tags.append(affix_tag)
	var sect_name: String = _item_sect(item_data)
	if sect_name != "" and not tags.has(sect_name):
		tags.append(sect_name)
	return tags


func _item_sect(item_data: Dictionary) -> String:
	var sect_name: String = str(item_data.get("sect", item_data.get("school", "")))
	if SECTS.has(sect_name) or SECT_TYPES.has(sect_name):
		return sect_name
	sect_name = str(item_data.get("sect_support", ""))
	if SECTS.has(sect_name) or SECT_TYPES.has(sect_name):
		return sect_name
	return ""


func _body_school_hp_bonus(player: PlayerData) -> float:
	var power: float = _school_power(player, "体修")
	if power <= 0.0:
		return 0.0
	return clampf(power * 0.12 + float(player.stats.get("体魄", 0)) * 0.025, 0.0, 2.2)


func _body_school_defense_bonus(player: PlayerData) -> float:
	var power: float = _school_power(player, "体修")
	if power <= 0.0:
		return 0.0
	return clampf(power * 0.09 + float(player.stats.get("体魄", 0)) * 0.012, 0.0, 1.6)


func _body_school_attack_bonus(player: PlayerData) -> float:
	var power: float = _school_power(player, "体修")
	if power <= 0.0:
		return 0.0
	return clampf(power * 0.045, 0.0, 0.75)


func _body_school_damage_reduction(player: PlayerData) -> float:
	var power: float = _school_power(player, "体修")
	if power <= 0.0:
		return 0.0
	return clampf(power * 0.035, 0.0, 0.35)


func _emotion_school_power(player: PlayerData) -> float:
	return _school_power(player, "情修")


func _effective_charm(player: PlayerData) -> int:
	if player == null:
		return 0
	var power: float = _emotion_school_power(player)
	return int(player.stats.get("魅力", 0)) + int(round(power * 2.0))


func _emotion_school_attack_bonus(player: PlayerData) -> float:
	var power: float = _emotion_school_power(player)
	if power <= 0.0:
		return 0.0
	return clampf(power * 0.035 + float(player.stats.get("魅力", 0)) * 0.008, 0.0, 0.75)


func _emotion_school_defense_bonus(player: PlayerData) -> float:
	var power: float = _emotion_school_power(player)
	if power <= 0.0:
		return 0.0
	return clampf(power * 0.03 + float(player.stats.get("魅力", 0)) * 0.006, 0.0, 0.55)


func _emotion_school_hp_bonus(player: PlayerData) -> float:
	var power: float = _emotion_school_power(player)
	if power <= 0.0:
		return 0.0
	return clampf(power * 0.045, 0.0, 0.65)


func _emotion_school_speed_bonus(player: PlayerData) -> int:
	var power: float = _emotion_school_power(player)
	if power <= 0.0:
		return 0
	return int(round(power * 3.5 + float(player.stats.get("魅力", 0)) * 1.5))


func _emotion_school_damage_reduction(player: PlayerData) -> float:
	var power: float = _emotion_school_power(player)
	if power <= 0.0:
		return 0.0
	return clampf(power * 0.018 + float(player.stats.get("魅力", 0)) * 0.003, 0.0, 0.24)


func prepare_duel() -> Dictionary:
	check_set_bonus(player_a)
	check_set_bonus(player_b)
	var mode: String = duel_mode if duel_mode != "" else "final"
	var pre_hp_a: int = player_a.qi_xue
	var pre_hp_b: int = player_b.qi_xue
	if mode == "sparring":
		player_a.qi_xue = _get_player_max_hp(player_a)
		player_b.qi_xue = _get_player_max_hp(player_b)
	var player_a_stats: Dictionary = calculate_duel_stats(player_a)
	var player_b_stats: Dictionary = calculate_duel_stats(player_b)
	var speed_a: float = float(player_a_stats.get("速度", 0)) * rng.randf_range(0.95, 1.05)
	var speed_b: float = float(player_b_stats.get("速度", 0)) * rng.randf_range(0.95, 1.05)
	var first_attacker: String = "player_a" if speed_a >= speed_b else "player_b"
	duel_round_number = 1
	var first_name: String = player_a.player_name if first_attacker == "player_a" else player_b.player_name
	var title: String = "论道切磋" if mode == "sparring" else "仙位之争"
	var opening_log: String = "第" + str(round_number) + "轮论道切磋开启，" + first_name + "先行出招" if mode == "sparring" else "仙位之争开启，" + first_name + "占得先机"
	duel_data = {
		"mode": mode,
		"title": title,
		"max_rounds": SPARRING_MAX_ACTIONS if mode == "sparring" else 0,
		"pre_sparring_hp_a": pre_hp_a,
		"pre_sparring_hp_b": pre_hp_b,
		"player_a_stats": player_a_stats,
		"player_b_stats": player_b_stats,
		"first_attacker": first_attacker,
		"current_attacker": first_attacker,
		"round": duel_round_number,
		"log": [opening_log],
	}
	return duel_data.duplicate(true)


func calculate_duel_stats(player: PlayerData) -> Dictionary:
	var realm_data: Dictionary = REALMS.get(player.realm, REALMS["炼气期"]) as Dictionary
	var final_stats: Dictionary = player.calculate_final_stats(
		1.0 + float(realm_data.get("attack_bonus", 0.0)),
		1.0 + float(realm_data.get("defense_bonus", 0.0)),
		1.0 + float(realm_data.get("hp_bonus", 0.0))
	)
	var body_attack_bonus: float = _body_school_attack_bonus(player)
	var body_defense_bonus: float = _body_school_defense_bonus(player)
	var body_hp_bonus: float = _body_school_hp_bonus(player)
	var emotion_attack_bonus: float = _emotion_school_attack_bonus(player)
	var emotion_defense_bonus: float = _emotion_school_defense_bonus(player)
	var emotion_hp_bonus: float = _emotion_school_hp_bonus(player)
	if body_attack_bonus > 0.0:
		final_stats["攻击力"] = int(round(float(final_stats.get("攻击力", 0)) * (1.0 + body_attack_bonus)))
	if body_defense_bonus > 0.0:
		final_stats["防御力"] = int(round(float(final_stats.get("防御力", 0)) * (1.0 + body_defense_bonus)))
	if body_hp_bonus > 0.0:
		final_stats["气血"] = int(round(float(final_stats.get("气血", 0)) * (1.0 + body_hp_bonus)))
	if emotion_attack_bonus > 0.0:
		final_stats["攻击力"] = int(round(float(final_stats.get("攻击力", 0)) * (1.0 + emotion_attack_bonus)))
	if emotion_defense_bonus > 0.0:
		final_stats["防御力"] = int(round(float(final_stats.get("防御力", 0)) * (1.0 + emotion_defense_bonus)))
	if emotion_hp_bonus > 0.0:
		final_stats["气血"] = int(round(float(final_stats.get("气血", 0)) * (1.0 + emotion_hp_bonus)))
	var base_speed: int = int(realm_data.get("speed_base", 10)) + int(player.stats.get("身法", 0)) * 6 + _emotion_school_speed_bonus(player)
	var technique_speed_bonus: float = _sum_player_technique_bonus(player, "速度")
	var other_speed_bonus: float = _sum_player_non_technique_bonus(player, "速度")
	var final_speed: int = int(round(float(base_speed) * (1.0 + technique_speed_bonus) + other_speed_bonus))
	var treasure: Dictionary = _get_equipped_treasure(player).duplicate(true)
	var treasure_growth: int = _duel_treasure_growth_power(treasure)
	var good_karma: int = _duel_good_karma(player)
	var build_level: int = int(player.final_attributes.get("cultivation_bond_level", 0))
	var active_links: Array = []
	var stats: Dictionary = {
		"攻击力": int(final_stats.get("攻击力", 0)),
		"防御力": int(final_stats.get("防御力", 0)),
		"气血": int(final_stats.get("气血", 0)),
		"当前气血": player.qi_xue,
		"速度": final_speed,
		"境界": player.realm,
		"境界层级": _realm_rank(player.realm),
		"境界战力": _realm_combat_power_bonus(player.realm),
		"修为": player.ling_li,
		"流派": _detect_player_school(player),
		"构筑层级": build_level,
		"魅力": int(player.stats.get("魅力", 0)),
		"法宝": treasure,
		"法宝成长": treasure_growth,
		"善因": good_karma,
		"因果": int(player.karmic_debt),
		"隐忍": int(player.forbearance),
		"炼体强度": _school_power(player, "体修"),
		"情修强度": _school_power(player, "情修"),
		"鬼魂强度": int(player.final_attributes.get("ghost_power", 0)),
		"吸血": _sum_player_bonus(player, "吸血"),
		"反伤": _sum_player_bonus(player, "反伤"),
		"暴击率": get_crit_chance(player),
		"闪避率": get_dodge_chance(player),
		"破防": _sum_player_bonus(player, "破防"),
		"联动列表": active_links,
		"伙伴列表": player.companions.duplicate(true),
	}
	stats["战力"] = _duel_combat_power_from_stats(stats)
	stats["战力说明"] = get_visible_combat_power_formula_text() + "；境界越高，基础攻防血和对决压制越强。"
	return stats


func _duel_combat_power_from_stats(stats: Dictionary) -> int:
	return int(round(
		float(stats.get("攻击力", 0)) * 2.0
		+ float(stats.get("防御力", 0))
		+ float(stats.get("当前气血", stats.get("气血", 0))) * 0.5
		+ float(stats.get("法宝成长", 0))
		+ float(stats.get("速度", 0)) * 0.2
		+ float(stats.get("境界战力", 0))
	))


func _duel_base_power_from_stats(stats: Dictionary) -> int:
	return int(round(
		float(stats.get("攻击力", 0)) * 2.0
		+ float(stats.get("防御力", 0))
		+ float(stats.get("气血", 0)) * 0.5
		+ float(stats.get("法宝成长", 0))
		+ float(stats.get("速度", 0)) * 0.2
		+ float(stats.get("境界战力", 0))
	))


func _duel_treasure_growth_power(treasure: Dictionary) -> int:
	if treasure.is_empty():
		return 0
	var power: int = int(treasure.get("growth_value", 0))
	power += int(treasure.get("awakening_level", 0)) * 6
	if bool(treasure.get("is_growth_sword", false)):
		power += int(treasure.get("growth_level", 1)) * 5
		power += int(round(float(treasure.get("growth_exp", 0)) / 6.0))
	return maxi(0, power)


func _duel_good_karma(player: PlayerData) -> int:
	if player == null:
		return 0
	var value: int = int(player.forbearance)
	value += int(round(_emotion_school_power(player) * 2.0))
	value += maxi(0, player.total_rang_count - player.total_qiang_count)
	return maxi(0, value)


func execute_duel_round(attacker: PlayerData, defender: PlayerData, attack_stats: Dictionary, defense_stats: Dictionary) -> Dictionary:
	var effects: Array = []
	_apply_duel_start_of_action(attacker, defender, attack_stats, defense_stats, effects)
	if attacker.qi_xue <= 0:
		var backlash_log: String = attacker.player_name + "心魔反噬，道心先崩"
		return {"damage": 0, "实际伤害": 0, "特殊效果触发列表": effects, "日志文字": backlash_log, "明细": effects.duplicate(), "攻击方": attacker.player_name, "防守方": defender.player_name}
	if defender.qi_xue <= 0:
		var drain_log: String = defender.player_name + "被道途余势拖入败局"
		return {"damage": 0, "实际伤害": 0, "特殊效果触发列表": effects, "日志文字": drain_log, "明细": effects.duplicate(), "攻击方": attacker.player_name, "防守方": defender.player_name}
	var attack_value: float = float(attack_stats.get("攻击力", 0))
	var detail_lines: Array[String] = ["基础攻击 " + str(int(round(attack_value)))]
	var attacker_treasure: Dictionary = attack_stats.get("法宝", {}) as Dictionary
	var defender_treasure: Dictionary = defense_stats.get("法宝", {}) as Dictionary
	var treasure_damage: float = float(attacker_treasure.get("duel_damage", 0.0))
	var treasure_growth_damage: float = float(attack_stats.get("法宝成长", 0)) * 0.45
	if treasure_growth_damage > 0.0:
		treasure_damage += treasure_growth_damage
		effects.append("法宝养成+" + str(int(round(treasure_growth_damage))))
	if treasure_damage > 0.0:
		attack_value += treasure_damage
		effects.append(str(attacker_treasure.get("name", "法宝")) + "轰击+" + str(int(round(treasure_damage))))
		detail_lines.append("法宝 +" + str(int(round(treasure_damage))))
	var ghost_damage: int = _ghost_attack_damage(attacker, true)
	if ghost_damage > 0:
		attack_value += ghost_damage
		effects.append("役鬼助战+" + str(ghost_damage))
		detail_lines.append("役鬼 +" + str(ghost_damage))
	var route_bonus: float = _duel_route_attack_bonus(attack_stats)
	if route_bonus > 0.0:
		attack_value *= 1.0 + route_bonus
		effects.append(str(attack_stats.get("流派", "道途")) + "杀势+" + str(int(round(route_bonus * 100.0))) + "%")
		detail_lines.append(str(attack_stats.get("流派", "道途")) + "杀势 +" + str(int(round(route_bonus * 100.0))) + "%")
	var emotion_damage: int = int(round(float(attack_stats.get("情修强度", 0.0)) * 0.9 + float(attack_stats.get("魅力", 0)) * 0.45))
	if emotion_damage > 0:
		attack_value += emotion_damage
		effects.append("红尘扰心+" + str(emotion_damage))
		detail_lines.append("红尘 +" + str(emotion_damage))
	var defense_value: float = float(defense_stats.get("防御力", 0))
	var defense_rate: float = minf(0.70, defense_value / (defense_value + 50.0))
	var ignore_defense: float = _get_duel_effect_value(attack_stats, "碎甲", 0.0)
	ignore_defense += float(attack_stats.get("破防", 0.0))
	ignore_defense += float(attacker_treasure.get("ignore_defense", 0.0))
	if _has_link(attack_stats, "摧枯拉朽"):
		ignore_defense += 0.10
	if _has_link(attack_stats, "蓄势待发"):
		ignore_defense += 0.20
	defense_rate = maxf(0.0, defense_rate * (1.0 - ignore_defense))
	detail_lines.append("防御抵消 " + str(int(round(defense_rate * 100.0))) + "%")
	if ignore_defense > 0.0:
		detail_lines.append("破防 " + str(int(round(ignore_defense * 100.0))) + "%")

	var dodge_chance: float = float(defense_stats.get("闪避率", BASE_DODGE_CHANCE))
	dodge_chance += _get_duel_effect_value(defense_stats, "逍遥游", 0.0)
	dodge_chance += float(defense_stats.get("隐忍", 0)) * 0.012
	if _has_link(defense_stats, "踏雪无痕"):
		dodge_chance += 0.05
	if rng.randf() < clampf(dodge_chance, 0.0, 0.75):
		effects.append("闪避！")
		detail_lines.append("闪避率 " + str(int(round(clampf(dodge_chance, 0.0, 0.75) * 100.0))) + "%，本次闪避成功")
		var dodge_log: String = defender.player_name + "身形一晃，避开了攻击"
		return {"damage": attack_value, "实际伤害": 0, "特殊效果触发列表": effects, "日志文字": dodge_log, "闪避": true, "暴击": false, "明细": detail_lines, "攻击方": attacker.player_name, "防守方": defender.player_name}

	var damage: float = maxf(1.0, attack_value * (1.0 - defense_rate))
	var realm_gap: int = int(attack_stats.get("境界层级", 0)) - int(defense_stats.get("境界层级", 0))
	if realm_gap > 0:
		var realm_advantage: float = REALM_DUEL_ADVANTAGE_DAMAGE * float(realm_gap)
		damage *= 1.0 + realm_advantage
		effects.append("境界压制+" + str(int(round(realm_advantage * 100.0))) + "%")
		detail_lines.append("境界压制 +" + str(int(round(realm_advantage * 100.0))) + "%")
	elif realm_gap < 0:
		var realm_suppression: float = clampf(REALM_DUEL_SUPPRESSED_DAMAGE * float(abs(realm_gap)), 0.0, 0.55)
		damage *= 1.0 - realm_suppression
		effects.append("境界受制-" + str(int(round(realm_suppression * 100.0))) + "%")
		detail_lines.append("境界受制 -" + str(int(round(realm_suppression * 100.0))) + "%")
	damage *= 1.0 + clampf(float(defense_stats.get("因果", 0)) * 0.025, 0.0, 0.28)
	var route_reduction: float = _duel_route_damage_reduction(defender, defense_stats)
	if route_reduction > 0.0:
		damage *= 1.0 - route_reduction
		effects.append("道途护身-" + str(int(round(route_reduction * 100.0))) + "%")
		detail_lines.append("道途护身 -" + str(int(round(route_reduction * 100.0))) + "%")
	var crit_chance: float = float(attack_stats.get("暴击率", BASE_CRIT_CHANCE))
	crit_chance += _get_duel_effect_value(attack_stats, "破军", 0.0)
	crit_chance += _duel_route_crit_bonus(attack_stats)
	crit_chance += float(defense_stats.get("因果", 0)) * 0.01
	if _has_link(attack_stats, "先发制人"):
		crit_chance += 0.30
	if _has_link(attack_stats, "一剑封喉") and defender.qi_xue <= int(defense_stats.get("气血", 1)) * 0.35:
		crit_chance += 0.25
	var is_crit: bool = false
	if rng.randf() < clampf(crit_chance, 0.0, 0.95):
		is_crit = true
		var crit_multiplier: float = CRIT_DAMAGE_MULTIPLIER + _duel_route_crit_damage_bonus(attack_stats)
		damage *= crit_multiplier
		effects.append("暴击！")
		detail_lines.append("暴击 x" + str(snappedf(crit_multiplier, 0.01)))
	else:
		detail_lines.append("暴击率 " + str(int(round(clampf(crit_chance, 0.0, 0.95) * 100.0))) + "%")

	var hurt_reduction: float = float(defender_treasure.get("battle_hurt_reduction", 0.0)) * 0.5
	hurt_reduction = clampf(hurt_reduction, 0.0, 0.45)
	if hurt_reduction > 0.0:
		damage *= 1.0 - hurt_reduction
		effects.append(str(defender_treasure.get("name", "法宝")) + "护体")
		detail_lines.append(str(defender_treasure.get("name", "法宝")) + "护体 -" + str(int(round(hurt_reduction * 100.0))) + "%")
	damage = _apply_duel_gold_body(defender, defense_stats, damage, effects)

	var actual_damage: int = max(1, int(round(damage)))
	if damage <= 0.0:
		actual_damage = 0
	defender.qi_xue = maxi(0, defender.qi_xue - actual_damage)
	if bool(attacker_treasure.get("is_growth_sword", false)):
		var sword_message: String = _add_growth_sword_exp(attacker, maxi(1, int(round(float(actual_damage) / 2.0))), "仙争出剑")
		if sword_message != "":
			effects.append(sword_message)
	var heal_rate: float = _get_duel_effect_value(attack_stats, "嗜血", 0.0)
	heal_rate += float(attack_stats.get("吸血", 0.0))
	heal_rate += float(attacker_treasure.get("lifesteal", 0.0))
	if _has_link(attack_stats, "血战") and effects.has("破军暴击"):
		heal_rate *= 2.0
	if heal_rate > 0.0:
		var heal_value: int = int(round(float(actual_damage) * heal_rate))
		attacker.qi_xue = mini(int(attack_stats.get("气血", attacker.qi_xue)), attacker.qi_xue + heal_value)
		effects.append("嗜血回血" + str(heal_value))
		detail_lines.append("吸血回血 " + str(heal_value))

	var thorn_rate: float = _get_duel_effect_value(defense_stats, "荆棘", 0.0)
	thorn_rate += float(defense_stats.get("反伤", 0.0))
	thorn_rate += float(defender_treasure.get("reflect", 0.0))
	if thorn_rate > 0.0:
		if _has_link(defense_stats, "铜墙铁壁") and defender.qi_xue <= int(defense_stats.get("气血", 1)) * 0.35:
			thorn_rate *= 2.0
		var reflected: int = int(round(float(actual_damage) * thorn_rate))
		attacker.qi_xue = maxi(0, attacker.qi_xue - reflected)
		effects.append("荆棘反弹" + str(reflected))
		detail_lines.append("反伤 " + str(reflected))

	var log_text: String = attacker.player_name + "造成" + str(actual_damage) + "点伤害"
	if not effects.is_empty():
		log_text += "（" + "，".join(effects) + "）"
	detail_lines.append("最终伤害 " + str(actual_damage))
	return {"damage": damage, "实际伤害": actual_damage, "特殊效果触发列表": effects, "日志文字": log_text, "暴击": is_crit, "闪避": false, "明细": detail_lines, "攻击方": attacker.player_name, "防守方": defender.player_name}


func _apply_duel_start_of_action(attacker: PlayerData, defender: PlayerData, attack_stats: Dictionary, defense_stats: Dictionary, effects: Array) -> void:
	var attacker_max_hp: int = maxi(1, int(attack_stats.get("气血", attacker.qi_xue)))
	var defender_max_hp: int = maxi(1, int(defense_stats.get("气血", defender.qi_xue)))
	var karmic_debt: int = int(attack_stats.get("因果", 0))
	if karmic_debt > 0:
		var backlash: int = int(round(float(attacker_max_hp) * clampf(float(karmic_debt) * 0.008, 0.0, 0.12)))
		if backlash > 0:
			attacker.qi_xue = maxi(0, attacker.qi_xue - backlash)
			effects.append("心魔反噬-" + str(backlash))
	var attacker_school: String = str(attack_stats.get("流派", ""))
	var build_level: int = int(attack_stats.get("构筑层级", 0))
	if attacker_school == "鬼修" and build_level >= 2:
		var drain: int = maxi(1, int(round(float(defender_max_hp) * (0.025 + float(build_level) * 0.01))))
		defender.qi_xue = maxi(0, defender.qi_xue - drain)
		var heal: int = int(round(float(drain) * 0.45))
		attacker.qi_xue = mini(attacker_max_hp, attacker.qi_xue + heal)
		effects.append("万魂蚀血-" + str(drain))
	if attacker_school == "情修" and build_level >= 3:
		var heal_amount: int = maxi(1, int(round(float(attacker_max_hp) * 0.05)))
		attacker.qi_xue = mini(attacker_max_hp, attacker.qi_xue + heal_amount)
		effects.append("红尘回春+" + str(heal_amount))


func _duel_route_attack_bonus(stats: Dictionary) -> float:
	var school: String = str(stats.get("流派", ""))
	var build_level: int = int(stats.get("构筑层级", 0))
	var treasure_growth: int = int(stats.get("法宝成长", 0))
	match school:
		"剑修":
			return clampf(0.05 * float(build_level) + float(treasure_growth) * 0.006, 0.0, 0.38)
		"鬼修":
			return clampf(0.04 * float(build_level) + float(stats.get("鬼魂强度", 0)) * 0.002, 0.0, 0.34)
		"体修":
			return clampf(0.03 * float(build_level), 0.0, 0.18)
		"情修":
			return clampf(float(stats.get("善因", 0)) * 0.006, 0.0, 0.22)
		_:
			return 0.0


func _duel_route_crit_bonus(stats: Dictionary) -> float:
	if str(stats.get("流派", "")) != "剑修":
		return 0.0
	return clampf(float(stats.get("构筑层级", 0)) * 0.07 + float(stats.get("法宝成长", 0)) * 0.004, 0.0, 0.34)


func _duel_route_crit_damage_bonus(stats: Dictionary) -> float:
	if str(stats.get("流派", "")) != "剑修":
		return 0.0
	return 0.35 if int(stats.get("构筑层级", 0)) >= 2 else 0.0


func _duel_route_damage_reduction(player: PlayerData, stats: Dictionary) -> float:
	var school: String = str(stats.get("流派", ""))
	var build_level: int = int(stats.get("构筑层级", 0))
	var reduction: float = 0.0
	if school == "体修":
		reduction += 0.06 * float(build_level) + float(stats.get("法宝成长", 0)) * 0.004
		if player.qi_xue <= int(stats.get("气血", 1)) * 0.5:
			reduction += 0.08
	if school == "情修":
		reduction += float(stats.get("善因", 0)) * 0.006
	reduction += float(stats.get("隐忍", 0)) * 0.018
	return clampf(reduction, 0.0, 0.42)


func _apply_duel_gold_body(defender: PlayerData, defense_stats: Dictionary, damage: float, effects: Array) -> float:
	if damage <= 0.0:
		return damage
	if str(defense_stats.get("流派", "")) != "体修":
		return damage
	if int(defense_stats.get("构筑层级", 0)) < 3:
		return damage
	if bool(defense_stats.get("金身已用", false)):
		return damage
	var max_hp: int = maxi(1, int(defense_stats.get("气血", defender.qi_xue)))
	if defender.qi_xue > int(round(float(max_hp) * 0.30)):
		return damage
	defense_stats["金身已用"] = true
	effects.append("不灭金身免伤")
	return 0.0


func start_duel_if_host() -> void:
	if not NetworkManager.is_host:
		return
	if duel_data.is_empty():
		var data: Dictionary = prepare_duel()
		NetworkManager.send_message("duel_data", data)
		on_duel_data(data)


func on_duel_data(data: Dictionary) -> void:
	duel_data = data.duplicate(true)
	duel_mode = str(duel_data.get("mode", duel_mode))
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
	attack_stats["战力"] = _duel_combat_power_from_stats(attack_stats)
	defense_stats["战力"] = _duel_combat_power_from_stats(defense_stats)
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

	if str(duel_data.get("mode", duel_mode)) == "sparring":
		if _sparring_should_finish():
			_finish_stage_sparring()
			return

	if player_a.qi_xue <= 0 or player_b.qi_xue <= 0:
		var winner_key: String = "player_b" if player_a.qi_xue <= 0 else "player_a"
		var loser_key: String = "player_a" if winner_key == "player_b" else "player_b"
		var winner: PlayerData = player_a if winner_key == "player_a" else player_b
		var loser: PlayerData = player_b if winner_key == "player_a" else player_a
		var duel_task_message: String = _complete_active_tasks(winner, "duel_win", {})
		if duel_task_message != "":
			logs.append(duel_task_message)
		pending_duel_winner_key = winner_key
		pending_duel_loser_key = loser_key
		logs.append(_duel_finish_reason(winner, loser, duel_data.get(winner_key + "_stats", {}) as Dictionary, duel_data.get(loser_key + "_stats", {}) as Dictionary))
		duel_data["log"] = logs
		var final_stats: Dictionary = duel_data.duplicate(true)
		var ending_data: Dictionary = {
			"winner": winner.player_name,
			"loser": loser.player_name,
			"winner_key": winner_key,
			"loser_key": loser_key,
			"winner_peer_id": winner.peer_id,
			"loser_peer_id": loser.peer_id,
			"awaiting_final_choice": true,
			"final_stats": final_stats,
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


func _duel_finish_reason(winner: PlayerData, loser: PlayerData, winner_stats: Dictionary, loser_stats: Dictionary) -> String:
	if winner == null or loser == null:
		return "胜负已分。"
	var reasons: Array[String] = []
	var winner_base_power: int = _duel_base_power_from_stats(winner_stats)
	var loser_base_power: int = _duel_base_power_from_stats(loser_stats)
	if winner_base_power > loser_base_power:
		reasons.append("面板战力更高")
	elif int(winner_stats.get("战力", 0)) > int(loser_stats.get("战力", 0)):
		reasons.append("残局气血更稳")
	if int(winner_stats.get("速度", 0)) > int(loser_stats.get("速度", 0)):
		reasons.append("速度占优")
	if int(winner_stats.get("法宝成长", 0)) > int(loser_stats.get("法宝成长", 0)):
		reasons.append("法宝成长更强")
	if int(winner_stats.get("构筑层级", 0)) > int(loser_stats.get("构筑层级", 0)):
		reasons.append("构筑层级更高")
	if float(winner_stats.get("暴击率", 0.0)) > float(loser_stats.get("暴击率", 0.0)):
		reasons.append("暴击更高")
	if float(winner_stats.get("闪避率", 0.0)) > float(loser_stats.get("闪避率", 0.0)):
		reasons.append("闪避更高")
	if reasons.is_empty():
		reasons.append("关键回合打出有效伤害")
	return "胜负原因：" + winner.player_name + "胜在" + "、".join(reasons) + "。" + get_visible_combat_power_formula_text() + "；高境界会带来基础属性和对决压制。"


func _sparring_should_finish() -> bool:
	var max_actions: int = int(duel_data.get("max_rounds", SPARRING_MAX_ACTIONS))
	if duel_round_number >= max_actions:
		return true
	if player_a == null or player_b == null:
		return true
	if player_a.qi_xue <= 0 or player_b.qi_xue <= 0:
		return true
	var stats_a: Dictionary = duel_data.get("player_a_stats", {}) as Dictionary
	var stats_b: Dictionary = duel_data.get("player_b_stats", {}) as Dictionary
	var hp_max_a: int = maxi(1, int(stats_a.get("气血", _get_player_max_hp(player_a))))
	var hp_max_b: int = maxi(1, int(stats_b.get("气血", _get_player_max_hp(player_b))))
	return float(player_a.qi_xue) / float(hp_max_a) <= SPARRING_LOW_HP_RATE or float(player_b.qi_xue) / float(hp_max_b) <= SPARRING_LOW_HP_RATE


func _sparring_winner_key() -> String:
	var stats_a: Dictionary = duel_data.get("player_a_stats", {}) as Dictionary
	var stats_b: Dictionary = duel_data.get("player_b_stats", {}) as Dictionary
	var hp_max_a: int = maxi(1, int(stats_a.get("气血", _get_player_max_hp(player_a))))
	var hp_max_b: int = maxi(1, int(stats_b.get("气血", _get_player_max_hp(player_b))))
	var hp_rate_a: float = float(player_a.qi_xue) / float(hp_max_a)
	var hp_rate_b: float = float(player_b.qi_xue) / float(hp_max_b)
	if absf(hp_rate_a - hp_rate_b) > 0.02:
		return "player_a" if hp_rate_a > hp_rate_b else "player_b"
	var power_a: float = get_visible_combat_power(player_a)
	var power_b: float = get_visible_combat_power(player_b)
	if absf(power_a - power_b) > 0.01:
		return "player_a" if power_a >= power_b else "player_b"
	return str(duel_data.get("first_attacker", "player_a"))


func _duel_player_by_key(key: String) -> PlayerData:
	return player_a if key == "player_a" else player_b


func _restore_sparring_hp() -> void:
	if player_a != null:
		player_a.qi_xue = clampi(int(duel_data.get("pre_sparring_hp_a", player_a.qi_xue)), 1, _get_player_max_hp(player_a))
	if player_b != null:
		player_b.qi_xue = clampi(int(duel_data.get("pre_sparring_hp_b", player_b.qi_xue)), 1, _get_player_max_hp(player_b))


func _finish_stage_sparring() -> void:
	var winner_key: String = _sparring_winner_key()
	var loser_key: String = "player_b" if winner_key == "player_a" else "player_a"
	var winner: PlayerData = _duel_player_by_key(winner_key)
	var loser: PlayerData = _duel_player_by_key(loser_key)
	if winner == null or loser == null:
		return
	var winner_ling_li: int = 28 + round_number * 6
	var winner_ling_shi: int = 120 + round_number * 35
	var loser_ling_li: int = maxi(12, int(round(float(winner_ling_li) * 0.55)))
	winner.ling_li += winner_ling_li
	winner.ling_shi += winner_ling_shi
	loser.ling_li += loser_ling_li
	loser.forbearance = clampi(loser.forbearance + 1, 0, MAX_FORBEARANCE)
	var reward_lines: Array[String] = [
		"切磋点到为止，" + winner.player_name + "占得上风",
		winner.player_name + "论道收益：修为 +" + str(winner_ling_li) + "，灵石 +" + str(winner_ling_shi),
		loser.player_name + "败中悟道：修为 +" + str(loser_ling_li) + "，隐忍 +1",
	]
	var treasure_message: String = grow_treasure(winner, 1)
	if treasure_message != "":
		reward_lines.append(treasure_message)
	var winner_study_message: String = _grow_techniques_for_cultivation(winner, _detect_player_school(winner), 1, "切磋印证")
	if winner_study_message != "":
		reward_lines.append(winner_study_message)
	var loser_study_message: String = _grow_techniques_for_cultivation(loser, _detect_player_school(loser), 1, "败中悟道")
	if loser_study_message != "":
		reward_lines.append(loser_study_message)
	var logs: Array = duel_data.get("log", []) as Array
	for line in reward_lines:
		logs.append(line)
	duel_data["log"] = logs
	duel_data["sparring_reward"] = "；".join(reward_lines)
	_restore_sparring_hp()
	var final_stats: Dictionary = duel_data.duplicate(true)
	var ending_data: Dictionary = {
		"mode": "sparring",
		"winner": winner.player_name,
		"loser": loser.player_name,
		"winner_key": winner_key,
		"loser_key": loser_key,
		"winner_peer_id": winner.peer_id,
		"loser_peer_id": loser.peer_id,
		"awaiting_final_choice": false,
		"message": "论道切磋结束",
		"final_stats": final_stats,
	}
	duel_data["ending"] = ending_data
	NetworkManager.send_message("duel_finished", ending_data)
	on_duel_finished(ending_data)


func on_duel_continue_received(peer_id: int, _data: Dictionary = {}) -> void:
	if not NetworkManager.is_host:
		return
	if current_state != GameState.DUEL or duel_mode != "sparring":
		return
	var continue_peer_id: int = peer_id
	if continue_peer_id <= 0:
		continue_peer_id = 1
	duel_continue_votes[continue_peer_id] = true
	if single_player_mode and continue_peer_id == player_a.peer_id and not duel_continue_votes.has(player_b.peer_id):
		duel_continue_votes[player_b.peer_id] = true
	if duel_continue_votes.size() < _lottery_energy_required_count():
		return
	duel_continue_votes.clear()
	_advance_after_sparring()


func on_duel_update(data: Dictionary) -> void:
	duel_data = data.duplicate(true)
	duel_round_number = int(duel_data.get("round", duel_round_number))
	duel_updated.emit(duel_data)
	_auto_save("duel_update")


func on_duel_finished(data: Dictionary) -> void:
	if str(data.get("mode", duel_mode)) == "sparring":
		duel_finished.emit(data)
		_auto_save("sparring_finished")
		return
	pending_duel_winner_key = str(data.get("winner_key", pending_duel_winner_key))
	pending_duel_loser_key = str(data.get("loser_key", pending_duel_loser_key))
	duel_finished.emit(data)
	_auto_save("duel_finished")
	if single_player_mode and pending_duel_winner_key == "player_b":
		_queue_npc_final_choice()


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


func _get_duel_effect_value(_stats: Dictionary, _resonance_name: String, default_value: float) -> float:
	return default_value


func _has_link(stats: Dictionary, link_name: String) -> bool:
	var links: Array = stats.get("联动列表", []) as Array
	for link in links:
		if link is Dictionary and str(link.get("name", "")) == link_name:
			return true
	return false


func generate_treasure(quality: String = "") -> Dictionary:
	var candidates: Array = []
	if quality != "":
		for treasure_item in _all_treasure_templates():
			var treasure_data: Dictionary = treasure_item as Dictionary
			if str(treasure_data.get("quality", "")) == quality:
				candidates.append(treasure_data)
	if candidates.is_empty():
		for treasure_item in _all_treasure_templates():
			candidates.append(treasure_item)

	var treasure: Dictionary = (candidates[rng.randi_range(0, candidates.size() - 1)] as Dictionary).duplicate(true)
	return _prepare_treasure(treasure)


func generate_treasure_for_player(player: PlayerData, quality: String = "") -> Dictionary:
	var candidates: Array = []
	for treasure_item in _all_treasure_templates():
		var treasure_data: Dictionary = treasure_item as Dictionary
		if quality != "" and str(treasure_data.get("quality", "")) != quality:
			continue
		candidates.append(treasure_data)
	if candidates.is_empty():
		return generate_treasure(quality)
	var treasure: Dictionary = (candidates[rng.randi_range(0, candidates.size() - 1)] as Dictionary).duplicate(true)
	return _prepare_treasure(treasure, _player_sect(player))


func _all_treasure_templates() -> Array:
	var templates: Array = []
	for treasure_item in TREASURE_POOL:
		templates.append(treasure_item)
	for sect_name in SECT_BUILD_DATA.keys():
		var sect_data: Dictionary = SECT_BUILD_DATA[sect_name] as Dictionary
		var treasures: Array = sect_data.get("treasures", []) as Array
		for treasure in treasures:
			var treasure_data: Dictionary = (treasure as Dictionary).duplicate(true)
			treasure_data["sect"] = str(sect_name)
			treasure_data["school"] = str(sect_name)
			templates.append(treasure_data)
	return templates


func _make_growth_sword() -> Dictionary:
	var sword: Dictionary = {
		"name": "本命飞剑",
		"quality": "筑基级",
		"school": "剑修",
		"attack_name": "飞剑出鞘",
		"is_growth_sword": true,
		"growth_level": 1,
		"growth_exp": 0,
		"battle_damage": 3,
		"duel_damage": 7,
		"crit_chance": 0.04,
		"ignore_defense": 0.04,
		"passive_bonus": {"攻击力": 0.08, "速度": 6},
		"use_effect": "剑修本命法宝。每次出剑、击败敌人、获得修为都会成长。",
	}
	return sword


func _ensure_growth_sword(player: PlayerData) -> String:
	if player == null:
		return ""
	if not _find_growth_sword(player).is_empty():
		return "本命飞剑已在身侧"
	return _store_equipment_item(player, "treasure", _make_growth_sword())


func _find_growth_sword(player: PlayerData) -> Dictionary:
	if player == null:
		return {}
	for treasure in player.treasures:
		if treasure is Dictionary and bool((treasure as Dictionary).get("is_growth_sword", false)):
			return treasure as Dictionary
	for entry in player.backpack:
		if entry is Dictionary:
			var entry_data: Dictionary = (entry as Dictionary).get("data", {}) as Dictionary
			if bool(entry_data.get("is_growth_sword", false)):
				return entry_data
	var key: String = str(player.peer_id)
	if pending_backpack_items.has(key):
		var pending_entry: Dictionary = pending_backpack_items[key] as Dictionary
		var pending_data: Dictionary = pending_entry.get("data", {}) as Dictionary
		if bool(pending_data.get("is_growth_sword", false)):
			return pending_data
	return {}


func _add_growth_sword_exp(player: PlayerData, amount: int, reason: String = "") -> String:
	if amount <= 0:
		return ""
	var sword: Dictionary = _find_growth_sword(player)
	if sword.is_empty():
		return ""
	var before_level: int = int(sword.get("growth_level", 1))
	sword["growth_exp"] = int(sword.get("growth_exp", 0)) + amount
	var new_level: int = maxi(1, 1 + int(floor(float(int(sword.get("growth_exp", 0))) / 90.0)))
	sword["growth_level"] = new_level
	_refresh_growth_sword_stats(sword)
	if new_level > before_level:
		var reason_text: String = "，因" + reason if reason != "" else ""
		return "本命飞剑升至" + str(new_level) + "阶" + reason_text
	return ""


func _refresh_growth_sword_stats(sword: Dictionary) -> void:
	var level: int = maxi(1, int(sword.get("growth_level", 1)))
	sword["quality"] = _growth_sword_quality(level)
	sword["battle_damage"] = 2 + level
	sword["duel_damage"] = 5 + level * 3
	sword["crit_chance"] = 0.03 + float(level) * 0.012
	sword["ignore_defense"] = 0.03 + float(level) * 0.01
	sword["passive_bonus"] = {"攻击力": 0.06 + float(level) * 0.018, "速度": 4 + level * 2}
	sword["use_effect"] = "本命飞剑 " + str(level) + "阶。战斗伤害+" + str(int(sword["battle_damage"])) + "，对决伤害+" + str(int(sword["duel_damage"])) + "，会继续成长。"


func _growth_sword_quality(level: int) -> String:
	if level >= 9:
		return "合体级"
	if level >= 6:
		return "化神级"
	if level >= 4:
		return "元婴级"
	if level >= 2:
		return "金丹级"
	return "筑基级"


func generate_companion(quality: String = "") -> Dictionary:
	var candidates: Array = []
	for companion_item in COMPANION_POOL:
		var companion_data: Dictionary = companion_item as Dictionary
		if quality == "" or str(companion_data.get("quality", "")) == quality:
			candidates.append(companion_data)
	if candidates.is_empty():
		candidates = COMPANION_POOL.duplicate()
	var companion: Dictionary = (candidates[rng.randi_range(0, candidates.size() - 1)] as Dictionary).duplicate(true)
	companion["alive"] = true
	_prepare_companion(companion)
	return companion


func generate_companion_for_player(player: PlayerData, quality: String = "") -> Dictionary:
	var candidates: Array = []
	for companion_item in COMPANION_POOL:
		var companion_data: Dictionary = companion_item as Dictionary
		if quality == "" or str(companion_data.get("quality", "")) == quality:
			candidates.append(companion_data)
	if candidates.is_empty():
		candidates = COMPANION_POOL.duplicate()
	var companion: Dictionary = (candidates[rng.randi_range(0, candidates.size() - 1)] as Dictionary).duplicate(true)
	companion["alive"] = true
	_prepare_companion(companion, player)
	return companion


func _prepare_companion(companion: Dictionary, player: PlayerData = null) -> void:
	if companion.is_empty():
		return
	companion.erase("school")
	companion.erase("hp")
	companion.erase("max_hp")
	companion.erase("attack")
	companion.erase("defense")
	companion["alive"] = true
	_normalize_companion_bonus(companion)
	_ensure_item_affixes(companion, "companion")
	var sect_support: String = _companion_sect_affix(companion)
	companion["sect_support"] = sect_support
	companion["alignment"] = _companion_alignment(companion)
	if not companion.has("bond"):
		var quality: String = str(companion.get("quality", "炼气级"))
		var base_bond: int = _companion_quality_base_bond(quality)
		var charm_bonus: int = int(player.stats.get("魅力", 0)) if player != null else 0
		companion["bond"] = mini(base_bond + charm_bonus, base_bond * 8)
	var max_bond: int = _companion_bond_max(companion)
	companion["bond"] = clampi(int(companion.get("bond", 0)), 0, max_bond)
	companion["bond_max"] = max_bond
	var prepared_bond_stage: int = get_companion_bond_stage(int(companion.get("bond", 0)))
	companion["bond_full_unlocked"] = _companion_bond_is_full(companion)
	if bool(companion["bond_full_unlocked"]):
		prepared_bond_stage = 3
	companion["bond_stage"] = prepared_bond_stage
	var full_bonus_type: String = str(companion.get("full_bonus_type", companion.get("bonus_type", "灵力获取")))
	if not COMPANION_PASSIVE_KEYS.has(full_bonus_type):
		full_bonus_type = str(companion.get("bonus_type", "灵力获取"))
	companion["full_bonus_type"] = full_bonus_type
	companion["full_bonus_value"] = float(companion.get("full_bonus_value", _companion_full_bonus_value(companion)))
	companion["full_effect_desc"] = "满羁绊解锁：" + _format_companion_bonus_desc(str(companion.get("full_bonus_type", "灵力获取")), float(companion.get("full_bonus_value", 0.0)))
	companion["effect_desc"] = _format_companion_bonus_desc(str(companion.get("bonus_type", "灵力获取")), float(companion.get("bonus_value", 0.0)))
	_refresh_item_build_tags(companion)


func _sect_companion_names(sect_name: String) -> Array[String]:
	var names: Array[String] = []
	if not SECT_BUILD_DATA.has(sect_name):
		return names
	var sect_data: Dictionary = SECT_BUILD_DATA[sect_name] as Dictionary
	var companions: Array = sect_data.get("companions", []) as Array
	for companion_name in companions:
		names.append(str(companion_name))
	return names


func _gain_companion_or_ghost(player: PlayerData, companion: Dictionary, _scale: float = 1.0) -> String:
	if player == null:
		return "伙伴无处可去"
	_prepare_companion(companion, player)
	return _store_equipment_item(player, "companion", companion)


func _has_companion(player: PlayerData, companion_name: String) -> bool:
	if player == null or companion_name == "":
		return false
	for companion in player.companions:
		if companion is Dictionary and str((companion as Dictionary).get("name", "")) == companion_name:
			return true
	return false


func _ghost_attack_damage(player: PlayerData, duel: bool = false) -> int:
	if player == null:
		return 0
	var route_level: int = _cultivation_route_level(player, "鬼修")
	var ghost_power: int = int(player.final_attributes.get("ghost_power", 0))
	if ghost_power <= 0 and route_level <= 0:
		return 0
	if duel:
		return maxi(1, int(round(float(ghost_power) * 0.16 + float(route_level) * 2.0)))
	return maxi(1, int(round(float(ghost_power) / 18.0 + float(route_level))))


func _feed_ghosts(player: PlayerData, amount: int, reason: String = "") -> String:
	if player == null or amount <= 0 or int(player.final_attributes.get("ghost_power", 0)) <= 0:
		return ""
	player.final_attributes["ghost_power"] = int(player.final_attributes.get("ghost_power", 0)) + amount
	var reason_text: String = "，" + reason if reason != "" else ""
	return player.player_name + "役鬼吞煞，鬼魂 +" + str(amount) + reason_text


func apply_companion_bonus(player: PlayerData) -> void:
	if player == null:
		return

	for companion in player.companions:
		if not companion is Dictionary:
			continue
		var companion_data: Dictionary = companion
		if bool(companion_data.get("bonus_applied", false)):
			_remove_companion_bonus(player, companion_data)
		_prepare_companion(companion_data, player)
		companion_data["bonus_applied"] = false
		companion_data.erase("applied_bonus_type")
		companion_data.erase("applied_bonus_value")
		companion_data.erase("applied_affix_bonus")


func _remove_companion_bonus(player: PlayerData, companion_data: Dictionary) -> void:
	if player == null or companion_data.is_empty():
		return
	if not bool(companion_data.get("bonus_applied", false)):
		return

	var bonus_type: String = str(companion_data.get("applied_bonus_type", companion_data.get("bonus_type", "")))
	var bonus_value: float = float(companion_data.get("applied_bonus_value", companion_data.get("bonus_value", 0.0)))
	match bonus_type:
		"攻击力", "防御力", "气血上限", "灵力获取", "全属性":
			player.refined_bonuses[bonus_type] = float(player.refined_bonuses.get(bonus_type, 0.0)) - bonus_value
		"速度":
			player.speed -= int(round(bonus_value))
		_:
			player.final_attributes[bonus_type] = float(player.final_attributes.get(bonus_type, 0.0)) - bonus_value
	_apply_companion_affix_bonus(player, companion_data.get("applied_affix_bonus", {}) as Dictionary, -1.0)
	companion_data["bonus_applied"] = false
	companion_data.erase("applied_bonus_type")
	companion_data.erase("applied_bonus_value")
	companion_data.erase("applied_affix_bonus")


func _apply_companion_affix_bonus(player: PlayerData, bonuses: Dictionary, sign: float) -> void:
	if player == null or bonuses.is_empty():
		return
	for bonus_name in bonuses:
		var bonus_key: String = str(bonus_name)
		var value: float = float(bonuses[bonus_name]) * sign
		match bonus_key:
			"攻击力", "防御力", "气血上限", "灵力获取", "全属性", "吸血", "破防", "反伤":
				player.refined_bonuses[bonus_key] = float(player.refined_bonuses.get(bonus_key, 0.0)) + value
			"速度":
				player.speed += int(round(value))
			_:
				player.final_attributes[bonus_key] = float(player.final_attributes.get(bonus_key, 0.0)) + value


func _make_backpack_entry(kind: String, item_data: Dictionary) -> Dictionary:
	return {"kind": kind, "data": item_data.duplicate(true)}


func _make_material_item(material_type: String, quality: String) -> Dictionary:
	var name: String = _material_name(material_type, quality)
	return {
		"name": name,
		"quality": quality,
		"material_type": material_type,
		"effect_desc": _material_effect_desc(material_type),
	}


func _material_name(material_type: String, quality: String) -> String:
	if material_type == "craft":
		match quality:
			"炼气级":
				return "凡铁矿"
			"筑基级":
				return "赤铜矿"
			"金丹级":
				return "玄铁"
			"元婴级":
				return "星陨铁"
			"化神级":
				return "太乙金精"
			"合体级":
				return "混元仙金"
			_:
				return "矿材"
	match quality:
		"炼气级":
			return "青灵草"
		"筑基级":
			return "玄露草"
		"金丹级":
			return "金纹芝"
		"元婴级":
			return "婴火莲"
		"化神级":
			return "紫府参"
		"合体级":
			return "九转仙芝"
		_:
			return "灵草"


func _material_effect_desc(material_type: String) -> String:
	return "炼器材料，用于淬炼上场法宝" if material_type == "craft" else "炼丹材料，用于开炉炼丹"


func _backpack_kind_count(player: PlayerData, kind: String) -> int:
	if player == null:
		return 0
	var count: int = 0
	for entry in player.backpack:
		if entry is Dictionary and str((entry as Dictionary).get("kind", "")) == kind:
			count += 1
	return count


func get_backpack_kind_limit(kind: String) -> int:
	match kind:
		"technique":
			return MAX_BACKPACK_TECHNIQUES
		"treasure":
			return MAX_BACKPACK_TREASURES
		"companion":
			return MAX_BACKPACK_COMPANIONS
		"material":
			return MAX_BACKPACK_MATERIALS
		_:
			return 0


func get_total_backpack_capacity() -> int:
	return MAX_BACKPACK_CAPACITY


func get_backpack_counts(player: PlayerData) -> Dictionary:
	return {
		"technique": _backpack_kind_count(player, "technique"),
		"treasure": _backpack_kind_count(player, "treasure"),
		"companion": _backpack_kind_count(player, "companion"),
		"material": _backpack_kind_count(player, "material"),
	}


func get_backpack_counts_text(player: PlayerData) -> String:
	var counts: Dictionary = get_backpack_counts(player)
	return "功法 " + str(int(counts.get("technique", 0))) + "/" + str(MAX_BACKPACK_TECHNIQUES) + "  法宝 " + str(int(counts.get("treasure", 0))) + "/" + str(MAX_BACKPACK_TREASURES) + "  伙伴 " + str(int(counts.get("companion", 0))) + "/" + str(MAX_BACKPACK_COMPANIONS) + "  材料 " + str(int(counts.get("material", 0))) + "/" + str(MAX_BACKPACK_MATERIALS)


func can_store_backpack_kind(player: PlayerData, kind: String) -> bool:
	var limit: int = get_backpack_kind_limit(kind)
	return player != null and limit > 0 and _backpack_kind_count(player, kind) < limit


func _add_to_scattered_pool(entry: Dictionary, owner_peer_id: int = 0, reason: String = "") -> void:
	if entry.is_empty():
		return
	var kind: String = str(entry.get("kind", ""))
	if not ["technique", "treasure", "companion"].has(kind):
		return
	var data: Dictionary = (entry.get("data", {}) as Dictionary).duplicate(true)
	if data.is_empty():
		return
	scattered_pool.append({
		"kind": kind,
		"data": data,
		"owner_peer_id": owner_peer_id,
		"round": round_number,
		"reason": reason,
	})
	while scattered_pool.size() > MAX_SCATTERED_POOL_SIZE:
		scattered_pool.remove_at(0)


func _try_generate_scattered_ji_yuan(stat: int, effect_type: String) -> Dictionary:
	if not ["technique", "treasure", "companion"].has(effect_type):
		return {}
	if scattered_pool.is_empty() or rng.randf() > SCATTERED_POOL_REAPPEAR_RATE:
		return {}
	var indices: Array[int] = []
	for i in range(scattered_pool.size()):
		var entry: Dictionary = scattered_pool[i] as Dictionary
		if str(entry.get("kind", "")) == effect_type:
			indices.append(i)
	if indices.is_empty():
		return {}
	var pool_index: int = int(indices[rng.randi_range(0, indices.size() - 1)])
	var scattered_entry: Dictionary = (scattered_pool[pool_index] as Dictionary).duplicate(true)
	scattered_pool.remove_at(pool_index)
	return _build_scattered_ji_yuan(stat, scattered_entry)


func _build_scattered_ji_yuan(stat: int, scattered_entry: Dictionary) -> Dictionary:
	var kind: String = str(scattered_entry.get("kind", ""))
	var item_data: Dictionary = (scattered_entry.get("data", {}) as Dictionary).duplicate(true)
	var quality: String = str(item_data.get("quality", roll_quality(get_adjusted_quality_prob(stat))))
	var data: Dictionary = {
		"quality": quality,
		"type": "散落机缘",
		"effect_type": kind,
		"base_effect": 1,
		"effect_value": 1,
		"value": 1,
		"multiplier": float(QUALITY_MULTIPLIER.get(quality, 1.0)),
		"scattered_entry": true,
		"scattered_from_peer_id": int(scattered_entry.get("owner_peer_id", 0)),
		"desc": "散落池：" + _item_kind_name(kind) + "《" + str(item_data.get("name", "未知")) + "》重新现世",
	}
	data[kind] = item_data
	return data


func _player_backpack_issue(player: PlayerData) -> String:
	if player == null:
		return ""
	if pending_backpack_items.has(str(player.peer_id)):
		return "还有待处理组件，请装备或丢弃后再继续"
	for kind in ["technique", "treasure", "companion", "material"]:
		var count: int = _backpack_kind_count(player, kind)
		var limit: int = get_backpack_kind_limit(kind)
		if count > limit:
			return _item_kind_name(kind) + "背包超出上限 " + str(count) + "/" + str(limit) + "，请丢弃或替换"
	return ""


func _player_has_technique_name(player: PlayerData, technique_name: String) -> bool:
	if player == null or technique_name == "":
		return false
	for technique in player.techniques:
		if technique is Dictionary and str((technique as Dictionary).get("name", "")) == technique_name:
			return true
	for entry in player.backpack:
		if entry is Dictionary:
			var entry_data: Dictionary = (entry as Dictionary).get("data", {}) as Dictionary
			if str((entry as Dictionary).get("kind", "")) == "technique" and str(entry_data.get("name", "")) == technique_name:
				return true
	var pending_entry: Dictionary = pending_backpack_items.get(str(player.peer_id), {}) as Dictionary
	if not pending_entry.is_empty() and str(pending_entry.get("kind", "")) == "technique":
		var pending_data: Dictionary = pending_entry.get("data", {}) as Dictionary
		return str(pending_data.get("name", "")) == technique_name
	return false


func _duplicate_technique_insight(player: PlayerData, technique_name: String, quality: String) -> String:
	if player == null:
		return "同名功法残卷失散"
	var owned_technique: Dictionary = _find_owned_technique(player, technique_name)
	if not owned_technique.is_empty():
		return _add_technique_fragment_progress(player, owned_technique, TECHNIQUE_DUPLICATE_FRAGMENT_PROGRESS, "同名残卷")
	var amount: int = maxi(18, int(round(38.0 * _quality_power(quality))))
	var before_stage: String = get_cultivation_stage_name(player)
	player.ling_li += amount
	var message: String = "已参悟《" + technique_name + "》，同名功法化为悟道，修为 +" + str(amount)
	message = _append_stage_change_to_message(player, before_stage, message)
	var sword_message: String = _add_growth_sword_exp(player, maxi(1, int(round(float(amount) / 24.0))), "悟道")
	if sword_message != "":
		message += "；" + sword_message
	return message


func _find_owned_technique(player: PlayerData, technique_name: String) -> Dictionary:
	if player == null or technique_name == "":
		return {}
	for technique in player.techniques:
		if technique is Dictionary and str((technique as Dictionary).get("name", "")) == technique_name:
			return technique as Dictionary
	for entry in player.backpack:
		if entry is Dictionary:
			var entry_data: Dictionary = (entry as Dictionary).get("data", {}) as Dictionary
			if str((entry as Dictionary).get("kind", "")) == "technique" and str(entry_data.get("name", "")) == technique_name:
				return entry_data
	var pending_entry: Dictionary = pending_backpack_items.get(str(player.peer_id), {}) as Dictionary
	if not pending_entry.is_empty() and str(pending_entry.get("kind", "")) == "technique":
		var pending_data: Dictionary = pending_entry.get("data", {}) as Dictionary
		if str(pending_data.get("name", "")) == technique_name:
			return pending_data
	return {}


func _find_first_upgradeable_technique(player: PlayerData) -> Dictionary:
	if player == null:
		return {}
	for technique in player.techniques:
		if not technique is Dictionary:
			continue
		var technique_data: Dictionary = technique as Dictionary
		var realm: String = str(technique_data.get("technique_realm", "初窥"))
		if _next_technique_realm(realm) != realm:
			return technique_data
	for entry in player.backpack:
		if not entry is Dictionary:
			continue
		var entry_data: Dictionary = entry as Dictionary
		if str(entry_data.get("kind", "")) != "technique":
			continue
		var item_data: Dictionary = entry_data.get("data", {}) as Dictionary
		if _next_technique_realm(str(item_data.get("technique_realm", "初窥"))) != str(item_data.get("technique_realm", "初窥")):
			return item_data
	return {}


func _player_has_stored_technique_name(player: PlayerData, technique_name: String) -> bool:
	if player == null or technique_name == "":
		return false
	for technique in player.techniques:
		if technique is Dictionary and str((technique as Dictionary).get("name", "")) == technique_name:
			return true
	for entry in player.backpack:
		if entry is Dictionary:
			var entry_data: Dictionary = (entry as Dictionary).get("data", {}) as Dictionary
			if str((entry as Dictionary).get("kind", "")) == "technique" and str(entry_data.get("name", "")) == technique_name:
				return true
	return false


func _next_technique_realm(current_realm: String) -> String:
	match current_realm:
		"初窥":
			return "小成"
		"小成":
			return "大成"
		_:
			return current_realm


func _technique_realm_fragment_req(current_realm: String) -> int:
	return int(TECHNIQUE_REALM_FRAGMENT_REQ.get(current_realm, 999))


func _add_technique_fragment_progress(player: PlayerData, technique: Dictionary, amount: int, source: String) -> String:
	if technique.is_empty():
		return "未找到可参悟功法"
	var technique_name: String = str(technique.get("name", "未知功法"))
	var before_realm: String = str(technique.get("technique_realm", "初窥"))
	var next_realm: String = _next_technique_realm(before_realm)
	if next_realm == before_realm:
		if bool(technique.get("max_conversion_done", false)):
			return ""
		var quality: String = str(technique.get("quality", "筑基级"))
		var insight: int = maxi(12, int(round(18.0 * _quality_power(quality))))
		player.ling_li += insight
		technique["max_conversion_done"] = true
		return "《" + technique_name + "》已至大成，" + source + "化为修为 +" + str(insight)

	var progress: int = int(technique.get("realm_progress", 0)) + maxi(1, amount)
	var required: int = _technique_realm_fragment_req(before_realm)
	if progress >= required:
		technique["technique_realm"] = next_realm
		technique["realm_progress"] = progress - required
		technique["realm_bonus"] = _technique_stage_multiplier(technique)
		check_set_bonus(player)
		return "《" + technique_name + "》" + source + "参悟圆满，由" + before_realm + "升至" + next_realm + "，功效" + get_technique_stage_multiplier_text(next_realm)

	technique["realm_progress"] = progress
	return "《" + technique_name + "》" + source + "参悟 +" + str(amount) + "（" + str(progress) + "/" + str(required) + "）"


func _cleanup_duplicate_techniques(player: PlayerData) -> void:
	if player == null:
		return

	var seen: Dictionary = {}
	var remove_technique_indices: Array[int] = []
	for i in range(player.techniques.size()):
		var technique: Variant = player.techniques[i]
		if not technique is Dictionary:
			continue
		var technique_data: Dictionary = technique as Dictionary
		var technique_name: String = str(technique_data.get("name", ""))
		if technique_name == "":
			continue
		if seen.has(technique_name):
			remove_technique_indices.append(i)
			_add_technique_fragment_progress(player, seen[technique_name] as Dictionary, TECHNIQUE_DUPLICATE_FRAGMENT_PROGRESS, "同名旧卷")
		else:
			seen[technique_name] = technique_data
	for remove_index in range(remove_technique_indices.size() - 1, -1, -1):
		player.techniques.remove_at(remove_technique_indices[remove_index])

	var remove_backpack_indices: Array[int] = []
	for i in range(player.backpack.size()):
		var entry: Variant = player.backpack[i]
		if not entry is Dictionary:
			continue
		var entry_data: Dictionary = entry as Dictionary
		if str(entry_data.get("kind", "")) != "technique":
			continue
		var item_data: Dictionary = entry_data.get("data", {}) as Dictionary
		var item_name: String = str(item_data.get("name", ""))
		if item_name == "":
			continue
		if seen.has(item_name):
			remove_backpack_indices.append(i)
			_add_technique_fragment_progress(player, seen[item_name] as Dictionary, TECHNIQUE_DUPLICATE_FRAGMENT_PROGRESS, "同名旧卷")
		else:
			seen[item_name] = item_data
	for remove_index in range(remove_backpack_indices.size() - 1, -1, -1):
		player.backpack.remove_at(remove_backpack_indices[remove_index])


func _normalize_player_technique_inventory(player: PlayerData) -> void:
	if player == null:
		return
	player.technique_slots = MAX_EQUIPPED_TECHNIQUES
	player.backpack_capacity = get_total_backpack_capacity()
	var normalized_techniques: Array = []
	for technique in player.techniques:
		if not technique is Dictionary:
			continue
		if normalized_techniques.size() >= MAX_EQUIPPED_TECHNIQUES:
			break
		normalized_techniques.append(_prepare_technique(technique as Dictionary))
	player.techniques = normalized_techniques
	for i in range(player.backpack.size()):
		var entry: Variant = player.backpack[i]
		if not entry is Dictionary:
			continue
		var entry_data: Dictionary = entry as Dictionary
		if str(entry_data.get("kind", "")) != "technique":
			continue
		var item_data: Dictionary = entry_data.get("data", {}) as Dictionary
		entry_data["data"] = _prepare_technique(item_data)
		player.backpack[i] = entry_data
	var normalized_treasures: Array = []
	for treasure in player.treasures:
		if not treasure is Dictionary:
			continue
		if normalized_treasures.size() >= MAX_EQUIPPED_TREASURES:
			break
		normalized_treasures.append(_prepare_treasure(treasure as Dictionary, _player_sect(player)))
	player.treasures = normalized_treasures
	for i in range(player.backpack.size()):
		var treasure_entry: Variant = player.backpack[i]
		if not treasure_entry is Dictionary:
			continue
		var treasure_entry_data: Dictionary = treasure_entry as Dictionary
		if str(treasure_entry_data.get("kind", "")) != "treasure":
			continue
		var treasure_item_data: Dictionary = treasure_entry_data.get("data", {}) as Dictionary
		treasure_entry_data["data"] = _prepare_treasure(treasure_item_data, _player_sect(player))
		player.backpack[i] = treasure_entry_data
	var normalized_companions: Array = []
	for companion in player.companions:
		if not companion is Dictionary:
			continue
		if normalized_companions.size() >= MAX_COMPANIONS:
			break
		var companion_data: Dictionary = companion as Dictionary
		if bool(companion_data.get("bonus_applied", false)):
			_remove_companion_bonus(player, companion_data)
		_prepare_companion(companion_data, player)
		normalized_companions.append(companion_data)
	player.companions = normalized_companions
	for i in range(player.backpack.size()):
		var companion_entry: Variant = player.backpack[i]
		if not companion_entry is Dictionary:
			continue
		var companion_entry_data: Dictionary = companion_entry as Dictionary
		if str(companion_entry_data.get("kind", "")) != "companion":
			continue
		var companion_item_data: Dictionary = companion_entry_data.get("data", {}) as Dictionary
		_prepare_companion(companion_item_data, player)
		companion_entry_data["data"] = companion_item_data
		player.backpack[i] = companion_entry_data


func _grant_technique_reward(player: PlayerData, quality: String) -> String:
	var technique: Dictionary = generate_unique_technique(player, quality)
	if technique.is_empty():
		return _duplicate_technique_insight(player, "诸般旧法", quality)
	return _store_equipment_item(player, "technique", technique)


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
		"material":
			return "材料"
		_:
			return "物品"


func _store_equipment_item(player: PlayerData, kind: String, item_data: Dictionary) -> String:
	if player == null or item_data.is_empty():
		return "物品失落"
	match kind:
		"technique":
			item_data = _prepare_technique(item_data)
		"treasure":
			item_data = _prepare_treasure(item_data, _player_sect(player))
			_apply_player_treasure_growth_cap(player, item_data)
		"companion":
			_prepare_companion(item_data, player)
	if kind == "technique" and _player_has_technique_name(player, str(item_data.get("name", ""))):
		return _duplicate_technique_insight(player, str(item_data.get("name", "未知功法")), str(item_data.get("quality", "筑基级")))
	var entry: Dictionary = _make_backpack_entry(kind, item_data)
	var limit: int = get_backpack_kind_limit(kind)
	if limit <= 0:
		return _collection_message(player, _backpack_item_label(entry) + "暂不能收入背包")
	var new_storage_over_limit: bool = _backpack_kind_count(player, kind) >= limit
	player.backpack.append(entry)
	player.backpack_capacity = get_total_backpack_capacity()
	var new_store_message: String = _backpack_item_label(entry) + "收入背包，打开背包装备后生效"
	if kind == "treasure":
		var treasure_study_message: String = _grow_techniques_for_cultivation(player, "器修", 1, "得宝参器")
		if treasure_study_message != "":
			new_store_message += "；" + treasure_study_message
	if new_storage_over_limit:
		new_store_message += "（已超出" + _item_kind_name(kind) + "上限，请打开背包清理）"
	return _collection_message(player, new_store_message)
	if _backpack_kind_count(player, kind) >= limit:
		pending_backpack_items[str(player.peer_id)] = entry
		return _collection_message(player, _item_kind_name(kind) + "背包已满：" + _backpack_item_label(entry) + "暂未收入，请打开背包清理")
	player.backpack.append(entry)
	player.backpack_capacity = get_total_backpack_capacity()
	var stored_message: String = _backpack_item_label(entry) + "收入背包，打开背包装备后生效"
	return _collection_message(player, stored_message)
	if kind == "treasure" and _backpack_kind_count(player, "treasure") >= MAX_BACKPACK_TREASURES:
		pending_backpack_items[str(player.peer_id)] = entry
		return _collection_message(player, "法宝背包已满：" + _backpack_item_label(entry) + "暂未收入，请先清理")
	if kind == "companion" and _backpack_kind_count(player, "companion") >= MAX_BACKPACK_COMPANIONS:
		pending_backpack_items[str(player.peer_id)] = entry
		return _collection_message(player, "伙伴背包已满：" + _backpack_item_label(entry) + "暂未收入，请先清理")
	if player.backpack.size() < player.backpack_capacity:
		player.backpack.append(entry)
		var backpack_message: String = _backpack_item_label(entry) + "收入背包，点背包装备后才会生效"
		return _collection_message(player, backpack_message)

	pending_backpack_items[str(player.peer_id)] = entry
	return _collection_message(player, "背包已满：" + _backpack_item_label(entry) + "暂未收入，请先清理")


func _store_material_item(player: PlayerData, material_type: String, quality: String) -> String:
	if player == null:
		return "材料失落"
	var material: Dictionary = _make_material_item(material_type, quality)
	return _store_material_data(player, material)


func _store_material_data(player: PlayerData, material: Dictionary) -> String:
	if player == null or material.is_empty():
		return "材料失落"
	var entry: Dictionary = _make_backpack_entry("material", material)
	var limit: int = get_backpack_kind_limit("material")
	if limit <= 0:
		return _collection_message(player, _backpack_item_label(entry) + "暂不能收入背包")
	var over_limit: bool = _backpack_kind_count(player, "material") >= limit
	player.backpack.append(entry)
	player.backpack_capacity = get_total_backpack_capacity()
	var message: String = _backpack_item_label(entry) + "收入背包"
	if over_limit:
		message += "（材料已超出上限，请打开背包清理）"
	return _collection_message(player, message)


func _try_store_pending_backpack_item(player: PlayerData) -> String:
	if player == null:
		return ""
	var key: String = str(player.peer_id)
	if not pending_backpack_items.has(key):
		return ""

	var entry: Dictionary = pending_backpack_items[key] as Dictionary
	var pending_kind: String = str(entry.get("kind", ""))
	var pending_item_data: Dictionary = entry.get("data", {}) as Dictionary
	match pending_kind:
		"technique":
			pending_item_data = _prepare_technique(pending_item_data)
			entry["data"] = pending_item_data
		"treasure":
			pending_item_data = _prepare_treasure(pending_item_data, _player_sect(player))
			_apply_player_treasure_growth_cap(player, pending_item_data)
			entry["data"] = pending_item_data
		"companion":
			_prepare_companion(pending_item_data, player)
			entry["data"] = pending_item_data
	if pending_kind == "technique" and _player_has_stored_technique_name(player, str(pending_item_data.get("name", ""))):
		pending_backpack_items.erase(key)
		return _duplicate_technique_insight(player, str(pending_item_data.get("name", "未知功法")), str(pending_item_data.get("quality", "筑基级")))
	var pending_limit: int = get_backpack_kind_limit(pending_kind)
	if pending_limit <= 0 or _backpack_kind_count(player, pending_kind) >= pending_limit:
		return ""
	player.backpack.append(entry)
	player.backpack_capacity = get_total_backpack_capacity()
	pending_backpack_items.erase(key)
	var stored_pending_message: String = _backpack_item_label(entry) + "已收入背包，打开背包装备后生效"
	return _collection_message(player, stored_pending_message)
	var kind: String = str(entry.get("kind", ""))
	var item_data: Dictionary = entry.get("data", {}) as Dictionary
	match kind:
		"technique":
			item_data = _prepare_technique(item_data)
			entry["data"] = item_data
		"treasure":
			item_data = _prepare_treasure(item_data, _player_sect(player))
			_apply_player_treasure_growth_cap(player, item_data)
			entry["data"] = item_data
		"companion":
			_prepare_companion(item_data, player)
			entry["data"] = item_data
	if kind == "technique" and _player_has_stored_technique_name(player, str(item_data.get("name", ""))):
		pending_backpack_items.erase(key)
		return _duplicate_technique_insight(player, str(item_data.get("name", "未知功法")), str(item_data.get("quality", "筑基级")))
	if kind == "treasure" and _backpack_kind_count(player, "treasure") >= MAX_BACKPACK_TREASURES:
		return ""
	if kind == "companion" and _backpack_kind_count(player, "companion") >= MAX_BACKPACK_COMPANIONS:
		return ""
	if player.backpack.size() < player.backpack_capacity:
		player.backpack.append(entry)
		pending_backpack_items.erase(key)
		var pending_backpack_message: String = _backpack_item_label(entry) + "已收入背包，点背包装备后才会生效"
		return _collection_message(player, pending_backpack_message)
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
	if lineup_locked and action in ["discard", "equip", "discard_pending", "discard_equipped", "equip_pending", "unequip"]:
		var locked_data: Dictionary = _backpack_update_data(peer_id, "阵容已锁定，无法调整")
		NetworkManager.send_message("backpack_updated", locked_data)
		on_backpack_updated(locked_data)
		return
	var message: String = ""
	match action:
		"discard":
			message = discard_backpack_item(player, index)
		"sell":
			message = sell_backpack_item(player, index)
		"equip":
			message = equip_from_backpack(player, index, target_type, target_index)
		"discard_pending":
			message = discard_pending_backpack_item(player)
		"sell_pending":
			message = sell_pending_backpack_item(player)
		"discard_equipped":
			message = discard_equipped_item(player, kind, index)
		"unequip":
			message = unequip_equipped_item(player, kind, index)
		"equip_pending":
			message = equip_pending_item(player, target_type, target_index)
		_:
			message = "未知背包操作"

	var update_data: Dictionary = _backpack_update_data(peer_id, message)
	NetworkManager.send_message("backpack_updated", update_data)
	on_backpack_updated(update_data)
	_auto_save("backpack")


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
		"alchemy":
			message = perform_alchemy(player, str(data.get("grade", "good")))
		"refining":
			message = perform_refining(player, str(data.get("grade", "good")))
		"backpack":
			message = buy_market_backpack(player)
		_:
			message = "未知坊市交易"

	var update_data: Dictionary = _market_update_data(peer_id, message, {
		"action": action,
		"grade": str(data.get("grade", "")),
		"material_name": str(data.get("material_name", "")),
	})
	NetworkManager.send_message("market_updated", update_data)
	on_market_updated(update_data)
	_auto_save("market")
	check_duel_trigger()


func _market_update_data(peer_id: int, message: String, extra_data: Dictionary = {}) -> Dictionary:
	var result: Dictionary = {
		"peer_id": peer_id,
		"message": message,
		"player_a": _player_snapshot(player_a),
		"player_b": _player_snapshot(player_b),
		"pending_backpack_items": pending_backpack_items.duplicate(true),
	}
	for key in extra_data:
		result[key] = extra_data[key]
	return result


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
		action_peer_id = player_a.peer_id if player_a != null and player_a.peer_id > 0 else 1
	auction_choices[str(action_peer_id)] = data.duplicate(true)
	if single_player_mode and player_b != null and action_peer_id != player_b.peer_id and not auction_choices.has(str(player_b.peer_id)):
		_queue_npc_auction_action()

	var total_required: int = _auction_peer_ids().size()
	if auction_choices.size() < total_required:
		return
	_settle_current_auction()


func _settle_current_auction() -> void:
	_ensure_current_auction_lots()
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
			messages[str(peer_id)] = "你在坊市观望了一轮"
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
				messages[str(claim_peer_id)] = "出价落空：" + str(lot.get("name", "货品")) + "被对方买走"
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
		return "坊市交易失败：未找到买家"

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
		return "坊市交易失败：灵石不足，" + str(lot.get("name", "货品")) + "需要 " + str(price)

	var effect_message: String = _apply_auction_lot(player, lot)
	var verb: String = "讲价购得" if mode == "haggle" else "出价购得"
	player.ji_yuan_list.append({
		"desc": "坊市：" + str(lot.get("name", "货品")),
		"quality": str(lot.get("quality", "")),
		"type": "坊市",
		"effect_value": price,
	})
	return verb + "【" + str(lot.get("name", "货品")) + "】，花费 " + str(price) + " 灵石；" + effect_message


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
	var quality: String = str(lot.get("quality", "筑基级"))
	match kind:
		"cultivation":
			var before_stage: String = get_cultivation_stage_name(player)
			var amount: int = int(lot.get("value", MARKET_CULTIVATION_GAIN))
			player.ling_li += amount
			var cultivation_message: String = _append_stage_change_to_message(player, before_stage, "修为 +" + str(amount))
			var sword_message: String = _add_growth_sword_exp(player, maxi(1, int(round(float(amount) / 20.0))), "坊市灵药")
			if sword_message != "":
				cultivation_message += "；" + sword_message
			return cultivation_message
		"heal":
			var max_hp: int = _get_player_max_hp(player)
			var heal_amount: int = maxi(1, int(round(float(max_hp) * MARKET_HEAL_PCT)))
			player.qi_xue = mini(max_hp, player.qi_xue + heal_amount)
			return "气血 +" + str(heal_amount)
		"dan":
			return _grant_breakthrough_dan(player)
		"backpack":
			player.backpack_capacity = get_total_backpack_capacity()
			return "背包上限已固定：功法8 / 法宝4 / 伙伴6 / 材料8"
			if player.backpack_capacity >= MAX_BACKPACK_CAPACITY:
				return "背包已达上限 " + str(MAX_BACKPACK_CAPACITY)
			player.backpack_capacity = mini(MAX_BACKPACK_CAPACITY, player.backpack_capacity + 1)
			var pending_message: String = _try_store_pending_backpack_item(player)
			return "背包容量 +1" if pending_message == "" else "背包容量 +1；" + pending_message
		"technique":
			var technique_data: Dictionary = (lot.get("item_data", {}) as Dictionary).duplicate(true)
			if technique_data.is_empty():
				return _grant_technique_reward(player, quality)
			return _store_equipment_item(player, "technique", technique_data)
		"treasure":
			var treasure_data: Dictionary = (lot.get("item_data", {}) as Dictionary).duplicate(true)
			if treasure_data.is_empty():
				treasure_data = generate_treasure_for_player(player, quality)
			return _store_equipment_item(player, "treasure", treasure_data)
		"companion":
			var companion_data: Dictionary = (lot.get("item_data", {}) as Dictionary).duplicate(true)
			if companion_data.is_empty():
				companion_data = generate_companion_for_player(player, quality)
			else:
				companion_data.erase("bond")
				companion_data.erase("bond_max")
				companion_data.erase("bond_stage")
				companion_data.erase("bond_full_unlocked")
			return _gain_companion_or_ghost(player, companion_data)
		"alchemy_material":
			var herb_data: Dictionary = (lot.get("item_data", {}) as Dictionary).duplicate(true)
			if herb_data.is_empty():
				herb_data = _make_material_item("alchemy", quality)
			return _store_material_data(player, herb_data)
		"craft_material":
			var ore_data: Dictionary = (lot.get("item_data", {}) as Dictionary).duplicate(true)
			if ore_data.is_empty():
				ore_data = _make_material_item("craft", quality)
			return _store_material_data(player, ore_data)
	return "货品无事发生"


func buy_market_cultivation(player: PlayerData) -> String:
	if not _spend_ling_shi(player, MARKET_CULTIVATION_COST):
		return "灵石不足，修为兑换需要 " + str(MARKET_CULTIVATION_COST)
	var before_stage: String = get_cultivation_stage_name(player)
	player.ling_li += MARKET_CULTIVATION_GAIN
	var message: String = _append_stage_change_to_message(player, before_stage, "坊市吐纳丹：修为 +" + str(MARKET_CULTIVATION_GAIN))
	var sword_message: String = _add_growth_sword_exp(player, maxi(1, int(round(float(MARKET_CULTIVATION_GAIN) / 20.0))), "坊市吐纳")
	if sword_message != "":
		message += "；" + sword_message
	return message


func buy_market_heal(player: PlayerData) -> String:
	if not _spend_ling_shi(player, MARKET_HEAL_COST):
		return "灵石不足，疗伤需要 " + str(MARKET_HEAL_COST)
	var max_hp: int = _get_player_max_hp(player)
	var heal_amount: int = maxi(1, int(round(float(max_hp) * MARKET_HEAL_PCT)))
	var old_hp: int = player.qi_xue
	player.qi_xue = mini(max_hp, player.qi_xue + heal_amount)
	var message: String = "坊市疗伤：气血 +" + str(heal_amount)
	if player.qi_xue > old_hp:
		var growth_message: String = _grow_treasure_for_cultivation(player, "丹修", 1)
		if growth_message != "":
			message += "；" + growth_message
		var technique_message: String = _grow_techniques_for_cultivation(player, "丹修", 1, "疗伤运功")
		if technique_message != "":
			message += "；" + technique_message
	return message


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
	var technique_message: String = _grow_techniques_for_cultivation(player, "丹修", 1, "购丹辨火")
	return "坊市购得" + dan_name if technique_message == "" else "坊市购得" + dan_name + "；" + technique_message


func get_alchemy_status(player: PlayerData) -> Dictionary:
	var status: Dictionary = {
		"can": false,
		"cost": 0,
		"label": "炼丹",
		"dan_name": "",
		"material_name": "",
		"material_count": 0,
		"stat_score": _craft_stat_score(player, "alchemy"),
		"stat_text": _craft_stat_text("alchemy"),
		"reason": "",
	}
	if player == null:
		status["reason"] = "未找到修士"
		return status
	if _is_alchemy_blocked():
		status["reason"] = "此时不能开炉"
		return status
	var material: Dictionary = _peek_material(player, "alchemy")
	status["material_count"] = _material_count(player, "alchemy")
	if material.is_empty():
		status["reason"] = "缺少灵草"
		return status
	status["material_name"] = str(material.get("name", "灵草"))

	var dan_name: String = _next_required_dan_name(player)
	if dan_name != "" and not has_dan(player, dan_name):
		status["label"] = "炼" + dan_name
		status["dan_name"] = dan_name
	else:
		status["label"] = "炼回春丹"
	status["can"] = true
	return status


func get_refining_status(player: PlayerData) -> Dictionary:
	var status: Dictionary = {
		"can": false,
		"cost": 0,
		"label": "炼器",
		"material_name": "",
		"material_count": 0,
		"stat_score": _craft_stat_score(player, "refining"),
		"stat_text": _craft_stat_text("refining"),
		"reason": "",
	}
	if player == null:
		status["reason"] = "未找到修士"
		return status
	if _is_alchemy_blocked():
		status["reason"] = "此时不能开炉"
		return status
	var material: Dictionary = _peek_material(player, "craft")
	status["material_count"] = _material_count(player, "craft")
	if material.is_empty():
		status["reason"] = "缺少矿材"
		return status
	status["material_name"] = str(material.get("name", "矿材"))
	var treasure: Dictionary = _get_equipped_treasure(player)
	if treasure.is_empty():
		status["reason"] = "先装备法宝"
		return status
	status["label"] = "炼器"
	status["can"] = true
	return status


func perform_alchemy(player: PlayerData, craft_grade: String = "good") -> String:
	var status: Dictionary = get_alchemy_status(player)
	if not bool(status.get("can", false)):
		var reason: String = str(status.get("reason", "暂时不能炼丹"))
		return reason + "，先去抽灵草"
	var material: Dictionary = _consume_material(player, "alchemy")
	if material.is_empty():
		return "缺少灵草，无法开炉"

	var grade: String = _normalize_craft_grade(craft_grade)
	var quality: String = str(material.get("quality", "炼气级"))
	var craft_quality: Dictionary = _craft_result_quality(player, "alchemy", quality, grade)
	var result_quality: String = str(craft_quality.get("quality", quality))
	var power: float = _quality_power(result_quality)
	var messages: Array[String] = [_craft_grade_text(grade) + "，耗去" + str(material.get("name", "灵草")) + "；" + _craft_quality_message(craft_quality)]
	var dan_name: String = str(status.get("dan_name", ""))
	if grade == "miss":
		var before_miss_stage: String = get_cultivation_stage_name(player)
		var miss_gain: int = maxi(6, int(round(8.0 * power)))
		player.ling_li += miss_gain
		messages.append(_append_stage_change_to_message(player, before_miss_stage, "丹火走偏，残丹化修为 +" + str(miss_gain)))
	elif dan_name != "":
		var dans: Array = player.final_attributes.get("dans", []) as Array
		if not dans.has(dan_name):
			dans.append(dan_name)
		player.final_attributes["dans"] = dans
		messages.append(result_quality + "·" + dan_name + "成丹")
		var dan_ling_gain: int = maxi(4, int(round((6.0 if grade == "good" else 12.0) * power)))
		var before_dan_stage: String = get_cultivation_stage_name(player)
		player.ling_li += dan_ling_gain
		messages.append(_append_stage_change_to_message(player, before_dan_stage, "丹香入脉，修为 +" + str(dan_ling_gain)))
	else:
		var max_hp: int = _get_player_max_hp(player)
		var old_hp: int = player.qi_xue
		var grade_rate: float = 1.45 if grade == "perfect" else 1.0
		var heal_amount: int = maxi(1, int(round(float(max_hp) * ALCHEMY_HEAL_PCT * grade_rate)))
		player.qi_xue = mini(max_hp, player.qi_xue + heal_amount)
		var before_stage: String = get_cultivation_stage_name(player)
		var ling_li_gain: int = maxi(1, int(round(float(ALCHEMY_LING_LI_GAIN) * power * grade_rate)))
		player.ling_li += ling_li_gain
		var healed: int = player.qi_xue - old_hp
		var hp_text: String = "气血 +" + str(healed) if healed > 0 else "气血已满"
		var recover_text: String = "回春丹成，" + hp_text + "，修为 +" + str(ling_li_gain)
		messages.append(_append_stage_change_to_message(player, before_stage, recover_text))

	var quality_bonus: int = maxi(0, _quality_rank(result_quality) - _quality_rank(quality))
	var treasure_growth: int = (1 if grade == "miss" else (5 if grade == "perfect" else 3)) + quality_bonus
	var technique_growth: int = (1 if grade != "perfect" else 2) + (1 if quality_bonus >= 2 else 0)
	var treasure_message: String = _grow_treasure_for_cultivation(player, "丹修", treasure_growth)
	if treasure_message != "":
		messages.append(treasure_message)
	var technique_message: String = _grow_techniques_for_cultivation(player, "丹修", technique_growth, "开炉炼丹")
	if technique_message != "":
		messages.append(technique_message)
	return "；".join(messages)


func perform_refining(player: PlayerData, craft_grade: String = "good") -> String:
	var status: Dictionary = get_refining_status(player)
	if not bool(status.get("can", false)):
		return str(status.get("reason", "暂时不能炼器")) + "，先备矿材和法宝"
	var material: Dictionary = _consume_material(player, "craft")
	if material.is_empty():
		return "缺少矿材，无法炼器"
	var grade: String = _normalize_craft_grade(craft_grade)
	var quality: String = str(material.get("quality", "炼气级"))
	var craft_quality: Dictionary = _craft_result_quality(player, "refining", quality, grade)
	var result_quality: String = str(craft_quality.get("quality", quality))
	var power: int = maxi(1, int(round(_quality_power(result_quality))))
	var growth_amount: int = 1
	if grade == "good":
		growth_amount = 3 + int(floor(float(power) * 0.5))
	elif grade == "perfect":
		growth_amount = 5 + power
	var quality_bonus: int = maxi(0, _quality_rank(result_quality) - _quality_rank(quality))
	growth_amount += quality_bonus
	var messages: Array[String] = [_craft_grade_text(grade) + "，耗去" + str(material.get("name", "矿材")) + "；" + _craft_quality_message(craft_quality)]
	var treasure_message: String = grow_treasure(player, growth_amount)
	if treasure_message != "":
		messages.append(treasure_message)
	var technique_growth: int = (1 if grade != "perfect" else 2) + (1 if quality_bonus >= 2 else 0)
	var technique_message: String = _grow_techniques_for_cultivation(player, "器修", technique_growth, "开炉炼器")
	if technique_message != "":
		messages.append(technique_message)
	return "；".join(messages)


func _material_count(player: PlayerData, material_type: String) -> int:
	if player == null:
		return 0
	var count: int = 0
	for entry in player.backpack:
		if not entry is Dictionary:
			continue
		var entry_data: Dictionary = entry as Dictionary
		if str(entry_data.get("kind", "")) != "material":
			continue
		var data: Dictionary = entry_data.get("data", {}) as Dictionary
		if str(data.get("material_type", "")) == material_type:
			count += 1
	return count


func _peek_material(player: PlayerData, material_type: String) -> Dictionary:
	var index: int = _find_material_index(player, material_type)
	if index < 0:
		return {}
	var entry: Dictionary = player.backpack[index] as Dictionary
	return (entry.get("data", {}) as Dictionary).duplicate(true)


func _consume_material(player: PlayerData, material_type: String) -> Dictionary:
	var index: int = _find_material_index(player, material_type)
	if index < 0:
		return {}
	var entry: Dictionary = player.backpack[index] as Dictionary
	player.backpack.remove_at(index)
	return (entry.get("data", {}) as Dictionary).duplicate(true)


func _find_material_index(player: PlayerData, material_type: String) -> int:
	if player == null:
		return -1
	var best_index: int = -1
	var best_rank: int = 999
	for i in range(player.backpack.size()):
		var entry_value: Variant = player.backpack[i]
		if not entry_value is Dictionary:
			continue
		var entry: Dictionary = entry_value as Dictionary
		if str(entry.get("kind", "")) != "material":
			continue
		var data: Dictionary = entry.get("data", {}) as Dictionary
		if str(data.get("material_type", "")) != material_type:
			continue
		var rank: int = _quality_rank(str(data.get("quality", "炼气级")))
		if rank < best_rank:
			best_rank = rank
			best_index = i
	return best_index


func _craft_related_stats(craft_mode: String) -> Array:
	return REFINING_RELATED_STATS if craft_mode == "refining" else ALCHEMY_RELATED_STATS


func _craft_stat_score(player: PlayerData, craft_mode: String) -> int:
	if player == null:
		return 0
	var total: int = 0
	for stat_name in _craft_related_stats(craft_mode):
		total += int(player.stats.get(str(stat_name), 0))
	return total


func _craft_stat_text(craft_mode: String) -> String:
	var names: Array[String] = []
	for stat_name in _craft_related_stats(craft_mode):
		names.append(str(stat_name))
	return "+".join(names)


func _craft_result_quality(player: PlayerData, craft_mode: String, material_quality: String, craft_grade: String) -> Dictionary:
	var grade: String = _normalize_craft_grade(craft_grade)
	var stat_score: int = _craft_stat_score(player, craft_mode)
	var start_rank: int = _quality_rank(material_quality)
	var rank: int = start_rank
	match grade:
		"miss":
			rank -= 1
		"perfect":
			rank += 1
		_:
			rank += 0
	var stat_upgrade_chance: float = _craft_stat_upgrade_chance(stat_score, grade)
	var stat_upgraded: bool = rng.randf() < stat_upgrade_chance
	if stat_upgraded:
		rank += 1
	rank = clampi(rank, 0, QUALITY_ORDER.size() - 1)
	return {
		"quality": _quality_by_rank(rank),
		"material_quality": material_quality,
		"grade": grade,
		"stat_score": stat_score,
		"stat_text": _craft_stat_text(craft_mode),
		"stat_upgrade_chance": stat_upgrade_chance,
		"stat_upgraded": stat_upgraded,
	}


func _craft_stat_upgrade_chance(stat_score: int, craft_grade: String) -> float:
	var score_bonus: float = float(maxi(0, stat_score)) * 0.025
	match craft_grade:
		"perfect":
			return clampf(0.20 + score_bonus, 0.0, 0.78)
		"miss":
			return clampf(float(maxi(0, stat_score)) * 0.012, 0.0, 0.22)
		_:
			return clampf(0.04 + score_bonus, 0.0, 0.55)


func _craft_quality_message(craft_quality: Dictionary) -> String:
	var quality: String = str(craft_quality.get("quality", "炼气级"))
	var stat_text: String = str(craft_quality.get("stat_text", "六维"))
	var stat_score: int = int(craft_quality.get("stat_score", 0))
	var upgraded_text: String = "，六维提品" if bool(craft_quality.get("stat_upgraded", false)) else ""
	return "成色：" + quality + "（" + stat_text + "=" + str(stat_score) + upgraded_text + "）"


func _normalize_craft_grade(craft_grade: String) -> String:
	if craft_grade == "perfect" or craft_grade == "miss":
		return craft_grade
	return "good"


func _craft_grade_text(craft_grade: String) -> String:
	match craft_grade:
		"perfect":
			return "炉火正妙"
		"miss":
			return "炉火失衡"
		_:
			return "火候已成"


func _is_alchemy_blocked() -> bool:
	return current_state == GameState.STAT_ALLOCATION or current_state == GameState.CONTEST or current_state == GameState.AUCTION or current_state == GameState.BATTLE or current_state == GameState.BREAKTHROUGH or current_state == GameState.TRIBULATION or current_state == GameState.DUEL or current_state == GameState.SECT_EVENT or current_state == GameState.ENDING


func buy_market_backpack(player: PlayerData) -> String:
	if player != null:
		player.backpack_capacity = get_total_backpack_capacity()
	return "背包上限已固定：功法8 / 法宝4 / 伙伴6 / 材料8"
	if player.backpack_capacity >= MAX_BACKPACK_CAPACITY:
		return "背包已达上限 " + str(MAX_BACKPACK_CAPACITY)
	if not _spend_ling_shi(player, MARKET_BACKPACK_COST):
		return "灵石不足，扩充背包需要 " + str(MARKET_BACKPACK_COST)
	player.backpack_capacity = mini(MAX_BACKPACK_CAPACITY, player.backpack_capacity + 1)
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
	_add_to_scattered_pool(entry, player.peer_id, "discard_backpack")
	player.backpack.remove_at(index)
	var pending_message: String = _try_store_pending_backpack_item(player)
	if pending_message != "":
		return _collection_message(player, "丢弃" + label + "；" + pending_message)
	return _collection_message(player, "丢弃" + label)


func sell_backpack_item(player: PlayerData, index: int) -> String:
	if index < 0 or index >= player.backpack.size():
		return "未选择背包物品"
	var entry: Dictionary = player.backpack[index] as Dictionary
	var label: String = _backpack_item_label(entry)
	var value: int = _sell_value_for_entry(player, entry)
	player.backpack.remove_at(index)
	player.ling_shi += value
	var pending_message: String = _try_store_pending_backpack_item(player)
	var message: String = "倒卖" + label + "，灵石 +" + str(value)
	if pending_message != "":
		message += "；" + pending_message
	return _collection_message(player, message)


func discard_pending_backpack_item(player: PlayerData) -> String:
	var key: String = str(player.peer_id)
	if not pending_backpack_items.has(key):
		return "没有待处理物品"
	var entry: Dictionary = pending_backpack_items[key] as Dictionary
	_add_to_scattered_pool(entry, player.peer_id, "discard_pending")
	pending_backpack_items.erase(key)
	return _collection_message(player, "放弃" + _backpack_item_label(entry))


func sell_pending_backpack_item(player: PlayerData) -> String:
	var key: String = str(player.peer_id)
	if not pending_backpack_items.has(key):
		return "没有待处理物品"
	var entry: Dictionary = pending_backpack_items[key] as Dictionary
	var label: String = _backpack_item_label(entry)
	var value: int = _sell_value_for_entry(player, entry)
	pending_backpack_items.erase(key)
	player.ling_shi += value
	return _collection_message(player, "倒卖" + label + "，灵石 +" + str(value))


func get_market_sell_value_for_entry(player: PlayerData, entry: Dictionary) -> int:
	return _sell_value_for_entry(player, entry)


func _sell_value_for_entry(player: PlayerData, entry: Dictionary) -> int:
	var kind: String = str(entry.get("kind", ""))
	var data: Dictionary = entry.get("data", {}) as Dictionary
	var quality: String = str(data.get("quality", "筑基级"))
	var market_kind: String = _market_kind_for_entry_kind(kind, data)
	var base_value: int = maxi(1, int(round(float(_market_base_price(market_kind)) * 0.48)))
	var multiplier: float = float(QUALITY_MULTIPLIER.get(quality, 1.0))
	var business_bonus: float = 1.0 + float(player.stats.get("经商", 0)) * 0.08 if player != null else 1.0
	return maxi(1, int(round(float(base_value) * multiplier * business_bonus)))


func discard_equipped_item(player: PlayerData, kind: String, index: int) -> String:
	var label: String = ""
	match kind:
		"technique":
			if index < 0 or index >= player.techniques.size():
				return "未选择已装备功法"
			var technique: Dictionary = player.techniques[index] as Dictionary
			_add_to_scattered_pool(_make_backpack_entry("technique", technique), player.peer_id, "discard_equipped")
			label = "功法 · " + str(technique.get("name", "未知"))
			player.techniques.remove_at(index)
		"treasure":
			if player.treasures.is_empty():
				return "未选择已装备法宝"
			var treasure: Dictionary = player.treasures[0] as Dictionary
			_add_to_scattered_pool(_make_backpack_entry("treasure", treasure), player.peer_id, "discard_equipped")
			label = "法宝 · " + str(treasure.get("name", "未知"))
			player.treasures.remove_at(0)
		"companion":
			if index < 0 or index >= player.companions.size():
				return "未选择同行同伴"
			var companion: Dictionary = player.companions[index] as Dictionary
			_remove_companion_bonus(player, companion)
			_add_to_scattered_pool(_make_backpack_entry("companion", companion), player.peer_id, "discard_equipped")
			label = "同伴 · " + str(companion.get("name", "未知"))
			player.companions.remove_at(index)
		_:
			return "不能丢弃此物品"
	var pending_message: String = _try_store_pending_backpack_item(player)
	if pending_message != "":
		return _collection_message(player, "丢弃" + label + "；" + pending_message)
	return _collection_message(player, "丢弃" + label)


func unequip_equipped_item(player: PlayerData, kind: String, index: int) -> String:
	if player == null:
		return "未找到玩家"
	if lineup_locked:
		return "阵容已锁定，无法调整"
	if not can_store_backpack_kind(player, kind):
		return _item_kind_name(kind) + "背包已满，请先丢弃同类组件"
	var item_data: Dictionary = {}
	match kind:
		"technique":
			if index < 0 or index >= player.techniques.size():
				return "未选择已装备功法"
			item_data = player.techniques[index] as Dictionary
			player.techniques.remove_at(index)
		"treasure":
			if player.treasures.is_empty():
				return "未选择已装备法宝"
			item_data = player.treasures[0] as Dictionary
			player.treasures.remove_at(0)
		"companion":
			if index < 0 or index >= player.companions.size():
				return "未选择上场伙伴"
			item_data = player.companions[index] as Dictionary
			_remove_companion_bonus(player, item_data)
			player.companions.remove_at(index)
			apply_companion_bonus(player)
		_:
			return "不能移回背包"
	var entry: Dictionary = _make_backpack_entry(kind, item_data)
	player.backpack.append(entry)
	player.backpack_capacity = get_total_backpack_capacity()
	var pending_message: String = _try_store_pending_backpack_item(player)
	var message: String = _backpack_item_label(entry) + "已移回背包"
	if pending_message != "":
		message += "；" + pending_message
	return _collection_message(player, message)


func equip_from_backpack(player: PlayerData, index: int, target_kind: String = "", target_index: int = -1) -> String:
	if index < 0 or index >= player.backpack.size():
		return "未选择背包物品"
	var entry: Dictionary = player.backpack[index] as Dictionary
	var kind: String = str(entry.get("kind", ""))
	var item_data: Dictionary = entry.get("data", {}) as Dictionary
	match kind:
		"technique":
			item_data = _prepare_technique(item_data)
			entry["data"] = item_data
		"treasure":
			item_data = _prepare_treasure(item_data, _player_sect(player))
			_apply_player_treasure_growth_cap(player, item_data)
			entry["data"] = item_data
		"companion":
			_prepare_companion(item_data, player)
			entry["data"] = item_data
	if target_kind != "" and target_kind != kind:
		return _backpack_item_label(entry) + "不能放入" + _item_kind_name(target_kind) + "槽"

	if kind == "technique":
		if target_index >= 0 and target_index < player.techniques.size():
			var old_technique: Dictionary = player.techniques[target_index] as Dictionary
			player.techniques[target_index] = item_data
			player.backpack[index] = _make_backpack_entry("technique", old_technique)
			var replace_message: String = _backpack_item_label(entry) + "已替换功法《" + str(old_technique.get("name", "未知")) + "》"
			return _collection_message(player, replace_message)
		if player.techniques.size() >= MAX_EQUIPPED_TECHNIQUES:
			return "功法已装备 " + str(MAX_EQUIPPED_TECHNIQUES) + " 本，请拖到已有功法上替换"
		player.backpack.remove_at(index)
		player.techniques.append(item_data)
	elif kind == "treasure":
		if player.treasures.size() > 0:
			var old_treasure: Dictionary = player.treasures[0] as Dictionary
			player.treasures[0] = item_data
			player.backpack[index] = _make_backpack_entry("treasure", old_treasure)
			return _collection_message(player, _backpack_item_label(entry) + "已替换法宝【" + str(old_treasure.get("name", "未知")) + "】")
		player.backpack.remove_at(index)
		player.treasures.append(item_data)
	elif kind == "companion":
		if target_index >= 0 and target_index < player.companions.size():
			var old_companion: Dictionary = player.companions[target_index] as Dictionary
			_remove_companion_bonus(player, old_companion)
			player.companions[target_index] = item_data
			player.backpack[index] = _make_backpack_entry("companion", old_companion)
			apply_companion_bonus(player)
			return _collection_message(player, _backpack_item_label(entry) + "已替换同伴「" + str(old_companion.get("name", "未知")) + "」")
		if player.companions.size() >= MAX_COMPANIONS:
			return "同伴区已满，请拖到已有同伴上替换"
		player.backpack.remove_at(index)
		player.companions.append(item_data)
		apply_companion_bonus(player)
	else:
		return "此物品暂不能装备"

	var pending_message: String = _try_store_pending_backpack_item(player)
	if pending_message != "":
		return _collection_message(player, _backpack_item_label(entry) + "已装备；" + pending_message)
	var equip_message: String = _backpack_item_label(entry) + "已装备"
	return _collection_message(player, equip_message)


func equip_pending_item(player: PlayerData, target_kind: String, target_index: int) -> String:
	var key: String = str(player.peer_id)
	if not pending_backpack_items.has(key):
		return "没有待处理物品"

	var entry: Dictionary = pending_backpack_items[key] as Dictionary
	var kind: String = str(entry.get("kind", ""))
	var item_data: Dictionary = entry.get("data", {}) as Dictionary
	match kind:
		"technique":
			item_data = _prepare_technique(item_data)
			entry["data"] = item_data
		"treasure":
			item_data = _prepare_treasure(item_data, _player_sect(player))
			_apply_player_treasure_growth_cap(player, item_data)
			entry["data"] = item_data
		"companion":
			_prepare_companion(item_data, player)
			entry["data"] = item_data
	if target_kind != kind:
		return _backpack_item_label(entry) + "不能放入" + _item_kind_name(target_kind) + "槽"

	var replaced_label: String = ""
	match kind:
		"technique":
			if target_index >= 0 and target_index < player.techniques.size():
				var old_technique: Dictionary = player.techniques[target_index] as Dictionary
				_add_to_scattered_pool(_make_backpack_entry("technique", old_technique), player.peer_id, "replace_pending")
				replaced_label = "，替换并丢弃功法《" + str(old_technique.get("name", "未知")) + "》"
				player.techniques[target_index] = item_data
			elif player.techniques.size() < MAX_EQUIPPED_TECHNIQUES:
				player.techniques.append(item_data)
			else:
				return "功法已满，请拖到已有功法上替换"
		"treasure":
			if player.treasures.size() > 0:
				var old_treasure: Dictionary = player.treasures[0] as Dictionary
				_add_to_scattered_pool(_make_backpack_entry("treasure", old_treasure), player.peer_id, "replace_pending")
				replaced_label = "，替换并丢弃法宝【" + str(old_treasure.get("name", "未知")) + "】"
				player.treasures[0] = item_data
			else:
				player.treasures.append(item_data)
		"companion":
			if target_index >= 0 and target_index < player.companions.size():
				var old_companion: Dictionary = player.companions[target_index] as Dictionary
				_remove_companion_bonus(player, old_companion)
				_add_to_scattered_pool(_make_backpack_entry("companion", old_companion), player.peer_id, "replace_pending")
				replaced_label = "，替换并请离同伴「" + str(old_companion.get("name", "未知")) + "」"
				player.companions[target_index] = item_data
				apply_companion_bonus(player)
			elif player.companions.size() < MAX_COMPANIONS:
				player.companions.append(item_data)
				apply_companion_bonus(player)
			else:
				return "同伴区已满，请拖到已有同伴上替换"
		_:
			return "此物品暂不能装备"

	pending_backpack_items.erase(key)
	var pending_equip_message: String = _backpack_item_label(entry) + "已装备" + replaced_label
	return _collection_message(player, pending_equip_message)


func use_treasure(player: PlayerData, treasure_name: String) -> String:
	for treasure in player.treasures:
		if not treasure is Dictionary:
			continue
		if str(treasure.get("name", "")) != treasure_name:
			continue
		_prepare_treasure(treasure as Dictionary, _player_sect(player))
		return treasure_name + "已上场，抢攻时会自动催动：" + str((treasure as Dictionary).get("use_effect", "法宝自动攻击"))
	return "未找到法宝：" + treasure_name


func refine_treasure(player: PlayerData, treasure_name: String) -> String:
	for treasure in player.treasures:
		if not treasure is Dictionary:
			continue
		if str(treasure.get("name", "")) != treasure_name:
			continue
		_prepare_treasure(treasure as Dictionary, _player_sect(player))
		return "炼化系统已取消，【" + treasure_name + "】会作为常驻法宝在抢攻时自动攻击"
	return "未找到法宝：" + treasure_name


func generate_desc(data: Dictionary, is_calamity: bool = false) -> String:
	var quality: String = str(data.get("quality", ""))
	var quality_text: String = quality_display_name(quality)
	var type_name: String = str(data.get("type", ""))
	var value: float = float(data.get("effect_value", data.get("value", 0)))
	var effect_type: String = str(data.get("effect_type", ""))

	if is_calamity:
		match effect_type:
			"ling_li_loss":
				return type_name + "：灵力 -" + str(int(value))
			"hp_percent_loss", "hp_damage":
				return type_name + "：气血 -" + str(int(value))
			"enemy":
				return type_name + "：进入战斗"
			"shou_yuan_loss":
				return type_name + "：寿元 -" + str(int(value))
			"tribulation":
				return type_name + "：天劫暗涌"
			_:
				return type_name

	match effect_type:
		"ling_li":
			return type_name + "：灵力 +" + str(int(value))
		"heal_percent":
			return type_name + "：气血回复 " + str(int(value)) + "%"
		"ling_shi":
			return type_name + "：灵石 +" + str(int(value))
		"auction":
			return "坊市：灵石 +" + str(int(value)) + "，可买功法/法宝/伙伴/材料"
		"quest":
			var quest: Dictionary = data.get("quest", {}) as Dictionary
			return "悬赏令：" + str(quest.get("name", "未知任务")) + "，" + str(quest.get("desc", "待完成"))
		"alchemy_material":
			return quality_text + " · 灵草：收入背包，可用于炼丹"
		"craft_material":
			return quality_text + " · 矿材：收入背包，可用于炼器"
		"adventure":
			return "秘境探索：可能获得修为、灵石、功法或法宝"
		"body_tempering":
			return "炼体熔炉：淬炼筋骨"
		"sword_tempering":
			return "剑冢悟剑：滋养本命飞剑"
		"ghost_altar":
			return "招魂坛：养鬼或摄魂"
		"technique", "treasure":
			return quality_text + " · " + type_name + "：获得" + type_name
		"dan", "companion":
			return type_name + "：获得" + type_name
		"stat_up":
			return type_name + "：" + str(data.get("stat", "属性")) + " +" + str(int(value))
		"shou_yuan":
			return "偶得延寿丹：寿元 +" + str(int(value))
		_:
			return type_name


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


func _calamity_quality_probs_for_current_realm() -> Dictionary:
	var realm_rank: int = _highest_player_realm_rank()
	match clampi(realm_rank, 0, 3):
		0:
			return {"炼气级": 0.62, "筑基级": 0.30, "金丹级": 0.08, "元婴级": 0.0, "化神级": 0.0, "合体级": 0.0}
		1:
			return {"炼气级": 0.25, "筑基级": 0.38, "金丹级": 0.25, "元婴级": 0.10, "化神级": 0.02, "合体级": 0.0}
		2:
			return {"炼气级": 0.08, "筑基级": 0.20, "金丹级": 0.36, "元婴级": 0.24, "化神级": 0.10, "合体级": 0.02}
		_:
			return {"炼气级": 0.04, "筑基级": 0.10, "金丹级": 0.22, "元婴级": 0.34, "化神级": 0.22, "合体级": 0.08}


func _highest_player_realm_rank() -> int:
	var rank_a: int = _realm_rank(player_a.realm) if player_a != null else 0
	var rank_b: int = _realm_rank(player_b.realm) if player_b != null else 0
	return maxi(rank_a, rank_b)


func _average_player_realm_rank() -> int:
	var total_rank: int = 0
	var player_count: int = 0
	if player_a != null:
		total_rank += _realm_rank(player_a.realm)
		player_count += 1
	if player_b != null:
		total_rank += _realm_rank(player_b.realm)
		player_count += 1
	if player_count <= 0:
		return 0
	return clampi(int(round(float(total_rank) / float(player_count))), 0, 3)


func _realm_combat_power_bonus(realm_name: String) -> int:
	var rank: int = clampi(_realm_rank(realm_name), 0, REALM_COMBAT_POWER_BONUS.size() - 1)
	return int(REALM_COMBAT_POWER_BONUS[rank])


func _realm_rank(realm_name: String) -> int:
	match realm_name:
		"炼气期":
			return 0
		"筑基期":
			return 1
		"金丹期":
			return 2
		"元婴期":
			return 3
		_:
			return 0


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


func _apply_ji_yuan(player: PlayerData, ji_yuan: Dictionary, ji_yuan_value: float, choice: String = "") -> String:
	var value: float = ji_yuan_value
	var message: String = ""
	match str(ji_yuan.get("effect_type", "")):
		"ling_li":
			var before_stage: String = get_cultivation_stage_name(player)
			var qi_gan_bonus: float = 1.0 + float(player.stats.get("气感", 0)) * 0.05 + _sum_player_bonus(player, "灵力获取")
			var amount: int = int(round(value * qi_gan_bonus))
			player.ling_li += amount
			message = "灵力 +" + str(amount)
			message = _append_stage_change_to_message(player, before_stage, message)
			var sword_message: String = _add_growth_sword_exp(player, maxi(1, int(round(float(amount) / 20.0))), "修行")
			if sword_message != "":
				message += "；" + sword_message
		"heal_percent":
			var max_hp: int = _get_player_max_hp(player)
			var heal_amount: int = int(round(max_hp * value / 100.0))
			var old_hp: int = player.qi_xue
			player.qi_xue = min(max_hp, player.qi_xue + heal_amount)
			message = "气血 +" + str(heal_amount)
			if player.qi_xue > old_hp:
				var heal_growth_message: String = _grow_treasure_for_cultivation(player, "丹修", 1)
				if heal_growth_message != "":
					message += "；" + heal_growth_message
				var heal_technique_message: String = _grow_techniques_for_cultivation(player, "丹修", 1, "回春运功")
				if heal_technique_message != "":
					message += "；" + heal_technique_message
			var heal_task_message: String = _complete_active_tasks(player, "heal_gain", {"max_hp": max_hp})
			if heal_task_message != "":
				message += "；" + heal_task_message
		"ling_shi":
			var stone_amount: int = int(round(value))
			player.ling_shi += stone_amount
			message = "灵石 +" + str(stone_amount)
		"technique":
			var technique_data: Dictionary = (ji_yuan.get("technique", {}) as Dictionary).duplicate(true)
			if technique_data.is_empty():
				message = _grant_technique_reward(player, str(ji_yuan.get("quality", "筑基级")))
			else:
				message = _store_equipment_item(player, "technique", technique_data)
			value = 1.0
		"treasure":
			var treasure: Dictionary = (ji_yuan.get("treasure", {}) as Dictionary).duplicate(true)
			if treasure.is_empty():
				treasure = generate_treasure_for_player(player, str(ji_yuan.get("quality", "")))
			message = _store_equipment_item(player, "treasure", treasure)
			value = 1.0
		"alchemy_material":
			message = _store_material_item(player, "alchemy", str(ji_yuan.get("quality", "炼气级")))
			value = 1.0
		"craft_material":
			message = _store_material_item(player, "craft", str(ji_yuan.get("quality", "炼气级")))
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
				var dan_sword_message: String = _add_growth_sword_exp(player, maxi(1, int(round(float(dan_li) / 25.0))), "丹力")
				if dan_sword_message != "":
					message += "；" + dan_sword_message
			var dan_growth_message: String = _grow_treasure_for_cultivation(player, "丹修", 3)
			if dan_growth_message != "":
				message += "；" + dan_growth_message
			var dan_technique_message: String = _grow_techniques_for_cultivation(player, "丹修", 1, "丹气入经")
			if dan_technique_message != "":
				message += "；" + dan_technique_message
			value = 1.0
		"stat_up":
			var stat: String = str(BASE_STATS[rng.randi_range(0, BASE_STATS.size() - 1)])
			player.stats[stat] = int(player.stats.get(stat, 0)) + 1
			value = 1.0
			message = stat + " +1"
		"shou_yuan":
			var years: int = maxi(1, int(round(value)))
			player.shou_yuan += years
			message = "寿元 +" + str(years)
		"companion":
			var companion: Dictionary = ji_yuan.get("companion", {}) as Dictionary
			if companion.is_empty():
				companion = generate_companion_for_player(player)
			companion = companion.duplicate(true)
			if value < 1.0:
				companion["bonus_value"] = float(companion.get("bonus_value", 0.0)) * value
				companion["effect_desc"] = str(companion.get("effect_desc", "")) + "（半效果）"
			message = _gain_companion_or_ghost(player, companion, value)
			value = 1.0
		"quest":
			if value < 0.75:
				message = "悬赏令无人接下"
			else:
				message = _grant_bounty_task(player, ji_yuan)
			value = 1.0
		"adventure":
			message = _apply_adventure_reward(player, str(ji_yuan.get("quality", "筑基级")), value)
			value = 1.0
		"body_tempering":
			message = _apply_body_tempering(player, str(ji_yuan.get("quality", "筑基级")), value)
			value = 1.0
		"sword_tempering":
			if choice != "抢":
				message = "你收剑退让，剑气未涨"
				value = 1.0
				player.total_ji_yuan_gained += int(round(value))
				player.ji_yuan_list.append(ji_yuan.duplicate(true))
				return message
			message = _apply_sword_tempering(player, str(ji_yuan.get("quality", "筑基级")), value)
			value = 1.0
		"ghost_altar":
			message = _apply_ghost_altar(player, str(ji_yuan.get("quality", "筑基级")), value)
			value = 1.0
	player.total_ji_yuan_gained += int(round(value))
	player.ji_yuan_list.append(ji_yuan.duplicate(true))
	return message


func _apply_body_tempering(player: PlayerData, quality: String, scale: float) -> String:
	var power: float = _quality_power(quality) * clampf(scale, 0.35, 1.5)
	var hp_bonus: float = 0.025 * power
	var defense_bonus: float = 0.018 * power
	player.refined_bonuses["气血上限"] = float(player.refined_bonuses.get("气血上限", 0.0)) + hp_bonus
	player.refined_bonuses["防御力"] = float(player.refined_bonuses.get("防御力", 0.0)) + defense_bonus
	var max_hp: int = _get_player_max_hp(player)
	var heal_amount: int = maxi(1, int(round(5.0 * power)))
	player.qi_xue = mini(max_hp, player.qi_xue + heal_amount)
	var message: String = "炼体熔炉淬骨，气血上限+" + str(int(round(hp_bonus * 100.0))) + "%，防御+" + str(int(round(defense_bonus * 100.0))) + "%"
	var grow_message: String = grow_treasure(player, maxi(1, int(round(4.0 * power))))
	if grow_message != "":
		message += "；" + grow_message
	var technique_message: String = _grow_techniques_for_cultivation(player, "体修", 1, "淬骨炼体")
	if technique_message != "":
		message += "；" + technique_message
	return message


func _apply_sword_tempering(player: PlayerData, quality: String, scale: float) -> String:
	var ensure_message: String = _ensure_growth_sword(player)
	var power: float = _quality_power(quality) * clampf(scale, 0.35, 1.5)
	var exp_gain: int = maxi(12, int(round(38.0 * power)))
	var grow_message: String = _add_growth_sword_exp(player, exp_gain, "剑冢悟剑")
	var treasure_message: String = grow_treasure(player, maxi(1, int(round(power * 3.0))))
	var messages: Array[String] = []
	if ensure_message != "":
		messages.append(ensure_message)
	if grow_message != "":
		messages.append(grow_message)
	else:
		messages.append("剑冢悟剑 +" + str(exp_gain))
	if treasure_message != "":
		messages.append(treasure_message)
	var technique_message: String = _grow_techniques_for_cultivation(player, "剑修", 1, "剑冢悟剑")
	if technique_message != "":
		messages.append(technique_message)
	return "；".join(messages)


func _apply_ghost_altar(player: PlayerData, quality: String, scale: float) -> String:
	var reward_scale: float = clampf(scale, 0.35, 1.5)
	var ghost_power: int = maxi(4, int(round(_quality_power(quality) * 10.0 * reward_scale)))
	player.final_attributes["ghost_power"] = int(player.final_attributes.get("ghost_power", 0)) + ghost_power
	player.final_attributes["ghost_count"] = int(player.final_attributes.get("ghost_count", 0)) + 1
	var ghost_names: Array = player.final_attributes.get("ghost_names", []) as Array
	ghost_names.append(quality + "坛魂")
	player.final_attributes["ghost_names"] = ghost_names
	player.refined_bonuses["攻击力"] = float(player.refined_bonuses.get("攻击力", 0.0)) + 0.01 * _quality_power(quality) * reward_scale
	var grow_message: String = grow_treasure(player, maxi(1, int(round(float(ghost_power) / 6.0))))
	var message: String = "招魂坛摄魂，养成鬼魂 +" + str(ghost_power)
	if grow_message != "":
		message += "；" + grow_message
	var technique_message: String = _grow_techniques_for_cultivation(player, "鬼修", 1, "招魂摄魄")
	if technique_message != "":
		message += "；" + technique_message
	return message


func _apply_adventure_reward(player: PlayerData, quality: String, scale: float) -> String:
	var multiplier: float = float(QUALITY_MULTIPLIER.get(quality, 1.0))
	var reward_scale: float = clampf(scale, 0.35, 1.5)
	var roll: float = rng.randf()
	if reward_scale < 0.55:
		var small_amount: int = int(round(36.0 * multiplier * reward_scale))
		player.ling_li += small_amount
		return "秘境边缘悟道，修为 +" + str(small_amount)

	if roll < 0.34:
		var before_stage: String = get_cultivation_stage_name(player)
		var amount: int = int(round(70.0 * multiplier * reward_scale))
		player.ling_li += amount
		var message: String = _append_stage_change_to_message(player, before_stage, "秘境灵泉灌顶，修为 +" + str(amount))
		var sword_message: String = _add_growth_sword_exp(player, maxi(1, int(round(float(amount) / 18.0))), "秘境灵泉")
		if sword_message != "":
			message += "；" + sword_message
		return message
	if roll < 0.52:
		var stone_amount: int = int(round(260.0 * multiplier * reward_scale))
		player.ling_shi += stone_amount
		return "秘境宝匣开启，灵石 +" + str(stone_amount)
	if roll < 0.72:
		return "秘境传承现世，" + _grant_technique_reward(player, quality)
	var treasure: Dictionary = generate_treasure_for_player(player, quality)
	return "秘境法宝认主，" + _store_equipment_item(player, "treasure", treasure)


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
			start_battle(str(calamity.get("quality", "元婴级")))
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


func _get_equipped_treasure(player: PlayerData) -> Dictionary:
	if player == null or player.treasures.is_empty():
		return {}
	var treasure: Variant = player.treasures[0]
	if treasure is Dictionary:
		return (treasure as Dictionary)
	return {}


func _sum_player_bonus(player: PlayerData, bonus_name: String) -> float:
	if player == null:
		return 0.0
	var total: float = _sum_player_technique_bonus(player, bonus_name)
	total += _sum_player_non_technique_bonus(player, bonus_name)
	return total


func _sum_player_technique_bonus(player: PlayerData, bonus_name: String) -> float:
	if player == null:
		return 0.0
	var total: float = 0.0
	for technique in player.techniques:
		if technique is Dictionary:
			var bonuses: Dictionary = (technique as Dictionary).get("bonuses", {}) as Dictionary
			total += float(bonuses.get(bonus_name, 0.0)) * _technique_effect_multiplier_total(technique as Dictionary)
	return total


func _sum_player_non_technique_bonus(player: PlayerData, bonus_name: String) -> float:
	if player == null:
		return 0.0
	var total: float = 0.0
	for treasure in player.treasures:
		if treasure is Dictionary:
			var passive_bonus: Dictionary = (treasure as Dictionary).get("passive_bonus", {}) as Dictionary
			total += float(passive_bonus.get(bonus_name, 0.0))
	total += float(player.refined_bonuses.get(bonus_name, 0.0))
	total += float(player.resonance_bonus.get(bonus_name, 0.0))
	total += float((player.final_attributes.get("cultivation_bonus", {}) as Dictionary).get(bonus_name, 0.0))
	for companion in player.companions:
		if companion is Dictionary:
			var companion_data: Dictionary = companion as Dictionary
			if str(companion_data.get("bonus_type", "")) == bonus_name:
				total += _companion_effective_bonus_value(companion_data)
	return total


func get_crit_chance(player: PlayerData) -> float:
	if player == null:
		return 0.0
	var treasure: Dictionary = _get_equipped_treasure(player)
	var chance: float = BASE_CRIT_CHANCE
	chance += _sum_player_bonus(player, "暴击率")
	chance += float(treasure.get("crit_chance", 0.0))
	chance += float(player.final_attributes.get("暴击率", 0.0))
	return clampf(chance, 0.0, 0.95)


func get_dodge_chance(player: PlayerData) -> float:
	if player == null:
		return 0.0
	var treasure: Dictionary = _get_equipped_treasure(player)
	var chance: float = BASE_DODGE_CHANCE
	chance += float(player.stats.get("身法", 0)) * DODGE_SHEN_FA_CHANCE
	chance += _sum_player_bonus(player, "闪避率")
	chance += float(treasure.get("dodge_chance", 0.0))
	chance += float(player.final_attributes.get("闪避率", 0.0))
	return clampf(chance, 0.0, 0.75)


func _battle_player_attack(player: PlayerData) -> float:
	if player == null:
		return 10.0
	var stats: Dictionary = calculate_duel_stats(player)
	return maxf(1.0, float(stats.get("攻击力", player.attack)))


func _battle_player_defense(player: PlayerData) -> float:
	if player == null:
		return 0.0
	var stats: Dictionary = calculate_duel_stats(player)
	return maxf(0.0, float(stats.get("防御力", player.defense)))


func _estimate_battle_action_damage(player: PlayerData) -> float:
	if player == null or player.qi_xue <= 0:
		return 0.0
	var treasure: Dictionary = _get_equipped_treasure(player)
	if not treasure.is_empty():
		_prepare_treasure(treasure, _player_sect(player))
	var treasure_damage: float = float(_treasure_effective_attack(treasure)) if not treasure.is_empty() else 0.0
	var attack_bonus: float = 1.0 + _sum_player_bonus(player, "攻击力") + _sum_player_bonus(player, "全属性")
	attack_bonus += _body_school_attack_bonus(player)
	attack_bonus += _emotion_school_attack_bonus(player) * 0.75
	var damage: float = (3.0 + treasure_damage + _battle_player_attack(player) * BATTLE_ATTACK_DAMAGE_SCALE) * attack_bonus
	damage += _identity_passive_value(player, "天剑阁")
	damage += float(_ghost_attack_damage(player, false))
	var sword_level: int = _cultivation_route_level(player, "剑修")
	if sword_level >= 1:
		damage *= 1.0 + 0.22 + float(sword_level) * 0.06
	return maxf(1.0, damage)


func _party_expected_battle_damage() -> float:
	var total: float = 0.0
	total += _estimate_battle_action_damage(player_a)
	total += _estimate_battle_action_damage(player_b)
	return maxf(1.0, total)


func _party_average_max_hp() -> float:
	var total_hp: float = 0.0
	var count: int = 0
	if player_a != null and player_a.qi_xue > 0:
		total_hp += float(_get_player_max_hp(player_a))
		count += 1
	if player_b != null and player_b.qi_xue > 0:
		total_hp += float(_get_player_max_hp(player_b))
		count += 1
	if count <= 0:
		return 80.0
	return total_hp / float(count)


func _enemy_required_build_level(enemy_quality: String = "") -> int:
	var quality: String = enemy_quality
	if quality == "" and not current_enemy.is_empty():
		quality = str(current_enemy.get("quality", "筑基级"))
	match quality:
		"炼气级", "筑基级":
			return 0
		"金丹级":
			return 1
		"元婴级":
			return 2
		"化神级":
			return 3
		"合体级":
			return 4
		_:
			return clampi(_quality_rank(quality) - 1, 0, 4)


func _player_build_level(player: PlayerData) -> int:
	if player == null:
		return 0
	check_set_bonus(player)
	return int(player.final_attributes.get("cultivation_bond_level", 0))


func _party_best_build_level() -> int:
	return maxi(_player_build_level(player_a), _player_build_level(player_b))


func _party_battle_combat_power() -> float:
	var total: float = 0.0
	if player_a != null and player_a.qi_xue > 0 and not _is_battle_peer_escaped(player_a.peer_id):
		total += get_visible_combat_power(player_a)
	if player_b != null and player_b.qi_xue > 0 and not _is_battle_peer_escaped(player_b.peer_id):
		total += get_visible_combat_power(player_b)
	return maxf(1.0, total)


func _battle_build_pressure_gap(player: PlayerData) -> int:
	if player == null or current_enemy.is_empty():
		return 0
	var required: int = _enemy_required_build_level(str(current_enemy.get("quality", "")))
	var current: int = _player_build_level(player)
	return maxi(0, required - current)


func _battle_build_damage_multiplier(player: PlayerData) -> float:
	var gap: int = _battle_build_pressure_gap(player)
	return clampf(1.0 - float(gap) * ENEMY_BUILD_PRESSURE_DAMAGE_LOSS, 0.45, 1.0)


func _battle_build_hurt_multiplier(player: PlayerData) -> float:
	var gap: int = _battle_build_pressure_gap(player)
	return 1.0 + float(gap) * ENEMY_BUILD_PRESSURE_HURT_GAIN


func _battle_build_pressure_text(player: PlayerData) -> String:
	var gap: int = _battle_build_pressure_gap(player)
	if player == null or gap <= 0:
		return ""
	var required: int = _enemy_required_build_level(str(current_enemy.get("quality", "")))
	var current: int = _player_build_level(player)
	return player.player_name + "构筑未稳（" + str(current) + "/" + str(required) + "），被妖威压制"


func _enemy_threat_level_for_battle(enemy_quality: String, enemy_power: float, party_power: float, enemy_count: int) -> int:
	var threat_level: int = 0
	var ratio: float = enemy_power / maxf(1.0, party_power)
	if ratio >= 1.35:
		threat_level = 3
	elif ratio >= 1.15:
		threat_level = 2
	elif ratio >= 0.95:
		threat_level = 1
	var build_gap: int = maxi(0, _enemy_required_build_level(enemy_quality) - _party_best_build_level())
	threat_level = maxi(threat_level, build_gap)
	if enemy_elite:
		threat_level += 1
	if enemy_count >= 2 and ratio >= 0.80:
		threat_level += 1
	return clampi(threat_level, 0, ENEMY_THREAT_MAX_LEVEL)


func _battle_enemy_threat_level() -> int:
	if current_enemy.is_empty():
		return 0
	return clampi(int(current_enemy.get("threat_level", 0)), 0, ENEMY_THREAT_MAX_LEVEL)


func _battle_enemy_threat_damage_multiplier() -> float:
	var threat_level: int = _battle_enemy_threat_level()
	return clampf(1.0 - float(threat_level) * ENEMY_THREAT_DAMAGE_LOSS, 0.55, 1.0)


func _battle_enemy_threat_hurt_multiplier() -> float:
	var threat_level: int = _battle_enemy_threat_level()
	return 1.0 + float(threat_level) * ENEMY_THREAT_HURT_GAIN


func _enemy_threat_text(threat_level: int) -> String:
	match threat_level:
		1:
			return "妖威渐盛，正面硬拼已有风险"
		2:
			return "妖威压境，未成套者容易受创"
		3:
			return "大妖横压，道基不稳者九死一生"
		_:
			return "凶煞滔天，此战不可恋战"


func _battle_action_damage(player: PlayerData, action: String) -> int:
	if player != null:
		player.final_attributes["last_treasure_attack_effects"] = []
		player.final_attributes["last_battle_crit"] = false
	if action == "逃跑":
		return 0
	var base_damage: float = 3.0 if action == "抢攻" else 2.0
	var treasure: Dictionary = _get_equipped_treasure(player)
	if not treasure.is_empty():
		_prepare_treasure(treasure, _player_sect(player))
	var treasure_damage: float = float(_treasure_effective_attack(treasure)) if action == "抢攻" and not treasure.is_empty() else 0.0
	var ghost_damage: int = _ghost_attack_damage(player, false)
	var attack_bonus: float = 1.0 + _sum_player_bonus(player, "攻击力") + _sum_player_bonus(player, "全属性")
	attack_bonus += _body_school_attack_bonus(player)
	attack_bonus += _emotion_school_attack_bonus(player) * 0.75
	var extra_damage: float = _battle_player_attack(player) * BATTLE_ATTACK_DAMAGE_SCALE
	var damage_float: float = (base_damage + treasure_damage + extra_damage) * attack_bonus
	if action == "抢攻":
		damage_float += _identity_passive_value(player, "天剑阁")
	var effect_logs: Array[String] = []
	var crit_chance: float = get_crit_chance(player)
	var lifesteal_rate: float = 0.0
	var treasure_effect_triggered: bool = false
	if action == "抢攻" and not treasure.is_empty():
		effect_logs.append("法宝+" + str(int(treasure_damage)))
		var effect_chance: float = clampf(TREASURE_ATTACK_EFFECT_CHANCE + float(player.final_attributes.get("treasure_effect_chance", 0.0)), 0.0, 0.95)
		var triggered_effects: Array[String] = []
		if rng.randf() <= effect_chance:
			triggered_effects.append(str(treasure.get("attack_effect", "")))
		var extra_effects: Array = treasure.get("extra_attack_effects", []) as Array
		for effect in extra_effects:
			if rng.randf() <= effect_chance:
				triggered_effects.append(str(effect))
		if int(treasure.get("awakening_level", 0)) > 0:
			var awaken_skill: Dictionary = treasure.get("awakening_skill", {}) as Dictionary
			var skill_damage: int = maxi(1, int(round(treasure_damage * float(awaken_skill.get("damage_scale", 0.35)) * attack_bonus)))
			damage_float += skill_damage
			effect_logs.append(str(awaken_skill.get("name", "觉醒技")) + "+" + str(skill_damage))
			lifesteal_rate = maxf(lifesteal_rate, float(awaken_skill.get("heal_rate", 0.0)))
		for effect_name in triggered_effects:
			treasure_effect_triggered = true
			match effect_name:
				"破甲":
					damage_float *= 1.20
					effect_logs.append("破甲")
				"吸血":
					lifesteal_rate = maxf(lifesteal_rate, 0.15)
					effect_logs.append("吸血")
				"连击":
					var combo_damage: int = maxi(1, int(round(damage_float * 0.50)))
					damage_float += combo_damage
					effect_logs.append("连击+" + str(combo_damage))
				"暴击加成":
					crit_chance = clampf(crit_chance + 0.20, 0.0, 0.95)
					effect_logs.append("暴击率+20%")
	var sword_level: int = _cultivation_route_level(player, "剑修")
	if action == "抢攻" and sword_level >= 1:
		var sword_scale: float = 0.22 + float(sword_level) * 0.06
		var sword_damage: int = maxi(1, int(round(damage_float * sword_scale)))
		damage_float += sword_damage
		effect_logs.append("剑影追斩+" + str(sword_damage))
		var second_sword_chance: float = 0.45 if sword_level >= 4 else 0.25
		if sword_level >= 3 and rng.randf() < second_sword_chance:
			var second_sword: int = maxi(1, int(round(float(sword_damage) * 0.55)))
			damage_float += second_sword
			effect_logs.append("万剑再斩+" + str(second_sword))
		if sword_level >= 4:
			var unity_sword: int = maxi(1, int(round(damage_float * 0.12)))
			damage_float += unity_sword
			effect_logs.append("剑心归一+" + str(unity_sword))
	var artificer_level: int = _cultivation_route_level(player, "器修")
	if action == "抢攻" and artificer_level >= 1 and not treasure.is_empty() and (artificer_level >= 4 or treasure_effect_triggered or int(treasure.get("awakening_level", 0)) > 0):
		var resonance_growth: int = 1
		if artificer_level >= 4:
			resonance_growth += 1
		elif artificer_level >= 3 and rng.randf() < 0.35:
			resonance_growth += 1
		var resonance_message: String = grow_treasure(player, resonance_growth)
		if resonance_message != "":
			effect_logs.append(("器魂归一+" if artificer_level >= 4 else "器魂共鸣+") + str(resonance_growth))
	if rng.randf() <= crit_chance:
		damage_float *= CRIT_DAMAGE_MULTIPLIER
		effect_logs.append("暴击！")
		if player != null:
			player.final_attributes["last_battle_crit"] = true
	var build_multiplier: float = _battle_build_damage_multiplier(player)
	if build_multiplier < 0.999:
		damage_float *= build_multiplier
		effect_logs.append("构筑压制-" + str(int(round((1.0 - build_multiplier) * 100.0))) + "%")
	var threat_multiplier: float = _battle_enemy_threat_damage_multiplier()
	if threat_multiplier < 0.999:
		damage_float *= threat_multiplier
		effect_logs.append("妖威压制-" + str(int(round((1.0 - threat_multiplier) * 100.0))) + "%")
	var preview_damage: int = maxi(1, int(round(damage_float))) + ghost_damage
	if lifesteal_rate > 0.0:
		var heal_value: int = maxi(1, int(round(float(preview_damage) * lifesteal_rate)))
		var max_hp: int = _get_player_max_hp(player)
		var old_hp: int = player.qi_xue
		player.qi_xue = mini(max_hp, player.qi_xue + heal_value)
		effect_logs.append("回血+" + str(heal_value))
		if player.qi_xue > old_hp:
			_grow_treasure_for_cultivation(player, "丹修", 1)
			_grow_techniques_for_cultivation(player, "丹修", 1, "吸血回春")
	if player != null:
		player.final_attributes["last_treasure_attack_effects"] = effect_logs
	var damage: int = maxi(1, int(round(damage_float))) + ghost_damage
	if bool(treasure.get("is_growth_sword", false)):
		_add_growth_sword_exp(player, maxi(1, damage), "出剑")
	return damage


func _battle_hurt_after_reduction(player: PlayerData, hurt: int, action: String = "") -> int:
	if player != null:
		player.final_attributes["last_battle_dodged"] = false
		_clear_last_battle_mechanic_flags(player)
	if hurt <= 0:
		return 0
	var talisman_level: int = _cultivation_route_level(player, "符修")
	if player != null and action == "周旋" and talisman_level >= 1:
		var talisman_chance: float = clampf(0.22 + float(talisman_level) * 0.08 + float(player.stats.get("身法", 0)) * 0.01, 0.0, 0.62)
		if rng.randf() <= talisman_chance:
			player.final_attributes["last_battle_dodged"] = true
			player.final_attributes["last_talisman_dodge"] = true
			_grow_treasure_for_cultivation(player, "符修", 2)
			_grow_techniques_for_cultivation(player, "符修", 1, "符步闪身")
			return 0
	if player != null and rng.randf() <= get_dodge_chance(player):
		player.final_attributes["last_battle_dodged"] = true
		_grow_treasure_for_cultivation(player, "符修", 2)
		_grow_techniques_for_cultivation(player, "符修", 1, "闪身画符")
		return 0
	var treasure: Dictionary = _get_equipped_treasure(player)
	if not treasure.is_empty():
		_prepare_treasure(treasure, _player_sect(player))
	var reduction: float = float(treasure.get("battle_hurt_reduction", 0.0))
	reduction += _sum_player_bonus(player, "战斗减伤")
	reduction += _body_school_damage_reduction(player)
	reduction += _emotion_school_damage_reduction(player)
	if action == "周旋":
		reduction += _identity_passive_value(player, "符箓门")
	var array_level: int = _cultivation_route_level(player, "阵修")
	if player != null and action == "周旋" and array_level >= 1:
		var array_marks: int = clampi(int(player.final_attributes.get("battle_array_marks", 0)) + 1, 1, 6)
		player.final_attributes["battle_array_marks"] = array_marks
		player.final_attributes["last_array_guard"] = array_marks
		reduction += minf(0.28, float(array_marks) * (0.04 + float(array_level) * 0.015))
	var defense_value: float = _battle_player_defense(player)
	var defense_reduction: float = defense_value / (defense_value + BATTLE_DEFENSE_REDUCTION_SCALE) if defense_value > 0.0 else 0.0
	reduction += minf(defense_reduction, BATTLE_DEFENSE_REDUCTION_CAP)
	reduction = clampf(reduction, 0.0, 0.65)
	var final_hurt: int = maxi(0, int(round(float(hurt) * (1.0 - reduction))))
	if player == null or final_hurt <= 0:
		return final_hurt
	var build_hurt_multiplier: float = _battle_build_hurt_multiplier(player)
	if build_hurt_multiplier > 1.001:
		final_hurt = maxi(1, int(round(float(final_hurt) * build_hurt_multiplier)))
		player.final_attributes["last_build_pressure_hurt"] = int(round((build_hurt_multiplier - 1.0) * 100.0))
	else:
		player.final_attributes.erase("last_build_pressure_hurt")
	var threat_hurt_multiplier: float = _battle_enemy_threat_hurt_multiplier()
	if threat_hurt_multiplier > 1.001:
		final_hurt = maxi(1, int(round(float(final_hurt) * threat_hurt_multiplier)))
		player.final_attributes["last_enemy_threat_hurt"] = int(round((threat_hurt_multiplier - 1.0) * 100.0))
	else:
		player.final_attributes.erase("last_enemy_threat_hurt")
	var max_hp: int = _get_player_max_hp(player)
	var ghost_guard: int = int(player.final_attributes.get("battle_ghost_guard", 0))
	if ghost_guard > 0:
		var ghost_absorb: int = mini(ghost_guard, final_hurt)
		player.final_attributes["battle_ghost_guard"] = ghost_guard - ghost_absorb
		player.final_attributes["last_ghost_guard_absorb"] = ghost_absorb
		final_hurt -= ghost_absorb
	var heart_guard: int = int(player.final_attributes.get("heart_guard", 0))
	if heart_guard > 0 and final_hurt > 0:
		var heart_absorb: int = mini(heart_guard, final_hurt)
		player.final_attributes["heart_guard"] = heart_guard - heart_absorb
		player.final_attributes["last_heart_guard_absorb"] = heart_absorb
		final_hurt -= heart_absorb
		var emotion_level: int = _cultivation_route_level(player, "情修")
		if emotion_level >= 2:
			var heart_heal: int = maxi(1, int(round(float(heart_absorb) * (0.20 + float(emotion_level) * 0.06))))
			var old_hp: int = player.qi_xue
			player.qi_xue = mini(max_hp, player.qi_xue + heart_heal)
			player.final_attributes["last_heart_guard_heal"] = player.qi_xue - old_hp
	var body_level: int = _cultivation_route_level(player, "体修")
	if body_level >= 1 and final_hurt > 0 and not bool(player.final_attributes.get("battle_dharma_body_used", false)):
		var heavy_hit: bool = final_hurt >= maxi(6, int(round(float(max_hp) * 0.08)))
		if heavy_hit or player.qi_xue <= int(round(float(max_hp) * 0.45)):
			var body_rate: float = clampf(0.30 + float(body_level) * 0.08, 0.0, 0.60)
			var body_absorb: int = mini(final_hurt, maxi(1, int(round(float(final_hurt) * body_rate))))
			player.final_attributes["battle_dharma_body_used"] = true
			player.final_attributes["last_dharma_body_absorb"] = body_absorb
			final_hurt -= body_absorb
	var dan_level: int = _cultivation_route_level(player, "丹修")
	if dan_level >= 1 and final_hurt > 0 and not bool(player.final_attributes.get("battle_dan_life_used", false)):
		if player.qi_xue - final_hurt <= int(round(float(max_hp) * 0.35)):
			var reserve: int = int(player.final_attributes.get("dan_life_reserve", 0))
			var dan_absorb: int = mini(final_hurt, maxi(1, int(round(float(max_hp) * (0.10 + float(dan_level) * 0.03))))) + reserve * 3
			dan_absorb = mini(final_hurt, dan_absorb)
			player.final_attributes["battle_dan_life_used"] = true
			player.final_attributes["last_dan_life_absorb"] = dan_absorb
			if reserve > 0:
				player.final_attributes["dan_life_reserve"] = reserve - 1
			if dan_level >= 2:
				var dan_heal: int = maxi(1, int(round(float(max_hp) * (0.04 + float(dan_level) * 0.02))))
				var old_dan_hp: int = player.qi_xue
				player.qi_xue = mini(max_hp, player.qi_xue + dan_heal)
				player.final_attributes["last_dan_life_heal"] = player.qi_xue - old_dan_hp
			final_hurt -= dan_absorb
	return final_hurt


func _battle_attack_log(player: PlayerData, action: String, damage: int) -> String:
	var treasure: Dictionary = _get_equipped_treasure(player)
	var weapon_name: String = str(treasure.get("attack_name", "掌中法力"))
	var treasure_name: String = str(treasure.get("name", "无名法宝"))
	if treasure.is_empty() or action != "抢攻":
		var ghost_text: String = "，役鬼追加撕咬" if _ghost_attack_damage(player, false) > 0 else ""
		var basic_effects: Array = player.final_attributes.get("last_treasure_attack_effects", []) as Array
		var basic_effect_text: String = "（" + "、".join(basic_effects) + "）" if not basic_effects.is_empty() else ""
		return player.player_name + action + "，以法力造成" + str(damage) + "点伤害" + ghost_text + basic_effect_text
	var extra_text: String = ""
	if bool(treasure.get("is_growth_sword", false)):
		extra_text = "（" + str(int(treasure.get("growth_level", 1))) + "阶）"
	if _ghost_attack_damage(player, false) > 0:
		extra_text += "，役鬼助攻"
	var effect_logs: Array = player.final_attributes.get("last_treasure_attack_effects", []) as Array
	if not effect_logs.is_empty():
		extra_text += "（" + "、".join(effect_logs) + "）"
	return player.player_name + action + "，催动【" + treasure_name + "】" + extra_text + "·" + weapon_name + "，造成" + str(damage) + "点伤害"


func _prepare_battle_route_mechanics(player: PlayerData) -> String:
	if player == null:
		return ""
	check_set_bonus(player)
	player.final_attributes["battle_array_marks"] = 0
	player.final_attributes["battle_dharma_body_used"] = false
	player.final_attributes["battle_dan_life_used"] = false
	_clear_last_battle_mechanic_flags(player)
	if not _has_cultivation_mechanic(player, "鬼修"):
		player.final_attributes.erase("battle_ghost_guard")
		return ""
	var level: int = _cultivation_route_level(player, "鬼修")
	var strength: float = _cultivation_route_strength(player, "鬼修")
	var ghost_power: int = int(player.final_attributes.get("ghost_power", 0))
	var guard: int = maxi(4, int(round(7.0 + float(level) * 4.0 + strength * 3.0 + float(ghost_power) / 12.0)))
	player.final_attributes["battle_ghost_guard"] = guard
	return player.player_name + "役鬼临阵，小鬼护在身前（护魂" + str(guard) + "）"


func _clear_last_battle_mechanic_flags(player: PlayerData) -> void:
	if player == null:
		return
	for key in [
		"last_ghost_guard_absorb",
		"last_dharma_body_absorb",
		"last_heart_guard_absorb",
		"last_dan_life_absorb",
		"last_array_guard",
		"last_talisman_dodge",
		"last_ghost_counter_damage",
		"last_dharma_counter_damage",
		"last_array_counter_damage",
		"last_talisman_counter_damage",
		"last_heart_guard_heal",
		"last_dan_life_heal",
		"last_build_pressure_hurt",
		"last_enemy_threat_hurt",
	]:
		player.final_attributes.erase(key)


func _battle_mechanic_log(player: PlayerData) -> String:
	if player == null:
		return ""
	var parts: Array[String] = []
	var build_pressure_hurt: int = int(player.final_attributes.get("last_build_pressure_hurt", 0))
	if build_pressure_hurt > 0:
		parts.append("构筑未稳+" + str(build_pressure_hurt) + "%")
	var threat_hurt: int = int(player.final_attributes.get("last_enemy_threat_hurt", 0))
	if threat_hurt > 0:
		parts.append("妖威压境+" + str(threat_hurt) + "%")
	var ghost_absorb: int = int(player.final_attributes.get("last_ghost_guard_absorb", 0))
	if ghost_absorb > 0:
		parts.append("小鬼挡劫-" + str(ghost_absorb))
	var ghost_counter: int = int(player.final_attributes.get("last_ghost_counter_damage", 0))
	if ghost_counter > 0:
		parts.append("役鬼反噬+" + str(ghost_counter))
	var heart_absorb: int = int(player.final_attributes.get("last_heart_guard_absorb", 0))
	if heart_absorb > 0:
		parts.append("红尘护心-" + str(heart_absorb))
	var heart_heal: int = int(player.final_attributes.get("last_heart_guard_heal", 0))
	if heart_heal > 0:
		parts.append("护心回春+" + str(heart_heal))
	var dharma_absorb: int = int(player.final_attributes.get("last_dharma_body_absorb", 0))
	if dharma_absorb > 0:
		parts.append("法相金身-" + str(dharma_absorb))
	var dharma_counter: int = int(player.final_attributes.get("last_dharma_counter_damage", 0))
	if dharma_counter > 0:
		parts.append("法相反震+" + str(dharma_counter))
	var dan_absorb: int = int(player.final_attributes.get("last_dan_life_absorb", 0))
	if dan_absorb > 0:
		parts.append("九转丹息-" + str(dan_absorb))
	var dan_heal: int = int(player.final_attributes.get("last_dan_life_heal", 0))
	if dan_heal > 0:
		parts.append("丹息续命+" + str(dan_heal))
	var array_guard: int = int(player.final_attributes.get("last_array_guard", 0))
	if array_guard > 0:
		parts.append("阵纹护身" + str(array_guard) + "层")
	var array_counter: int = int(player.final_attributes.get("last_array_counter_damage", 0))
	if array_counter > 0:
		parts.append("阵纹绞杀+" + str(array_counter))
	if bool(player.final_attributes.get("last_talisman_dodge", false)):
		parts.append("符步错身")
	var talisman_counter: int = int(player.final_attributes.get("last_talisman_counter_damage", 0))
	if talisman_counter > 0:
		parts.append("符剑回刺+" + str(talisman_counter))
	if parts.is_empty():
		return ""
	return player.player_name + "：" + "，".join(parts)


func _battle_defensive_counter_damage(player: PlayerData) -> int:
	if player == null:
		return 0
	var total: int = 0
	var ghost_level: int = _cultivation_route_level(player, "鬼修")
	var ghost_absorb: int = int(player.final_attributes.get("last_ghost_guard_absorb", 0))
	if ghost_level >= 2 and ghost_absorb > 0:
		var ghost_counter: int = maxi(1, int(round(float(ghost_absorb) * (0.25 + float(ghost_level) * 0.08))))
		player.final_attributes["last_ghost_counter_damage"] = ghost_counter
		total += ghost_counter
	var body_level: int = _cultivation_route_level(player, "体修")
	var dharma_absorb: int = int(player.final_attributes.get("last_dharma_body_absorb", 0))
	if body_level >= 2 and dharma_absorb > 0:
		var dharma_counter: int = maxi(1, int(round(float(dharma_absorb) * (0.20 + float(body_level) * 0.08))))
		player.final_attributes["last_dharma_counter_damage"] = dharma_counter
		total += dharma_counter
	var array_level: int = _cultivation_route_level(player, "阵修")
	var array_guard: int = int(player.final_attributes.get("last_array_guard", 0))
	if array_level >= 3 and array_guard > 0:
		var array_counter: int = array_guard * (2 + array_level)
		player.final_attributes["last_array_counter_damage"] = array_counter
		total += array_counter
	var talisman_level: int = _cultivation_route_level(player, "符修")
	if talisman_level >= 3 and bool(player.final_attributes.get("last_talisman_dodge", false)):
		var talisman_counter: int = 4 + talisman_level * 2 + int(player.stats.get("身法", 0))
		player.final_attributes["last_talisman_counter_damage"] = talisman_counter
		total += talisman_counter
	return total


func _roll_enemy_pack_count(enemy_quality: String) -> int:
	var realm_rank: int = _highest_player_realm_rank()
	if realm_rank < MULTI_ENEMY_MIN_REALM_RANK:
		return 1
	var chance: float = MULTI_ENEMY_BASE_CHANCE + float(realm_rank - MULTI_ENEMY_MIN_REALM_RANK) * MULTI_ENEMY_REALM_CHANCE
	chance += float(_quality_rank(enemy_quality)) * 0.015
	if enemy_elite:
		chance += 0.10
	return 2 if rng.randf() < clampf(chance, 0.0, 0.68) else 1


func _enemy_pack_title(enemy_quality: String, count: int) -> String:
	var quality_name: String = quality_display_name(enemy_quality)
	if count >= 2:
		return "双妖围攻·" + quality_name + ("精英妖兽" if enemy_elite else "妖兽")
	return quality_name + ("精英妖兽" if enemy_elite else "妖兽")


func _refresh_enemy_pack_state() -> void:
	if current_enemy.is_empty():
		return
	var count: int = maxi(1, int(current_enemy.get("enemy_count", 1)))
	var single_hp: int = maxi(1, int(current_enemy.get("single_max_hp", current_enemy.get("max_hp", current_enemy.get("hp", 1)))))
	var single_attack: int = maxi(1, int(current_enemy.get("single_attack", current_enemy.get("attack", 1))))
	var hp: int = maxi(0, int(current_enemy.get("hp", 0)))
	var alive_count: int = 0 if hp <= 0 else clampi(int(ceil(float(hp) / float(single_hp))), 1, count)
	current_enemy["alive_count"] = alive_count
	current_enemy["attack"] = single_attack * alive_count
	current_enemy["pack_text"] = ("剩" + str(alive_count) + "/" + str(count) + "只") if count > 1 else ""


func start_battle(enemy_quality: String) -> void:
	if not NetworkManager.is_host:
		return
	if current_state == GameState.BATTLE:
		return

	enemy_quality = _clamp_enemy_quality_for_current_realm(enemy_quality)
	var template: Dictionary = ENEMIES.get(enemy_quality, ENEMIES["元婴级"]) as Dictionary
	current_enemy = template.duplicate(true)
	if enemy_elite:
		current_enemy["hp"] = int(round(float(current_enemy.get("hp", 0)) * 1.5))
		current_enemy["attack"] = int(round(float(current_enemy.get("attack", 0)) * 1.5))
	var round_hp_scale: float = 1.0 + float(maxi(0, round_number - 1)) * 0.08
	var round_attack_scale: float = 1.0 + float(maxi(0, round_number - 1)) * 0.04
	current_enemy["hp"] = int(round(float(current_enemy.get("hp", 0)) * round_hp_scale))
	current_enemy["attack"] = int(round(float(current_enemy.get("attack", 0)) * round_attack_scale))

	var enemy_count: int = _roll_enemy_pack_count(enemy_quality)
	var single_hp: int = int(current_enemy.get("hp", 0))
	var single_attack: int = int(current_enemy.get("attack", 0))
	var expected_party_damage: float = _party_expected_battle_damage()
	var survive_actions: float = ENEMY_ELITE_SURVIVE_ACTIONS if enemy_elite else ENEMY_MIN_SURVIVE_ACTIONS
	var hp_floor: int = int(round(expected_party_damage * survive_actions))
	var hp_was_raised: bool = hp_floor > single_hp
	single_hp = maxi(single_hp, hp_floor)
	var attack_floor: int = int(round(_party_average_max_hp() * ENEMY_ATTACK_HP_PRESSURE * (1.15 if enemy_elite else 1.0)))
	var attack_was_raised: bool = attack_floor > single_attack
	single_attack = maxi(single_attack, attack_floor)
	current_enemy["dynamic_scaled"] = hp_was_raised or attack_was_raised
	current_enemy["expected_party_damage"] = int(round(expected_party_damage))
	current_enemy["enemy_count"] = enemy_count
	current_enemy["alive_count"] = enemy_count
	current_enemy["single_max_hp"] = single_hp
	current_enemy["single_attack"] = single_attack
	current_enemy["hp"] = single_hp * enemy_count
	current_enemy["max_hp"] = single_hp * enemy_count
	current_enemy["quality"] = enemy_quality
	current_enemy["name"] = _enemy_pack_title(enemy_quality, enemy_count)
	_refresh_enemy_pack_state()
	battle_escaped_peers.clear()
	var party_power: float = _party_battle_combat_power()
	var enemy_power: float = get_enemy_visible_combat_power(current_enemy)
	var threat_level: int = _enemy_threat_level_for_battle(enemy_quality, enemy_power, party_power, enemy_count)
	current_enemy["threat_level"] = threat_level
	current_enemy["party_power_at_start"] = int(round(party_power))
	current_enemy["enemy_power_at_start"] = int(round(enemy_power))
	battle_contributions.clear()
	battle_choices.clear()
	battle_log.clear()
	if bool(current_enemy.get("dynamic_scaled", false)):
		battle_log.append("妖兽感到杀意，气血与妖力随你的战力攀升")
	if enemy_count >= 2:
		battle_log.append("妖气并起，双妖拦路！先斩一只，压力便会降下来。")
	if threat_level > 0:
		battle_log.append(_enemy_threat_text(threat_level))
	var pressure_a: String = _battle_build_pressure_text(player_a)
	if pressure_a != "":
		battle_log.append(pressure_a)
	var pressure_b: String = _battle_build_pressure_text(player_b)
	if pressure_b != "":
		battle_log.append(pressure_b)
	var prep_a: String = _prepare_battle_route_mechanics(player_a)
	if prep_a != "":
		battle_log.append(prep_a)
	var prep_b: String = _prepare_battle_route_mechanics(player_b)
	if prep_b != "":
		battle_log.append(prep_b)
	change_state(GameState.BATTLE)
	battle_started.emit(current_enemy)
	if not single_player_mode:
		_show_battle.rpc(current_enemy)
	transition_to_scene("res://scenes/battle.tscn")


func _is_battle_peer_escaped(peer_id: int) -> bool:
	return battle_escaped_peers.has(str(peer_id)) or battle_escaped_peers.has(peer_id)


func _mark_battle_peer_escaped(peer_id: int) -> void:
	if peer_id > 0:
		battle_escaped_peers[str(peer_id)] = true
		battle_contributions.erase(peer_id)
		battle_contributions.erase(str(peer_id))


func _active_battle_player_count() -> int:
	var count: int = 0
	if player_a != null and not _is_battle_peer_escaped(player_a.peer_id):
		count += 1
	if player_b != null and not _is_battle_peer_escaped(player_b.peer_id):
		count += 1
	return count


func _enemy_attack_candidates(hurt_a: int, hurt_b: int, action_a: String, action_b: String, escaped_a: bool, escaped_b: bool) -> Array:
	var candidates: Array = []
	if player_a != null and not escaped_a and not _is_battle_peer_escaped(player_a.peer_id) and hurt_a > 0:
		candidates.append({"key": "a", "name": player_a.player_name, "hurt": hurt_a, "action": action_a})
	if player_b != null and not escaped_b and not _is_battle_peer_escaped(player_b.peer_id) and hurt_b > 0:
		candidates.append({"key": "b", "name": player_b.player_name, "hurt": hurt_b, "action": action_b})
	return candidates


func _choose_enemy_single_attack_target(candidates: Array) -> String:
	var total_weight: float = 0.0
	var weighted: Array = []
	for candidate in candidates:
		var key: String = str((candidate as Dictionary).get("key", ""))
		var action: String = str((candidate as Dictionary).get("action", ""))
		var weight: float = maxf(1.0, float((candidate as Dictionary).get("hurt", 0)))
		match action:
			"抢攻":
				weight *= 1.30
			"逃跑":
				weight *= 1.12
			"周旋":
				weight *= 0.80
		total_weight += weight
		weighted.append({"key": key, "weight": weight})
	if total_weight <= 0.0:
		return str((candidates[0] as Dictionary).get("key", ""))
	var roll: float = rng.randf() * total_weight
	var cursor: float = 0.0
	for entry in weighted:
		cursor += float((entry as Dictionary).get("weight", 0.0))
		if roll <= cursor:
			return str((entry as Dictionary).get("key", ""))
	return str(((weighted.back() as Dictionary).get("key", "")))


func _apply_enemy_attack_pattern(hurt_a: int, hurt_b: int, action_a: String, action_b: String, escaped_a: bool, escaped_b: bool) -> Dictionary:
	var candidates: Array = _enemy_attack_candidates(hurt_a, hurt_b, action_a, action_b, escaped_a, escaped_b)
	if candidates.size() <= 1:
		var only_target: String = ""
		if candidates.size() == 1:
			only_target = str((candidates[0] as Dictionary).get("key", ""))
		return {"hurt_a": hurt_a, "hurt_b": hurt_b, "mode": "single", "target": only_target, "message": ""}

	var alive_count: int = maxi(1, int(current_enemy.get("alive_count", current_enemy.get("enemy_count", 1))))
	var group_chance: float = 1.0 - ENEMY_SINGLE_ATTACK_CHANCE
	if alive_count >= 2:
		group_chance += float(alive_count - 1) * ENEMY_GROUP_ATTACK_PACK_BONUS
	if enemy_elite:
		group_chance += ENEMY_GROUP_ATTACK_ELITE_BONUS
	group_chance += float(_battle_enemy_threat_level()) * ENEMY_GROUP_ATTACK_THREAT_BONUS
	group_chance = clampf(group_chance, 0.25, 0.78)
	if rng.randf() < group_chance:
		var group_hurt_a: int = hurt_a
		var group_hurt_b: int = hurt_b
		if hurt_a > 0 and not escaped_a and player_a != null and not _is_battle_peer_escaped(player_a.peer_id):
			group_hurt_a = maxi(1, int(round(float(hurt_a) * ENEMY_GROUP_ATTACK_MULTIPLIER)))
		if hurt_b > 0 and not escaped_b and player_b != null and not _is_battle_peer_escaped(player_b.peer_id):
			group_hurt_b = maxi(1, int(round(float(hurt_b) * ENEMY_GROUP_ATTACK_MULTIPLIER)))
		var group_name: String = "群妖" if alive_count >= 2 else "妖兽"
		return {
			"hurt_a": group_hurt_a,
			"hurt_b": group_hurt_b,
			"mode": "group",
			"target": "",
			"message": group_name + "横扫全场，未脱离者皆受波及",
		}

	var target_key: String = _choose_enemy_single_attack_target(candidates)
	var target_name: String = ""
	for candidate in candidates:
		if str((candidate as Dictionary).get("key", "")) == target_key:
			target_name = str((candidate as Dictionary).get("name", ""))
			break
	var single_hurt_a: int = 0
	var single_hurt_b: int = 0
	if target_key == "a":
		single_hurt_a = maxi(1, int(round(float(hurt_a) * ENEMY_SINGLE_ATTACK_MULTIPLIER)))
	elif target_key == "b":
		single_hurt_b = maxi(1, int(round(float(hurt_b) * ENEMY_SINGLE_ATTACK_MULTIPLIER)))
	return {
		"hurt_a": single_hurt_a,
		"hurt_b": single_hurt_b,
		"mode": "single",
		"target": target_key,
		"message": "妖兽锁定" + target_name + "，一记重击破风而至",
	}


func settle_battle_action(peer_id: int, action: String) -> void:
	if not NetworkManager.is_host:
		return
	if current_enemy.is_empty():
		return

	var action_peer_id: int = peer_id
	if action_peer_id <= 0:
		action_peer_id = 1
	if _is_battle_peer_escaped(action_peer_id):
		return
	battle_choices[action_peer_id] = action
	if single_player_mode and action_peer_id == player_a.peer_id and not _is_battle_peer_escaped(player_b.peer_id) and not battle_choices.has(player_b.peer_id):
		_queue_npc_battle_action()

	var needs_a: bool = player_a != null and not _is_battle_peer_escaped(player_a.peer_id)
	var needs_b: bool = player_b != null and not _is_battle_peer_escaped(player_b.peer_id)
	if not needs_a and not needs_b:
		handle_double_escape()
		return
	if needs_a and not battle_choices.has(player_a.peer_id):
		return
	if needs_b and not battle_choices.has(player_b.peer_id):
		return

	var action_a: String = str(battle_choices[player_a.peer_id]) if needs_a else "脱离"
	var action_b: String = str(battle_choices[player_b.peer_id]) if needs_b else "脱离"
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
	var name_a: String = player_a.player_name
	var name_b: String = player_b.player_name

	if action_a == "脱离" and action_b == "脱离":
		handle_double_escape()
		return
	elif action_a == "脱离":
		match action_b:
			"抢攻":
				enemy_damage_b = _battle_action_damage(player_b, action_b)
				hurt_b = enemy_attack
				battle_log.append(name_a + "已脱离战斗，" + name_b + "独自抢攻")
			"周旋":
				enemy_damage_b = _battle_action_damage(player_b, action_b)
				hurt_b = int(round(float(enemy_attack) * 0.5))
				battle_log.append(name_a + "已脱离战斗，" + name_b + "独自周旋")
			"逃跑":
				if escape_success_b:
					escaped_b = true
					battle_log.append(name_b + "逃脱成功，战斗彻底脱离")
				else:
					hurt_b = _escape_fail_hurt(enemy_attack)
					battle_log.append(name_b + "逃跑失败，独受反击")
	elif action_b == "脱离":
		match action_a:
			"抢攻":
				enemy_damage_a = _battle_action_damage(player_a, action_a)
				hurt_a = enemy_attack
				battle_log.append(name_b + "已脱离战斗，" + name_a + "独自抢攻")
			"周旋":
				enemy_damage_a = _battle_action_damage(player_a, action_a)
				hurt_a = int(round(float(enemy_attack) * 0.5))
				battle_log.append(name_b + "已脱离战斗，" + name_a + "独自周旋")
			"逃跑":
				if escape_success_a:
					escaped_a = true
					battle_log.append(name_a + "逃脱成功，战斗彻底脱离")
				else:
					hurt_a = _escape_fail_hurt(enemy_attack)
					battle_log.append(name_a + "逃跑失败，独受反击")
	elif action_a == "抢攻" and action_b == "抢攻":
		enemy_damage_a = _battle_action_damage(player_a, action_a)
		enemy_damage_b = _battle_action_damage(player_b, action_b)
		hurt_a = enemy_attack
		hurt_b = enemy_attack
		battle_log.append("双方抢攻，各受全额反击")
	elif action_a == "抢攻" and action_b == "周旋":
		enemy_damage_a = _battle_action_damage(player_a, action_a)
		enemy_damage_b = _battle_action_damage(player_b, action_b)
		hurt_a = enemy_attack
		hurt_b = int(round(float(enemy_attack) * 0.5))
		battle_log.append("一方抢攻，一方周旋")
	elif action_a == "周旋" and action_b == "抢攻":
		enemy_damage_a = _battle_action_damage(player_a, action_a)
		enemy_damage_b = _battle_action_damage(player_b, action_b)
		hurt_a = int(round(float(enemy_attack) * 0.5))
		hurt_b = enemy_attack
		battle_log.append("一方周旋，一方抢攻")
	elif action_a == "抢攻" and action_b == "逃跑":
		enemy_damage_a = _battle_action_damage(player_a, action_a)
		hurt_a = enemy_attack * 2
		if escape_success_b:
			escaped_b = true
			battle_log.append(name_a + "抢攻，" + name_b + "逃脱成功")
		else:
			hurt_b = _escape_fail_hurt(enemy_attack)
			battle_log.append(name_a + "抢攻，" + name_b + "逃跑失败")
	elif action_a == "逃跑" and action_b == "抢攻":
		enemy_damage_b = _battle_action_damage(player_b, action_b)
		hurt_b = enemy_attack * 2
		if escape_success_a:
			escaped_a = true
			battle_log.append(name_b + "抢攻，" + name_a + "逃脱成功")
		else:
			hurt_a = _escape_fail_hurt(enemy_attack)
			battle_log.append(name_b + "抢攻，" + name_a + "逃跑失败")
	elif action_a == "周旋" and action_b == "周旋":
		enemy_damage_a = _battle_action_damage(player_a, action_a)
		enemy_damage_b = _battle_action_damage(player_b, action_b)
		hurt_a = int(round(float(enemy_attack) * 0.25))
		hurt_b = int(round(float(enemy_attack) * 0.25))
		battle_log.append("双方周旋，以守势磨损妖兽")
	elif action_a == "周旋" and action_b == "逃跑":
		enemy_damage_a = _battle_action_damage(player_a, action_a)
		hurt_a = enemy_attack
		if escape_success_b:
			escaped_b = true
			battle_log.append(name_a + "周旋，" + name_b + "逃脱成功")
		else:
			hurt_b = _escape_fail_hurt(enemy_attack)
			battle_log.append(name_a + "周旋，" + name_b + "逃跑失败")
	elif action_a == "逃跑" and action_b == "周旋":
		enemy_damage_b = _battle_action_damage(player_b, action_b)
		hurt_b = enemy_attack
		if escape_success_a:
			escaped_a = true
			battle_log.append(name_b + "周旋，" + name_a + "逃脱成功")
		else:
			hurt_a = _escape_fail_hurt(enemy_attack)
			battle_log.append(name_b + "周旋，" + name_a + "逃跑失败")
	else:
		if escape_success_a and escape_success_b:
			handle_double_escape()
			return
		if escape_success_a:
			escaped_a = true
			hurt_b = _escape_fail_hurt(enemy_attack)
			battle_log.append(name_a + "逃脱成功，" + name_b + "逃跑失败")
		elif escape_success_b:
			escaped_b = true
			hurt_a = _escape_fail_hurt(enemy_attack)
			battle_log.append(name_b + "逃脱成功，" + name_a + "逃跑失败")
		else:
			hurt_a = _escape_fail_hurt(enemy_attack)
			hurt_b = _escape_fail_hurt(enemy_attack)
			battle_log.append("双方逃跑失败，各受反击")

	if escaped_a:
		_mark_battle_peer_escaped(player_a.peer_id)
	if escaped_b:
		_mark_battle_peer_escaped(player_b.peer_id)
	if _active_battle_player_count() <= 0:
		handle_double_escape()
		return

	var enemy_attack_pattern: Dictionary = _apply_enemy_attack_pattern(hurt_a, hurt_b, action_a, action_b, escaped_a, escaped_b)
	hurt_a = int(enemy_attack_pattern.get("hurt_a", hurt_a))
	hurt_b = int(enemy_attack_pattern.get("hurt_b", hurt_b))
	var enemy_attack_message: String = str(enemy_attack_pattern.get("message", ""))
	if enemy_attack_message != "":
		battle_log.append(enemy_attack_message)

	hurt_a = _battle_hurt_after_reduction(player_a, hurt_a, action_a)
	hurt_b = _battle_hurt_after_reduction(player_b, hurt_b, action_b)
	enemy_damage_a += _battle_defensive_counter_damage(player_a)
	enemy_damage_b += _battle_defensive_counter_damage(player_b)
	if bool(player_a.final_attributes.get("last_battle_dodged", false)):
		battle_log.append(name_a + "闪避！")
	if bool(player_b.final_attributes.get("last_battle_dodged", false)):
		battle_log.append(name_b + "闪避！")
	var mechanic_log_a: String = _battle_mechanic_log(player_a)
	if mechanic_log_a != "":
		battle_log.append(mechanic_log_a)
	var mechanic_log_b: String = _battle_mechanic_log(player_b)
	if mechanic_log_b != "":
		battle_log.append(mechanic_log_b)
	if enemy_damage_a > 0:
		battle_log.append(_battle_attack_log(player_a, action_a, enemy_damage_a))
	if enemy_damage_b > 0:
		battle_log.append(_battle_attack_log(player_b, action_b, enemy_damage_b))

	current_enemy["hp"] = maxi(0, int(current_enemy.get("hp", 0)) - enemy_damage_a - enemy_damage_b)
	_refresh_enemy_pack_state()
	player_a.qi_xue = maxi(0, player_a.qi_xue - hurt_a)
	player_b.qi_xue = maxi(0, player_b.qi_xue - hurt_b)
	if _single_player_npc_battle_rescue():
		escaped_b = true
		if _active_battle_player_count() <= 0:
			handle_double_escape()
			return
	var build_message_a: String = "" if action_a == "脱离" else _apply_build_growth_from_battle(player_a, action_a, enemy_damage_a, hurt_a, escaped_a)
	var build_message_b: String = "" if action_b == "脱离" else _apply_build_growth_from_battle(player_b, action_b, enemy_damage_b, hurt_b, escaped_b)
	if build_message_a != "":
		battle_log.append(build_message_a)
	if build_message_b != "":
		battle_log.append(build_message_b)
	if action_a != "脱离" and not escaped_a:
		battle_contributions[player_a.peer_id] = float(battle_contributions.get(player_a.peer_id, 0.0)) + float(enemy_damage_a)
	if action_b != "脱离" and not escaped_b:
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
		"enemy_attack_mode": str(enemy_attack_pattern.get("mode", "")),
		"enemy_attack_target": str(enemy_attack_pattern.get("target", "")),
		"escape_chance_a": escape_chance_a,
		"escape_chance_b": escape_chance_b,
		"crit_a": bool(player_a.final_attributes.get("last_battle_crit", false)),
		"crit_b": bool(player_b.final_attributes.get("last_battle_crit", false)),
		"dodge_a": bool(player_a.final_attributes.get("last_battle_dodged", false)),
		"dodge_b": bool(player_b.final_attributes.get("last_battle_dodged", false)),
	})
	NetworkManager.send_message("battle_update", update_data)
	on_battle_update(update_data)
	_auto_save("battle_round")

	if current_enemy.is_empty():
		return
	if int(current_enemy.get("hp", 0)) <= 0:
		distribute_loot()
		return
	if not _is_battle_peer_escaped(player_a.peer_id) and player_a.qi_xue <= 0:
		handle_player_death(player_a)
		return
	if not _is_battle_peer_escaped(player_b.peer_id) and player_b.qi_xue <= 0:
		handle_player_death(player_b)
		return
	if single_player_mode and _is_battle_peer_escaped(player_a.peer_id) and not _is_battle_peer_escaped(player_b.peer_id):
		_queue_npc_battle_action()


func _single_player_npc_battle_rescue() -> bool:
	if not single_player_mode or player_b == null or current_state != GameState.BATTLE:
		return false
	if player_b.qi_xue > 0 or int(current_enemy.get("hp", 0)) <= 0:
		return false
	player_b.qi_xue = maxi(1, int(round(float(_get_player_max_hp(player_b)) * 0.12)))
	_mark_battle_peer_escaped(player_b.peer_id)
	battle_log.append(player_b.player_name + "护身符碎裂，重伤脱离本战")
	return true


func _apply_build_growth_from_battle(player: PlayerData, action: String, enemy_damage: int, hurt: int, escaped: bool) -> String:
	if player == null:
		return ""
	var treasure: Dictionary = _get_equipped_treasure(player)
	if not treasure.is_empty():
		_prepare_treasure(treasure, _player_sect(player))
	var growth_type: String = _treasure_growth_type(treasure) if not treasure.is_empty() else ""
	var amount: int = 0
	match growth_type:
		"剑修":
			if action == "抢攻":
				amount += 1
		"体修":
			if hurt > 0:
				amount += int(floor(float(hurt) / 10.0))
		"鬼修":
			if action == "抢攻" and enemy_damage > 0 and int(current_enemy.get("hp", 0)) <= 0:
				amount += 3
		"符修":
			if action == "周旋":
				amount += 1
			if escaped:
				amount += 2
	var messages: Array[String] = []
	var treasure_message: String = grow_treasure(player, amount)
	if treasure_message != "":
		messages.append(player.player_name + "：" + treasure_message)
	if action == "抢攻":
		var sword_message: String = _grow_techniques_for_cultivation(player, "剑修", 1, "抢攻磨剑")
		if sword_message != "":
			messages.append(player.player_name + "：" + sword_message)
	if action == "周旋":
		var talisman_message: String = _grow_techniques_for_cultivation(player, "符修", 1, "周旋画符")
		if talisman_message != "":
			messages.append(player.player_name + "：" + talisman_message)
	if hurt > 0:
		var body_message: String = _grow_techniques_for_cultivation(player, "体修", maxi(1, int(floor(float(hurt) / 20.0))), "受创淬体")
		if body_message != "":
			messages.append(player.player_name + "：" + body_message)
	if action == "抢攻" and enemy_damage > 0 and int(current_enemy.get("hp", 0)) <= 0:
		var ghost_message: String = _grow_techniques_for_cultivation(player, "鬼修", 1, "斩妖摄魂")
		if ghost_message != "":
			messages.append(player.player_name + "：" + ghost_message)
	if action == "抢攻":
		var attack_bond_message: String = _grow_companion_bonds_for_event(player, "battle_attack")
		if attack_bond_message != "":
			messages.append(player.player_name + "：" + attack_bond_message)
	if action == "抢攻" and enemy_damage > 0 and int(current_enemy.get("hp", 0)) <= 0:
		var kill_bond_message: String = _grow_companion_bonds_for_event(player, "enemy_kill")
		if kill_bond_message != "":
			messages.append(player.player_name + "：" + kill_bond_message)
	return "；".join(messages)


func get_escape_success_chance(player: PlayerData) -> float:
	if player == null:
		return 0.0
	var quality: String = str(current_enemy.get("quality", "元婴级"))
	var quality_penalty: float = _escape_quality_penalty(quality)
	var chance: float = ESCAPE_BASE_CHANCE
	chance += float(player.stats.get("身法", 0)) * ESCAPE_SHEN_FA_CHANCE
	chance += (float(player.speed) + _sum_player_bonus(player, "速度")) * ESCAPE_SPEED_CHANCE
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
		"炼气级":
			return 0.0
		"筑基级":
			return 0.04
		"金丹级":
			return 0.08
		"元婴级":
			return 0.13
		"化神级":
			return 0.18
		"合体级":
			return 0.24
		_:
			return 0.12


func handle_double_escape() -> void:
	enemy_elite = true
	battle_log.append("双方逃跑，敌人记住了这份因果，下次更强")
	var data: Dictionary = _battle_state_data({"message": "双方逃跑，敌人下次将变为精英"})
	battle_continue_votes.clear()
	NetworkManager.send_message("battle_end", data)
	battle_ended.emit(data)
	if not single_player_mode:
		_end_battle.rpc(data)
	change_state(GameState.BARGAIN)


func distribute_loot() -> void:
	var total_contribution: float = maxf(1.0, float(battle_contributions.get(player_a.peer_id, 0.0)) + float(battle_contributions.get(player_b.peer_id, 0.0)))
	var share_a: float = float(battle_contributions.get(player_a.peer_id, 0.0)) / total_contribution
	var share_b: float = float(battle_contributions.get(player_b.peer_id, 0.0)) / total_contribution
	var drop_desc: String = str(current_enemy.get("drop_desc", "掉落"))
	var enemy_quality: String = str(current_enemy.get("quality", "元婴级"))
	var was_elite: bool = enemy_elite
	var enemy_count: int = maxi(1, int(current_enemy.get("enemy_count", 1)))
	var pack_reward_scale: float = 1.0 + float(enemy_count - 1) * MULTI_ENEMY_REWARD_SCALE
	var reward_ling_li: int = int(round(float(_enemy_ling_li_reward(str(current_enemy.get("quality", "元婴级")))) * pack_reward_scale))
	var reward_a: int = int(round(float(reward_ling_li) * share_a))
	var reward_b: int = int(round(float(reward_ling_li) * share_b))
	var reward_stones: int = int(round(float(_enemy_ling_shi_reward(enemy_quality)) * pack_reward_scale))
	var stones_a: int = int(round(float(reward_stones) * share_a))
	var stones_b: int = int(round(float(reward_stones) * share_b))
	var name_a: String = player_a.player_name
	var name_b: String = player_b.player_name
	player_a.ling_li += reward_a
	player_b.ling_li += reward_b
	player_a.ling_shi += stones_a
	player_b.ling_shi += stones_b
	var reward_lines: Array[String] = []
	reward_lines.append("修为：" + name_a + " +" + str(reward_a) + " / " + name_b + " +" + str(reward_b))
	reward_lines.append("灵石：" + name_a + " +" + str(stones_a) + " / " + name_b + " +" + str(stones_b))
	reward_lines.append("贡献：" + name_a + " " + str(int(share_a * 100.0)) + "% / " + name_b + " " + str(int(share_b * 100.0)) + "%")
	var title_prefix: String = ""
	if enemy_count >= 2:
		title_prefix = "精英双妖" if was_elite else "双妖"
	elif was_elite:
		title_prefix = "精英"
	var title: String = title_prefix + quality_display_name(enemy_quality) + "妖兽伏诛"
	var message: String = title + "，掉落：" + drop_desc + "。"
	if enemy_count >= 2:
		reward_lines.append("双妖围攻：基础收益 +" + str(int(round((pack_reward_scale - 1.0) * 100.0))) + "%")
	var sword_a_message: String = _add_growth_sword_exp(player_a, maxi(1, int(round(float(reward_a) / 10.0))), "斩妖")
	var sword_b_message: String = _add_growth_sword_exp(player_b, maxi(1, int(round(float(reward_b) / 10.0))), "斩妖")
	if sword_a_message != "":
		message += "；" + name_a + " " + sword_a_message
		reward_lines.append(name_a + "：" + sword_a_message)
	if sword_b_message != "":
		message += "；" + name_b + " " + sword_b_message
		reward_lines.append(name_b + "：" + sword_b_message)
	var ghost_a_message: String = _feed_ghosts(player_a, int(round(_quality_power(enemy_quality) * share_a * 8.0)), "吞食妖煞")
	var ghost_b_message: String = _feed_ghosts(player_b, int(round(_quality_power(enemy_quality) * share_b * 8.0)), "吞食妖煞")
	if ghost_a_message != "":
		message += "；" + ghost_a_message
		reward_lines.append(ghost_a_message)
	if ghost_b_message != "":
		message += "；" + ghost_b_message
		reward_lines.append(ghost_b_message)
	var top_player: PlayerData = player_a if share_a >= share_b else player_b
	var top_share: float = maxf(share_a, share_b)
	var special_loot_message: String = _grant_enemy_special_loot(top_player, enemy_quality, top_share, was_elite)
	if special_loot_message != "":
		message += "；" + special_loot_message
		reward_lines.append(special_loot_message)
	if share_a > 0.0:
		var task_a_message: String = _complete_active_tasks(player_a, "enemy_kill", {"enemy_quality": enemy_quality})
		if task_a_message != "":
			message += "；" + task_a_message
			reward_lines.append(task_a_message)
	if share_b > 0.0:
		var task_b_message: String = _complete_active_tasks(player_b, "enemy_kill", {"enemy_quality": enemy_quality})
		if task_b_message != "":
			message += "；" + task_b_message
			reward_lines.append(task_b_message)
	if was_elite:
		message += "；精英额外掉落"
		var elite_ling_a: int = int(round(20.0 * share_a))
		var elite_ling_b: int = int(round(20.0 * share_b))
		var elite_stones_a: int = int(round(80.0 * share_a))
		var elite_stones_b: int = int(round(80.0 * share_b))
		player_a.ling_li += elite_ling_a
		player_b.ling_li += elite_ling_b
		player_a.ling_shi += elite_stones_a
		player_b.ling_shi += elite_stones_b
		reward_lines.append("精英额外：修为 " + name_a + " +" + str(elite_ling_a) + " / " + name_b + " +" + str(elite_ling_b))
		reward_lines.append("精英额外：灵石 " + name_a + " +" + str(elite_stones_a) + " / " + name_b + " +" + str(elite_stones_b))

	enemy_elite = false
	battle_log.append(message)
	var data: Dictionary = _battle_state_data({
		"message": message,
		"battle_reward_title": title,
		"reward_lines": reward_lines,
		"loot": drop_desc,
		"share_a": share_a,
		"share_b": share_b,
	})
	pending_battle_reward_feedback = data.duplicate(true)
	current_enemy.clear()
	battle_continue_votes.clear()
	NetworkManager.send_message("battle_end", data)
	battle_ended.emit(data)
	if not single_player_mode:
		_end_battle.rpc(data)
	change_state(GameState.BARGAIN)


func _enemy_ling_li_reward(quality: String) -> int:
	match quality:
		"炼气级":
			return 30
		"筑基级":
			return 50
		"金丹级":
			return 80
		"元婴级":
			return 120
		"化神级":
			return 180
		"合体级":
			return 260
		_:
			return 100


func _enemy_ling_shi_reward(quality: String) -> int:
	match quality:
		"炼气级":
			return 45
		"筑基级":
			return 75
		"金丹级":
			return 120
		"元婴级":
			return 190
		"化神级":
			return 300
		"合体级":
			return 480
		_:
			return 100


func _grant_enemy_special_loot(player: PlayerData, quality: String, contribution_share: float, was_elite: bool) -> String:
	if player == null or contribution_share <= 0.0:
		return ""

	var elite_bonus: int = 1 if was_elite else 0
	var max_rank: int = mini(_quality_rank(quality) + 1, QUALITY_ORDER.size() - 1)
	var min_rank: int = maxi(0, max_rank - 2)
	var loot_lines: Array[String] = []
	var treasure_chance: float = 0.20 if was_elite else 0.10
	var technique_chance: float = 0.40 if was_elite else 0.20
	var material_chance: float = 0.55 if was_elite else 0.35
	var bonus_material_chance: float = 0.30 if was_elite else 0.0
	if rng.randf() < treasure_chance:
		var treasure_quality: String = _quality_by_rank(rng.randi_range(min_rank, max_rank))
		var treasure: Dictionary = generate_treasure_for_player(player, treasure_quality)
		loot_lines.append(player.player_name + "夺得法宝掉落：" + _store_equipment_item(player, "treasure", treasure))
	if rng.randf() < technique_chance:
		var technique_quality: String = _quality_by_rank(rng.randi_range(min_rank, max_rank))
		loot_lines.append(player.player_name + "夺得功法掉落：" + _grant_technique_reward(player, technique_quality))
	if rng.randf() < material_chance:
		var material_type: String = "alchemy" if rng.randf() < 0.5 else "craft"
		var material_quality: String = _quality_by_rank(rng.randi_range(min_rank, max_rank))
		var material_label: String = "灵草" if material_type == "alchemy" else "矿材"
		loot_lines.append(player.player_name + "搜得" + material_label + "：" + _store_material_item(player, material_type, material_quality))
	if rng.randf() < bonus_material_chance:
		var bonus_material_type: String = "alchemy" if rng.randf() < 0.5 else "craft"
		var bonus_material_quality: String = _quality_by_rank(rng.randi_range(min_rank, max_rank))
		var bonus_material_label: String = "灵草" if bonus_material_type == "alchemy" else "矿材"
		loot_lines.append(player.player_name + "额外搜得" + bonus_material_label + "：" + _store_material_item(player, bonus_material_type, bonus_material_quality))

	var amount: int = 80 + _quality_rank(quality) * 45 + elite_bonus * 70
	player.ling_shi += amount
	loot_lines.append(player.player_name + "搜得战利品，灵石 +" + str(amount))
	return "；".join(loot_lines)


func on_battle_update(data: Dictionary) -> void:
	current_enemy = data.get("enemy", current_enemy) as Dictionary
	_apply_player_snapshot(player_a, data.get("player_a", {}) as Dictionary)
	_apply_player_snapshot(player_b, data.get("player_b", {}) as Dictionary)
	battle_log = data.get("battle_log", battle_log) as Array
	battle_escaped_peers = (data.get("battle_escaped_peers", battle_escaped_peers) as Dictionary).duplicate(true)
	battle_updated.emit(data)


func on_battle_end(data: Dictionary) -> void:
	if data.has("reward_lines") or data.has("battle_reward_title"):
		pending_battle_reward_feedback = data.duplicate(true)
	on_battle_update(data)
	battle_ended.emit(data)


func on_battle_continue_received(peer_id: int, _data: Dictionary = {}) -> void:
	if not NetworkManager.is_host:
		return
	var continue_peer_id: int = peer_id
	if continue_peer_id <= 0:
		continue_peer_id = 1
	battle_continue_votes[continue_peer_id] = true
	if single_player_mode and continue_peer_id == player_a.peer_id and not battle_continue_votes.has(player_b.peer_id):
		battle_continue_votes[player_b.peer_id] = true
	var total_required: int = _lottery_energy_required_count()
	if battle_continue_votes.size() < total_required:
		return
	battle_continue_votes.clear()
	change_state(GameState.BARGAIN)
	_resume_lottery_after_battle()


func pop_battle_reward_feedback() -> Dictionary:
	var data: Dictionary = pending_battle_reward_feedback.duplicate(true)
	pending_battle_reward_feedback.clear()
	return data


func _resume_lottery_after_battle() -> void:
	await get_tree().create_timer(1.6).timeout
	if not NetworkManager.is_host:
		return
	if current_state != GameState.BARGAIN:
		return
	if current_card_index >= 0 and current_card_index < current_lottery_cards.size():
		_reveal_card_for_bargain(current_card_index)
	else:
		_finish_round_without_rest()


func _battle_state_data(extra: Dictionary = {}) -> Dictionary:
	var data: Dictionary = {
		"enemy": current_enemy.duplicate(true),
		"player_a": _player_snapshot(player_a),
		"player_b": _player_snapshot(player_b),
		"battle_contributions": battle_contributions.duplicate(true),
		"battle_escaped_peers": battle_escaped_peers.duplicate(true),
		"battle_log": battle_log.duplicate(true),
	}
	data.merge(extra, true)
	return data


func _get_player_max_hp(player: PlayerData) -> int:
	var hp_bonus: float = _sum_player_bonus(player, "气血上限")
	hp_bonus += _body_school_hp_bonus(player)
	hp_bonus += _emotion_school_hp_bonus(player)
	return maxi(1, int(round(100.0 * (1.0 + float(player.stats.get("体魄", 0)) * 0.04 + hp_bonus))))


func _heal_player_percent(player: PlayerData, pct: float) -> int:
	if player == null or pct <= 0.0:
		return 0
	var max_hp: int = _get_player_max_hp(player)
	var heal_amount: int = maxi(1, int(round(float(max_hp) * pct)))
	var old_hp: int = player.qi_xue
	player.qi_xue = mini(max_hp, player.qi_xue + heal_amount)
	if player.qi_xue > old_hp:
		_grow_treasure_for_cultivation(player, "丹修", 1)
		var dan_level: int = _cultivation_route_level(player, "丹修")
		if dan_level >= 1:
			player.final_attributes["dan_life_reserve"] = clampi(int(player.final_attributes.get("dan_life_reserve", 0)) + 1, 0, 3 + dan_level)
	return heal_amount


func _heal_player_to_full(player: PlayerData) -> void:
	if player == null:
		return
	var old_hp: int = player.qi_xue
	player.qi_xue = _get_player_max_hp(player)
	if player.qi_xue > old_hp:
		_grow_treasure_for_cultivation(player, "丹修", 1)
		var dan_level: int = _cultivation_route_level(player, "丹修")
		if dan_level >= 1:
			player.final_attributes["dan_life_reserve"] = clampi(int(player.final_attributes.get("dan_life_reserve", 0)) + 1, 0, 3 + dan_level)


func _apply_round_end_grace() -> String:
	var heal_a: int = _heal_player_percent(player_a, 0.05)
	var heal_b: int = _heal_player_percent(player_b, 0.05)
	var message: String = "天道恩泽：" + player_a.player_name + "气血+" + str(heal_a) + "，" + player_b.player_name + "气血+" + str(heal_b)
	player_a.final_attributes["last_round_grace"] = message
	player_b.final_attributes["last_round_grace"] = message
	return message


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


func _generate_bounty_task() -> Dictionary:
	var task: Dictionary = (BOUNTY_TASK_POOL[rng.randi_range(0, BOUNTY_TASK_POOL.size() - 1)] as Dictionary).duplicate(true)
	var duration: int = rng.randi_range(1, 2)
	task["duration"] = duration
	task["taken_round"] = round_number
	task["expires_round"] = round_number + duration
	task["completed"] = false
	return task


func _grant_bounty_task(player: PlayerData, card: Dictionary) -> String:
	if player == null:
		return "悬赏令无人可接"
	var task: Dictionary = (card.get("quest", {}) as Dictionary).duplicate(true)
	if task.is_empty():
		task = _generate_bounty_task()
	task["taken_round"] = round_number
	if not task.has("expires_round"):
		task["expires_round"] = round_number + int(task.get("duration", rng.randi_range(1, 2)))
	task["completed"] = false
	player.active_tasks.append(task)
	return "接下悬赏【" + str(task.get("name", "未知任务")) + "】：" + str(task.get("desc", "待完成"))


func _expire_active_tasks(player: PlayerData) -> void:
	if player == null:
		return
	var remaining: Array = []
	for task_item in player.active_tasks:
		if not task_item is Dictionary:
			continue
		var task: Dictionary = task_item as Dictionary
		if bool(task.get("completed", false)):
			continue
		if int(task.get("expires_round", round_number)) < round_number:
			continue
		remaining.append(task)
	player.active_tasks = remaining


func _complete_active_tasks(player: PlayerData, trigger: String, context: Dictionary = {}) -> String:
	if player == null or player.active_tasks.is_empty():
		return ""
	var messages: Array[String] = []
	var remaining: Array = []
	for task_item in player.active_tasks:
		if not task_item is Dictionary:
			continue
		var task: Dictionary = task_item as Dictionary
		if bool(task.get("completed", false)) or int(task.get("expires_round", round_number)) < round_number:
			continue
		if str(task.get("trigger", "")) != trigger:
			remaining.append(task)
			continue
		var message: String = _apply_bounty_task_reward(player, task, context)
		if message != "":
			messages.append(message)
		task["completed"] = true
	player.active_tasks = remaining
	return "；".join(messages)


func _apply_bounty_task_reward(player: PlayerData, task: Dictionary, context: Dictionary) -> String:
	var task_name: String = str(task.get("name", "悬赏"))
	match str(task.get("id", "")):
		"beast_core":
			var stone_reward: int = int(task.get("reward_ling_shi", 500))
			player.ling_shi += stone_reward
			return "悬赏完成【" + task_name + "】，灵石 +" + str(stone_reward)
		"spirit_herb":
			var max_hp: int = int(context.get("max_hp", _get_player_max_hp(player)))
			var heal_amount: int = maxi(1, int(round(float(max_hp) * float(task.get("bonus_heal_pct", 0.20)))))
			player.qi_xue = mini(max_hp, player.qi_xue + heal_amount)
			return "悬赏完成【" + task_name + "】，额外回血 +" + str(heal_amount)
		"escort_friend":
			var stone_reward: int = 300
			player.ling_shi += stone_reward
			return "悬赏完成【" + task_name + "】，灵石 +" + str(stone_reward)
		"duel_trial":
			var duel_reward: int = int(task.get("reward_ling_shi", 1000))
			player.ling_shi += duel_reward
			return "悬赏完成【" + task_name + "】，灵石 +" + str(duel_reward)
	return ""


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

	return false


func _consume_breakthrough_dan(player: PlayerData, dan_name: String) -> bool:
	if dan_name == "":
		return true
	if player == null:
		return false
	var dans: Array = player.final_attributes.get("dans", []) as Array
	if dans.has(dan_name):
		dans.erase(dan_name)
		player.final_attributes["dans"] = dans
		return true
	for i in range(player.backpack.size()):
		if not player.backpack[i] is Dictionary:
			continue
		var entry: Dictionary = player.backpack[i] as Dictionary
		var item_data: Dictionary = entry.get("data", {}) as Dictionary
		if str(item_data.get("name", "")) == dan_name:
			player.backpack.remove_at(i)
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
			result["reason"] = "突破修为不足：" + str(player.ling_li) + " / " + str(minor_req)
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

	if current_state == GameState.REST or current_state == GameState.AUCTION or current_state == GameState.TRIBULATION or current_state == GameState.BATTLE or current_state == GameState.DUEL or current_state == GameState.SECT_EVENT or current_state == GameState.ENDING:
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

	var cost: int = get_next_breakthrough_req(player)
	var chance: float = get_breakthrough_success_chance(player, "minor")
	if rng.randf() > chance:
		var fail_data: Dictionary = _apply_breakthrough_failure(player, "minor")
		var fail_message: String = player.player_name + "冲击" + target_name + "失败，修为 -" + str(int(fail_data.get("ling_li_loss", 0))) + "，气血 -" + str(int(fail_data.get("hp_damage", 0)))
		var fail_feedback: Dictionary = _breakthrough_feedback_data(peer_id, fail_message)
		NetworkManager.send_message("breakthrough_feedback", fail_feedback)
		on_breakthrough_feedback(fail_feedback)
		return

	var spent: int = _spend_breakthrough_ling_li(player, cost)
	player.minor_stage = clampi(player.minor_stage + 1, 1, MINOR_STAGE_NAMES.size())
	_heal_player_to_full(player)
	var life_reward: int = _apply_breakthrough_life_reward(player, "minor")
	var reached_name: String = get_cultivation_stage_name(player)
	var message: String = player.player_name + "突破至" + (target_name if target_name != "" else reached_name) + "，消耗修为 " + str(spent) + "，寿元 +" + str(life_reward) + "，成功率 " + str(int(round(chance * 100.0))) + "%"
	var sword_growth_message: String = _grow_treasure_for_cultivation(player, "剑修", 5)
	if sword_growth_message != "":
		message += "；" + sword_growth_message
	var technique_message: String = _grow_techniques_for_cultivation(player, "剑修", 1, "破境悟剑")
	if technique_message != "":
		message += "；" + technique_message
	var data: Dictionary = _breakthrough_feedback_data(peer_id, message)
	NetworkManager.send_message("breakthrough_feedback", data)
	on_breakthrough_feedback(data)
	check_duel_trigger()


func _apply_breakthrough_life_reward(player: PlayerData, breakthrough_type: String) -> int:
	if player == null:
		return 0
	var ti_po: int = int(player.stats.get("体魄", 0))
	var reward: int = 1
	if breakthrough_type == "major":
		reward = 3 + int(floor(float(ti_po) / 4.0))
	else:
		reward = 1 + int(floor(float(ti_po) / 8.0))
	reward = maxi(1, reward)
	player.shou_yuan += reward
	return reward


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
	_auto_save("breakthrough")


func check_breakthrough() -> void:
	if not NetworkManager.is_host:
		return
	_advance_after_round_end(true)


func _try_queue_npc_breakthrough() -> bool:
	if not single_player_mode or player_b == null:
		return false
	if current_state == GameState.REST or current_state == GameState.AUCTION or current_state == GameState.TRIBULATION or current_state == GameState.BATTLE or current_state == GameState.DUEL or current_state == GameState.SECT_EVENT or current_state == GameState.ENDING:
		return false
	var status: Dictionary = get_breakthrough_status(player_b)
	if not bool(status.get("can", false)):
		return false
	if not _npc_should_attempt_breakthrough(status):
		return false
	_queue_npc_breakthrough()
	return true


func _queue_npc_breakthrough() -> void:
	if not single_player_mode or player_b == null:
		return
	push_npc_dialogue("breakthrough")
	await get_tree().create_timer(0.85).timeout
	if not single_player_mode or player_b == null:
		return
	if current_state == GameState.REST or current_state == GameState.AUCTION or current_state == GameState.TRIBULATION or current_state == GameState.BATTLE or current_state == GameState.DUEL or current_state == GameState.SECT_EVENT or current_state == GameState.ENDING:
		return
	var status: Dictionary = get_breakthrough_status(player_b)
	if not bool(status.get("can", false)):
		_start_next_round_for_all()
		return
	if not _npc_should_attempt_breakthrough(status):
		_start_next_round_for_all()
		return

	request_breakthrough(player_b.peer_id)
	await get_tree().create_timer(1.15).timeout
	if not single_player_mode:
		return
	if current_state == GameState.TRIBULATION or current_state == GameState.DUEL or current_state == GameState.SECT_EVENT or current_state == GameState.ENDING:
		return
	_start_next_round_for_all()


func _npc_should_attempt_breakthrough(status: Dictionary) -> bool:
	if player_b == null:
		return false
	var hp_rate: float = float(player_b.qi_xue) / float(maxi(1, _get_player_max_hp(player_b)))
	var breakthrough_type: String = str(status.get("type", ""))
	var chance: float = float(status.get("success_chance", get_breakthrough_success_chance(player_b, breakthrough_type)))
	match breakthrough_type:
		"minor":
			return hp_rate >= 0.38 and chance >= 0.46
		"major":
			return hp_rate >= 0.70 and chance >= 0.48
		"duel":
			return true
		_:
			return hp_rate >= 0.50


func _start_breakthrough(player: PlayerData, next_realm: String) -> void:
	if player == null or next_realm == "":
		return

	pending_breakthrough_player = player
	tribulation_next_realm = next_realm
	pending_tribulation_data = (TRIBULATIONS[next_realm] as Dictionary).duplicate(true)
	pending_tribulation_data["player_name"] = player.player_name
	pending_tribulation_data["player_peer_id"] = player.peer_id
	pending_tribulation_data["next_realm"] = next_realm
	pending_tribulation_data["ling_li_req"] = get_realm_ling_li_req(next_realm)
	bargain_choices.clear()
	bargain_continue_votes.clear()
	tribulation_choices.clear()
	change_state(GameState.TRIBULATION)
	tribulation_triggered.emit(pending_tribulation_data)
	if not single_player_mode:
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


func _apply_treasure_growth_from_tribulation(player: PlayerData, own_choice: String, other_choice: String) -> String:
	if player == null:
		return ""
	var treasure: Dictionary = _get_equipped_treasure(player)
	var amount: int = 0
	if not treasure.is_empty():
		_prepare_treasure(treasure, _player_sect(player))
		match _treasure_growth_type(treasure):
			"体修":
				if own_choice == "扛":
					amount += 3
			"情修":
				if own_choice == "扛":
					amount += 2
			"阵修":
				if own_choice == "扛" and other_choice == "扛":
					amount += 3
				elif own_choice == "扛":
					amount += 2
	var messages: Array[String] = []
	var treasure_message: String = grow_treasure(player, amount)
	if treasure_message != "":
		messages.append(treasure_message)
	if own_choice == "扛":
		var formation_amount: int = 2 if other_choice == "扛" else 1
		var formation_message: String = _grow_techniques_for_cultivation(player, "阵修", formation_amount, "扛劫布阵")
		if formation_message != "":
			messages.append(formation_message)
		var body_message: String = _grow_techniques_for_cultivation(player, "体修", 1, "雷劫淬体")
		if body_message != "":
			messages.append(body_message)
	else:
		var talisman_message: String = _grow_techniques_for_cultivation(player, "符修", 1, "避劫藏符")
		if talisman_message != "":
			messages.append(talisman_message)
	return "；".join(messages)


func _apply_companion_bond_from_tribulation(player: PlayerData, own_choice: String) -> String:
	if player == null:
		return ""
	if own_choice == "扛":
		return _grow_companion_bonds_for_event(player, "bear_tribulation")
	if own_choice == "躲":
		return _grow_companion_bonds_for_event(player, "dodge_tribulation")
	return ""


func settle_tribulation(peer_id: int, choice: String) -> void:
	if not NetworkManager.is_host:
		return
	if pending_breakthrough_player == null:
		return

	var choice_peer_id: int = peer_id
	if choice_peer_id <= 0:
		choice_peer_id = 1
	tribulation_choices[choice_peer_id] = choice
	if single_player_mode and choice_peer_id == player_a.peer_id and not tribulation_choices.has(player_b.peer_id):
		_queue_npc_tribulation_choice()
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

	_apply_tribulation_damage(pending_breakthrough_player, breakthrough_damage_pct, breakthrough_choice, other_choice)
	_apply_tribulation_damage(other_player, other_damage_pct, other_choice, breakthrough_choice)
	pending_breakthrough_player.ling_li += breakthrough_reward
	other_player.ling_li += other_reward
	pending_breakthrough_player.tribulation_choices.append(tribulation_choices.duplicate(true))
	other_player.tribulation_choices.append(tribulation_choices.duplicate(true))
	var tribulation_growth_messages: Array[String] = []
	var breakthrough_growth_message: String = _apply_treasure_growth_from_tribulation(pending_breakthrough_player, breakthrough_choice, other_choice)
	if breakthrough_growth_message != "":
		tribulation_growth_messages.append(pending_breakthrough_player.player_name + "：" + breakthrough_growth_message)
	var other_growth_message: String = _apply_treasure_growth_from_tribulation(other_player, other_choice, breakthrough_choice)
	if other_growth_message != "":
		tribulation_growth_messages.append(other_player.player_name + "：" + other_growth_message)
	var breakthrough_companion_message: String = _apply_companion_bond_from_tribulation(pending_breakthrough_player, breakthrough_choice)
	if breakthrough_companion_message != "":
		tribulation_growth_messages.append(pending_breakthrough_player.player_name + "：" + breakthrough_companion_message)
	var other_companion_message: String = _apply_companion_bond_from_tribulation(other_player, other_choice)
	if other_companion_message != "":
		tribulation_growth_messages.append(other_player.player_name + "：" + other_companion_message)

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

	var npc_rescue_message: String = _single_player_npc_tribulation_rescue()
	if npc_rescue_message != "":
		tribulation_growth_messages.append(npc_rescue_message)
		result["player_a"] = _player_snapshot(player_a)
		result["player_b"] = _player_snapshot(player_b)

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
		if not tribulation_growth_messages.is_empty():
			result["message"] += "；" + "；".join(tribulation_growth_messages)
		result["player_a"] = _player_snapshot(player_a)
		result["player_b"] = _player_snapshot(player_b)
		NetworkManager.send_message("tribulation_result", result)
		on_tribulation_result(result)
		_clear_pending_tribulation_state()

		await get_tree().create_timer(2.0).timeout
		_start_next_round_for_all()
		return

	var realm_data: Dictionary = REALMS[tribulation_next_realm] as Dictionary
	var breakthrough_cost: int = int(pending_tribulation_data.get("ling_li_req", get_realm_ling_li_req(tribulation_next_realm)))
	var spent_ling_li: int = _spend_breakthrough_ling_li(pending_breakthrough_player, breakthrough_cost)
	var dan_name: String = str(realm_data.get("dan", ""))
	_consume_breakthrough_dan(pending_breakthrough_player, dan_name)
	pending_breakthrough_player.realm = tribulation_next_realm
	pending_breakthrough_player.minor_stage = 1
	pending_breakthrough_player.speed = int(realm_data.get("speed_base", 10)) + int(pending_breakthrough_player.stats.get("身法", 0)) * 6
	_heal_player_to_full(pending_breakthrough_player)
	var life_reward: int = _apply_breakthrough_life_reward(pending_breakthrough_player, "major")
	result["success"] = true
	result["success_chance"] = breakthrough_chance
	result["message"] = pending_breakthrough_player.player_name + "突破至" + tribulation_next_realm + "，消耗修为 " + str(spent_ling_li) + "，寿元 +" + str(life_reward) + "，成功率 " + str(int(round(breakthrough_chance * 100.0))) + "%"
	var major_sword_growth_message: String = _grow_treasure_for_cultivation(pending_breakthrough_player, "剑修", 5)
	if major_sword_growth_message != "":
		tribulation_growth_messages.append(pending_breakthrough_player.player_name + "：" + major_sword_growth_message)
	var major_technique_message: String = _grow_techniques_for_cultivation(pending_breakthrough_player, "剑修", 2, "破大境悟剑")
	if major_technique_message != "":
		tribulation_growth_messages.append(pending_breakthrough_player.player_name + "：" + major_technique_message)
	if not tribulation_growth_messages.is_empty():
		result["message"] += "；" + "；".join(tribulation_growth_messages)
	result["player_a"] = _player_snapshot(player_a)
	result["player_b"] = _player_snapshot(player_b)
	NetworkManager.send_message("tribulation_result", result)
	on_tribulation_result(result)
	_clear_pending_tribulation_state()

	await get_tree().create_timer(2.0).timeout
	if check_duel_trigger():
		return
	_start_next_round_for_all()


func on_tribulation_result(data: Dictionary) -> void:
	_apply_player_snapshot(player_a, data.get("player_a", {}) as Dictionary)
	_apply_player_snapshot(player_b, data.get("player_b", {}) as Dictionary)
	tribulation_settled.emit(data)
	_auto_save("tribulation")


func _single_player_npc_tribulation_rescue() -> String:
	if not single_player_mode or player_b == null or current_state != GameState.TRIBULATION:
		return ""
	if player_b.qi_xue > 0:
		return ""
	player_b.qi_xue = maxi(1, int(round(float(_get_player_max_hp(player_b)) * 0.10)))
	player_b.ling_li = maxi(0, player_b.ling_li - 30)
	return player_b.player_name + "护身符碎裂，吊住一口气"


func handle_player_death(dead_player: PlayerData, result: Dictionary = {}) -> void:
	if current_state == GameState.ENDING:
		return

	if current_state == GameState.DUEL:
		var alive_player: PlayerData = _get_alive_player_for_death(dead_player)
		var final_dead_player: PlayerData = player_b if alive_player == player_a else player_a
		alive_player.final_attributes["final_choice"] = "踏入仙门"
		final_dead_player.final_attributes["final_choice"] = "败于仙争"
		trigger_ending(alive_player, final_dead_player)
		return

	var other_player: PlayerData = player_b if dead_player == player_a else player_a
	if player_a.qi_xue <= 0 and player_b.qi_xue <= 0:
		player_a.final_attributes["final_choice"] = "同途俱灭"
		player_b.final_attributes["final_choice"] = "同途俱灭"
	else:
		dead_player.final_attributes["final_choice"] = "中道陨落"
		other_player.final_attributes["final_choice"] = "同修陨落"
	result["message"] = "一人气血断绝，二人道途俱断。仙路未至终局，已先败给生死。"
	result["player_a"] = _player_snapshot(player_a)
	result["player_b"] = _player_snapshot(player_b)
	trigger_mutual_failure(dead_player, other_player, result)


func _get_alive_player_for_death(dead_player: PlayerData) -> PlayerData:
	var other_player: PlayerData = player_b if dead_player == player_a else player_a
	if other_player != null and other_player.qi_xue > 0:
		return other_player
	if dead_player != null and dead_player.qi_xue > 0:
		return dead_player
	if player_a.ling_li != player_b.ling_li:
		return player_a if player_a.ling_li > player_b.ling_li else player_b
	return player_a if player_a.shou_yuan >= player_b.shou_yuan else player_b


func _try_trigger_death_ending() -> bool:
	if current_state == GameState.ENDING:
		return true
	if player_a == null or player_b == null:
		return false
	if player_a.qi_xue <= 0:
		handle_player_death(player_a)
		return true
	if player_b.qi_xue <= 0:
		handle_player_death(player_b)
		return true
	return false


func trigger_mutual_failure(dead_player: PlayerData, other_player: PlayerData, result: Dictionary = {}) -> void:
	if dead_player == null or other_player == null:
		return
	var dead_scroll: Dictionary = generate_scroll_data(dead_player, false, other_player)
	var other_scroll: Dictionary = generate_scroll_data(other_player, false, dead_player)
	var data: Dictionary = {
		"mutual_failure": true,
		"death_peer_id": dead_player.peer_id,
		"message": str(result.get("message", "一人陨落，二人同败。")),
		"scrolls": {
			str(dead_player.peer_id): dead_scroll,
			str(other_player.peer_id): other_scroll,
		},
	}
	change_state(GameState.ENDING)
	if not single_player_mode:
		_show_ending.rpc(data)
	ending_scroll_data = _select_ending_scroll_data(data)
	transition_to_scene("res://scenes/ending.tscn")


func _apply_tribulation_damage(player: PlayerData, pct: float, own_choice: String = "", other_choice: String = "") -> void:
	if pct <= 0.0:
		return
	var final_pct: float = pct
	var reduction: float = 0.0
	if own_choice == "扛":
		reduction += _identity_passive_value(player, "金刚寺")
		var body_level: int = _cultivation_route_level(player, "体修")
		if body_level >= 1:
			reduction += 0.05 + float(body_level) * 0.03
		var formation_level: int = _cultivation_route_level(player, "阵修")
		if formation_level >= 1:
			reduction += 0.06 + float(formation_level) * (0.03 if other_choice == "扛" else 0.02)
		if other_choice == "扛":
			reduction += _identity_passive_value(player, "阵宗")
	reduction = clampf(reduction, 0.0, 0.90)
	final_pct *= 1.0 - reduction
	player.qi_xue = maxi(0, player.qi_xue - int(player.qi_xue * final_pct))


func _player_snapshot(player: PlayerData) -> Dictionary:
	_normalize_player_technique_inventory(player)
	_cleanup_duplicate_techniques(player)
	check_set_bonus(player)
	return {
		"player_name": player.player_name,
		"peer_id": player.peer_id,
		"sect": player.sect,
		"resonance_level": player.resonance_level,
		"resonance_bonus": player.resonance_bonus,
		"companion_bond": player.companion_bond,
		"active_tasks": player.active_tasks,
		"stats": player.stats,
		"remain_points": player.remain_points,
		"shou_yuan": player.shou_yuan,
		"ling_li": player.ling_li,
		"ling_shi": player.ling_shi,
		"qi_xue": player.qi_xue,
		"attack": player.attack,
		"defense": player.defense,
		"speed": player.speed,
		"realm": player.realm,
		"minor_stage": player.minor_stage,
		"technique_slots": player.technique_slots,
		"techniques": player.techniques,
		"treasures": player.treasures,
		"backpack": player.backpack,
		"backpack_capacity": player.backpack_capacity,
		"companions": player.companions,
		"final_attributes": player.final_attributes,
		"total_ji_yuan_gained": player.total_ji_yuan_gained,
		"total_calamity_taken": player.total_calamity_taken,
		"total_qiang_count": player.total_qiang_count,
		"total_rang_count": player.total_rang_count,
		"total_shuang_rang": player.total_shuang_rang,
		"total_shuang_qiang": player.total_shuang_qiang,
		"qiang_streak": player.qiang_streak,
		"karmic_debt": player.karmic_debt,
		"forbearance": player.forbearance,
		"tribulation_choices": player.tribulation_choices,
		"ji_yuan_list": player.ji_yuan_list,
		"calamity_list": player.calamity_list,
		"duel_rounds": player.duel_rounds,
	}


func _apply_player_snapshot(player: PlayerData, data: Dictionary) -> void:
	if player == null or data.is_empty():
		return
	player.player_name = str(data.get("player_name", player.player_name))
	player.peer_id = int(data.get("peer_id", player.peer_id))
	player.sect = str(data.get("sect", player.sect))
	player.resonance_level = int(data.get("resonance_level", player.resonance_level))
	player.resonance_bonus = (data.get("resonance_bonus", player.resonance_bonus) as Dictionary).duplicate(true)
	player.companion_bond = (data.get("companion_bond", player.companion_bond) as Dictionary).duplicate(true)
	player.active_tasks = (data.get("active_tasks", player.active_tasks) as Array).duplicate(true)
	var incoming_stats: Dictionary = data.get("stats", player.stats) as Dictionary
	player.stats = _normalize_stats(incoming_stats)
	player.remain_points = int(data.get("remain_points", player.remain_points))
	player.shou_yuan = int(data.get("shou_yuan", player.shou_yuan))
	player.ling_li = int(data.get("ling_li", player.ling_li))
	player.ling_shi = int(data.get("ling_shi", player.ling_shi))
	player.qi_xue = int(data.get("qi_xue", player.qi_xue))
	player.attack = int(data.get("attack", player.attack))
	player.defense = int(data.get("defense", player.defense))
	player.speed = int(data.get("speed", player.speed))
	player.realm = str(data.get("realm", player.realm))
	player.minor_stage = clampi(int(data.get("minor_stage", player.minor_stage)), 1, MINOR_STAGE_NAMES.size())
	player.technique_slots = MAX_EQUIPPED_TECHNIQUES
	player.techniques = data.get("techniques", player.techniques).duplicate(true)
	player.treasures = data.get("treasures", player.treasures).duplicate(true)
	player.backpack = data.get("backpack", player.backpack).duplicate(true)
	player.backpack_capacity = get_total_backpack_capacity()
	player.companions = data.get("companions", player.companions).duplicate(true)
	player.final_attributes = data.get("final_attributes", player.final_attributes).duplicate(true)
	player.total_ji_yuan_gained = int(data.get("total_ji_yuan_gained", player.total_ji_yuan_gained))
	player.total_calamity_taken = int(data.get("total_calamity_taken", player.total_calamity_taken))
	player.total_qiang_count = int(data.get("total_qiang_count", player.total_qiang_count))
	player.total_rang_count = int(data.get("total_rang_count", player.total_rang_count))
	player.total_shuang_rang = int(data.get("total_shuang_rang", player.total_shuang_rang))
	player.total_shuang_qiang = int(data.get("total_shuang_qiang", player.total_shuang_qiang))
	player.qiang_streak = int(data.get("qiang_streak", player.qiang_streak))
	player.karmic_debt = int(data.get("karmic_debt", player.karmic_debt))
	player.forbearance = int(data.get("forbearance", player.forbearance))
	player.tribulation_choices = (data.get("tribulation_choices", player.tribulation_choices) as Array).duplicate(true)
	player.ji_yuan_list = (data.get("ji_yuan_list", player.ji_yuan_list) as Array).duplicate(true)
	player.calamity_list = (data.get("calamity_list", player.calamity_list) as Array).duplicate(true)
	player.duel_rounds = (data.get("duel_rounds", player.duel_rounds) as Array).duplicate(true)
	_normalize_player_technique_inventory(player)


func _get_scroll_affix_stats(player: PlayerData) -> Dictionary:
	var sect_counts: Dictionary = {}
	var cultivation_counts: Dictionary = {}
	if player == null:
		return {"门派词条": sect_counts, "修词条": cultivation_counts}
	var cultivation_items: Array = []
	cultivation_items.append_array(player.techniques)
	cultivation_items.append_array(player.treasures)
	for item in cultivation_items:
		if not item is Dictionary:
			continue
		var data: Dictionary = item as Dictionary
		var cultivation_tag: String = _item_cultivation_tag(data)
		if cultivation_tag != "":
			cultivation_counts[cultivation_tag] = int(cultivation_counts.get(cultivation_tag, 0)) + 1
	for companion in player.companions:
		if not companion is Dictionary:
			continue
		var companion_data: Dictionary = companion as Dictionary
		var sect_tag: String = _item_sect_tag(companion_data)
		if sect_tag != "":
			sect_counts[sect_tag] = int(sect_counts.get(sect_tag, 0)) + 1
	return {"门派词条": sect_counts, "修词条": cultivation_counts}


func _strongest_technique_name(player: PlayerData) -> String:
	if player == null or player.techniques.is_empty():
		return "无"
	var best: Dictionary = {}
	var best_score: int = -1
	for technique in player.techniques:
		if not technique is Dictionary:
			continue
		var data: Dictionary = technique as Dictionary
		var realm_score: int = 0
		match str(data.get("technique_realm", "初窥")):
			"小成":
				realm_score = 1
			"大成":
				realm_score = 2
		var score: int = _quality_rank(str(data.get("quality", "炼气级"))) * 10 + realm_score
		if score > best_score:
			best_score = score
			best = data
	if best.is_empty():
		return "无"
	return quality_display_name(str(best.get("quality", ""))) + "·" + str(best.get("name", "无名功法"))


func _awakened_treasure_name(player: PlayerData) -> String:
	if player == null:
		return "无"
	var best: Dictionary = {}
	var best_score: int = -1
	for treasure in player.treasures:
		if not treasure is Dictionary:
			continue
		var data: Dictionary = treasure as Dictionary
		if int(data.get("awakening_level", 0)) <= 0 and not bool(data.get("awakened", false)):
			continue
		var score: int = _quality_rank(str(data.get("quality", "炼气级"))) * 100 + int(data.get("growth_value", 0))
		if score > best_score:
			best_score = score
			best = data
	if best.is_empty():
		return "无"
	return quality_display_name(str(best.get("quality", ""))) + "·" + str(best.get("name", "无名法宝"))


func _closest_companion_name(player: PlayerData) -> String:
	if player == null or player.companions.is_empty():
		return "无"
	var best: Dictionary = {}
	var best_bond: int = -1
	for companion in player.companions:
		if not companion is Dictionary:
			continue
		var data: Dictionary = companion as Dictionary
		var bond: int = int(data.get("bond", 0))
		if bond > best_bond:
			best_bond = bond
			best = data
	if best.is_empty():
		return "无"
	return str(best.get("name", "无名同道")) + "（羁绊" + str(best_bond) + "）"


func _make_immortal_record(player: PlayerData, is_winner: bool, final_blow: String) -> Dictionary:
	if player == null:
		return {}
	check_set_bonus(player)
	var sect_name: String = str(player.final_attributes.get("identity_sect", "散修"))
	var cultivation_type: String = str(player.final_attributes.get("cultivation_type", "散修"))
	var identity: String = get_identity_level_short(int(player.final_attributes.get("identity_level", 0)))
	return {
		"timestamp": Time.get_datetime_string_from_system(false, true),
		"name": player.player_name,
		"sect": sect_name,
		"cultivation": cultivation_type,
		"identity": identity,
		"is_winner": is_winner,
		"total_qiang": player.total_qiang_count,
		"total_rang": player.total_rang_count,
		"strongest_technique": _strongest_technique_name(player),
		"awakened_treasure": _awakened_treasure_name(player),
		"closest_companion": _closest_companion_name(player),
		"final_blow": final_blow,
	}


func generate_scroll_data(player: PlayerData, is_winner: bool, opponent: PlayerData) -> Dictionary:
	var title: String = _get_life_title(player)
	var opponent_title: String = _get_life_title(opponent)
	var final_stats: Dictionary = calculate_duel_stats(player)
	var key_rounds: String = _get_key_duel_rounds(player)
	var final_blow: String = _get_final_blow(player)
	var final_choice_desc: String = _get_final_choice_desc(player, is_winner)
	var life_story: Dictionary = _generate_life_story(player, is_winner, opponent, final_stats, title, final_choice_desc)
	var affix_stats: Dictionary = _get_scroll_affix_stats(player)
	var immortal_record: Dictionary = _make_immortal_record(player, is_winner, final_blow)
	return {
		"is_winner": is_winner,
		"verdict": _get_life_verdict(player, is_winner),
		"仙册": immortal_record,
		"故事": life_story,
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
			"sect_affixes": (affix_stats.get("门派词条", {}) as Dictionary).duplicate(true),
			"cultivation_affixes": (affix_stats.get("修词条", {}) as Dictionary).duplicate(true),
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
	if not single_player_mode:
		_show_ending.rpc(data)
	ending_scroll_data = _select_ending_scroll_data(data)
	if single_player_mode:
		transition_to_scene("res://scenes/ending.tscn")


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
	single_player_mode = false
	selected_npc_profile.clear()
	npc_last_dialogue = ""
	current_state = GameState.STAT_ALLOCATION
	round_number = 0
	player_a = PlayerData.new()
	player_a.player_name = "道友甲"
	player_b = PlayerData.new()
	player_b.player_name = "道友乙"
	current_lottery_results.clear()
	current_lottery_cards.clear()
	current_card_index = 0
	lottery_energy_injections.clear()
	lottery_energy_started = false
	current_bargain_index = 0
	current_enemy.clear()
	enemy_elite = false
	loaded_game_pending_resume = false
	current_auction.clear()
	auction_choices.clear()
	battle_contributions.clear()
	battle_choices.clear()
	battle_escaped_peers.clear()
	battle_log.clear()
	battle_continue_votes.clear()
	stat_allocation_started = false
	bargain_choices.clear()
	current_contest.clear()
	bargain_continue_votes.clear()
	pending_continue_next_index = -1
	pending_continue_round_finished = false
	pending_backpack_items.clear()
	rest_confirm_votes.clear()
	final_duel_after_rest = false
	lineup_locked = false
	scattered_pool.clear()
	round_started = false
	bargain_direction = 1
	pending_breakthrough_player = null
	tribulation_next_realm = ""
	pending_tribulation_data.clear()
	tribulation_choices.clear()
	duel_data.clear()
	duel_round_number = 0
	duel_mode = "final"
	duel_continue_votes.clear()
	pending_duel_winner_key = ""
	pending_duel_loser_key = ""
	current_sect_event.clear()
	sect_event_choices.clear()
	sect_event_continue_votes.clear()
	ending_scroll_data.clear()
	change_state(GameState.STAT_ALLOCATION)


func _get_life_verdict(player: PlayerData, is_winner: bool) -> String:
	var final_choice: String = str(player.final_attributes.get("final_choice", ""))
	if final_choice == "中道陨落":
		return "你未败于故人，却败给了半路的生死。仙门尚远，道途已断。"
	if final_choice == "同修陨落":
		return "你还活着，却没能把同修带到仙门前。道不同，终究也没能独行。"
	if final_choice == "同途俱灭":
		return "一场劫数吞没两条命数。你们没能走到反目的那一天。"
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
	if final_choice in ["中道陨落", "同修陨落", "同途俱灭"]:
		titles.append("道途俱断")
	elif final_choice == "放弃仙位":
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
	var identity: Dictionary = _refresh_companion_identity_scores(player)
	var best_score: int = int(identity.get("best_score", 0))
	if best_score >= 24:
		var best_alignment: String = str(identity.get("best_alignment", "正"))
		titles.append("正道知交" if best_alignment == "正" else "邪道同盟")
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
		if final_choice == "中道陨落":
			return "他倒在半路，你也没能独自抵达仙门。"
		if final_choice == "同修陨落":
			return "你倒下之后，他也失去了继续问道的资格。"
		if final_choice == "同途俱灭":
			return "你们同陷一劫，仙路在那一刻合上。"
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
		"中道陨落":
			return "你倒在仙路半途，未能见到最后的仙门。"
		"同修陨落":
			return "同修先你一步陨落，你虽未死，却也失去了继续独行的资格。"
		"同途俱灭":
			return "你们同陷死劫，没能走到最后翻脸争仙的那一步。"
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
		var companion_name: String = str(data.get("name", ""))
		data["fate"] = "随主飞升" if is_winner else "随主陨落"
		data["last_words"] = str(COMPANION_LAST_WORDS.get(companion_name, "仙路至此，各安天命。"))
		result.append(data)
	return result


func _generate_life_story(player: PlayerData, is_winner: bool, opponent: PlayerData, final_stats: Dictionary, title: String, final_choice_desc: String) -> Dictionary:
	var opponent_name: String = opponent.player_name if opponent != null else "故人"
	var school: String = _detect_player_school(player)
	var initial_life: int = int(player.final_attributes.get("initial_shou_yuan", calculate_initial_shou_yuan(player)))
	var best_ji_yuan: String = _get_best_record_desc(player.ji_yuan_list)
	var worst_calamity: String = _get_best_record_desc(player.calamity_list)
	var strongest_stat: String = _get_strongest_stat_name(player)
	var final_attack: int = int(final_stats.get("攻击力", 0))
	var final_hp: int = int(final_stats.get("气血", 0))

	return {
		"命起": "你以" + strongest_stat + "入道，凡寿" + str(initial_life) + "年。起初不过一介凡躯，却在第一口灵气里听见了自己的命数。",
		"行路": _story_choice_sentence(player) + "此后所得最重的一场机缘，是" + best_ji_yuan + "；最险的一次回头，是" + worst_calamity + "。",
		"道途": _story_school_sentence(player, school),
		"终局": "仙门将开时，你已修成" + title + "之名。攻伐" + str(final_attack) + "，气血" + str(final_hp) + "，与" + opponent_name + "在门前分出了最后一步。",
		"余声": final_choice_desc + _story_aftertaste(player, is_winner),
	}


func _get_strongest_stat_name(player: PlayerData) -> String:
	var strongest_stat: String = "体魄"
	var strongest_value: int = -1
	for stat in BASE_STATS:
		var value: int = int(player.stats.get(stat, 0))
		if value > strongest_value:
			strongest_stat = str(stat)
			strongest_value = value
	return strongest_stat


func _story_choice_sentence(player: PlayerData) -> String:
	var ratios: Dictionary = _get_choice_ratios(player)
	var qiang_ratio: float = float(ratios.get("qiang", 0.0))
	var rang_ratio: float = float(ratios.get("rang", 0.0))
	if qiang_ratio > 0.62:
		return "你一路多取少让，见机缘便出手，见灾厄便推开，硬是在乱局里夺出一条路。"
	if rang_ratio > 0.62:
		return "你一路多让少争，常把最险的位置留给自己，也因此在别人松懈处等到了天意。"
	return "你既争也让，遇强不莽，见利不怯，像是在乱局里慢慢摸清了天道的脾气。"


func _story_school_sentence(player: PlayerData, school: String) -> String:
	var technique_name: String = _story_top_technique_name(player)
	var treasure_name: String = _story_treasure_name(player)
	match school:
		"体修":
			var body_power: int = int(round(_school_power(player, "体修") * 10.0))
			return "你最后走成了体修一路，以《" + technique_name + "》打底，以" + treasure_name + "护身。筋骨一寸寸熬硬，炼体火候已至" + str(body_power) + "，越到残局越像一座推不倒的山。"
		"剑修":
			var sword: Dictionary = _find_growth_sword(player)
			var sword_text: String = "本命飞剑尚未成形"
			if not sword.is_empty():
				sword_text = "本命飞剑养至" + str(int(sword.get("growth_level", 1))) + "阶"
			return "你最后走成了剑修一路，以《" + technique_name + "》开锋，以" + treasure_name + "定势。" + sword_text + "，每一次出剑都像在把自己的命也押进去。"
		"鬼修":
			var ghost_count: int = int(player.final_attributes.get("ghost_count", 0))
			var ghost_power: int = int(player.final_attributes.get("ghost_power", 0))
			return "你最后走成了鬼修一路，以《" + technique_name + "》引魂，以" + treasure_name + "镇魄。旗下养鬼" + str(ghost_count) + "缕，阴魂强度" + str(ghost_power) + "，每一次胜利背后都有一声低低的魂啸。"
		"情修":
			var emotion_power: int = int(round(_school_power(player, "情修") * 10.0))
			return "你最后走成了情修一路，以《" + technique_name + "》牵红尘，以" + treasure_name + "定心神。情修火候已至" + str(emotion_power) + "，救人与负人都成了你道途的一部分。"
		_:
			return "你未拘一门，以《" + technique_name + "》为主，以" + treasure_name + "为凭。诸法杂糅，虽不纯粹，却也走出了自己的路。"


func _story_top_technique_name(player: PlayerData) -> String:
	var best_name: String = "无名法门"
	var best_power: float = -1.0
	for technique in player.techniques:
		if technique is Dictionary:
			var data: Dictionary = technique as Dictionary
			var power: float = _quality_power(str(data.get("quality", "筑基级")))
			if power > best_power:
				best_power = power
				best_name = str(data.get("name", best_name))
	return best_name


func _story_treasure_name(player: PlayerData) -> String:
	var treasure: Dictionary = _get_equipped_treasure(player)
	if treasure.is_empty():
		return "空手道心"
	return "【" + str(treasure.get("name", "无名法宝")) + "】"


func _story_aftertaste(player: PlayerData, is_winner: bool) -> String:
	var companion_count: int = player.companions.size()
	var ghost_count: int = int(player.final_attributes.get("ghost_count", 0))
	var final_choice: String = str(player.final_attributes.get("final_choice", ""))
	if final_choice == "同修陨落":
		return " 你还站着，却知道这一局已经没有胜者；少了那个人，后面的仙路只剩空壳。"
	if final_choice == "中道陨落":
		return " 你倒下时，最后看见的不是仙门，而是同修仍在伸手。"
	if final_choice == "同途俱灭":
		return " 两道命火一同熄灭，连最后反目的机会也被天道夺走。"
	if is_winner:
		if ghost_count > 0:
			return " 飞升那一刻，幡中诸魂没有散去，反而随你一同望向更高处。"
		if companion_count > 0:
			return " 回头看时，仍有人站在你身后，替你记得这一路的血与火。"
		return " 自此天门之后，只剩你的名字在风里回响。"
	if ghost_count > 0:
		return " 你倒下后，幡中阴魂仍绕身不散，像是不肯承认这一局已经结束。"
	if companion_count > 0:
		return " 你倒下时，同行之人没有退开，这比仙位更像一场报应，也更像一场慰藉。"
	return " 你倒在门前，身后空无一人，唯有风把你的名字吹回人间。"
