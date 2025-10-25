extends Node3D

@onready var window: Window = get_window()
@onready var player: Player = get_tree().get_first_node_in_group('Players')

# GOAL:
# Create the potion out of the asked for ingredients

# DO: 
# - Push the desired ingredients in
# - Push the scary ingredients in
# - Dodge the traps
# - Portals appear on the 4 walls, at increments. 
# - Use Portals to disappear bad ingredients or hazards
# - Portals are how you get rid of unwanted enemies AND unwanted ingredients

# DO NOT: 
# - allow too many oopsies (bad ingredients)
# - run out of time to make the potions

func _ready():
	%CauldronArea.set_collision_mask_value(8, true)
	%CauldronArea.body_entered.connect(on_collect)
	%Door.body_entered.connect(on_door)
	%Door2.body_entered.connect(on_door)
	
func on_collect(body):
	if body.is_in_group("Ingredients"):
		body.queue_free()
		player.add_item()

func on_door(body):
	if body.is_in_group("Ingredients"):
		body.queue_free()	
