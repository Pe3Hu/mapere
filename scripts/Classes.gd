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
	var dict = {}
	var flag = {}
	var color = {}
	var obj = {}

	func _init(input_):
		num.index = Global.num.primary_key.hex
		Global.num.primary_key.hex += 1
		vec.grid = input_.grid
		vec.center = Vector2()
		num.parity = int(vec.grid.y)%2
		num.ring = -1
		num.sector = -1
		num.hp = {}
		num.level = {}
		num.level.current = 0
		num.level.base = 9
		num.level.degree = 2
		rise_level()
		arr.dot = input_.dots
		arr.point = []
		arr.neighbor = []
		dict.challenger = {}
		dict.direction = {}
		flag.visiable = false
		flag.capital = false
		obj.map = input_.map
		obj.bastion = null
		recolor("Default")
		
		for dot in arr.dot:
			arr.point.append(dot.vec.pos)
			vec.center += dot.vec.pos/arr.dot.size()
		
		for _i in Global.num.map.neighbors:
			dict.direction[_i] = null

	func contribute_damage(bastion_, value_):
		if bastion_ != obj.bastion:
			if dict.challenger.keys().has(bastion_):
				dict.challenger[bastion_] += value_
			else:
				dict.challenger[bastion_] = value_

	func embody_damage():
		var conqueror = {}
		conqueror.value = -1
		conqueror.bastion = null
		
		for challenger in dict.challenger.keys():
			if obj.map.arr.bastion.has(challenger) && dict.challenger[challenger] > conqueror.value:
				conqueror.value = dict.challenger[challenger]
				conqueror.bastion = challenger
		
		dict.challenger = {}
		get_damage(conqueror)

	func get_damage(conqueror_):
		if conqueror_.value > num.hp.current:
			conqueror_.value = conqueror_.value - num.hp.current
			num.hp.current = 0
		else:
			num.hp.current -= conqueror_.value
			conqueror_.value = 0
		
		if num.hp.current <= 0:
			conqueror_.bastion.get_experience(num.level.current)
			rise_level()
			
			if obj.bastion != null:
				if flag.capital:
					obj.bastion.die()
				else:
					obj.bastion.arr.hex.erase(self)
					#obj.bastion.check_continuity([self],0)
				
			obj.bastion = conqueror_.bastion
			obj.bastion.arr.hex.append(self)
			#parent_.arr.child.append(self)
			recolor("Bastions")
		else:
			recolor("Hp")
		
		#return conqueror_.value

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

	func reset():
		obj.bastion = null
		recolor("Default")

	func rise_level():
		num.level.current += 1
		num.hp.max = pow((num.level.base+num.level.current),num.level.degree)
		num.hp.current = num.hp.max

class Card:
	var num = {}
	var word = {}
	var obj = {}

	func _init(input_):
		word.type = input_.type
		word.element = "None"
		num.denomination = input_.denomination
		obj.bastion = input_.deck
		num.level = {}
		num.level.current = 0
		num.experience = {}
		num.experience.current = 0
		num.experience.max = 1
		num.shift = {}
		num.shift.current = 0
		num.shift.max = 3

	func use():
		match word.type:
			"Trigger":
				if obj.bastion.check_charge_value():
					obj.bastion.launch_charge()
			"Blank":
				obj.bastion.num.fuel += num.denomination

