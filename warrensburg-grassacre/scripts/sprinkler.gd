extends Area2D

var damage_interval = 1.0
var damage_radius = 100.0

@export var tilemap: TileMapLayer

func _ready():
	$DamageArea/CollisionShape2D.shape.radius = damage_radius
	damage_loop()

func damage_loop():
	while true:
		await get_tree().create_timer(damage_interval).timeout
		tilemap.unmow_at(global_position, damage_radius)

func _on_body_entered(body):
	if body.is_in_group("mower"):
		Poofer.spawn_poof(global_position)
		Autosound.play($Destroy.stream)
		queue_free()
