extends CharacterBody2D

var speed = 80.0
var warning_duration = 2.0
var active = false
var stop_chance = 0.002
var stop_duration = 2.0

func launch(from: Vector2, to: Vector2):
	position = from
	var direction = (to - from).normalized()
	velocity = direction * speed
	$Sprite2D.visible = false
	$Area2D.monitoring = false
	active = false
	$AnimationPlayer.play("blink")
	$Warning2.pitch_scale = randf_range(0.5, 0.8)
	$Warning2.play()
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
	if randf() < stop_chance:
		stop()
	if position.x < -100 or position.x > get_tree().root.get_visible_rect().size.x + 100:
		queue_free()
	if position.y < -100 or position.y > get_tree().root.get_visible_rect().size.y + 100:
		queue_free()

func stop():
	var stored_velocity = velocity
	velocity = Vector2.ZERO
	active = false
	$Sprite2D.animation = "paused"
	$Walking.stop()
	await get_tree().create_timer(stop_duration).timeout
	velocity = stored_velocity
	$Sprite2D.animation = "default"
	$Walking.play()
	active = true

func _on_area_2d_body_entered(body):
	if body.is_in_group("mower"):
		Poofer.spawn_poof(global_position)
		get_tree().get_first_node_in_group("strikes").add_strike()
		queue_free()
