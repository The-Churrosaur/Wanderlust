class_name humanity_test
extends Node2D

export var max_pop = 115
export var population = 100
export var balance = -0 # sum of humanity modifiers
export var log_base = 100 # for pop bonus
export var velocity = 10 # movement towards baseline, h per seond
export var wages = 10
export var starting_humanity = 0

onready var label = $HBoxContainer/Label
onready var b1 = $HBoxContainer/Button
onready var b2 = $HBoxContainer/Button2

onready var humanity = starting_humanity # current humanity
var cap = 0 # baseline humanity

func _ready():
	b1.connect("button_down", self, "button_one")
	b2.connect("button_down", self, "button_two")

func _process(delta):
	
#	humanity += positive * delta
#	humanity -= negative * delta
#
#	# population needs
##	humanity -= population * 1.0 * delta
#
#	humanity -= humanity * drag_coefficient * population * delta
	
#	var hcapita = humanity / population
#	hcapita += balance / population * delta
#	hcapita -= hcapita * drag_coefficient * delta
#	humanity = hcapita * population
	
#	var cap = balance / drag_coefficient
#	var vel = velocity * delta
#
#	# if depleting rate
#	if cap < humanity && humanity > 0 : vel /= 2
#
#	humanity = move_toward(humanity, cap, vel)
	
	# ========== 7/16 notes - additive humanity
	
	set_cap()
	
	humanity = move_toward(humanity, cap, velocity * delta)
	
	set_label()
	

func set_cap():
	# pop bonus
	
	# log of base
	var a = log(population) / log(log_base)
	a += 1
	
	cap = a * population
	
	cap += balance

func set_label():
	label.text = ""
	label.text += "\nBalance: " + String(balance)
	label.text += "\nPopulation: " + String(population)
	label.text += "\nHumanity: " + String(stepify(humanity, 0.01))
	label.text += "\nHumanity/Capita: " + String(stepify(hpc(), 0.01))

func hpc(): # humanity per capita
	return humanity / population

func get_leavers(shipB) -> int: # population that wants to go
	
	var percent = 0.0
	
	# wanderlust
	percent += 0.01 * randf()
	
	# humanity
	# 1 - 1/(ax+1) : x -> 0-1 range
	var pcap = 1 # max, 0 - 100%
	var growth_a = 0.1 # almost linear
	var hdelta = shipB.hpc() - hpc()
	
	if hdelta > 0 : percent += randf() * pcap * n_to_one(growth_a, hdelta)
	
	# wage
	var wdelta = shipB.wages - wages
	if wdelta > 0 : percent += randf() * 1 * n_to_one(0.1, wdelta)
	
	return int(percent * population)

func n_to_one(a, x) -> float: # 1 - 1/(ax+1) : x -> 0-1 range
	return 1 - (1/(a * x + 1))

func button_one():
	balance += 1

func button_two():
	balance -= 1

# notes

# if population -> modules -> humanity

