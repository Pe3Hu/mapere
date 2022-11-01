extends Node2D


func _draw():
	for dots in Global.obj.map.arr.dot:
		for dot in dots:
			if dot.flag.visiable:
				draw_circle(dot.vec.pos, 3, dot.color.current)
				
	for hexs in Global.obj.map.arr.hex:
		for hex in hexs:
			if hex.flag.visiable:
				draw_polygon(hex.arr.point, PoolColorArray([hex.color.current]))
				
				if hex.flag.capital:
					#set_text(1)
					#draw_circle(hex.vec.center, Global.num.map.a/2, Color(0.0, 0.0, 0.0))
					#if hex.obj.bastion.flag.update_label:
					#hex.obj.bastion.node.level.rect_position = hex.vec.cente
					#hex.obj.bastion.node.text = hex.obj.rbastion.num.level.current
					hex.obj.bastion.flag.update_label = false
					
#	for bastion in Global.obj.map.arr.bastion:
#		bastion.node.level.rect_position = Vector2(50,50)
	
	#draw_circle(Global.vec.window_size.center, 3, Color(1.0, 1.0, 1.0))
	pass

func _process(delta):
	for bastion in Global.obj.map.arr.bastion:
		bastion.node.level.rect_global_position =  bastion.obj.hex.vec.center
		bastion.node.level.text = str(bastion.num.level.current)
		
	update()

#var n = arr.hex.size()/2
#var center = arr.hex[n][n]
#center.color.current = Color().from_hsv(1.0, 1.0, 1.0)
#
#var index_r = 0
#var grid = center.vec.grid
#var value = 3
#
#while value > 0:
#	if check_border(grid):
#		var direction_hex = arr.hex[grid.y][grid.x]
#		direction_hex.color.current = Color().from_hsv(0.5, 1.0, 1.0)
#
#		if direction_hex.flag.visiable:
#			var parity = int(grid.y)%2
#			var direction = Global.arr.neighbor[parity][index_r]
#			grid += direction 
#
#			value -= 1
