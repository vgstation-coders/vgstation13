/datum/pda_app/multimessage
	name = "Department Messenger"
	desc = "Messages an entire department at once."
	has_screen = FALSE
	icon = "pda_mail"

/datum/pda_app/multimessage/on_select(var/mob/user)
	var/list/department_list = list("security","engineering","medical","research","cargo","service")
	var/target = input("Select a department", "CAMO Service") as null|anything in department_list
	if(!target)
		return
	var/t = input(user, "Please enter message", "Message to [target]", null) as text|null
	t = copytext(sanitize(t), 1, MAX_MESSAGE_LEN)
	//If no message, messaging is off, and we're either out of range or not in usr
	if (!t || pda_device.toff || (!in_range(pda_device, user) && pda_device.loc != user))
		return
	if (pda_device.last_text && world.time < pda_device.last_text + 5)
		return
	pda_device.last_text = world.time
	for(var/obj/machinery/pda_multicaster/multicaster in pda_multicasters)
		if(multicaster.check_status())
			multicaster.multicast(target,pda_device,user,t)
			pda_device.tnote["msg_id"] = "<i><b>&rarr; To [target]:</b></i><br>[t]<br>"
			msg_id++
			return
	to_chat(user, "[bicon(pda_device)]<span class='warning'>The PDA's screen flashes, 'Error, CAMO server is not responding.'</span>")