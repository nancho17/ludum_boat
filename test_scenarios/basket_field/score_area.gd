extends Area3D

signal point_from_player(data:int)

func _ready() -> void:
	body_entered.connect(aferer)

func aferer(body : Node):
	print("Score!",body)
	#body.player_last_touched
	point_from_player.emit(15)
