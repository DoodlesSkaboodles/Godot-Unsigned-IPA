extends CanvasLayer

var touch_start_x = 0.0
var is_touching_left = false

func _ready():
	if not OS.has_feature("mobile"):
		visible = false
	$TouchAccelerate.button_down.connect(func(): Input.action_press("accelerate"))
	$TouchAccelerate.button_up.connect(func(): Input.action_release("accelerate"))
	$TouchBrake.button_down.connect(func(): Input.action_press("brake"))
	$TouchBrake.button_up.connect(func(): Input.action_release("brake"))
	$TouchUse.button_down.connect(func(): Input.action_press("use"))
	$TouchUse.button_up.connect(func(): Input.action_release("use"))

func _input(event):
	if event is InputEventScreenTouch:
		if event.position.x < get_viewport().get_visible_rect().size.x / 2:
			if event.pressed:
				is_touching_left = true
				touch_start_x = event.position.x
			else:
				is_touching_left = false

	if event is InputEventScreenDrag:
		if event.position.x < get_viewport().get_visible_rect().size.x / 2:
			# Feed drag delta directly into mower steering
			var mower = get_tree().get_first_node_in_group("mower")
			if mower:
				mower.touch_steer(event.relative.x)
