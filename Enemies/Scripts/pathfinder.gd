class_name PathFinder extends Node2D

var vectors : Array[ Vector2 ] = [
		Vector2( 0, -1 ), #UP
		Vector2( 1, -1 ), #UP/RIGHT
		Vector2( 1, 0 ),  #RIGHT
		Vector2( 1, 1 ),  #DOWN/RIGHT
		Vector2( 0, 1 ),  #DOWN
		Vector2( -1, 1 ), #DOWN/LEFT
		Vector2( -1, 0 ), #LEFT
		Vector2( -1, -1 ) #UP/LEFT
]

var interests : Array[ float ]
var obstacles : Array[ float ] = [ 0, 0, 0, 0, 0, 0, 0, 0 ]
var outcomes : Array[ float ] = [ 0, 0, 0, 0, 0, 0, 0, 0 ]
var rays : Array[ RayCast2D ]

var move_dir : Vector2 = Vector2.ZERO
var best_path : Vector2 = Vector2.ZERO

@onready var timer: Timer = $Timer


func _ready() -> void:
	# gather all raycast2d nodes
	for c in get_children():
		if c is RayCast2D:
			rays.append( c )
	
	# normalize all vectors
	for i in vectors.size():
		vectors[ i ] = vectors[ i ].normalized()
	
	# perform initial pathfinder function
	set_path()
	
	# connect timer
	timer.timeout.connect( set_path )
	pass


func _process(delta: float) -> void:
	move_dir = lerp( move_dir, best_path, 10 * delta )
	pass


# Set the "best_path" vector by checking for desired direction and considering obstacles
func set_path() -> void:
	# get direction to player
	var player_dir : Vector2 = global_position.direction_to( PlayerManager.player.global_position )
	
	# reset obstacles and outcomes values to 0
	for i in 8:
		obstacles[ i ] = 0
		outcomes[ i ] = 0
	
	# check each raycast2d for collisions & update values in obstacles array
	for i in 8:
		if rays[ i ].is_colliding():
			obstacles[ i ] += 2
			obstacles[ get_next_i( i ) ] += 1
			obstacles[ get_prev_i( i ) ] += 1
	
	# if no obstacles, recommend path in direction of player
	if obstacles.max() == 0:
		best_path = player_dir
		return
	
	# populate interest array. This array contains values that represent
	# the desireability of each direction.
	interests.clear()
	for v in vectors:
		interests.append( v.dot( player_dir ) )
	
	# populate outcomes array by combining interests and obstacles arrays
	for i in 8:
		outcomes[ i ] = interests[ i ] - obstacles[ i ]
	
	# set the best path with the vector2 that corresponds with the
	# outcome with the highest value
	best_path = vectors[ outcomes.find( outcomes.max() ) ]
	pass


# returns the next index value, wrapping at 8
func get_next_i( i : int ) -> int:
	var n_i : int = i + 1
	if n_i >= 8:
		return 0
	else:
		return n_i


# returns the previous index value, wrapping at -1
func get_prev_i( i : int ) -> int:
	var p_i : int = i - 1
	if p_i < 0:
		return 7
	else:
		return p_i
