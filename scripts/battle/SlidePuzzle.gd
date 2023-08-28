extends Control

@export var enemy: Resource

signal finished_win
signal finished_loss

@onready var atlas = enemy.atlas
@onready var enemy_tattle = enemy.tattle_description
@onready var enemy_name = enemy.name

var slide_puzzle = []
var puzzle_size = 3
var free_space = puzzle_size * puzzle_size - 1
var has_won = false
var has_failed
var texture_width = 136
var texture_height = 26
var extra_height = texture_height

var timer = 100

#
#[ 0 1 2 
#  3 4 5
#  6 7 8 ]

#[ 0  1  2  3 
#  4  5  6  7
#  8  9  10 11
#  12 13 14 15]

enum {UP, DOWN, LEFT, RIGHT}

func get_adjacent(index, direction):
	match direction:
		UP:
			if index < puzzle_size: return null
			return index - puzzle_size
		DOWN:
			if index >= puzzle_size * (puzzle_size - 1): return null
			return index + puzzle_size
		LEFT:
			if index % puzzle_size == 0: return null
			return index - 1
		RIGHT:
			if index % puzzle_size == puzzle_size - 1: return null
			return index + 1

func swap(index1, index2):
	var val1 = slide_puzzle[index1]
	slide_puzzle[index1] = slide_puzzle[index2]
	slide_puzzle[index2] = val1

func do_input(direction, check_for_win):
	var index = slide_puzzle.find(free_space)
	var adj = get_adjacent(index, direction)
	if adj == null:
		return null
	swap(index, adj)
	$SFX.play("Menu/Move")
	if check_for_win:
		if check_win():
			has_won = true
			$SFX.play("Correct")
	return adj

func check_win():
	for i in range(0, puzzle_size * puzzle_size):
		if slide_puzzle[i] !=  i:
			return false
	return true

func count_inversions(index):
	var inversions = 0
	for q in range(index + 1, puzzle_size * puzzle_size):
		if(slide_puzzle[index] > slide_puzzle[q] and slide_puzzle[index] != free_space):
			inversions += 1
	return inversions

func sum_inversions():
	var inversions = 0
	for i in range(0, puzzle_size * puzzle_size):
		inversions += count_inversions(i)
	return inversions

func is_solvable(f_puzzle_size, empty_row):
	if f_puzzle_size % 2 == 1:
		return sum_inversions() % 2 == 0
	else:
		return (sum_inversions() + f_puzzle_size - empty_row) % 2 == 0

func _ready():
	randomize()
	
	$SFX.play("Menu/In")
	
	$Tape1.modulate.a = 0
	$Tape2.modulate.a = 0
	$Book.offset_top = -1000
	
#	var e = size * size - 1
#	while e > 0:
#		var j = randi() % e
#		swap(i, j)
#		e -= 1
	
	for i in range(0, puzzle_size * puzzle_size):
		slide_puzzle.append(i)
	
	while(sum_inversions() < 3 or sum_inversions() > 6):
		slide_puzzle = []
		for i in range(0, puzzle_size * puzzle_size):
			slide_puzzle.append(i)
		
		var movement_count = 0
		while movement_count < 10:
			var input = randi() % 4
			if do_input(input, false) != null:
				movement_count += 1
	
#	if not is_solvable(size, floor(slide_puzzle.find(free_space) / size)) :
#		if slide_puzzle.find(free_space) % size <= 1:
#		  swap(2, 3)
#		else:
#		  swap(0, 1)

	for i in range(0, puzzle_size * puzzle_size):
		var new_tile = TextureRect.new()
		new_tile.stretch_mode = new_tile.STRETCH_KEEP
		new_tile.texture = AtlasTexture.new()
		new_tile.texture.atlas = atlas
		new_tile.texture.region.size.x = atlas.get_width() / puzzle_size
		new_tile.texture.region.size.y = atlas.get_height() / puzzle_size
		new_tile.texture.region.position.x = i % puzzle_size * atlas.get_width() / puzzle_size
		new_tile.texture.region.position.y = floor(i / puzzle_size) * atlas.get_height() / puzzle_size
		new_tile.set_name(str(i))
		$SlideBack/Slides.add_child(new_tile) 
	$SlideBack/Slides.get_node(str(free_space)).modulate.a = 0

var has_started_dialog = false
var has_paused = false
func _process(delta):
	if has_paused:
		return
	$Book.offset_bottom = $Book.offset_top + 191
	
	if has_started_dialog:
		if Input.is_action_just_pressed("jump"):
			$SFX.play("Menu/Option")
			emit_signal("finished_win")
			has_paused = true
	elif has_won:
		extra_height -= extra_height * .1
		$TextureProgressBar.modulate.a += -$TextureProgressBar.modulate.a * .1
		
		$Book.offset_top -= $Book.offset_top * .1
		if $Book.offset_top > -.1:
			$Tape1.modulate.a += (1 - $Tape1.modulate.a) * .1
			$Tape2.modulate.a += (1 - $Tape2.modulate.a) * .1
			$SlideBack.rotation_degrees += (4 - $SlideBack.rotation_degrees) * .1
			
			if $Tape1.modulate.a  > .99 and not has_started_dialog:
				has_started_dialog = true
				$SFX.play("Sparkle")
				$Book/Title.text = enemy_name
				$Book/RichTextLabel.text = " ".join(enemy_tattle.split("\n"))
				$Book/MoveText.set_active(true)
				#$Book/BookText.strings = enemy_tattle.split("\n")
				#$Book/BookText._ready()
		$SlideBack/Slides.get_node(str(free_space)).modulate.a += (1 - $SlideBack/Slides.get_node(str(free_space)).modulate.a) * .05
	elif has_failed:
		$TextureProgressBar.modulate.a -= $TextureProgressBar.modulate.a * .1
		$SlideBack.modulate.a -= ($SlideBack.modulate.a - .4) * .05
		$SlideBack.modulate.r = $SlideBack.modulate.a
		$SlideBack.modulate.g = $SlideBack.modulate.a
		$SlideBack.modulate.b = $SlideBack.modulate.a
		$BigX.modulate.a += (1 - $BigX.modulate.a) * .05
		if $TextureProgressBar.modulate.a < .01:
			emit_signal("finished_loss")
			has_paused = true
	else:
		timer -= delta * 15
		if timer < 0:
			has_failed = true
		$TextureProgressBar.value =  timer
		$TextureProgressBar.tint_progress.r = (100 - timer) / 100 + .1
		$TextureProgressBar.tint_progress.b = timer / 100
		if Input.is_action_just_pressed("ui_right"):
			do_input(LEFT, true)
		elif Input.is_action_just_pressed("ui_left"):
			do_input(RIGHT, true)
		if Input.is_action_just_pressed("ui_down"):
			do_input(UP, true)
		elif Input.is_action_just_pressed("ui_up"):
			do_input(DOWN, true)
	for i in range(0, puzzle_size * puzzle_size):
		var index = slide_puzzle.find(i)
		var new_margins = Vector2((index % puzzle_size - 1.9) * atlas.get_width() / puzzle_size, 
			(floor(index / puzzle_size) - 1.9) * atlas.get_height() / puzzle_size)
		$SlideBack/Slides.get_node(str(i)).offset_left += (new_margins.x - $SlideBack/Slides.get_node(str(i)).offset_left) * .3 + 4
		$SlideBack/Slides.get_node(str(i)).offset_top += (new_margins.y - $SlideBack/Slides.get_node(str(i)).offset_top) * .3 + 4


func _on_BookText_text_finished():
	emit_signal("finished_win")
	has_paused = true
