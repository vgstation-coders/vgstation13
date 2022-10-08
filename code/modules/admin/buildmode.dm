#define MASS_FILL			0
#define MASS_DELETE			1
#define SELECTIVE_DELETE	2
#define SELECTIVE_FILL		3
#define MASS_RESET			4

/proc/togglebuildmode(mob/M as mob in player_list)
	set name = "Toggle Build Mode"
	set category = "Special Verbs"

	if(M.client)
		if(M.client.buildmode)
			log_admin("[key_name(usr)] has left build mode.")
			M.client.buildmode = 0
			M.client.show_popup_menus = 1
			var/obj/effect/bmode/buildholder/holder = null
			for(var/obj/effect/bmode/buildholder/H in buildmodeholders)
				if(H.cl == M.client)
					holder = H
					break
			if(holder)
				qdel(holder)
		else
			log_admin("[key_name(usr)] has entered build mode.")
			M.client.buildmode = 1
			M.client.show_popup_menus = 0

			var/obj/effect/bmode/buildholder/hold = new /obj/effect/bmode/buildholder
			hold.builddir = new /obj/effect/bmode/builddir(hold)
			hold.buildhelp = new /obj/effect/bmode/buildhelp(hold)
			hold.buildmode = new /obj/effect/bmode/buildmode(hold)
			hold.buildquit = new /obj/effect/bmode/buildquit(hold)
			M.client.screen += list(hold.builddir,hold.buildhelp,hold.buildmode,hold.buildquit)
			hold.cl = M.client

/obj/effect/bmode//Cleaning up the tree a bit
	density = 1
	anchored = 1
	mouse_opacity = 1 //So we can actually click these
	layer = HUD_ITEM_LAYER
	plane = HUD_PLANE
	dir = NORTH
	icon = 'icons/misc/buildmode.dmi'
	var/obj/effect/bmode/buildholder/master = null

/obj/effect/bmode/New()
	..()
	master = loc

/obj/effect/bmode/Destroy()
	if(master && master.cl)
		master.cl.screen -= src
		master = null
	..()

/obj/effect/bmode/builddir
	icon_state = "build"
	screen_loc = "NORTH,WEST"
/obj/effect/bmode/builddir/Click()
	switch(dir)
		if(NORTH)
			dir = EAST
		if(EAST)
			dir = SOUTH
		if(SOUTH)
			dir = WEST
		if(WEST)
			dir = SOUTHWEST
		if(SOUTHWEST)
			dir = NORTH
	return 1

/obj/effect/bmode/buildhelp
	icon = 'icons/misc/buildmode.dmi'
	icon_state = "buildhelp"
	screen_loc = "NORTH,WEST+1"

