extends Node

const TIANGAN: Array[String] = ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"]
const DIZHI: Array[String] = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]

const BASE_STATS: Array[String] = ["体魄", "气感", "经商", "身法", "魅力", "机缘"]
const TARGET_TOTAL_POINTS := 12

const STEM_STAT_BONUS: Dictionary = {
	"甲": ["体魄", "气感"],
	"乙": ["气感", "经商"],
	"丙": ["经商", "身法"],
	"丁": ["身法", "魅力"],
	"戊": ["魅力", "机缘"],
	"己": ["体魄", "机缘"],
	"庚": ["体魄", "经商"],
	"辛": ["气感", "魅力"],
	"壬": ["经商", "机缘"],
	"癸": ["身法", "气感"],
}

const BRANCH_STAT_BONUS: Dictionary = {
	"子": "经商",
	"丑": "机缘",
	"寅": "身法",
	"卯": "身法",
	"辰": "魅力",
	"巳": "气感",
	"午": "气感",
	"未": "机缘",
	"申": "体魄",
	"酉": "体魄",
	"戌": "魅力",
	"亥": "经商",
}

const HOUR_BONUS: Dictionary = {
	"子": {"气血": 0.03},
	"丑": {"防御": 0.03},
	"寅": {"速度": 5},
	"卯": {"闪避": 0.03},
	"辰": {"气血": 0.03},
	"巳": {"攻击": 0.03},
	"午": {"攻击": 0.03},
	"未": {"防御": 0.03},
	"申": {"速度": 5},
	"酉": {"攻击": 0.03},
	"戌": {"气血": 0.03},
	"亥": {"灵力获取": 0.03},
}

var rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()


func calculate_stats(year_gan: String, month_zhi: String, day_gan: String, hour_zhi: String = "") -> Dictionary:
	var result: Dictionary = _empty_stats()
	_add_stem_bonus(result, year_gan, 1)
	_add_branch_bonus(result, month_zhi, 2)
	_add_stem_bonus(result, day_gan, 2)
	_add_branch_bonus(result, hour_zhi, 2)
	_fill_to_target_points(result, year_gan + month_zhi + day_gan + hour_zhi)
	return result


func _empty_stats() -> Dictionary:
	var result: Dictionary = {}
	for stat in BASE_STATS:
		result[stat] = 0
	return result


func _add_stem_bonus(result: Dictionary, stem: String, amount: int) -> void:
	var stats: Array = STEM_STAT_BONUS.get(stem, []) as Array
	for stat_name in stats:
		_add_stat_bonus(result, str(stat_name), amount)


func _add_branch_bonus(result: Dictionary, branch: String, amount: int) -> void:
	var stat: String = str(BRANCH_STAT_BONUS.get(branch, ""))
	if stat != "":
		_add_stat_bonus(result, stat, amount)


func _add_stat_bonus(result: Dictionary, stat: String, amount: int) -> void:
	if result.has(stat):
		result[stat] = int(result[stat]) + amount


func _fill_to_target_points(result: Dictionary, seed_text: String) -> void:
	var total: int = _stat_total(result)
	var guard: int = 0
	while total < TARGET_TOTAL_POINTS and guard < TARGET_TOTAL_POINTS * 2:
		var stat: String = _lowest_stat_for_seed(result, seed_text, guard)
		result[stat] = int(result[stat]) + 1
		total += 1
		guard += 1


func _lowest_stat_for_seed(result: Dictionary, seed_text: String, step: int) -> String:
	var lowest_value: int = 999
	var candidates: Array[String] = []
	for stat in BASE_STATS:
		var value: int = int(result.get(stat, 0))
		if value < lowest_value:
			lowest_value = value
			candidates.clear()
			candidates.append(stat)
		elif value == lowest_value:
			candidates.append(stat)
	var index: int = posmod(_stable_seed(seed_text) + step, candidates.size())
	return candidates[index]


func _stable_seed(text: String) -> int:
	var value: int = 0
	for i in range(text.length()):
		value = posmod(value * 31 + text.unicode_at(i), 1000003)
	return value


func _stat_total(result: Dictionary) -> int:
	var total: int = 0
	for stat in BASE_STATS:
		total += int(result.get(stat, 0))
	return total


func get_hour_bonus(hour_zhi: String) -> Dictionary:
	var bonus: Dictionary = HOUR_BONUS.get(hour_zhi, {}) as Dictionary
	return bonus.duplicate(true)


func random_bazi() -> Dictionary:
	var year_gan: String = TIANGAN[rng.randi_range(0, TIANGAN.size() - 1)]
	var month_zhi: String = DIZHI[rng.randi_range(0, DIZHI.size() - 1)]
	var day_gan: String = TIANGAN[rng.randi_range(0, TIANGAN.size() - 1)]
	var hour_zhi: String = DIZHI[rng.randi_range(0, DIZHI.size() - 1)]

	return {
		"year": year_gan,
		"month": month_zhi,
		"day": day_gan,
		"hour": hour_zhi,
		"stats": calculate_stats(year_gan, month_zhi, day_gan, hour_zhi),
		"hour_bonus": get_hour_bonus(hour_zhi),
	}
