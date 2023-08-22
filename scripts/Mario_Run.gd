extends Node

var rng = RandomNumberGenerator.new()

var items = [
]

#var badges = []
var badges = [
	#{"badge": load("res://stats/badges/quakesmash.tres"), "active": true},
]

var boots = [{"type": load("res://stats/boots/basic.tres"), "name": "Normal Boots", "badges": []}]
#var boots = [{"type": load("res://stats/boots/basic.tres"), "name": "Normal Boots", 
#	"badges": [load("res://stats/badges/multibounce.tres")]}]
var equipped_boots = boots[0]

var hammers = [{"type": load("res://stats/hammers/basic.tres"), "name": "Normal Hammer", "badges": []}]
var equipped_hammer = hammers[0]

var level_bonuses = []
var experience = 0
var level_ups_waiting = 0

var party = {}
var active_partner

var enemies = {}

var fp = 0
var coins = 0

var current_stage = 0

# 9
var possible_items = [
	# attacks
	{"probability": 1, "item": load("res://stats/heroattack/items/fireflower.tres")},
	# hp
	{"probability": 1, "item": load("res://stats/heroattack/items/mushroom.tres")},
	{"probability": 1, "item": load("res://stats/heroattack/items/supermushroom.tres")},
	{"probability": 1, "item": load("res://stats/heroattack/items/ultramushroom.tres")},
	# fp
	{"probability": 1, "item": load("res://stats/heroattack/items/honeysyrup.tres")},
	{"probability": 1, "item": load("res://stats/heroattack/items/maplesyrup.tres")},
	{"probability": 1, "item": load("res://stats/heroattack/items/jamminjelly.tres")},	
	# hp/fp
	{"probability": 1, "item": load("res://stats/heroattack/items/cookiecombo.tres")},
	{"probability": 1, "item": load("res://stats/heroattack/items/strawberrycake.tres")},
]

var possible_weapons = [
	{"probability": 1, "item": load("res://stats/boots/super.tres")},
	{"probability": 1, "item": load("res://stats/boots/ultra.tres")},
	{"probability": 1, "item": load("res://stats/hammers/super.tres")},
	{"probability": 1, "item": load("res://stats/hammers/ultra.tres")},
]

# 26 badges
var possible_badges = [
	# jump
	{"probability": 1, "item": load("res://stats/badges/multibounce.tres")},
	{"probability": 1, "item": load("res://stats/badges/powerbounce.tres")},
	{"probability": 1, "item": load("res://stats/badges/superstomp.tres")},
	{"probability": 1, "item": load("res://stats/badges/spikeshield.tres")},
	{"probability": 1, "item": load("res://stats/badges/jumpman.tres")},
	# hammer
	{"probability": 1, "item": load("res://stats/badges/superpound.tres")},
	{"probability": 1, "item": load("res://stats/badges/quakesmash.tres")},
	{"probability": 1, "item": load("res://stats/badges/earthbreaker.tres")},
	{"probability": 1, "item": load("res://stats/badges/hammerman.tres")},
	# field effects
	{"probability": 1, "item": load("res://stats/badges/coinup.tres")},
	{"probability": 1, "item": load("res://stats/badges/chillout.tres")},
	# damage effects
	{"probability": 1, "item": load("res://stats/badges/strikeplus.tres")},
	{"probability": 1, "item": load("res://stats/badges/dodgeplus.tres")},
	{"probability": 1, "item": load("res://stats/badges/attackplus.tres")},
	{"probability": 1, "item": load("res://stats/badges/defendplus.tres")},
	{"probability": 1, "item": load("res://stats/badges/chancetaker.tres")},
	{"probability": 1, "item": load("res://stats/badges/riskavoider.tres")},
	{"probability": 1, "item": load("res://stats/badges/prettylucky.tres")},
	{"probability": 1, "item": load("res://stats/badges/closecall.tres")},
	# hp/fp
	{"probability": 1, "item": load("res://stats/badges/hpup.tres")},
	{"probability": 1, "item": load("res://stats/badges/fpup.tres")},
	{"probability": 1, "item": load("res://stats/badges/hpdrain.tres")},
	{"probability": 1, "item": load("res://stats/badges/fpdrain.tres")},
	{"probability": 1, "item": load("res://stats/badges/happyheart.tres")},
	{"probability": 1, "item": load("res://stats/badges/happyflower.tres")},
	{"probability": 1, "item": load("res://stats/badges/flowersaver.tres")},
]

func get_random_item(items = 1.0, weapons = 1.0, badges = 1.0):
	var combined_list = []
	var probability_total = 0
	if items != 0:
		for item in possible_items:
			combined_list.append(item)
			probability_total += item["probability"] * items
	if weapons != 0:
		for item in possible_weapons:
			combined_list.append(item)
			probability_total += item["probability"] * weapons
	if badges != 0: 
		for item in possible_badges:
			combined_list.append(item)
			probability_total += item["probability"] * badges
	
	var chance = rng.randf_range(0.0, probability_total)
	for item in combined_list:
		if item["item"].is_badge:
			chance -= item["probability"] * badges 
		elif item["item"].is_weapon:
			chance -= item["probability"] * weapons
		else:
			chance -= item["probability"] * items
		if chance <= 0:
			return item["item"]

func start_battle():
	pass

func add_bonus(bonus):
	level_bonuses.append(bonus)
	level_ups_waiting -= 1

func add_experience(amount):
	experience += amount
	while(experience > 99):
		experience -= 100
		level_ups_waiting += 1

