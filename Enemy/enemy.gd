class_name Enemy extends RigidBody2D

@export var damage := 3.0
@export var health := 100.0

@export var max_speed := 50.0
@export var acceleration := 15.0

@onready var cake := Cake.instance

func _physics_process(_delta):
	var goal := cake.global_position - global_position
	var goal_hat := goal.normalized()
	
	apply_central_force(goal_hat * acceleration * mass)
	
	#velocity += goal * acceleration * delta
	#velocity = velocity.limit_length(max_speed)
	#move_and_slide()
	

func take_damage(amount: float):
	health -= amount

	if health <= 0:
		queue_free()
	
	modulate = Color.RED
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	modulate = Color.WHITE