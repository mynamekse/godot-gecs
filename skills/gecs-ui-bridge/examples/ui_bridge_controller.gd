class_name UIBridgeController
extends CanvasLayer

## Decoupled UI controller managing health bars and score display.

@onready var health_bar: ProgressBar = get_node_or_null(^"MarginContainer/VBoxContainer/HealthBar")
@onready var score_label: Label = get_node_or_null(^"MarginContainer/VBoxContainer/ScoreLabel")


func update_health(current: float, maximum: float) -> void:
	if health_bar != null:
		health_bar.max_value = maximum
		health_bar.value = current


func update_score(score: int) -> void:
	if score_label != null:
		score_label.text = "Score: %d" % score