func get_level_ups():
	return level_ups_waiting

func get_experience():
	return experience

func get_coins():
	return coins

func get_fp_cost(action):
	if action.fp_cost == 0:
		return 0
	
	return max(1, action.fp_cost - get_badge_value("fp_reduce"))

func change_coins(amount):
	var coin_chance = get_badge_value("coin_up")
	if amount > 0:
		for c in amount:
			var chance = coin_chance
			while(rng.randf_range(0.0, 1.0) < chance):
				coins += 1
				chance -= 1.0
	coins += amount

func get_max_hp(stats):
	var max_hp = stats.max_hp
	
	if stats.name == "Mario":
		max_hp += get_badge_value("hp_up")
		for bonus in level_bonuses:
			if bonus == "hp":
				max_hp += 3
	else:
		max_hp += get_badge_value("hp_up_partner")
	
	return max_hp

func get_hp(stats):
	if party[stats].hp > get_max_hp(stats):
		party[stats].hp = get_max_hp(stats)
	return party[stats].hp

func get_partner_hp():
	return get_hp(active_partner)

func get_partner_max_hp():
	return get_max_hp(active_partner)

func take_damage(stats, damage):
	party[stats].hp -= damage
	return damage

func heal(stats, health):
	var healed = min(party[stats].hp + health, get_max_hp(stats)) - party[stats].hp
	party[stats].hp += healed
	return healed

func get_max_bp():
	var max_bp = 3
	for bonus in level_bonuses:
		if bonus == "bp":
			max_bp += 3
	
	return max_bp

func get_badge_value(attribute, multiplicative=false):
	if multiplicative:
		var modifier = 1
		var effective_badges = get_effective_badges()
		for badge in effective_badges:
			if badge.attributes.has(attribute):
				for i in effective_badges[badge]:
					modifier *= (1 - badge.attributes[attribute])
		return modifier

	var modifier = 0
	var effective_badges = get_effective_badges()
	for badge in effective_badges:
		if badge.attributes.has(attribute):
			modifier += badge.attributes[attribute] * effective_badges[badge]
	return modifier

func get_max_fp():
	var max_fp = 5
	max_fp += get_badge_value("fp_up")
	
	for bonus in level_bonuses:
		if bonus == "fp":
			max_fp += 3
	
	return max_fp

func get_fp():
	return fp

func gain_fp(change):
	var gained = min(fp + change, get_max_fp()) - fp
	fp += gained
	return gained

func get_choices(stats):
	var dynamic_attacks = [load("res://stats/heroattack/tactics/run.tres"), 
		load("res://stats/heroattack/tactics/skip.tres")]
	
	if stats.name == "Mario":
		for badge in get_effective_badges():
			if badge.attack != null:
				dynamic_attacks.append(badge.attack)
	
	return dynamic_attacks + stats.attacks + items

func get_effective_badges():
	var equipped_badges = get_equipped_badges()
	var badges_gear = get_equipped_boots().badges + get_equipped_hammer().badges
	for badge in badges_gear:
		if equipped_badges.has(badge):
			equipped_badges[badge] += 1
		else:
			equipped_badges[badge] = 1
	return equipped_badges

func get_equipped_badges():
	var multiset_badges = {}
	for badge in badges:
		if badge["active"]:
			if multiset_badges.has(badge["badge"]):
				multiset_badges[badge["badge"]] += 1
			else:
				multiset_badges[badge["badge"]] = 1
	return multiset_badges

func toggle_badge(badge_index):
	if badges[badge_index].active:
		badges[badge_index].active = false
		return true
	if get_bp_used() + badges[badge_index].badge.bp <= get_max_bp():
		badges[badge_index].active = true
		return true
	return false

func get_bp_used():
	var bp = 0
	var equipped = get_equipped_badges()
	for badge in equipped:
		bp += badge.bp * equipped[badge]
	return bp

func badge_order(a, b):
	if a.active and not b.active:
		return true
	if not a.active and b.active:
		return false
	return a.badge.bp < b.badge.bp

func sort_badges():
	badges.sort_custom(Callable(self, "badge_order"))

func get_badges():
	return badges

func get_items():
	return items

func add_item(item, auto_equip = false):
	if item.is_badge:
		badges.append({"badge": item, "active": auto_equip})
	elif item.is_weapon:
		var new_weapon = {"type": item, "name": item.name, "badges": []}
		if item.is_boots:
			boots.append(new_weapon)
		else:
			hammers.append(new_weapon)
	else:
		items.append(item)


func item_used(item):
	items.remove_at(items.find(item))

func equip_boots(index):
	equipped_boots = boots[index]

func get_equipped_boots():
	return equipped_boots

func get_boots_list():
	return boots

func equip_hammer(index):
	equipped_hammer = hammers[index]

func get_equipped_hammer():
	return equipped_hammer

func get_hammer_list():
	return hammers

func tattle_enemy(stats):
	if not enemies.has(stats):
		enemies[stats] = {"tattled": false}
	enemies[stats].tattled = true

func is_tattled(stats):
	if not enemies.has(stats):
		enemies[stats] = {"tattled": false}
	return enemies[stats].tattled

# Called when the node enters the scene tree for the first time.
func _ready():
	party[load("res://stats/herostats/goombario.tres")] = {"hp": 0}
	party[load("res://stats/herostats/mario.tres")] = {"hp": 0}
	
	for member in party:
		party[member].hp = get_max_hp(member) 
	fp = get_max_fp() 
	
	active_partner = load("res://stats/herostats/goombario.tres")
