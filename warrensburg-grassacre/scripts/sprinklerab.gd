extends CharacterBody2D

var speed = 180.0
var warning_duration = 2.0
var active = false

@export var sprinkler_scene: PackedScene

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
	await get_tree().create_timer(warning_duration).timeout
	$AnimationPlayer.stop()
	$Warning.visible = false
	$Sprite2D.visible = true
	$Area2D.monitoring = true
	$Walking.play()
	active = true
	await get_tree().create_timer(randf_range(1.2, 2.5)).timeout
	if active:
		drop_sprinkler()

func _physics_process(_delta):
	if not active:
		return
	move_and_slide()
	rotation = velocity.angle() + PI / 2
	if position.x < -100 or position.x > get_tree().root.get_visible_rect().size.x + 100:
		queue_free()
	if position.y < -100 or position.y > get_tree().root.get_visible_rect().size.y + 100:
		queue_free()

func drop_sprinkler():
	var tilemap = get_tree().get_first_node_in_group("tilemap")
	if not tilemap.is_clear(position):
		return
	var sprinkler = sprinkler_scene.instantiate()
	sprinkler.position = position
	sprinkler.tilemap = tilemap
	get_parent().add_child(sprinkler)

func _on_area_2d_body_entered(body):
	if body.is_in_group("mower"):
		Poofer.spawn_poof(global_position)
		get_tree().get_first_node_in_group("strikes").add_strike()
		queue_free()
