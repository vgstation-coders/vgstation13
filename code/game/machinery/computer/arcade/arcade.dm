/obj/machinery/computer/arcade
	name = "arcade machine"
	desc = "Does not support pinball."
	icon = 'icons/obj/computer.dmi'
	icon_state = "arcade"
	circuit = "/obj/item/weapon/circuitboard/arcade"
	var/datum/arcade_game/game
	machine_flags = EMAGGABLE | SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK
	emag_cost = 0 // because fun
	light_color = LIGHT_COLOR_GREEN
	var/haunted = 0

/obj/machinery/computer/arcade/haunted
	desc = "Still doesn't support pinball, but does support spookiness."
	light_color = LIGHT_COLOR_PURPLE
	haunted = 1
	icon_state = "arcadeh"

/obj/machinery/computer/arcade/New()
	..()
	game = new /datum/arcade_game/space_villain(src)
	name = game.name

/obj/machinery/computer/arcade/Destroy()
	if(game)
		qdel(game)
		game = null
	..()

/obj/machinery/computer/arcade/proc/import_game_data(var/obj/item/weapon/circuitboard/arcade/A)
	if(!A || !A.game_data || !A.game_data.len)
		return
	game.import_data(A.game_data)

/obj/machinery/computer/arcade/proc/export_game_data(var/obj/item/weapon/circuitboard/arcade/A)
	if(!A)
		return
	if(!A.game_data)
		A.game_data = list()
	A.game_data.len = 0
	A.game_data = game.export_data()

/obj/machinery/computer/arcade/attack_hand(mob/user)
	if(..())
		return
	user.set_machine(src)
	var/dat = game.get_dat()

	user << browse(dat, "window=arcade")
	onclose(user, "arcade")

/obj/machinery/computer/arcade/emag(mob/user)
	game.emag_act(user)

/obj/machinery/computer/arcade/emp_act(severity)
	if(stat & (NOPOWER|BROKEN))
		..(severity)
		return
	game.emp_act(severity)
	..(severity)

/obj/machinery/computer/arcade/togglePanelOpen(var/obj/toggleitem, mob/user)
	if(game.is_cheater(user))
		return

	var/obj/item/weapon/circuitboard/arcade/A
	if(circuit)
		A = new
		export_game_data(A)
	..(toggleitem, user, A)

/obj/machinery/computer/arcade/kick_act()
	..()
	if(stat & (NOPOWER|BROKEN))
		return

	game.kick_act()

/obj/machinery/computer/arcade/npc_tamper_act(mob/living/L)
	game.npc_tamper_act(L)