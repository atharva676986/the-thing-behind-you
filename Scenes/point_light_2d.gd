extends PointLight2D

@export var drain_per_second: float = 0.045
@export var min_energy_factor: float = 0
@export var min_scale_factor: float = 0.4


var charge: float = 1.0
var base_energy: float
var base_scale: float
var timer: float = 0
var flicker: float = 1
var blackout: bool = false

var bar: ProgressBar

func _ready() -> void:
	base_energy = energy
	base_scale = texture_scale
	bar = get_tree().current_scene.get_node_or_null("CanvasLayer/BatteryBar")
	
func recharge(amount: float) -> void:
	charge = minf(charge + amount, 1)
	
func trigger_scare(duration: float = 3) -> void:
	if blackout:
		return
	
	blackout = true
	energy = 0
	texture_scale = 0
	
	await get_tree().create_timer(duration).timeout
	
	blackout = false


func _process(delta: float) -> void:
	charge = maxf(charge - drain_per_second * delta, 0)
	
	if blackout:
		energy = 0
		texture_scale = 0
		if bar:
			bar.value = charge
		return
	
	timer -= delta
	if timer <= 0:
		var roll := randf()
		var dark_chance := 0.25 + (1.0 - charge) * 0.3
		if roll < dark_chance:
			flicker = 0
			timer = randf_range(0.1, 0.35)
		elif roll < dark_chance + 0.33:
			flicker = randf_range(0, 0.08)
			timer = randf_range(0.04, 0.15)
		else:
			flicker = 1
			timer = randf_range(0.2, 0.8)

	energy = base_energy + lerpf(min_energy_factor, 1, charge) * flicker
	texture_scale = base_scale * lerpf(min_scale_factor, 1, charge)

	if bar:
		bar.value = charge
