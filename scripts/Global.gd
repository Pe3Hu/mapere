extends Node


var rng = RandomNumberGenerator.new()
var noise = OpenSimplexNoise.new()
var num = {}
var arr = {}
var dict = {}
var obj = {}
var node = {}
var flag = {}
var vec = {}

func init_num():
	init_primary_key()
	
	num.map = {}
	num.map.rings = 24
	num.map.sectors = 3
	num.map.boundary = 3
	num.map.a = 10
	num.map.h = 2*num.map.a
	num.map.w = sqrt(3)*num.map.a
	num.map.neighbors = 6
	
	num.dot = {}
	num.dot.n = num.map.rings*2-1
	num.dot.rows = 4+(num.dot.n-1)*2
	num.dot.cols = 1+num.dot.n
	
	num.deck = {}
	num.deck.size = 12
	num.deck.refill = num.deck.size/3
	
	num.ammo = {}
	num.ammo.size = 6

func init_primary_key():
	num.primary_key = {}
	num.primary_key.dot = 0
	num.primary_key.hex = 0
	num.primary_key.bastion = 0

func init_dict():
	dict.deck = {}
#	dict.deck.base = {
#		"Trigger": 1,
#		"Blank": num.deck.size-dict.deck.base["Trigger"]
#	}
	dict.deck.base = {}
	dict.deck.base["Trigger"] = 1
	dict.deck.base["Blank"] = num.deck.size-dict.deck.base["Trigger"]
	
	dict.sphenic_number = {}
	calc_sphenic_numbers()
	#rint(dict.sphenic_number)
#	var file_path = "res://jsons/"
#	var file_name = "sphenic_number"
#	dict.sphenic_number = load_json(file_path,file_name)
	
	dict.sphenic_number.keys = []
	
	for key in dict.sphenic_number.full.keys():
		dict.sphenic_number.keys.append(int(key))
	
	dict.cannon = {}
	dict.cannon.rank = {
		"0": ["Singler"],
		"1": ["Rounder","Faner"],
		"2": ["Beamer","Artillery"]
	}
	dict.cannon.description = {
		"Singler": {
			"Directions": [0],
		},
		"Rounder": {
			"Directions": [0,4,2],
		},
		"Faner": {
			"Directions": [0,5,1],
		},
		"Beamer": {
			"Directions": [0],
		},
		"Artillery": {
			"Directions": [0],
		}
	}
	dict.ammo = {}
	dict.ammo.rank = {
		"0": ["Basic"],
		"1": ["Splasher","Piercer"],
		"2": ["Blader","Waver","Blaster"]
	}
	dict.ammo.description = {
		"Basic": {
			"Alpha Part": 1,
			"Beta Part": 0,
			"Directions": [],
			"Range": 0,
			"Dilution": 0,
			"Alpha Factor": 1,
			"Beta Factor": 0
		},
		"Splasher": {
			"Alpha Part": 0.5,
			"Beta Part": 0.5,
			"Directions": [5,1],
			"Range": 1,
			"Dilution": 0,
			"Alpha Factor": 1,
			"Beta Factor": 1
		},
		"Piercer": {
			"Alpha Part": 0.5,
			"Beta Part": 0.5,
			"Directions": [0],
			"Range": 1,
			"Dilution": 0,
			"Alpha Factor": 1,
			"Beta Factor": 1
		},
		"Blader": {
			"Alpha Part": 0.5,
			"Beta Part": 0.5,
			"Directions": [0,1,2],
			"Range": 2,
			"Dilution": 0,
			"Alpha Factor": 1,
			"Beta Factor": 1
		},
		"Waver": {
			"Alpha Part": 0.5,
			"Beta Part": 0.5,
			"Directions": [0,1],
			"Range": 3,
			"Dilution": 0,
			"Alpha Factor": 1,
			"Beta Factor": 1
		},
		"Blaster": {
			"Alpha Part": 0.5,
			"Beta Part": 0.5,
			"Directions": [0,1,2,3,4,5],
			"Range": 1,
			"Dilution": 0,
			"Alpha Factor": 1,
			"Beta Factor": 1
		}
	}
	
	dict.sphenic_number.keys.sort()
	
	for key in dict.sphenic_number.keys:
		var flag = false
		
		for obj in dict.sphenic_number.full[key]:
			if obj.values[0] == 5:
				flag = true
#		if flag:
#			rint(dict.sphenic_number[key])
#		rint(key," min ",dict.sphenic_number.full[key][0].mult," max ",dict.sphenic_number.full[key][dict.sphenic_number.full[key].size()-1].mult)
	dict.path = {}
	dict.path.label = NodePath("res://Game/BastionLevel")

