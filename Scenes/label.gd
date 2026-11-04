extends Label

var timer: float = 0

func _process(delta: float) -> void:
	timer -= delta
	if timer > 0:
		return
	var roll := randf()
	if roll < 0.25:
		modulate.a = 0.1
		timer = randf_range(0.05, 0.15)
	elif roll < 0.55:
		modulate.a = randf_range(0.4, 0.7)
		timer = randf_range(0.1, 0.5)
	else:
		modulate.a = 1
		timer = randf_range(0.3, 1.2)
		
