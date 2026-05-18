extends Node

const TIANGAN: Array[String] = ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"]
const DIZHI: Array[String] = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]

const BASE_STATS: Array[String] = ["体魄", "气感", "经商", "身法", "魅力", "机缘"]

const YEAR_BONUS: Dictionary = {
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

const MONTH_BONUS: Dictionary = {
	"寅": "身法",
	"卯": "身法",
	"巳": "气感",
	"午": "气感",
	"申": "体魄",
	"酉": "体魄",
	"亥": "经商",
	"子": "经商",
	"辰": "魅力",
	"戌": "魅力",
	"丑": "机缘",
	"未": "机缘",
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

const DAY_BONUS: Dictionary = {
	"甲": "体魄",
	"乙": "体魄",
	"丙": "气感",
	"丁": "气感",
	"戊": "经商",
	"己": "经商",
	"庚": "身法",
	"辛": "身法",
	"壬": "魅力",
	"癸": "魅力",
}

var rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()


func calculate_stats(year_gan: String, month_zhi: String, day_gan: String) -> Dictionary:
	var result: Dictionary = {
		"体魄": 0,
		"气感": 0,
		"经商": 0,
		"身法": 0,
		"魅力": 0,
		"机缘": 0,
	}

	var year_bonus: Array = YEAR_BONUS.get(year_gan, []) as Array
	for stat_name in year_bonus:
		var stat: String = str(stat_name)
		result[stat] += 1

	var month_stat: String = str(MONTH_BONUS.get(month_zhi, ""))
	if month_stat != "":
		result[month_stat] += 2

	var day_stat: String = str(DAY_BONUS.get(day_gan, ""))
	if day_stat != "":
		result[day_stat] += 1

	var total: int = 0
	for stat in BASE_STATS:
		total += int(result[stat])

	var remain: int = maxi(0, 12 - total)
	for i in range(remain):
		var stat: String = BASE_STATS[rng.randi_range(0, BASE_STATS.size() - 1)]
		result[stat] += 1

	return result


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
		"stats": calculate_stats(year_gan, month_zhi, day_gan),
		"hour_bonus": get_hour_bonus(hour_zhi),
	}
