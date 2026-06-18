extends Area2D

@export var partner: NodePath
var on_cooldown = false
var mower_inside = false

func _on_body_entered(body):
	if body.is_in_group("mower"):
		mower_inside = true
		$Sprite2D2.visible = true

func _on_body_exited(body):
	if body.is_in_group("mower"):
		mower_inside = false
		$Sprite2D2.visible = false

func _process(_delta):
	if mower_inside and not on_cooldown and Input.is_action_just_pressed("use"):
		var target = get_node(partner)
		if target and not target.on_cooldown:
			$Sewer.play()
			on_cooldown = true
			target.on_cooldown = true
			get_tree().get_first_node_in_group("mower").global_position = target.global_position
			mower_inside = false
			await get_tree().create_timer(0.5).timeout
			on_cooldown = false
			target.on_cooldown = false
