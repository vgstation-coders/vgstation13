//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery/computer/hologram_comp
	name = "Hologram Computer"
	desc = "Rumoured to control holograms."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "holo_console0"
	var/obj/machinery/hologram/projector/projector = null
	var/temp = null
	var/lumens = 0.0
	var/h_r = 245.0
	var/h_g = 245.0
	var/h_b = 245.0


/obj/machinery/computer/hologram_comp/New()
	..()
	spawn( 10 )
		projector = locate(/obj/machinery/hologram/projector, get_step(loc, NORTH))
		return
	return

/obj/machinery/computer/hologram_comp/DblClick()
	if (!in_range(src, usr))
		return 0
	show_console(usr)
	return

/obj/machinery/computer/hologram_comp/proc/render()
	var/icon/I = new /icon('icons/mob/human.dmi', "body_m_s")

	if (lumens >= 0)
		I.Blend(rgb(lumens, lumens, lumens), ICON_ADD)
	else
		I.Blend(rgb(- lumens,  -lumens,  -lumens), ICON_SUBTRACT)

	I.Blend(new /icon('icons/mob/human.dmi', "mouth_m_s"), ICON_OVERLAY)
	I.Blend(new /icon('icons/mob/human.dmi', "underwear1_m_s"), ICON_OVERLAY)

	var/icon/U = new /icon('icons/mob/human_face.dmi', "hair_a_s")
	U.Blend(rgb(h_r, h_g, h_b), ICON_ADD)

	I.Blend(U, ICON_OVERLAY)

	projector.hologram.icon = I

/obj/machinery/computer/hologram_comp/proc/show_console(var/mob/user as mob)
	var/dat
	user.set_machine(src)
	if (temp)
		dat = text("[]<BR><BR><A href='?src=\ref[];temp=1'>Clear</A>", temp, src)
	else
		dat = text("<B>Hologram Status:</B><HR>\nPower: <A href='?src=\ref[];power=1'>[]</A><HR>\n<B>Hologram Control:</B><BR>\nColor Luminosity: []/220 <A href='?src=\ref[];reset=1'>\[Reset\]</A><BR>\nLighten: <A href='?src=\ref[];light=1'>1</A> <A href='?src=\ref[];light=10'>10</A><BR>\nDarken: <A href='?src=\ref[];light=-1'>1</A> <A href='?src=\ref[];light=-10'>10</A><BR>\n<BR>\nHair Color: ([],[],[]) <A href='?src=\ref[];h_reset=1'>\[Reset\]</A><BR>\nRed (0-255): <A href='?src=\ref[];h_r=-300'>\[0\]</A> <A href='?src=\ref[];h_r=-10'>-10</A> <A href='?src=\ref[];h_r=-1'>-1</A> [] <A href='?src=\ref[];h_r=1'>1</A> <A href='?src=\ref[];h_r=10'>10</A> <A href='?src=\ref[];h_r=300'>\[255\]</A><BR>\nGreen (0-255): <A href='?src=\ref[];h_g=-300'>\[0\]</A> <A href='?src=\ref[];h_g=-10'>-10</A> <A href='?src=\ref[];h_g=-1'>-1</A> [] <A href='?src=\ref[];h_g=1'>1</A> <A href='?src=\ref[];h_g=10'>10</A> <A href='?src=\ref[];h_g=300'>\[255\]</A><BR>\nBlue (0-255): <A href='?src=\ref[];h_b=-300'>\[0\]</A> <A href='?src=\ref[];h_b=-10'>-10</A> <A href='?src=\ref[];h_b=-1'>-1</A> [] <A href='?src=\ref[];h_b=1'>1</A> <A href='?src=\ref[];h_b=10'>10</A> <A href='?src=\ref[];h_b=300'>\[255\]</A><BR>", src, (projector.hologram ? "On" : "Off"),  -lumens + 35, src, src, src, src, src, h_r, h_g, h_b, src, src, src, src, h_r, src, src, src, src, src, src, h_g, src, src, src, src, src, src, h_b, src, src, src)
	user << browse(dat, "window=hologram_console")
	onclose(user, "hologram_console")
	return

/obj/machinery/computer/hologram_comp/Topic(href, href_list)
	if(..())
		return 1
	else
		flick("holo_console1", src)
		if (href_list["power"])
			if (projector.hologram)
				projector.icon_state = "hologram0"
				//projector.hologram = null
				qdel(projector.hologram)
				projector.hologram = null
			else
				projector.hologram = new(projector.loc)
				projector.hologram.icon = 'icons/mob/human.dmi'
				projector.hologram.icon_state = "body_m_s"
				projector.icon_state = "hologram1"
				render()
		else
			if (href_list["h_r"])
				if (projector.hologram)
					h_r += text2num(href_list["h_r"])
					h_r = min(max(h_r, 0), 255)
					render()
			else
				if (href_list["h_g"])
					if (projector.hologram)
						h_g += text2num(href_list["h_g"])
						h_g = min(max(h_g, 0), 255)
						render()
				else
					if (href_list["h_b"])
						if (projector.hologram)
							h_b += text2num(href_list["h_b"])
							h_b = min(max(h_b, 0), 255)
							render()
					else
						if (href_list["light"])
							if (projector.hologram)
								lumens += text2num(href_list["light"])
								lumens = min(max(lumens, -185.0), 35)
								render()
						else
							if (href_list["reset"])
								if (projector.hologram)
									lumens = 0
									render()
							else
								if (href_list["temp"])
									temp = null
		for(var/mob/M in viewers(1, src))
			if ((M.client && M.machine == src))
				show_console(M)
	return
