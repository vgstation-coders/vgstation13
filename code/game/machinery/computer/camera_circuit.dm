
//the researchable camera circuit that can connect to any camera network

/obj/item/weapon/circuitboard/camera
	//name = "Circuit board (Camera)"
	var/secured = 1
	var/authorised = 0
	var/possibleNets[0]
	var/network = ""

//when adding a new camera network, you should only need to update these two procs
	New()
		possibleNets[CAMERANET_ENGI] = access_ce
		possibleNets[CAMERANET_SS13] = access_hos
		possibleNets[CAMERANET_MINE] = access_mining
		possibleNets[CAMERANET_CARGO] = access_qm
		possibleNets[CAMERANET_SCIENCE] = access_rd
		possibleNets[CAMERANET_MEDBAY] = access_cmo

	proc/updateBuildPath()
		build_path = null
		if(authorised && secured)
			switch(network)
				if(CAMERANET_SS13)
					build_path = /obj/machinery/computer/security
				if(CAMERANET_ENGI)
					build_path = /obj/machinery/computer/security/engineering
				if(CAMERANET_MINE)
					build_path = /obj/machinery/computer/security/mining
				if(CAMERANET_SCIENCE)
					build_path = /obj/machinery/computer/security/research
				if(CAMERANET_MEDBAY)
					build_path = /obj/machinery/computer/security/medbay
				if(CAMERANET_CARGO)
					build_path = /obj/machinery/computer/security/cargo

	attackby(var/obj/item/I, var/mob/user)//if(health > 50)
		..()
		if(istype(I,/obj/item/weapon/card/emag))
			if(network)
				var/obj/item/weapon/card/emag/E = I
				if(E.uses)
					E.uses--
				else
					return
				authorised = 1
				to_chat(user, "<span class='notice'>You authorised the circuit network!</span>")
				updateDialog()
			else
				to_chat(user, "<span class='notice'>You must select a camera network circuit!</span>")
		else if(istype(I,/obj/item/weapon/screwdriver))
			secured = !secured
			user.visible_message("<span class='notice'>The [src] can [secured ? "no longer" : "now"] be modified.</span>")
			updateBuildPath()
		return

	attack_self(var/mob/user)
		if(!secured && ishuman(user))
			user.machine = src
			interact(user, 0)

	proc/interact(var/mob/user, var/ai=0)
		if(secured)
			return
		if (!ishuman(user))
			return ..(user)
		var/t = "<B>Circuitboard Console - Camera Monitoring Computer</B><BR>"
		t += "<A href='?src=\ref[src];close=1'>Close</A><BR>"
		t += "<hr> Please select a camera network:<br>"

		for(var/curNet in possibleNets)
			if(network == curNet)
				t += "- [curNet]<br>"
			else
				t += "- <A href='?src=\ref[src];net=[curNet]'>[curNet]</A><BR>"
		t += "<hr>"
		if(network)
			if(authorised)
				t += "Authenticated <A href='?src=\ref[src];removeauth=1'>(Clear Auth)</A><BR>"
			else
				t += "<A href='?src=\ref[src];auth=1'><b>*Authenticate*</b></A> (Requires an appropriate access ID)<br>"
		else
			t += "<A href='?src=\ref[src];auth=1'>*Authenticate*</A> (Requires an appropriate access ID)<BR>"
		t += "<A href='?src=\ref[src];close=1'>Close</A><BR>"
		user << browse(t, "window=camcircuit;size=500x400")
		onclose(user, "camcircuit")

	Topic(href, href_list)
		if(..())
			return 1
		if( href_list["close"] )
			usr << browse(null, "window=camcircuit")
			usr.machine = null
			return
		else if(href_list["net"])
			network = href_list["net"]
			authorised = 0
		else if( href_list["auth"] )
			var/mob/M = usr
			var/obj/item/weapon/card/id/I = M.equipped()
			if (istype(I, /obj/item/device/pda))
				var/obj/item/device/pda/pda = I
				I = pda.id
			if (I && istype(I))
				if(access_captain in I.access)
					authorised = 1
				else if (possibleNets[network] in I.access)
					authorised = 1
			if(istype(I,/obj/item/weapon/card/emag))
				if(network)
					var/obj/item/weapon/card/emag/E = I
					if(E.uses)
						E.uses--
					else
						return
					authorised = 1
					to_chat(usr, "<span class='notice'>You authorised the circuit network!</span>")
					updateDialog()
				else
					to_chat(usr, "<span class='notice'>You must select a camera network circuit!</span>")
		else if( href_list["removeauth"] )
			authorised = 0
		updateDialog()

	updateDialog()
		if(istype(src.loc,/mob))
			attack_self(src.loc)
