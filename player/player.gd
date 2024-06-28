class_name Player
extends CharacterBody2D


signal meat_collected(value: int)
signal gold_collected(value: int)


@export_category("Movement")
@export var speed: float = 3
@export_category("Sword")
@export var sword_damage = 4
@export_category("Spell")
@export var spell_damage: int = 7
@export var spell_interval: float = 15.0
@export var spell_prefab: PackedScene
@export_category("Life")
@export var health: int = 50
@export var max_health: int = 50
@export var death_prefab: PackedScene


@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sword_area: Area2D = $SwordArea
@onready var hit_box_area: Area2D = $HitBoxArea
@onready var health_progress_bar: ProgressBar = $HealthProgressBar


enum Direction { UP, DOWN, LEFT, RIGHT, NONE }


var movement_direction = Direction.NONE
var input_vector: Vector2 = Vector2(0,0)
var is_running: bool = false
var was_running: bool = false
var is_attacking: bool = false
var attack_cooldown: float = 0.0
var hit_box_cooldown: float = 0.0
var spell_cooldown: float = 0.0


func _ready() -> void:
	GameManager.player = self
	meat_collected.connect(
		func(value: int): 
			GameManager.meat_counter += 1
	)
	gold_collected.connect(
		func(value: int): 
			GameManager.gold_counter += 1
	)

func _process(delta: float) -> void:
	GameManager.player_position = position
	#Read Input
	get_input()
	#Process attack and cooldown
	update_attack_cooldown(delta)

	if Input.is_action_just_pressed("attack"):
		performe_attack()
	
	#Process animation and rotation of sprite
	play_run_idle_animation()
	if not is_attacking:
		rotate_sprite()

	#Process Damage
	update_hitbox_detection(delta)
	
	#Process Spell
	update_spell(delta)

	#Process Health
	update_health_progress_bar()


func _physics_process(_delta: float) -> void:
	#Modify velocity
	var target_velocity = input_vector * speed * 100.0
	if is_attacking:
		target_velocity *= 0.25

	velocity = lerp(velocity, target_velocity,0.05)
	move_and_slide()

#Update attack_cooldown
func update_attack_cooldown(delta: float) -> void:
	if is_attacking:
		attack_cooldown -= delta
		if attack_cooldown <= 0.0:
			is_attacking = false
			is_running = false
			play_run_idle_animation()
			#animation_player.play("idle") 


func update_spell(delta: float) -> void:
	spell_cooldown -= delta
	if spell_cooldown > 0:
		return
		
	spell_cooldown = spell_interval
	
	#Cast the spell
	if GameManager.enemies_defeated_counter >= 10:
		var spell = spell_prefab.instantiate()
		spell.damage_amount = spell_damage
		add_child(spell)


func get_input() -> void:
	#Get input_vector
	input_vector = Input.get_vector("move_left", "move_right", "move_up",
	 "move_down")
	
	#Detemine the direction based on input vector
	if input_vector.y < 0:
		movement_direction = Direction.UP
	elif input_vector.y > 0:
		movement_direction = Direction.DOWN
	elif input_vector.x < 0:
		movement_direction = Direction.LEFT
	elif input_vector.x > 0:
		movement_direction = Direction.RIGHT
	else:
		movement_direction = Direction.NONE
		
	#Delete dead_zone from input_vector
	var dead_zone: float = 0.15
	
	
	if abs(input_vector.x) < dead_zone:
		input_vector.x = 0.0
		
	if abs(input_vector.y) < dead_zone:
		input_vector.y = 0.0

	#Update is_running
	was_running = is_running
	is_running = not input_vector.is_zero_approx()


func play_run_idle_animation() -> void:
	#Play animation_player
	if not is_attacking: #FIXME: Verify movement issue
		if was_running != is_running:
			if is_running:
				animation_player.play("run")
			else:
				animation_player.play("idle")


func rotate_sprite() -> void:
	#Flip Sprite2D
	if input_vector.x > 0:
		sprite.flip_h = false
	elif input_vector.x < 0:
		sprite.flip_h = true


func performe_attack() -> void:
	if is_attacking:
		return

	#Play attack animation
	match movement_direction:
		Direction.UP:
			attack_up()
		Direction.DOWN:
			attack_down()
		Direction.LEFT:
			attack_left()
		Direction.RIGHT:
			attack_right()
		Direction.NONE:
			attack_default()

	attack_cooldown = 0.6
	is_attacking = true


func attack_up():
	animation_player.play("attack_up_1")


func attack_down():
	animation_player.play("attack_down_1")


func attack_left():
	animation_player.play("attack_side_2")


func attack_right():
	animation_player.play("attack_side_2")


func attack_default():
	animation_player.play("attack_side_1")


func deal_demage_to_enemies() -> void:
	var bodies = sword_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var direction_to_enemy = (enemy.position - position).normalized()
			var attack_direction: Vector2
			
			if sprite.flip_h:
				attack_direction = Vector2.LEFT
			else:
				attack_direction = Vector2.RIGHT
			
			var dot_product = direction_to_enemy.dot(attack_direction)
			
			if dot_product > 0.3:
				enemy.damage(sword_damage)


func update_hitbox_detection(delta: float) ->void:
	hit_box_cooldown -= delta
	if hit_box_cooldown > 0:
		return
		
	hit_box_cooldown = 0.5
	
	# Detect Enemies
	var bodies = hit_box_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			#var enemy: Enemy = body
			var damage_amount = 1
			damage(damage_amount)


func damage(amount: int) -> void:
	if health <= 0:
		return
		
	health -= amount
	#print("Player received Damage ",amount, " Health ",health)
	
	#Blink Sprite
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate",Color.WHITE, 0.3)
	
	#Process Death
	if health <= 0:
		death()


func death() -> void:
	GameManager.end_game()
	
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
		
	queue_free()


func heal(amount: int) -> int:
	health += amount
	if health >= max_health:
		health = max_health
	return health


func update_health_progress_bar() -> void:
	health_progress_bar.max_value = max_health
	health_progress_bar.value = health
