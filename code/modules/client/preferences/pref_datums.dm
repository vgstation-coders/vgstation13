// -- Preference datums for easy, maintainable prefs to add --

/datum/preference_setting
	var/name = "Abstract preference setting" // Actual name
	var/sql_name = "" // Name in the sql query
	var/sql_table = "abstract"

	var/enabled = FALSE    // Is it actually used in game?

	var/default_setting
	var/setting = null

	var/saved_as_string = FALSE // This is ENTIRELY from historical reasons! Do not mess with it, or risk the pref not working!
	var/datum/preferences/parent

/datum/preference_setting/New(var/datum/preferences/parent_prefs)
	parent = parent_prefs
	setting = default_setting
	return ..()

/datum/preference_setting/Destroy()
	parent = null
	return ..()

// This is to prevent admins `accidentally` breaking the database.
/datum/preference_setting/can_edit_var(var/edited_variable)
	switch (edited_variable)
		// Block varedits related to SQL
		if ("sql_table", "sql_name", "enabled", "parent", "saved_as_string")
			return
		else
			return ..()

// Change setting to new_setting
/datum/preference_setting/proc/set_setting(var/new_setting)
	new_setting = sanitize_setting(new_setting)
	setting = new_setting
	return setting

// Sanity checks
/datum/preference_setting/proc/sanitize_setting(var/new_setting)
	return new_setting ? new_setting : default_setting // Return the default setting in case of null

// Convert the raw SQL value into something byond-readable
// For HISTORICAL REASONS (forma de technical debt), a lot of stuff is saved in the DB as a string
// so usually, this means converting whatever you have from a string into a number.
// Other examples include: the job list is loaded as a json string.
/datum/preference_setting/proc/load_sql(var/sql_value)
	return sql_value

// Opposite operation.
// At the moment, this is only relevant for:
// - Player alt-titles, saved as some weird string;
// - jobs list, saved as JSON
/datum/preference_setting/proc/save_sql()
	return setting

// Handles the href changes (including things like input(), randomisation, etc)

/datum/preference_setting/proc/process_link(var/task, var/mob/user, var/list/href_list) // href_list is for extra data.
	switch (task)
		if ("random")
			randomise(user)
			return TRUE
		if ("input")
			choose_setting(user)
			return TRUE
	return FALSE // Need to do something more

// These are wrapped
/datum/preference_setting/proc/randomise(var/mob/user)

/datum/preference_setting/proc/choose_setting(var/mob/user)

// -- Abstract categories

// Binary toggles
/datum/preference_setting/toggle
	default_setting = TRUE

/datum/preference_setting/toggle/sanitize_setting(var/new_setting)
	return sanitize_integer(new_setting, 0, 1, default_setting)

/datum/preference_setting/toggle/load_sql(var/sql_value)
	if (saved_as_string)
		return text2num(sql_value)
	else
		return sql_value

/datum/preference_setting/toggle/save_sql()
	if (saved_as_string)
		return num2text(setting)
	else
		return setting

/datum/preference_setting/toggle/choose_setting(var/mob/user)
	setting = !setting
	parent.ShowChoices(user)

// Numerical values
/datum/preference_setting/numerical
	default_setting = 0
	var/min_value = 0
	var/max_value = 100

/datum/preference_setting/numerical/sanitize_setting(var/new_setting)
	return sanitize_integer(new_setting, min_value, max_value, default_setting)

/datum/preference_setting/numerical/load_sql(var/sql_value)
	if (saved_as_string)
		return text2num(sql_value)
	else
		return sql_value

/datum/preference_setting/numerical/save_sql()
	if (saved_as_string)
		return num2text(setting)
	else
		return setting

/datum/preference_setting/numerical/randomise()
	setting = rand(min_value, max_value)

// Floating point values

// Numerical values
/datum/preference_setting/float
	default_setting = 0
	var/min_value = 0
	var/max_value = 1

/datum/preference_setting/float/sanitize_setting(var/new_setting)
	if (isnum(new_setting))
		return clamp(new_setting, min_value, max_value)
	return default_setting

/datum/preference_setting/float/load_sql(var/sql_value)
	if (saved_as_string)
		return text2num(sql_value)
	else
		return sql_value

/datum/preference_setting/float/save_sql()
	if (saved_as_string)
		return num2text(setting)
	else
		return setting

// Binary flags
/datum/preference_setting/binary_flag
	default_setting = 0
	var/max_binary_value = (1 << 20)
	var/toggles = list() // The actual flag toggles this is checking against

/datum/preference_setting/binary_flag/sanitize_setting(var/new_setting)
	return sanitize_integer(new_setting, 0, max_binary_value, default_setting)

/datum/preference_setting/binary_flag/load_sql(var/sql_value)
	if (saved_as_string)
		return text2num(sql_value)
	else
		return sql_value

/datum/preference_setting/binary_flag/save_sql()
	if (saved_as_string)
		return num2text(setting)
	else
		return setting

// Strings
/datum/preference_setting/string
	default_setting = ""
	var/max_length = 0

/datum/preference_setting/string/sanitize_setting(var/new_setting)
	return sanitize_text(new_setting, default_setting)


// "Enums"
/datum/preference_setting/enum
	default_setting = null
	var/allowed_values = list(null)

/datum/preference_setting/enum/sanitize_setting(var/new_setting)
	if (!(new_setting in allowed_values))
		return default_setting
	return new_setting

/datum/preference_setting/enum/load_sql(var/sql_value)
	if (saved_as_string)
		return text2num(sql_value)
	else
		return sql_value

/datum/preference_setting/enum/save_sql()
	if (saved_as_string)
		return num2text(setting)
	else
		return setting

/datum/preference_setting/enum/string
	saved_as_string = FALSE

// -- Typically of the form:
/* list(
 *		ROLE_ONE = JOB_PREF_HIGH,
 *		ROLE_TWO = JOB_PREF_LOW,
 *	)
 *
 */

/datum/preference_setting/assoc_list_setting
	default_setting = list()
	var/allowed_values_for_list_items = list() // Alllowed values for the assoc list in the setting. First value = default.

/datum/preference_setting/assoc_list_setting/sanitize_setting(var/new_setting)
	if (!islist(new_setting))
		return default_setting
	for (var/data in new_setting)
		if (!(new_setting[data] in allowed_values_for_list_items))
			new_setting[data] = allowed_values_for_list_items[1]
	return new_setting

// -- For general lists (this is only used for alt-titles now) --

/datum/preference_setting/list_values
	default_setting = list()
