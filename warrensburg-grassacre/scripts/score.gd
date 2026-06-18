extends Node

signal points_earned(amount)

var score = 0

func add_points(amount: int):
	score += amount
	points_earned.emit(amount)
