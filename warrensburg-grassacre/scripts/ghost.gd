extends CharacterBody2D

var speed = 180.0
var warning_duration = 2.0
var active = false

func launch(from: Vector2, to: Vector2):
	position = from
	var direction = (to - from).normalized()
	velocity = direction * speed
	$Sprite2D.visible = false
	active = false
	$AnimationPlayer.play("blink")
	$Warning2.pitch_scale = randf_range(0.8, 1.2)
	$Ghostly.pitch_scale = randf_range(0.4, 0.8)
	$Ghostly.play()
	$Warning2.play()
	await get_tree().create_timer(warning_duration).timeout
	$AnimationPlayer.stop()
	$Warning.visible = false
	$Sprite2D.visible = true
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
