/obj/structure/girder
	icon_state = "girder"
	anchored = 1
	density = 1
	layer = 2
	var/state = 0

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W, /obj/item/weapon/wrench) && state == 0)
			if(anchored && !istype(src,/obj/structure/girder/displaced))
				playsound(get_turf(src), 'sound/items/Ratchet.ogg', 100, 1)
				user << "<span class=\"notice\">Now disassembling the girder</span>"
				if(do_after(user,40))
					if(!src) return
					user << "<span class=\"notice\">You dissasembled the girder!</span>"
					new /obj/item/stack/sheet/metal(get_turf(src))
					del(src)
			else if(!anchored)
				playsound(get_turf(src), 'sound/items/Ratchet.ogg', 100, 1)
				user << "<span class=\"notice\">Now securing the girder</span>"
				if(get_turf(user, 40))
					user << "<span class=\"notice\">You secured the girder!</span>"
					new/obj/structure/girder( src.loc )
					del(src)

		else if(istype(W, /obj/item/weapon/pickaxe/plasmacutter))
			user << "<span class=\"notice\">Now slicing apart the girder</span>"
			if(do_after(user,30))
				if(!src) return
				user << "<span class=\"notice\">You slice apart the girder!</span>"
				new /obj/item/stack/sheet/metal(get_turf(src))
				del(src)

		else if(istype(W, /obj/item/weapon/pickaxe/diamonddrill))
			user << "<span class=\"notice\">You drill through the girder!</span>"
			new /obj/item/stack/sheet/metal(get_turf(src))
			del(src)

		else if(istype(W, /obj/item/weapon/screwdriver) && state == 2 && istype(src,/obj/structure/girder/reinforced))
			playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 100, 1)
			user << "<span class=\"notice\">Now unsecuring support struts</span>"
			if(do_after(user,40))
				if(!src) return
				user << "<span class=\"notice\">You unsecured the support struts!</span>"
				state = 1

		else if(istype(W, /obj/item/weapon/wirecutters) && istype(src,/obj/structure/girder/reinforced) && state == 1)
			playsound(get_turf(src), 'sound/items/Wirecutter.ogg', 100, 1)
			user << "<span class=\"notice\">Now removing support struts</span>"
			if(do_after(user,40))
				if(!src) return
				user << "<span class=\"notice\">You removed the support struts!</span>"
				new/obj/structure/girder( src.loc )
				del(src)

		else if(istype(W, /obj/item/weapon/crowbar) && state == 0 && anchored )
			playsound(get_turf(src), 'sound/items/Crowbar.ogg', 100, 1)
			user << "<span class=\"notice\">Now dislodging the girder</span>"
			if(do_after(user, 40))
				if(!src) return
				user << "<span class=\"notice\">You dislodged the girder!</span>"
				new/obj/structure/girder/displaced( src.loc )
				del(src)

		else if(istype(W, /obj/item/stack/sheet))

			var/obj/item/stack/sheet/S = W
			switch(S.type)

				if(/obj/item/stack/sheet/metal, /obj/item/stack/sheet/metal/cyborg)
					if(!anchored)
						if(S.amount < 2) return
						var/pdiff=performWallPressureCheck(src.loc)
						if(!pdiff)
							S.use(2)
							user << "<span class=\"notice\">You create a false wall! Push on it to open or close the passage.</span>"
							new /obj/structure/falsewall (src.loc)
							del(src)
						else
							user << "<span class=\"rose\">There is too much air moving through the gap!  The door wouldn't stay closed if you built it.</span>"
							message_admins("Attempted false wall made by [user.real_name] ([formatPlayerPanel(user,user.ckey)]) at [formatJumpTo(loc)] had a pressure difference of [pdiff]!")
							log_admin("Attempted false wall made by [user.real_name] (user.ckey) at [loc] had a pressure difference of [pdiff]!")
							return
					else
						if(S.amount < 2) return ..()
						user << "<span class=\"notice\">Now adding plating...</span>"
						if (do_after(user,40))
							if(!src || !S || S.amount < 2) return
							S.use(2)
							user << "<span class=\"notice\">You added the plating!</span>"
							var/turf/Tsrc = get_turf(src)
							Tsrc.ChangeTurf(/turf/simulated/wall)
							for(var/turf/simulated/wall/X in Tsrc.loc)
								if(X)	X.add_hiddenprint(usr)
							del(src)
						return

				if(/obj/item/stack/sheet/plasteel)
					if(!anchored)
						if(S.amount < 2) return
						var/pdiff=performWallPressureCheck(src.loc)
						if(!pdiff)
							S.use(2)
							user << "<span class=\"notice\">You create a false wall! Push on it to open or close the passage.</span>"
							new /obj/structure/falserwall (src.loc)
							del(src)
						else
							user << "<span class=\"rose\">There is too much air moving through the gap!  The door wouldn't stay closed if you built it.</span>"
							message_admins("Attempted false rwall made by [user.real_name] ([formatPlayerPanel(user,user.ckey)]) at [formatJumpTo(loc)] had a pressure difference of [pdiff]!")
							log_admin("Attempted false rwall made by [user.real_name] ([user.ckey]) at [loc] had a pressure difference of [pdiff]!")
							return
					else
						if (src.icon_state == "reinforced") //I cant believe someone would actually write this line of code...
							if(S.amount < 1) return ..()
							user << "<span class=\"notice\">Now finalising reinforced wall.</span>"
							if(do_after(user, 50))
								if(!src || !S || S.amount < 1) return
								S.use(1)
								user << "<span class=\"notice\">Wall fully reinforced!</span>"
								var/turf/Tsrc = get_turf(src)
								Tsrc.ChangeTurf(/turf/simulated/wall/r_wall)
								for(var/turf/simulated/wall/r_wall/X in Tsrc.loc)
									if(X)	X.add_hiddenprint(usr)
								del(src)
							return
						else
							if(S.amount < 1) return ..()
							user << "<span class=\"notice\">Now reinforcing girders</span>"
							if (do_after(user,60))
								if(!src || !S || S.amount < 1) return
								S.use(1)
								user << "<span class=\"notice\">Girders reinforced!</span>"
								new/obj/structure/girder/reinforced( src.loc )
								del(src)
							return

			if(S.sheettype)
				var/M = S.sheettype
				if(!anchored)
					if(S.amount < 2) return
					var/pdiff=performWallPressureCheck(src.loc)
					if(!pdiff)
						S.use(2)
						user << "<span class=\"notice\">You create a false wall! Push on it to open or close the passage.</span>"
						var/F = text2path("/obj/structure/falsewall/[M]")
						new F (src.loc)
						del(src)
					else
						user << "<span class=\"rose\">There is too much air moving through the gap!  The door wouldn't stay closed if you built it.</span>"
						message_admins("Attempted false [M] wall made by [user.real_name] ([formatPlayerPanel(user,user.ckey)]) at [formatJumpTo(loc)] had a pressure difference of [pdiff]!")
						log_admin("Attempted false [M] wall made by [user.real_name] ([user.ckey]) at [loc] had a pressure difference of [pdiff]!")
						return
				else
					if(S.amount < 2) return ..()
					user << "<span class=\"notice\">Now adding plating...</span>"
					if (do_after(user,40))
						if(!src || !S || S.amount < 2) return
						S.use(2)
						user << "<span class=\"notice\">You added the plating!</span>"
						var/turf/Tsrc = get_turf(src)
						Tsrc.ChangeTurf(text2path("/turf/simulated/wall/mineral/[M]"))
						for(var/turf/simulated/wall/mineral/X in Tsrc.loc)
							if(X)	X.add_hiddenprint(usr)
						del(src)
					return

			add_hiddenprint(usr)

		else if(istype(W, /obj/item/pipe))
			var/obj/item/pipe/P = W
			if (P.pipe_type in list(0, 1, 5))	//simple pipes, simple bends, and simple manifolds.
				user.drop_item()
				P.loc = src.loc
				user << "<span class=\"notice\">You fit the pipe into the [src]!</span>"
		else
			..()


	blob_act()
		if(prob(40))
			del(src)


	ex_act(severity)
		switch(severity)
			if(1.0)
				qdel(src)
				return
			if(2.0)
				if (prob(30))
					var/remains = pick(/obj/item/stack/rods,/obj/item/stack/sheet/metal)
					new remains(loc)
					qdel(src)
				return
			if(3.0)
				if (prob(5))
					var/remains = pick(/obj/item/stack/rods,/obj/item/stack/sheet/metal)
					new remains(loc)
					qdel(src)
				return
			else
		return

