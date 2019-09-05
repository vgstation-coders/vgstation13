// reference: /client/proc/modify_variables(var/atom/O, var/param_var_name = null, var/autodetect_class = 0)
/client/proc/debug_reagents(datum/D in world)
	set category = "Debug"
	set name = "Add Reagent"

	if(!usr.client || !usr.client.holder)
		to_chat(usr, "<span class='warning'>You need to be an administrator to access this.</span>")
		return

	if(!D)
		return
	if(istype(D, /atom))
		var/atom/A = D
		var/reagentDatum = input(usr,"Reagent","Insert Reagent","") as text|null
		if(reagentDatum)
			var/reagentAmount = input(usr, "Amount", "Insert Amount", "") as num
			var/reagentTemp = input(usr, "Temperature", "Insert Temperature (As Kelvin)", T0C+20) as num
			if(A.reagents.add_reagent(reagentDatum, reagentAmount, reagtemp = reagentTemp))
				to_chat(usr, "<span class='warning'>[reagentDatum] doesn't exist.</span>")
				return
			log_admin("[key_name(usr)] added [reagentDatum] with [reagentAmount] units to [A] at [reagentTemp]K temperature.")
			message_admins("[key_name(usr)] added [reagentDatum] with [reagentAmount] units to [A] at [reagentTemp]K temperature.")

