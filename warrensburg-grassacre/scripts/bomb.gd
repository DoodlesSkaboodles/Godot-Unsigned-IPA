extends Node2D

var fuse_duration = 4.0
var blast_radius = 120.0

func _ready():
	$Area2D/CollisionShape2D.shape.radius = blast_radius
	$Ticking.play()
	countdown()

func countdown():
	var time_left = fuse_duration
	while time_left > 0:
		$Label.text = str(ceil(time_left))
		await get_tree().create_timer(0.1).timeout
		time_left -= 0.1
	explode()

func explode():
	$Sprite2D.visible = false
	$Label.visible = false
	$Sprite2D2.visible = true
	$AnimatedSprite2D.visible = false
	$Sprite2D2.frame = 0
	$Sprite2D2.play("default")
	$Ticking.stop()
	$Explode.play()
	get_tree().get_first_node_in_group("mower").shake(8.0, 0.4)
	var mower = get_tree().get_first_node_in_group("mower")
	if mower and position.distance_to(mower.position) < blast_radius:
		get_tree().get_first_node_in_group("strikes").add_strike()
	await get_tree().create_timer(1.5).timeout
	queue_free()

func _on_sprite_2d_2_animation_finished():
	$Sprite2D2.visible = false
