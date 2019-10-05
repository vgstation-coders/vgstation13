var/global/datum/credits/end_credits = new

/datum/credits
	var/audio_post_delay = 10 SECONDS //Audio will start playing this many seconds before server shutdown.
	var/scroll_speed = 20 //Lower is faster.
	var/splash_time = 2000 //Time in miliseconds that each head of staff/star/production staff etc splash screen gets before displaying the next one.

	var/control = "mapwindow.credits" //if updating this, update in credits.html as well
	var/file = 'code/modules/credits/credits.html'

	var/director = "Pomf Chicken Productions"
	var/list/producers = list()
	var/star = ""
	var/list/disclaimers = list()
	var/list/datum/episode_name/episode_names = list()

	var/episode_name = ""
	var/producers_string = ""
	var/episode_string = ""
	var/cast_string = ""
	var/disclaimers_string = ""
	var/star_string = ""

	//If any of the following four are modified, the episode is considered "not a rerun".
	var/customized_name = ""
	var/customized_star = ""
	var/rare_episode_name = FALSE
	var/theme = "NT"

	var/drafted = FALSE
	var/finalized = FALSE
	var/js_args = list()

	var/audio_link = "http://ss13.moe/media/m2/source/roundend/credits/Frolic_Luciano_Michelini.mp3"
	var/list/classic_roundend_jingles = list(
		"http://ss13.moe/media/m2/source/roundend/jingleclassic/bangindonk.mp3",
		"http://ss13.moe/media/m2/source/roundend/jingleclassic/apcdestroyed.mp3"
		)
	var/list/new_roundend_jingles = list(
		"http://ss13.moe/media/m2/source/roundend/jinglenew/FTLvictory.mp3",
		"http://ss13.moe/media/m2/source/roundend/jinglenew/bayojingle.mp3",
		"http://ss13.moe/media/m2/source/roundend/jinglenew/calamitytrigger.mp3",
		"http://ss13.moe/media/m2/source/roundend/jinglenew/castlevania.mp3",
		"http://ss13.moe/media/m2/source/roundend/jinglenew/duckgame.mp3",
		"http://ss13.moe/media/m2/source/roundend/jinglenew/gameoveryeah.mp3",
		"http://ss13.moe/media/m2/source/roundend/jinglenew/marioworld.mp3",
		"http://ss13.moe/media/m2/source/roundend/jinglenew/megamanX.mp3",
		"http://ss13.moe/media/m2/source/roundend/jinglenew/rayman.mp3",
		"http://ss13.moe/media/m2/source/roundend/jinglenew/slugmissioncomplete.mp3",
		"http://ss13.moe/media/m2/source/roundend/jinglenew/soniclevelcomplete.mp3",
		"http://ss13.moe/media/m2/source/roundend/jinglenew/tfvictory.mp3"
		)

/datum/credits/proc/is_rerun()
	if(customized_name != "" || customized_star != "" || rare_episode_name == TRUE || theme != initial(theme))
		return FALSE
	else
		return TRUE

/*
 * draft():
 * Stage 1 of credit assembly. Called as soon as the rock cooks. Picks the episode names, staff, etc.
 * and allows the admins to edit those before the round ends proper and the credits roll.
 * Called by on_round_end() (on normal roundend, otherwise on_world_reboot_start() will call finalize() which will call us)
 */
/datum/credits/proc/draft(var/force = FALSE)
	if(drafted && !force)
		return
	draft_caststring() //roundend grief not included in the credits
	draft_producerstring() //so that we show admins who have logged out before the credits roll
	draft_star() //done early so admins have time to edit it
	draft_episode_names() //only selects the possibilities, doesn't pick one yet
	draft_disclaimers()
	drafted = TRUE

/*
 * finalize():
 * Stage 2 of credit assembly. Called shortly before the server shuts down.
 * Takes all of our drafted, possibly admin-edited stuff, packages it up into JS arguments, and gets it ready to ship to clients.
 * Called by on_world_reboot_start()
*/
/datum/credits/proc/finalize(var/force = FALSE)
	if(finalized && !force)
		return
	if(!drafted) //In case the world is rebooted without the round ending normally.
		draft()

	finalize_name()
	finalize_episodestring()
	finalize_starstring()
	finalize_disclaimerstring() //finalize it after the admins have had time to edit them

	var/scrollytext = episode_string + cast_string + disclaimers_string
	var/splashytext = producers_string + star_string

	js_args = list(scrollytext, splashytext, theme, scroll_speed, splash_time) //arguments for the makeCredits function back in the javascript
	finalized = TRUE

