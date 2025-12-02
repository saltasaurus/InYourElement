extends Node

enum Elements {
	NONE, FIRE, WATER, EARTH, AIR, STEAM, EMBER, SMOKE, MUD, MIST, DUST
}

func element_str(key: int) -> String:
	return Elements.keys()[key]
