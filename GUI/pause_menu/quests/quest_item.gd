class_name QuestItem extends Button

var quest : Quest

@onready var title_label: Label = $TitleLabel
@onready var step_label: Label = $StepLabel


func _ready() -> void:
	focus_entered.connect( _on_focus_enter )
	focus_exited.connect( _on_focus_exit )


func initialize( q_data : Quest, q_state ) -> void:
	quest = q_data
	title_label.text = q_data.title
	
	if q_state.is_complete == true:
		step_label.text = "Completed"
		step_label.modulate = Color.LIGHT_GREEN
	else:
		var step_count : int = q_data.steps.size()
		var completed_count : int = q_state.completed_steps.size()
		step_label.text = "quest step: " + str( completed_count ) + "/" + str( step_count )
	pass


func _on_focus_enter() -> void:
	title_label.modulate = Color(0.949, 0.769, 0.294, 1.0)
	pass


func _on_focus_exit() -> void:
	title_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	pass
