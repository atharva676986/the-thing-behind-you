extends Area2D

@export var base_speed: float = 160
@export var speed_per_fuse: float = 25
@export var point_spacing: float = 6.0
@export var run_at_fuses: int = 2

@export var heartbeat_max_distance: float = 500
@export var heartbeat_min_volume: float = -30

var player: Node2D
var trail: Array[Vector2] = []
var last_recorded: Vector2

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var heartbeat: AudioStreamPlayer = get_parent().get_node("HeartbeatAudio")

func _ready() -> void:
	player = get_parent().get_node("Player")
	body_entered.connect(_on_body_entered)
	anim.play("walk")
	last_recorded = player.global_position
	trail.append(last_recorded)

func _physics_process(delta: float) -> void:
	if player == null:
		return

	var distance := global_position.distance_to(player.global_position)
	_update_heartbeat(distance)

	if player.global_position.distance_to(last_recorded) >= point_spacing:
		last_recorded = player.global_position
		trail.append(last_recorded)

	var fuses: int = get_parent().fuses
	var speed: float = base_speed + speed_per_fuse * fuses
	var budget: float = speed * delta
	var start_x: float = global_position.x

	while budget > 0.0:
		if trail.is_empty():
			global_position = global_position.move_toward(player.global_position, budget)
			break
		var target: Vector2 = trail[0]
		var dist: float = global_position.distance_to(target)
		if dist > budget:
			global_position = global_position.move_toward(target, budget)
			break
		global_position = target
		budget -= dist
		trail.pop_front()

	var dx: float = global_position.x - start_x
	if absf(dx) > 0.01:
		anim.flip_h = dx < 0.0

	_update_animation(fuses)
	
func _update_heartbeat(distance: float) -> void:
	if distance <= heartbeat_max_distance:
		if not heartbeat.playing:
			heartbeat.play()
			
		var closeness := 1 - (distance / heartbeat_max_distance)
		heartbeat.volume_db = lerpf(heartbeat_min_volume +24, 24, closeness)
	else:
		if heartbeat.playing:
			heartbeat.stop()
	
	
func _update_animation(fuses: int) -> void:
	var wanted: String = "run" if fuses >= run_at_fuses else "walk"
	if anim.sprite_frames.has_animation(wanted) and anim.animation != wanted:
		anim.play(wanted)
	
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		set_physics_process(false)
		anim.flip_h = body.global_position.x < global_position.x
		
		if anim.sprite_frames.has_animation("attack"):
			anim.play("attack")
		
		body.die()
