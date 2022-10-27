extends Node2D


func _draw():
	for dots in Global.obj.map.arr.dot:
		for dot in dots:
			if dot.flag.visiable:
				draw_circle(dot.vec.pos, 3, dot.color.current)
				
	for hexs in Global.obj.map.arr.hex:
		for hex in hexs:
			draw_polygon(hex.arr.point, PoolColorArray([hex.color.current]))
	
	draw_circle(Global.vec.window_size.center, 3, Color(1.0, 1.0, 1.0))

