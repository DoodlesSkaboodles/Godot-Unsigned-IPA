extends CharacterBody2D

var crossing_speed = 180.0
var chase_speed = 450.0
var warning_duration = 2.0
var active = false
var chasing = false
var fleeing = false

@export var powerbox_scene: PackedScene

func launch(from: Vector2, to: Vector2):
	position = from
	var direction = (to - from).normalized()
	velocity = direction * crossing_speed
	$Sprite2D.visible = false
	$Area2D.monitoring = false
	active = false
	$AnimationPlayer.play("blink")
	$Warning2.pitch_scale = randf_range(0.8, 1.2)
	$Warning2.play()
	await get_tree().create_timer(warning_duration).timeout
	$AnimationPlayer.stop()
	$Warning.visible = false
	$Sprite2D.visible = true
	$Area2D.monitoring = true
	$Walking.play()
	active = true
	await get_tree().create_timer(randf_range(1.2, 2.5)).timeout
	if active:
		drop_powerbox()

func drop_powerbox():
	var tilemap = get_tree().get_first_node_in_group("tilemap")
	if not tilemap.is_clear(position):
		return
	var powerbox = powerbox_scene.instantiate()
	powerbox.position = position
	powerbox.linked_robot = self
	get_parent().add_child(powerbox)
	$Walking.pitch_scale = 1.5
	chasing = true

func deactivate():
	chasing = false
	fleeing = true
	var screen = get_tree().root.get_visible_rect().size
	var exits = [
		Vector2(position.x, -100),
		Vector2(position.x, screen.y + 100),
		Vector2(-100, position.y),
		Vector2(screen.x + 100, position.y)
	]
	$Walking.pitch_scale = 1.0
	var target = exits.reduce(func(a, b): return a if position.distance_to(a) < position.distance_to(b) else b)
	velocity = (target - position).normalized() * chase_speed

func _physics_process(_delta):
	if not active:
		return
	if chasing:
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
		var boxes = get_tree().get_nodes_in_group("powerbox")
		for box in boxes:
			box.queue_free()
		get_tree().get_first_node_in_group("strikes").add_strike()
		queue_free()
