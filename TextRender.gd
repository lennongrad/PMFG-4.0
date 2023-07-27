tool # update in editor

extends Control # use on basic control node.

#printing variables -- DO NOT EDIT!!!
var counter = 0
var vcounter = 0

@export var text : String = "Test"
@export var position : Vector2 = Vector2(0, 0)


@export var letter_size : int = 16 #default font size
@export var letter_spacing : int = 0 # horizontal space between letters. negative values are allowed
@export var vertical_spacing : int = 0 # vertical space between letters. negative values are allowed

@export var image_extension : String = ".png" # the extension (format) of the image files

@export var font_path : String = "res://pixel-sans-serif/" # path to the folder of the font images

func _process(delta):
	# Run every frame DO NOT EDIT!!!
	_clear()
	_print(position, text)

func _print(pos : Vector2, text : String):
	# Reset counters DO NOT EDIT!!
	counter = 0
	vcounter = 0
	
	# For every char in string text
	for i in text:
		# if newline, make a newline
		if (i == "/"):
			vcounter += 1
			counter = -1
		#if colon, make a colon from "colon" image
		if (i == ":"):
			var tex = TextureRect.new()
			tex.texture = load(font_path + "colon" + image_extension)
			tex.position.x = pos.x + counter*(letter_size + letter_spacing)
			tex.position.y = pos.y + vcounter*(letter_size + vertical_spacing)
			tex.expand = true
			tex.size = Vector2(letter_size, letter_size)
			add_child(tex)
		# otherwise, print from char.ext
		if (i != " " and i != "/" and i != ":"):
			var tex = TextureRect.new()# create a 2d texture
			tex.texture = load(font_path + i.to_lower() + image_extension) # load the texture
			#position it on the screen
			tex.position.x = pos.x + counter*(letter_size + letter_spacing)
			tex.position.y = pos.y + vcounter*(letter_size + vertical_spacing)
			# make the texture expand to the rect
			tex.expand = true
			# set the size of he rect
			tex.size = Vector2(letter_size, letter_size)
			# add the rectangle
			add_child(tex)
		counter += 1

func _clear():
	# iterate through children
	for i in get_children():
		#delete current child
		i.queue_free()
