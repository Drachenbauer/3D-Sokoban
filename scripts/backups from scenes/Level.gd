extends GridMap

onready var targets = $Targets
onready var ground = get_parent().get_node("Ground")
onready var box_path = preload("res://scenes/Box.tscn")
onready var player_path = preload("res://scenes/Player.tscn")
onready var bricks = load("res://assets/materials/GroundBricksMaterial.tres")
onready var rock = load("res://assets/materials/GroundRockMaterial.tres")

var player
var tile_size = get_cell_size()
var grid_size = Vector3(32, 1, 24)
var target_grid = []
var grid = []
var level = 0
var materials = [bricks, rock]

enum {WALL, TARGET, BOX, PLAYER}

# Called when the node enters the scene tree for the first time.
func _ready():
	level = G.level
	setup_grid()
	ground.set_surface_material(0, materials[G.wall_type])
	generate_walls()
	generate_targets()
	generate_boxes()
	generate_player()
	count_boxes_on_target()


func _on_OptionPanel_refresh():
	ground.set_surface_material(0, materials[G.wall_type])
	generate_walls()
	generate_targets()


func setup_grid():
	for x in range(grid_size.x):
		target_grid.append([])
		grid.append([])
		for y in range(grid_size.y):
			target_grid[x].append([])
			grid[x].append([])
			for _z in range(grid_size.z):
				target_grid[x][y].append(null)
				grid[x][y].append(null)


func generate_walls():
	for y in range(G.MAPS[level - 1].size() - 1):
		for z in range(G.MAPS[level - 1][y].size() - 1):
			for x in range(G.MAPS[level - 1][y][z].size() - 1):
				if G.MAPS[level - 1][y][z][x] == 1:
					set_cell_item(x, y, z, G.wall_type, 0)
	
	var wall_positions = get_used_cells()
	for wall_pos in wall_positions:
		if wall_pos.x < grid_size.x and wall_pos.y < grid_size.y and wall_pos.z < grid_size.z:
			grid[wall_pos.x][wall_pos.y][wall_pos.z] = WALL


func generate_targets():
	for y in range(G.MAPS[level - 1].size() - 1):
		for z in range(G.MAPS[level - 1][y].size() - 1):
			for x in range(G.MAPS[level - 1][y][z].size() - 1):
				if G.MAPS[level - 1][y][z][x] == 2:
					targets.set_cell_item(x, y, z, G.wall_type, 0)
	
	var target_positions = targets.get_used_cells()
	for target_pos in target_positions:
		if target_pos.x < grid_size.x and target_pos.y < grid_size.y and target_pos.z < grid_size.z:
			target_grid[target_pos.x][target_pos.y][target_pos.z] = TARGET


func generate_boxes():
	for box_pos in G.BOX_POSITIONS[level - 1]:
		var box = box_path.instance()
		box.translation = map_to_world(box_pos.x, box_pos.y, box_pos.z)
		add_child(box)
		G.boxes += 1
		grid[box_pos.x][box_pos.y][box_pos.z] = BOX


func generate_player():
	var player_pos = G.PLAYER_POSITIONS[level - 1]
	player = player_path.instance()
	player.translation = map_to_world(player_pos.x, player_pos.y, player_pos.z)
	add_child(player)
	grid[player_pos.x][player_pos.y][player_pos.z] = PLAYER

#called by player to know, if can move to the next cell
func is_valid_move(pos, direction):
	var own_pos = world_to_map(pos)
	var target_pos = own_pos + direction
	var behind_box_pos = target_pos + direction
	
	if target_pos.x < grid_size.x and target_pos.x >= 0:
		if target_pos.y < grid_size.y and target_pos.y >= 0:
			if target_pos.z < grid_size.z and target_pos.z >= 0:
				if grid[target_pos.x][target_pos.y][target_pos.z] == WALL:
					return false
				elif grid[target_pos.x][target_pos.y][target_pos.z] == BOX:
					return grid[behind_box_pos.x][behind_box_pos.y][behind_box_pos.z] == null
				else:
					return true
	return false

#called by the box to know, if the player is about to push it
func has_pusher(pos, direction):
	var own_pos = world_to_map(pos)
	var pusher_pos = own_pos - direction
	return grid[pusher_pos.x][pusher_pos.y][pusher_pos.z] == PLAYER

#called by player to know, if pushing a box
func is_pushing(pos, direction):
	var own_pos = world_to_map(pos)
	var box_pos = own_pos + direction
	return grid[box_pos.x][box_pos.y][box_pos.z] == BOX

#called by the box to know, if it´s placed on a target
func is_on_target(pos):
	var own_pos = world_to_map(pos)
	return target_grid[own_pos.x][own_pos.y][own_pos.z] == TARGET

#called by the player at te end of a move to display nomber of boxes on target
func count_boxes_on_target():
	G.on_target = 0
	var boxes = get_tree().get_nodes_in_group("Boxes")
	for box in boxes:
		if box.is_on_target():
			G.on_target += 1

#called by player and box to set their new positions in the grid
func update_child_pos(child_node):
	var grid_pos = world_to_map(child_node.pos)
	var last_pos = grid_pos - child_node.direction
	
	grid[last_pos.x][last_pos.y][last_pos.z] = null
	grid[grid_pos.x][grid_pos.y][grid_pos.z] = child_node.type

#called at undo move by player and box to set their last positions in the grid
func update_child_pos_undo(child_node):
	var grid_pos = world_to_map(child_node.pos)
	var last_pos = world_to_map(child_node.undo_pos)
	
	grid[last_pos.x][last_pos.y][last_pos.z] = null
	grid[grid_pos.x][grid_pos.y][grid_pos.z] = child_node.type
