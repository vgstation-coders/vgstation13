
/datum/admins/proc/player_panel_new()//The new one
	if (!usr.client.holder)
		return
	var/dat = "<html><head><title>Admin Player Panel</title></head>"

	//javascript, the part that does most of the work~
	dat += {"

		<head>
			<script type='text/javascript'>

				var locked_tabs = new Array();

				function updateSearch(){


					var filter_text = document.getElementById('filter');
					var filter = filter_text.value.toLowerCase();

					if(complete_list != null && complete_list != ""){
						var mtbl = document.getElementById("maintable_data_archive");
						mtbl.innerHTML = complete_list;
					}

					if(filter.value == ""){
						return;
					}else{

						var maintable_data = document.getElementById('maintable_data');
						var ltr = maintable_data.getElementsByTagName("tr");
						for ( var i = 0; i < ltr.length; ++i )
						{
							try{
								var tr = ltr\[i\];
								if(tr.getAttribute("id").indexOf("data") != 0){
									continue;
								}
								var ltd = tr.getElementsByTagName("td");
								var td = ltd\[0\];
								var lsearch = td.getElementsByTagName("b");
								var search = lsearch\[0\];
								//var inner_span = li.getElementsByTagName("span")\[1\] //Should only ever contain one element.
								//document.write("<p>"+search.innerText+"<br>"+filter+"<br>"+search.innerText.indexOf(filter))
								if ( search.innerText.toLowerCase().indexOf(filter) == -1 )
								{
									//document.write("a");
									//ltr.removeChild(tr);
									td.innerHTML = "";
									i--;
								}
							}catch(err) {   }
						}
					}

					var count = 0;
					var index = -1;
					var debug = document.getElementById("debug");

					locked_tabs = new Array();

				}

				function expand(id,job,name,real_name,image,key,ip,antagonist,ref){

					clearAll();

					var span = document.getElementById(id);

					body = "<table><tr><td>";

					body += "</td><td align='center'>";

					body += "<font size='2'><b>"+job+" "+name+"</b><br><b>Real name "+real_name+"</b><br><b>Played by "+key+" ("+ip+")</b></font>"

					body += "</td><td align='center'>";

					body += "<a href='?src=\ref[src];adminplayeropts="+ref+"'>PP</a> - "
					body += "<a href='?src=\ref[src];notes=show;mob="+ref+"'>N</a> - "
					body += "<a href='?_src_=vars;Vars="+ref+"'>VV</a> - "
					body += "<a href='?src=\ref[src];traitor="+ref+"'>TP</a> - "
					body += "<a href='?src=\ref[usr];priv_msg=\ref"+ref+"'>PM</a> - "
					body += "<a href='?src=\ref[src];subtlemessage="+ref+"'>SM</a> - "
					body += "<a href='?src=\ref[src];adminplayerobservejump="+ref+"'>JMP</a><br>"
					if(antagonist > 0)
						body += "<font size='2'><a href='?src=\ref[src];check_antagonist=1'><font color='red'><b>Antagonist</b></font></a></font>";

					body += "</td></tr></table>";


					span.innerHTML = body
				}

				function clearAll(){
					var spans = document.getElementsByTagName('span');
					for(var i = 0; i < spans.length; i++){
						var span = spans\[i\];

						var id = span.getAttribute("id");

						if(!(id.indexOf("item")==0))
							continue;

						var pass = 1;

						for(var j = 0; j < locked_tabs.length; j++){
							if(locked_tabs\[j\]==id){
								pass = 0;
								break;
							}
						}

						if(pass != 1)
							continue;




						span.innerHTML = "";
					}
				}

				function addToLocked(id,link_id,notice_span_id){
					var link = document.getElementById(link_id);
					var decision = link.getAttribute("name");
					if(decision == "1"){
						link.setAttribute("name","2");
					}else{
						link.setAttribute("name","1");
						removeFromLocked(id,link_id,notice_span_id);
						return;
					}

					var pass = 1;
					for(var j = 0; j < locked_tabs.length; j++){
						if(locked_tabs\[j\]==id){
							pass = 0;
							break;
						}
					}
					if(!pass)
						return;
					locked_tabs.push(id);
					var notice_span = document.getElementById(notice_span_id);
					notice_span.innerHTML = "<font color='red'>Locked</font> ";
					//link.setAttribute("onClick","attempt('"+id+"','"+link_id+"','"+notice_span_id+"');");
					//document.write("removeFromLocked('"+id+"','"+link_id+"','"+notice_span_id+"')");
					//document.write("aa - "+link.getAttribute("onClick"));
				}

				function attempt(ab){
					return ab;
				}

				function removeFromLocked(id,link_id,notice_span_id){
					//document.write("a");
					var index = 0;
					var pass = 0;
					for(var j = 0; j < locked_tabs.length; j++){
						if(locked_tabs\[j\]==id){
							pass = 1;
							index = j;
							break;
						}
					}
					if(!pass)
						return;
					locked_tabs\[index\] = "";
					var notice_span = document.getElementById(notice_span_id);
					notice_span.innerHTML = "";
					//var link = document.getElementById(link_id);
					//link.setAttribute("onClick","addToLocked('"+id+"','"+link_id+"','"+notice_span_id+"')");
				}

				function selectTextField(){
					var filter_text = document.getElementById('filter');
					filter_text.focus();
					filter_text.select();
				}

			</script>
		</head>


	"}

	//body tag start + onload and onkeypress (onkeyup) javascript event calls
	dat += "<body onload='selectTextField(); updateSearch();' onkeyup='updateSearch();'>"

	//title + search bar
	dat += {"

		<table width='560' align='center' cellspacing='0' cellpadding='5' id='maintable'>
			<tr id='title_tr'>
				<td align='center'>
					<font size='5'><b>Player panel</b></font><br>
					Hover over a line to see more information - <a href='?src=\ref[src];check_antagonist=1'>Check antagonists</a>
					<p>
				</td>
			</tr>
			<tr id='search_tr'>
				<td align='center'>
					<b>Search:</b> <input type='text' id='filter' value='' style='width:300px;'>
				</td>
			</tr>
	</table>

	"}

	//player table header
	dat += {"
		<span id='maintable_data_archive'>
		<table width='560' align='center' cellspacing='0' cellpadding='5' id='maintable_data'>"}

	var/list/mobs = sortmobs()
	var/i = 1
	for(var/mob/M in mobs)
		if(M.ckey)

			var/color = "#e6e6e6"
			if(i%2 == 0)
				color = "#f2f2f2"
			var/is_antagonist = is_special_character(M)

			var/M_job = ""

			if(isliving(M))

				if(iscarbon(M)) //Carbon stuff
					if(ishuman(M))
						M_job = M.job
					else if(isslime(M))
						M_job = "slime"
					else if(ismonkey(M))
						M_job = "Monkey"
					else if(isalien(M)) //aliens
						if(islarva(M))
							M_job = "Alien larva"
						else
							M_job = "Alien"
					else
						M_job = "Carbon-based"

				else if(issilicon(M)) //silicon
					if(isAI(M))
						M_job = "AI"
					else if(ispAI(M))
						M_job = "pAI"
					else if(isrobot(M))
						M_job = "Cyborg"
					else if(isMoMMI(M))
						M_job = "Mobile-MMI"
					else
						M_job = "Silicon-based"

				else if(isanimal(M)) //simple animals
					if(iscorgi(M))
						M_job = "Corgi"
					else if(isborer(M))
						M_job = "Borer"
					else
						M_job = "Animal"

				else
					M_job = "Living"

			else if(istype(M,/mob/new_player))
				M_job = "New player"

			else if(isobserver(M))
				M_job = "Ghost"

			M_job = replacetext(M_job, "'", "")
			M_job = replacetext(M_job, "\"", "")
			M_job = replacetext(M_job, "\\", "")

			var/M_name = M.name
			M_name = replacetext(M_name, "'", "")
			M_name = replacetext(M_name, "\"", "")
			M_name = replacetext(M_name, "\\", "")
			var/M_rname = M.real_name
			M_rname = replacetext(M_rname, "'", "")
			M_rname = replacetext(M_rname, "\"", "")
			M_rname = replacetext(M_rname, "\\", "")

			var/M_key = M.key
			M_key = replacetext(M_key, "'", "")
			M_key = replacetext(M_key, "\"", "")
			M_key = replacetext(M_key, "\\", "")

			//output for each mob
			dat += {"

				<tr id='data[i]' name='[i]' onClick="addToLocked('item[i]','data[i]','notice_span[i]')">
					<td align='center' bgcolor='[color]'>
						<span id='notice_span[i]'></span>
						<a id='link[i]'
						onmouseover='expand("item[i]","[M_job]","[M_name]","[M_rname]","--unused--","[M_key]","[M.lastKnownIP]",[is_antagonist],"\ref[M]")'
						>
						<b id='search[i]'>[M_name] - [M_rname] - [M_key] ([M_job])</b>
						</a>
						<br><span id='item[i]'></span>
					</td>
				</tr>

			"}

			i++


	//player table ending
	dat += {"
		</table>
		</span>

		<script type='text/javascript'>
			var maintable = document.getElementById("maintable_data_archive");
			var complete_list = maintable.innerHTML;
		</script>
	</body></html>
	"}

	usr << browse(dat, "window=players;size=600x480")

//The old one
/datum/admins/proc/player_panel_old()
	if (!usr.client.holder)
		return

	// AUTOFIXED BY fix_string_idiocy.py
	// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\admin\player_panel.dm:327: var/dat = "<html><head><title>Player Menu</title></head>"
	var/dat = {"<html><head><title>Player Menu</title></head>
<body><table border=1 cellspacing=5><B><tr><th>Name</th><th>Real Name</th><th>Assigned Job</th><th>Key</th><th>Options</th><th>PM</th><th>Traitor?</th></tr></B>"}
	// END AUTOFIX
	//add <th>IP:</th> to this if wanting to add back in IP checking
	//add <td>(IP: [M.lastKnownIP])</td> if you want to know their ip to the lists below
	var/list/mobs = sortmobs()

	for(var/mob/M in mobs)
		if(!M.ckey)	continue

		dat += "<tr><td>[M.name]</td>"
		if(isAI(M))
			dat += "<td>AI</td>"
		else if(isrobot(M))
			dat += "<td>Cyborg</td>"
		else if(ishuman(M))
			dat += "<td>[M.real_name]</td>"
		else if(istype(M, /mob/living/silicon/pai))
			dat += "<td>pAI</td>"
		else if(istype(M, /mob/new_player))
			dat += "<td>New Player</td>"
		else if(isobserver(M))
			dat += "<td>Ghost</td>"
		else if(ismonkey(M))
			dat += "<td>Monkey</td>"
		else if(isalien(M))
			dat += "<td>Alien</td>"
		else if(isborer(M))
			dat += "<td>Borer</td>"
		else
			dat += "<td>Unknown</td>"


		if(istype(M,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(H.mind && H.mind.assigned_role)
				dat += "<td>[H.mind.assigned_role]</td>"
		else
			dat += "<td>NA</td>"


		dat += {"<td>[(M.client ? "[M.client]" : "No client")]</td>
		<td align=center><A HREF='?src=\ref[src];adminplayeropts=\ref[M]'>X</A></td>
		<td align=center><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td>
		"}
		switch(is_special_character(M))
			if(0)
				dat += {"<td align=center><A HREF='?src=\ref[src];traitor=\ref[M]'>Traitor?</A></td>"}
			if(1)
				dat += {"<td align=center><A HREF='?src=\ref[src];traitor=\ref[M]'><font color=red>Traitor?</font></A></td>"}
			if(2)
				dat += {"<td align=center><A HREF='?src=\ref[src];traitor=\ref[M]'><font color=red><b>Traitor?</b></font></A></td>"}

	dat += "</table></body></html>"

	usr << browse(dat, "window=players;size=640x480")



/datum/admins/proc/check_antagonists()
	if (ticker && ticker.current_state >= GAME_STATE_PLAYING)
		var/dat = "<html><head><title>Round Status</title></head><body><h1><B>Round Status</B></h1>"

		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\admin\player_panel.dm:386: dat += "Current Game Mode: <B>[ticker.mode.name]</B><BR>"
		dat += {"Current Game Mode: <B>[ticker.mode.name]</B><BR>
			Round Duration: <B>[round(world.time / 36000)]:[add_zero(world.time / 600 % 60, 2)]:[world.time / 100 % 6][world.time / 100 % 10]</B><BR>
			<B>Emergency shuttle</B><BR>"}
		// END AUTOFIX
		if (!emergency_shuttle.online)
			dat += "<a href='?src=\ref[src];call_shuttle=1'>Call Shuttle</a><br>"
		else
			var/timeleft = emergency_shuttle.timeleft()
			switch(emergency_shuttle.location)
				if(0)

					// AUTOFIXED BY fix_string_idiocy.py
					// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\admin\player_panel.dm:395: dat += "ETA: <a href='?src=\ref[src];edit_shuttle_time=1'>[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]</a><BR>"
					dat += {"ETA: <a href='?src=\ref[src];edit_shuttle_time=1'>[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]</a><BR>
						<a href='?src=\ref[src];call_shuttle=2'>Send Back</a><br>"}
					// END AUTOFIX
				if(1)
					dat += "ETA: <a href='?src=\ref[src];edit_shuttle_time=1'>[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]</a><BR>"
		dat += "<a href='?src=\ref[src];delay_round_end=1'>[ticker.delay_end ? "End Round Normally" : "Delay Round End"]</a><br>"
		if(ticker.mode.syndicates.len)
			dat += "<br><table cellspacing=5><tr><td><B>Syndicates</B></td><td></td></tr>"
			for(var/datum/mind/N in ticker.mode.syndicates)
				var/mob/M = N.current
				if(M)

					// AUTOFIXED BY fix_string_idiocy.py
					// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\admin\player_panel.dm:405: dat += "<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += {"<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
						<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td></tr>"}
					// END AUTOFIX
				else
					dat += "<tr><td><i>Nuclear Operative not found!</i></td></tr>"
			dat += "</table><br><table><tr><td><B>Nuclear Disk(s)</B></td></tr>"
			for(var/obj/item/weapon/disk/nuclear/N in world)
				dat += "<tr><td>[N.name], "
				var/atom/disk_loc = N.loc
				while(!istype(disk_loc, /turf))
					if(istype(disk_loc, /mob))
						var/mob/M = disk_loc
						dat += "carried by <a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a> "
					if(istype(disk_loc, /obj))
						var/obj/O = disk_loc
						dat += "in \a [O.name] "
					disk_loc = disk_loc.loc
				dat += "in [disk_loc.loc] at ([disk_loc.x], [disk_loc.y], [disk_loc.z])</td></tr>"
			dat += "</table>"

		if(ticker.mode.head_revolutionaries.len || ticker.mode.revolutionaries.len)
			dat += "<br><table cellspacing=5><tr><td><B>Revolutionaries</B></td><td></td></tr>"
			for(var/datum/mind/N in ticker.mode.head_revolutionaries)
				var/mob/M = N.current
				if(!M)
					dat += "<tr><td><i>Head Revolutionary not found!</i></td></tr>"
				else

					// AUTOFIXED BY fix_string_idiocy.py
					// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\admin\player_panel.dm:431: dat += "<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a> <b>(Leader)</b>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += {"<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a> <b>(Leader)</b>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
						<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td></tr>"}
					// END AUTOFIX
			for(var/datum/mind/N in ticker.mode.revolutionaries)
				var/mob/M = N.current
				if(M)

					// AUTOFIXED BY fix_string_idiocy.py
					// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\admin\player_panel.dm:436: dat += "<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += {"<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
						<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td></tr>"}
					// END AUTOFIX
			dat += "</table><table cellspacing=5><tr><td><B>Target(s)</B></td><td></td><td><B>Location</B></td></tr>"
			for(var/datum/mind/N in ticker.mode.get_living_heads())
				var/mob/M = N.current
				if(M)

					// AUTOFIXED BY fix_string_idiocy.py
					// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\admin\player_panel.dm:442: dat += "<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += {"<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
						<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td>"}
					// END AUTOFIX
					var/turf/mob_loc = get_turf(M)
					dat += "<td>[mob_loc.loc]</td></tr>"
				else
					dat += "<tr><td><i>Head not found!</i></td></tr>"
			dat += "</table>"

		if(ticker.mode.changelings.len > 0)
			dat += "<br><table cellspacing=5><tr><td><B>Changelings</B></td><td></td><td></td></tr>"
			for(var/datum/mind/changeling in ticker.mode.changelings)
				var/mob/M = changeling.current
				if(M)

					// AUTOFIXED BY fix_string_idiocy.py
					// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\admin\player_panel.dm:455: dat += "<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += {"<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
						<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td>
						<td><A HREF='?src=\ref[src];traitor=\ref[M]'>Show Objective</A></td></tr>"}
					// END AUTOFIX
				else
					dat += "<tr><td><i>Changeling not found!</i></td></tr>"
			dat += "</table>"

		if(ticker.mode.wizards.len > 0)
			dat += "<br><table cellspacing=5><tr><td><B>Wizards</B></td><td></td><td></td></tr>"
			for(var/datum/mind/wizard in ticker.mode.wizards)
				var/mob/M = wizard.current
				if(M)

					// AUTOFIXED BY fix_string_idiocy.py
					// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\admin\player_panel.dm:467: dat += "<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += {"<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
						<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td>
						<td><A HREF='?src=\ref[src];traitor=\ref[M]'>Show Objective</A></td></tr>"}
					// END AUTOFIX
				else
					dat += "<tr><td><i>Wizard not found!</i></td></tr>"
			dat += "</table>"

		/* REMOVED as requested
		if(ticker.mode.raiders.len > 0)
			dat += "<br><table cellspacing=5><tr><td><B>Raiders</B></td><td></td><td></td></tr>"
			for(var/datum/mind/raider in ticker.mode.raiders)
				var/mob/M = raider.current
				if(M)

					// AUTOFIXED BY fix_string_idiocy.py
					// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\admin\player_panel.dm:479: dat += "<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += {"<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
						<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td>
						<td><A HREF='?src=\ref[src];traitor=\ref[M]'>Show Objective</A></td></tr>"}
					// END AUTOFIX
			dat += "</table>"
		*/

		/*
		if(ticker.mode.ninjas.len > 0)
			dat += "<br><table cellspacing=5><tr><td><B>Ninjas</B></td><td></td><td></td></tr>"
			for(var/datum/mind/ninja in ticker.mode.ninjas)
				var/mob/M = ninja.current
				if(M)

					// AUTOFIXED BY fix_string_idiocy.py
					// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\admin\player_panel.dm:490: dat += "<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += {"<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
						<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td>
						<td><A HREF='?src=\ref[src];traitor=\ref[M]'>Show Objective</A></td></tr>"}
					// END AUTOFIX
				else
					dat += "<tr><td><i>Ninja not found!</i></td></tr>"
			dat += "</table>"
		*/

		if(ticker.mode.cult.len)
			dat += "<br><table cellspacing=5><tr><td><B>Cultists</B></td><td></td></tr>"
			for(var/datum/mind/N in ticker.mode.cult)
				var/mob/M = N.current
				if(M)

					// AUTOFIXED BY fix_string_idiocy.py
					// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\admin\player_panel.dm:503: dat += "<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += {"<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
						<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td></tr>"}
					// END AUTOFIX
			dat += "</table>"

			var/datum/game_mode/cult/mode_ticker = ticker.mode

			var/living_crew = 0
			var/living_cultists = 0
			for(var/mob/living/L in player_list)
				if(L.stat != DEAD)
					if(L.mind in mode_ticker.cult)
						living_cultists++
					else
						if(istype(L, /mob/living/carbon))
							living_crew++

			dat += "<br>[living_cultists] living cultists."
			dat += "<br>[living_crew] living non-cultists."

			dat += "<br><B>Cult Objectives:</B>"

			for(var/obj_count=1, obj_count <= mode_ticker.objectives.len, obj_count++)
				var/explanation
				switch(mode_ticker.objectives[obj_count])
					if("convert")
						explanation = "Reach a total of [mode_ticker.convert_target] cultists.[(obj_count < mode_ticker.objectives.len) ? "<font color='green'><B>Success!</B></font>" : "(currently [mode_ticker.cult.len] cultists)"]"
					if("bloodspill")
						explanation = "Cover [mode_ticker.spilltarget] tiles in blood.[(obj_count < mode_ticker.objectives.len) ? "<font color='green'><B>Success!</B></font>" : "(currently [mode_ticker.bloody_floors.len] bloody floors)"]"
					if("sacrifice")
						explanation = "Sacrifice [mode_ticker.sacrifice_target.name], the [mode_ticker.sacrifice_target.assigned_role].[(obj_count < mode_ticker.objectives.len) ? "<font color='green'><B>Success!</B></font>" : ""]"
					if("eldergod")
						explanation = "Summon Nar-Sie.[(obj_count < mode_ticker.objectives.len) ? "<font color='green'><B>Success!</B></font>" : ""]"
					if("harvest")
						explanation = "Bring [mode_ticker.harvest_target] humans directly to Nar-Sie.[mode_ticker.bonus ? "<font color='green'><B>Success!</B></font>" : "(currently [mode_ticker.harvested] sacrifices)"]"
					if("hijack")
						explanation = "Don't let any non-cultist escape on the Shuttle alive.[mode_ticker.bonus ? "<font color='green'><B>Success!</B></font>" : ""]"
					if("massacre")
						explanation = "Massacre the crew until there are less than [mode_ticker.massacre_target] people left on the station.[mode_ticker.bonus ? "<font color='green'><B>Success!</B></font>" : ""]"

				dat += "<br><B>Objective #[obj_count]</B>: [explanation]"

		/*if(istype(ticker.mode, /datum/game_mode/anti_revolution) && ticker.mode:heads.len)	//comment out anti-revolution
			dat += "<br><table cellspacing=5><tr><td><B>Corrupt Heads</B></td><td></td></tr>"
			for(var/datum/mind/N in ticker.mode:heads)
				var/mob/M = N.current
				if(M)

					// AUTOFIXED BY fix_string_idiocy.py
					// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\admin\player_panel.dm:512: dat += "<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += {"<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
						<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td></tr>"}
					// END AUTOFIX
			dat += "</table>"
*/

		if(ticker.mode.vampires.len > 0)
			dat += "<br><table cellspacing=5><tr><td><B>Vampires</B></td><td></td><td></td></tr>"
			for(var/datum/mind/vampire in ticker.mode.vampires)
				var/mob/M = vampire.current
				if(M)

					// AUTOFIXED BY fix_string_idiocy.py
					// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\admin\player_panel.dm:521: dat += "<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += {"<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
						<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td>
						<td><A HREF='?src=\ref[src];traitor=\ref[M]'>Show Objective</A></td></tr>"}
					// END AUTOFIX
				else
					dat += "<tr><td><i>Vampire not found!</i></td></tr>"
		if(ticker.mode.traitors.len > 0)
			dat += "<br><table cellspacing=5><tr><td><B>Traitors</B></td><td></td><td></td></tr>"
			for(var/datum/mind/traitor in ticker.mode.traitors)
				var/mob/M = traitor.current
				if(M)

					// AUTOFIXED BY fix_string_idiocy.py
					// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\admin\player_panel.dm:521: dat += "<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += {"<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
						<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td>
						<td><A HREF='?src=\ref[src];traitor=\ref[M]'>Show Objective</A></td></tr>"}
					// END AUTOFIX
				else
					dat += "<tr><td><i>Traitor not found!</i></td></tr>"
			dat += "</table>"

		if(istype(ticker.mode, /datum/game_mode/blob))
			var/datum/game_mode/blob/mode = ticker.mode

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\admin\player_panel.dm:530: dat += "<br><table cellspacing=5><tr><td><B>Blob</B></td><td></td><td></td></tr>"
			dat += {"<br><table cellspacing=5><tr><td><B>Blob</B></td><td></td><td></td></tr>
				<tr><td><i>Progress: [blobs.len]/[mode.blobwincount]</i></td></tr>"}
			// END AUTOFIX
			for(var/datum/mind/blob in mode.infected_crew)
				var/mob/M = blob.current
				if(M)

					// AUTOFIXED BY fix_string_idiocy.py
					// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\admin\player_panel.dm:536: dat += "<tr><td><a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += {"<tr><td><a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
						<td><A href='?priv_msg=\ref[M]'>PM</A></td>"}
					// END AUTOFIX
				else
					dat += "<tr><td><i>Blob not found!</i></td></tr>"
			dat += "</table>"
		else if(locate(/mob/camera/blob) in world)
			dat += "<br><table cellspacing=5><tr><td><B>Blob</B></td><td></td><td></td></tr>"
			for(var/mob/M in world)
				if(istype(M, /mob/camera/blob))

					// AUTOFIXED BY fix_string_idiocy.py
					// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\admin\player_panel.dm:545: dat += "<tr><td><a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += {"<tr><td><a href='?_src_=holder;adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
						<td><A href='?priv_msg=\ref[M]'>PM</A></td>"}
					// END AUTOFIX
			dat += "</table>"

		dat += "</body></html>"
		usr << browse(dat, "window=roundstatus;size=400x500")
	else
		alert("The game hasn't started yet!")
