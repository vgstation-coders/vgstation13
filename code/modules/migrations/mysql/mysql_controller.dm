var/global/datum/migration_controller/mysql/migration_controller_mysql = null

/datum/migration_controller/mysql
	id="mysql"
	var/datum/subsystem/database/db

/datum/migration_controller/mysql/setup()
	if(!SSdatabase || !istype(SSdatabase) || !SSdatabase.IsConnected())
		warning("Something wrong with SSdatabase.")
		return FALSE
	var/datum/DBQuery/Q = SSdatabase.NewQuery()
	if(!Q)
		warning("Something wrong with SSdatabase.NewQuery()")
		return FALSE
	Q.Close()
	//testing("MySQL is okay")
	db = SSdatabase
	return TRUE

/datum/migration_controller/mysql/createMigrationTable()
	var/tableSQL = {"
CREATE TABLE IF NOT EXISTS [TABLE_NAME] (
	pkgID VARCHAR(15) PRIMARY KEY, -- Implies NOT NULL
	version INT(11) NOT NULL
);
	"}
	execute(tableSQL)

/datum/migration_controller/mysql/query(var/sql)
	var/datum/DBQuery/query = execute(sql)

	var/list/rows=list()
	while(query.NextRow())
		rows[++rows.len] = query.item.Copy()

	return rows

/datum/migration_controller/mysql/hasResult(var/sql)
	var/datum/DBQuery/query = execute(sql)

	if (query.NextRow())
		return TRUE
	return FALSE

/datum/migration_controller/mysql/execute(var/sql)
	var/datum/DBQuery/query = db.NewQuery(sql)
	query.Execute()
	return query

/datum/migration_controller/mysql/hasTable(var/tableName)
	return hasResult("SHOW TABLES LIKE '[tableName]")
