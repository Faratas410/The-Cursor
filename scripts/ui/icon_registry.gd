extends Node
class_name IconRegistry

# Centralized icon registry for gameplay icons
# Pure data mapping, no gameplay logic

const RELIC_ICONS: Dictionary = {
	"ritual_skull": preload("res://assets/ui/icons/relics/relic_skull.png"),
	"cursed_coin": preload("res://assets/ui/icons/relics/relic_coin.png"),
	"forbidden_book": preload("res://assets/ui/icons/relics/relic_book.png"),
	"dark_idol": preload("res://assets/ui/icons/relics/relic_idol.png"),
	"broken_halo": preload("res://assets/ui/icons/relics/relic_halo.png"),
	"ritual_orb": preload("res://assets/ui/icons/relics/relic_orb.png")
}

const UPGRADE_ICONS: Dictionary = {
	"conversion_speed": preload("res://assets/ui/icons/upgrades/upgrade_conversion_speed.png"),
	"cult_influence": preload("res://assets/ui/icons/upgrades/upgrade_cult_influence.png"),
	"faith_multiplier": preload("res://assets/ui/icons/upgrades/upgrade_faith_multiplier.png"),
	"mass_conversion": preload("res://assets/ui/icons/upgrades/upgrade_mass_conversion.png"),
	"dark_ritual": preload("res://assets/ui/icons/upgrades/upgrade_dark_ritual.png"),
	"corruption_power": preload("res://assets/ui/icons/upgrades/upgrade_corruption_power.png"),
	"cult_growth": preload("res://assets/ui/icons/upgrades/upgrade_candle_rite.png"),
	"candle_rite": preload("res://assets/ui/icons/upgrades/upgrade_candle_rite.png"),
	"conversion_chain": preload("res://assets/ui/icons/upgrades/upgrade_conversion_chain.png"),
	"divine_favor": preload("res://assets/ui/icons/upgrades/upgrade_divine_favor.png"),
	"forbidden_knowledge": preload("res://assets/ui/icons/upgrades/upgrade_forbidden_knowledge.png"),
	"ritual_mastery": preload("res://assets/ui/icons/upgrades/upgrade_ritual_mastery.png"),
	"cult_dominion": preload("res://assets/ui/icons/upgrades/upgrade_cult_dominion.png")
}

static func get_relic_icon(icon_name: String) -> Texture2D:
	if RELIC_ICONS.has(icon_name):
		return RELIC_ICONS[icon_name] as Texture2D
	return null

static func get_upgrade_icon(icon_name: String) -> Texture2D:
	if UPGRADE_ICONS.has(icon_name):
		return UPGRADE_ICONS[icon_name] as Texture2D
	return null
