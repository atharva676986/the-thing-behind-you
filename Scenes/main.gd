extends Node2D

var fuses: int = 0
var total_fuses: int = 6
var won: bool = false

@onready var fuse_label: Label = $CanvasLayer/Label
@onready var pickup_audio: AudioStreamPlayer = $PickupAudio
@onready var death_audio: AudioStreamPlayer = $DeathAudio
@onready var vignette: TextureRect = $CanvasLayer/Vignette

var message_label: Label


func _ready() -> void:
	message_label = Label.new()
	message_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	message_label.add_theme_font_size_override("font_size", 40)
	message_label.add_theme_color_override("font_color", Color.RED)
	message_label.add_theme_color_override("font_outline_color", Color.BLACK)
	message_label.add_theme_constant_override("outline_size", 8)
	$CanvasLayer.add_child(message_label)
	
func play_pickup() -> void:
	pickup_audio.play()	

func add_fuse() -> void:
	play_pickup()
	fuses += 1
	fuse_label.text = "Fuses: %d/%d" % [fuses, total_fuses]
	fuse_label.pivot_offset = fuse_label.size / 2
	fuse_label.scale = Vector2(1.6, 1.6)
	fuse_label.modulate = Color(1, 0.9, 0.2)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(fuse_label, "scale", Vector2.ONE, 0.3)
	tween.tween_property(fuse_label, "modulate", Color.WHITE, 0.3)
	
func show_death() -> void:
	if won:
		return
	message_label.text = "You Died"	
	death_audio.play()
	
	
func try_exit() -> void:
	if won:
		return
	if fuses >= total_fuses:
		won = true
		message_label.text = "You Have Escaped For Now."
		$Player.set_physics_process(false)
		$Ghost.set_physics_process(false)
		await get_tree().create_timer(4.0).timeout
		get_tree().change_scene_to_file("res://Scenes/title.tscn")
	else:
		message_label.text = "Collect All The Fuses To Escape"
		await get_tree().create_timer(2.0).timeout
		if not won:
			message_label.text = ""
			
func _process(_delta: float) -> void:
	if won or not has_node("Ghost") or not has_node("Player"):
		vignette.modulate.a = 0
		return
	var dist: float = absf($Ghost.global_position.x - $Player.global_position.x)
	var danger: float = clampf(1 - dist / 350, 0, 1)
	var pulse: float = 0.75 + 0.25 * sin(Time.get_ticks_msec() * 0.012 * (1 + danger * 2))
	vignette.modulate.a = danger * pulse * 0.4
