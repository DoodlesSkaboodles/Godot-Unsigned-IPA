extends CharacterBody2D

var speed = 320.0
var warning_duration = 2.0
var active = false
var points = 500

func launch(from: Vector2, to: Vector2):
	position = from
	var direction = (to - from).normalized()
	velocity = direction * speed
	$Sprite2D.visible = false
	$Area2D.monitoring = false
	active = false
	$AnimationPlayer.play("blink")
	$Warning2.pitch_scale = randf_range(0.8, 1.2)
	$Warning2.play()
	$Heaven.pitch_scale = randf_range(0.8, 1.2)
	$Heaven.play()
	await get_tree().create_timer(warning_duration).timeout
	$AnimationPlayer.stop()
	$Warning.visible = false
	$Sprite2D.visible = true
	$Area2D.monitoring = true
	$Walking.play()
	active = true

func _physics_process(_delta):
	if not active:
		return
	move_and_slide()
	rotation = velocity.angle() + PI / 2
	if position.x < -100 or position.x > get_tree().root.get_visible_rect().size.x + 100:
		queue_free()
	if position.y < -100 or position.y > get_tree().root.get_visible_rect().size.y + 100:
		queue_free()

func _on_area_2d_body_entered(body):
	if body.is_in_group("mower"):
		Poofer.spawn_poof(global_position)
		get_tree().get_first_node_in_group("score").add_points(points)
		Autosound.play($Collect.stream, randf_range(0.7, 1.3))
		$Area2D.set_deferred("monitoring", false)
		visible = false
		queue_free()
