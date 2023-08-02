extends Node

var items = [
	load("res://stats/heroattack/items/supermushroom.tres")
]

var badges = []

var boots = [{"type": load("res://stats/boots/basic.tres"), "name": "Normal Boots", "badges": []}]
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

func start_battle():
	fp = get_max_fp()
	party[active_partner].hp = get_max_hp(active_partner)

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

func change_coins(amount):
	coins += amount

func get_max_hp(stats):
	var max_hp = stats.max_hp
	
	if stats.name == "Mario":
		for bonus in level_bonuses:
			if bonus == "hp":
				max_hp += 3
	
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

func get_max_fp():
	var max_fp = 3
	
	var effective_badges = get_effective_badges()
	for badge in effective_badges:
		if badge.attributes.has("fp_up"):
			max_fp += badge.attributes["fp_up"] * effective_badges[badge]
	
	for bonus in level_bonuses:
		if bonus == "fp":
			max_fp += 3
	
	return max_fp

func get_fp():
	return fp

func change_fp(change):
	fp += change

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

func add_item(item):
	if item.is_badge:
		badges.append({"badge": item, "active": false})
	elif item.is_weapon:
		var new_weapon = {"type": item, "name": item.name, "badges": [load("res://stats/badges/multibounce.tres")]}
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
	enemies[stats].tattled = true

func is_tattled(stats):
	return enemies[stats].tattled

# Called when the node enters the scene tree for the first time.
func _ready():
#	var dir = DirAccess.open("res://stats/herostats")
#
#	if dir:
#		dir.list_dir_begin() # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
#		var file_name = dir.get_next()
#		while file_name != "":
#			if file_name != "." and file_name != ".." and file_name != "herostats.gd":
#				file_name = "res://stats/herostats/" + file_name
#				party[load(file_name)] = {"hp": 0}
#			file_name = dir.get_next()
#
#	dir = DirAccess.open("res://stats/enemystats");
#	if dir:
#		dir.list_dir_begin() # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
#		var file_name = dir.get_next()
#		while file_name != "":
#			if file_name != "." and file_name != "..":
#				file_name = "res://stats/enemystats/" + file_name
#				enemies[load(file_name)] = {"tattled": false}
#			file_name = dir.get_next()
	party[load("res://stats/herostats/goombario.tres")] = {"hp": 0}
	party[load("res://stats/herostats/mario.tres")] = {"hp": 0}
	enemies[load("res://stats/enemystats/enemystats_cheepcheep.tres")] = {"tattled": false}
	enemies[load("res://stats/enemystats/enemystats_redshyguy.tres")] = {"tattled": false}
	enemies[load("res://stats/enemystats/enemystats_skyguy.tres")] = {"tattled": false}
	
	for member in party:
		party[member].hp = get_max_hp(member)
	
	active_partner = load("res://stats/herostats/goombario.tres")
