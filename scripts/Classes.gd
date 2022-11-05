extends Node


class Dot:
	var word = {}
	var num = {}
	var vec = {}
	var arr = {}
	var flag = {}
	var color = {}

	func _init(input_):
		word.class = "Dot"
		num.index = Global.num.primary_key.dot
		Global.num.primary_key.dot += 1
		vec.grid = input_.grid
		vec.pos = input_.pos
		flag.visiable = false
		color.background = Color(0.0, 0.0, 0.0)

class Effect:
	var word = {}
	var num = {}
	var obj = {}

	func _init(input_):
		word.class = "Effect"
		word.type = input_.type
		num.value = input_.value
		obj.hex = input_.hex
		obj.bastion = input_.bastion

class Hex:
	var word = {}
	var num = {}
	var vec = {}
	var arr = {}
	var dict = {}
	var flag = {}
	var color = {}
	var obj = {}
	var node = {}

	func _init(input_):
		word.class = "Hex"
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
		Global.rise_level(self)
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
		init_nodes()
		
		for dot in arr.dot:
			arr.point.append(dot.vec.pos)
			vec.center += dot.vec.pos/arr.dot.size()
		
		for _i in Global.num.map.neighbors:
			dict.direction[_i] = null

	func init_nodes():
		node.label = Label.new()
		node.label.set("custom_fonts/font", Global.font.chunkfive)
		updated_label_text()
		Global.node.HexLabels.add_child(node.label)

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
			Global.get_experience(conqueror_.bastion,num.level.current*3)
			Global.rise_level(self)
			
			if obj.bastion != null:
				if flag.capital:
					obj.bastion.die()
				else:
					obj.bastion.arr.hex.erase(self)
				
			obj.bastion = conqueror_.bastion
			obj.bastion.arr.hex.append(self)
			recolor("Bastions")
		else:
			recolor("Hp")
			
		updated_label_text()

	func get_heal(value_):
		var heal = min(num.hp.max-num.hp.current,value_)
		num.hp.current += heal
		value_ -= heal
		updated_label_text()
		return value_

	func recolor(layer_):
		#var h = float(num.index)/Global.num.primary_key.hex
		#var h = float(num.ring)/Global.num.map.rings/2
		#var h = float(num.sector)/Global.num.map.sectors
		var h = null
		
		match layer_:
			"Default":
				color.background = Color().from_hsv(0.0, 0.0, 1)
			"Sectors":
				h = float(num.sector)/Global.num.map.sectors
				color.background = Color.from_hsv(h, 1.0, 1.0)  
			"Bastions":
				h = float(obj.bastion.num.index)/Global.num.primary_key.bastion
				color.background = Color.from_hsv(h, 1.0, 1.0)  
			"Hp":
				var v = float(num.hp.current)/num.hp.max
				color.background = Color().from_hsv(0.0, 0.0, v)
				
				if obj.bastion != null:
					if obj.bastion.num.index != -1:
						h = float(obj.bastion.num.index)/Global.num.primary_key.bastion
						color.background = Color().from_hsv(h, 1.0, v)

	func reset():
		obj.bastion = null
		recolor("Default")

	func updated_label_text():
		var v = float(num.hp.current)/num.hp.max+0.5
		
		if v > 1:
			v -= 1
		
		color.label = Color().from_hsv(0.0, 0.0, v)
		var hp = float(num.hp.current)/num.hp.max*100
		word.label = str(hp)

