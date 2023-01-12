extends Node2D

#state machine
enum {wait, move}
var state

#Grid Variables
export (int) var width
export (int) var height
export (int) var offset
export (int) var x_start
export (int) var y_start
export (int) var y_offset



var possible_pieces = [
	preload("res://Scenes/BluePiece.tscn"),
	preload("res://Scenes/RedPiece.tscn"),
	preload("res://Scenes/YellowPiece.tscn"),
	preload("res://Scenes/GreenPiece.tscn")
]

var enemies = [
	preload("res://Scenes/red sus meme.tscn")
]

var all_pieces = []
var first_touch = Vector2(0,0)
var last_touch = Vector2(0,0)
var controlling = false
# Called when the node enters the scene tree for the first time.
func _ready():
	state = move
	randomize()
	all_pieces = make_array()
	print(all_pieces)
	spawn()
	enemy()

func make_array():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array

func enemy():
	var rand = floor(rand_range(0, enemies.size()))
	var enemy = enemies[rand].instance()
	add_child(enemy)

func spawn():
	for i in width:
		for j in height:
			var rand = floor(rand_range(0, possible_pieces.size()))
			var piece = possible_pieces[rand].instance()
			var loops = 0
			while(match_at(i,j,piece.color) && loops < 100):
				rand = floor(rand_range(0, possible_pieces.size()))
				loops += 1
				piece = possible_pieces[rand].instance()
			add_child(piece)
			piece.position = grid_to_pixel(i,j)
			all_pieces[i][j] = piece
			

func match_at(i, j, color):
	if i > 1:
		if all_pieces[i-1][j] != null && all_pieces[i-2][j] != null:
			if all_pieces[i-1][j].color == color && all_pieces[i-2][j].color == color:
				return true
	if j > 1:
		if all_pieces[i][j-1] != null && all_pieces[i][j-2] != null:
			if all_pieces[i][j-1].color == color && all_pieces[i][j-2].color == color:
				return true
	pass

func is_in_grid(grid_position):
	if grid_position.x >= 0 && grid_position.x < width:
		if grid_position.y >= 0 && grid_position.y < height:
			return true
		
		return false 

func grid_to_pixel(column, row):
	var new_x = x_start + offset * column
	var new_y = y_start + -offset * row
	return Vector2(new_x, new_y)

func pixel_to_grid(pixel_x,pixel_y):
	var new_x = round((pixel_x - x_start) / offset)
	var new_y = round((pixel_y - y_start) / -offset)
	return Vector2(new_x, new_y) 

func touchInput():
	if Input.is_action_just_pressed("ui_touch"):
		var mouse = get_global_mouse_position()
		var grid_position = pixel_to_grid(mouse.x, mouse.y)
		if is_in_grid(grid_position):
			controlling = true
			first_touch = pixel_to_grid(mouse.x,mouse.y)
	if Input.is_action_just_released("ui_touch"):
		var mouse = get_global_mouse_position()
		var grid_position = pixel_to_grid(mouse.x, mouse.y)
		if is_in_grid(grid_position) && controlling:
			controlling = false
			last_touch = pixel_to_grid(mouse.x,mouse.y)
			touch_difference(first_touch, last_touch)
	pass

func swap(column, row, direction):
	var first_piece = all_pieces[column][row]
	var other_piece = all_pieces[column + direction.x][row + direction.y]
	if first_piece != null && other_piece != null:
		state = wait
		all_pieces[column][row] = other_piece
		all_pieces[column + direction.x][row + direction.y] = first_piece
		first_piece.move(grid_to_pixel(column + direction.x,row + direction.y))
		other_piece.move(grid_to_pixel(column,row))
		find_matches()
	

func touch_difference(grid_1, grid_2):
	var difference = grid_2 - grid_1
	if abs(difference.x) > abs(difference.y):
		if difference.x > 0:
			swap(grid_1.x, grid_1.y, Vector2(1,0))
		elif difference.x < 0:
			swap(grid_1.x, grid_1.y, Vector2(-1,0))
	elif abs(difference.y) > abs(difference.x):
		if difference.y > 0:
			swap(grid_1.x, grid_1.y, Vector2(0,1))
		elif difference.y < 0:
			swap(grid_1.x, grid_1.y, Vector2(0,-1))
	pass

func find_matches():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				var current_color = all_pieces[i][j].color
				if i > 0 && i < width - 1:
					if all_pieces[i-1][j] != null && all_pieces[i+1][j] != null:
						if all_pieces[i-1][j].color == current_color && all_pieces[i+1][j].color == current_color:
							all_pieces[i-1][j].matched = true
							all_pieces[i-1][j].dim()
							all_pieces[i+1][j].matched = true
							all_pieces[i+1][j].dim()
							all_pieces[i][j].matched = true
							all_pieces[i][j].dim()
					if j > 0 && j < height - 1:
						if all_pieces[i][j-1] != null && all_pieces[i][j+1] != null:
							if all_pieces[i][j-1].color == current_color && all_pieces[i][j+1].color == current_color:
								all_pieces[i][j-1].matched = true
								all_pieces[i][j-1].dim()
								all_pieces[i][j+1].matched = true
								all_pieces[i][j+1].dim()
								all_pieces[i][j].matched = true
								all_pieces[i][j].dim()
	get_parent().get_node("Destroy Timer").start()

func destroy_matched():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if all_pieces[i][j].matched:
					all_pieces[i][j].queue_free()
					all_pieces[i][j] = null
	get_parent().get_node("collapse_timer").start()

func collapse_collumn():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null:
				for k in range(j+1, height):
					if all_pieces[i][k] != null:
						all_pieces[i][k].move(grid_to_pixel(i,j))
						all_pieces[i][j] = all_pieces[i][k]
						all_pieces[i][k] = null
						break
	get_parent().get_node("refill_timer").start()

func refill():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null:
				var rand = floor(rand_range(0, possible_pieces.size()))
				var piece = possible_pieces[rand].instance()
				var loops = 0
				while(match_at(i,j,piece.color) && loops < 100):
					rand = floor(rand_range(0, possible_pieces.size()))
					loops += 1
					piece = possible_pieces[rand].instance()
				add_child(piece)
				piece.position = grid_to_pixel(i,j - y_offset)
				piece.move(grid_to_pixel(i,j))
				all_pieces[i][j] = piece
	after_refill()

func after_refill():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if match_at(i,j,all_pieces[i][j].color):
					find_matches()
					get_parent().get_node("Destroy Timer").start()
					return
	state = move
	
	

func _physics_process(delta):
	touchInput()


func _on_Destroy_Timer_timeout():
	destroy_matched()

func _on_collapse_timer_timeout():
	collapse_collumn()



func _on_refill_timer_timeout():
	refill()

