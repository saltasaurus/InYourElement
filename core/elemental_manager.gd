extends Node

const COMBO_TABLE: Dictionary = {
	"FIRE_WATER": Enums.Elements.STEAM,
	"EARTH_FIRE": Enums.Elements.EMBER,
	"AIR_FIRE": Enums.Elements.SMOKE,
	"EARTH_WATER": Enums.Elements.MUD,
	"AIR_WATER": Enums.Elements.MIST,
	"AIR_EARTH": Enums.Elements.DUST
}

func get_result_element(base: Enums.Elements, infusion: Enums.Elements) -> Enums.Elements:
	print(Enums.element_str(base), " + ", Enums.element_str(infusion))
	if base == infusion:
		return base
	
	if infusion == Enums.Elements.NONE:
		return base
	
	if base == Enums.Elements.NONE:
		push_warning("Base element not set")
		return infusion
				
	# Sort on string, not enum
	var combined_elements_list = [
		Enums.element_str(base),
		Enums.element_str(infusion)
		]
	
	# Ensure consistent element ordering
	combined_elements_list.sort()
	
	var infusion_key = "%s_%s" % combined_elements_list
		
	return COMBO_TABLE[infusion_key]

func get_element_color(element) -> Color:
	match element:
		Enums.Elements.FIRE:
			return Color.RED
		Enums.Elements.WATER:
			return Color.BLUE
		Enums.Elements.EARTH:
			return Color.BROWN
		Enums.Elements.AIR:
			return Color.LIGHT_GRAY
		Enums.Elements.STEAM:
			return Color.LIGHT_BLUE
		Enums.Elements.EMBER:
			return Color.ORANGE
		Enums.Elements.MUD:
			return Color.SADDLE_BROWN
		Enums.Elements.MIST:
			return Color.ALICE_BLUE
		Enums.Elements.SMOKE:
			return Color.DARK_SLATE_GRAY
		Enums.Elements.DUST:
			return Color.TAN
		_:
			return Color.WHITE
