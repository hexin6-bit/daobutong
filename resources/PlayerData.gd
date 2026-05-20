class_name PlayerData
extends Resource

var player_name: String = ""
var peer_id: int = 0
var stats: Dictionary = {"体魄": 0, "气感": 0, "经商": 0, "身法": 0, "魅力": 0, "机缘": 0}
var remain_points: int = 12
var shou_yuan: int = 10
var ling_li: int = 0
var ling_shi: int = 0
var qi_xue: int = 100
var attack: int = 10
var defense: int = 5
var speed: int = 10
var realm: String = "炼气期"
var minor_stage: int = 1
var sect: String = ""
var resonance_level: int = 0
var resonance_bonus: Dictionary = {}
var companion_bond: Dictionary = {}
var active_tasks: Array = []
var technique_slots: int = 4
var techniques: Array = []
var treasures: Array = []
var backpack: Array = []
var backpack_capacity: int = 18
var companions: Array = []
var refined_bonuses: Dictionary = {"攻击力": 0.0, "防御力": 0.0, "气血上限": 0.0, "灵力获取": 0.0, "速度": 0.0}
var total_ji_yuan_gained: int = 0
var total_calamity_taken: int = 0
var total_qiang_count: int = 0
var total_rang_count: int = 0
var total_shuang_rang: int = 0
var total_shuang_qiang: int = 0
var qiang_streak: int = 0
var karmic_debt: int = 0
var forbearance: int = 0
var tribulation_choices: Array = []
var ji_yuan_list: Array = []
var calamity_list: Array = []
var duel_rounds: Array = []
var final_attributes: Dictionary = {}


func calculate_final_stats(realm_attack: float, realm_defense: float, realm_hp: float) -> Dictionary:
	var total_attack_bonus: float = 0.0
	var total_defense_bonus: float = 0.0
	var total_hp_bonus: float = 0.0
	var all_bonus: float = 0.0

	for technique in techniques:
		if technique is Dictionary and technique.has("bonuses"):
			var bonuses: Dictionary = technique["bonuses"]
			var technique_multiplier: float = _technique_effect_multiplier(technique as Dictionary)
			total_attack_bonus += float(bonuses.get("攻击力", 0.0)) * technique_multiplier
			total_defense_bonus += float(bonuses.get("防御力", 0.0)) * technique_multiplier
			total_hp_bonus += float(bonuses.get("气血上限", 0.0)) * technique_multiplier
			all_bonus += float(bonuses.get("全属性", 0.0)) * technique_multiplier

	for treasure in treasures:
		if treasure is Dictionary:
			var treasure_bonus: Dictionary = treasure.get("passive_bonus", {}) as Dictionary
			total_attack_bonus += float(treasure_bonus.get("攻击力", 0.0))
			total_defense_bonus += float(treasure_bonus.get("防御力", 0.0))
			total_hp_bonus += float(treasure_bonus.get("气血上限", 0.0))
			all_bonus += float(treasure_bonus.get("全属性", 0.0))

	total_attack_bonus += float(refined_bonuses.get("攻击力", 0.0))
	total_defense_bonus += float(refined_bonuses.get("防御力", 0.0))
	total_hp_bonus += float(refined_bonuses.get("气血上限", 0.0))
	all_bonus += float(refined_bonuses.get("全属性", 0.0))
	total_attack_bonus += float(resonance_bonus.get("攻击力", 0.0))
	total_defense_bonus += float(resonance_bonus.get("防御力", 0.0))
	total_hp_bonus += float(resonance_bonus.get("气血上限", 0.0))
	all_bonus += float(resonance_bonus.get("全属性", 0.0))

	for companion in companions:
		if companion is Dictionary:
			var bonus_type: String = str(companion.get("bonus_type", ""))
			var bonus_value: float = _companion_effective_bonus_value(companion as Dictionary)

			match bonus_type:
				"攻击力":
					total_attack_bonus += bonus_value
				"防御力":
					total_defense_bonus += bonus_value
				"气血上限", "气血":
					total_hp_bonus += bonus_value
				"全属性":
					all_bonus += bonus_value

	var final_attack: int = int(10 * realm_attack * (1.0 + float(stats.get("气感", 0)) * 0.02 + total_attack_bonus + all_bonus))
	var final_defense: int = int(5 * realm_defense * (1.0 + float(stats.get("体魄", 0)) * 0.02 + total_defense_bonus + all_bonus))
	var final_hp: int = int(100 * realm_hp * (1.0 + float(stats.get("体魄", 0)) * 0.04 + total_hp_bonus + all_bonus))

	var preserved_attributes: Dictionary = final_attributes.duplicate(true)
	preserved_attributes["攻击力"] = final_attack
	preserved_attributes["防御力"] = final_defense
	preserved_attributes["气血"] = final_hp
	final_attributes = preserved_attributes
	return final_attributes


func _companion_effective_bonus_value(companion: Dictionary) -> float:
	var value: float = float(companion.get("bonus_value", 0.0))
	var bond_value: int = int(companion.get("bond", 0))
	var bond_max: int = int(companion.get("bond_max", 0))
	if bond_max <= 0:
		bond_max = _companion_quality_base_bond(str(companion.get("quality", "炼气级"))) * 8
	if bond_value >= bond_max:
		value += float(companion.get("full_bonus_value", _companion_full_bonus_value(companion)))
	return value


func _companion_quality_base_bond(quality: String) -> int:
	match quality:
		"炼气级":
			return 1
		"筑基级":
			return 2
		"金丹级":
			return 3
		"元婴级":
			return 4
		"化神级":
			return 5
		"合体级":
			return 6
		_:
			return 1


func _companion_quality_factor(quality: String) -> float:
	match quality:
		"炼气级":
			return 1.0
		"筑基级":
			return 2.0
		"金丹级":
			return 3.0
		"元婴级":
			return 4.0
		"化神级":
			return 5.0
		"合体级":
			return 6.0
		_:
			return 1.0


func _companion_full_bonus_value(companion: Dictionary) -> float:
	var factor: float = _companion_quality_factor(str(companion.get("quality", "炼气级")))
	var bonus_type: String = str(companion.get("full_bonus_type", companion.get("bonus_type", "灵力获取")))
	if bonus_type == "速度":
		return factor * 4.0
	if bonus_type == "全属性":
		return factor * 0.02
	return factor * 0.04


func _technique_effect_multiplier(technique: Dictionary) -> float:
	var realm_multiplier: float = 1.0
	match str(technique.get("technique_realm", "初窥")):
		"初窥":
			realm_multiplier = 0.5
		"大成":
			realm_multiplier = 1.5
	var quality_multiplier: float = float(technique.get("quality_multiplier", _technique_quality_multiplier(str(technique.get("quality", "金丹级")))))
	return realm_multiplier * quality_multiplier


func _technique_quality_multiplier(quality: String) -> float:
	match quality:
		"炼气级":
			return 0.5
		"筑基级":
			return 0.7
		"金丹级":
			return 1.0
		"元婴级":
			return 1.3
		"化神级":
			return 1.6
		"合体级":
			return 2.0
		_:
			return 1.0
