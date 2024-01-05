/*
 * Remote gallery
 * I apologise for the awful amount of copypaste with the existing library code ;_;
 */
/obj/machinery/computer/library/checkout/remote_gallery
	name = "remote gallery computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "artcomp"
	moody_state = "overlay_artcomp"
	anchored = 1
	density = 1
	req_access = list(access_library) //This access requirement is currently only used for the delete button showing

	library_table = "painting_db"

	pass_flags = PASSTABLE
	machine_flags = EMAGGABLE | WRENCHMOVE | FIXED2WORK

	library_section_names = list("14x14", "24x24", "24x14", "14x24")

	hack_abilities = list(
		/datum/malfhack_ability/toggle/disable,
		/datum/malfhack_ability/oneuse/overload_quiet,
	)


// -- Not /sure/ how to make this work without copypaste ;_;
/obj/machinery/computer/library/checkout/remote_gallery/interact(var/mob/user)
	if(interact_check(user))
		return

	var/dat={"
	<h3>Remote gallery viewer</h3>
	<br/>
	"}

	if(!SSdbcore.IsConnected())
		dat += "<font color=red><b>ERROR</b>: Unable to contact Remote Gallery. Please contact your system administrator for assistance.</font>"
	else
		num_results = src.get_num_results()
		num_pages = Ceiling(num_results/LIBRARY_BOOKS_PER_PAGE)
		dat += {"<ul>
			<li><A href='?src=\ref[src];id=-1'>(Order painting by SS<sup>13</sup>BN)</A></li>
		</ul>"}
		var/pagelist = get_pagelist()

		var/list/category_elements = list()
		for(var/i=1,i<=library_section_names.len, ++i)
			category_elements += "<option value='[library_section_names[i]]'>[library_section_names[i]]</option>"
		category_elements = category_elements.Join("")

		var/script = {"
			<script type="text/javascript">
				function toggleForm() {
					var form = document.getElementById('category-form');
					if (form.style.display === 'none' || form.style.display === '') {
						form.style.display = 'block';
					} else {
						form.style.display = 'none';
					}
				}
			</script>"}

		dat += {"<h3>Search Settings</h3><br />
			<A href='?src=\ref[src];settitle=1'>Filter by Title: [query.title]</A><br />
			<A href='?src=\ref[src];setauthor=1'>Filter by Author: [query.author]</A><br />
			<A href="javascript:toggleForm();">Filter by Categories: [query.categories ? query.categories.Join(", ") : ""]</A><br />
			<form id='category-form' name='setcategories' action='?src=\ref[src]' method='get' style='display:none; width: 130px'>
				<input type='hidden' name='src' value='\ref[src]'>
				<input type='hidden' name='setcategories' value='1'>
				<select name='categories' multiple style='width: 100%; height: 80px; display: inline-block;'>
					[category_elements]
				</select>
				<input type='submit' value='Set Categories' onclick='toggleForm();'>
			</form>
			[script]
			<A href='?src=\ref[src];search=1'>\[Start Search\]</A><br />"}
		dat += pagelist

		dat += {"<table border=\"0\">
					<tr>
						<td>Author</td>
						<td>Title</td>
						<td>Painting</td>
						<td>Description</td>
						<td>Controls</td>
					</tr>"}

		for(var/datum/cachedbook/C in get_page(page_num))
			if(C) last_id_processed = C.id
			var/author = C.author
			var/datum/custom_painting/the_painting = json2painting(C.content)
			var/controls =  "<A href='?src=\ref[src];id=[C.id]'>\[Order\]</A>"
			if(isAdminGhost(user))
				author += " (<A style='color:red' href='?src=\ref[src];delbyckey=[ckey(C.ckey)]'>[ckey(C.ckey)])</A>)"
			if(isAdminGhost(user) || allowed(user))
				controls +=  " <A style='color:red' href='?src=\ref[src];del=[C.id]'>\[Delete\]</A>"
			dat += {"<tr>
						<td>[author]</td>
						<td>[C.title]</td>
						<td><img src='data:image/png;base64,[icon2base64(the_painting.render_on(icon('icons/obj/paintings.dmi', "blank")))]'></td>
						<td>[C.description]</td>
						<td>
							[controls]
						</td>
					</tr>"}

		dat += "</table><br />[pagelist]"
		dat += "<hr><br/> <a href='?src=\ref[src];upload=1'>Upload new painting</a>"

	var/datum/browser/B = new /datum/browser/clean(user, "remote_gallery", "Remote Gallery Viewer")
	B.set_content(dat)
	B.open()

/obj/machinery/computer/library/checkout/remote_gallery/get_scanner_title(var/obj/machinery/libraryscanner/LS)
	return LS.cached_painting.painting_data.title || "Untitled painting"

/obj/machinery/computer/library/checkout/remote_gallery/get_scanner_author(var/obj/machinery/libraryscanner/LS)
	return LS.cached_painting.painting_data.author || "Anonymous"

/obj/machinery/computer/library/checkout/remote_gallery/get_scanner_dat(var/obj/machinery/libraryscanner/LS)
	return painting2json(LS.cached_painting.painting_data)

/obj/machinery/computer/library/checkout/remote_gallery/get_scanner_category(var/obj/machinery/libraryscanner/LS)
	return "[LS.cached_painting.painting_height]x[LS.cached_painting.painting_width]"

/obj/machinery/computer/library/checkout/remote_gallery/get_scanner_desc(var/obj/machinery/libraryscanner/LS)
	return LS.cached_painting.painting_data.description || "No description available"

/obj/machinery/computer/library/checkout/remote_gallery/has_cached_data()
	return scanner.cached_painting

/obj/machinery/computer/library/checkout/remote_gallery/make_external_book(var/datum/cachedbook/newbook)
	if(!newbook)
		return
	var/obj/item/mounted/frame/painting/custom/C = new(get_turf(src))
	C.name = "[newbook.title] by [newbook.author]"
	C.desc = newbook.description
	C.set_painting_data(json2painting(newbook.content, newbook.title, newbook.author, newbook.description))
	C.update_painting(TRUE)
	return C