/obj/structure/girder/displaced
	icon_state = "displaced"
	anchored = 0

/obj/structure/girder/reinforced
	icon_state = "reinforced"
	state = 2

/obj/structure/cultgirder
	icon= 'icons/obj/cult.dmi'
	icon_state= "cultgirder"
	anchored = 1
	density = 1
	layer = 2

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W, /obj/item/weapon/wrench))
			playsound(get_turf(src), 'sound/items/Ratchet.ogg', 100, 1)
			user << "<span class=\"notice\">Now disassembling the girder</span>"
			if(do_after(user,40))
				user << "<span class=\"notice\">You dissasembled the girder!</span>"
				new /obj/effect/decal/remains/human(get_turf(src))
				del(src)

		else if(istype(W, /obj/item/weapon/pickaxe/plasmacutter))
			user << "<span class=\"notice\">Now slicing apart the girder</span>"
			if(do_after(user,30))
				user << "<span class=\"notice\">You slice apart the girder!</span>"
			new /obj/effect/decal/remains/human(get_turf(src))
			del(src)

		else if(istype(W, /obj/item/weapon/pickaxe/diamonddrill))
			user << "<span class=\"notice\">You drill through the girder!</span>"
			new /obj/effect/decal/remains/human(get_turf(src))
			del(src)

	blob_act()
		if(prob(40))
			del(src)


	ex_act(severity)
		switch(severity)
			if(1.0)
				qdel(src)
				return
			if(2.0)
				if (prob(30))
					new /obj/effect/decal/remains/human(loc)
					qdel(src)
				return
			if(3.0)
				if (prob(5))
					new /obj/effect/decal/remains/human(loc)
					qdel(src)
				return
			else
		return