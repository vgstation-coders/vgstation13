//This could either be split into the proper DM files or placed somewhere else all together, but it'll do for now -Nodrak

/*

A list of items and costs is stored under the datum of every game mode, alongside the number of crystals, and the welcoming message. //WHY

*/

/obj/item/device/uplink
	var/welcome 					// Welcoming menu message
	var/uses 						// Number of crystals
	// List of items not to shove in their hands.
	var/list/purchase_log = list()
	var/show_description = null
	var/active = 0
	var/job = null

/obj/item/device/uplink/New()
	..()
	if(ticker)
		initialize()
		return

/obj/item/device/uplink/initialize()
	if(ticker.mode)
		welcome = "Syndicate Uplink Console"
		uses = 20
	else
		welcome = "THANKS FOR MAPPING IN THIS THING AND NOT CHECKING FOR RUNTIMES BUDDY"
		uses = 90 // Because this is only happening on centcomm's snowflake uplink

/obj/item/device/uplink/proc/refund(mob/user, obj/item/I)
	if(!user || !I)
		return
	if(!uplink_items)
		get_uplink_items()
	for(var/category in uplink_items)
		for(var/item in uplink_items[category])
			var/datum/uplink_item/UI = item
			var/path = UI.refund_path || UI.item
			var/cost = UI.refund_amount || UI.cost
			if(istype(I, path) && UI.refundable && I.check_uplink_validity())
				uses += cost
				to_chat(user, "<span class='notice'>[I] refunded.</span>")
				qdel(I)
				return TRUE
	return FALSE

