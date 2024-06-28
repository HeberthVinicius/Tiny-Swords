class_name Enemy
extends Node2D

@export_category("Health")
@export var health: int = 10
@export_category("Death")
@export var death_prefab: PackedScene
@export_category("Drops")
@export var drop_rate: float = 0.1
@export var drop_items: Array[PackedScene]
@export var drop_rates: Array[float]

@onready var damage_digit_marker: Marker2D  = $DamageDigitMarker

var damage_digit_prefab: PackedScene

func _ready() -> void:
	damage_digit_prefab = preload("res://enemies/damage_digit.tscn")


func damage(amount: int) -> void:
	health -= amount
	#print("Enemy received Damage ",amount, " Health ",health)
	
	#Blink Sprite
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate",Color.WHITE, 0.3)
	
	#Create Damage Digit
	var damage_digit: Node = damage_digit_prefab.instantiate()
	damage_digit.value = amount
	if damage_digit_marker:
		damage_digit.global_position = damage_digit_marker.global_position
	else:
		damage_digit.global_position = global_position
	
	get_parent().add_child(damage_digit)
	
	#Process Death
	if health <= 0:
		death()


func death() -> void:
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)

	if randf() <= drop_rate:
		item_drop()
		
	#Increment enemies_defeated_counter
	GameManager.enemies_defeated_counter += 1
	
	queue_free()


func item_drop() -> void:
	var drop = get_random_drop().instantiate()
	drop.position = position
	get_parent().add_child(drop)

func get_random_drop() -> PackedScene:
	if drop_items.size() == 1:
		return drop_items[0]

	# Calculate Max Rate
	var max_rate: float = 0.0
	for rate in drop_rates:
		max_rate += rate
	
	#draw drop rate
	var random_value = randf() * max_rate
	var prize: float = 0.0
	for i in drop_items.size():
		var droped_item = drop_items[i]
		var droped_rate = drop_rates[i] if i < drop_rates.size() else 1
		
		if random_value <= drop_rate + prize:
			return droped_item
		prize += droped_rate
	
	return drop_items[0]
