extends Node


class Dot:
	var num = {}
	var vec = {}
	var arr = {}
	var flag = {}
	var color = {}
	
	func _init(input_):
		num.index = Global.num.primary_key.dot
		Global.num.primary_key.dot += 1
		vec.grid = input_.grid
		vec.pos = input_.pos
		flag.visiable = false
		color.current = Color(0.0, 0.0, 0.0)

class Hex:
	var num = {}
	var vec = {}
	var arr = {}
	var flag = {}
	var color = {}
	var obj = {}
	
	func _init(input_):
		num.index = Global.num.primary_key.hex
		Global.num.primary_key.hex += 1
		num.ring = -1
		vec.grid = input_.grid
		arr.dot = input_.dots
		color.current = Color(0.5, 0.5, 0.5)
		arr.point = []
		
		for dot in arr.dot:
			arr.point.append(dot.vec.pos)

	func recolor():
		var h = float(num.index)/Global.num.primary_key.hex
		color.current = Color.from_hsv(h, 1.0, 1.0)  

class Map:
	var num = {}
	var word = {}
	var arr = {}
	var obj = {}

	func _init():
		arr.dot = []
		arr.hex = []
		
		init_dots()
		init_hexs()
		recolor_hexs()

	func init_dots():
		var vec = Vector2(Global.vec.map.offset.x, Global.vec.map.offset.y)
		var x_shifts = [0,1,1,0]
		var y_shifts = [1,0,1,0]
		
		for _i in Global.num.dot.rows:
			arr.dot.append([])
			vec.y += Global.num.map.h/4
			
			vec.y += y_shifts[_i%y_shifts.size()]*Global.num.map.h/4
			vec.x += x_shifts[_i%x_shifts.size()]*Global.num.map.w/2
			
			for _j in Global.num.dot.cols:
				vec.x += Global.num.map.w
				
				var input = {}
				input.pos = vec
				input.grid = Vector2(_j,_i)
				var dot = Classes.Dot.new(input)
				arr.dot[_i].append(dot)
				
			vec.x = Global.vec.map.offset.x

	func init_hexs():
		var input = {}
		input.grid = Vector2(0,-1)
		
		for _i in Global.num.dot.rows:
			input.grid.x = 0
			var k = (_i-1)%4
			var flag = false
			
			match k:
				0:
					flag = true
				1:
					flag = true
			
			if flag:
				input.grid.y += 1
				arr.hex.append([])
			
				for _j in Global.num.dot.cols:
					var dot = arr.dot[_i][_j]
					var grid = dot.vec.grid
					input.dots = []
					
					for spin in Global.arr.spin[k]:
						grid += spin
						flag = flag && chec_dot(grid)
						
						if flag:
							input.dots.append(arr.dot[grid.y][grid.x])
						
					if flag:
						input.grid.x += 1
						var hex = Classes.Hex.new(input)
						arr.hex[input.grid.y].append(hex)

	func recolor_hexs():
		for hexs in arr.hex:
			for hex in hexs:
				hex.recolor()

	func chec_dot(grid_):
		return grid_.y >= 0 && grid_.x >= 0 && grid_.y < arr.dot.size() && grid_.x < arr.dot[0].size()

class Sorter:
	static func sort_ascending(a, b):
		if a.value < b.value:
			return true
		return false

	static func sort_descending(a, b):
		if a.value > b.value:
			return true
		return false
