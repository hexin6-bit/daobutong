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
var techniques: Array = []
var treasures: Array = []
var backpack: Array = []
var backpack_capacity: int = 5
var companions: Array = []
var refined_bonuses: Dictionary = {"攻击力": 0.0, "防御力": 0.0, "气血上限": 0.0, "灵力获取": 0.0, "速度": 0.0}
var total_ji_yuan_gained: int = 0
var total_calamity_taken: int = 0
var total_qiang_count: int = 0
var total_rang_count: int = 0
var total_shuang_rang: int = 0
var total_shuang_qiang: int = 0
var tribulation_choices: Array = []
var ji_yuan_list: Array = []
var calamity_list: Array = []
var duel_rounds: Array = []
var final_attributes: Dictionary = {}


func calculate_final_stats(realm_attack: float, realm_defense: float, realm_hp: float) -> Dictionary:
	var total_attack_bonus: float = 0.0
	var total_defense_bonus: float = 0.0
	var total_hp_bonus: float = 0.0

	for technique in techniques:
		if technique is Dictionary and technique.has("bonuses"):
			var bonuses: Dictionary = technique["bonuses"]
			total_attack_bonus += float(bonuses.get("攻击力", 0.0))
			total_defense_bonus += float(bonuses.get("防御力", 0.0))
			total_hp_bonus += float(bonuses.get("气血上限", 0.0))

	total_attack_bonus += float(refined_bonuses.get("攻击力", 0.0))
	total_defense_bonus += float(refined_bonuses.get("防御力", 0.0))
	total_hp_bonus += float(refined_bonuses.get("气血上限", 0.0))

	for companion in companions:
		if companion is Dictionary:
			var bonus_type: String = str(companion.get("bonus_type", ""))
			var bonus_value: float = float(companion.get("bonus_value", 0.0))

			match bonus_type:
				"攻击力":
					total_attack_bonus += bonus_value
				"防御力":
					total_defense_bonus += bonus_value
				"气血上限", "气血":
					total_hp_bonus += bonus_value

	var final_attack: int = int(10 * (1.0 + float(stats.get("气感", 0)) * 0.02 + total_attack_bonus))
	var final_defense: int = int(5 * (1.0 + float(stats.get("体魄", 0)) * 0.02 + total_defense_bonus))
	var final_hp: int = int(100 * (1.0 + float(stats.get("体魄", 0)) * 0.04 + total_hp_bonus))

	final_attributes = {"攻击力": final_attack, "防御力": final_defense, "气血": final_hp}
	return final_attributes
