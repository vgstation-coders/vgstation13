/area/shuttle/eet_mothership
	name = "\improper Extraterrestrial Mothership"
	icon_state = "shuttle"

/datum/map_element/dungeon/eetmothership
	file_path = "maps/randomvaults/dungeons/eetmothership.dmm"
	unique = TRUE

    /***********************
	*                      *
	*        Items         *
	*                      *
	***********************/

/obj/item/eet_implant
	name = "enigmatic implant"
	desc = "It's pulsing and warm..."

/obj/item/device/mindchip
	name = "enigmatic mindchip"
	desc = "EETs use these to reclaim the minds of other dead EETs."
	icon = 'icons/obj/eet.dmi'
	icon_state = "mindchip"
	var/datum/mind/mind

/obj/item/device/mindchip/preattack(var/atom/A, mob/user)
	if(ishuman(A) && !mind)
		var/mob/living/carbon/human/H = A
		if(H.stat == DEAD && H.mind.GetRole(EET))
			mind = H.mind
			to_chat(H,"<span class='danger'><font size='3'>Your mind has been backed up to a mindchip.</font></span>")
			return 1
	else
		..()

    /***********************
	*                      *
	*      Structures      *
	*       Machines       *
	***********************/

/obj/structure/reagent_dispensers/eet_ship_core
	name = "enigmatic engine core"
	desc = "This device somehow propels an EET vessel."
	icon = 'icons/obj/eet.dmi'
	icon_state = "shipcore"

/obj/structure/reagent_dispensers/eet_ship_core/New()
	..()
	reagents.maximum_volume = ARBITRARILY_LARGE_NUMBER*2
	if(!eet_core)
		eet_core = src

/obj/structure/reagent_dispensers/eet_ship_core/ex_act()
	return

/obj/structure/reagent_dispensers/eet_ship_core/attack_hand(mob/user)
	..()
	if(reagents.reagent_list.len>1)
		reagents.isolate_reagent(FUEL)
		to_chat("<span class='notice'>You flush the non-fuel from \the [src].</span>")

/obj/machinery/smartfridge/eet_archive
	name = "enigmatic archive"
	desc = "This is the key component in all EET research efforts."
	icon = 'icons/obj/eet.dmi'
	icon_state = "archive"
	accepted_types = list(/obj/item)

/obj/machinery/smartfridge/eet_archive/New()
	. = ..()
	if(!eet_arch)
		eet_arch = src
	var/obj/item/seeds/random/S = new
	eet_seeds = S.seed
	insert_item(S)
	var/obj/item/weapon/virusdish/random/V
	eet_virus = V.virus2
	V.growth = 100
	insert_item(V)
	insert_item(new /obj/item/device/mindchip)
	insert_item(new /obj/item/device/mindchip)
	insert_item(new /obj/item/device/mindchip)
	insert_item(new /obj/item/device/mindchip)
	insert_item(new /obj/item/weapon/reagent_containers/food/snacks/yogurt)
	insert_item(new /obj/item/weapon/reagent_containers/food/snacks/yogurt)
	insert_item(new /obj/item/weapon/reagent_containers/food/snacks/yogurt)
	insert_item(new /obj/item/weapon/reagent_containers/food/snacks/yogurt)
	insert_item(new /obj/item/weapon/reagent_containers/food/snacks/yogurt)
	insert_item(new /obj/item/weapon/reagent_containers/food/snacks/yogurt)

/obj/machinery/smartfridge/eet_archive/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if(isscrewdriver(O))
		return 1
	..()

/obj/machinery/smartfridge/eet_archive/attack_hand(mob/user)
	if(user.mind.GetRole(EET))
		..()

/obj/machinery/smartfridge/eet_archive/ex_act()
	return

/obj/structure/eet_continuum
	name = "enigmatic mind continuum"
	desc = "The source of all preserved EET thought."
	icon = 'icons/obj/eet.dmi'
	icon_state = "continuum"
	var/list/eet_freeminds = list() //This should be a list of lists to work with NanoUI

/obj/structure/eet_continuum/New()
	..()
	if(!eet_cont)
		eet_cont = src

/obj/structure/eet_continuum/ex_act()
	return

/obj/structure/eet_continuum/attack_hand(mob/user)
	return ui_interact(user)

/obj/structure/eet_continuum/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open=NANOUI_FOCUS)
	if (gcDestroyed || !get_turf(src) || !anchored)
		if(!ui)
			ui = nanomanager.get_open_ui(user, src, ui_key)
		if(ui)
			ui.close()
		return

	var/data[0]
	data["name"] = name
	data["mindList"] = eet_freeminds

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "eet_mind_cont.tmpl", "Mind Continuum", 520, 460)
		ui.set_initial_data(data)
		ui.open()

/obj/structure/eet_continuum/attackby(mob/user,obj/item/I)
	if(istype(I,/obj/item/device/mindchip))
		var/obj/item/device/mindchip/M = I
		if(!M.mind)
			to_chat(user,"<span class='warning'>There was no mind within!</span>")
			return
		eet_freeminds[eet_freeminds.len+1] = list(M.mind,FALSE) //List of lists. Contains minds and whether they're muted.

		var/mob/camera/eet/E = new(src.loc)
		M.mind.current = E
		M.mind = null
		playsound(src, 'sound/weapons/emitter.ogg', 25, 1)

/obj/machinery/computer/eet_datacore
	name = "Enigmatic Data Core"
	desc = "Who knows what sort of mysterious data this computer could hold?"
	icon_state = "ai-fixer"
	light_color = LIGHT_COLOR_PURPLE
	var/datum/faction/eet_faction

/obj/machinery/computer/eet_datacore/New()
	..()
	eet_faction = find_active_faction_by_type(/datum/faction/eet)

/obj/machinery/computer/eet_datacore/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if(isscrewdriver(O))
		return 1
	..()

/obj/machinery/computer/eet_datacore/ex_act()
	return

/obj/machinery/computer/eet_datacore/attack_hand(var/mob/user as mob)
	if(..())
		return
	if(!user.mind.GetRole(EET))
		return
	user.set_machine(src)
	var/wand=0
	var/dead=0
	for(var/datum/role/R in eet_faction.members)
		if(R.antag.current.stat == DEAD)
			dead++
		else
			wand++
	var/dat = list()
	dat += "<center>"
	dat += "Wandering Minds: [wand]<BR>"
	dat += "Free Minds: [eet_cont.eet_freeminds.len]<BR>"
	dat += "Lost Minds: [dead]<BR>"
	dat += "Cultural Spread (type 1): [eet_rel.adepts.len]<BR>"
	dat += "Cultural Spread (type 2): <BR>"
	dat += "Cultural Spread (type 3): <BR>"
	dat += "</center>"
	dat = jointext(dat,"")
	var/datum/browser/popup = new(user, "eet_data", "Enigmatic Data Core", 325, 500, src)
	popup.set_content(dat)
	popup.open()
	onclose(user, "eet_data")

/obj/machinery/computer/security/eet
	name = "Enigmatic Camera Console"
	desc = "It's so different than human technology!"
	icon_state = "teleport"
	light_color = LIGHT_COLOR_PURPLE

/obj/machinery/computer/security/eet/attack_ai(var/mob/user)
	return

/obj/machinery/computer/security/eet/ex_act()
	return

/obj/machinery/computer/security/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if(isscrewdriver(O))
		return 1
	..()