#	func get_experience(experience_):
#		num.experience.current += experience_
#
#		if num.experience.current >= num.experience.max:
#			rise_level()
#
#	func rise_level():
#		num.level.current += 1
#		num.experience.current -= num.experience.max
#		num.experience.max = num.level.current+1
		pass

	func upgrade():
		var types = ["Denomination","Shift","Element"]
		var copys = [4,2,1]
		var options = []
		
		for _i in types.size():
			if types[_i] != "Element" || (types[_i] == "Element" && word.element == "None"):
				for _j in copys[_i]:
					options.append(types[_i])
		
		Global.rng.randomize()
		var index_r = Global.rng.randi_range(0, options.size()-1)
		
		match options[index_r]:
			"Denomination":
				var bonus = 1
				num.denomination += bonus
			"Shift":
				var bonus = 1
				num.shift.current += bonus
				
				while num.shift.current > num.shift.max:
					num.shift.current -= num.shift.max
					num.denomination += 1
			"Element":
				options = []
				var elements = {}
				var base = 2
				
				for element in Global.arr.element:
					elements[element] = 0
				
				elements[Global.arr.element[obj.bastion.num.element]] += 1
				
				for card in obj.bastion.arr.card:
					if elements.keys().has(card.word.type):
						elements[card.word.type] += 1
				
				for element in elements.keys():
					for _i in pow(base, elements[element]):
						options.append(element)
						
				Global.rng.randomize()
				index_r = Global.rng.randi_range(0, options.size()-1)
				word.type = options[index_r]

class Cannon:
	var num = {}
	var word = {}
	var obj = {}

	func _init(input_):
		num.rank = input_.rank
		num.level = {}
		num.level.current = 0
		word.type = input_.type
		obj.owner = input_.owner

	func upgrade_rank():
		if num.rank < Global.dict.cannon.rank.keys().size()-1:
			num.rank += 1
			
			Global.rng.randomize()
			var index_r = Global.rng.randi_range(0, Global.dict.cannon.rank[str(num.rank)].size() - 1)
			
			word.type = Global.dict.cannon.rank[str(num.rank)][index_r]
			print(word.type)
		else:
			print("OverExpCannon")

class Ammo:
	var num = {}
	var word = {}
	var obj = {}

	func _init(input_):
		num.rank = input_.rank
		num.level = {}
		num.level.current = 0
		word.type = input_.type
		obj.owner = input_.owner

	func detonation(hex_, charge_,direction_index_):
		var description = Global.dict.ammo.description[word.type]
		var charge = float(charge_)/Global.dict.cannon.description[obj.owner.obj.cannon.word.type]["Directions"].size()
		var targets = []
		var target = {}
		target.hex = hex_
		target.charge = description["Alpha Part"]*charge
		targets.append(target)
		obj.owner.update_borderlands()
		
		for index in description["Directions"]:
			var hexs = [hex_]
			var current_index = (direction_index_+index)%Global.num.map.neighbors
			
			if target.hex.flag.visiable:
				for _j in description["Range"]:
					if word.type == "Waver":
						hexs.append(get_waver_hex(hexs,index))
					else:
						hexs.append(hexs.back().dict.direction[current_index])
					
					if target.hex.flag.visiable:
						target = {}
						target.hex = hexs.back()
						target.charge = description["Beta Part"]/description["Directions"].size()/description["Range"]*charge
						targets.append(target)
		
		for target_ in targets:
			target_.hex.contribute_damage(obj.owner, target.charge)
	
	func get_waver_hex(hexs_,index_):
		var options = []
		
		for neighbor in hexs_.back().arr.neighbor:
			if obj.owner.arr.borderland.has(neighbor) && !hexs_.has(neighbor):
				options.append(neighbor)
		
		if options.size() > 1:
			options.remove(index_)
			
		if options.size() > 0:
			return options[0]
		else:
			return hexs_.back()

	func upgrade_rank():
		num.rank += 1
		
		Global.rng.randomize()
		var index_r = Global.rng.randi_range(0, Global.dict.ammo.rank[str(num.rank)].size() - 1)
		
		word.type = Global.dict.ammo.rank[str(num.rank)][index_r]
		print(word.type)

