#define NOCIRCUITBOARD 0
#define UNSECURED_CIRCUITBOARD 1
#define SECURED_CIRCUITBOARD 2
#define WIREDFRAME 3
#define GLASS_PANELED 4

/obj/structure/AIcore
	density = 1
	anchored = 0
	name = "AI core"
	icon = 'icons/mob/AI.dmi'
	icon_state = "0"
	var/state = 0
	var/datum/ai_laws/laws
	var/obj/item/weapon/circuitboard/circuit = null
	var/obj/item/device/mmi/brain = null
	sheet_type = /obj/item/stack/sheet/plasteel

/obj/structure/AIcore/New()
	. = ..()
	laws = new base_law_type

/obj/structure/AIcore/update_icon()
	switch(state)
		if(NOCIRCUITBOARD)
			icon_state = "0"
		if(UNSECURED_CIRCUITBOARD)
			icon_state = "1"
		if(SECURED_CIRCUITBOARD)
			icon_state = "2"
		if(WIREDFRAME)
			icon_state = "3[brain ? "b" : ""]"
		if(GLASS_PANELED)
			icon_state = "4"

/obj/structure/AIcore/attackby(var/obj/item/P, var/mob/user)
	if(iswrench(P))
		wrenchAnchor(user, time_to_wrench = 2 SECONDS)
	switch(state)
		if(NOCIRCUITBOARD)
			if(iswelder(P))
				var/obj/item/weapon/weldingtool/WT = P
				if(WT.do_weld(user, src, 2 SECONDS, 0))
					if(gcDestroyed || state != NOCIRCUITBOARD)
						return
					to_chat(user, "<span class='notice'>You deconstruct the frame.</span>")
					drop_stack(sheet_type, loc, 4, user)
					qdel(src)
			if(istype(P, /obj/item/weapon/circuitboard/aicore) && !circuit)
				if(user.drop_item(P, src))
					playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
					to_chat(user, "<span class='notice'>You place the circuit board inside the frame.</span>")
					circuit = P
					state = UNSECURED_CIRCUITBOARD
		if(UNSECURED_CIRCUITBOARD)
			if(P.is_screwdriver(user) && circuit)
				playsound(loc, 'sound/items/Screwdriver.ogg', 50, 1)
				to_chat(user, "<span class='notice'>You screw the circuit board into place.</span>")
				state = SECURED_CIRCUITBOARD
			if(iscrowbar(P) && circuit)
				playsound(loc, 'sound/items/Crowbar.ogg', 50, 1)
				to_chat(user, "<span class='notice'>You remove the circuit board.</span>")
				state = NOCIRCUITBOARD
				circuit.forceMove(loc)
				circuit = null
		if(SECURED_CIRCUITBOARD)
			if(P.is_screwdriver(user) && circuit)
				playsound(loc, 'sound/items/Screwdriver.ogg', 50, 1)
				to_chat(user, "<span class='notice'>You unfasten the circuit board.</span>")
				state = UNSECURED_CIRCUITBOARD
			if(iscablecoil(P))
				var/obj/item/stack/cable_coil/cable_coil = P
				if(cable_coil.amount >= 5)
					playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
					if(do_after(user, src, 2 SECONDS))
						if(!src || state != SECURED_CIRCUITBOARD || !cable_coil || !cable_coil.use(5))
							return
						to_chat(user, "<span class='notice'>You add cables to the frame.</span>")
						state = WIREDFRAME
		if(WIREDFRAME)
			if(iswirecutter(P))
				if(brain)
					to_chat(user, "Get that brain out of there first!")
				else
					playsound(loc, 'sound/items/Wirecutter.ogg', 50, 1)
					to_chat(user, "<span class='notice'>You remove the cables.</span>")
					state = SECURED_CIRCUITBOARD
					drop_stack(/obj/item/stack/cable_coil, loc, 5, user)
			var/obj/item/stack/sheet/glass/rglass/rglass = P
			if(istype(rglass))
				if(rglass.amount >= 2)
					playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
					if(do_after(user, src, 2 SECONDS))
						if(!src || state != WIREDFRAME || !rglass || !rglass.use(2))
							return
						to_chat(user, "<span class='notice'>You put in the glass panel.</span>")
						state = GLASS_PANELED

			if(istype(P, /obj/item/device/mmi))
				var/obj/item/device/mmi/prison = P
				if(!prison.brainmob)
					to_chat(user, "<span class='warning'>Sticking an empty [P] into the frame would sort of defeat the purpose.</span>")
					return
				if(prison.brainmob.stat == DEAD)
					to_chat(user, "<span class='warning'>Sticking a dead [P] into the frame would sort of defeat the purpose.</span>")
					return

				if(jobban_isbanned(prison.brainmob, "AI"))
					to_chat(user, "<span class='warning'>This [P] does not seem to fit.</span>")
					return

				if(!user.drop_item(P, src))
					user << "<span class='warning'>You can't let go of \the [P]!</span>"
					return

				if (!brain)
					if (user.drop_item(P, src))
						brain = P
						to_chat(user, "Added [P].")

			if(iscrowbar(P) && brain)
				playsound(loc, 'sound/items/Crowbar.ogg', 50, 1)
				to_chat(user, "<span class='notice'>You remove the brain.</span>")
				brain.forceMove(loc)
				brain = null

		if(GLASS_PANELED)
			if(iscrowbar(P))
				playsound(loc, 'sound/items/Crowbar.ogg', 50, 1)
				to_chat(user, "<span class='notice'>You remove the glass panel.</span>")
				state = WIREDFRAME
				drop_stack(/obj/item/stack/sheet/glass/rglass, loc, 2, user)
			else if(P.is_screwdriver(user))
				playsound(loc, 'sound/items/Screwdriver.ogg', 50, 1)
				to_chat(user, "<span class='notice'>You connect the monitor.</span>")
				var/mob/living/silicon/ai/A = new /mob/living/silicon/ai ( loc, laws, brain )
				if(A) //if there's no brain, the mob is deleted and a structure/AIcore is created
					A.rename_self("ai", 1)
				feedback_inc("cyborg_ais_created",1)
				qdel(src)
				return // To avoid running update_icon
	update_icon()