class Card:
	var num = {}
	var word = {}
	var arr = {}
	var flag = {}
	var obj = {}

	func _init(input_):
		word.type = input_.type
		word.class = "Card"
		num.denomination = input_.denomination
		obj.bastion = input_.bastion
		num.level = {}
		num.level.current = 0
		num.experience = {}
		num.experience.current = 0
		num.experience.max = 1
		num.shift = {}
		num.shift.current = 0
		num.shift.max = 3
		arr.element = []
		flag.unique = false

	func use():
		match word.type:
			"Trigger":
				if obj.bastion.check_charge_value():
					obj.bastion.launch_charge()
			"Blank":
				obj.bastion.num.fuel += num.denomination
				
				if arr.element.size() > 0:
					for element in arr.element:
						for _i in num.denomination:
							obj.bastion.arr.element.append(element)

	func poker_check():
		flag.unique = true
		
		for poker in obj.bastion.arr.poker:
			if poker.arr.element.front() == arr.element.front() && poker.num.denomination == num.denomination:
				flag.unique = false
		
		if flag.unique:
			obj.bastion.arr.poker.append(self)
			
			for type in obj.bastion.dict.upgrade[word.class].keys():
				for index in obj.bastion.dict.upgrade[word.class][type]["Indexs"].keys():
					if obj.bastion.dict.upgrade[word.class][type]["Indexs"][index].size() > 0:
						if obj.bastion.dict.upgrade[word.class][type]["Indexs"][index].has(self):
							obj.bastion.dict.upgrade[word.class][type]["Indexs"][index].erase(self)
		
			#obj.bastion.dict.poker["Element"][arr.element.front()].append(num.denomination)
			
			#if obj.bastion.dict.poker["Denomination"].keys().has(num.denomination):
			#	obj.bastion.dict.poker["Denomination"][num.denomination].append(arr.element.front())
			
			if obj.bastion.num.index == 0:
				print(obj.bastion.arr.poker.size(), " ", arr.element.front(), " ", num.denomination)

class Cannon:
	var word = {}
	var num = {}
	var obj = {}

	func _init(input_):
		word.type = input_.type
		word.class = "Cannon"
		num.rank = input_.rank
		num.level = {}
		num.level.current = 0
		num.factor = 1
		obj.owner = input_.owner

	func upgrade_rank():
		if num.rank < Global.dict[word.class].rank.keys().size()-1:
			num.rank += 1
			
			Global.rng.randomize()
			var index_r = Global.rng.randi_range(0, Global.dict[word.class].rank[str(num.rank)].size() - 1)
			
			word.type = Global.dict[word.class].rank[str(num.rank)][index_r]
			print(word.type)
		else:
			print("OverExpCannon")

class Ammo:
	var word = {}
	var num = {}
	var obj = {}

	func _init(input_):
		word.class = "Ammo"
		num.rank = input_.rank
		num.level = {}
		num.level.current = 0
		num.factor = 1
		word.type = input_.type
		obj.owner = input_.owner

	func detonation(data_):
		var description = Global.dict[word.class].description[word.type]
		var charge = float(obj.owner.num.charge)/Global.dict["Cannon"].description[obj.owner.arr.cannon.front().word.type]["Directions"].size()
		
		match obj.owner.arr.cannon.front().word.type:
			"Beamer":
				charge /= data_.hexs.size()
			"Artillery":
				charge /= data_.hexs.size()
		
		var targets = []
		var target = {}
		target.hex = data_.hex
		target.charge = description["Alpha Part"]*charge
		targets.append(target)
		obj.owner.update_borderlands()

		for index in description["Directions"]:
			var hexs = [data_.hex]
			var current_index = (data_.direction_index+index)%Global.num.map.neighbors
			
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

