extends Node2D;

# State machine
enum { wait, move };
var state;

# Grid variables
export (int) var width;
export (int) var height;
export (int) var offset;
export (int) var x_start;
export (int) var y_start;
export (int) var y_offset;

# Pieces array
var possible_pieces = [
	preload("res://Scenes/BluePiece.tscn"),
	preload("res://Scenes/RedPiece.tscn"),
	preload("res://Scenes/YellowPiece.tscn"),
	preload("res://Scenes/GreenPiece.tscn")
];

# Enemies array
var enemies = [
	preload("res://Scenes/red sus meme.tscn")
];

# Enemy health
export (int) var health = 2959;
var current_health = health;

# Current pieces in the scene
var all_pieces = [];
var current_matches = [];

# Swap back variables
var piece_one = null;
var piece_two = null;
var last_place = Vector2(0, 0);
var last_direction = Vector2(0, 0);
var move_checked = false;

# Touch variables
var first_touch = Vector2(0, 0);
var last_touch = Vector2(0, 0);
var controlling = false;

# Scoring variables
var piece_value = 10;
var match_value = 100;
var combo_value = 50;
var streak = 1;

# Called when the node enters the scene tree for the first time.
func _ready():
	state = move;
	randomize();
	all_pieces = make_array();
	print(all_pieces);
	spawn();
	enemy();

func make_array():
	var array = [];
	for i in width:
		array.append([]);
		for j in height:
			array[i].append(null);
	return array;

func enemy():
	var rand = floor(rand_range(0, enemies.size()));
	var enemy = enemies[rand].instance();
	add_child(enemy);

func spawn():
	for i in width:
		for j in height:
			var rand = floor(rand_range(0, possible_pieces.size()));
			var piece = possible_pieces[rand].instance();
			var loops = 0;
			while(match_at(i, j, piece.color) && loops < 100):
				rand = floor(rand_range(0, possible_pieces.size()));
				loops += 1;
				piece = possible_pieces[rand].instance();
			add_child(piece);
			piece.position = grid_to_pixel(i, j);
			all_pieces[i][j] = piece;

func match_at(i, j, color):
	if i > 1:
		if all_pieces[i - 1][j] != null && all_pieces[i - 2][j] != null:
			if all_pieces[i - 1][j].color == color && all_pieces[i - 2][j].color == color:
				return true;
	if j > 1:
		if all_pieces[i][j - 1] != null && all_pieces[i][j - 2] != null:
			if all_pieces[i][j - 1].color == color && all_pieces[i][j - 2].color == color:
				return true;
	pass;

func is_in_grid(grid_position):
	if grid_position.x >= 0 && grid_position.x < width:
		if grid_position.y >= 0 && grid_position.y < height:
			return true;
	return false; 

func grid_to_pixel(column, row):
	var new_x = x_start + offset * column;
	var new_y = y_start - offset * row;
	return Vector2(new_x, new_y);

func pixel_to_grid(pixel_x,pixel_y):
	var new_x = round((pixel_x - x_start) / offset);
	var new_y = round((y_start - pixel_y) / offset);
	return Vector2(new_x, new_y);

func touch_input():
	if Input.is_action_just_pressed("ui_touch"):
		var temp_grid = pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y);
		if is_in_grid(temp_grid):
			first_touch = temp_grid;
			controlling = true;
	if Input.is_action_just_released("ui_touch"):
		var temp_grid = pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y);
		if is_in_grid(temp_grid) && controlling:
			last_touch = temp_grid;
			touch_difference(first_touch, last_touch);
			controlling = false;

func swap(column, row, direction):
	var first_piece = all_pieces[column][row];
	var other_piece = all_pieces[column + direction.x][row + direction.y];
	if first_piece != null && other_piece != null:
		store_info(first_piece, other_piece, Vector2(column, row), direction);
		state = wait;
		all_pieces[column][row] = other_piece;
		all_pieces[column + direction.x][row + direction.y] = first_piece;
		first_piece.move(grid_to_pixel(column + direction.x, row + direction.y));
		other_piece.move(grid_to_pixel(column,row));
		if !move_checked:
			find_matches();

