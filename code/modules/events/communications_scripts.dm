/datum/event/communications_scripts
	oneShot			= 1

	var/obj/machinery/telecomms/server/server_to_attack
	var/list/codes = list()



/datum/event/communications_scripts/can_start(var/list/active_with_role)
	if(active_with_role["Engineering"] > 1)
		return 20
	return 0

/datum/event/communications_scripts/start()
	for(var/obj/machinery/telecomms/server/S in telecomms_list)
		if (istype(S, /obj/machinery/telecomms/server/presets/common))
			server_to_attack = S
			break

	if (!server_to_attack)
		return


	var/names_len = data_core.general.len
	var/i = 0
	var/names = ""
	for(var/datum/data/record/t in data_core.general)//Picks from crew manifest.
		i = i + 1
		if (i < names_len)
			names += t.fields["name"] +  ";"
		else
			names += t.fields["name"]
	codes+="if (mem('chosen') == null){$names=explode('[names]', ';');$chosen = pick($names); mem('chosen', $chosen); } if (mem('chosen') != null){$source = mem('chosen');}"
	codes+="$time = time();if (mem('DOORED') == null){$names=explode('[names]', ';');$chosen = pick($names);broadcast('AI door',$freq, $chosen);mem('DOORED', $time);}elseif ($time > mem('DOORED') + 3000){$names=explode('[names]', ';');$chosen = pick($names);broadcast('AI door',$freq, $chosen);mem('DOORED', $time);}"
	codes+="$time = time();if (mem('DANNED') == null){broadcast('And remember, the next message you will hear is sponsored by Discount Dan! Buy it, it IS good for you!',$freq, 'Discount Dan', 'CEO');mem('DANNED', $time);}elseif ($time > mem('DANNED') + 3000){broadcast('And remember, the next message you will hear is sponsored by Discount Dan! Buy it, it IS good for you!',$freq, 'Discount Dan', 'CEO');mem('DANNED', $time);}"
	codes+="$honorifics = vector('-kun','-sama','-senpai','-sempai','-chan','-san');  $content = replace ($content, 'l', 'w');  $content = replace ($content, 'r', 'w');  $source = $source+pick($honorifics);"
	codes+="$swap = $job; $job = $source; $source=$swap;"
	codes+="$source = 'Anonymous'; $job='Anonymous';"
	codes+="$time = time();$fakejobs = vector('Assistant','Bartender', 'Chef', 'Botanist', 'Cargo Technician', 'Shaft Miner', 'Janitor','Librarian', 'Station Engineer');$fakenames = vector('Aaron', 'Andrea', 'Brady', 'Bronte', 'Chip', 'Cleveland', 'Dakota', 'Devon','Emilia', 'Evan', 'Fabiana', 'Fernando', 'Gage', 'George', 'Hunter', 'Jamar', 'Leonard', 'Mario', 'Nick');$fakesurnames = vector('Adams','Armstrong', 'Bailey','Clark', 'Ellis', 'Isamann', 'Kellogg', 'Lowe', 'Mens', 'Noton');if (mem('ATTACKED') == null){$chosenfakename = pick($fakenames);$chosenlastname = pick($fakesurnames);$chosenfakejob = pick($fakejobs);$names=explode('[names]', ';');$chosen = pick($names);$chosen = upper($chosen);broadcast($chosen + ' KILLING ME',$freq, $chosenfakename + ' '+ $chosenlastname, $chosenfakejob);mem('ATTACKED', $time);}elseif ($time > mem('ATTACKED') + 3000){$chosenfakename = pick($fakenames);$chosenlastname = pick($fakesurnames);$chosenfakejob = pick($fakejobs);$names=explode('[names]', ';');$chosen = pick($names);$chosen = upper($chosen);broadcast($chosen + ' KILLING ME',$freq, $chosenfakename + ' '+ $chosenlastname, $chosenfakejob);mem('ATTACKED', $time);}"
	
	server_to_attack.rawcode = pick(codes)
	server_to_attack.compile(null)
	server_to_attack.autoruncode = TRUE