func init_arr():
	arr.sequence = {} 
	arr.sequence["A000040"] = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67]#, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199
	arr.sequence["A000045"] = [0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987]
	arr.sequence["A000124"] = [1, 2, 4, 7, 11, 16]#, 22, 29, 37, 46, 56, 67, 79, 92, 106, 121, 137, 154, 172, 191, 211
	arr.sequence["A001358"] = [4, 6, 9, 10, 14, 15, 21, 22, 25, 26]#, 33, 34, 35, 38, 39, 46, 49, 51, 55, 57, 58, 62, 65, 69, 74, 77, 82, 85, 86, 87, 91, 93, 94, 95, 106
	arr.sequence["A000108"] = [1, 1, 2, 5, 14, 42, 132, 429, 1430]
	arr.sequence["A160860"] = [1, 4, 11, 24, 47, 80]
	arr.sequence["A006003"] = [0, 1, 5, 15, 34, 65, 111, 175, 260, 369, 505, 671, 870]
	arr.sequence["A007304"] = [30, 42, 66, 70, 78, 102, 105, 110, 114, 130, 138, 154, 165, 170, 174, 182, 186, 190, 195, 222, 230, 231, 238, 246, 255, 258, 266, 273, 282, 285, 286]
	
	
	arr.neighbor = [
		[
			Vector2( 1,-1), 
			Vector2( 1, 0), 
			Vector2( 1, 1), 
			Vector2( 0, 1), 
			Vector2(-1, 0),
			Vector2( 0,-1)
		],
		[
			Vector2( 0,-1),
			Vector2( 1, 0),
			Vector2( 0, 1),
			Vector2(-1, 1),
			Vector2(-1, 0),
			Vector2(-1,-1)
		]
	]
	
	arr.spin = [
		[
			Vector2( 1,-1), 
			Vector2( 0, 1), 
			Vector2( 0, 1), 
			Vector2( 0, 1), 
			Vector2(-1,-1),
			Vector2( 0,-1)
		],
		[
			Vector2( 1, 1),
			Vector2( 0, 1),
			Vector2(-1, 1),
			Vector2( 0,-1),
			Vector2( 0,-1),
			Vector2( 0,-1)
		]
	]
	
	arr.element = ["Aqua","Wind","Fire","Earth"]

func init_node():
	node.TimeBar = get_node("/root/Game/TimeBar") 
	node.Game = get_node("/root/Game") 
	node.BastionLevel = get_node("/root/Game/BastionLevel") 
	node.BastionCharge = get_node("/root/Game/BastionCharge") 

func init_flag():
	flag.click = false
	flag.grid = {}
	flag.grid.odd = true

func init_vec():
	init_window_size()
	
	vec.map = {}
	vec.map.offset = vec.window_size.center
	vec.map.offset.y -= Global.num.map.h/2
	vec.map.offset.x -= Global.num.map.w
	vec.map.offset.x -= (num.dot.rows-1)*num.map.w / 4
	vec.map.offset.y -= (num.dot.cols+0.5*(num.dot.n-1))*num.map.h / 4

func reload_noise():
	Global.rng.randomize()
	Global.noise.seed = Global.rng.randi()
	Global.noise.octaves = 3
	Global.noise.period = 20.0
	Global.noise.persistence = 0.8

func init_window_size():
	vec.window_size = {}
	vec.window_size.width = ProjectSettings.get_setting("display/window/size/width")
	vec.window_size.height = ProjectSettings.get_setting("display/window/size/height")
	vec.window_size.center = Vector2(vec.window_size.width/2, vec.window_size.height/2)

func _ready():
	init_num()
	init_arr()
	init_dict()
	init_node()
	init_flag()
	init_vec()

func save_json(data_,file_path_,file_name_):
	var file = File.new()
	file.open(file_path_+file_name_+".json", File.WRITE)
	file.store_line(to_json(data_))
	file.close()

func load_json(file_path_,file_name_):
	var file = File.new()
	
	if not file.file_exists(file_path_+file_name_+".json"):
			 #save_json()
			 return null
	
	file.open(file_path_+file_name_+".json", File.READ)
	var data = parse_json(file.get_as_text())
	return data

func calc_sphenic_numbers():
	#products of 3 distinct primes
	var values = {}
	
	for _i in arr.sequence["A000040"].size():
		for _j in range(_i+1,arr.sequence["A000040"].size(),1):
			for _k in range(_j+1,arr.sequence["A000040"].size(),1):
				var obj = {}
				obj.mult = 1
				obj.sum = 0
				obj.indexs = [_i,_j,_k]
				obj.values = []
				
				
				for index in obj.indexs:
					var value = arr.sequence["A000040"][index]
					obj.values.append(value)
					obj.sum += value
					obj.mult *= value
				
				if values.keys().has(obj.sum):
					values[obj.sum].append(obj)
				else:
					values[obj.sum] = [obj]
	
				obj.value = obj.mult
	
	for key in values:
		values[key].sort_custom(Classes.Sorter, "sort_ascending")
	
	var file_path = "res://jsons/"
	var file_name = "sphenic_number"
	#save_json(values,file_path,file_name)
	#rint(values)
	dict.sphenic_number.full = values
	
