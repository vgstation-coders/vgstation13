/*** 

Adding a preference :

1)  use the script (scripts/preference_helper.py)
    this will edit "code/modules/client/preferences_savefile.dm" to add some of the necessary code for your pref to work.
    more precisely, it edits the default sql queries in the 'save_preferences_sqlite' proc. 
2)  you will still need to edit the 'load_preferences_sqlite' proc.
3)  edit the interface (code/modules/client/preferences.dm) to make sure the preference shows up when the player looks at it.
4)  add a variable in the same file (var/my_pref = default value).
5)  you can now access this pref in client.prefs.my_prefs. Always make sure that client and client.prefs exist.
6)  add a migration datum file in SS13_prefs. See below.

***/

/***

An example code for adding a preference.
Not suitable for a more advanced SQL change.

/datum/migration/sqlite/ss13_prefs/_0xx
	id = xx
	name = "Add a new preference"

/datum/migration/sqlite/ss13_prefs/_0xx/up()
	if(!hasColumn("client","my_pref"))
		return execute("ALTER TABLE `client` ADD COLUMN my_pref PREF_TYPE DEFAULT def_value")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_0xx/down()
	if(hasColumn("client","my_pref"))
		return execute("ALTER TABLE `client` DROP COLUMN my_pref")
	return TRUE

Change :
    - my_pref to the name of the variable you are adding
    - PREF_TYPE to the type of the preference (INTEGER, STRING...)
    - def_value to the default value
    - xx to the migration number.

Nota Bene :
    - adding an admin-only preference or a general pref is the same as far as SQL is concerned. What matters is that only admins can see it & edit it.
    - this code adds a preference that is "client-wide". This means that it will apply for all the player's character slots.
    - if you want your preference to only affect a character slot, use the 'players' table instead.

***/