extends Node2D

# export (int) var health = 2959;
export (String) var enemyname;
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("Label").text = enemyname;
	var rng = RandomNumberGenerator.new().randi_range(2500, 5000);
	get_node("../../Health/HealthContainer/Label").text = String(rng) + "/" + String(rng);

func blip():
	var sprite = get_node("Sprite");
	print("blipped")
	sprite.modulate = Color(1, 0, 0, 1)

func blipback():
	var sprite = get_node("Sprite");
	print("blipped back")
	sprite.modulate = Color(1, 1, 1, 1)
