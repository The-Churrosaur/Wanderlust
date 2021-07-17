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
	
	# check conscription necessary from leavers
	
	# s1 conscripts needed
	var s1c = conscripts_needed(ship1, s2_leavers, s1_leavers)
	# leavers reduced by remainder
	s1_leavers -= try_get_conscripts(ship2, ship1, s1c)
	
	var s2c = conscripts_needed(ship2, s1_leavers, s2_leavers)
	s2_leavers -= try_get_conscripts(ship1, ship2, s2c)
	
	move_pop(ship1, ship2, s1_leavers, s2_leavers)
	move_pop(ship2, ship1, s2_leavers, s1_leavers)

# does this ship still need conscripts after estimating entering, leaving crew
func conscripts_needed(ship, entering, leaving) -> int: 
	var delta = ship.essential_crew - (ship.population - leaving + entering)
	var amount = int(max(delta, 0))
	print(ship.name, ", conscripts needed: ", amount)
	return amount

# moves amount from ship to ship2
# returns unfilled remainder
func try_get_conscripts(ship, ship2, amount) -> int: 
	var delta = amount - ship.get_conscripts()
	delta = int(max(0, delta))
	# transfer personnel
	var transfer = amount - delta
	print("transferring conscripts: ", transfer)
	move_pop(ship, ship2, transfer, 0)
	
	return delta

func move_pop(ship1, ship2, pop, pop_out): # moves pop from ship1 to ship2
	
	# caps amount to smalled ship max population
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
	
	print("moving: ", moveable, " from: ", ship1.name, " to ", ship2.name)
	
	ship1.population -= moveable
	ship2.population += moveable
	
	# transfer humanity
	var val = ship1.hpc() * moveable
	ship2.humanity += val
	ship1.humanity -= val
