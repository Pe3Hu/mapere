extends Node


func init_map():
	Global.obj.map = Classes.Map.new()
	
	#Global.rng.randomize()
	#var index_r = Global.rng.randi_range(0, options.size() - 1)

func _ready():
	init_map()

func _input(event):
	if event is InputEventMouseButton:
		if Global.flag.click:
			Global.flag.click = !Global.flag.click
			Global.obj.terrain.next_layer()
		else:
			Global.flag.click = !Global.flag.click

func _on_Timer_timeout():
	Global.node.TimeBar.value +=1
	
	if Global.node.TimeBar.value >= Global.node.TimeBar.max_value:
		Global.node.TimeBar.value -= Global.node.TimeBar.max_value
