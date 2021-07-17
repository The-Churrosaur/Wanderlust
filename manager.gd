extends Node2D

export var path_1 : NodePath
export var path_2 : NodePath

onready var ship1 = get_node(path_1)
onready var ship2 = get_node(path_2)

onready var button = $Button

func _ready():
	button.connect("button_down", self, "button")

func button():
	dock()

func dock():
	print("docking ships")
	
	var s1_leavers = ship1.get_leavers(ship2)
	var s2_leavers = ship2.get_leavers(ship1)
	
	print("ship1 leavers: ", s1_leavers)
	print("ship2 leavers: ", s2_leavers)
	
	move_pop(ship1, ship2, s1_leavers, s2_leavers)
	move_pop(ship2, ship1, s2_leavers, s1_leavers)

func move_pop(ship1, ship2, pop, pop_out): # moves pop from ship1 to ship2
	
	var moveable
	var s2pop = ship2.population - pop_out
	
	if s2pop > ship2.max_pop :
		moveable = 0
	elif s2pop + pop > ship2.max_pop : 
		moveable = ship2.max_pop - s2pop
	else:
		moveable = pop
	
	# stowaways
	# see calculation in get leavers humanity
	var pcap = pop - moveable # out of remaining pop
	var a = 0.01
	var delta = pop - moveable
	
	if delta > 0 : 
		var extra = int(round(pcap * (1 - (1/(a * delta + 1)))))
		# shake it up
		if extra > 0: extra = int(randf() * extra)
		print("Stowaways: ", extra)
		moveable += extra
	
	print("moving: ", moveable, " from: ", ship1, " to ", ship2)
	
	ship1.population -= moveable
	ship2.population += moveable
	
	# transfer humanity
	var val = ship1.hpc() * moveable
	ship2.humanity += val
	ship1.humanity -= val