/*
 * send2clients():
 * Take our packaged JS arguments and ship them to clients, BUT DON'T PLAY YET.
 * Called by on_world_reboot_start()
*/
/datum/credits/proc/send2clients()
	if(isnull(finalized))
		stack_trace("PANIC! CREDITS ATTEMPTED TO SEND TO CLIENTS WITHOUT BEING FINALIZED!")
	for(var/client/C in clients)
		C.download_credits()

/*
 * play2clients:
 * Okay, roll'em!
 * Called by on_world_reboot_end()
*/
/datum/credits/proc/play2clients()
	if(isnull(finalized))
		stack_trace("PANIC! CREDITS ATTEMPTED TO PLAY TO CLIENTS WITHOUT BEING FINALIZED!")
	for(var/client/C in clients)
		C.play_downloaded_credits()

/*
 * on_round_end:
 * Called by /gameticker/process() (on normal roundend)
 * |-ROUND ENDS--------------------------(60 sec)--------------------------REBOOT STARTS--------(audio_post_delay sec)--------REBOOT ENDS, SERVER SHUTDOWN-|
 *     ^^^^^ we are here
 */
/datum/credits/proc/on_round_end()
	draft()
	for(var/client/C in clients)
		C.credits_audio(preload_only = TRUE) //Credits preference set to "No Reruns" should still preload, since we still don't know if the episode is a rerun. If audio time comes and the episode is a rerun, then we can start preloading the jingle instead.

/*
 * on_round_end:
 * Called by /world/Reboot(). Round may not have ended normally, so don't assume on_round_end was called!
 * |-ROUND ENDS--------------------------(60 sec)--------------------------REBOOT STARTS--------(audio_post_delay sec)--------REBOOT ENDS, SERVER SHUTDOWN-|
 *                                                                            ^^^^^ we are here
 */
/datum/credits/proc/on_world_reboot_start()
	if(!drafted) //In case the round did not end normally via smelele.
		draft()
	if(!finalized) //In case for some unknowable reason an admin vareditting the credits already proccall-finalized them?
		finalize()
	send2clients()
	for(var/client/C in clients)
		if(!C.prefs)
			continue
		switch(C.prefs.credits)
			if(CREDITS_ALWAYS)
				C.credits_audio()
			if(CREDITS_NO_RERUNS) //The time has come to decide. Shall we play credits audio, or preload the jingle audio instead?
				if(!is_rerun())
					C.credits_audio()
				else
					C.jingle_audio(preload_only = TRUE)
			if(CREDITS_NEVER)
				C.jingle_audio(preload_only = TRUE)
			else
				log_debug("[C] somehow had an unknown credits preference of: [C.prefs.credits]")

/*
 * on_world_reboot_end:
 * Called by /world/Reboot(), after sleeping for audio_post_delay seconds.
 * |-ROUND ENDS--------------------------(60 sec)--------------------------REBOOT STARTS--------(audio_post_delay sec)--------REBOOT ENDS, SERVER SHUTDOWN-|
 *                                                                                                                               ^^^^^ we are here
 */
/datum/credits/proc/on_world_reboot_end()
	play2clients()
	for(var/client/C in clients)
		C.jingle_audio()





/datum/credits/proc/finalize_name()
	if(customized_name)
		episode_name = customized_name
		return
	var/list/drafted_names = list()
	var/list/is_rare_assoc_list = list()
	for(var/datum/episode_name/N in episode_names)
		drafted_names["[N.thename]"] = N.weight
		is_rare_assoc_list["[N.thename]"] = N.rare
	episode_name = pickweight(drafted_names)
	if(is_rare_assoc_list[episode_name] == TRUE)
		rare_episode_name = TRUE

/datum/credits/proc/finalize_episodestring()
	var/season = time2text(world.realtime,"YY")
	var/episode_count_data = SSpersistence_misc.read_data(/datum/persistence_task/round_count)
	var/episodenum = episode_count_data[season]
	episode_string = "<h1><span id='episodenumber'>SEASON [season] EPISODE [episodenum]</span><br><span id='episodename'>[episode_name]</span></h1><br><div style='padding-bottom: 75px;'></div>"
	log_game("So ends [is_rerun() ? "another rerun of " : ""]SEASON [season] EPISODE [episodenum] - [episode_name]")

/datum/credits/proc/finalize_disclaimerstring()
	disclaimers_string = "<div class='disclaimers'>"
	for(var/disclaimer in disclaimers)
		disclaimers_string += "[disclaimer]"
	disclaimers_string += "</div>"