//Let's build a menu!
/obj/item/device/uplink/proc/generate_menu(mob/user as mob)
	if(!job)
		job = user.mind.assigned_role

	var/dat = list()
	dat += "<B>[src.welcome]</B><BR>"

	dat += {"Tele-Crystals left: [src.uses]<BR>
		<HR>
		<B>Request item:</B><BR>
		<I>Each item costs a number of tele-crystals as indicated by the number following their name.</I><br><BR>"}
	var/list/buyable_items = get_uplink_items()

	// Loop through categories
	var/index = 0
	for(var/category in buyable_items)

		index++
		dat += "<b>[category]</b><br>"

		var/discounted_list = list() //These go on top.
		var/jobexclusive_list = list()
		var/nondiscounted_list = list() //These go on the bottom.

		var/i = 0
		// Loop through items in category
		for(var/datum/uplink_item/item in buyable_items[category])
			i++

			if(!item.available_for_job(job))
				continue

			var/itemcost = item.get_cost(job)
			var/cost_text = ""
			var/desc = "[item.desc]"
			var/final_text = ""
			if(itemcost > 0)
				if(item.gives_discount(job) || item.jobs_exclusive.len)
					cost_text = "<span style='color: yellow; font-weight: bold;'>([itemcost]!)</span>"
				else
					cost_text = "([itemcost])"
			if(itemcost <= uses)
				final_text += "<A href='byond://?src=\ref[src];buy_item=[url_encode(category)]:[i];'>[item.name]</A> [cost_text] "
			else
				final_text += "<font color='grey'><i>[item.name] [cost_text] </i></font>"
			if(item.refundable)
				final_text += "<span style='color: yellow;'>\[R\]</span>"
			if(item.desc)
				if(show_description == 2)
					final_text += "<A href='byond://?src=\ref[src];show_desc=1'><font size=2>\[-\]</font></A><BR><font size=2>[desc][item.refundable ? " Use this item on your uplink to refund it for [item.refund_amount || item.cost] TC.":""]</font>"
				else
					final_text += "<A href='byond://?src=\ref[src];show_desc=2' title='[html_encode(desc)]'><font size=2>\[?\]</font></A>"
			final_text += "<BR>"

			if(item.gives_discount(job))
				discounted_list += final_text
			else if(item.jobs_exclusive.len) //If we don't match this thing's job, we already exited out, so we don't need to check again
				jobexclusive_list += final_text
			else
				nondiscounted_list += final_text

		for(var/text in discounted_list|jobexclusive_list|nondiscounted_list) //Discounted first, nondiscounted later.
			dat += text

		// Break up the categories, if it isn't the last.
		if(buyable_items.len != index)
			dat += "<br>"

	dat += "<HR>"
	dat = jointext(dat,"") //Optimize BYOND's shittiness by making "dat" actually a list of strings and join it all together afterwards! Yes, I'm serious, this is actually a big deal
	return dat

// Interaction code. Gathers a list of items purchasable from the paren't uplink and displays it. It also adds a lock button.
/obj/item/device/uplink/interact(mob/user as mob)

	var/dat = "<body link='yellow' alink='white' bgcolor='#601414'><font color='white'>"
	dat += src.generate_menu(user)

	dat += {"<A href='byond://?src=\ref[src];lock=1'>Lock</a>
		</font></body>"}
	user << browse(dat, "window=hidden")
	onclose(user, "hidden")
	return


/obj/item/device/uplink/Topic(href, href_list)
	..()

	if (!is_holder_of(usr, src))
		message_admins("[key_name(usr)] tried to access [src], an unlocked PDA, despite not being its holder. ([formatJumpTo(get_turf(src))])")
		return FALSE

	if(!active)
		return

	if (href_list["buy_item"])

		var/item = href_list["buy_item"]
		var/list/split = splittext(item, ":") // throw away variable

		if(split.len == 2)
			// Collect category and number
			var/category = split[1]
			var/number = text2num(split[2])

			if(!job) //Should never happen unless the user somehow sends out a Topic() call before opening their uplink, but just in case.
				job = usr.mind.assigned_role
			var/list/buyable_items = get_uplink_items(job)

			var/list/uplink = buyable_items[category]
			if(uplink && uplink.len >= number)
				var/datum/uplink_item/I = uplink[number]
				if(I)
					I.buy(src, usr)
			else
				var/text = "[key_name(usr)] tried to purchase an uplink item that doesn't exist"
				var/textalt = "[key_name(usr)] tried to purchase an uplink item that doesn't exist [item]"
				message_admins(text)
				log_game(textalt)
				admin_log.Add(textalt)

	else if(href_list["show_desc"])
		show_description = text2num(href_list["show_desc"])
		interact(usr)

// HIDDEN UPLINK - Can be stored in anything but the host item has to have a trigger for it.
/* How to create an uplink in 3 easy steps!

 1. All obj/item 's have a hidden_uplink var. By default it's null. Give the item one with "new(src)", it must be in it's contents. Feel free to add "uses".

 2. Code in the triggers. Use check_trigger for this, I recommend closing the item's menu with "usr << browse(null, "window=windowname") if it returns true.
 The var/value is the value that will be compared with the var/target. If they are equal it will activate the menu.

 3. If you want the menu to stay until the users locks his uplink, add an active_uplink_check(mob/user as mob) in your interact/attack_hand proc.
 Then check if it's true, if true return. This will stop the normal menu appearing and will instead show the uplink menu.
*/

/obj/item/device/uplink/hidden
	name = "Hidden Uplink."
	desc = "There is something wrong if you're examining this."

/obj/item/device/uplink/hidden/Destroy()
	var/obj/item/I = loc
	I.hidden_uplink = null
	..()

/obj/item/device/uplink/hidden/Topic(href, href_list)
	..()
	if(href_list["lock"])
		toggle()
		usr << browse(null, "window=hidden")
		return 1

// Toggles the uplink on and off. Normally this will bypass the item's normal functions and go to the uplink menu, if activated.
/obj/item/device/uplink/hidden/proc/toggle()
	active = !active

// Directly trigger the uplink. Turn on if it isn't already.
/obj/item/device/uplink/hidden/proc/trigger(mob/user as mob)
	if(!active)
		toggle()
	interact(user)

// Checks to see if the value meets the target. Like a frequency being a traitor_frequency, in order to unlock a headset.
// If true, it accesses trigger() and returns 1. If it fails, it returns false. Use this to see if you need to close the
// current item's menu.
/obj/item/device/uplink/hidden/proc/check_trigger(mob/user as mob, var/value, var/target)
	if(value == target)
		trigger(user)
		return 1
	return 0

// I placed this here because of how relevant it is.
// You place this in your uplinkable item to check if an uplink is active or not.
// If it is, it will display the uplink menu and return 1, else it'll return false.
// If it returns true, I recommend closing the item's normal menu with "user << browse(null, "window=name")"
/obj/item/proc/active_uplink_check(mob/user as mob)
	// Activates the uplink if it's active
	if(src.hidden_uplink)
		if(src.hidden_uplink.active)
			src.hidden_uplink.trigger(user)
			return 1
	return 0

// PRESET UPLINKS
// A collection of preset uplinks.
//
// Includes normal radio uplink, multitool uplink,
// implant uplink (not the implant tool) and a preset headset uplink.

/obj/item/device/radio/uplink/New()
	hidden_uplink = new(src)
	icon_state = "radio"

/obj/item/device/radio/uplink/attack_self(mob/user as mob)
	if(hidden_uplink)
		hidden_uplink.trigger(user)

/obj/item/device/radio/uplink/attackby(var/obj/I, var/mob/user)
	if(hidden_uplink && hidden_uplink.refund(user, I))
		return
	..()

/obj/item/device/radio/uplink/nukeops/New()
	..()
	hidden_uplink.uses = 80 //haha fuck OOP
	hidden_uplink.job = "Nuclear Operative"

/obj/item/device/multitool/uplink/New()
	hidden_uplink = new(src)

/obj/item/device/multitool/uplink/attack_self(mob/user as mob)
	if(hidden_uplink)
		hidden_uplink.trigger(user)

/obj/item/device/radio/headset/uplink
	traitor_frequency = 1445

/obj/item/device/radio/headset/uplink/New()
	..()
	hidden_uplink = new(src)
	hidden_uplink.uses = 20
