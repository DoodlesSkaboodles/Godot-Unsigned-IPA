extends CharacterBody2D

const BASE_SPEED  = 400.0
const BOOST_SPEED = 800.0
const BRAKE_SPEED = 100.0
const TURN_RATE   = 0.00004
const SPEED_LERP  = 0.06

var speed = 0.0
var stunned = false
var stun_duration = 1.5
var active = true
var in_mud = false
var touching_wall = false
var impact_sounds = []

@export var tilemap: TileMapLayer

func _ready():
	lock()
	get_tree().get_first_node_in_group("score").points_earned.connect(show_points)
	impact_sounds = [$Impact1, $Impact2, $Impact3]

func lock():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	active = true

func unlock():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	active = false

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if active:
			unlock()
		else:
			lock()
	if event is InputEventMouseButton and event.pressed and active:
		if event.button_index == MOUSE_BUTTON_LEFT:
			$Speedup.play()
		if event.button_index == MOUSE_BUTTON_RIGHT:
			$Slowdown.play()
	if event.is_action_pressed("accelerate"):
		$Speedup.play()
	if event.is_action_pressed("brake"):
		$Slowdown.play()

func _physics_process(delta):
	if not active:
		speed = lerp(speed, 0.0, 0.15)
		velocity = Vector2(cos(rotation), sin(rotation)) * speed
		move_and_slide()
		return
	if stunned:
		speed = lerp(speed, 0.0, 0.15)
		velocity = Vector2(cos(rotation), sin(rotation)) * speed
		move_and_slide()
		return
	var mouse_delta = Input.get_last_mouse_velocity()
	rotation += mouse_delta.x * TURN_RATE * delta * 60
	var mud_multiplier = 0.4 if in_mud else 1.0
	var target = BASE_SPEED * mud_multiplier
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_action_pressed("accelerate"):
		target = BOOST_SPEED * mud_multiplier
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) or Input.is_action_pressed("brake"):
		target = BRAKE_SPEED * mud_multiplier
	speed = lerp(speed, target, SPEED_LERP)
	velocity = Vector2(cos(rotation), sin(rotation)) * speed
	var newly_mowed = tilemap.mow_at(global_position, speed)
	if newly_mowed:
		$GrassClip.frame = 0
		$GrassClip.visible = true
		$GrassClip.play("clip")
	$Label.rotation = -rotation
	move_and_slide()
	var hitting = get_slide_collision_count() > 0
	if hitting and not touching_wall:
		touching_wall = true
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision.get_collider().is_in_group("crate"):
				collision.get_collider().take_hit(speed)
		$BumpSound.pitch_scale = randf_range(0.6, 1.4)
		$BumpSound.play()
		var impact = impact_sounds[randi() % impact_sounds.size()]
		impact.pitch_scale = randf_range(0.8, 1.2)
		impact.volume_db = randf_range(-6.0, 0.0)
		impact.play()
	elif not hitting:
		touching_wall = false

func touch_steer(delta_x: float):
	if not active or stunned:
		return
	rotation += delta_x * TURN_RATE * 60

func stun():
	stunned = true
	$AnimationPlayer.play("spin")
	$Stunned.play()
	await get_tree().create_timer(stun_duration).timeout
	$AnimationPlayer.play("RESET")
	stunned = false

func enter_mud():
	in_mud = true

func exit_mud():
	in_mud = false

func show_points(amount: int):
	$Label.text = "+" + str(amount)
	$AnimationPlayer2.stop()
	$AnimationPlayer2.play("score")

func shake(amount: float, duration: float):
	var camera = get_tree().get_first_node_in_group("camera")
	var elapsed = 0.0
	while elapsed < duration:
		camera.offset = Vector2(randf_range(-amount, amount), randf_range(-amount, amount))
		await get_tree().create_timer(0.02).timeout
		elapsed += 0.02
	camera.offset = Vector2.ZERO

func blink_strike():
	for i in 4:
		$Sprite2D.modulate = Color(1.5, 0.2, 0.2, 1.0)
		await get_tree().create_timer(0.1).timeout
		$Sprite2D.modulate = Color(1, 1, 1, 1.0)
		await get_tree().create_timer(0.1).timeout
