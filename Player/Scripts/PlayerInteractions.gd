class_name PlayerInteractions extends Node2D

@onready var player: Player = $".."


func _ready() -> void:
	player.DirectionChanged.connect( UpdateDirection )
	pass
	
	
func UpdateDirection( new_direction : Vector2 ) -> void:
	match new_direction:
		Vector2.DOWN:
			rotation_degrees = 0
			position = Vector2(1,-16)
		Vector2.UP:
			rotation_degrees = 180
			position = Vector2(-1,-1)
		Vector2.LEFT:
			rotation_degrees = 90
			position = Vector2(7,-7)
			
		Vector2.RIGHT:
			rotation_degrees = -90
			position = Vector2(-7, -9)
		_:
			rotation_degrees = 0
			position = Vector2(1,-16)
	pass
