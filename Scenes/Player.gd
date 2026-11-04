extends CharacterBody2D

@export var speed: float = 180
@export var gravity: float = 900
@export var fall_gravity: float = 1500
@export var jump_velocity: float = -520

var dead: bool = false

@export var coyote_time: float = 0.1
@export var jump_buffer_time = 0.1
@export var max_fall_speed: float = 800

var coyote_timer: float = 0
var buffer_timer: float = 0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	if dead:
		velocity.x = 0
		velocity.y += fall_gravity * delta
		move_and_slide()
		return
	
	var direction := Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * speed
	
	var jump_pressed := (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up"))
	var jump_released := (Input.is_action_just_released("ui_accept") or Input.is_action_just_released("ui_up"))
	
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta
	if jump_pressed:
		buffer_timer = jump_buffer_time
	else:
		buffer_timer -= delta
	if buffer_timer > 0 and coyote_timer > 0:
		velocity.y = jump_velocity
		buffer_timer = 0
		coyote_timer = 0
	
	if not is_on_floor():
		if velocity.y < 0:
			velocity.y += gravity * delta
		else:
			velocity.y += fall_gravity * delta
		velocity.y = minf(velocity.y, max_fall_speed)
	
	if jump_released and velocity.y < 0:
		velocity.y = 0
	move_and_slide()
	_update_animation(direction)
	
func _update_animation(direction: float) -> void:
	if direction != 0:
		anim.flip_h = direction < 0
		
	if not is_on_floor():
		if velocity.y < 0:
			_play("jump")
		else:
			_play("fall")
	elif direction != 0:
		_play("walk")
	else:
		_play("idle")

func _play(name: String) -> void:
	if anim.animation != name:
		anim.play(name)

func die() -> void:
	if dead:
		return
	dead = true
	anim.play("death")
	_shake()
	var level := get_parent()
	if level.has_method("show_death"):
		level.show_death()
	await get_tree().create_timer(1.6).timeout
	get_tree().change_scene_to_file("res://Scenes/title.tscn")
	
	
func _shake() -> void:
	var cam := get_node_or_null("Camera2d") as Camera2D
	if cam == null:
		return
	var tween := create_tween()
	for i in 8:
		tween.tween_property(cam, "offset", Vector2(randf_range(-8,8),randf_range(-8, 8)), 0.04)
	tween.tween_property(cam, "offset", Vector2.ZERO, 0.04)
