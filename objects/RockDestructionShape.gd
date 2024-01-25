extends Area3D

signal destructed

func try_to_destruct():
	destructed.emit()
