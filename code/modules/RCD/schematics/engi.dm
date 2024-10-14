/datum/rcd_schematic/decon
	name			= "Deconstruct"
	icon			= 'icons/effects/condecon.dmi'
	icon_state		= "decon"
	category		= "Construction"
	energy_cost		= 5
	var/can_r_wall	= 0

/datum/rcd_schematic/decon/attack(var/atom/A, var/mob/user)
	if(istype(A, /turf/simulated/wall))
		var/turf/simulated/wall/T = A
		if((istype(T, /turf/simulated/wall/r_wall) && !can_r_wall) || istype(T, /turf/simulated/wall/invulnerable))
			return "it cannot deconstruct reinforced walls!"

		to_chat(user, "Deconstructing \the [T]...")
		playsound(master, 'sound/machines/click.ogg', 50, 1)

		if(master.delay(user, T, 4 SECONDS))
			if(master.get_energy(user) < energy_cost)
				return 1

			playsound(master, 'sound/items/Deconstruct.ogg', 50, 1)
			T.ChangeTurf(/turf/simulated/floor/plating)
			return 0

	else if(istype(A, /turf/simulated/floor))
		var/turf/simulated/floor/T = A
		to_chat(user, "Deconstructing \the [T]...")
		if(master.delay(user, T, 5 SECONDS))
			if(master.get_energy(user) < energy_cost)
				return 1

			playsound(master, 'sound/items/Deconstruct.ogg', 50, 1)
			add_gamelogs(user, "deconstructed \the [T] with \the [master]", admin = TRUE, tp_link = TRUE, tp_link_short = FALSE, span_class = "danger")
			T.investigation_log(I_RCD,"was deconstructed by [user]")
			T.ChangeTurf(T.get_underlying_turf())
			return 0

	else if(istype(A, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/D = A
		to_chat(user, "Deconstructing \the [D]...")
		if(master.delay(user, D, 5 SECONDS))
			if(master.get_energy(user) < energy_cost)
				return 1

			playsound(master, 'sound/items/Deconstruct.ogg', 50, 1)
			D.investigation_log(I_RCD,"was deconstructed by [user]")
			qdel(D)
			return 0

	else if(istype(A,/obj/structure/window))
		var/obj/structure/window/W = A
		if(is_type_in_list(W, list(/obj/structure/window/plasma,/obj/structure/window/reinforced/plasma,/obj/structure/window/full/plasma,/obj/structure/window/full/reinforced/plasma)) && !can_r_wall)
			return "it cannot deconstruct plasma glass!"
		to_chat(user, "Deconstructing \the [W]...")
		if(master.delay(user, W, 5 SECONDS))
			if(master.get_energy(user) < energy_cost)
				return 1

			playsound(master, 'sound/items/Deconstruct.ogg', 50, 1)
			for(var/obj/structure/grille/G in W.loc)
				if(!istype(G,/obj/structure/grille/invulnerable)) // No more breaking out in places like lamprey
					G.investigation_log(I_RCD,"was deconstructed by [user]")
					qdel(G)
			for(var/obj/structure/window/WI in W.loc)
				if(is_type_in_list(W, list(/obj/structure/window/plasma,/obj/structure/window/reinforced/plasma,/obj/structure/window/full/plasma,/obj/structure/window/full/reinforced/plasma)) && !can_r_wall)
					continue
				if(WI != W)
					WI.investigation_log(I_RCD,"was deconstructed by [user]")
					qdel(WI)
			W.investigation_log(I_RCD,"was deconstructed by [user]")
			qdel(W)
			return 0
	return 1

/datum/rcd_schematic/con_floors
	name		= "Build floors"
	icon		= 'icons/turf/floors.dmi'
	icon_state	= "floor"
	category	= "Construction"
	energy_cost	= 1

	flags		= RCD_GET_TURF

/datum/rcd_schematic/con_floors/attack(var/atom/A, var/mob/user)
	if(!(istype(A, /turf/space) && !istype(A, /turf/space/transit)))
		return "it can only create floors on space!"

	var/turf/space/S = A

	to_chat(user, "Building floor...")
	playsound(master, 'sound/items/Deconstruct.ogg', 50, 1)
	S.investigation_log(I_RCD,"was made into a floor by [user]")
	S.ChangeTurf(/turf/simulated/floor/plating/airless)
	return 0

/datum/rcd_schematic/con_rfloors
	name				= "Build reinforced floors"
	icon				= 'icons/turf/floors.dmi'
	icon_state			= "engine"
	category			= "Construction"
	energy_cost			= 2

	flags		= RCD_GET_TURF

/datum/rcd_schematic/con_rfloors/attack(var/atom/A, var/mob/user)
	if(!(istype(A,/turf/simulated/floor)))
		return "it can only create floors on plating!"
	else
		var/turf/simulated/floor/F = A
		if(F.floor_tile)
			return "it can only create floors on plating!"

	var/turf/T = A

	to_chat(user, "Building floor...")
	playsound(master, 'sound/items/Deconstruct.ogg', 50, 1)
	if(master.delay(user, A, 2 SECONDS))
		if(master.get_energy(user) < energy_cost)
			return 1


		playsound(master, 'sound/items/Deconstruct.ogg', 50, 1)
		T.investigation_log(I_RCD,"was made into a reinforced floor by [user]")
		T.ChangeTurf(/turf/simulated/floor/engine/plated/airless)
	return 0

/datum/rcd_schematic/con_walls
	name		= "Build walls"
	icon		= 'icons/turf/walls.dmi'
	icon_state	= "metal0"
	category	= "Construction"
	energy_cost	= 3

/datum/rcd_schematic/con_walls/attack(var/atom/A, var/mob/user)
	if(!istype(A, /turf/simulated/floor))
		return 1

	var/turf/simulated/floor/T = A
	to_chat(user, "Building wall...")
	playsound(master, 'sound/machines/click.ogg', 50, 1)
	if(master.delay(user, A, 2 SECONDS))
		if(master.get_energy(user) < energy_cost)
			return 1

		playsound(master, 'sound/items/Deconstruct.ogg', 50, 1)
		T.investigation_log(I_RCD,"had a wall built on it by [user]")
		T.ChangeTurf(/turf/simulated/wall)
		return 0

	return 1

/datum/rcd_schematic/con_rwalls
	name				= "Build reinforced walls"
	icon				= 'icons/turf/walls.dmi'
	icon_state			= "r_wall"
	category			= "Construction"
	energy_cost			= 5

/datum/rcd_schematic/con_rwalls/attack(var/atom/A, var/mob/user)
	if(A?.type != /turf/simulated/wall) // Only one with strict type like this for now
		return "it can only reinforce existing walls!"

	var/turf/simulated/floor/T = A
	to_chat(user, "Building wall...")
	playsound(master, 'sound/machines/click.ogg', 50, 1)
	if(master.delay(user, A, 2 SECONDS))
		if(master.get_energy(user) < energy_cost)
			return 1

		playsound(master, 'sound/items/Deconstruct.ogg', 50, 1)
		T.investigation_log(I_RCD,"had a reinforced wall built on it by [user]")
		T.ChangeTurf(/turf/simulated/wall/r_wall)
		return 0

	return 1

/datum/rcd_schematic/con_airlock
	name						= "Build airlock"
	icon						= 'icons/obj/doors/door.dmi'
	icon_state					= "door_closed"
	category					= "Construction"
	energy_cost					= 3

	var/allow_access			= 1
	var/selected_name			= "Airlock"
	var/list/selected_access	= list()	//Selected access levels.
	var/one_access				= 0

	var/list/schematics			= list()
	var/ready

/datum/rcd_schematic/con_airlock/borg
	energy_cost					= 30

/datum/rcd_schematic/con_airlock/show(var/mob/living/user, close = 0)
	if(!close)
		user.shown_schematics_background = 1
		user.hud_used.toggle_show_schematics_display(schematics,1, master)
	else
		user.shown_schematics_background = 1
		user.hud_used.toggle_show_schematics_display(master.schematics["Construction"], 1, master)
		master.selected = null
	return 1

/datum/rcd_schematic/con_airlock/no_access
	allow_access				= 0

/datum/rcd_schematic/con_airlock/New()
	. = ..()

	for(var/path in typesof(/datum/selection_schematic/airlock_schematic))
		schematics += new path(src)
	schematics += new /datum/selection_schematic/access_schematic(src)
	selected = schematics[1]

/datum/rcd_schematic/con_airlock/Destroy()
	for(var/datum/selection_schematic/thing in schematics)
		QDEL_NULL(thing)
	..()

/datum/rcd_schematic/con_airlock/select(var/mob/user, var/datum/rcd_schematic/old_schematic)
	..()
	show(user)
/datum/rcd_schematic/con_airlock/deselect()
	. = ..()
	selected = schematics[1]	//Reset the selection.

/*/datum/rcd_schematic/con_airlock/register_assets()
	for(var/datum/selection_schematic/airlock_schematic/C in schematics)
		C.register_icon()

/datum/rcd_schematic/con_airlock/send_assets(var/client/client)
	for(var/datum/selection_schematic/airlock_schematic/C in schematics)
		C.send_icon(client)
*/

/datum/rcd_schematic/con_airlock/get_HTML(var/obj/machinery/door/airlock/D)
	. = "<p>"
	. += {"

		<form action="?src=\ref[master.interface]" method="get">
			<input type="hidden" name="src" value="\ref[master.interface]"/>
			[istype(D) ? "<input type=\"hidden\" name = \"target\" value=\"\ref[D]\"/>" : ""]
			<input type="text" name="new_name" value="[istype(D) ? D.name : selected_name]"/>
			<input type="submit" name="act" value="Save Name"/>
		</form><br/>
		"}
	if(allow_access)
		. += {"
		<script>
		$("#accessListShowButton").click(
			function toggleAccessList()
			{
				if($("#accessList").is(":hidden"))
				{
					$("#accessList").slideDown("fast");
					$("#accessListShowButton").html("Hide access controls");
				}
				else
				{
					$("#accessList").slideUp("fast");
					$("#accessListShowButton").html("Show access controls");
				}
			}
		);
		</script>



		<form action="?src=\ref[master.interface]" method="get" id="accessList" style="display:inline-block;font-size:100%">
			<input type="hidden" name="src" value="\ref[master.interface]"/>
			[istype(D) ? "<input type=\"hidden\" name = \"target\" value=\"\ref[D]\"/>" : ""]
			<input type="submit" value="Save Access Settings"/><br/><br/>


			Access requirement is set to: <br/>
		<table style='width:100%'>
		<tr>
		"}
		if((istype(D) && D.req_one_access && D.req_one_access.len) || (!istype(D) && one_access))	//So we check the correct button by default
			. += {"
			<input type="radio" name="oneAccess" value="0"/>ALL
			<br/>
			<input type="radio" name="oneAccess" value="1" checked/>ONE
			"}
		else
			. += {"
			<input type="radio" name="oneAccess" value="0" checked/>ALL
			<br/>
			<input type="radio" name="oneAccess" value="1"/>ONE
			"}

		for(var/i = 1; i <= 7; i++)
			. += "<td style='width:14%'><b>[get_region_accesses_name(i)]:</b></td>"
		. += "</tr><tr>"
		for(var/i = 1; i <= 7; i++)
			. += "<td style='width:14%' valign='top'>"
			for(var/A in get_region_accesses(i))
				var/access_name = get_access_desc(A)
				if(!access_name)
					continue
				var/checked = ""//((D && (D.req_access.Find(A)) || (D.req_one_access.Find(A)))) || (!D && (selected_access.Find(A))) ? " checked" : ""
				if(istype(D))
					if(D.req_access.Find(A) || D.req_one_access.Find(A))
						checked = " checked"
				else
					if(selected_access.Find(A))
						checked = " checked"
				/*if((D && (A in D.req_access) || (A in D.req_one_access)) || (!D && (A in selected_access)))
					. += {"<input type="checkbox" name="[A]" checked/> [access_name] <br/>"}
				else
					. += {"<input type="checkbox" name="[A]"/> [access_name] <br/>"}
				*/
				. += {"<input type="checkbox" name="[A]"[checked]/> [access_name] <br/>"}
//				to_chat(world, "[access_name]([A]) is [checked ? "in" : "not in"] selected access. [selected_access.Find(A) ? "find returned true" : "find returned false"]")
				. += "<br>"
			. += "</td>"
		. += "</tr></table>"
		. = "</form><tt>[.]</tt></p>"

/*
		. += {"<br/>
		Access levels: <br/>
		"}

		//Access level selection comes here.
		for(var/access in get_all_accesses())
			var/access_name	= get_access_desc(access)
			if(!access_name)	//I noticed in testing there's a broken access level that shows up, this should filter it out.
				continue

			var/checked		= ""

			if(D)
				if((access in D.req_access) || (access in D.req_one_access))
					checked		= " checked"
			else if((access in selected_access))
				checked		= " checked"
			. += {"
				<input type="checkbox" name="[access]"[checked]/> [access_name] <br/>
			"}


		. += "</form>"

	. += "</p>"
*/
/datum/rcd_schematic/con_airlock/build_ui()
	master.interface.updateLayout("<div id='schematic_options'> </div>")
	master.update_options_menu()

/datum/rcd_schematic/con_airlock/Topic(var/href, var/href_list)
	if(href_list["set_selected"])
		var/idx = clamp(text2num(href_list["set_selected"]), 1, schematics.len)
		var/datum/selection_schematic/airlock_schematic/C = schematics[idx]

		selected = C
		selected_name = C.name	//Reset the name.

		master.update_options_menu()
		return 1

	if(href_list["new_name"])
		var/obj/machinery/door/airlock/D
		if(href_list["target"])
			D = locate(href_list["target"])
			if(!istype(D))
				return
			if(!D.Adjacent(usr))
				return
			D.name = copytext(sanitize(href_list["new_name"]), 1, MAX_NAME_LEN)
			master.update_options_menu(list2params(list(D)))
			return 1
		selected_name = copytext(sanitize(href_list["new_name"]), 1, MAX_NAME_LEN)

		master.update_options_menu()
		return 1

	if(!isnull(href_list["oneAccess"]) && allow_access)
		var/OA = text2num(href_list["oneAccess"])
		var/obj/machinery/door/airlock/D
		if(href_list["target"])
			D = locate(href_list["target"])
			if(!istype(D))
				return
			if(!D.Adjacent(usr))
				return
		var/list/new_access = new
		//Along with oneAccess, the hrefs for access levels get called, as such we process them here before we return 1

		var/list/access_levels = get_all_accesses()

		for(var/href_key in href_list - list("oneAccess", "src"))	//This should loop through all the access levels that are on.
			var/access = text2num(href_key)
			if(!(access in access_levels))	//Only check valid access levels.
				continue

			new_access |= access
		if(!D)
			selected_access.Cut()
			selected_access = new_access.Copy()
			one_access = OA
		else
			if(OA)
				D.req_one_access = new_access.Copy()
				D.req_access.Cut()
			else
				D.req_access = new_access.Copy()
				D.req_one_access.Cut()

		master.update_options_menu(list2params(list(D)))
		return 1

/datum/rcd_schematic/con_airlock/attack(var/atom/A, var/mob/user)
	if(istype(A, /obj/machinery/door/airlock))
		if(!ready)
			build_ui()
			ready = 1
		master.interface.show(user)
		master.interface.updateContent("schematic_options", get_HTML(A))
		return 1

	if(!istype(A, /turf))
		return 1

	for(var/obj/machinery/door/airlock/D in A)
		return "there is already an airlock on this spot!"

	to_chat(user, "Building airlock...")

	if(!master.delay(user, A, 5 SECONDS))
		return 1

	if(master.get_energy(user) < energy_cost)
		return 1

	for(var/obj/machinery/door/airlock/D in A)
		return "there is already an airlock on this spot!"

	playsound(master, 'sound/items/Deconstruct.ogg', 50, 1)

	var/obj/machinery/door/airlock/D = new selected.build_type(A)
	if(selected_name && (capitalize(selected_name) == selected_name))	//The name inputted is capitalized, so we add \improper.
		D.name	= "\improper [selected_name]"
	else
		D.name		= selected_name

	if(allow_access)
		if(one_access)
			D.req_one_access = selected_access.Copy()
		else
			D.req_access = selected_access.Copy()

	D.autoclose	= 1
	A.investigation_log(I_RCD,"had \a [D] built on it by [user]")

/datum/rcd_schematic/con_window
	name						= "Build window"
	icon 						= 'icons/obj/window_grille_spawner.dmi'
	icon_state 					= "windowgrille"
	category					= "Construction"
	energy_cost					= 2

	var/list/schematics			= list()
	var/ready

/datum/rcd_schematic/con_window/borg
	energy_cost					= 20

/datum/rcd_schematic/con_window/show(var/mob/living/user, close = 0)
	if(!close)
		user.shown_schematics_background = 1
		user.hud_used.toggle_show_schematics_display(schematics,1, master)
	else
		user.shown_schematics_background = 1
		user.hud_used.toggle_show_schematics_display(master.schematics["Construction"], 1, master)
		master.selected = null
	return 1

/datum/rcd_schematic/con_window/New()
	. = ..()

	for(var/path in typesof(/datum/selection_schematic/window_schematic))
		schematics += new path(src)
	selected = schematics[1]

/datum/rcd_schematic/con_window/Destroy()
	for(var/datum/selection_schematic/thing in schematics)
		QDEL_NULL(thing)
	..()

/datum/rcd_schematic/con_window/select(var/mob/user, var/datum/rcd_schematic/old_schematic)
	..()
	show(user)
/datum/rcd_schematic/con_window/deselect()
	. = ..()
	selected = schematics[1]	//Reset the selection.

/*/datum/rcd_schematic/con_window/register_assets()
	for(var/datum/selection_schematic/airlock_schematic/C in schematics)
		C.register_icon()

/datum/rcd_schematic/con_window/send_assets(var/client/client)
	for(var/datum/selection_schematic/airlock_schematic/C in schematics)
		C.send_icon(client)
*/

/datum/rcd_schematic/con_window/build_ui()
	master.interface.updateLayout("<div id='schematic_options'> </div>")
	master.update_options_menu()

/datum/rcd_schematic/con_window/Topic(var/href, var/href_list)
	if(href_list["set_selected"])
		var/idx = clamp(text2num(href_list["set_selected"]), 1, schematics.len)
		var/datum/selection_schematic/window_schematic/C = schematics[idx]

		selected = C

		master.update_options_menu()
		return 1

/datum/rcd_schematic/con_window/attack(var/atom/A, var/mob/user)
	if(!istype(A, /turf))
		return 1

	to_chat(user, "Building window...")

	if(!master.delay(user, A, 5 SECONDS))
		return 1

	if(master.get_energy(user) < energy_cost)
		return 1

	playsound(master, 'sound/items/Deconstruct.ogg', 50, 1)

	new selected.build_type(A)
	A.investigation_log(I_RCD,"had \a [selected.name] built on it by [user]")

/datum/selection_schematic
	var/name			= "Selection"
	var/build_type
	var/icon_state
	var/icon
	var/list/overlays 	= list()
	var/obj/abstract/screen/ourobj
	var/datum/rcd_schematic/master

/datum/selection_schematic/proc/clicked(var/mob/user)
	return 0

/datum/selection_schematic/New(var/master)
	..()
	src.master = master
	ourobj = new /obj/abstract/screen/schematics(null, src)

/datum/selection_schematic/Destroy()
	for(var/client/C in clients)
		C.screen.Remove(ourobj)
	QDEL_NULL(ourobj)
	..()

/datum/selection_schematic/access_schematic
	name = "Set Accesses"
	build_type = null
	icon_state = "data"
	icon = 'icons/obj/card.dmi'

/datum/selection_schematic/access_schematic/clicked(var/mob/user)
	if(!master:ready)
		master.build_ui()
		master:ready = 1
	master.master.interface.show(user)
	return

/datum/selection_schematic/airlock_schematic/clicked(var/mob/user)
	if(master:selected == src)
		master:selected_name = copytext(sanitize(input(usr,"What would you like to name this airlock?","Input a name",name) as text|null),1,MAX_NAME_LEN)
		if(master:selected_name && (capitalize(master:selected_name) == master:selected_name))
			master:selected_name = "\improper [master:selected_name]"
	else
		master.selected = src
// Schematics for schematics, I know, but it's OOP!
/datum/selection_schematic/airlock_schematic
	name			= "Airlock"						//Name of the airlock for the tooltip.
	build_type		= /obj/machinery/door/airlock	//Type of the airlock.
	icon_state		= "door_closed"
	icon			= 'icons/obj/doors/Doorint.dmi'

/datum/selection_schematic/airlock_schematic/proc/register_icon()
	//register_asset(img, new /icon(icon, "door_closed"))

/datum/selection_schematic/airlock_schematic/proc/send_icon(var/client/client)
	//send_asset(client, img)

// ALL THE AIRLOCK TYPES.
/datum/selection_schematic/airlock_schematic/engie
	name			= "Engineering Airlock"
	build_type	= /obj/machinery/door/airlock/engineering
	icon			= 'icons/obj/doors/Dooreng.dmi'

/datum/selection_schematic/airlock_schematic/atmos
	name			= "Atmospherics Airlock"
	build_type	= /obj/machinery/door/airlock/atmos
	icon			= 'icons/obj/doors/Dooratmo.dmi'

/datum/selection_schematic/airlock_schematic/sec
	name			= "Security Airlock"
	build_type	= /obj/machinery/door/airlock/security
	icon			= 'icons/obj/doors/Doorsec.dmi'

/datum/selection_schematic/airlock_schematic/command
	name			= "Command Airlock"
	build_type	= /obj/machinery/door/airlock/command
	icon			= 'icons/obj/doors/Doorcom.dmi'

/datum/selection_schematic/airlock_schematic/med
	name			= "Medical Airlock"
	build_type	= /obj/machinery/door/airlock/medical
	icon			= 'icons/obj/doors/Doormed.dmi'

/datum/selection_schematic/airlock_schematic/sci
	name			= "Research Airlock"
	build_type	= /obj/machinery/door/airlock/research
	icon			= 'icons/obj/doors/doorresearch.dmi'

/datum/selection_schematic/airlock_schematic/mining
	name			= "Mining Airlock"
	build_type	= /obj/machinery/door/airlock/mining
	icon			= 'icons/obj/doors/Doormining.dmi'

/datum/selection_schematic/airlock_schematic/maint
	name			= "Maintenance Access"
	build_type	= /obj/machinery/door/airlock/maintenance
	icon			= 'icons/obj/doors/Doormaint.dmi'

/datum/selection_schematic/airlock_schematic/ext
	name			= "External Airlock"
	build_type	= /obj/machinery/door/airlock/external
	icon			= 'icons/obj/doors/Doorext.dmi'

/datum/selection_schematic/airlock_schematic/high_sec
	name			= "High-Tech Security Airlock"
	build_type	= /obj/machinery/door/airlock/highsecurity
	icon			= 'icons/obj/doors/hightechsecurity.dmi'

/datum/selection_schematic/airlock_schematic/glass
	name			= "Glass Airlock"
	build_type	= /obj/machinery/door/airlock/glass
	icon			= 'icons/obj/doors/Doorglass.dmi'

/datum/selection_schematic/airlock_schematic/glass_eng
	name			= "Glass Engineering Airlock"
	build_type	= /obj/machinery/door/airlock/glass_engineering
	icon			= 'icons/obj/doors/Doorengglass.dmi'

/datum/selection_schematic/airlock_schematic/glass_atmos
	name			= "Glass Atmospherics Airlock"
	build_type	= /obj/machinery/door/airlock/glass_atmos
	icon			= 'icons/obj/doors/Dooratmoglass.dmi'

/datum/selection_schematic/airlock_schematic/glass_sec
	name			= "Glass Security Airlock"
	build_type	= /obj/machinery/door/airlock/glass_security
	icon			= 'icons/obj/doors/Doorsecglass.dmi'

/datum/selection_schematic/airlock_schematic/glass_command
	name			= "Glass Command Airlock"
	build_type	= /obj/machinery/door/airlock/glass_command
	icon			= 'icons/obj/doors/Doorcomglass.dmi'

/datum/selection_schematic/airlock_schematic/glass_med
	name			= "Glass Medical Airlock"
	build_type	= /obj/machinery/door/airlock/glass_medical
	icon			= 'icons/obj/doors/doormedglass.dmi'

/datum/selection_schematic/airlock_schematic/glass_sci
	name			= "Glass Research Airlock"
	build_type	= /obj/machinery/door/airlock/glass_research
	icon			= 'icons/obj/doors/doorresearchglass.dmi'

/datum/selection_schematic/airlock_schematic/glass_mining
	name			= "Glass Mining Airlock"
	build_type	= /obj/machinery/door/airlock/glass_mining
	icon			= 'icons/obj/doors/Doorminingglass.dmi'

// ALL THE WINDOW TYPES.
/datum/selection_schematic/window_schematic
	name			= "window"						//Name of the window for the tooltip.
	build_type		= /obj/effect/spawner/window	//Type of the window.
	icon = 'icons/obj/structures.dmi'
	icon_state = "grille0"
	var/list/dirs = list(NORTH,EAST,WEST,SOUTH)

/datum/selection_schematic/window_schematic/New()
	for(var/d in dirs)
		overlays += image('icons/obj/structures/window.dmi',icon_state="rwindow0",dir=d)
	..()

/datum/selection_schematic/window_schematic/Destroy()
	overlays = list()
	..()

/datum/selection_schematic/window_schematic/clicked(var/mob/user)
	master.selected = src

/datum/selection_schematic/window_schematic/northend
	name			= "\improper north window"
	build_type	= /obj/effect/spawner/window/northend
	dirs = list(NORTH)

/datum/selection_schematic/window_schematic/eastend
	name			= "\improper east window"
	build_type	= /obj/effect/spawner/window/eastend
	dirs = list(EAST)

/datum/selection_schematic/window_schematic/southend
	name			= "\improper south window"
	build_type	= /obj/effect/spawner/window/southend
	dirs = list(SOUTH)

/datum/selection_schematic/window_schematic/westend
	name			= "\improper west window"
	build_type	= /obj/effect/spawner/window/westend
	dirs = list(WEST)

/datum/selection_schematic/window_schematic/horizontal
	name			= "\improper horizontal window"
	build_type	= /obj/effect/spawner/window/horizontal
	dirs = list(NORTH,SOUTH)

/datum/selection_schematic/window_schematic/vertical
	name			= "\improper vertical window"
	build_type	= /obj/effect/spawner/window/vertical
	dirs = list(EAST,WEST)

/datum/selection_schematic/window_schematic/necorner
	name			= "\improper northeast window"
	build_type	= /obj/effect/spawner/window/necorner
	dirs = list(NORTH,EAST)

/datum/selection_schematic/window_schematic/secorner
	name			= "\improper southeast window"
	build_type	= /obj/effect/spawner/window/secorner
	dirs = list(EAST,SOUTH)

/datum/selection_schematic/window_schematic/swcorner
	name			= "\improper southwest window"
	build_type	= /obj/effect/spawner/window/swcorner
	dirs = list(WEST,SOUTH)

/datum/selection_schematic/window_schematic/nwcorner
	name			= "\improper northwest window"
	build_type	= /obj/effect/spawner/window/nwcorner
	dirs = list(NORTH,WEST)

/datum/selection_schematic/window_schematic/northcap
	name			= "\improper north window cap"
	build_type	= /obj/effect/spawner/window/northcap
	dirs = list(NORTH,EAST,WEST)

/datum/selection_schematic/window_schematic/eastcap
	name			= "\improper east window cap"
	build_type	= /obj/effect/spawner/window/eastcap
	dirs = list(NORTH,EAST,SOUTH)

/datum/selection_schematic/window_schematic/southcap
	name			= "\improper south window cap"
	build_type	= /obj/effect/spawner/window/southcap
	dirs = list(EAST,WEST,SOUTH)

/datum/selection_schematic/window_schematic/westcap
	name			= "\improper west window cap"
	build_type	= /obj/effect/spawner/window/westcap
	dirs = list(NORTH,WEST,SOUTH)

/datum/selection_schematic/window_schematic/full
	name			= "\improper full window"
	build_type	= /obj/effect/spawner/window/full

/datum/selection_schematic/window_schematic/full/New()
	overlays += image('icons/obj/structures/window.dmi',icon_state="frwindow0")
	..()

/datum/selection_schematic/window_schematic/full/northend
	name			= "\improper full north window"
	build_type	= /obj/effect/spawner/window/full/northend
	dirs = list(NORTH)

/datum/selection_schematic/window_schematic/full/eastend
	name			= "\improper full east window"
	build_type	= /obj/effect/spawner/window/full/eastend
	dirs = list(EAST)

/datum/selection_schematic/window_schematic/full/southend
	name			= "\improper full south window"
	build_type	= /obj/effect/spawner/window/full/southend
	dirs = list(SOUTH)

/datum/selection_schematic/window_schematic/full/westend
	name			= "\improper full west window"
	build_type	= /obj/effect/spawner/window/full/westend
	dirs = list(WEST)

/datum/selection_schematic/window_schematic/full/horizontal
	name			= "\improper full horizontal window"
	build_type	= /obj/effect/spawner/window/full/horizontal
	dirs = list(NORTH,SOUTH)

/datum/selection_schematic/window_schematic/full/vertical
	name			= "\improper full vertical window"
	build_type	= /obj/effect/spawner/window/full/vertical
	dirs = list(EAST,WEST)

/datum/selection_schematic/window_schematic/full/necorner
	name			= "\improper full northeast window"
	build_type	= /obj/effect/spawner/window/full/necorner
	dirs = list(NORTH,EAST)

/datum/selection_schematic/window_schematic/full/secorner
	name			= "\improper full southeast window"
	build_type	= /obj/effect/spawner/window/full/secorner
	dirs = list(EAST,SOUTH)

/datum/selection_schematic/window_schematic/full/swcorner
	name			= "\improper full southwest window"
	build_type	= /obj/effect/spawner/window/full/swcorner
	dirs = list(WEST,SOUTH)

/datum/selection_schematic/window_schematic/full/nwcorner
	name			= "\improper full northwest window"
	build_type	= /obj/effect/spawner/window/full/nwcorner
	dirs = list(NORTH,WEST)

/datum/selection_schematic/window_schematic/full/northcap
	name			= "\improper full north window cap"
	build_type	= /obj/effect/spawner/window/full/northcap
	dirs = list(NORTH,EAST,WEST)

/datum/selection_schematic/window_schematic/full/eastcap
	name			= "\improper full east window cap"
	build_type	= /obj/effect/spawner/window/full/eastcap
	dirs = list(NORTH,EAST,SOUTH)

/datum/selection_schematic/window_schematic/full/southcap
	name			= "\improper full south window cap"
	build_type	= /obj/effect/spawner/window/full/southcap
	dirs = list(EAST,WEST,SOUTH)

/datum/selection_schematic/window_schematic/full/westcap
	name			= "\improper full west window cap"
	build_type	= /obj/effect/spawner/window/full/westcap
	dirs = list(NORTH,WEST,SOUTH)
