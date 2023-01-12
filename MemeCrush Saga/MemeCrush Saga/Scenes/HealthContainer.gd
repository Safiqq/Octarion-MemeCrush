extends TextureRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var health = get_parent().get_node("grid").current_health

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("HealthContainer/Label").text = String(health) + "/" + String(health)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
