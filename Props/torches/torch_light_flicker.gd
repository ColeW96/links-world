extends PointLight2D


func _ready() -> void:
	flicker()
	pass


func flicker() -> void:
	energy = randf() * 0.05 + .9
	scale = Vector2( 1, 1 ) * energy
	await get_tree().create_timer( 0.1333 ).timeout
	flicker()
	pass
