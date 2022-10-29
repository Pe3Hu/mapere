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
		vec.grid = input_.grid
		num.parity = int(vec.grid.y)%2
		num.ring = -1
		num.sector = -1
		num.hp = {}
		num.hp.max = 10
		num.hp.current = num.hp.max
		arr.dot = input_.dots
		arr.point = []
		arr.neighbor = []
		#arr.parent = []
		#arr.child = []
		obj.map = input_.map
		flag.visiable = false
		obj.bastion = null
		flag.capital = false
		recolor("Default")
		
		for dot in arr.dot:
			arr.point.append(dot.vec.pos)

	func get_damage(bastion_, value_):
		if value_ > num.hp.current:
			value_ = value_ - num.hp.current
			num.hp.current = 0
		else:
			num.hp.current -= value_
			value_ = 0
		
		if num.hp.current <= 0:
			num.hp.current = num.hp.max
			
			if obj.bastion != null:
				if flag.capital:
					obj.bastion.die()
				else:
					obj.bastion.arr.hex.erase(self)
					#obj.bastion.check_continuity([self],0)
					obj.bastion.update_connects()
				
			obj.bastion = bastion_
			obj.bastion.arr.hex.append(self)
			#parent_.arr.child.append(self)
			recolor("Bastions")
		
		return value_

	func get_heal(value_):
		var heal = min(num.hp.max-num.hp.current,value_)
		num.hp.current += heal
		value_ -= heal
		return value_

	func recolor(layer_):
		#var h = float(num.index)/Global.num.primary_key.hex
		#var h = float(num.ring)/Global.num.map.rings/2
		#var h = float(num.sector)/Global.num.map.sectors
		var h = null
		
		match layer_:
			"Default":
				color.current = Color().from_hsv(0.0, 0.0, 1)
			"Sectors":
				h = float(num.sector)/Global.num.map.sectors
				color.current = Color.from_hsv(h, 1.0, 1.0)  
			"Bastions":
				h = float(obj.bastion.num.index)/Global.num.primary_key.bastion
				color.current = Color.from_hsv(h, 1.0, 1.0)  
			"Hp":
				var v = float(num.hp.current)/num.hp.max
				color.current = Color().from_hsv(0.0, 0.0, v)
				
				if obj.bastion != null:
					if obj.bastion.num.index != -1:
						h = float(obj.bastion.num.index)/Global.num.primary_key.bastion
						color.current = Color().from_hsv(h, 1.0, v)

class Card:
	var num = {}
	var word = {}
	var obj = {}

	func _init(input_):
		word.type = input_.type
		num.value = input_.value
		obj.bastion = input_.deck

	func use():
		match word.type:
			"Trigger":
				if obj.bastion.num.charge > 0:
					obj.bastion.launch_charge()
			"Blank":
				obj.bastion.num.charge += num.value

