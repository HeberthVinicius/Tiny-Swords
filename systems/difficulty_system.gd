extends Node

@export var mob_spawner: MobSpawner
@export var initial_spawn_rate: float = 60.0
@export var spawn_rate_per_minute: float  = 30.0
@export var wave_duration: float = 20.0
@export var brake_intensity: float = 0.5

var time: float = 0.0 

func _process(delta: float) -> void:
	if GameManager.is_game_over:
		return
		
	time += delta
	
	# Linear Difficulty
	var spawn_rate = initial_spawn_rate + spawn_rate_per_minute * time / 60
	# Wave Factor
	var sin_wave: float = sin((time * TAU) / wave_duration)
	var wave_factor: float = remap(sin_wave, -1, 1, brake_intensity, 1)
	
	spawn_rate *= wave_factor
	mob_spawner.mobs_per_minute = spawn_rate
