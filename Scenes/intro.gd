extends Control

@onready var story_text: Label = $StoryText
@onready var continue_button: Button = $ContinueButton
@onready var skip_button: Button = $SkipButton

var full_text := [
	"There are places that remember.",
	"Places that keep what should have been forgotten.",
	"Some doors are locked to keep things out.",
	"Others, to keep things in.",
	"And some things......",
	"Remember the way you came."
]

@export var fade_duration: float = 0.8
@export var character_delay: float = 0.025
@export var sentence_pause: float = 0.8
@export var transition_duration: float = 0.5
@export var hold_time: float = 2.5

var current_line: int = 0
var is_playing: bool = false
var can_continue: bool = false
var skip_requested: bool = false
var transitioning: bool = false

var flicker_strength: float = 0.04

func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)
	skip_button.pressed.connect(_on_skip_pressed)
	

	
	story_text.text = ""
	story_text.modulate.a = 0
	continue_button.modulate.a = 0
	
	continue_button.disabled = true
	
	await get_tree().create_timer(1).timeout
	if not transitioning:
		_play_story()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if is_playing:
			skip_requested = true
		elif can_continue:
			_on_continue_pressed()

func _play_story() -> void:
	is_playing = true
	
	for i in range(full_text.size()):
		if transitioning:
			return
			
		current_line = i
		await _show_line(full_text[i])
		print("Finished line: ", i)
		
		if transitioning:
			return
		
		if i < full_text.size() - 1:
			await get_tree().create_timer(hold_time).timeout
			await _fade_out_text()
			await get_tree().create_timer(sentence_pause).timeout
			if transitioning:
				return
	await _finish_intro()
	
func _show_line(line: String) -> void:
	skip_requested = false
	story_text.text = ""
	story_text.modulate.a = 0
	
	var fade := create_tween()
	fade.tween_property(
		story_text,
		"modulate:a",
		1,
		fade_duration
	)

	for character in line:
		if skip_requested:
			skip_requested = false
			story_text.text = line
			break
			
		story_text.text += character
		await get_tree().create_timer(character_delay).timeout
	if fade.is_running():
		await fade.finished
		
func _fade_out_text() -> void:
	var tween := create_tween()
	tween.tween_property(
		story_text,
		"modulate:a",
		0,
		transition_duration
	)
	await tween.finished
	
func _finish_intro() -> void:
	is_playing = false
	can_continue = true
	skip_button.hide()
	
	var button_tween := create_tween()
	button_tween.tween_property(
		continue_button,
		"modulate:a",
		1,
		1.5
	)
	
	continue_button.disabled = false
	
	
	
func _process(_delta: float) -> void:
	if not is_playing or transitioning:
		return
		
	var flicker := randf_range(
		1 - flicker_strength,
		1
	)
	
	story_text.modulate.r = flicker
	story_text.modulate.g = flicker
	story_text.modulate.b = flicker
	
func _on_skip_pressed() -> void:
	_transition_to_game()	
	
func _on_continue_pressed() -> void:
	if not can_continue:
		return
	
	_transition_to_game()	
		
func _transition_to_game() -> void:
	if transitioning:
		return
		
	transitioning = true
	is_playing = false
	can_continue = false
	
	skip_button.disabled = true
	continue_button.disabled = true
	
	var tween := create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(story_text, "modulate:a", 0, 0.8)
	tween.tween_property(continue_button, "modulate:a", 0, 0.8)
	tween.tween_property(skip_button, "modulate:a", 0, 0.8)
	
	await tween.finished
	
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
