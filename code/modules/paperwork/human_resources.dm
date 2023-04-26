var/list/stamptype2region = list(
	/obj/item/weapon/stamp/captain = 5,
	/obj/item/weapon/stamp/hop = 6,
	/obj/item/weapon/stamp/hos = 1,
	/obj/item/weapon/stamp/ce = 4,
	/obj/item/weapon/stamp/rd = 3,
	/obj/item/weapon/stamp/cmo = 2,
)

/obj/item/weapon/paper/demotion_key
	name = "Human Resources: Demotion Fax Key"
	info = "<center><B>Fax Machine Demotion Key</B></center><BR><BR>This document is intended for use in the station fax machines sent to NANOTRASEN HR.  Demotion keys sent to Centcomm will result in insults and allegations of incompetence.<br><ol><li>Insert into fax with your Internal Affairs ID.</li><li>Select NANOTRASEN HR to send to; Requires official Agent authorization.</li><li>Use the printed chip to carefully set a name.</li></ol> Remember to match capitalization of the employee name. Acquire Heads of Staff stamps to bar respective access, and once you have completed gathering authorizations you can apply the chip to the intended ID card.<br><br>In case of a mistake, stamp the ID card with any authorization stamp previously used to deactivate the chip."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper"
	stamps = "<br><br><i>This document has an intricate Nanontrasen logo in magnetic ink. It looks impossible to forge.</i>"

/obj/item/weapon/paper/commendation_key
	name = "Human Resources: Commendation Fax Key"
	info = "<center><B>Fax Machine Commendation Key</B></center><BR><BR>This document is intended for use in the station fax machines sent to NANOTRASEN HR.  Commendation keys sent to Centcomm will result in insults and allegations of incompetence.<br><ol><li>Insert into fax with your Internal Affairs ID.</li><li>Select NANOTRASEN HR to send to; Requires official Agent authorization.</li><li>Take the printed poster and give cordially to valued employee.</li></ol> Commendations should only be given to outstanding crew members and those who exhibit positive, productive qualities."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper"
	stamps = "<br><br><i>This document has an intricate Nanontrasen logo in magnetic ink. It looks impossible to forge.</i>"


/obj/item/demote_chip
	name = "unprogrammed demotion microchip"
	desc = "A microchip that removes certain access when applied to ID cards."
	icon = 'icons/obj/card.dmi'
	icon_state = "demote_chip"
	w_class = W_CLASS_TINY
	var/target_name = null
	var/list/stamped = list()

/obj/item/demote_chip/attack_self(mob/user as mob)
	if(target_name != null) //Used hand-labeler as example
		to_chat(user, "<span class='notice'>The target name cannot be reset!</span>")
		return
	else
		var/str = copytext(reject_bad_text(input(user,"Enter the properly capitalized name for demotion","Set name","") as text|null),1,MAX_NAME_LEN)
		if (!Adjacent(user) || user.stat)
			return
		if(!str)
			alert("Invalid name.")
			target_name = null
			return
		target_name = str
		name = "[target_name]'s demotion microchip"
		to_chat(user, "<span class='notice'>The demotion microchip for [src.target_name] is now ready to be stamped.</span>")

/obj/item/demote_chip/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/stamp))
		var/obj/item/weapon/stamp/S = I
		if(target_name != null)//Stamper must be able to see who he is banning
			stamped += S.type
			to_chat(user, "<span class='notice'>You stamp the demotion microchip of [target_name] with \the [S].</span>")
			desc = "A microchip that removes certain access when applied to ID cards. Stamped by: [english_list(uniquenamelist(stamped), "Nobody", "/", "/")]"
		else
			to_chat(user, "<span class='notice'>The chip has not been initialized.</span>")
	else
		return ..()

/obj/item/weapon/card/id/syndicate/attackby(var/obj/item/I as obj, mob/user as mob)
	//placebo, does not affect access on syndie agent card
	if(istype(I, /obj/item/demote_chip/))
		var/obj/item/demote_chip/DE = I
		if(registered_name != DE.target_name)
			to_chat(user, "<span class='notice'>Failed to apply, names do not match.</span>")
		else if(dchip)
			to_chat(user, "<span class='notice'>This card already has a microchip applied</span>")
		else if(user.drop_item(DE,src))
			icon_state = "centcom_old"
			dchip = DE
	else
		return ..()

/obj/item/weapon/card/id/attackby(var/obj/item/I as obj, mob/user as mob)
	//Check for if names match, card already has a chip, and its not a captains ID.
	if(istype(I, /obj/item/demote_chip))
		var/obj/item/demote_chip/D = I
		if(registered_name != D.target_name)
			to_chat(user, "<span class='notice'>Failed to apply, names do not match.</span>")
		else if(dchip)
			to_chat(user, "<span class='notice'>This card already has a microchip applied.</span>")
		else if(icon_state == "gold")
			to_chat(user, "<span class='notice'>This microchip cannot apply to this card type.</span>")
		else if(!D.stamped.len)
			to_chat(user, "<span class='notice'>You require at least one stamp.</span>")
			return
		else if(user.drop_item(D,src))
			for(var/stamptype in D.stamped)
				if(isnum(stamptype2region[stamptype]))
					access -= get_region_accesses(stamptype2region[stamptype])
					if(stamptype2region[stamptype] == 6)
						access -= get_region_accesses(7)
			icon_state = "centcom_old"
			dchip = D
			to_chat(user, "<span class='notice'>You apply \the [D] to \the [src].</span>")
	if(dchip && (istype(I,/obj/item/weapon/stamp/captain) || istype(I,/obj/item/weapon/stamp/hop) || (I.type in dchip.stamped)))
		to_chat(user, "<span class='notice'>You remove \the [dchip] from \the [src] by stamping it.</span>")
		user.put_in_hands(dchip)
		dchip = null
	else
		return ..()
