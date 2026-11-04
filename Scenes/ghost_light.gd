extends PointLight2D

var base_energy: float
var timer: float = 0

func _ready() -> void:
	base_energy = energy

func _process(delta: float) -> void:
	timer -= delta
	if timer > 0:
		return
	var roll := randf()
	if roll < 0.15:
		energy = base_energy * 0.1
		timer = randf_range(0.05, 0.2)
	elif roll < 0.4:
		energy = base_energy * randf_range(0.4, 0.7)
		timer = randf_range(0.05, 0.15)
	else:
		energy = base_energy
		timer = randf_range(0.2, 0.7)
		
		
