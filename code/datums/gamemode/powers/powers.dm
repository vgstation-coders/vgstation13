/datum/power
	var/name = "Power"
	var/desc = "Placeholder"
	var/helptext = ""
	var/granttext = ""
	var/passive = FALSE     //is this a spell or a passive effect?
	var/spellpath           //Path to a verb that contains the effects.
	var/cost                //the cost of this power
	var/datum/role/role
	var/obj/abstract/screen/movable/spell_master/spellmaster

	var/store_in_memory = FALSE

//basic proc for limiting powers in monkeys or whatever, override this with checks
/datum/power/proc/can_use(var/mob/user)
	return TRUE

//adding the powers to the current ones, override this with passive effects
/datum/power/proc/add_power(var/datum/role/R)
	if (!istype(R) || !R)
		return FALSE
	if(locate(type) in R.current_powers)
		to_chat(R.antag.current, "<span class='warning'>You already have that power.</span>")
		return FALSE
	if (granttext)
		to_chat(R.antag.current, "<span class = 'notice'>[granttext]</span>")
	if (store_in_memory)
		R.antag.store_memory("<font size = '1'>[granttext]</font>")
	R.current_powers += src
	role = R
	grant_spell()
	post_upgrade()
	return TRUE

//gives the user the spells if theres one associated with it, seperated from add_power in instances where spells need to be added/removed repeatedly (changelings)
/datum/power/proc/grant_spell()
	if(!role)
		return
	var/mob/M = role.antag.current
	if (!istype(role) || !istype(M))
		return FALSE
	if(!can_use(M))
		return FALSE
	if (spellpath)
		if(locate(spellpath) in role.antag.current.spell_list)
			. = FALSE
			CRASH("grant_spell called more times than needed")
		var/spell/S = new spellpath
		role.antag.current.add_spell(S, master_type = spellmaster)

/datum/power/proc/remove_spell()
	var/mob/M = role.antag.current
	if (!istype(role) || !istype(M))
		return FALSE
	if (spellpath)
		for(var/spell/targetspell in M.spell_list)
			if(targetspell.type == spellpath)
				role.antag.current.remove_spell(targetspell)
				return TRUE
		return FALSE

//For when you want to do more things with upgraded spells, such as modify spell text.
/datum/power/proc/post_upgrade()
	return

/datum/power_holder
	var/datum/role/role
	//text stuff
	var/menu_name = "Power Menu"
	var/menu_desc = "Purchase your powers here."
	var/purchase_word = "Purchase"
	var/currency = "Points"

/datum/power_holder/New(var/datum/role/newRole)
	role = newRole

/datum/power_holder/proc/PowerMenu()
	if(!role)
		return
	var/list/purchased_powers = role.current_powers
	var/dat = "<html><head><title>[menu_name]</title></head>"

	//javascript, the part that does most of the work~
	dat += {"

		<head>
			<script type='text/javascript'>

				var locked_tabs = new Array();

				function updateSearch(){


					var filter_text = document.getElementById('filter');
					var filter = filter_text.value.toLowerCase();

					if(complete_list != null && complete_list != "")
						{
						var mtbl = document.getElementById("maintable_data_archive");
						mtbl.innerHTML = complete_list;
					}

					if(filter.value == "")
						{
						return;
					}else{

						var maintable_data = document.getElementById('maintable_data');
						var ltr = maintable_data.getElementsByTagName("tr");
						for ( var i = 0; i < ltr.length; ++i )
						{
							try{
								var tr = ltr\[i\];
								if(tr.getAttribute("id").indexOf("data") != 0)
									{
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

				function expand(id,name,desc,helptext,power,ownsthis){

					clearAll();

					var span = document.getElementById(id);


					body = "<table><tr><td>";
					body +=	"</td><td align='center'>";
					body +=	"<font size='2'><b>"+desc+"</b></font> <BR>";
					body +=	"<font size='2'><font color = 'red'><b>"+helptext+"</b></font> <BR>";

					if(!ownsthis)
					{
						body += "<a href='?src=\ref[src];P="+power+"'>[purchase_word]</a>"
					}


					body += "</td><td align='center'>";
					body +=	"</td></tr></table>";

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
							if(locked_tabs\[j\]==id)
								{
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
					if(decision == "1")
						{
						link.setAttribute("name","2");
					}else{
						link.setAttribute("name","1");
						removeFromLocked(id,link_id,notice_span_id);
						return;
					}

					var pass = 1;
					for(var j = 0; j < locked_tabs.length; j++){
						if(locked_tabs\[j\]==id)
							{
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
						if(locked_tabs\[j\]==id)
							{
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
					<font size='5'><b>[menu_name]</b></font><br>
						[menu_desc]<br>
						<b>[role.powerpoints] [currency] left.</b>
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

	var/i = 1
	for(var/datum/power/P in role.available_powers)
		var/ownsthis = 0

		if(P in purchased_powers)
			ownsthis = 1

		var/color = "#e6e6e6"
		if(i%2 == 0)
			color = "#f2f2f2"


		dat += {"

			<tr id='data[i]' name='[i]' onClick="addToLocked('item[i]','data[i]','notice_span[i]')">
				<td align='center' bgcolor='[color]'>
					<span id='notice_span[i]'></span>
					<a id='link[i]'
					onmouseover='expand("item[i]","[P.name]","[P.desc]","[P.helptext]","[P]",[ownsthis])'
					>
					<b id='search[i]'>[purchase_word] [P] - Cost: [ownsthis ? "Purchased" : P.cost]</b>
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

	usr << browse(dat, "window=powers;size=900x480")




/datum/power_holder/Topic(href, href_list)
	if(href_list["P"])
		purchasePower(href_list["P"])
		PowerMenu()


/datum/power_holder/proc/purchasePower(var/power_name)
	var/datum/mind/M = role.antag
	var/datum/power/thepower = power_name

	for (var/datum/power/P in role.available_powers)
		if(P.name == power_name)
			thepower = P
			break

	if(!thepower)		//ABORT!
		return

	if(thepower in role.current_powers)
		to_chat(M.current, "<span class='warning'>You have already purchased this power.</span>")
		return

	if(role.powerpoints < thepower.cost)
		to_chat(M.current, "<span class='warning'>You cannot afford this power.</span>")
		return

	role.powerpoints -= thepower.cost
	thepower.add_power(role)





