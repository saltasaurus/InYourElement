extends Node

enum Elements {
	NONE, FIRE, WATER, EARTH, AIR, STEAM, EMBER, SMOKE, MUD, MIST, DUST
}

static func get_element_string(key: int) -> String:
	return Elements.keys()[key]

const COMBO_TABLE: Dictionary = {
	"FIRE_WATER": Elements.STEAM,
	"EARTH_FIRE": Elements.EMBER,
	"AIR_FIRE": Elements.SMOKE,
	"EARTH_WATER": Elements.MUD,
	"AIR_WATER": Elements.MIST,
	"AIR_EARTH": Elements.DUST
}

func get_result_element(base: Elements, infusion: Elements) -> Elements:
	if base == infusion:
		return base
	
	if infusion == Elements.NONE:
		return base
	
	if base == Elements.NONE:
		push_warning("Base element not set")
		return infusion
				
	# Sort on string, not enum
	var combined_elements_list = [
		get_element_string(base),
		get_element_string(infusion)
		]
	
	# Ensure consistent element ordering
	combined_elements_list.sort()
	
	var infusion_key = "%s_%s" % combined_elements_list
		
	return COMBO_TABLE[infusion_key]
