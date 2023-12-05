class_name TurnCount extends Label

signal next_turn_signal;

var turn_number = 0;

func next_turn():
	turn_number += 1; 
	text = "Turn #: " +  str(turn_number);
	next_turn_signal.emit();
