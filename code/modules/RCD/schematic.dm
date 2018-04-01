/datum/rcd_schematic
	var/name			= "whomp"	//Obvious.
	var/category		= ""		//More obvious. Yes you need a category.
	var/energy_cost		= 0			//Energy cost of this schematic.
	var/flags			= 0			//Bitflags.

	var/obj/item/device/rcd/master	//Okay all of the vars here are obvious...
	var/icon
	var/icon_state
	var/obj/abstract/screen/schematics/ourobj
	var/datum/selection_schematic/selected

/datum/rcd_schematic/New(var/obj/item/device/rcd/n_master)
	master = n_master
	. = ..()
	ourobj = getFromPool(/obj/abstract/screen/schematics, null, src)

/datum/rcd_schematic/Destroy()
	master = null
	if(ourobj)
		for(var/client/C in clients)
			C.screen.Remove(ourobj)
		returnToPool(ourobj)
		ourobj = null

/datum/rcd_schematic/proc/show()
	return 0
/*
Called when the RCD this thing belongs to attacks an atom.
params:
	- var/atom/A:	The atom being attacked.
	- var/mob/user:	The mob using the RCD.

return value:
	- !0:		Non-descriptive error.
	- string:	Error with reason.
	- 0:		No errors.
*/

/datum/rcd_schematic/proc/attack(var/atom/A, var/mob/user)
	return 0

/datum/rcd_schematic/proc/clicked(var/mob/user)
	select(user, master.selected)
	return 0

/*
Called when the RCD's schematic changes away from this one.
params:
	- var/mob/user:								The user, duh...
	- var/datum/rcd_schematic/old_schematic:	The new schematic.

return value:
	- !0:	Switch allowed.
	- 0:	Switch not allowed
*/

/datum/rcd_schematic/proc/deselect(var/mob/user, var/datum/rcd_schematic/new_schematic)
	return 1


/*
Called when the RCD's schematic changes to this one
Note: this is called AFTER deselect().
params:
	- var/mob/user:								The user, duh...
	- var/datum/rcd_schematic/old_schematic:	The schematic before this one.

return value:
	- !0:	Switch allowed.
	- 0:	Switch not allowed
*/

/datum/rcd_schematic/proc/select(var/mob/user, var/datum/rcd_schematic/old_schematic)
	if(old_schematic)
		old_schematic.deselect(user, src)

	master.do_spark()

	master.selected = src

	return 1


/*
Called to get the HTML for things like the direction menu on an RPD.
Note:
	- Do not do hrefs to the src, any hrefs should direct at the HTML interface, Topic() calls are passed down if not used by the RCD itself.
	- Always return something here ("" is not enough), else there will be a Jscript error for clients.

params:
	- I don't need to explain this.
*/

/datum/rcd_schematic/proc/get_HTML()
	return " "

/datum/rcd_schematic/proc/send_assets(var/client/client)
	return

/datum/rcd_schematic/proc/register_assets()
	return

/datum/rcd_schematic/proc/build_ui()
	master.interface.updateLayout("<div id='schematic_options'> </div>")

/datum/rcd_schematic/proc/schematic_list_line(var/datum/html_interface/interface, var/fav=FALSE)
	var/fav_html
	// Important distinction: being favorited vs being rendered for the favorited list.
	// The fav parameter means the latter.
	if (master.favorites.Find(src))
		fav_html = "<a href='?src=\ref[interface];schematic=\ref[src];act=defav' class='fav' title='Unfavorite'>\[X]</a>"

		if (fav)
			var/index = master.favorites.Find(src)
			fav_html += "<span class='fav'>"
			fav_html += index != master.favorites.len ? "<a href='?src=\ref[interface];schematic=\ref[src];act=favorder;order=down'>&#8743;</a>" : "&nbsp;"
			fav_html += index != 1                    ? "<a href='?src=\ref[interface];schematic=\ref[src];act=favorder;order=up'>&#8744;</a>" : "&nbsp;"
			fav_html += "</span>"

	else
		fav_html = "<a href='?src=\ref[interface];schematic=\ref[src];act=fav' class='fav' title='Favorite'>\[F]</a>"

	var/class = ""
	if (fav && master.selected == src)
		class = "class='schematic_selected'"

	return "<li>[fav_html]<a href='?src=\ref[interface];schematic=\ref[src];act=select' [class]>[name]</a></li>"

/datum/rcd_schematic/proc/MouseWheeled(var/mob/user, var/delta_x, var/delta_y, var/params)
