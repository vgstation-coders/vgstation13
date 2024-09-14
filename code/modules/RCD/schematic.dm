/datum/rcd_schematic
	var/name				= "whomp"	//Obvious.
	var/category			= ""		//More obvious. Yes you need a category.
	var/energy_cost			= 0			//Energy cost of this schematic.
	var/delaytime			= 0			//Delay time.
	var/flags				= 0			//Bitflags.

	var/obj/item/device/rcd/master		//Okay all of the vars here are obvious...
	var/icon
	var/icon_state
	var/list/overlays		= list()
	var/obj/abstract/screen/schematics/ourobj
	var/datum/selection_schematic/selected
	var/list_icon=null //the icon that is displayed next to the name on the list.

/datum/rcd_schematic/New(var/obj/item/device/rcd/n_master)
	master = n_master
	. = ..()
	ourobj = new /obj/abstract/screen/schematics(null, src)

/datum/rcd_schematic/Destroy()
	master = null
	if(ourobj)
		for(var/client/C in clients)
			C.screen.Remove(ourobj)
		QDEL_NULL(ourobj)
	selected = null
	..()

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

/datum/rcd_schematic/proc/send_list_assets(var/client/client) //this is called when opening the menu to make sure the listed options have their icons.
	return //registering happens on the same proc unlike send_assets, since this is more specialized.

/datum/rcd_schematic/proc/schematic_list_line(var/datum/html_interface/interface, var/fav=FALSE,var/selected=FALSE)
	var/fav_html
	var/class="'schem'"
	var/image_html=""
	// Important distinction: being favorited vs being rendered for the favorited list.
	// The fav parameter means the latter.
	if (master.favorites.Find(src))
		fav_html = "<td class='shcem_sub'><a href='?src=\ref[interface];schematic=\ref[src];act=defav' title='Unfavorite'>&#x2605;</a><td>"

		if (fav)
			var/index = master.favorites.Find(src)
			fav_html += index != 1 ? "<td class='shcem_sub'><a href='?src=\ref[interface];schematic=\ref[src];act=favorder;order=down'>&#x2BC5;</a></td>" : "<td class='shcem_sub'><a>&nbsp;</a></td>"
			fav_html += index != master.favorites.len                    ? "<td class='shcem_sub' ><a href='?src=\ref[interface];schematic=\ref[src];act=favorder;order=up'>&#X2BC6;</a></td>" : "<td class='shcem_sub'><a>&nbsp;</a></td>"

	else
		fav_html = "<td class='shcem_sub'><a href='?src=\ref[interface];schematic=\ref[src];act=fav'  title='Favorite'>&#x2606;</a></td>"

	if (selected)
		class="'schem_selected'"
	if (list_icon)
		image_html="<img id='list_icon' src='[list_icon]'></img>"
		
	return "<table class=[class]><tr>[fav_html]<td><a href='?src=\ref[interface];schematic=\ref[src];act=select' >[image_html][name]</a><td><tr></table>"

/datum/rcd_schematic/proc/MouseWheeled(var/mob/user, var/delta_x, var/delta_y, var/params)
