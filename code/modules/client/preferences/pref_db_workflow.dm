/*

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
---------------------------------- SQLite DB workflow                                 ----------------------------------
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

"ShiftyRail", 2025

//////////////////////////////////////////////
//                                          //
//            New player Login	            //
//                                          //
//////////////////////////////////////////////

1. client/New()

Called automatically by BYOND

2. /datum/preferences/New(client/C)

3.		init_datums()

Creates a list of /datum/preference_setting with the default values

4.      init_subsections()

Creates the subsection helpers, who handle menu generation, etc, etc.

5. try_load_preferences(Client.ckey, client.mob)

	a) Executes a DB query to check if the client is registered into the database
    "SELECT ckey FROM client WHERE ckey = [client.ckey]",

	b)
    	1) If that fails:
    	save_preferences_sqlite(ckey, user)

		Which will create and save a new entry

		2) If that works

		load_preferences_sqlite(ckey)

		Which load the `client` preferences, such as FPS, toggles, etc.

6) If preferences have been correctly loaded
	try_load_save_sqlite(Client.ckey, Client, default_slot) -- Where default_slot has been read from `client` preferences

	a) Existing character slot check :
	"SELECT player_ckey FROM players WHERE player_ckey = ? AND player_slot = ?"

	b)

		1) If that fails:
		create_character_sqlite(Client.ckey, Client, default_slot)

		Which will create a new (random body) character

		2) If that works:
		load_character_sqlite(Client.ckey, Client, default_slot)

		Which just load the character at that slot.

		3) If both queries fail:
		fallback_random_character(theckey, theclient)

		Which generates an ad-hoc random body for that round.
		If we are on this path, it is assumed that SQLite has failed.
		Saving the fallback random character may overwrite an existing.

7) Play loading sound and end of flow.

//////////////////////////////////////////////
//                                          //
//       Loading a new character slot	    //
//                                          //
//////////////////////////////////////////////

1) Click on the href with '?_src_=prefs;action=changeslot'

2) Since there is no `src`, this goes to Client/Topic()

3) Client/Topic() directs it to /datum/preferences/process_link()

4) Directly inside the decision tree, it calls:

	try_load_slot(user.ckey, user, num) -- where `num` is the slot number passed by href

	a) Exisiting character slot check:
	"SELECT player_ckey FROM players WHERE player_ckey = [ckey] AND player_slot = [num]"

	b)

		1) If that fails:
		create_character_sqlite(Client.ckey, client, num)

		Which will create a new (random body) character

		2) If that works:
		load_character_sqlite(Client.ckey, client, num)

		Which just load the character at that slot.

5) Change the default slot preference, and calls:
	save_preferences_sqlite(user, ckey)
	So that it is remembered for next time

6) Update the UI:
	ShowChoices(user)

//////////////////////////////////////////////
//                                          //
//       Updating a preference			    //
//                                          //
//////////////////////////////////////////////

1) Click on the href with '?_src_=prefs;preference=[something];task=[something]'
   OR '?_src_=prefs;action=[something]'

2) Since there is no `src`, this goes to Client/Topic()

3) Client/Topic() directs it to /datum/preferences/process_link(user, list/href_list)

4) Existing preference datums are scanned for the correct `sql_name` of /datum/preference

	a) If there's a match:
		/datum/preference_setting/process_link(user, task, list/href_list)

		-- Depending on task
			- "random" = /datum/preference_setting/randomise(user)
			- "input"  = /datum/preference_setting/choose_setting(user)

			- Special tasks : randomise hair colour, etc.

		ShowChoices(user) is either called on process_link (most of the `character` prefs)
		Or manually after (`client` prefs, which are mostly toggles)

	b) If there isn't :

		- Hardcoded tasks remaining:
			* updating records
			* changing role preferences (for antags)
			* random body

	c) Other thing : changing character preview background

5) `action` called by hrefs:
	- Save slot
	- Load slot
	- changing preference tab

6) Still not handled the link? Coding error, throw a runtime.

//////////////////////////////////////////////
//                                          //
//       Roundstart/latejoin			    //
//                                          //
//////////////////////////////////////////////

1) Roundstart:
/datum/controller/gameticker/proc/setup()

Latejoin:
/mob/new_player/AttemptLateSpawn()

They both call

2) H = mob/new_player/create_human()
This creates a client-less human mob in the famous cuck cube

3) Player is not appearance banned:

	a) /datum/preferences/copy_to(H)

	On the human `H`, the /datum/my_appearance is loaded with the values in `/datum/preferences`

	b) If the player has `Be Random Body`, /datum/my_apperance/randomise() is called

	Which randomises their appearance but respecting the `GENDER` variable in prefs.

4) Player is appearance banned:

	a) /datum/preferences/randomize_appearance_for(H)

	This scrambles their prefs. The code has an explicit provision for randomising gender in this case.

//////////////////////////////////////////////
//                                          //
//      Other notes						    //
//                                          //
//////////////////////////////////////////////

- The DB queries for `body`, `players`, and `client` are all generated at runtime.
- They are setup to take into account changes in the code structure so you don't need to modify the procs "generating" them.

- The DB queries for `client_roles` and `jobs` are (still) hardcoded and not generated at runtime.
- Further improvements will be neded to converted those to runtime-generated code.
- However, it is less critical as those tables have much less collumns.

*/
