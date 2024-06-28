class_name MobSpawner
extends Node2D

@export var creatures: Array[PackedScene]

@onready var path_follow_2d: PathFollow2D = %PathFollow2D

var mobs_per_minute: float = 60.0
var cooldown: float = 0.0

func _process(delta: float) -> void:
	if GameManager.is_game_over:
		return
	
	#Timer
	cooldown -= delta
	if cooldown > 0:
		return
		
	#Frequency
	var interval: float = 60 / mobs_per_minute
	cooldown = interval
	
	#Check if it's a valid point 
	var point = get_point()
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = point
	parameters.collision_mask = 0b1001
	var world_state = get_world_2d().direct_space_state
	var result = world_state.intersect_point(parameters, 1)
	
	if not result.is_empty():
		return
	
	#Instance a new  random creature
	var index: int = randi_range(0, creatures.size() - 1)
	var creature_scene = creatures[index]
	
	#Instance creature packed scene
	var creature = creature_scene.instantiate()
	
	#Difine position point
	creature.position = get_point()
	
	#Definr the parent
	get_parent().add_child(creature)
	
func get_point() -> Vector2:
	path_follow_2d.progress_ratio = randf()
	return path_follow_2d.global_position
