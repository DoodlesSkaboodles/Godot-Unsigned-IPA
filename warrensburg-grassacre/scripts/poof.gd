extends AnimatedSprite2D

func _ready():
	play("poof")
	animation_finished.connect(queue_free)