/obj/structure/AIcore/deactivated
	name = "Inactive AI"
	icon = 'icons/mob/AI.dmi'
	icon_state = "ai-empty"
	anchored = 1
	state = 20 //So it doesn't interact based on the above. Not really necessary.

/obj/structure/AIcore/deactivated/attackby(var/obj/item/device/aicard/A as obj, var/mob/user as mob)
	if(istype(A, /obj/item/device/aicard))//Is it?
		A.transfer_ai("INACTIVE","AICARD",src,user)
	return ..()

/*
This is a good place for AI-related object verbs so I'm sticking it here.
If adding stuff to this, don't forget that an AI need to cancel_camera() whenever it physically moves to a different location.
That prevents a few funky behaviors.
*/
//What operation to perform based on target, what ineraction to perform based on object used, target itself, user. The object used is src and calls this proc.
/obj/item/proc/transfer_ai(var/choice as text, var/interaction as text, var/target, var/mob/U as mob)
	if(!src:flush)
		switch(choice)
			if("AICORE")//AI mob.
				var/mob/living/silicon/ai/T = target
				switch(interaction)
					if("AICARD")
						var/obj/item/device/aicard/C = src
						if(C.contents.len)//If there is an AI on card.
							to_chat(U, "<span class='danger'>Transfer failed:</span> Existing AI found on this terminal. Remove existing AI to install a new one.")
						else
							if(T.mind.GetRole(MALF))
								to_chat(U, "<span class='danger'>ERROR:</span> Remote transfer interface disabled.")//Do ho ho ho~
								return
							new /obj/structure/AIcore/deactivated(T.loc)//Spawns a deactivated terminal at AI location.
							//T.aiRestorePowerRoutine = 0//So the AI initially has power.
							T.control_disabled = 1//Can't control things remotely if you're stuck in a card!
							T.forceMove(C)//Throw AI into the card.
							C.name = "inteliCard - [T.name]"
							if (T.stat == 2)
								C.icon_state = "aicard-404"
							else
								C.icon_state = "aicard-full"
							T.cancel_camera()
							to_chat(T, "You have been downloaded to a mobile storage device. Remote device connection severed.")
							to_chat(U, "<span class='notice'><b>Transfer successful</b>:</span> [T.name] ([rand(1000,9999)].exe) removed from host terminal and stored within local memory.")
							//fix blindness from powerloss
							if(T.aiRestorePowerRoutine)
								T.aiRestorePowerRoutine = -1
								T.clear_fullscreen("blind")

			if("INACTIVE")//Inactive AI object.
				var/obj/structure/AIcore/deactivated/T = target
				switch(interaction)
					if("AICARD")
						var/obj/item/device/aicard/C = src
						var/mob/living/silicon/ai/A = locate() in C//I love locate(). Best proc ever.
						if(A)//If AI exists on the card. Else nothing since both are empty.
							A.control_disabled = 0
							A.forceMove(T.loc)//To replace the terminal.
							A.update_icon()
							C.icon_state = "aicard"
							C.name = "inteliCard"
							C.overlays.len = 0
							A.cancel_camera()
							to_chat(A, "You have been uploaded to a stationary terminal. Remote device connection restored.")
							to_chat(U, "<span class='notice'><b>Transfer successful</b>:</span> [A.name] ([rand(1000,9999)].exe) installed and executed successfully. Local copy has been removed.")
							qdel(T)
							T = null
			if("AIFIXER")//AI Fixer terminal.
				var/obj/machinery/computer/aifixer/T = target
				switch(interaction)
					if("AICARD")
						var/obj/item/device/aicard/C = src
						if(!T.contents.len)
							if (!C.contents.len)
								to_chat(U, "No AI to copy over!")//Well duh

							else
								for(var/mob/living/silicon/ai/A in C)
									C.icon_state = "aicard"
									C.name = "inteliCard"
									C.overlays.len = 0
									A.forceMove(T)
									T.occupant = A
									A.control_disabled = 1
									if (A.stat == 2)
										T.overlays += image('icons/obj/computer.dmi', "ai-fixer-404")
									else
										T.overlays += image('icons/obj/computer.dmi', "ai-fixer-full")
									T.overlays -= image('icons/obj/computer.dmi', "ai-fixer-empty")
									A.cancel_camera()
									to_chat(A, "You have been uploaded to a stationary terminal. Sadly, there is no remote access from here.")
									to_chat(U, "<span class='notice'><b>Transfer successful</b>:</span> [A.name] ([rand(1000,9999)].exe) installed and executed successfully. Local copy has been removed.")
						else
							if(!C.contents.len && T.occupant && !T.active)
								C.name = "inteliCard - [T.occupant.name]"
								T.overlays += image('icons/obj/computer.dmi', "ai-fixer-empty")
								if (T.occupant.stat == 2)
									C.icon_state = "aicard-404"
									T.overlays -= image('icons/obj/computer.dmi', "ai-fixer-404")
								else
									C.icon_state = "aicard-full"
									T.overlays -= image('icons/obj/computer.dmi', "ai-fixer-full")
								to_chat(T.occupant, "You have been downloaded to a mobile storage device. Still no remote access.")
								to_chat(U, "<span class='notice'><b>Transfer succesful</b>:</span> [T.occupant.name] ([rand(1000,9999)].exe) removed from host terminal and stored within local memory.")
								T.occupant.forceMove(C)
								T.occupant.cancel_camera()
								T.occupant = null
							else if (C.contents.len)
								to_chat(U, "<span class='danger'>ERROR:</span> Artificial intelligence detected on terminal.")
							else if (T.active)
								to_chat(U, "<span class='danger'>ERROR:</span> Reconstruction in progress.")
							else if (!T.occupant)
								to_chat(U, "<span class='danger'>ERROR:</span> Unable to locate artificial intelligence.")
	else
		to_chat(U, "<span class='danger'>ERROR:</span> AI flush is in progress, cannot execute transfer protocol.")
	return

#undef NOCIRCUITBOARD
#undef UNSECURED_CIRCUITBOARD
#undef SECURED_CIRCUITBOARD
#undef WIREDFRAME
#undef GLASS_PANELED