/obj/effect/bmode/buildhelp/Click(location, control, params)
	var/list/pa = params2list(params)

	if(pa.Find("right"))
		master.warnings = !master.warnings
		to_chat(usr, "<span class='blob'>Toggled warnings [master.warnings ? "ON" : "OFF"].</span>")
		return

	switch(master.cl.buildmode)
		if(1)
			to_chat(usr, "<span class='notice'>Right click on help: toggle warnings on v off.</span>")
			to_chat(usr, "<span class='notice'>***********************************************************</span>")
			to_chat(usr, "<span class='notice'>Click and drag to do a fill operation</span>")
			to_chat(usr, "<span class='notice'>Left Mouse Button        = Construct / Upgrade</span>")
			to_chat(usr, "<span class='notice'>Right Mouse Button       = Deconstruct / Delete / Downgrade</span>")
			to_chat(usr, "<span class='notice'>Left Mouse Button + ctrl = R-Window</span>")
			to_chat(usr, "<span class='notice'>Left Mouse Button + alt  = Airlock</span>")
			to_chat(usr, "")
			to_chat(usr, "<span class='notice'>Use the button in the upper left corner to</span>")
			to_chat(usr, "<span class='notice'>change the direction of built objects.</span>")
			to_chat(usr, "<span class='notice'>***********************************************************</span>")
		if(2)
			to_chat(usr, "<span class='notice'>***********************************************************</span>")
			to_chat(usr, "<span class='notice'>Click and drag to do a fill operation</span>")
			to_chat(usr, "<span class='notice'>Right Mouse Button on buildmode button = Set object type</span>")
			//this line is green because it is very important
			to_chat(usr, "<span class='good'>On buildmode button: Rightclick = select type, Shiftclick = toggle map reset on/off, Ctrlclick = toggle mass v selective, Altclick = toggle fill v delete, Middleclick = toggle exact-type vs children-ok")
			to_chat(usr, "<span class='notice'>Left Mouse Button on turf/obj          = Place objects</span>")
			to_chat(usr, "<span class='notice'>Right Mouse Button                     = Delete objects</span>")
			to_chat(usr, "<span class='notice'>Middle Mouse Button                    = Copy atom</span>")
			to_chat(usr, "<span class='notice'>Middle Mouse Button twice on a turf    = Area editing mode</span>")
			to_chat(usr, "")
			to_chat(usr, "<span class='notice'>Ctrl+Shift+Left Mouse Button           = Sets bottom left corner for fill mode</span>")
			to_chat(usr, "<span class='notice'>Ctrl+Shift+Right Mouse Button           = Sets top right corner for fill mode</span>")

			to_chat(usr, "")
			to_chat(usr, "<span class='notice'>Use the button in the upper left corner to</span>")
			to_chat(usr, "<span class='notice'>change the direction of built objects.</span>")
			to_chat(usr, "<span class='notice'>***********************************************************</span>")
		if(3)
			to_chat(usr, "<span class='notice'>***********************************************************</span>")
			to_chat(usr, "<span class='notice'>Click and drag to do a mass edit operation</span>")
			to_chat(usr, "<span class='notice'>Right Mouse Button on buildmode button = Select var(type) & value</span>")
			to_chat(usr, "<span class='notice'>Left Mouse Button on turf/obj/mob      = Set var(type) & value</span>")
			to_chat(usr, "<span class='notice'>Right Mouse Button on turf/obj/mob     = Reset var's value</span>")
			to_chat(usr, "<span class='notice'>Middle Mouse Button on turf/obj/mob    = Copy value from object</span>")
			to_chat(usr, "<span class='notice'>***********************************************************</span>")
		if(4)
			to_chat(usr, "<span class='notice'>***********************************************************</span>")
			to_chat(usr, "<span class='notice'>Left Mouse Button on turf/obj/mob      = Select</span>")
			to_chat(usr, "<span class='notice'>Right Mouse Button on turf/obj/mob     = Throw</span>")
			to_chat(usr, "<span class='notice'>***********************************************************</span>")
	return 1

/obj/effect/bmode/buildhelp/DblClick(object,location,control,params)
	return Click(object,location,control,params)

/obj/effect/bmode/buildquit
	icon_state = "buildquit"
	screen_loc = "NORTH,WEST+3"

/obj/effect/bmode/buildquit/Click()
	togglebuildmode(master.cl.mob)
	return 1

/obj/effect/bmode/buildquit/DblClick(object,location,control,params)
	return Click(object,location,control,params)

var/global/list/obj/effect/bmode/buildholder/buildmodeholders = list()
/obj/effect/bmode/buildholder
	density = 0
	anchored = 1
	var/client/cl = null
	var/obj/effect/bmode/builddir/builddir = null
	var/obj/effect/bmode/buildhelp/buildhelp = null
	var/obj/effect/bmode/buildmode/buildmode = null
	var/obj/effect/bmode/buildquit/buildquit = null
	var/atom/movable/throw_atom = null
	var/turf/fill_left
	var/turf/fill_right
	var/deletemode = FALSE
	var/resetmode = FALSE
	var/selective = FALSE
	var/resetvars = FALSE
	var/strictness = FALSE
	var/warnings = TRUE

/obj/effect/bmode/buildholder/New()
	..()
	buildmodeholders |= src

/obj/effect/bmode/buildholder/Destroy()
	..()
	cl.screen -= list(builddir,buildhelp,buildmode,buildquit)
	cl.images -= buildmode.area_overlay
	buildmodeholders -= src

/obj/effect/bmode/buildmode
	icon_state = "buildmode1"
	screen_loc = "NORTH,WEST+2"
	var/varholder = "name"
	var/valueholder = "derp"
	var/objholder = /obj/structure/closet
	var/atom/copycat
	var/image/area_overlay

/obj/effect/bmode/buildmode/New()
	..()
	area_overlay = image('icons/turf/areas.dmi', "yellow")

/obj/effect/bmode/buildmode/Destroy()
	copycat = null
	..()