class Bastion:
	var num = {}
	var arr = {}
	var obj = {}

	func _init(input_):
		num.index = Global.num.primary_key.bastion
		Global.num.primary_key.bastion += 1
		obj.hex = input_.hex
		obj.hex.obj.bastion = self
		obj.hex.flag.capital = true
		obj.map = obj.hex.obj.map
		arr.hex = [obj.hex]
		num.charge = 0
		num.refill = {}
		num.refill.card = Global.num.deck.refill
		init_deck()

	func init_deck():
		arr.deck = []
		arr.hand = []
		arr.discard = []
		arr.exile = []
		
		for key in Global.dict.deck.base.keys():
			for _i in Global.dict.deck.base[key]:
				var input = {}
				input.type = key
				input.value = 1
				input.deck = self
				var card = Classes.Card.new(input)
				arr.deck.append(card)
		
		arr.deck.shuffle()

	func refill_hand():
		arr.hand = []
		
		for _i in num.refill.card:
			pull_card()

	func pull_card():
		if arr.deck.size() > 0:
			arr.hand.append(arr.deck.pop_back())
		else:
			reshuffle() 

	func reshuffle():
		for _i in arr.discard.size():
			arr.deck.append(arr.discard.pop_back())
		
		arr.deck.shuffle()

	func use_hand():
		while arr.hand.size() > 0:
			var card = arr.hand.pop_front()
			card.use()
			arr.discard.append(card)

	func launch_charge():
		var value = floor(sqrt(num.charge))
		#self hex fix
		value += 1
		value += arr.hex.size()
		
		Global.rng.randomize()
		var index_r = Global.rng.randi_range(0, Global.arr.neighbor[obj.hex.num.parity].size() - 1)
		var grid = obj.hex.vec.grid
		var counter = 0
		
		while value > 0 && counter < 100:
			counter += 1
			if obj.map.check_border(grid):
				var direction_hex = obj.map.arr.hex[grid.y][grid.x]
				
				if direction_hex.flag.visiable:
					var type = ""
					
					if direction_hex.obj.bastion == null:
						type = "Damage"
					else:
						if direction_hex.obj.bastion.num.index == num.index:
							type = "Move"
							
							if direction_hex.num.hp.current != direction_hex.num.hp.max:
								if !direction_hex.flag.capital:
									type = "Heal"
						else:
							type = "Damage"
					
					match type:
						"Move":
							var parity = int(grid.y)%2
							index_r = get_deviation(index_r)
							var direction = Global.arr.neighbor[parity][index_r]
							grid += direction 
							
							var border = false
							
							if !obj.map.check_border(grid):
								border = true
							else:
								var next_hex = obj.map.arr.hex[grid.y][grid.x]
								
								if !next_hex.flag.visiable:
									border = true
							
							if border:
								grid -= direction 
								var new_index = get_after_border_direction(direction_hex, index_r)
								print("old",index_r)
								print("new",new_index)
								index_r = new_index
								direction = Global.arr.neighbor[parity][new_index]
								grid += direction 
								
							value -= 1
						"Heal":
							value = direction_hex.get_heal(value)
						"Damage":
							direction_hex.recolor("Hp")
							value = direction_hex.get_damage(self,value)
				
		
		num.charge = 0

	func get_deviation(old_index_):
		var options = []
		var copy = 2
		var n = Global.arr.neighbor[0].size()
		
		for _i in range(-1,1,1):
			var index = (old_index_+_i+n)%n
			options.append(index)
			
			if index == old_index_:
				for _j in copy:
					options.append(index)
			
		Global.rng.randomize()
		var index_r = Global.rng.randi_range(0, options.size() - 1)
		return options[index_r]

	func get_after_border_direction(hex_, old_index_):
		var options = []
		var parity = int(hex_.vec.grid.y)%2
		var n = Global.arr.neighbor[parity].size()
		var reflected_index = (n/2+old_index_)%n
		var reflected_direction = Global.arr.neighbor[parity][reflected_index]
		
		for _i in Global.arr.neighbor[parity].size():
			var neighbor = Global.arr.neighbor[parity][_i]
			var grid = hex_.vec.grid + neighbor
			
			if obj.map.check_border(grid) && reflected_direction != neighbor:
				options.append(_i)
		
		Global.rng.randomize()
		var index_r = Global.rng.randi_range(0, options.size() - 1)
		print(old_index_,options,options[index_r])
		return options[index_r]

	func check_continuity(loss_,counter_):
#		var new_loss = []
#
#		for loss in loss_:
#			get_loss(loss)
#
#		for loss in loss_:
#			for child in loss.arr.child:
#				if child.arr.parent.size() == 0:
#					new_loss.append(child)
#
#		if new_loss == loss_:
#			return
#		else:
#			if new_loss.size() > 0:
#				check_continuity(new_loss,counter_+1)
		pass

	func update_connects():
		var unconnecteds = []
		var connecteds = [obj.hex]
		
		for hex in arr.hex:
			unconnecteds.append(hex)
		
		unconnecteds.erase(obj.hex)
		
		var flag = true
		
		while flag:
			flag = false
			
			for connected in connecteds:
				for neighbor in connected.arr.neighbor:
					if unconnecteds.has(neighbor):
						connecteds.append(neighbor)
						unconnecteds.erase(neighbor)
						flag = true
		
		for unconnected in unconnecteds:
			get_loss(unconnected)

	func get_loss(loss_):
#		for child in loss_.arr.child:
#			child.arr.parent.erase(loss_)
		
		arr.hex.erase(loss_)
		loss_.obj.bastion = null
		loss_.recolor("Default")

	func die():
		obj.hex.flag.capital = false
		
		for hex in arr.hex:
			obj.hex.obj.bastion = null
			hex.recolor("Default")
		
		obj.map.arr.bastion.erase(self)

