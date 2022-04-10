extends Camera

# Declare member variables here:
var dir = {"N" : [Vector3(0, 0, -1), Vector3(0, 0, 1), Vector3(-1, 0, 0), Vector3(1, 0, 0)],
"S" : [Vector3(0, 0, 1), Vector3(0, 0, -1), Vector3(1, 0, 0), Vector3(-1, 0, 0)],
"W" : [Vector3(-1, 0, 0), Vector3(1, 0, 0), Vector3(0, 0, 1), Vector3(0, 0, -1)],
"E" : [Vector3(1, 0, 0), Vector3(-1, 0, 0), Vector3(0, 0, -1), Vector3(0, 0, 1)]}
var direct = ["N", "W", "S", "E"]
var direction
var move = "stop"
var step = 0
var pos = Vector3(0, 0, 0)
var rotL = 0
var rotR = 0
var id = {87:0, 83:1, 65:2, 68:3}
var map
var type

const STEP = 20.0 / 60.0
const ROT_STEP = PI / 2.0 / 60.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pos = translation
	map = get_parent()
	type = map.PLAYER

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	step_mov(KEY_W)
	step_mov(KEY_S)
	step_mov(KEY_A)
	step_mov(KEY_D)
	rot()


func step_mov(key):
	if (Input.is_key_pressed(key) && move == "stop") || move == direct[id[key]]:
		direction = dir[direct[0]][id[key]]
		if map.is_possible_move(pos, direction) || step > 0:
			if step == 0:
				map.update_child_pos(self)
			move = direct[id[key]]
			step += 1
			pos += STEP * dir[direct[0]][id[key]]
			if step == 60:
				move = "stop"
				step = 0
				pos = Vector3(round(pos.x), 10, round(pos.z))
			set_translation(Vector3(pos.x, 10, pos.z))


func rot():
	if Input.is_key_pressed(KEY_Q) && step == 0 && rotR == 0 || rotL != 0:
		if rotL == 0:
			direct.push_back(direct[0])
			direct.pop_front()
		rotL += 1
		if rotL == 60:
			rotL = 0
		rotate_y(ROT_STEP)
				
	if Input.is_key_pressed(KEY_E) && step == 0 && rotL == 0 || rotR != 0:
		if rotR == 0:
			direct.push_front(direct[3])
			direct.pop_back()
		rotR += 1
		if rotR == 60:
			rotR = 0
		rotate_y(-ROT_STEP)
