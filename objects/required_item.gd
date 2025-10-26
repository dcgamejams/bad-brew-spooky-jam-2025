extends Control

class_name RequiredItem

var active : bool = false : set = set_active
var complete : bool = false : set = set_complete
var ingredient_desired: Ingredient.TYPE

var COLORS: Array[Color] = [Color.AQUA, Color.CRIMSON, Color.CORNFLOWER_BLUE, Color.DARK_GOLDENROD]

func _ready() -> void:
	add_to_group("RequiredItems")
	set_active(false)

func	 set_active(value: bool):
	active = value
	if value: 
		%Question.hide()
		%Vis.show()
	else:
		%Question.show()

func set_complete(value: bool):
	complete = value
	if value == true:
		%Success.show()
	else:
		%Failure.show()
		%Vis.hide()

func set_required(type: Ingredient.TYPE):
	if type == Ingredient.TYPE.MUSHROOM:
		%Mushroom.show()
	elif type == Ingredient.TYPE.STAR:
		%Star.show()
	elif type == Ingredient.TYPE.BERRY:
		%Berry.show()
		
	#if type == 1:
		#%Mushroom.hide()
	#ingredient_desired = type
	#var box: StyleBoxFlat = %Panel.get_theme_stylebox('panel')
	#box.bg_color = COLORS[type]
	#box.bg_color.a = 0.5
	#
