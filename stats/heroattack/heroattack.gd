extends Resource
@export var choice: Resource
@export var icon: CompressedTexture2D
@export var icon_texture: CompressedTexture2D
@export var icon_gray: CompressedTexture2D
@export var name: String
@export var description: String
@export var steps: Array
@export var walkto_distance: float
@export var fp_cost: int
@export var skipEnemySelection: bool
@export var firstStrike: bool
@export var attributes: Dictionary

var is_badge = false
var is_weapon = false

func _init(p_steps = [], p_walkto_distance = 0):
	steps = p_steps
	walkto_distance = p_walkto_distance