class Map:
	var arr = {}
	var flag = {}

	func _init():
		arr.dot = []
		arr.hex = []
		arr.bastion = []
		flag.ready = false
		
		init_dots()
		init_hexs()
		init_neighbor()
		around_center()
		init_sectors()
		init_bastions()
		flag.ready = true
		#recolor_hexs()

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
		input.map = self
		
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
						var hex = Classes.Hex.new(input)
						input.grid.x += 1
						arr.hex[input.grid.y].append(hex)
		
		arr.hex.pop_back()

	func init_neighbor():
		for hexs in arr.hex:
			for hex in hexs:
				for neighbor in Global.arr.neighbor[hex.num.parity]:
					var grid = hex.vec.grid + neighbor 
					
					if check_border(grid):
						var neighbor_hex = arr.hex[grid.y][grid.x]
						
						if !hex.arr.neighbor.has(neighbor_hex):
							hex.arr.neighbor.append(neighbor_hex)
							neighbor_hex.arr.neighbor.append(hex)

	func around_center():
		var n = arr.hex.size()/2
		var center = arr.hex[n][n]
		var arounds = [[center]]
		center.num.ring = 0
		center.flag.visiable = true
		
		for _i in Global.num.map.rings-1:
			var next_ring = []
			
			for _j in range(arounds[_i].size()-1,-1,-1):
				for neighbor in arounds[_i][_j].arr.neighbor:
					if neighbor.num.ring == -1:
						next_ring.append(neighbor)
						neighbor.num.ring = _i+1
						neighbor.flag.visiable = true
			
			arounds.append(next_ring)

	func init_sectors():
		var hex_counters = []
		var sum = 0
		
		for _i in Global.num.map.rings:
			hex_counters.append(0)
		
		for hexs in arr.hex:
			for hex in hexs:
				if hex.num.ring != -1:
					hex_counters[hex.num.ring] += 1
					sum += 1
		
		var sector_sums = []
		var sector_begins = [0]
		var sector_ends = []
		
		for _i in Global.num.map.sectors:
			sector_sums.append(0)
		
		for _i in hex_counters.size():
			sector_sums[sector_ends.size()] += hex_counters[_i]
			
			if sector_sums[sector_ends.size()] >= sum/Global.num.map.sectors:
				if sector_ends.size() < Global.num.map.sectors:
					sector_sums[sector_ends.size()] -= hex_counters[_i]
				
				sector_ends.append(_i-1)
				
				if sector_ends.size() != Global.num.map.sectors:
					sector_sums[sector_ends.size()] += hex_counters[_i]
					sector_begins.append(sector_ends.back()+1)
					
				else:
					sector_sums[sector_ends.size()-1] += hex_counters[_i]
		
		if sector_ends.size() == Global.num.map.sectors:
			sector_ends.pop_back()
			
		sector_ends.append(Global.num.map.rings-1)
		var ring_to_sector = []
		
		for _i in Global.num.map.sectors:
			for ring_ in sector_ends[_i]-sector_begins[_i]+1:
				ring_to_sector.append(_i)
		
		for hexs in arr.hex:
			for hex in hexs:
				hex.num.sector = ring_to_sector[hex.num.ring]

	func init_bastions():
		var options = []
		var sectors = []
		
		for _i in range(1,Global.num.map.sectors-1):
			sectors.append(_i) 
		
		for hexs in arr.hex:
			for hex in hexs:
				if sectors.has(hex.num.sector):
					options.append(hex)
		
		while options.size() > 1:
			Global.rng.randomize()
			var index_r = Global.rng.randi_range(0, options.size() - 1)
			var input = {}
			input.hex = options[index_r]
			var bastion = Classes.Bastion.new(input)
			arr.bastion.append(bastion)
			
			var arounds = [input.hex]
			
			for _i in Global.num.map.boundary:
				for _j in range(arounds.size()-1,-1,-1):
					for neighbor in arounds[_j].arr.neighbor:
						if !arounds.has(neighbor):
							arounds.append(neighbor)
			
			for around in arounds:
				options.erase(around)
			
		for hex in options:
			hex.recolor("Sectors")
			
		for bastion in arr.bastion:
			bastion.obj.hex.recolor("Bastions")

	func recolor_hexs():
		for hexs in arr.hex:
			for hex in hexs:
				hex.recolor("Sectors")

	func chec_dot(grid_):
		return grid_.y >= 0 && grid_.x >= 0 && grid_.y < arr.dot.size() && grid_.x < arr.dot[0].size()

	func check_border(grid_):
		var flag = ( grid_.x >= arr.hex[0].size() ) || ( grid_.x < 0 ) || ( grid_.y >= arr.hex.size() ) || ( grid_.y < 0 )
		return !flag

class Sorter:
	static func sort_ascending(a, b):
		if a.value < b.value:
			return true
		return false

	static func sort_descending(a, b):
		if a.value > b.value:
			return true
		return false