/obj/effect/bmode/buildmode/Click(location, control, params)
	var/list/pa = params2list(params)

	if(pa.Find("middle"))
		master.strictness = !master.strictness
		to_chat(usr, "<span class='blob'>Toggled strictness [master.strictness ? "ON" : "OFF"].</span>")
		return 1

	if(pa.Find("shift"))
		if(master.cl.buildmode < 3) //1 or 2
			master.resetmode = !master.resetmode
			to_chat(usr, "<span class='blob'>Toggled map reset mode [master.resetmode ? "ON" : "OFF"].</span>")
		return 1

	if(pa.Find("ctrl"))
		if(master.cl.buildmode < 4) //1 (basic), 2 (adv), or 3 (edit)
			master.selective = !master.selective
			to_chat(usr, "<span class='blob'>Toggled selective mode [master.selective ? "ON" : "OFF"].</span>")
		return 1

	if(pa.Find("alt"))
		if(master.cl.buildmode < 3) //1 or 2
			master.deletemode = !master.deletemode
			to_chat(usr, "<span class='blob'>Toggled mass delete mode [master.deletemode ? "ON" : "OFF"].</span>")
		else if(master.cl.buildmode == 3) //edit
			master.resetvars = !master.resetvars
			to_chat(usr, "<span class='blob'>Toggled resetvars mode [master.resetvars ? "ON" : "OFF"].</span>")
		return 1

	if(pa.Find("left"))
		switch(master.cl.buildmode)
			if(1)
				master.cl.buildmode = 2
				src.icon_state = "buildmode2"
			if(2)
				master.cl.buildmode = 3
				src.icon_state = "buildmode3"
			if(3)
				master.cl.buildmode = 4
				src.icon_state = "buildmode4"
			if(4)
				master.cl.buildmode = 1
				src.icon_state = "buildmode1"

	else if(pa.Find("right"))
		switch(master.cl.buildmode)
			if(1)
				return 1
			if(2)
				copycat = null
				var/partial_type = input(usr, "Enter type, or leave blank to see all types", "Typepath", "/obj/structure/closet") as text|null
				if(isnull(partial_type))
					return

				var/list/matches = get_matching_types(partial_type, /atom)
				objholder = input("Select type", "Typepath") as null|anything in matches

				if(!ispath(objholder))
					objholder = /obj/structure/closet
					alert("That path is not allowed.")
				else
					if(ispath(objholder,/mob) && !check_rights(R_DEBUG,0))
						objholder = /obj/structure/closet
			if(3)
				var/list/locked = list("vars", "key", "ckey", "client", "firemut", "ishulk", "telekinesis", "xray", "virus", "viruses", "cuffed", "ka", "last_eaten", "urine")

				var/edit_variable = input(usr,"Enter variable name:" ,"Name", "name")
				if(edit_variable in locked && !check_rights(R_DEBUG,0))
					return 1

				master.buildmode.varholder = edit_variable
				if(edit_variable != "appearance") //Special case for appearance
					master.buildmode.valueholder = variable_set(usr)
	return 1

/client/MouseWheel(object,delta_x,delta_y,location,control,params)
	if(istype(mob,/mob/dead/observer) || buildmode) //DEAD FAGS CAN ZOOM OUT THIS WILL END POORLY
		if(delta_y > 0)
			changeView(view - 1)
		else
			changeView(view + 1)
		changeView(max(view,1))
		haszoomed = 1
	..()

