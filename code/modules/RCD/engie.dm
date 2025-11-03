/obj/item/device/rcd/matter/engineering
	schematics = list(
	/datum/rcd_schematic/decon,
	/datum/rcd_schematic/con_floors,
	/datum/rcd_schematic/con_walls,
	/datum/rcd_schematic/con_airlock,
	/datum/rcd_schematic/con_window,
	)
	current_menu="deconstruct"


/obj/item/device/rcd/matter/engineering/New(var/loc=null,var/no_schematics=FALSE)
	. = ..()
	rcd_list += src

	if(!no_schematics)
		var/datum/rcd_scematic_grouping/destroy/dest_g = new(src)
		dest_g.schematics+= new /datum/rcd_grouped_schematic/destroy_all(src)
	
		var/datum/rcd_scematic_grouping/build_wall/engi_std/wall_g = new(src)
		var/datum/rcd_scematic_grouping/build_floors/engi_std/floor_g = new(src)
		var/datum/rcd_scematic_grouping/build_windows/engi_std/window_g = new(src)
		var/datum/rcd_scematic_grouping/build_airlock/engi_std/airlock_g=new(src)
		var/datum/rcd_scematic_grouping/misc_objects/engi_std/misc_g=new(src)
	
		schem_groups+=dest_g
		schem_groups+=wall_g
		schem_groups+=floor_g
		schem_groups+=airlock_g
		schem_groups+=window_g
		schem_groups+=misc_g
	
		current_menu=schem_groups[1]?.name
		schem_groups[1]?.switch_to()
	

/obj/item/device/rcd/matter/engineering/Destroy()
	. = ..()
	rcd_list -= src

/obj/item/device/rcd/matter/engineering/afterattack(var/atom/A, var/mob/user)
	if(malf_rcd_disable)
		return

	return ..()
	
/obj/item/device/rcd/matter/engineering/attack_self(var/mob/user)
	rebuild_ui()	
	interface.show(user)
	if( locate(user.client) in loaded_clients )
		return
		
	for(var/datum/rcd_scematic_grouping/schemgroup in schem_groups)
		schemgroup.send_assets(user.client)
		for(var/datum/rcd_grouped_schematic/sch)
			sch.send_assets(user.client)
	interface.hide(user) //have to do this since loading so many images takes a lot of time. and no images is better than no UI
	interface.show(user)
	loaded_clients+=user.client


/obj/item/device/rcd/matter/engineering/Topic(var/href, var/list/href_list)	
	if(href_list["clear_images"])
		loaded_clients=new()
	if(href_list["set_group"])
		for(var/datum/rcd_scematic_grouping/schem_group in schem_groups)
			if(schem_group.name==href_list["set_group"])
				current_menu=href_list["set_group"]
				schem_group.switch_to()
				do_spark()
				rebuild_ui()
				return
	if(href_list["set_schematic"])
		var/datum/rcd_scematic_grouping/group
		for(var/datum/rcd_scematic_grouping/schem_group in schem_groups)
			if(schem_group.name==current_menu)
				group=schem_group
				break
		if(group)
			for(var/datum/rcd_grouped_schematic/schm in group.schematics)
				if(schm.name==href_list["set_schematic"])
					selected_schem=schm
					do_spark()
					rebuild_ui()
					break
		return			
	if(href_list["set_arg"])
		if(href_list["value_togglelist"])
			var/val =  href_list["value_isnum"]=="yes" ? text2num(href_list["value"]) : href_list["value"]
			var/found=FALSE
			for(var/n in settings[href_list["set_arg"]])
				if(n==val)
					found=TRUE
					break
			if( found )
				settings[href_list["set_arg"]] -= val
			else
				settings[href_list["set_arg"]] += val
		else if(href_list["value_resetlist"])
			settings[href_list["set_arg"]]=new /list()
		else if(href_list["value_toggle"] )
			settings[href_list["set_arg"]] = ! settings[href_list["set_arg"]]
		else if (href_list["value_input"])
			var/tx=""
			for(var/datum/rcd_scematic_grouping/schem_group in schem_groups)
				if(schem_group.name==current_menu)
					tx=schem_group.selectiondialogue
					break
			settings[href_list["set_arg"]] = input(usr, tx, src, "[selected_schem?.name]")
		else
			settings[href_list["set_arg"]] = href_list["value_isnum"]=="yes" ? text2num(href_list["value"]) : href_list["value"]
		rebuild_ui()
		return
		
	return

