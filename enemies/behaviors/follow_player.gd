extends Node

@export var speed: float = 1

var enemy: Enemy
var animated_sprite: AnimatedSprite2D

func _ready() -> void:
	enemy = get_parent()
	animated_sprite = enemy.get_node("AnimatedSprite2D")

func _physics_process(_delta: float) -> void:
	# Calc Direction
	var player_position: Vector2 = GameManeger.player_position
	var diference: Vector2 = player_position - enemy.position
	var input_vector: Vector2 = diference.normalized()
	
	#Movement
	enemy.velocity = input_vector * speed * 100.0
	enemy.move_and_slide()

	#rotate sprite
	if input_vector.x > 0:
		animated_sprite.flip_h = false
	elif input_vector.x < 0:
		animated_sprite.flip_h = true
