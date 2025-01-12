/datum/hud/living
	ui_style = 'icons/hud/screen_gen.dmi'

/datum/hud/living/New(mob/living/owner)
	..()

	pull_icon = new /atom/movable/screen/pull()
	pull_icon.icon = retro_hud ? ui_style : pull_icon.icon
	pull_icon.update_icon()
	pull_icon.screen_loc = retro_hud ? UI_LIVING_PULL_RETRO : UI_LIVING_PULL
	pull_icon.hud = src
	static_inventory += pull_icon

	combo_display = new /atom/movable/screen/combo()
	infodisplay += combo_display

	//mob health doll! assumes whatever sprite the mob is
	healthdoll = new /atom/movable/screen/healthdoll/living()
	healthdoll.screen_loc = retro_hud ? UI_LIVING_HEALTHDOLL_RETRO : UI_LIVING_HEALTHDOLL
	healthdoll.hud = src
	infodisplay += healthdoll
