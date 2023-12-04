class_name TurnCount extends Label


signal next_turn_signal;
var turn_number = 0;

func next_turn():
	turn_number += 1; 
	text = "Turn #: " +  str(turn_number);
	next_turn_signal.emit();
		#Right now these signals are being implicitely called, unlike how its handled in other ways
		#this was done because GDscript gets mad when Labels is defined after TerrainMap
		#When I try to move Labels above terrain map it gives me some weird errors in terrainMap
	
