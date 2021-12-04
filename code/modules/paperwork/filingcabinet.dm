/* Filing cabinets!
 * Contains:
 *		Filing Cabinets
 *		Security Record Cabinets
 *		Medical Record Cabinets
 */


/*
 * Filing Cabinets
 */
/obj/structure/filingcabinet
	name = "filing cabinet"
	desc = "A large cabinet with drawers."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "filingcabinet"
	density = 1
	anchored = 1
	starting_materials = list(MAT_IRON = 2*CC_PER_SHEET_METAL)
	w_type = RECYK_METAL

/obj/structure/filingcabinet/chestdrawer
	name = "chest drawer"
	icon_state = "chestdrawer"


/obj/structure/filingcabinet/filingcabinet	//not changing the path to avoid unecessary map issues, but please don't name stuff like this in the future -Pete
	icon_state = "tallcabinet"


/obj/structure/filingcabinet/initialize()
	for(var/obj/item/I in loc)
		if(istype(I, /obj/item/weapon/paper) || istype(I, /obj/item/weapon/folder) || istype(I, /obj/item/weapon/photo))
			I.forceMove(src)


/obj/structure/filingcabinet/attackby(obj/item/P as obj, mob/user as mob)
	if(istype(P, /obj/item/weapon/paper) || istype(P, /obj/item/weapon/folder) || istype(P, /obj/item/weapon/photo))
		if(user.drop_item(P, src))
			to_chat(user, "<span class='notice'>You put [P] in [src].</span>")
			flick("[initial(icon_state)]-open",src)
			updateUsrDialog()
	else if(istype(P, /obj/item/weapon/storage/bag/clipboard))
		var/obj/item/weapon/storage/bag/clipboard/C = P
		for(var/obj/item/I in C)
			if(!istype(I, /obj/item/weapon/pen))
				C.remove_from_storage(I,src)
		C.update_icon()
		flick("[initial(icon_state)]-open",src)
		to_chat(user, "<span class='notice'>You empty the [C] into \the [src].</span>")
		updateUsrDialog()
	else if(P.is_wrench(user))
		P.playtoolsound(loc, 50)
		anchored = !anchored
		to_chat(user, "<span class='notice'>You [anchored ? "wrench" : "unwrench"] \the [src].</span>")
	else if(iswelder(P))
		var/obj/item/tool/weldingtool/WT = P
		if(!WT.remove_fuel(1,user))
			return
		new /obj/item/stack/sheet/metal(loc, 2)
		for(var/mob/M in viewers(src))
			M.show_message("<span class='notice'>\The [src] has been cut apart by [user] with \the [WT].</span>", 1, "You hear welding.", 2)
		qdel(src)
		return
	else
		to_chat(user, "<span class='notice'>You can't put [P] in [src]!</span>")


/obj/structure/filingcabinet/attack_hand(mob/user as mob)
	if(contents.len <= 0)
		to_chat(user, "<span class='notice'>\The [src] is empty.</span>")
		return

	user.set_machine(src)
	var/dat = "<center><table>"
	var/i
	for(i=contents.len, i>=1, i--)
		var/obj/item/P = contents[i]
		dat += "<tr><td><a href='?src=\ref[src];retrieve=\ref[P]'>[P.name]</a></td></tr>"
	dat += "</table></center>"
	user << browse("<html><head><title>[name]</title></head><body>[dat]</body></html>", "window=filingcabinet;size=350x300")

	return


/obj/structure/filingcabinet/Topic(href, href_list)
	if(href_list["retrieve"])
		usr << browse("", "window=filingcabinet") // Close the menu

		//var/retrieveindex = text2num(href_list["retrieve"])
		var/obj/item/P = locate(href_list["retrieve"])//contents[retrieveindex]
		if(P && (P.loc == src) && in_range(src, usr))
			usr.put_in_hands(P)
			updateUsrDialog()
			flick("[initial(icon_state)]-open",src)


/*
 * Security Record Cabinets
 */
/obj/structure/filingcabinet/security
	var/virgin = 1


/obj/structure/filingcabinet/security/attack_hand(mob/user as mob)
	if(virgin)
		for(var/datum/data/record/G in data_core.general)
			var/datum/data/record/S
			for(var/datum/data/record/R in data_core.security)
				if((R.fields["name"] == G.fields["name"] || R.fields["id"] == G.fields["id"]))
					S = R
					break
			var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(src)

			P.info = {"<CENTER><B>Security Record</B></CENTER><BR>
				Name: [G.fields["name"]] ID: [G.fields["id"]]<BR>\nSex: [G.fields["sex"]]<BR>\nAge: [G.fields["age"]]<BR>\nFingerprint: [G.fields["fingerprint"]]<BR>\nPhysical Status: [G.fields["p_stat"]]<BR>\nMental Status: [G.fields["m_stat"]]<BR>
				<BR>\n<CENTER><B>Security Data</B></CENTER><BR>\nCriminal Status: [S.fields["criminal"]]<BR>\n<BR>\nImportant Notes:<BR>\n\t[S.fields["notes"]]<BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>"}
			var/counter = 1
			while(S.fields["com_[counter]"])
				P.info += "[S.fields["com_[counter]"]]<BR>"
				counter++
			P.info += "</TT>"
			P.name = "paper - '[G.fields["name"]]'"
			virgin = 0	//tabbing here is correct- it's possible for people to try and use it
						//before the records have been generated, so we do this inside the loop.
	..()


/*
 * Medical Record Cabinets
 */
/obj/structure/filingcabinet/medical
	var/virgin = 1

/obj/structure/filingcabinet/medical/attack_hand(mob/user as mob)
	if(virgin)
		for(var/datum/data/record/G in data_core.general)
			var/datum/data/record/M
			for(var/datum/data/record/R in data_core.medical)
				if((R.fields["name"] == G.fields["name"] || R.fields["id"] == G.fields["id"]))
					M = R
					break
			var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(src)

			P.info = {"<CENTER><B>Medical Record</B></CENTER><BR>
				Name: [G.fields["name"]] ID: [G.fields["id"]]<BR>\nSex: [G.fields["sex"]]<BR>\nAge: [G.fields["age"]]<BR>\nFingerprint: [G.fields["fingerprint"]]<BR>\nPhysical Status: [G.fields["p_stat"]]<BR>\nMental Status: [G.fields["m_stat"]]<BR>
				<BR>\n<CENTER><B>Medical Data</B></CENTER><BR>\nBlood Type: [M.fields["b_type"]]<BR>\nDNA: [M.fields["b_dna"]]<BR>\n<BR>\nMinor Disabilities: [M.fields["mi_dis"]]<BR>\nDetails: [M.fields["mi_dis_d"]]<BR>\n<BR>\nMajor Disabilities: [M.fields["ma_dis"]]<BR>\nDetails: [M.fields["ma_dis_d"]]<BR>\n<BR>\nAllergies: [M.fields["alg"]]<BR>\nDetails: [M.fields["alg_d"]]<BR>\n<BR>\nCurrent Diseases: [M.fields["cdi"]] (per disease info placed in log/comment section)<BR>\nDetails: [M.fields["cdi_d"]]<BR>\n<BR>\nImportant Notes:<BR>\n\t[M.fields["notes"]]<BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>"}
			var/counter = 1
			while(M.fields["com_[counter]"])
				P.info += "[M.fields["com_[counter]"]]<BR>"
				counter++
			P.info += "</TT>"
			P.name = "paper - '[G.fields["name"]]'"
			virgin = 0	//tabbing here is correct- it's possible for people to try and use it
						//before the records have been generated, so we do this inside the loop.
	..()