class Bastion:
	var word = {}
	var num = {}
	var arr = {}
	var flag = {}
	var obj = {}
	var node = {}
	var dict = {}

	func _init(input_):
		word.class = "Bastion"
		num.index = Global.num.primary_key.bastion
		Global.num.primary_key.bastion += 1
		obj.capital = input_.hex
		obj.capital.obj.bastion = self
		obj.capital.flag.capital = true
		obj.map = obj.capital.obj.map
		arr.hex = [obj.capital]
		init_nodes()
		init_nums()
		init_deck()
		init_cannons()
		init_ammos()
		init_poker()
		init_upgrades()
		init_elements()

	func init_nums():
		num.fuel = 0
		num.charge = 0
		num.refill = {}
		num.refill.card = Global.num.deck.refill
		num.experience = {}
		num.experience.current = 0
		num.experience.max = 1
		num.level = {}
		num.level.current = -1
		num.upgrade = {}
		num.upgrade.current = 0
		Global.rise_level(self)
		num.factor = 1
		num.element = num.index*Global.arr.element.size()/Global.num.primary_key.bastion

	func init_nodes():
		node.level = Label.new()
		node.level.set("custom_fonts/font", Global.font.chunkfive)
		Global.node.BastionLevels.add_child(node.level)

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
				input.bastion = self
				var card = Classes.Card.new(input)
				arr.card.append(card)
		
		for card in arr.card:
			arr.deck.append(card)
		
		arr.deck.shuffle()

	func init_cannons():
		arr.cannon = []
		var input = {}
		input.owner = self
		input.type = "Singler"#Singler Rounder Faner Beamer Artillery
		input.rank = 0
		var cannon = Classes.Cannon.new(input)
		arr.cannon.append(cannon)

	func init_ammos():
		arr.ammo = []
		
		for _i in Global.dict["Ammo"].size:
			var input = {}
			input.owner = self
			input.type = "Basic"# Basic Piercer Splasher Blader Blaster Waver
			input.rank = 0
			var ammo = Classes.Ammo.new(input)
			arr.ammo.append(ammo)

	func init_upgrades():
		dict.upgrade = {}
		
		for class_ in Global.dict.upgrade.rise.keys():
			dict.upgrade[class_] = {}
			
			for type in Global.dict.upgrade.rise[class_].keys():
				dict.upgrade[class_][type] = {}
				dict.upgrade[class_][type]["Weight"] = 0
				dict.upgrade[class_][type]["Indexs"] = {}
				dict.upgrade[class_][type]["Indexs"][0] = []
				
				match class_:
					"Card":
						dict.upgrade[class_][type]["Indexs"][0].append_array(arr.card)
						
						for card in dict.upgrade[class_][type]["Indexs"][0]:
							if card.word.type == "Trigger":
								dict.upgrade[class_][type]["Indexs"][0].erase(card)
					"Ammo":
						dict.upgrade[class_][type]["Indexs"][0].append_array(arr.ammo)
					"Cannon":
						dict.upgrade[class_][type]["Indexs"][0].append_array(arr.cannon)
		
		reset_weights()

	func reset_weights():
		if flag.poker:
			dict.upgrade["Card"]["Denomination"]["Weight"] = 1
			dict.upgrade["Card"]["Element"]["Weight"] = 4
		if flag.peak:
			dict.upgrade["Card"]["Shift"]["Weight"] = 1

	func init_elements():
		arr.element = []
		dict.element = {}
		
		for element in Global.arr.element:
			dict.element[element] = 0
			
		dict.element[Global.arr.element[num.element]] += 1

	func init_poker():
		flag.peak = false
		flag.poker = true
		arr.poker = []
		dict.poker = {}
		#dict.poker["Denomination"].pool = []
		dict.poker["Element"] = []
		
		for _i in Global.dict.poker.size["Denomination"]:
			for _j in Global.dict.poker.size["Element"]:
				dict.poker["Element"].append(Global.arr.element[_j]) 

	func refill_hand():
		for _i in num.refill.card:
			pull_card()

	func pull_card():
		if arr.deck.size() > 0:
			arr.hand.append(arr.deck.pop_back())
		else:
			reshuffle() 
			arr.hand.append(arr.deck.pop_back())

	func reshuffle():
		while arr.discard.size() > 0:
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
		
		if  Global.dict["Cannon"].description[arr.cannon.front().word.type]["Standart"]:
			for index in Global.dict["Cannon"].description[arr.cannon.front().word.type]["Directions"]:
				var sub_index = (direction_index+index)%Global.num.map.neighbors
				#pint(sub_index,self,num.charge)
				sub_launch(sub_index)
		else:
			load_basic_ammo()
			
			match arr.cannon.front().word.type:
				"Beamer":
					launch_beamer(direction_index)
				"Artillery":
					launch_artillery(direction_index)
		
		next_ammo()
		num.fuel = 0
		num.charge = 0
		arr.element = []

	func launch_beamer(direction_index_):
		var data = {}
		data.hexs = [obj.capital]
		data.direction_index = direction_index_
		
		for  _i in Global.dict["Cannon"].description[arr.cannon.front().word.type]["Range"]:
			if data.hexs.back().dict.direction[direction_index_].flag.visiable:
				data.hexs.append(data.hexs.back().dict.direction[direction_index_])
			else:
				break
		
		data.hexs.pop_front()
		
		for hex in data.hexs:
			data.hex = hex
			arr.ammo.front().detonation(data)

	func launch_artillery(direction_index_):
		update_borderlands()
		var data = {}
		data.hexs = [obj.capital]
		data.direction_index = direction_index_
		var options = []
		var min_d = Global.num.map.rings * 2
		var max_d = 0
		
		while !arr.borderland.has(data.hexs.back()) && data.hexs.back().dict.direction[direction_index_] != null:
			data.hexs.append(data.hexs.back().dict.direction[direction_index_])
		
		for borderland in arr.borderland:
			for neighbor in borderland.arr.neighbor:
				if !arr.borderland.has(neighbor) && !arr.hex.has(neighbor):
					var option = {}
					option.hex = neighbor
					option.direction_d = data.hexs.back().vec.grid.distance_to(neighbor.vec.grid)
					option.capital_d = data.hexs.front().vec.grid.distance_to(neighbor.vec.grid)
					options.append(option)
					
					if min_d > option.capital_d:
						min_d = option.capital_d
					if max_d < option.direction_d:
						max_d = option.direction_d
		
		for _i in options.size():
			var option = options[_i]
			
			for _j in (max_d-option.direction_d)+(option.capital_d-min_d):
				options.append(option)
		
		Global.rng.randomize()
		var index_r = Global.rng.randi_range(0, options.size()-1)
		var arounds = obj.map.get_hexs_around_hex(options[index_r].hex,Global.dict["Cannon"].description[arr.cannon.front().word.type]["Range"])
		data.hexs = []
		
		for around in arounds:
			for hex in around:
				if hex.flag.visiable:
					data.hexs.append(hex)
		
		for hex in data.hexs:
			data.hex = hex
			arr.ammo.front().detonation(data)

	func load_basic_ammo():
		while arr.ammo.front().word.type != "Basic":
			next_ammo()

	func sub_launch(sub_index_):
		var data = {}
		data.hexs = [obj.capital]
		data.direction_index = sub_index_
		var type = ""
		#pls fix this bug 1
		var counter = 0
		var finish = false
		
		while !finish && counter < 100:
			counter += 1
			
			if data.hexs.back().obj.bastion == null:
				type = "Damage"
			else:
				if data.hexs.back().obj.bastion.num.index == num.index:
					type = "Move"
				else:
					type = "Damage"
			
			match type:
				"Move":
					data.hexs.append(data.hexs.back().dict.direction[data.direction_index])
					
					if !data.hexs.back().dict.direction[data.direction_index].flag.visiable:
						data.direction_index = get_after_border_direction(data.hexs.back(), data.direction_index)
					
					data.direction_index = get_deviation(data)
				"Damage":
					data.hex = data.hexs.back()
					arr.ammo.front().detonation(data)
					activate_effect(data)
					finish = true

	func activate_effect(data_):
		if arr.element.size() > 0:
			Global.rng.randomize()
			var index_r = Global.rng.randi_range(0, arr.element.size()-1)
			var element = arr.element[index_r]
			
			match element:
				"Earth":
					var targets = [data_.hexs[0]]
					
					for hex in data_.hexs:
						if arr.hex.has(hex):
							targets = [hex]
					
					for neighbor in targets.front().arr.neighbor:
						if arr.hex.has(neighbor):
							targets.append(neighbor)
					
					for target in targets:
						var input = {}
						input.type = "Barricade"
						input.charge = sqrt(float(num.charge)/Global.dict["Cannon"].description[arr.cannon.front().word.type]["Directions"].size())
						input.hex = target
						input.bastion = self

	func next_ammo():
		var ammo = arr.ammo.pop_front()
		arr.ammo.append(ammo)

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

	func get_deviation(data_):
		var options = []
		var copy = 2
		
		for _i in range(-1,1,1):
			var index = (data_.direction_index+_i+Global.num.map.neighbors)%Global.num.map.neighbors
			
			if data_.hexs.back().dict.direction[index] != null:
				if data_.hexs.back().dict.direction[index].flag.visiable:
					options.append(index)
				
					if index == data_.direction_index:
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

	func choose_upgrade():
		var datas = []
		
		for class_ in dict.upgrade.keys():
			for type in dict.upgrade[class_].keys():
				for index in dict.upgrade[class_][type]["Indexs"].keys():
					if dict.upgrade[class_][type]["Indexs"][index].size() > 0:
						var data = {}
						data.class = class_
						data.type = type
						data.index = index
						data.bonus = 1
						
						if Global.get_price(data) <= num.upgrade.current: 
							for _i in dict.upgrade[class_][type]["Weight"]:
								datas.append(data)
		
		Global.rng.randomize()
		var index_r = Global.rng.randi_range(0, datas.size()-1)
		var data = datas[index_r]
		Global.rng.randomize()
		var a = dict.upgrade[data.class][data.type]
		index_r = Global.rng.randi_range(0, dict.upgrade[data.class][data.type]["Indexs"][data.index].size()-1)
		data.obj = dict.upgrade[data.class][data.type]["Indexs"][data.index].pop_at(index_r)
		Global.upgrade(data)
		
		if data.type != "Shift" && data.type != "Element":
			if dict.upgrade[data.class][data.type]["Indexs"].keys().has(data.index+1):
				dict.upgrade[data.class][data.type]["Indexs"][data.index+1].append(data.obj)
			else:
				dict.upgrade[data.class][data.type]["Indexs"][data.index+1] = [data.obj]

	func die():
		obj.capital.flag.capital = false
		
		for hex in arr.hex:
			hex.reset()
		
		for child in Global.node.BastionLevels.get_children():
			if child == node.level: 
				child.queue_free()
				
		
		Global.obj.map.arr.bastion.erase(self)

class Map:
	var word = {}
	var arr = {}
	var flag = {}

	func _init():
		word.class = "Map"
		arr.dot = []
		arr.hex = []
		arr.bastion = []
		flag.ready = false
		
		init_dots()
		init_hexs()
		init_neighbors()
		set_visiable_around_center()
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

	func get_hexs_around_hex(hex_,rings_):
		var arounds = [[hex_]]
		var totals = [hex_]
		
		for _i in rings_:
			var next_ring = []
			
			for _j in range(arounds[_i].size()-1,-1,-1):
				for neighbor in arounds[_i][_j].arr.neighbor:
					if !totals.has(neighbor):
						next_ring.append(neighbor)
						totals.append(neighbor)
			
			arounds.append(next_ring)
		
		return arounds

	func set_visiable_around_center():
		var center = arr.hex[arr.hex.size()/2][arr.hex.size()/2]
		var arounds = get_hexs_around_hex(center,Global.num.map.rings-2)
		
		for _i in arounds.size():
			for hex in arounds[_i]:
				hex.num.ring = _i
				hex.flag.visiable = true

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
