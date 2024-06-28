class_name GameOverUI
extends CanvasLayer

@onready var count_time_label: Label = %CountTimeLabel
@onready var count_enemies_label: Label = %CountEnemiesLabel

@export var restart_dealay: float = 10.0

var restart_cooldown: float

func _ready() -> void:
	count_time_label.text = GameManager.time_elapsed_string
	count_enemies_label.text = str(GameManager.enemies_defeated_counter)
	restart_cooldown = restart_dealay

func _process(delta: float) -> void:
	restart_cooldown -= delta
	if restart_cooldown <= 0.00:
		restart_game()
		

func restart_game() -> void:
	GameManager.reset()
	get_tree().reload_current_scene()
