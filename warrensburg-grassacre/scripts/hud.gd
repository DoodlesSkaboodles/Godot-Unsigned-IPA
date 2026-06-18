extends CanvasLayer

@export var tilemap: TileMapLayer
@export var strikes_node: Node
@export var win_condition: Node

var last_milestone = 0
var displayed_score = 0
var target_score = 0
var hud_visible = false

const MOWED_REST   = Color(0.9, 1.0, 0.9, 0.6)
const STRIKES_REST = Color(1.0, 0.85, 0.85, 0.6)
const SCORE_REST   = Color(1.0, 1.0, 0.8, 0.6)

func _ready():
	get_tree().get_first_node_in_group("score").points_earned.connect(on_points_earned)
	$MowedLabel.modulate   = MOWED_REST
	$StrikesLabel.modulate = STRIKES_REST
	$ScoreLabel.modulate   = SCORE_REST

func _process(_delta: float) -> void:
	var pct = tilemap.mow_percent()
	var milestone = int(pct / 10) * 10
	if milestone > last_milestone and milestone > 0:
		last_milestone = milestone
		flash_percent()
	$MowedLabel.text   = "[i]Mowed[/i]\n%.1f%% / %.0f%%" % [pct, win_condition.win_threshold]
	$StrikesLabel.text = "[i]Strikes[/i]\n%d / 3" % strikes_node.strikes
	$ScoreLabel.text   = "[i]Score[/i]\n%d" % displayed_score

	# HUD slide toggle
	if Input.is_action_just_pressed("hud"):
		$AnimationPlayer.play("slideon")
	elif Input.is_action_just_released("hud"):
		$AnimationPlayer.play_backwards("slideon")

func flash_percent():
	$CrowdCheer.pitch_scale = randf_range(0.8, 1.2)
	$CrowdCheer.play()
	for i in 5:
		$MowedLabel.modulate = Color(1.5, 1.5, 0.465, 1.0)
		await get_tree().create_timer(0.1).timeout
		$MowedLabel.modulate = Color(1.0, 1.0, 1.0, 0.784)
		await get_tree().create_timer(0.1).timeout
	$MowedLabel.modulate = MOWED_REST

func on_points_earned(amount: int):
	count_up(amount)
	flash_score()

func count_up(amount: int):
	target_score += amount
	while displayed_score < target_score:
		displayed_score += max(1, int((target_score - displayed_score) / 10.0))
		displayed_score = min(displayed_score, target_score)
		await get_tree().create_timer(0.02).timeout

func flash_score():
	for i in 5:
		$ScoreLabel.modulate = Color(1.5, 1.5, 0.0, 1.0)
		await get_tree().create_timer(0.08).timeout
		$ScoreLabel.modulate = Color(1, 1, 1, 0.647)
		await get_tree().create_timer(0.08).timeout
	$ScoreLabel.modulate = SCORE_REST

func flash_strikes():
	for i in 5:
		$StrikesLabel.modulate = Color(1.5, 0.0, 0.0, 1.0)
		await get_tree().create_timer(0.08).timeout
		$StrikesLabel.modulate = Color(1, 1, 1, 0.647)
		await get_tree().create_timer(0.08).timeout
	$StrikesLabel.modulate = STRIKES_REST
