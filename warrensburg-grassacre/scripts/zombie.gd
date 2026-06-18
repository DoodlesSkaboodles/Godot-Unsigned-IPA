extends CharacterBody2D

var chase_speed = 400.0
var flee_speed = 350.0
var warning_duration = 2.0
var chase_duration = 5.0
var active = false
var fleeing = false

func launch(from: Vector2, _to: Vector2):
	position = from
	$Sprite2D.visible = false
	$Area2D.monitoring = false
	active = false
	$AnimationPlayer.play("blink")
	$Warning2.pitch_scale = randf_range(0.8, 1.2)
	$Groan.pitch_scale = randf_range(0.8, 1.2)
	$Warning2.play()
	$Groan.play()
	await get_tree().create_timer(warning_duration).timeout
	$AnimationPlayer.stop()
	$Warning.visible = false
	$Sprite2D.visible = true
	$Area2D.monitoring = true
	$Walking.play()
	active = true
	chase()

func chase():
	await get_tree().create_timer(chase_duration).timeout
	flee()

func flee():
	fleeing = true
	var screen = get_tree().root.get_visible_rect().size
	var exits = [
		Vector2(position.x, -100),
		Vector2(position.x, screen.y + 100),
		Vector2(-100, position.y),
		Vector2(screen.x + 100, position.y)
	]
	var target = exits.reduce(func(a, b): return a if position.distance_to(a) < position.distance_to(b) else b)
	velocity = (target - position).normalized() * flee_speed
	$Walking.pitch_scale = 1.0

func _physics_process(_delta):
	if not active:
		return
	if not fleeing:
		var mower = get_tree().get_first_node_in_group("mower")
		if mower:
			velocity = (mower.position - position).normalized() * chase_speed
	move_and_slide()
	rotation = velocity.angle() + PI / 2
	if position.x < -100 or position.x > get_tree().root.get_visible_rect().size.x + 100:
		queue_free()
	if position.y < -100 or position.y > get_tree().root.get_visible_rect().size.y + 100:
		queue_free()

func _on_area_2d_body_entered(body):
	if body.is_in_group("mower"):
		Poofer.spawn_poof(global_position)
		get_tree().get_first_node_in_group("strikes").add_strike()
		queue_free()
