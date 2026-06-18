extends AnimatedSprite2D

func _ready():
	play("clip")
	animation_finished.connect(queue_free)
