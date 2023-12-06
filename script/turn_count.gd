class_name TurnCount extends Label

signal new_turn_signal;

var turn_number = 0;

func next_turn():
	set_turn(turn_number+1)
	new_turn_signal.emit()

func set_turn(turn: int):
	turn_number = turn
	text = "Turn #: " +  str(turn_number)