/client/MouseDrop(src_object,over_object,src_location,over_location,src_control,over_control,params)
	if(!src.buildmode)
		return ..()
	var/obj/effect/bmode/buildholder/holder = null
	for(var/obj/effect/bmode/buildholder/H in buildmodeholders)
		if(H.cl == src)
			holder = H
			break
	if(!holder)
		return
	var/turf/start = get_turf(src_location)
	var/turf/end = get_turf(over_location)
	if(!start || !end)
		return
	switch(buildmode)
		if(1 to 2)
			var/list/fillturfs = block(start,end)
			if(fillturfs.len < 3) //most likely unintended
				return
			if(holder.warnings && alert("You're about to do a fill operation spanning [fillturfs.len] tiles, are you sure?","Panic","Yes","No") == "No")
				return
			var/areaAction
			if(holder.deletemode)
				areaAction = holder.selective ? SELECTIVE_DELETE : MASS_DELETE //2 : 1
			else if(holder.resetmode)
				areaAction = MASS_RESET //4
			else
				areaAction = holder.selective ? SELECTIVE_FILL : MASS_FILL //3 : 0

			var/whatfill = (buildmode == 1 ? input("What are we filling with?", "So many choices") as null|anything in list(/turf/simulated/floor,/turf/simulated/wall,/turf/simulated/wall/r_wall,/obj/machinery/door/airlock, /obj/structure/window/reinforced) : holder.buildmode.objholder)
			if(!whatfill)
				return
			var/msglog = "<span class='danger'>[key_name_admin(usr)] just buildmode"
			var/strict = holder.strictness
			var/chosen
			switch(areaAction)
				if(MASS_DELETE)
					msglog += " <big>DELETED EVERYTHING</big> in [fillturfs.len] tile\s "
				if(SELECTIVE_DELETE)
					chosen = easyTypeSelector()
					if(!chosen)
						return
					msglog += " <big>DELETED [!strict ? "ALL TYPES OF " :""][chosen]</big> in [fillturfs.len] tile\s "
				if(SELECTIVE_FILL)
					chosen = easyTypeSelector()
					if(!chosen)
						return
					msglog += " Changed all [chosen] in [fillturfs.len] tile\s to [whatfill] "
				if(MASS_RESET)
					msglog += " <big>RESETTED</big> [fillturfs.len] tile\s "
				else
					msglog += " FILLED [fillturfs.len] tile\s with [whatfill] "
			msglog += "at ([formatJumpTo(start)] to [formatJumpTo(end)])</span>"
			message_admins(msglog)
			log_admin(msglog)
			to_chat(usr, "<span class='notice'>If the server is lagging the operation will periodically sleep so the fill may take longer than typical.</span>")
			var/deletions = 0
			if(areaAction == MASS_RESET)
				var/lowest_x = min(start.x,end.x)
				var/lowest_y = min(start.y,end.y)
				var/lowest_z = min(start.z,end.z)
				var/highest_x = max(start.x,end.x)
				var/highest_y = max(start.y,end.y)
				var/highest_z = max(start.z,end.z)
				var/datum/map_element/ME = new
				ME.file_path = "maps/[map.map_dir].dmm"
				if(!fexists(file(ME.file_path)))
					if(map.file_dir != "")
						ME.file_path = "maps/[map.file_dir].dmm"
					if(!fexists(file(ME.file_path)))
						CRASH("Map file path for current map ([ME.file_path]) not found somehow! Cannot reset map segment.")
				ME.load(0, 0, 1, 0, 1, 0, lowest_x, highest_x, lowest_y, highest_y, lowest_z, highest_z)
			else
				for(var/turf/T in fillturfs)
					if(areaAction == MASS_DELETE || areaAction == SELECTIVE_DELETE)
						if(ispath(chosen, /turf))
							T.ChangeTurf(chosen)
							deletions++
						else
							for(var/atom/thing in T.contents)
								if(thing==usr)
									continue
								if(areaAction == MASS_DELETE || v_typechk(thing,chosen,strict))
									qdel(thing)
									deletions++
								CHECK_TICK
							if(areaAction == MASS_DELETE)
								T.ChangeTurf(get_base_turf(T.z))
					else
						if(ispath(whatfill, /area) || istype(holder.buildmode.copycat, /area))
							//In case of a selective fill, make sure the turf fits into the criteria before changing it
							if(areaAction == SELECTIVE_FILL && !v_typechk(T,chosen,strict))
								continue

							var/area/A
							if(istype(holder.buildmode.copycat, /area))
								A = holder.buildmode.copycat
							else
								A = locate(whatfill)

							T.set_area(A)
						else if(ispath(whatfill, /turf))
							if(areaAction == SELECTIVE_FILL && !v_typechk(T,chosen,strict))
								continue

							T.ChangeTurf(whatfill)
						else
							if(areaAction == SELECTIVE_FILL)
								for(var/atom/thing in T.contents)
									if(!v_typechk(thing,chosen,strict))
										continue
									var/atom/A = new whatfill(T)
									A.change_dir(thing.dir)
									qdel(thing)
									CHECK_TICK
							else
								var/obj/A = new whatfill(T)
								if(istype(A))
									A.change_dir(holder.builddir.dir)
					CHECK_TICK
			if(deletions)
				to_chat(usr, "<span class='info'>Successfully deleted [deletions] [chosen]'\s</span>")
		if(3)
			var/list/fillturfs = block(start,end)
			if(fillturfs.len < 3)
				return
			if(holder.warnings && alert("You're about to do a mass edit operation spanning [fillturfs.len] tiles, are you sure?","Panic","Yes","No") == "No")
				return
			var/reset = holder.resetvars


			var/msglog = "<span class='danger'>[key_name_admin(usr)] just buildmode"
			var/strict = holder.strictness
			var/chosen
			switch(holder.selective)
				if(FALSE)
					msglog += " <big>EDITED EVERYTHING</big> in [fillturfs.len] tile\s "
				if(TRUE)
					chosen = easyTypeSelector()
					if(!chosen)
						return
					msglog += " <big>EDITED [!strict ? "ALL TYPES OF " :""][chosen]</big> in [fillturfs.len] tile\s "
				else
					return
			msglog += "at ([formatJumpTo(start)] to [formatJumpTo(end)])</span>"
			message_admins(msglog)
			log_admin(msglog)
			to_chat(usr, "<span class='notice'>If the server is lagging the operation will periodically sleep so the mass edit may take longer than typical.</span>")
			var/edits = 0
			for(var/turf/T in fillturfs)
				if(ispath(chosen, /turf))
					setvar(holder.buildmode.varholder, holder.buildmode.valueholder, T, reset)
				else
					for(var/atom/thing in T.contents)
						if(thing==usr)
							continue
						if(thing.invisibility > usr.see_invisible)
							continue
						if(!istype(thing, /mob) && !istype(thing, /obj)) //Checks if thing is either an object or a mob. Ignore other /atom/movable subtypes (such as lighting overlays)
							continue

						if(!holder.selective || v_typechk(thing,chosen,strict))
							setvar(holder.buildmode.varholder, holder.buildmode.valueholder, thing, reset, log = FALSE)
							edits++
						CHECK_TICK
				edits++
				CHECK_TICK
			if(edits)
				to_chat(usr, "<span class='info'>Successfully edited [edits] [chosen]'\s</span>")
		else
			return

