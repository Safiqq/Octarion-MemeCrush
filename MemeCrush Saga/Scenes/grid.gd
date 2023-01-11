extends Node2D
#Grid Variables
export (int) var width
export (int) var height
export (int) var offset
export (int) var x_start
export (int) var y_start

var possible_pieces = [
	preload("res://Scenes/BluePiece.tscn"),
	preload("res://Scenes/RedPiece.tscn"),
	preload("res://Scenes/YellowPiece.tscn")
]

var all_pieces = []
var first_touch = Vector2(0,0)
var last_touch = Vector2(0,0)
var controlling = false
# Called when the node enters the scene tree for the first time.
func _ready():
	all_pieces = make_array()
	print(all_pieces)
	spawn()

func make_array():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array

func spawn():
	for i in width:
		for j in height:
			var rand = floor(rand_range(0, possible_pieces.size()))
			var piece = possible_pieces[rand].instance()
			var loops = 0
			while(match(i,j,piece.color) && loops < 100):
				rand = floor(rand_range(0, possible_pieces.size()))
				loops += 1
				piece = possible_pieces[rand].instance()
			add_child(piece)
			piece.position = grid_to_pixel(i,j)
			all_pieces[i][j] = piece
			
func match(i, j, color):
	if i > 1:
		if all_pieces[i-1][j] != null && all_pieces[i-2][j] != null:
			if all_pieces[i-1][j].color == color && all_pieces[i-2][j].color == color:
				return true
	if j > 1:
		if all_pieces[i][j-1] != null && all_pieces[i][j-2] != null:
			if all_pieces[i][j-1].color == color && all_pieces[i][j-2].color == color:
				return true
	pass

func is_in_grid(column, row):
	if column >= 0 && column < width:
		if row >= 0 && row < height:
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
		first_touch = get_global_mouse_position()
		var grid_position = pixel_to_grid(first_touch.x, first_touch.y)
		if is_in_grid(grid_position.x, grid_position.y):
			controlling = true
	if Input.is_action_just_released("ui_touch"):
		last_touch = get_global_mouse_position()
		var grid_position = pixel_to_grid(last_touch.x, last_touch.y)
		if is_in_grid(grid_position.x, grid_position.y) && controlling:
			touch_difference(pixel_to_grid(first_touch.x, first_touch.y), grid_position)
			controlling = false

func swap(column, row, direction):
	var first_piece = all_pieces[column][row]
	var other_piece = all_pieces[column + direction.x][row + direction.y]
	all_pieces[column][row] = other_piece
	all_pieces[column + direction.x][direction.y] = first_piece
	first_piece.move(grid_to_pixel(column + direction.x,row + direction.y))
	other_piece.move(grid_to_pixel(column,row))

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
	

func _physics_process(delta):
	touchInput()