/client/proc/debug_variables(datum/D in world)
	set category = "Debug"
	set name = "View Variables"
	//set src in world


	if(!usr.client || !usr.client.holder)
		to_chat(usr, "<span class='warning'>You need to be an administrator to access this.</span>")
		return


	var/title = ""
	var/body = list()

	if(!D)
		return
	if(istype(D, /atom))
		var/atom/A = D
		title = "[A.name] (\ref[A]) = [A.type]"

		#ifdef VARSICON
		if (A.icon)
			body += "<li>"+debug_variable("icon", new/icon(A.icon, A.icon_state, A.dir), 0)+"<\li>"
		#endif

	var/sprite

	if(istype(D,/atom))
		var/atom/AT = D
		if(AT.icon && AT.icon_state)
			sprite = 1

	title = "[D] (\ref[D]) = [D.type]"

	body += {"<body onload='selectTextField(); updateSearch()' onkeyup='updateSearch()'>
		<div align='center'><table width='100%'><tr><td width='50%'>
		<table align='center' width='100%'><tr><td>"}
	if(sprite)
		body += "[bicon(D)]</td><td>"

	body += "<div align='center'>"

	if(istype(D,/atom))
		var/atom/A = D
		if(isliving(A))
			body += "<a href='?_src_=vars;rename=\ref[D]'><b>[D]</b></a>"
			if(A.dir)
				body += "<br><font size='1'><a href='?_src_=vars;rotatedatum=\ref[D];rotatedir=left'><<</a> <a href='?_src_=vars;datumedit=\ref[D];varnameedit=dir'>[dir2text(A.dir)]</a> <a href='?_src_=vars;rotatedatum=\ref[D];rotatedir=right'>>></a></font>"
			var/mob/living/M = A
			body += "<br><font size='1'><a href='?_src_=vars;datumedit=\ref[D];varnameedit=ckey'>[M.ckey ? M.ckey : "No ckey"]</a> / <a href='?_src_=vars;datumedit=\ref[D];varnameedit=real_name'>[M.real_name ? M.real_name : "No real name"]</a></font>"
			body += {"
			<br><font size='1'>
			BRUTE:<font size='1'><a href='?_src_=vars;mobToDamage=\ref[D];adjustDamage=brute'>[M.getBruteLoss()]</a>
			FIRE:<font size='1'><a href='?_src_=vars;mobToDamage=\ref[D];adjustDamage=fire'>[M.getFireLoss()]</a>
			TOXIN:<font size='1'><a href='?_src_=vars;mobToDamage=\ref[D];adjustDamage=toxin'>[M.getToxLoss()]</a>
			OXY:<font size='1'><a href='?_src_=vars;mobToDamage=\ref[D];adjustDamage=oxygen'>[M.getOxyLoss()]</a>
			CLONE:<font size='1'><a href='?_src_=vars;mobToDamage=\ref[D];adjustDamage=clone'>[M.getCloneLoss()]</a>
			BRAIN:<font size='1'><a href='?_src_=vars;mobToDamage=\ref[D];adjustDamage=brain'>[M.getBrainLoss()]</a>
			</font>


			"}
		else
			body += "<a href='?_src_=vars;datumedit=\ref[D];varnameedit=name'><b>[D]</b></a>"
			if(A.dir)
				body += "<br><font size='1'><a href='?_src_=vars;rotatedatum=\ref[D];rotatedir=left'><<</a> <a href='?_src_=vars;datumedit=\ref[D];varnameedit=dir'>[dir2text(A.dir)]</a> <a href='?_src_=vars;rotatedatum=\ref[D];rotatedir=right'>>></a></font>"
	else
		body += "<b>[D]</b>"


	body += {"</div>
		</tr></td></table>"}
	var/formatted_type = text("[D.type]")
	if(length(formatted_type) > 25)
		var/middle_point = length(formatted_type) / 2
		var/splitpoint = findtext(formatted_type,"/",middle_point)
		if(splitpoint)
			formatted_type = "[copytext(formatted_type,1,splitpoint)]<br>[copytext(formatted_type,splitpoint)]"
		else
			formatted_type = "Type too long" //No suitable splitpoint (/) found.

	body += "<div align='center'><b><font size='1'>[formatted_type]</font></b>"

	if(src.holder && src.holder.marked_datum && src.holder.marked_datum == D)
		body += "<br><font size='1' color='red'><b>Marked Object</b></font>"


	body += {"</div>
		</div></td>
		<td width='50%'><div align='center'><a href='?_src_=vars;datumrefresh=\ref[D]'>Refresh</a>"}
	//if(ismob(D))
	//	body += "<br><a href='?_src_=vars;mob_player_panel=\ref[D]'>Show player panel</a></div></td></tr></table></div><hr>"

	body += {"	<form>
				<select name="file" size="1"
				onchange="loadPage(this.form.elements\[0\])"
				target="_parent._top"
				onmouseclick="this.focus()"
				style="background-color:#ffffff">
			"}

	body += {"	<option value>Select option</option>
				<option value> </option>
			"}


	body += "<option value='?_src_=vars;mark_object=\ref[D]'>Mark Object</option>"
	if(ismob(D))
		body += "<option value='?_src_=vars;mob_player_panel=\ref[D]'>Show player panel</option>"

	if(istype(D,/atom/movable))
		body += "<option value='?_src_=vars;teleport_here=\ref[D]'>Teleport Here</option>"

	if(istype(D,/atom))
		body += "<option value='?_src_=vars;teleport_to=\ref[D]'>Teleport To</option>"

	if(hasvar(D, "transform"))
		body += "<option value='?_src_=vars;edit_transform=\ref[D]'>Edit Transform Matrix</option>"
	if(hasvar(D, "appearance_flags"))
		body += "<option value='?_src_=vars;toggle_aliasing=\ref[D]'>Toggle Transform Aliasing</option>"

	body += "<option value='?_src_=vars;proc_call=\ref[D]'>Proc call</option>"

	body += "<option value>---</option>"

	if(ismob(D))

		body += {"<option value='?_src_=vars;give_spell=\ref[D]'>Give Spell</option>
			<option value='?_src_=vars;give_disease=\ref[D]'>Give Old Disease</option>
			<option value='?_src_=vars;give_disease2=\ref[D]'>Give New Disease</option>
			<option value='?_src_=vars;addcancer=\ref[D]'>Inflict Cancer</option>
			<option value='?_src_=vars;godmode=\ref[D]'>Toggle Godmode</option>
			<option value='?_src_=vars;build_mode=\ref[D]'>Toggle Build Mode</option>
			<option value='?_src_=vars;make_skeleton=\ref[D]'>Make 2spooky</option>
			<option value='?_src_=vars;direct_control=\ref[D]'>Assume Direct Control</option>
			<option value='?_src_=vars;drop_everything=\ref[D]'>Drop Everything</option>
			<option value='?_src_=vars;regenerateicons=\ref[D]'>Regenerate Icons</option>
			<option value='?_src_=vars;addlanguage=\ref[D]'>Add Language</option>
			<option value='?_src_=vars;remlanguage=\ref[D]'>Remove Language</option>
			<option value='?_src_=vars;make_invisible=\ref[D]'>Make invisible</option>"}
		if(ishuman(D))

			body += {"<option value>---</option>
				<option value='?_src_=vars;setmutantrace=\ref[D]'>Set Mutantrace</option>
				<option value='?_src_=vars;setspecies=\ref[D]'>Set Species</option>
				<option value='?_src_=vars;makeai=\ref[D]'>Make AI</option>
				<option value='?_src_=vars;makerobot=\ref[D]'>Make cyborg</option>
				<option value='?_src_=vars;makemonkey=\ref[D]'>Make monkey</option>
				<option value='?_src_=vars;makealien=\ref[D]'>Make alien</option>
				<option value='?_src_=vars;makeslime=\ref[D]'>Make slime</option>
				<option value='?_src_=vars;makecluwne=\ref[D]'>Make cluwne</option>"}

		body += {"<option value>---</option>
			<option value='?_src_=vars;gib=\ref[D]'>Gib</option>"}
	if(istype(D,/atom))
		body += "<option value='?_src_=vars;delete=\ref[D]'>Delete</option>"
	if(isobj(D))
		body += "<option value='?_src_=vars;delall=\ref[D]'>Delete all of type</option>"
	if(isobj(D) || ismob(D) || isturf(D))

		body += {"<option value='?_src_=vars;explode=\ref[D]'>Trigger explosion</option>
			<option value='?_src_=vars;emp=\ref[D]'>Trigger EM pulse</option>"}

	body += {"</select></form>
		</div></td></tr></table></div><hr>
		<font size='1'><b>E</b> - Edit, tries to determine the variable type by itself.<br>
		<b>C</b> - Change, asks you for the var type first.<br>
		<b>M</b> - Mass modify: changes this variable for all objects of this type.</font><br>
		<hr><table width='100%'><tr><td width='20%'><div align='center'><b>Search:</b></div></td><td width='80%'><input type='text' id='filter' name='filter_text' value='' style='width:100%;'></td></tr></table><hr>
		<ul id='vars'>"}
	var/list/names = list()
	for (var/V in D.vars)
		names += V

	names = sortList(names)

	for (var/V in names)
		body += "<li>"+debug_variable(V, D.vars[V], 0, D)+"</li>"

	body += "</ul>"
	body = jointext(body,"")

	var/html = "<html><head>"
	if (title)
		html += "<title>[title]</title>"
	html += {"<style>
body
{
	font-family: Verdana, sans-serif;
	font-size: 9pt;
}
.value
{
	font-family: "Courier New", monospace;
	font-size: 8pt;
}
</style>
<script type="text/javascript">
function updateSearch(){
	var filter_text = document.getElementById('filter');
	var filter = filter_text.value.toLowerCase();

	if(event.keyCode == 13)
		{	//Enter / return
		var vars_ol = document.getElementById('vars');
		var lis = vars_ol.getElementsByTagName("li");
		for ( var i = 0; i < lis.length; ++i )
		{
			try{
				var li = lis\[i\];
				if ( li.style.backgroundColor == "#ffee88" )
				{
					alist = lis\[i\].getElementsByTagName("a")
					if(alist.length > 0)
						{
						location.href=alist\[0\].href;
					}
				}
			}catch(err) {   }
		}
		return
	}

	if(event.keyCode == 38)
		{	//Up arrow
		var vars_ol = document.getElementById('vars');
		var lis = vars_ol.getElementsByTagName("li");
		for ( var i = 0; i < lis.length; ++i )
		{
			try{
				var li = lis\[i\];
				if ( li.style.backgroundColor == "#ffee88" )
				{
					if( (i-1) >= 0)
						{
						var li_new = lis\[i-1\];
						li.style.backgroundColor = "white";
						li_new.style.backgroundColor = "#ffee88";
						return
					}
				}
			}catch(err) {  }
		}
		return
	}

	if(event.keyCode == 40)
		{	//Down arrow
		var vars_ol = document.getElementById('vars');
		var lis = vars_ol.getElementsByTagName("li");
		for ( var i = 0; i < lis.length; ++i )
		{
			try{
				var li = lis\[i\];
				if ( li.style.backgroundColor == "#ffee88" )
				{
					if( (i+1) < lis.length)
						{
						var li_new = lis\[i+1\];
						li.style.backgroundColor = "white";
						li_new.style.backgroundColor = "#ffee88";
						return
					}
				}
			}catch(err) {  }
		}
		return
	}

	//This part here resets everything to how it was at the start so the filter is applied to the complete list. Screw efficiency, it's client-side anyway and it only looks through 200 or so variables at maximum anyway (mobs).
	if(complete_list != null && complete_list != "")
		{
		var vars_ol1 = document.getElementById("vars");
		vars_ol1.innerHTML = complete_list
	}

	if(filter.value == "")
		{
		return;
	}else{
		var vars_ol = document.getElementById('vars');
		var lis = vars_ol.getElementsByTagName("li");

		for ( var i = 0; i < lis.length; ++i )
		{
			try{
				var li = lis\[i\];
				if ( li.innerText.toLowerCase().indexOf(filter) == -1 )
				{
					vars_ol.removeChild(li);
					i--;
				}
			}catch(err) {   }
		}
	}
	var lis_new = vars_ol.getElementsByTagName("li");
	for ( var j = 0; j < lis_new.length; ++j )
	{
		var li1 = lis\[j\];
		if (j == 0)
			{
			li1.style.backgroundColor = "#ffee88";
		}else{
			li1.style.backgroundColor = "white";
		}
	}
}

function selectTextField(){
	var filter_text = document.getElementById('filter');
	filter_text.focus();
	filter_text.select();

}

function loadPage(list) {

	if(list.options\[list.selectedIndex\].value == "")
		{
		return;
	}

	location.href=list.options\[list.selectedIndex\].value;

}
</script></head>"}
	html += body

	html += {"
		<script type='text/javascript'>
			var vars_ol = document.getElementById("vars");
			var complete_list = vars_ol.innerHTML;
		</script>
	"}

	html += "</html>"

	usr << browse(html, "window=variables\ref[D];size=475x650")

/client/proc/debug_variable(name, value, level, var/datum/DA = null)
	var/html = ""

	if(DA)
		if(name == "appearance")
			html += {"
			(<a href='?_src_=vars;datumsave=\ref[DA];varnamesave=[name]'>save</a> |
			<a href='?_src_=vars;datumedit=\ref[DA];varnameedit=[name]'>load</a>) "}
		else
			html += {"
			(<a href='?_src_=vars;datumedit=\ref[DA];varnameedit=[name]'>E</a>)
			(<a href='?_src_=vars;datumchange=\ref[DA];varnamechange=[name]'>C</a>)
			(<a href='?_src_=vars;datummass=\ref[DA];varnamemass=[name]'>M</a>)
			(<a href='?_src_=vars;datumsave=\ref[DA];varnamesave=[name]'>S</a>) "}

	if (isnull(value))
		html += "[name] = <span class='value'>null</span>"

	else if (istext(value))
		html += "[name] = <span class='value'>\"[html_encode(value)]\"</span>"

	else if (isicon(value))
		#ifdef VARSICON
		html += "[name] = /icon (<span class='value'>[value]</span>) [bicon(value)]"
		#else
		html += "[name] = /icon (<span class='value'>[value]</span>)"
		#endif

	else if(istype(value, /image))
		#ifdef VARSICON
		html += "<a href='?_src_=vars;Vars=\ref[value]'>[name] \ref[value]</a> = /image (<span class='value'>[value]</span>) [bicon(value)]"
		#else
		html += "<a href='?_src_=vars;Vars=\ref[value]'>[name] \ref[value]</a> = /image (<span class='value'>[value]</span>)"
		#endif

	else if (isfile(value))
		html += "[name] = <span class='value'>'[value]'</span>"

	else if (istype(value, /datum))
		var/datum/D = value
		html += "<a href='?_src_=vars;Vars=\ref[value]'>[name] \ref[value]</a> = [D.type]"

	else if (istype(value, /client))
		var/client/C = value
		html += "<a href='?_src_=vars;Vars=\ref[value]'>[name] \ref[value]</a> = [C] [C.type]"
//
	else if (istype(value, /list))
		var/list/L = value
		html += "[name] = /list ([L.len])"

		if (L.len > 0 && !(name == "underlays" || name == "overlays" || name == "vars" || L.len > 500))
			// not sure if this is completely right...
			html += "<ul>"
			var/index = 1
			for (var/entry in L)
				if(istext(entry))
					html += "<li>"+debug_variable(entry, L[entry], level + 1)
				else
					html += "<li>"+debug_variable(index, L[index], level + 1)
				html += " <a href='?_src_=vars;delValueFromList=1;list=\ref[L];index=[index];datum=\ref[DA]'>(Delete)</a></li>"
				index++
			html += "</ul>"

	else
		html += "[name] = <span class='value'>[value]</span>"
		/*
		// Bitfield stuff
		if(round(value)==value) // Require integers.
			var/idx=0
			var/bit=0
			var/bv=0
			html += "<div class='value binary'>"
			for(var/block=0;block<8;block++)
				html += " <span class='block'>"
				for(var/i=0;i<4;i++)
					idx=(block*4)+i
					to_chat(bit=1, idx)
					bv=value & bit
					html += "<a href='?_src_=vars;togbit=[idx];var=[name];subject=\ref[DA]' title='bit [idx] ([bit])'>[bv?1:0]</a>"
				html += "</span>"
			html += "</div>"
		*/

	return html

/client/proc/debug_list(var/list/L)
	if(!istype(L))
		return

	var/html = "<h1>List Viewer</h1><i>Length: [L.len]</i>"

	if(L.len)
		html += "<hr><ul>"
		var/index = 1
		for (var/entry in L)
			if(istext(entry))
				html += "<li>"+debug_variable(entry, L[entry], 0)
				html += " <a href='?_src_=vars;delValueFromList=1;list=\ref[L];index=[index];datum=\ref[L[entry]]'>(Delete)</a></li>"
			else
				html += "<li>"+debug_variable(index, L[index], 0)
				html += " <a href='?_src_=vars;delValueFromList=1;list=\ref[L];index=[index];datum=\ref[L[index]]'>(Delete)</a></li>"
			index++
		html += "</ul>"

	usr << browse(html, "window=listedit\ref[L];size=475x650")

/client/proc/view_var_Topic(href, href_list, hsrc)
	//This should all be moved over to datum/admins/Topic() or something ~Carn
	if( (usr.client != src) || !src.holder )
		return
	if(href_list["Vars"])
		debug_variables(locate(href_list["Vars"]))
	else if(href_list["List"])
		debug_list(locate(href_list["List"]))

	//~CARN: for renaming mobs (updates their name, real_name, mind.name, their ID/PDA and datacore records).
	else if(href_list["rename"])
		if(!check_rights(R_VAREDIT))
			return

		var/mob/M = locate(href_list["rename"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		var/new_name = copytext(sanitize(input(usr,"What would you like to name this mob?","Input a name",M.real_name) as text|null),1,MAX_NAME_LEN)
		if( !new_name || !M )
			return

		message_admins("Admin [key_name_admin(usr)] renamed [key_name_admin(M)] to [new_name].")
		M.fully_replace_character_name(M.real_name,new_name)
		href_list["datumrefresh"] = href_list["rename"]

	else if(href_list["varnameedit"] && href_list["datumedit"])
		if(!check_rights(R_VAREDIT))
			return

		var/datum/D = locate(href_list["datumedit"])
		if(!istype(D,/datum) && !istype(D,/client))
			to_chat(usr, "This can only be used on instances of types /client or /datum")
			return

		var/original_name = "[D]"
		var/edited_variable = href_list["varnameedit"]
		var/new_value = variable_set(src, D, edited_variable, TRUE)
		message_admins("[key_name_admin(src)] modified [original_name]'s [edited_variable] to [html_encode(new_value)]", 1)
		world.log << "### VarEdit by [src]: [D.type] [edited_variable]=[html_encode("[new_value]")]"
	else if(href_list["togbit"])
		if(!check_rights(R_VAREDIT))
			return

		var/atom/D = locate(href_list["subject"])
		if(!istype(D,/datum) && !istype(D,/client))
			to_chat(usr, "This can only be used on instances of types /client or /datum")
			return
		if(!(href_list["var"] in D.vars))
			to_chat(usr, "Unable to find variable specified.")
			return
		var/value = D.vars[href_list["var"]]
		value ^= 1 << text2num(href_list["togbit"])
		D.vars[href_list["var"]] = value

	else if(href_list["varnamechange"] && href_list["datumchange"])
		if(!check_rights(R_VAREDIT))
			return

		var/datum/D = locate(href_list["datumchange"])
		if(!istype(D,/datum) && !istype(D,/client))
			to_chat(usr, "This can only be used on instances of types /client or /datum")
			return

		var/original_name = "[D]"
		var/edited_variable = href_list["varnamechange"]
		var/new_value = variable_set(src, D, edited_variable)
		message_admins("[key_name_admin(src)] modified [original_name]'s [edited_variable] to [html_encode(new_value)]", 1)
		world.log << "### VarEdit by [src]: [D.type] [edited_variable]=[html_encode("[new_value]")]"
	else if(href_list["varnamemass"] && href_list["datummass"])
		if(!check_rights(R_VAREDIT))
			return

		var/atom/A = locate(href_list["datummass"])
		if(!istype(A))
			to_chat(usr, "This can only be used on instances of type /atom")
			return

		cmd_mass_modify_object_variables(A.type, href_list["varnamemass"])
	else if(href_list["varnamesave"] && href_list["datumsave"])
		if(!check_rights(R_VAREDIT))
			return

		var/atom/A = locate(href_list["datumsave"])
		var/variable_name = href_list["varnamesave"]

		if(A)
			var/saved_value = A.vars[variable_name]

			if(variable_name == "appearance" && (isimage(A) || isatom(A))) //Appearance is a special case
				holder.marked_appearance = A
				to_chat(usr, "Saved [A] as your stored appearance.")
			else if(variable_contains_protected_list(variable_name)) //Checks for lists like 'vars', 'contents' and 'locs' that can't be edited
				to_chat(usr, "<span class='notice'>The list [variable_name] is protected, and can't be saved. Saving a copy of it...</span>")
				var/list/L = saved_value

				sanitize_contents_list(L)

				holder.marked_datum = L.Copy()

			else if(islist(saved_value))
				if(alert("Save this exact list, or a copy of it? A copy is independent, and changing it will not affect the original list.", "Datum saving", "Save Copy", "Save Exact") == "Save Copy")
					var/list/L = saved_value
					holder.marked_datum = L.Copy()
					to_chat(usr, "Saved a copy of the [variable_name] list as your marked datum.")
				else
					holder.marked_datum = saved_value
					to_chat(usr, "Saved the original [variable_name] list as your marked datum.")
			else
				holder.marked_datum = saved_value
				to_chat(usr, "Your marked datum is now: [holder.marked_datum]")

	else if(href_list["mob_player_panel"])
		if(!check_rights(0))
			return

		var/mob/M = locate(href_list["mob_player_panel"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		src.holder.show_player_panel(M)
		href_list["datumrefresh"] = href_list["mob_player_panel"]

	else if(href_list["give_spell"])
		if(!check_rights(R_ADMIN|R_FUN))
			return

		var/mob/M = locate(href_list["give_spell"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		src.give_spell(M)
		href_list["datumrefresh"] = href_list["give_spell"]

	else if(href_list["make_invisible"])
		if(!check_rights(R_ADMIN|R_FUN))
			return

		var/mob/M = locate(href_list["make_invisible"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		src.toggle_invisible(M)
		href_list["datumrefresh"] = href_list["make_invisible"]

	else if(href_list["give_disease"])
		if(!check_rights(R_ADMIN|R_FUN))
			return

		var/mob/M = locate(href_list["give_disease"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		src.give_disease(M)
		href_list["datumrefresh"] = href_list["give_disease"]

	else if(href_list["give_disease2"])
		if(!check_rights(R_ADMIN|R_FUN|R_DEBUG))
			return

		var/mob/living/M = locate(href_list["give_disease2"])
		if(!M.can_be_infected())
			to_chat(usr, "This mob cannot be infected.")
			return

		virus2_make_custom(src,M)
		href_list["datumrefresh"] = href_list["give_disease2"]

	else if(href_list["addcancer"])
		if(!check_rights(R_FUN))
			return

		var/mob/living/carbon/human/H = locate(href_list["addcancer"])
		if(!ishuman(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		if(alert(usr, "Are you sure you wish to inflict cancer upon [key_name(H)]?",  "Confirm Cancer?" , "Yes" , "No") != "Yes")
			return

		log_admin("[key_name(H)] was inflicted with cancer, courtesy of [key_name(usr)]")
		message_admins("[key_name(H)] was inflicted with cancer, courtesy of [key_name(usr)]")
		H.add_cancer()

	else if(href_list["godmode"])
		if(!check_rights(R_REJUVINATE))
			return

		var/mob/M = locate(href_list["godmode"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		src.cmd_admin_godmode(M)
		href_list["datumrefresh"] = href_list["godmode"]

	else if(href_list["gib"])
		if(!check_rights(0))
			return

		var/mob/M = locate(href_list["gib"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		src.cmd_admin_gib(M)

	else if(href_list["build_mode"])
		if(!check_rights(R_BUILDMODE))
			return

		var/mob/M = locate(href_list["build_mode"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		togglebuildmode(M)
		href_list["datumrefresh"] = href_list["build_mode"]

	else if(href_list["drop_everything"])
		if(!check_rights(R_DEBUG|R_ADMIN))
			return

		var/mob/M = locate(href_list["drop_everything"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		if(usr.client)
			usr.client.cmd_admin_drop_everything(M)

	else if(href_list["direct_control"])
		if(!check_rights(0))
			return

		var/mob/M = locate(href_list["direct_control"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		if(usr.client)
			usr.client.cmd_assume_direct_control(M)

	else if(href_list["make_skeleton"])
		if(!check_rights(R_FUN))
			return

		var/mob/living/carbon/human/H = locate(href_list["make_skeleton"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		H.makeSkeleton()
		href_list["datumrefresh"] = href_list["make_skeleton"]

	else if(href_list["delall"])
		if(!check_rights(R_DEBUG|R_SERVER))
			return

		var/obj/O = locate(href_list["delall"])
		if(!isobj(O))
			to_chat(usr, "This can only be used on instances of type /obj")
			return

		var/action_type = alert("Strict type ([O.type]) or type and all subtypes?",,"Strict type","Type and subtypes","Cancel")
		if(action_type == "Cancel" || !action_type)
			return

		if(alert("Are you really sure you want to delete all objects of type [O.type]?",,"Yes","No") != "Yes")
			return

		if(alert("Second confirmation required. Delete?",,"Yes","No") != "Yes")
			return

		var/O_type = O.type
		switch(action_type)
			if("Strict type")
				var/i = 0
				for(var/obj/Obj in world)
					if(Obj.type == O_type)
						i++
						qdel(Obj)
				if(!i)
					to_chat(usr, "No objects of this type exist")
					return
				log_admin("[key_name(usr)] deleted all objects of type [O_type] ([i] objects deleted) ")
				message_admins("<span class='notice'>[key_name(usr)] deleted all objects of type [O_type] ([i] objects deleted) </span>")
			if("Type and subtypes")
				var/i = 0
				for(var/obj/Obj in world)
					if(istype(Obj,O_type))
						i++
						qdel(Obj)
				if(!i)
					to_chat(usr, "No objects of this type exist")
					return
				log_admin("[key_name(usr)] deleted all objects of type or subtype of [O_type] ([i] objects deleted) ")
				message_admins("<span class='notice'>[key_name(usr)] deleted all objects of type or subtype of [O_type] ([i] objects deleted) </span>")

	else if(href_list["explode"])
		if(!check_rights(R_DEBUG|R_FUN))
			return

		var/atom/A = locate(href_list["explode"])
		if(!isobj(A) && !ismob(A) && !isturf(A))
			to_chat(usr, "This can only be done to instances of type /obj, /mob and /turf")
			return

		src.cmd_admin_explosion(A)
		href_list["datumrefresh"] = href_list["explode"]

	else if(href_list["emp"])
		if(!check_rights(R_DEBUG|R_FUN))
			return

		var/atom/A = locate(href_list["emp"])
		if(!isobj(A) && !ismob(A) && !isturf(A))
			to_chat(usr, "This can only be done to instances of type /obj, /mob and /turf")
			return

		src.cmd_admin_emp(A)
		href_list["datumrefresh"] = href_list["emp"]

	else if(href_list["mark_object"])
		if(!check_rights(0))
			return

		var/datum/D = locate(href_list["mark_object"])

		src.holder.marked_datum = D
		href_list["datumrefresh"] = href_list["mark_object"]

	else if(href_list["teleport_here"])
		if(!check_rights(0))
			return

		var/atom/movable/A = locate(href_list["teleport_here"])
		if(!istype(A))
			to_chat(usr, "This can only be done to instances of movable atoms.")
			return

		var/turf/origin = get_turf(A)
		var/turf/T = get_turf(usr)

		if(istype(A,/mob))
			var/mob/M = A
			M.teleport_to(T)
		else
			A.forceMove(T)
		log_admin("[key_name(usr)] has teleported [A] from [formatLocation(origin)] to [formatLocation(T)].")
		switch(teleport_here_pref)
			if("Flashy")
				if(flashy_level > 0)
					T.turf_animation('icons/effects/96x96.dmi',"beamin",-32,0,MOB_LAYER+1,'sound/weapons/emitter2.ogg',anim_plane = EFFECTS_PLANE)
				if(flashy_level > 1)
					for(var/mob/M in range(T,7))
						shake_camera(M, 4, 1)
				if(flashy_level > 2)
					to_chat(world, "<font size='15' color='red'><b>[uppertext(A.name)] HAS RISEN</b></font>")
			if("Stealthy")
				A.alpha = 0
				animate(A, alpha = 255, time = stealthy_level)

	else if(href_list["teleport_to"])
		if(!check_rights(0))
			return

		var/mob/user = usr
		if(!istype(user))
			return

		var/atom/A = locate(href_list["teleport_to"])
		if(!istype(A))
			to_chat(user, "This can only be done to instances of atoms.")
			return

		user.teleport_to(A)

	else if(href_list["delete"])
		if(!check_rights(0))
			return

		var/atom/movable/A = locate(href_list["delete"])
		if(!istype(A))
			to_chat(usr, "This can only be done to instances of movable atoms.")
			return

		if(ismob(A))
			var/mob/M = A
			if(M.client)
				if(alert("You sure?","Confirm","Yes","No") != "Yes")
					return

		log_admin("[key_name(usr)] deleted [A] at ([A.x],[A.y],[A.z])")
		message_admins("<span class='notice'>[key_name(usr)] deleted [A] at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[A.x];Y=[A.y];Z=[A.z]'>([A.x],[A.y],[A.z])</a></span>")
		qdel(A)

	else if(href_list["rotatedatum"])
		if(!check_rights(0))
			return

		var/atom/A = locate(href_list["rotatedatum"])
		if(!istype(A))
			to_chat(usr, "This can only be done to instances of type /atom")
			return

		switch(href_list["rotatedir"])
			if("right")
				A.dir = turn(A.dir, -45)
			if("left")
				A.dir = turn(A.dir, 45)
		href_list["datumrefresh"] = href_list["rotatedatum"]

	else if(href_list["makemonkey"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["makemonkey"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")
			return
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		holder.Topic(href, list("monkeyone"=href_list["makemonkey"]))

	else if(href_list["makerobot"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["makerobot"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")
			return
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		holder.Topic(href, list("makerobot"=href_list["makerobot"]))

	else if(href_list["makealien"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["makealien"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")
			return
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		holder.Topic(href, list("makealien"=href_list["makealien"]))

	else if(href_list["makeslime"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["makeslime"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")
			return
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		holder.Topic(href, list("makeslime"=href_list["makeslime"]))

	else if(href_list["makeai"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["makeai"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")
			return
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		holder.Topic(href, list("makeai"=href_list["makeai"]))

	else if(href_list["setmutantrace"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["setmutantrace"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		var/new_mutantrace = input("Please choose a new mutantrace","Mutantrace",null) as null|anything in list("NONE","golem","lizard","slime","plant","shadow","tajaran","skrell","vox")
		switch(new_mutantrace)
			if(null)
				return
			if("NONE")
				new_mutantrace = ""
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		if(H.dna)
			H.dna.mutantrace = new_mutantrace
			H.update_mutantrace()

	else if(href_list["setspecies"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["setspecies"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		var/new_species = input("Please choose a new species.","Species",null) as null|anything in all_species

		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		if(H.set_species(new_species, force_organs=1))
			to_chat(usr, "Set species of [H] to [H.species].")
			H.regenerate_icons()
		else
			to_chat(usr, "Failed! Something went wrong.")

	else if(href_list["addlanguage"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/H = locate(href_list["addlanguage"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob")
			return

		var/new_language = input("Please choose a language to add.","Language",null) as null|anything in all_languages

		if(!new_language)
			return

		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		if(H.add_language(new_language))
			to_chat(usr, "Added [new_language] to [H].")
		else
			to_chat(usr, "Mob already knows that language.")

	else if(href_list["remlanguage"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/H = locate(href_list["remlanguage"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob")
			return

		if(!H.languages.len)
			to_chat(usr, "This mob knows no languages.")
			return

		var/datum/language/rem_language = input("Please choose a language to remove.","Language",null) as null|anything in H.languages

		if(!rem_language)
			return

		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		if(H.remove_language(rem_language.name))
			to_chat(usr, "Removed [rem_language] from [H].")
		else
			to_chat(usr, "Mob doesn't know that language.")

	else if(href_list["regenerateicons"])
		if(!check_rights(0))
			return

		var/mob/M = locate(href_list["regenerateicons"])
		if(!ismob(M))
			to_chat(usr, "This can only be done to instances of type /mob")
			return
		M.regenerate_icons()

	else if(href_list["adjustDamage"] && href_list["mobToDamage"])
		if(!check_rights(R_DEBUG|R_ADMIN|R_FUN))
			return

		var/mob/living/L = locate(href_list["mobToDamage"])
		if(!istype(L))
			return

		var/Text = href_list["adjustDamage"]

		var/amount =  input("Deal how much damage to mob? (Negative values here heal)","Adjust [Text]loss",0) as num

		if(!L)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		switch(Text)
			if("brute")
				L.adjustBruteLoss(amount)
			if("fire")
				L.adjustFireLoss(amount)
			if("toxin")
				L.adjustToxLoss(amount)
			if("oxygen")
				L.adjustOxyLoss(amount)
			if("brain")
				L.adjustBrainLoss(amount)
			if("clone")
				L.adjustCloneLoss(amount)
			else
				to_chat(usr, "You caused an error. DEBUG: Text:[Text] Mob:[L]")
				return

		if(amount != 0)
			log_admin("[key_name(usr)] dealt [amount] amount of [Text] damage to [L] ")
			message_admins("<span class='notice'>[key_name(usr)] dealt [amount] amount of [Text] damage to [L] </span>")
			href_list["datumrefresh"] = href_list["mobToDamage"]

	else if(href_list["proc_call"])
		if(!check_rights(R_DEBUG))
			return

		var/datum/DAT = locate(href_list["proc_call"])
		if(!DAT)
			return

		callatomproc(DAT)	//Yes it could be a datum, technically but eh

	else if (href_list["edit_transform"])
		if (!check_rights(R_DEBUG))
			return

		var/datum/DAT = locate(href_list["edit_transform"])
		if (!hasvar(DAT, "transform"))
			to_chat(src, "This object does not have a transform variable to edit!")
			return

		var/matrix/M = DAT.vars["transform"] // It's like using a colon but without the colon!

		if (!istype(M))
			to_chat(src, "Transform is not set to a /matrix.")
			return

		DAT.vars["transform"] = modify_matrix_menu(M)

	else if(href_list["toggle_aliasing"])
		if(!check_rights(R_DEBUG))
			return

		var/datum/DAT = locate(href_list["toggle_aliasing"])
		if(!hasvar(DAT, "appearance_flags"))
			to_chat(src, "This object does not support appearance flags!")
			return

		var/aflags = DAT.vars["appearance_flags"]
		if(aflags & PIXEL_SCALE)
			to_chat(src, "Enabling aliasing for that astigmatism aesthetic...")
			aflags &= ~PIXEL_SCALE
		else
			to_chat(src, "Disabling aliasing for x-tra crispiness...")
			aflags |= PIXEL_SCALE

		DAT.vars["appearance_flags"] = aflags

	else if (href_list["delValueFromList"])
		if (!check_rights(R_DEBUG))
			return FALSE

		var/list/L = locate(href_list["list"])
		var/datum/D = locate(href_list["datum"])

		if (!istype(L))
			return FALSE

		var/index = text2num(href_list["index"])
		if(!index)
			if(istext(href_list["index"]))
				index = href_list["index"]
			else
				return FALSE

		if (!(index in L))
			return FALSE

		log_admin("[key_name(usr)] has deleted the value [L[index]] in the list [L][D ? ", belonging to the datum [D] of type [D.type]." : "."]")
		message_admins("[key_name(usr)] has deleted the value [L[index]] in the list [L][D ? ", belonging to the datum [D] of type [D.type]." : "."]")

		L -= L[index]
		href_list["datumrefresh"] = href_list["datum"]

	// No else, as it must be checked separatly, and at the end.
	if(href_list["datumrefresh"])
		var/datum/DAT = locate(href_list["datumrefresh"])
		if(!istype(DAT, /datum))
			return
		src.debug_variables(DAT)
