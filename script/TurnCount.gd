extends Label

var turn_number = 0;

func update_turn_count():
	turn_number += 1;
	text = "Turn #: " +  str(turn_number);
