/proc/gen_tacmap(map_z = 2)
	var/icon/tacmap_icon = new('white/valtos/icons/tacmap.dmi', "tacmap_base")
	// берём все турфы с нужного з-уровня и рисуем шедевр
	for(var/xx in 1 to world.maxx)
		for(var/yy in 1 to world.maxy)
			var/turf/T = locate(xx, yy, map_z)
			if(isspaceturf(T) || isopenspace(T))
				if(locate(/obj/structure/lattice) in T)
					tacmap_icon.DrawBox(rgb(143, 103, 175), xx, yy, xx, yy)
				continue
			if(isopenturf(T))
				if(isplatingturf(T))
					if(locate(/obj/structure/window) in T)
						tacmap_icon.DrawBox(rgb(0, 60, 255), xx, yy, xx, yy)
					else if(locate(/obj/machinery/door) in T)
						tacmap_icon.DrawBox(rgb(255, 0, 0), xx, yy, xx, yy)
					else
						tacmap_icon.DrawBox(rgb(109, 42, 128), xx, yy, xx, yy)
					continue
				tacmap_icon.DrawBox(rgb(220, 44, 255), xx, yy, xx, yy)
				continue
			if(isclosedturf(T))
				tacmap_icon.DrawBox(rgb(0, 195, 255), xx, yy, xx, yy)
	return tacmap_icon

/proc/gen_tacmap_areas(map_z = 2)
	var/icon/tacmap_icon = new('white/valtos/icons/tacmap.dmi', "tacmap_base")
	for(var/xx in 1 to world.maxx)
		for(var/yy in 1 to world.maxy)
			var/turf/T = locate(xx, yy, map_z)
			if(isspaceturf(T) || isopenspace(T))
				continue
			var/area/A = get_area(T)
			if(istype(A, /area/hallway))
				tacmap_icon.DrawBox(rgb(255, 255, 255), xx, yy, xx, yy)
				continue
			if(istype(A, /area/security))
				tacmap_icon.DrawBox(rgb(255, 0, 0), xx, yy, xx, yy)
				continue
			if(istype(A, /area/cargo))
				tacmap_icon.DrawBox(rgb(209, 101, 43), xx, yy, xx, yy)
				continue
			if(istype(A, /area/service/hydroponics) || istype(A, /area/service/chapel) || istype(A, /area/service/library) || istype(A, /area/commons))
				tacmap_icon.DrawBox(rgb(62, 209, 43), xx, yy, xx, yy)
				continue
			if(istype(A, /area/science))
				tacmap_icon.DrawBox(rgb(209, 43, 209), xx, yy, xx, yy)
				continue
			if(istype(A, /area/medical))
				tacmap_icon.DrawBox(rgb(0, 255, 229), xx, yy, xx, yy)
				continue
			if(istype(A, /area/ai_monitored) || istype(A, /area/command/teleporter) || istype(A, /area/command/gateway) || istype(A, /area/command))
				tacmap_icon.DrawBox(rgb(0, 60, 255), xx, yy, xx, yy)
				continue
			if(istype(A, /area/commons/storage) || istype(A, /area/maintenance))
				tacmap_icon.DrawBox(rgb(70, 70, 70), xx, yy, xx, yy)
				continue
			if(istype(A, /area/commons/vacant_room) || istype(A, /area/tcommsat) || istype(A, /area/comms) || istype(A, /area/server) || istype(A, /area/solar) || istype(A, /area/engineering))
				tacmap_icon.DrawBox(rgb(255, 145, 0), xx, yy, xx, yy)
				continue
	return tacmap_icon

GLOBAL_LIST_INIT(generated_tacmaps, list())

/proc/gen_tacmap_full(map_z = 2)
	map_z = "[map_z]"
	if(LAZYLEN(GLOB.generated_tacmaps) && GLOB.generated_tacmaps[map_z])
		return GLOB.generated_tacmaps[map_z]
	var/icon/mapofthemap   = gen_tacmap(text2num(map_z))
	var/icon/areasofthemap = gen_tacmap_areas(text2num(map_z))
	mapofthemap.Blend(areasofthemap, ICON_MULTIPLY)
	GLOB.generated_tacmaps[map_z] = mapofthemap
	return mapofthemap

/obj/tacmap
	name = "голокарта"
	desc = "Позволяет понять где ТЫ сейчас находишься."
	icon = 'icons/obj/vending.dmi' // temp
	icon_state = "modularpc"
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND
	var/list/viewers = list()

/obj/tacmap/Initialize()
	. = ..()
	gen_tacmap_full(z)

/obj/tacmap/interact(mob/user, special_state)
	. = ..()
	if(user in viewers)
		user.clear_fullscreen("tacmap")
		viewers -= user
		return
	viewers |= user
	var/atom/movable/screen/fullscreen/tacmap/S = user.overlay_fullscreen("tacmap", /atom/movable/screen/fullscreen/tacmap)
	S.our_mob = user
	START_PROCESSING(SSobj, src)

/obj/tacmap/process(delta_time)
	if(!LAZYLEN(viewers))
		return PROCESS_KILL
	for(var/mob/user in viewers)
		if(get_dist(src, user) > 1)
			user.clear_fullscreen("tacmap")
			if(user in viewers)
				viewers -= user

/atom/movable/screen/fullscreen/tacmap
	icon = 'white/valtos/icons/tacmap.dmi'
	icon_state = "tacmap_base"
	screen_loc = "CENTER-4:16,CENTER-3"
	alpha = 200
	var/mob/our_mob

/atom/movable/screen/fullscreen/tacmap/New(loc, ...)
	. = ..()
	var/mutable_appearance/imgloc = mutable_appearance('white/valtos/icons/effects.dmi', "location")
	imgloc.pixel_x = our_mob?.x
	imgloc.pixel_y = our_mob?.y
	add_overlay(imgloc)
	icon = gen_tacmap_full(our_mob?.z)
	var/matrix/M = matrix()
	M.Scale(1.5, 1.5)
	transform = M
