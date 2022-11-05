extends Node2D


func _draw():
	for dots in Global.obj.map.arr.dot:
		for dot in dots:
			if dot.flag.visiable:
				draw_circle(dot.vec.pos, 3, dot.color.background)
				
	for hexs in Global.obj.map.arr.hex:
		for hex in hexs:
			if hex.flag.visiable:
				draw_polygon(hex.arr.point, PoolColorArray([hex.color.background]))
			if hex.flag.capital:
				draw_circle(hex.vec.center, Global.num.map.a/2, Color(0.0, 0.0, 0.0))

func _process(delta):
#	for hexs in Global.obj.map.arr.hex:
#		for hex in hexs:
#			if hex.flag.visiable:
#				hex.node.label.rect_global_position = hex.vec.center
#				hex.node.label.rect_global_position.y -= Global.font.chunkfive.size*25/60
#				hex.node.label.rect_global_position.x -= (Global.font.chunkfive.size/5)*len(hex.word.label)
#				Global.font.chunkfive.outline_color = hex.color.label
#				hex.node.label.text = hex.word.label
		
	update()