/proc/build_click(var/mob/user, buildmode, params, var/obj/object)
	var/obj/effect/bmode/buildholder/holder = null
	for(var/obj/effect/bmode/buildholder/H in buildmodeholders)
		if(H.cl == user.client)
			holder = H
			break
	if(!holder)
		return
	var/list/pa = params2list(params)
	var/turf/RT = get_turf(object)
	switch(buildmode)
		if(1)
			if(istype(object,/turf) && pa.Find("left") && !pa.Find("alt") && !pa.Find("ctrl") )
				var/turf/T = object
				if(istype(T,get_base_turf(T.z)))
					T.ChangeTurf(/turf/simulated/floor)
					log_admin("[key_name(usr)] made a floor at [formatJumpTo(T)]")
					return
				else if(istype(T,/turf/simulated/floor))
					T.ChangeTurf(/turf/simulated/wall)
					log_admin("[key_name(usr)] made a wall at [formatJumpTo(T)]")
					return
				else if(istype(T,/turf/simulated/wall))
					T.ChangeTurf(/turf/simulated/wall/r_wall)
					log_admin("[key_name(usr)] made an rwall at [formatJumpTo(T)]")
					return
			else if(pa.Find("right"))
				if(istype(object,/turf/simulated/wall))
					var/turf/T = object
					T.ChangeTurf(/turf/simulated/floor)
					log_admin("[key_name(usr)] removed a wall at [formatJumpTo(T)]")
					return
				else if(istype(object,/turf/simulated/floor))
					var/turf/T = object
					T.ChangeTurf(get_base_turf(T.z))
					log_admin("[key_name(usr)] removed flooring at [formatJumpTo(T)]")
					return
				else if(istype(object,/turf/simulated/wall/r_wall))
					var/turf/T = object
					T.ChangeTurf(/turf/simulated/wall)
					log_admin("[key_name(usr)] downgraded an rwall at [formatJumpTo(T)]")
					return
				else if(istype(object,/obj))
					qdel(object)
					return
			else if(istype(object,/turf) && pa.Find("alt") && pa.Find("left"))
				new/obj/machinery/door/airlock(get_turf(object))
				log_admin("[key_name(usr)] made an airlock at [formatJumpTo(RT)]")
			else if(istype(object,/turf) && pa.Find("ctrl") && pa.Find("left"))
				log_admin("[key_name(usr)] made a window at [formatJumpTo(RT)]")
				switch(holder.builddir.dir)
					if(NORTH)
						var/obj/structure/window/reinforced/WIN = new/obj/structure/window/reinforced(get_turf(object))
						WIN.change_dir(NORTH)
					if(SOUTH)
						var/obj/structure/window/reinforced/WIN = new/obj/structure/window/reinforced(get_turf(object))
						WIN.change_dir(SOUTH)
					if(EAST)
						var/obj/structure/window/reinforced/WIN = new/obj/structure/window/reinforced(get_turf(object))
						WIN.change_dir(EAST)
					if(WEST)
						var/obj/structure/window/reinforced/WIN = new/obj/structure/window/reinforced(get_turf(object))
						WIN.change_dir(WEST)
					if(SOUTHWEST)
						new/obj/structure/window/full/reinforced(get_turf(object))
		if(2)
			if(pa.Find("ctrl") && pa.Find("shift"))
				if(!holder)
					return
				if(pa.Find("left"))
					holder.fill_left = RT
					to_chat(usr, "<span class='notice'>Set bottom left fill corner to ([formatJumpTo(RT)])</span>")
				else if(pa.Find("right"))
					holder.fill_right = RT
					to_chat(usr, "<span class='notice'>Set top right fill corner to ([formatJumpTo(RT)])</span>")
				if(holder.fill_left && holder.fill_right)
					var/turf/start = holder.fill_left
					var/turf/end = holder.fill_right
					if(start.z != end.z)
						to_chat(usr, "<span class='warning'>You can't do a fill across zlevels you silly person.</span>")
						holder.fill_left = null
						holder.fill_right = null
						return
					var/list/fillturfs = block(start,end)
					if(fillturfs.len)
						if(alert("You're about to do a fill operation spanning [fillturfs.len] tiles, are you sure?","Panic","Yes","No") == "Yes")
							if(fillturfs.len > 150)
								if(alert("Are you completely sure about filling [fillturfs.len] tiles?","Panic!!!!","Yes","No") != "Yes")
									holder.fill_left = null
									holder.fill_right = null
									to_chat(usr, "<span class='notice'>Cleared filling corners.</span>")
									return
							var/areaAction = alert("FILL tiles or DELETE them? areaAction will destroy EVERYTHING IN THE SELECTED AREA", "Create or destroy, your chance to be a GOD","FILL","DELETE") == "DELETE"
							if(areaAction)
								areaAction = (alert("Selective(TYPE) Delete or MASS Delete?", "Scorched Earth or selective destruction?", "Selective", "MASS") == "Selective" ? 2 : 1)
							else
								areaAction = (alert("Type FILL or map reset FILL?", "Do they really need [fillturfs.len] of the old station?", "Reset", "Fill") == "Reset" ? 4 : 0)
								if(!areaAction)
									areaAction = (alert("Mass FILL or Selective(Type => Type) FILL?", "Do they really need [fillturfs.len] of closets?", "Selective", "Mass") == "Selective" ? 3 : 0)
							var/msglog = "<span class='danger'>[key_name_admin(usr)] just buildmode"
							var/strict = 1
							var/chosen
							switch(areaAction)
								if(MASS_DELETE)
									msglog += " <big>DELETED EVERYTHING</big> in [fillturfs.len] tile\s "
								if(SELECTIVE_DELETE)
									chosen = easyTypeSelector()
									if(!chosen)
										return
									strict = alert("Delete all children of [chosen]?", "Children being all types and subtypes of [chosen]", "Yes", "No") == "No"
									msglog += " <big>DELETED [!strict ? "ALL TYPES OF " :""][chosen]</big> in [fillturfs.len] tile\s "
								if(SELECTIVE_FILL)
									chosen = easyTypeSelector()
									if(!chosen)
										return
									strict = alert("Change all children of [chosen]?", "Children being all types and subtypes of [chosen]", "Yes", "No") == "No"
									msglog += " Changed all [chosen] in [fillturfs.len] tile\s to [holder.buildmode.objholder] "
								if(MASS_RESET)
									msglog += " <big>RESETTED</big> [fillturfs.len] tile\s "
								else
									msglog += " FILLED [fillturfs.len] tile\s with [holder.buildmode.objholder] "
							msglog += "at ([formatJumpTo(start)] to [formatJumpTo(end)])</span>"
							message_admins(msglog)
							log_admin(msglog)
							to_chat(usr, "<span class='notice'>If the server is lagging the operation will periodically sleep so the fill may take longer than typical.</span>")

							var/deletions = 0
							if(areaAction == MASS_RESET)
								var/lowest_x = min(start.x,end.x)
								var/lowest_y = min(start.y,end.y)
								var/lowest_z = min(start.z,end.z)
								var/highest_x = max(start.x,end.x)
								var/highest_y = max(start.y,end.y)
								var/highest_z = max(start.z,end.z)
								var/datum/map_element/ME = new
								ME.file_path = "maps/[map.map_dir].dmm"
								if(!fexists(file(ME.file_path)))
									if(map.file_dir != "")
										ME.file_path = "maps/[map.file_dir].dmm"
									if(!fexists(file(ME.file_path)))
										CRASH("Map file path for current map ([ME.file_path]) not found somehow! Cannot reset map segment.")
								ME.load(0, 0, 1, 0, 1, 0, lowest_x, highest_x, lowest_y, highest_y, lowest_z, highest_z)
							else
								for(var/turf/T in fillturfs)
									if(areaAction == MASS_DELETE || areaAction == SELECTIVE_DELETE)
										if(ispath(chosen, /turf))
											T.ChangeTurf(chosen)
											deletions++
										else
											for(var/atom/thing in T.contents)
												if(thing==usr)
													continue
												if(areaAction == MASS_DELETE || (strict && thing.type == chosen) || istype(thing,chosen))
													qdel(thing)
												deletions++
												CHECK_TICK
											if(areaAction == MASS_DELETE)
												T.ChangeTurf(get_base_turf(T.z))
									else
										if(ispath(holder.buildmode.objholder, /area) || istype(holder.buildmode.copycat, /area))
											//In case of a selective fill, make sure the turf fits into the criteria before changing it
											if(areaAction == SELECTIVE_FILL)
												if(strict)
													if(T.type != chosen)
														continue
												else
													if(!istype(T, chosen))
														continue

											var/area/A
											if(istype(holder.buildmode.copycat, /area))
												A = holder.buildmode.copycat
											else
												A = locate(holder.buildmode.objholder)

											T.set_area(A)
										else if(ispath(holder.buildmode.objholder, /turf))
											if(areaAction == SELECTIVE_FILL)
												if(strict)
													if(T.type != chosen)
														continue
												else
													if(!istype(T, chosen))
														continue

											T.ChangeTurf(holder.buildmode.objholder)
										else
											if(areaAction == SELECTIVE_FILL)
												for(var/atom/thing in T.contents)
													if(strict)
														if(thing.type != chosen)
															continue
													else
														if(!istype(thing, chosen))
															continue
													var/atom/A = new holder.buildmode.objholder(T)
													A.change_dir(thing.dir)
													qdel(thing)
													CHECK_TICK
											else
												var/obj/A = new holder.buildmode.objholder(T)
												if(istype(A))
													A.change_dir(holder.builddir.dir)
									CHECK_TICK
							holder.fill_left = null
							holder.fill_right = null
							if(deletions)
								to_chat(usr, "<span class='info'>Successfully deleted [deletions] [chosen]'\s</span>")
				return
			if(pa.Find("left"))
				if(holder.buildmode.copycat)
					if(isturf(holder.buildmode.copycat))
						var/turf/T = get_turf(object)
						T.ChangeTurf(holder.buildmode.copycat.type)
						spawn(1)
							T.appearance = holder.buildmode.copycat.appearance
					else if(isarea(holder.buildmode.copycat))
						var/turf/T = get_turf(object)
						T.set_area(holder.buildmode.copycat)
						return
					else
						var/atom/movable/A = new holder.buildmode.copycat.type(get_turf(object))
						if(istype(A))
							A.appearance = holder.buildmode.copycat.appearance
							A.change_dir(holder.builddir.dir)
					log_admin("[key_name(usr)] made a [holder.buildmode.copycat.type] at [formatJumpTo(RT)]")
				else
					if(ispath(holder.buildmode.objholder,/turf)) //Handle turf changing
						var/turf/T = get_turf(object)
						T.ChangeTurf(holder.buildmode.objholder)
					else if(ispath(holder.buildmode.objholder,/area)) //Handle area changing
						var/area/A = locate(holder.buildmode.objholder)
						var/turf/T = get_turf(object)
						T.set_area(A)
					else //Handle object spawning
						var/obj/A = new holder.buildmode.objholder (get_turf(object))
						if(istype(A))
							A.change_dir(holder.builddir.dir)
					log_admin("[key_name(usr)] made a [holder.buildmode.objholder] at [formatJumpTo(RT)]")
			else if(pa.Find("right"))
				log_admin("[key_name(usr)] deleted a [object] at [formatJumpTo(RT)]")
				if(isobj(object))
					qdel(object)
			else if(pa.Find("middle"))
				if(istype(object,/mob) && !check_rights(R_DEBUG,0))
					to_chat(usr, "<span class='notice'>You don't have sufficient rights to clone [object.type]</span>")
				else
					if(ismob(object))
						holder.buildmode.copycat = object
						to_chat(usr, "<span class='info'>You will now build a lookalike of [object] when clicking.</span>")
					else
						//Handle leaving area editing mode
						if(istype(holder.buildmode.copycat, /area))
							var/area/A = holder.buildmode.copycat
							if(get_area(object) == A) //Leave area editing mode by copying an object from a different area
								//Note: it would be much better to do this on any middle mouse button click
								//I tried it, and it made this too sensitive, since after a double click, a THIRD mouse click was registered,
								//so it would immediately leave area editing mode if you clicked on a turf too quickly

								//Blame the old coders
								return

							holder.buildmode.copycat = null
							user.client.images.Remove(holder.buildmode.area_overlay)
							to_chat(usr, "<span class='info'>No longer editing area.</span>")
							return

						//Handle entering area editing mode
						if(isturf(object))
							//Middle mouse buttoning a turf twice will enter area editing mode for its area. Use the build-adv function to modify the area
							if(holder.buildmode.copycat == object)
								to_chat(usr, "<span class='info'>Modifying area of [object] ([formatJumpTo(object)]). Use the build-adv function to add tiles. Middle-click anywhere outside of the area to stop.</span>")
								var/area/A = get_area(object)
								holder.buildmode.copycat = A
								holder.buildmode.area_overlay.loc = A
								user.client.images.Add(holder.buildmode.area_overlay) //Enable area visualisation
								return
							else
								holder.buildmode.copycat = object
						else
							//The copycat variable has priority over the objholder variable when deciding a left mouse button action
							//Middle-clicking turfs sets them to copycat, middle-clicking objects doesn't
							//Set copycat to null to allow copying objects
							holder.buildmode.copycat = null

						holder.buildmode.objholder = object.type
						to_chat(usr, "<span class='info'>You will now build [object.type] when clicking.</span>")

		if(3)
			if(!object.vars.Find(holder.buildmode.varholder))
				to_chat(usr, "<span class='warning'>[initial(object.name)] does not have a var called '[holder.buildmode.varholder]'</span>")
				return

			if(pa.Find("left")) //I cant believe this shit actually compiles.
				setvar(holder.buildmode.varholder, holder.buildmode.valueholder, object, 0)

			if(pa.Find("right"))
				setvar(holder.buildmode.varholder, holder.buildmode.valueholder, object, 1) //Reset the var to its initial value

			if(pa.Find("middle"))
				if(holder.buildmode.varholder == "appearance") //Special case for appearance, as it doesn't behave like other varialbes
					user.client.holder.marked_appearance = object
				else
					holder.buildmode.valueholder = object.vars[holder.buildmode.varholder]

				to_chat(usr, "Copied '[holder.buildmode.varholder]' from [object].")

		if(4)
			if(pa.Find("left"))
				if(!istype(object, /atom/movable))
					return
				log_admin("[key_name(usr)] is selecting [object] for throwing at [formatJumpTo(RT)]")
				holder.throw_atom = object
			if(pa.Find("right"))
				if(holder.throw_atom)
					holder.throw_atom.throw_at(object, 10, 1)
					log_admin("[key_name(usr)] is throwing a [holder.throw_atom] at [object] - [formatJumpTo(RT)]")

/proc/easyTypeSelector()
	var/chosen = null

	var/list/matches = new()
	var/O = input("What type? Leave as /atom to choose from a global list of types.", "Gibs me dat", "/atom") as text
	for(var/path in typesof(/atom))
		if(findtext("[path]", O))
			matches += path

	if(matches.len==0)
		to_chat(usr, "<span class='warning'>No types of [O] found.</span>")
		return

	if(matches.len==1)
		chosen = matches[1]
	else
		chosen = input("Select an atom type", "Selected Atom", matches[1]) as null|anything in matches
		if(!chosen)
			return
	return chosen

/proc/setvar(varname, varvalue, atom/A, reset = 0, log = TRUE)
	if(!reset)
		variable_set(usr, A, varname, value_override = varvalue, logging = log)
	else
		var/init_value = initial(A.vars[varname])
		if(varname == "appearance") //Appearance doesn't play by the rules
			init_value = "initial"

		variable_set(usr, A, varname, value_override = init_value, logging = log)

#undef MASS_FILL
#undef MASS_DELETE
#undef SELECTIVE_DELETE
#undef SELECTIVE_FILL