func store_info(first_piece, other_piece, place, direction):
	piece_one = first_piece;
	piece_two = other_piece;
	last_place = place;
	last_direction = direction;
	pass;

func touch_difference(grid_1, grid_2):
	var difference = grid_2 - grid_1;
	if abs(difference.x) > abs(difference.y):
		if difference.x > 0:
			swap(grid_1.x, grid_1.y, Vector2(1, 0));
		elif difference.x < 0:
			swap(grid_1.x, grid_1.y, Vector2(-1, 0));
	elif abs(difference.y) > abs(difference.x):
		if difference.y > 0:
			swap(grid_1.x, grid_1.y, Vector2(0, 1));
		elif difference.y < 0:
			swap(grid_1.x, grid_1.y, Vector2(0, -1));

func match_and_dim(item):
	item.matched = true;
	item.dim();

func find_matches():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				var current_color = all_pieces[i][j].color;
				if i > 0 && i < width - 1:	
					if all_pieces[i - 1][j] != null && all_pieces[i + 1][j] != null:
						if all_pieces[i - 1][j].color == current_color && all_pieces[i + 1][j].color == current_color:
							match_and_dim(all_pieces[i - 1][j]);
							match_and_dim(all_pieces[i][j]);
							match_and_dim(all_pieces[i + 1][j]);
				if j > 0 && j < height - 1:
					if all_pieces[i][j - 1] != null && all_pieces[i][j + 1] != null:
						if all_pieces[i][j-1].color == current_color && all_pieces[i][j+1].color == current_color:
							match_and_dim(all_pieces[i][j - 1]);
							match_and_dim(all_pieces[i][j]);
							match_and_dim(all_pieces[i][j + 1]);
	get_parent().get_node("destroy_timer").start();

func destroy_matched():
	var was_matched = false;
	var count_matched = 0;
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if all_pieces[i][j].matched:
					count_matched += 1;
					was_matched = true;
					all_pieces[i][j].queue_free();
					all_pieces[i][j] = null;
	move_checked = true;
	if was_matched:
		current_health -= piece_value * count_matched + match_value + combo_value * (streak - 1);
		if current_health <= 0:
			change_enemy();
		else:
			get_node("../Health/HBoxContainer/Label").text = String(current_health) + "/" + String(health);
			get_parent().get_node("collapse_timer").start();
	else:
		swap_back();
		streak = 1;

func change_enemy():
	pass;

func swap_back():
	if piece_one != null && piece_two != null:
		swap(last_place.x, last_place.y, last_direction);
	state = move;
	move_checked = false;
	pass;

func collapse_collumn():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null:
				for k in range(j + 1, height):
					if all_pieces[i][k] != null:
						all_pieces[i][k].move(grid_to_pixel(i, j));
						all_pieces[i][j] = all_pieces[i][k];
						all_pieces[i][k] = null;
						break;
	get_parent().get_node("refill_timer").start();

func refill():
	streak += 1;
	for i in width:
		for j in height:
			if all_pieces[i][j] == null:
				var rand = floor(rand_range(0, possible_pieces.size()));
				var piece = possible_pieces[rand].instance();
				var loops = 0;
				while(match_at(i, j, piece.color) && loops < 100):
					rand = floor(rand_range(0, possible_pieces.size()));
					loops += 1;
					piece = possible_pieces[rand].instance();
				add_child(piece);
				piece.position = grid_to_pixel(i, j - y_offset); # +
				piece.move(grid_to_pixel(i, j));
				all_pieces[i][j] = piece;
	after_refill();

func after_refill():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if match_at(i, j, all_pieces[i][j].color):
					find_matches();
					get_parent().get_node("destroy_timer").start();
					return;
	state = move;
	move_checked = false;

func _physics_process(_delta):
	if state == move:
		touch_input();

func _on_destroy_timer_timeout():
	destroy_matched();

func _on_collapse_timer_timeout():
	collapse_collumn();

func _on_refill_timer_timeout():
	refill();
