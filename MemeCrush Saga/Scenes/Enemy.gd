extends Node2D

# export (int) var health = 2959;
export (String) var enemyname;
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("Label").text = enemyname;

func blip():
	var sprite = get_node("Sprite");
	print("blipped")
	sprite.modulate = Color(1, 0, 0, 1)

func blipback():
	var sprite = get_node("Sprite");
	print("blipped back")
	sprite.modulate = Color(1, 1, 1, 1)