/obj/item/device/rcd/matter/engineering/rebuild_ui()
	var/dat=""
	
	dat+="Compressed Matter: [matter]/[max_matter] <span class='schem'><a href='?src=\ref[interface];clear_images=yes;'>Reload Images</a></span><hr>"
	
	//that's right, you can embed a stylesheet in the html body, and you better believe i'm going to do this instead of setting up a whole new file for like 2 rules.
	dat+={"<style> 
	.grouplisting{
	text-align:center;
	font-size:100%;
	}
	.grouplisting img {
	width:64px;
	height:64px;
	}
	
	.grouplisting a{
	width:100%;
	height:100%;
	display:block;
	background:revert;
	}
	
	.clickabletable td{
		text-align:center;
		height:100%; /*to make it so that links inhabit the whole size of the td. kinda annoying to have to do all this.*/
	}
	
	.clickabletable a{
		width:100%;
		height:100%;
		display:block;
	}
	
	img, .clickabletable img, .grouplisting img {
		border:none;
		background:none;
		image-rendering:pixelated;
	}
	
	</style>"}
	
	dat+="<table class='grouplisting'><tr>"
	for(var/datum/rcd_scematic_grouping/schem_group in schem_groups)
		dat+="<td class='[schem_group.name==current_menu ? "schem_selected" : "schem" ]'><a href='?src=\ref[interface];set_group=[schem_group.name]'><img src='[schem_group.headerimage]'><br>[schem_group.name]</a></td>"
	dat+="</tr></table><hr>"
	
	
	for(var/datum/rcd_scematic_grouping/schem_group in schem_groups)
		if(schem_group.name==current_menu)
			var/t=schem_group.generate_html()
			dat+=t
			break
			
	
	interface.updateLayout(dat)

/obj/item/device/rcd/matter/engineering/afterattack(var/atom/A, var/mob/user)
	if(!selected_schem)
		return 1
	if( !(user.Adjacent(A) && A.Adjacent(user)) )
		return 1
	if(get_dist(A, user) > 1)
		return 1

	var/c=selected_schem.build(A,user)
	if(!c)
		to_chat(user, "<span class='warning'>\The [src]'s error light flickers.</span>")
	else
		use_energy(c, user)
		rebuild_ui()
	return 1
	

/obj/item/device/rcd/matter/engineering/suicide_act(var/mob/living/user)
	visible_message("<span class='danger'>[user] is using the deconstruct function on \the [src] on \himself! It looks like \he's trying to commit suicide!</span>")
	user.death(1)
	return SUICIDE_ACT_CUSTOM

/obj/item/device/rcd/matter/engineering/pre_loaded/New(var/loc=null,var/no_schematics=FALSE) //Comes with max energy
	..(loc,no_schematics)
	matter = max_matter






/obj/item/device/rcd/borg/engineering
	schematics = list(
	/datum/rcd_schematic/decon,
	/datum/rcd_schematic/con_floors,
	/datum/rcd_schematic/con_walls,
	/datum/rcd_schematic/con_airlock/borg,
	/datum/rcd_schematic/con_window/borg,
	)
	var/matter=0
	
	current_menu="deconstruct"

/obj/item/device/rcd/borg/engineering/New()
	. = ..()
	rcd_list += src

	var/datum/rcd_scematic_grouping/destroy/dest_g = new(src)
	dest_g.schematics+= new /datum/rcd_grouped_schematic/destroy_all(src)

	schem_groups+=dest_g
	schem_groups+=new /datum/rcd_scematic_grouping/build_wall/engi_std(src)
	schem_groups+=new /datum/rcd_scematic_grouping/build_floors/engi_std(src)
	schem_groups+=new /datum/rcd_scematic_grouping/build_airlock/engi_std(src)
	schem_groups+=new /datum/rcd_scematic_grouping/build_windows/engi_std(src)
	
	current_menu=schem_groups[1]?.name
	schem_groups[1]?.switch_to()

	
/obj/item/device/rcd/borg/engineering/attack_self(var/mob/user)
	if(!isrobot(user))
		return
	matter = get_energy(user)

	rebuild_ui()	
	interface.show(user)
	if( locate(user.client) in loaded_clients )
		return
		
	for(var/datum/rcd_scematic_grouping/schemgroup in schem_groups)
		schemgroup.send_assets(user.client)
		for(var/datum/rcd_grouped_schematic/sch)
			sch.send_assets(user.client)
	interface.hide(user) //have to do this since loading so many images takes a lot of time. and no images is better than no UI
	interface.show(user)
	loaded_clients+=user.client


/obj/item/device/rcd/borg/engineering/Topic(var/href, var/list/href_list)
	if(href_list["clear_images"])
		loaded_clients=new()
	if(href_list["set_group"])
		for(var/datum/rcd_scematic_grouping/schem_group in schem_groups)
			if(schem_group.name==href_list["set_group"])
				current_menu=href_list["set_group"]
				schem_group.switch_to()
				do_spark()
				rebuild_ui()
				return
	if(href_list["set_schematic"])
		var/datum/rcd_scematic_grouping/group
		for(var/datum/rcd_scematic_grouping/schem_group in schem_groups)
			if(schem_group.name==current_menu)
				group=schem_group
				break
		if(group)
			for(var/datum/rcd_grouped_schematic/schm in group.schematics)
				if(schm.name==href_list["set_schematic"])
					selected_schem=schm
					do_spark()
					rebuild_ui()
					break
		return			
	if(href_list["set_arg"])
		if(href_list["value_togglelist"])
			var/val =  href_list["value_isnum"]=="yes" ? text2num(href_list["value"]) : href_list["value"]
			var/found=FALSE
			for(var/n in settings[href_list["set_arg"]])
				if(n==val)
					found=TRUE
					break
			if( found )
				settings[href_list["set_arg"]] -= val
			else
				settings[href_list["set_arg"]] += val
		else if(href_list["value_resetlist"])
			settings[href_list["set_arg"]]=new /list()
		else if(href_list["value_toggle"] )
			settings[href_list["set_arg"]] = ! settings[href_list["set_arg"]]
		else if (href_list["value_input"])
			var/tx=""
			for(var/datum/rcd_scematic_grouping/schem_group in schem_groups)
				if(schem_group.name==current_menu)
					tx=schem_group.selectiondialogue
					break
			settings[href_list["set_arg"]] = input(usr, tx, src, "[selected_schem?.name]")
		else
			settings[href_list["set_arg"]] = href_list["value_isnum"]=="yes" ? text2num(href_list["value"]) : href_list["value"]
		rebuild_ui()
		return
		
	return

/obj/item/device/rcd/borg/engineering/rebuild_ui()
	var/dat=""
	
	dat+="Charge: [floor(matter)] <span class='schem'><a href='?src=\ref[interface];clear_images=yes;'>Reload Images</a></span><hr>"
	
	//that's right, you can embed a stylesheet in the html body, and you better believe i'm going to do this instead of setting up a whole new file for like 2 rules.
	dat+={"<style> 
	.grouplisting{
	text-align:center;
	font-size:100%;
	}
	.grouplisting img {
	width:64px;
	height:64px;
	}
	
	.grouplisting a{
	width:100%;
	height:100%;
	display:block;
	background:revert;
	}
	
	.clickabletable td{
		text-align:center;
		height:100%; /*to make it so that links inhabit the whole size of the td. kinda annoying to have to do all this.*/
	}
	
	.clickabletable a{
		width:100%;
		height:100%;
		display:block;
	}
	
	img, .clickabletable img, .grouplisting img {
		border:none;
		background:none;
		image-rendering:pixelated;
	}
	
	</style>"}
	
	dat+="<table class='grouplisting'><tr>"
	for(var/datum/rcd_scematic_grouping/schem_group in schem_groups)
		dat+="<td class='[schem_group.name==current_menu ? "schem_selected" : "schem" ]'><a href='?src=\ref[interface];set_group=[schem_group.name]'><img src='[schem_group.headerimage]'><br>[schem_group.name]</a></td>"
	dat+="</tr></table><hr>"
	
	
	for(var/datum/rcd_scematic_grouping/schem_group in schem_groups)
		if(schem_group.name==current_menu)
			var/t=schem_group.generate_html()
			dat+=t
			break
			
	
	interface.updateLayout(dat)

/obj/item/device/rcd/borg/engineering/afterattack(var/atom/A, var/mob/user)
	if(!selected_schem)
		return 1
	if( !(user.Adjacent(A) && A.Adjacent(user)) )
		return 1
	if(get_dist(A, user) > 1)
		return 1

	if(!isrobot(user))
		return 1
	matter = get_energy(user)

	var/c=selected_schem.build(A,user)
	if(!c)
		to_chat(user, "<span class='warning'>\The [src]'s error light flickers.</span>")
	else
		use_energy(c, user)
		
		matter = get_energy(user)
		
		rebuild_ui()
	return 1	

/obj/item/device/rcd/matter/engineering/pre_loaded/adv
	name = "advanced Rapid-Construction-Device (RCD)"
	icon_state = "arcd"
	schematics = list(
	/datum/rcd_schematic/decon,
	/datum/rcd_schematic/con_floors,
	/datum/rcd_schematic/con_rfloors,
	/datum/rcd_schematic/con_walls,
	/datum/rcd_schematic/con_rwalls,
	/datum/rcd_schematic/con_airlock,
	/datum/rcd_schematic/con_window,
	)
	matter = 90
	max_matter = 90
	origin_tech = Tc_ENGINEERING + "=5;" + Tc_MATERIALS + "=4;" + Tc_PLASMATECH + "=4"
	mech_flags = MECH_SCAN_FAIL
	slimeadd_message = "You put the slime extract on the SRCTAG's compressed matter slot"
	slimes_accepted = SLIME_DARKPURPLE
	slimeadd_success_message = "It gains a distinct plasma pink hue"

/obj/item/device/rcd/matter/engineering/pre_loaded/adv/New(var/loc=null,var/no_schematics=FALSE)
	..(loc,TRUE)
	
	if(!no_schematics)
		var/datum/rcd_scematic_grouping/destroy/dest_g = new(src)
		dest_g.schematics+= new /datum/rcd_grouped_schematic/destroy_all(src)

		schem_groups+=dest_g
		schem_groups+=new /datum/rcd_scematic_grouping/build_wall/engi_std/CE(src)
		schem_groups+=new /datum/rcd_scematic_grouping/build_floors/engi_std/CE(src)
		schem_groups+=new /datum/rcd_scematic_grouping/build_airlock/engi_std/CE(src)
		schem_groups+=new /datum/rcd_scematic_grouping/build_windows/engi_std(src)
		schem_groups+=new /datum/rcd_scematic_grouping/misc_objects/engi_std/CE(src)
	
		current_menu=schem_groups[1].name
		schem_groups[1].switch_to()

	
/obj/item/device/rcd/matter/engineering/pre_loaded/adv/slime_act(primarytype, mob/user)
	. = ..()
	if(. && (slimes_accepted & primarytype))
		var/datum/rcd_schematic/con_pwindow/P = new(src)
		if(!schematics[P.category])
			schematics[P.category] = list()
		schematics[P.category] += P
		
		for(var/datum/rcd_scematic_grouping/schem_group in schem_groups)
			if(istype(schem_group,/datum/rcd_scematic_grouping/build_windows) )
				schem_group.schematics+=new /datum/rcd_grouped_schematic/glass/plasma(src)
				schem_group.schematics+=new /datum/rcd_grouped_schematic/glass/rplas(src)	
			if(istype(schem_group,/datum/rcd_scematic_grouping/build_airlock) )
				schem_group.schematics+= new /datum/rcd_grouped_schematic/airlock/tabledoor/reinforced(src)
			if(istype(schem_group,/datum/rcd_scematic_grouping/build_floors) )
				schem_group.schematics+= new/datum/rcd_grouped_schematic/plasmaglassfloor(src)
			if(istype(schem_group,/datum/rcd_scematic_grouping/misc_objects) )
				schem_group.schematics+= new/datum/rcd_grouped_schematic/table/pglass(src)	
		loaded_clients=list() //refresh images since we are adding more to show.
		rebuild_ui()
			

/obj/item/device/rcd/matter/engineering/pre_loaded/adv/delay(var/mob/user, var/atom/target, var/amount)
	return do_after(user, target, amount/2)

/obj/item/device/rcd/matter/engineering/pre_loaded/adv/admin
	name = "experimental Rapid-Construction-Device (RCD)"
	schematics = list(
	/datum/rcd_schematic/decon,
	/datum/rcd_schematic/con_floors,
	/datum/rcd_schematic/con_rfloors,
	/datum/rcd_schematic/con_walls,
	/datum/rcd_schematic/con_rwalls,
	/datum/rcd_schematic/con_airlock,
	/datum/rcd_schematic/con_window,
	/datum/rcd_schematic/con_pwindow,
	)
	has_slimes = SLIME_DARKPURPLE // just so this doesn't cause anything off

/obj/item/device/rcd/matter/engineering/pre_loaded/adv/admin/afterattack(var/atom/A, var/mob/user)
	if(!user.check_rights(R_ADMIN))
		visible_message("\The [src] disappears into nothing.")
		qdel(src)
		return
	return ..()

/obj/item/device/rcd/matter/engineering/pre_loaded/adv/admin/delay(var/mob/user, var/atom/target, var/amount)
	return TRUE
