extends Area2D

@export var recharge_amount: float = 0.4

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		var light := body.get_node_or_null("PointLight2D")
		if light:
			light.recharge(recharge_amount)
			
		var pickup_audio := get_tree().current_scene.get_node_or_null("PickupAudio")
		if pickup_audio:
			pickup_audio.play()
			
		queue_free()