class Bastion:
	var num = {}
	var arr = {}
	var flag = {}
	var obj = {}
	var node = {}

	func _init(input_):
		num.index = Global.num.primary_key.bastion
		Global.num.primary_key.bastion += 1
		obj.capital = input_.hex
		obj.capital.obj.bastion = self
		obj.capital.flag.capital = true
		obj.map = obj.capital.obj.map
		arr.hex = [obj.capital]
		num.fuel = 0
		num.refill = {}
		num.refill.card = Global.num.deck.refill
		num.experience = {}
		num.experience.current = 0
		num.experience.max = 1
		num.level = {}
		num.level.current = 0
		num.element = num.index*Global.arr.element.size()/Global.num.primary_key.bastion
		init_nodes()
		init_deck()
		init_cannon()

	func init_nodes():
		node.level = Label.new()
		node.level.set("custom_fonts/font", load("res://assets/ELEPHNT.TTF"))
		node.level.set("custom_colors/font_color", Color(1,1,1))
		node.level.text = str(num.index)
		Global.node.BastionLevel.add_child(node.level)
		
		node.charge = Label.new()
		node.charge.set("custom_fonts/font", load("res://assets/ELEPHNT.TTF"))
		node.charge.set("custom_colors/font_color", Color(1,1,1))
		node.charge.text = "# "+str(num.index)
		
		if num.index < 10:
			node.charge.text += " "
		
		node.charge.text += ": " + str(num.fuel)
		Global.node.BastionCharge.add_child(node.charge)

	func init_deck():
		arr.deck = []
		arr.hand = []
		arr.discard = []
		arr.exile = []
		arr.card = []
		
		for key in Global.dict.deck.base.keys():
			for _i in Global.dict.deck.base[key]:
				var input = {}
				input.type = key
				input.denomination = 1
				input.deck = self
				var card = Classes.Card.new(input)
				arr.card.append(card)
		
		for card in arr.card:
			arr.deck.append(card)
		
		arr.deck.shuffle()

	func init_cannon():
		var input = {}
		input.owner = self
		input.type = "Rounder"#Singler Rounder Faner
		input.rank = 0
		obj.cannon = Classes.Cannon.new(input)
		
		init_ammos()

	func init_ammos():
		arr.ammo = []
		
		for _i in Global.num.ammo.size:
			var input = {}
			input.owner = self
			input.type = "Basic"# Basic Piercer Splasher Blader Blaster Waver
			input.rank = 0
			var ammo = Classes.Ammo.new(input)
			arr.ammo.append(ammo)

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
		#launch_expanse()

	func use_hand():
		while arr.hand.size() > 0:
			var card = arr.hand.pop_front()
			card.use()
			arr.discard.append(card)

	func launch_charge():
		Global.rng.randomize()
		var direction_index = Global.rng.randi_range(0, Global.num.map.neighbors-1) 
		
		for index in 1:#Global.dict.cannon.description[obj.cannon.word.type]["Directions"]:
			var sub_index = (direction_index+index)%Global.num.map.neighbors
			#print(self,sub_index)
			sub_launch(sub_index)

	func sub_launch(sub_index_):
		var direction_index = sub_index_
		var current_hex = obj.capital
		var type = ""
		#pls fix this bug 1
		var counter = 0
		
		while num.charge > 0 && counter < 100:
			counter += 1
			#print(self,current_hex)
			
			if current_hex.obj.bastion == null:
				type = "Damage"
			else:
				if current_hex.obj.bastion.num.index == num.index:
					type = "Move"
					
					if current_hex.num.hp.current != current_hex.num.hp.max:
						if !current_hex.flag.capital:
							type = "Heal"
				else:
					type = "Damage"
			
			match type:
				"Move":
					direction_index = get_deviation(current_hex,direction_index)
					current_hex = current_hex.dict.direction[direction_index]
					
					if !current_hex.dict.direction[direction_index].flag.visiable:
						direction_index = get_after_border_direction(current_hex, direction_index)
						
					#value -= 1
				"Heal":
					current_hex.get_heal(num.charge)
				"Damage":
					arr.ammo.front().detonation(current_hex,num.charge,direction_index)
					next_ammo()

		num.fuel = 0
		num.charge = 0

	func next_ammo():
		var ammo = arr.ammo.pop_front()
		arr.ammo.append(ammo)
		num.charge = 0

	func check_charge_value():
		var min_value = Global.dict.sphenic_number.keys[0]
		var flag = Global.dict.sphenic_number.keys.has(num.fuel) && num.fuel >= min_value
		
		if !flag:
			num.fuel /= 2 
		else:
			var b = num.fuel
			var a = Global.dict.sphenic_number.full[num.fuel]
			num.charge = Global.dict.sphenic_number.full[num.fuel].back().mult
		
			#self hex fix
			num.charge += 1
		
		return flag

	func launch_expanse():
		if obj.map.arr.bastion.size() > 1:
			tick_borderlands()

	func get_ordered():
		var ordered = []
		update_borderlands()
		ordered.append_array(arr.hollow)
		var threats = find_capital_threats()
		ordered.append_array(threats)
		return ordered

	func update_borderlands():
		var hexs = []
		arr.chain = [[]]
		arr.borderland = []
		arr.hollow = []
		
		for hex in arr.hex:
			for neighbor in hex.arr.neighbor:
				if neighbor.obj.bastion != self && !hexs.has(neighbor):
					hexs.append(neighbor)
		
		for hex in hexs:
			var flag = true
			
			for chain in arr.chain:
				for hex_ in chain:
					if hex_.arr.neighbor.has(hex) && !chain.has(hex):
						chain.append(hex)
						flag = false
			
			if flag:
				arr.chain.append([hex])
				
		arr.chain.pop_front()
		
		for chain in arr.chain:
			var flag = true
			
			for hex in chain:
				for neighbor in hex.arr.neighbor:
					if !chain.has(neighbor):
						flag = flag && neighbor.obj.bastion == self
			
			if flag:
				arr.hollow.append_array(chain)
			else:
				arr.borderland.append_array(chain)

	func calc_centroidal():
		var vec = Vector2()
		
		for hex in arr.hex:
			vec += hex.vec.center/arr.hex.size()
		
		return vec

	func find_nearest_capital():
		var centroidal = calc_centroidal()
		var dists = []
		
		for bastion in obj.map.arr.bastion:
			if bastion != self:
				var dist = {}
				dist.value = bastion.obj.capital.vec.center.distance_to(centroidal)
				dist.bastion = bastion
				dists.append(dist)
		
		dists.sort_custom(Classes.Sorter, "sort_ascending")
		return dists

	func find_capital_threats():
		var ordered = []
		var threats = []
		var bastions = find_nearest_capital()
		
		for hex in arr.borderland:
			var threat = {}
			threat.value = hex.vec.center.distance_to(bastions[0].bastion.obj.capital.vec.center)
			threat.hex = hex
			threats.append(threat)
				
		threats.sort_custom(Classes.Sorter, "sort_ascending")
		
		for threat in threats:
			ordered.append(threat.hex)
			
		return ordered

	func tick_borderlands():
		var ordered = get_ordered()
		var value = floor(sqrt(arr.hex.size()))
		
		for _i in value:
			var hex = ordered.pop_front()
			hex.contribute_damage(self, value)

	func get_deviation(hex_,old_index_):
		var options = []
		var copy = 2
		
		for _i in range(-1,1,1):
			var index = (old_index_+_i+Global.num.map.neighbors)%Global.num.map.neighbors
			
			if hex_.dict.direction[index] != null:
				if hex_.dict.direction[index].flag.visiable:
					options.append(index)
				
					if index == old_index_:
						for _j in copy:
							options.append(index)
				
		Global.rng.randomize()
		var index_r = Global.rng.randi_range(0, options.size()-1)
		return options[index_r]

	func get_after_border_direction(hex_, old_index_):
		var options = []
		var reflected_index = (Global.num.map.neighbors/2+old_index_)%Global.num.map.neighbors
		
		for index in Global.num.map.neighbors:
			if hex_.dict.direction[index] != null:
				if hex_.dict.direction[index].flag.visiable && reflected_index != index:
					options.append(index)
		
		Global.rng.randomize()
		var index_r = Global.rng.randi_range(0, options.size()-1)
		return options[index_r]

	func update_connects():
		var unconnecteds = []
		var connecteds = [[obj.capital]]
		
		for hex in arr.hex:
			unconnecteds.append(hex)
		
		unconnecteds.erase(obj.capital)
		
		var flag = true
		var _i = 0
		
		while flag:
			flag = false
			connecteds.append([])
			
			for connected in connecteds[_i]:
				for neighbor in connected.arr.neighbor:
					if unconnecteds.has(neighbor):
						connecteds[_i+1].append(neighbor)
						unconnecteds.erase(neighbor)
						flag = true
			
			_i += 1
		
		for unconnected in unconnecteds:
			unconnected.reset()
			arr.hex.erase(unconnected)

	func get_experience(experience_):
		num.experience.current += experience_
		
		if num.experience.current >= num.experience.max:
			rise_level()

	func rise_level():
		num.experience.current -= num.experience.max
		num.level.current += 1
		num.experience.max = pow(num.level.current+1,2)
		
		choose_upgrade()

	func choose_upgrade():
		if arr.discard.size() > 0:
			var card = null
			
			for card_ in arr.discard:
				if card_.word.type == "Blank":
					card = card_
			
			if card != null:
				card.upgrade()
			else:
				print("error 2 upgrade card:no Blank in discard")
		else:
			print("error 1 upgrade card: discard size == 0")
			
		if num.level.current%12 == 0:
			upgrade_ammo()
		if num.level.current%12 == 0:
			obj.cannon.upgrade_rank()

	func upgrade_ammo():
		var options = []
		
		for ammo in arr.ammo:
			for _i in pow(Global.dict.ammo.rank.keys().size()-1-ammo.num.rank,2):
				options.append(ammo)
		
		Global.rng.randomize()
		var index_r = Global.rng.randi_range(0, options.size()-1)
		options[index_r].upgrade_rank()

	func die():
		obj.capital.flag.capital = false
		
		for hex in arr.hex:
			hex.reset()
		
		for child in Global.node.BastionLevel.get_children():
			if child == node.level: 
				child.queue_free()
				
		for child in Global.node.BastionCharge.get_children():
			if child == node.charge: 
				child.queue_free()
		#node.level.get_children().queue_free()
		#node.charge.get_children().queue_free()
		#Global.node.BastionLevel.remove_child(node.level)
		#Global.node.BastionCharge.remove_child(node.charge)
		Global.obj.map.arr.bastion.erase(self)

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
		init_neighbors()
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

	func init_neighbors():
		for hexs in arr.hex:
			for hex in hexs:
				for index in Global.num.map.neighbors:
					var neighbor = Global.arr.neighbor[hex.num.parity][index]
					var grid = hex.vec.grid + neighbor 
					
					if check_border(grid):
						var neighbor_hex = arr.hex[grid.y][grid.x]
						
						if !hex.arr.neighbor.has(neighbor_hex):
							hex.arr.neighbor.append(neighbor_hex)
							neighbor_hex.arr.neighbor.append(hex)
							
							var reflected_index = (index+Global.num.map.neighbors/2)%Global.num.map.neighbors
							hex.dict.direction[index] = neighbor_hex
							neighbor_hex.dict.direction[reflected_index] = hex

	func around_center():
		var center = arr.hex[arr.hex.size()/2][arr.hex.size()/2]
		var arounds = [[center]]
		center.num.ring = 0
		center.flag.visiable = true
		
		for _i in Global.num.map.rings-2:
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
		
		for _i in Global.num.map.rings-1:
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
		
		while options.size() > 0:
			Global.rng.randomize()
			var index_r = Global.rng.randi_range(0, options.size()-1)
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
			bastion.obj.capital.recolor("Bastions")

	func embody_hexs():
		for hexs in arr.hex:
			for hex in hexs:
				if hex.dict.challenger.keys().size() > 0:
					hex.embody_damage()
			
		for bastion in arr.bastion:
			bastion.update_connects()
		if arr.bastion.size() == 1:
			flag.ready = false

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

	static func sort_subarray_ascending(a, b):
		var flag = true
		
		for _i in a.values.size():
			flag = flag && a.values[_i] <= b.values[_i]
		return flag
