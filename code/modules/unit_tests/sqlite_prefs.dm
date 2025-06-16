#include "sqlite_unit_testing_procs.dm"

// -- Targets the empty file
/datum/preferences/unit_testing
	// We only target the baseline DB so that we cant EVER even accidentally touch player prefs
    db = ("players2_empty.sqlite")

// -- Only inits its datums
/datum/preferences/unit_testing/New()
	// This will automatically put players2_emtpy to the latest schema
	migration_controller_sqlite = new ("players2_empty.sqlite", "players2_empty.sqlite")
	init_datums()

/datum/preferences/unit_testing/proc/clear_db()
	var/database/query/clear_db = new
	clear_db.Add("DELETE FROM client;")
	ASSERT(clear_db.Execute(db))
	clear_db.Add("DELETE FROM players;")
	ASSERT(clear_db.Execute(db))
	clear_db.Add("DELETE FROM body;")
	ASSERT(clear_db.Execute(db))
	clear_db.Add("DELETE FROM limbs;")
	ASSERT(clear_db.Execute(db))
	clear_db.Add("DELETE FROM client_roles;")
	ASSERT(clear_db.Execute(db))
	clear_db.Add("DELETE FROM jobs;")
	ASSERT(clear_db.Execute(db))

/datum/preferences/unit_testing/Del()
	world.log << "Clearing dummy database..."
	clear_db()
	return ..()

/datum/unit_test/sqlite/start()
	var/datum/preferences/unit_testing/test_prefs = new
	test_prefs.clear_db()
	var/dummy_ckey = "this_ckey_does_not_exist" // this dummy ckey contains _, so we won't ever accidentally collide with an existing ckey
	var/DEFAULT_SLOT = 1

	// TEST 1: loading a pref for a new client
	var/load_pref = test_prefs.try_load_preferences(dummy_ckey, null) // Here, `null` simply means there is no mob to recieve confirmation messages
	ASSERT(load_pref)

	// TEST 2: creating a new save
	test_prefs.try_load_save_sqlite(dummy_ckey, null, DEFAULT_SLOT)

	// TEST 3: client table is not empty
	var/database/query/check_existing = new
	check_existing.Add("SELECT ckey FROM client WHERE ckey = ?", dummy_ckey)
	check_existing.Execute(test_prefs.db)
	ASSERT(check_existing.NextRow()) // there should be at least one row.

	// TEST 4: loading a character works
	test_prefs.load_character_sqlite(dummy_ckey, null, DEFAULT_SLOT)

	// TEST 5: Checking vars:
	for (var/setting in typesof(/datum/preference_setting))
		var/datum/preference_setting/setting_type = setting
		if (!initial(setting_type.enabled))
			continue

		// Cannot check for default values since body is randomised at first entry.
		var/datum/preference_setting/test = test_prefs.get_pref_datum(setting)
		ASSERT(test.enabled)

	// TEST 6: Checking if vars are equal to what is on the database
	// For client
	var/list/database_data = test_prefs.execute_load_pref_query(dummy_ckey)
	for (var/setting in typesof(/datum/preference_setting))
		var/datum/preference_setting/setting_type = setting
		if (!initial(setting_type.enabled))
			continue
		if (initial(setting_type.sql_table) != "client")
			continue

		var/datum/preference_setting/the_setting = test_prefs.get_pref_datum(setting_type)
		var/db_value = the_setting.load_sql(database_data[the_setting.sql_name])
		var/actual_value = the_setting.setting

		if(!(actual_value ~= db_value))
			stack_trace("equal values test failed. actual_value = [actual_value], db_value = [db_value]. Setting type = [setting]")

	// For body
	var/sql = test_prefs.load_character_sql()
	var/database/query/check_body = new
	var/list/preference_list = list()
	// Ckey and slot and ?/joker parameters in the prepared query
	check_body.Add(sql, dummy_ckey, DEFAULT_SLOT)

	if(check_body.Execute(test_prefs.db))
		while(check_body.NextRow())
			var/list/row = check_body.GetRowData()
			for(var/a in row)
				preference_list[a] = row[a]

	for (var/setting in typesof(/datum/preference_setting))
		var/datum/preference_setting/setting_type = setting
		if (!initial(setting_type.enabled))
			continue
		if (initial(setting_type.sql_table) == "client")
			continue

		var/datum/preference_setting/the_setting = test_prefs.get_pref_datum(setting_type)
		var/db_value = the_setting.load_sql(preference_list[the_setting.sql_name])
		var/actual_value = the_setting.setting

		if(!(actual_value ~= db_value))
			stack_trace("equal values test failed. actual_value = [islist(actual_value) ? json_encode(actual_value) : actual_value], db_value = [islist(db_value) ? json_encode(db_value) : db_value]. Setting type = [setting]")

	// 7. Change some vars (will be checked later)

	for (var/type, setting in test_prefs.preference_settings_client)
		var/datum/preference_setting/the_setting = setting
		the_setting.simulate_setting_change()

	for (var/type, setting in test_prefs.preference_settings_character)
		var/datum/preference_setting/the_setting = setting
		the_setting.simulate_setting_change()

	test_prefs.save_character_sqlite(dummy_ckey, null, DEFAULT_SLOT)
	test_prefs.save_preferences_sqlite(null, dummy_ckey)

	// 8. Creating a new slot on an unoccupied slot

	var/NEW_SLOT = 2
	var/load_new_slot_result = test_prefs.try_load_slot(dummy_ckey, null, NEW_SLOT)
	ASSERT(load_new_slot_result)

	// Simulate default slot change
	var/datum/preference_setting/slot_pref = test_prefs.get_pref_datum(/datum/preference_setting/numerical/default_slot)
	slot_pref.setting = NEW_SLOT
	test_prefs.slot = NEW_SLOT
	test_prefs.save_preferences_sqlite(null, dummy_ckey)

	// 9. Has the defaultslot being changed?
	var/database/query/check_slot = new
	var/list/data_default_slot = list()
	check_slot.Add("SELECT [slot_pref.sql_name] FROM [slot_pref.sql_table] WHERE ckey = ?", dummy_ckey)
	ASSERT(check_slot.Execute(test_prefs.db))
	while(check_slot.NextRow())
		var/list/row = check_slot.GetRowData()
		for(var/a in row)
			data_default_slot[a] = row[a]

	var/def_slot_db_result = slot_pref.load_sql(data_default_slot[slot_pref.sql_name])
	assert_eq(slot_pref.setting, def_slot_db_result)

	// 10. Load back initial slot
	var/load_initial_slot_result = test_prefs.try_load_slot(dummy_ckey, null, DEFAULT_SLOT)
	ASSERT(load_initial_slot_result)

	// 11. Check if we get our vars back

	for (var/type, setting in test_prefs.preference_settings_client)
		var/datum/preference_setting/the_setting = setting
		the_setting.check_setting_change()

	for (var/type, setting in test_prefs.preference_settings_character)
		var/datum/preference_setting/the_setting = setting
		the_setting.check_setting_change()

	del test_prefs // Explicitly clears out the DB