/datum/credits/proc/draft_producerstring()
	var/list/staff = list("<h1>PRODUCTION STAFF</h1><br>")
	var/list/staffjobs = list("Coffee Fetcher", "Cameraman", "Angry Yeller", "Chair Operator", "Choreographer", "Historical Consultant", "Costume Designer", "Chief Editor", "Executive Assistant", "Key Grip")
	if(!admins.len)
		staff += "<h2>PRODUCER - Alan Smithee</h2><br>"
	for(var/client/C in admins)
		if(!C.holder)
			continue
		if(C.holder.rights & (R_DEBUG|R_ADMIN))
			var/observername = ""
			if(C.mob && istype(C.mob,/mob/dead/observer))
				var/mob/dead/observer/O = C.mob
				if(O.started_as_observer)
					observername = "[O.real_name] a.k.a. "
			staff += "<h2>[uppertext(pick(staffjobs))] - [observername]'[C.key]'</h2><br>"

	producers = list("<h1>Directed by</br>[uppertext(director)]</h1>","[jointext(staff,"")]")
	for(var/head in data_core.get_manifest_json()["heads"])
		producers += "<h1>[head["rank"]]<br>[uppertext(head["name"])]</h1><br>"

	producers_string = ""
	for(var/producer in producers)
		producers_string += "[producer]%<splashbreak>" //%<splashbreak> being an arbitrary "new splash card" char we use to split this string back in the javascript

/datum/credits/proc/draft_star()
	var/mob/living/carbon/human/most_talked
	for(var/mob/living/carbon/human/H in mob_list)
		if(!H.key || H.iscorpse)
			continue
		if(!most_talked || H.talkcount > most_talked.talkcount)
			most_talked = H
	star = thebigstar(most_talked)

/datum/credits/proc/finalize_starstring()
	if(customized_star == "" && star == "")
		return
	star_string = "<h1>Starring<br>[customized_star != "" ? customized_star : star]</h1><br>%<splashbreak>" //%<splashbreak> being an arbitrary "new splash card" char we use to split this string back in the javascript

/datum/credits/proc/draft_caststring()
	cast_string = "<h1>CAST:</h1><br><h2>(in order of appearance)</h2><br>"
	cast_string += "<table class='crewtable'>"
	for(var/mob/living/carbon/human/H in mob_list)
		if(!H.key || H.iscorpse)
			continue
		cast_string += "[gender_credits(H)]"

	for(var/mob/living/silicon/S in mob_list)
		if(!S.key)
			continue
		cast_string += "[silicon_credits(S)]"

	cast_string += "</table><br>"
	cast_string += "<div class='disclaimers'>"
	var/list/corpses = list()
	for(var/mob/living/carbon/human/H in dead_mob_list)
		if(!H.key || H.iscorpse)
			continue
		else if(H.real_name)
			corpses += H.real_name
	if(corpses.len)
		var/true_story_bro = "<br>[pick("BASED ON","INSPIRED BY","A RE-ENACTMENT OF")] [pick("A TRUE STORY","REAL EVENTS","THE EVENTS ABOARD [uppertext(station_name())]")]"
		cast_string += "<h3>[true_story_bro]</h3><br>In memory of those that did not make it.<br>[english_list(corpses)].<br>"
	cast_string += "</div><br>"

/proc/gender_credits(var/mob/living/carbon/human/H)
	if(H.mind && H.mind.key)
		var/assignment = H.get_assignment(if_no_id = "", if_no_job = "")
		return "<tr><td class='actorname'>[uppertext(H.mind.key)]</td><td class='actorsegue'> as </td><td class='actorrole'>[H.real_name][assignment == "" ? "" : ", [assignment]"]</td></tr>"
	else
		var/t_him = "Them"
		if(H.gender == MALE)
			t_him = "Him"
		else if(H.gender == FEMALE)
			t_him = "Her"
		return "<tr><td class='actorname'>[uppertext(H.real_name)]</td><td class='actorsegue'> as </td><td class='actorrole'>[t_him == "Them" ? "Themselves" : "[t_him]self"]</td></tr>"

/proc/silicon_credits(var/mob/living/silicon/S)
	if(S.mind && S.mind.key)
		return "<tr><td class='actorname'>[uppertext(S.mind.key)]</td><td class='actorsegue'> as </td><td class='actorrole'>[S.name]</td></tr>"
	else
		return "<tr><td class='actorname'>[uppertext(S.name)]</td><td class='actorsegue'> as </td><td class='actorrole'>Itself</td></tr>"

/proc/thebigstar(var/star)
	if(istext(star))
		return star
	if(ismob(star))
		var/mob/M = star
		if(M.mind && M.mind.key)
			return "[uppertext(M.mind.key)] as [M.real_name]"
		else
			var/t_him = "Them"
			if(M.gender == MALE)
				t_him = "Him"
			else if(M.gender == FEMALE)
				t_him = "Her"
			return "[uppertext(M.real_name)] as [t_him == "Them" ? "Themselves" : "[t_him]self"]"
