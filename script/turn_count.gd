class_name TurnCount extends Label

signal new_turn_signal

var turn_number = 0

var translated_text: String = "Turn"

func next_turn():
	set_turn(turn_number + 1)
	new_turn_signal.emit()

func set_turn(turn: int):
	turn_number = turn
	translate_turn()

func translate_turn():
	text = translated_text + " #: " + str(turn_number)
	
