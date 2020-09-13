/datum/migration/mysql
	var/datum/subsystem/dbcore/db
	dbms="mysql"

/datum/migration/mysql/New(var/datum/migration_controller/mysql/mc)
	..(mc)
	if(istype(mc))
		db=mc.db

/datum/migration/mysql/query(var/sql)
	var/datum/DBQuery/query = db.NewQuery(sql)
	if(!query.Execute())
		world.log << "Error in [package]#[id]: [query.ErrorMsg()]"
		qdel(query)
		return FALSE

	var/list/rows=list()
	while(query.NextRow())
		rows += list(query.item)
	qdel(query)
	return rows

/datum/migration/mysql/hasResult(var/sql)
	var/datum/DBQuery/query = db.NewQuery(sql)
	if(!query.Execute())
		world.log << "Error in [package]#[id]: [query.ErrorMsg()]"
		qdel(query)
		return FALSE

	if (query.NextRow())
		qdel(query)
		return TRUE
	qdel(query)
	return FALSE

/datum/migration/mysql/execute(var/sql)
	var/datum/DBQuery/query = db.NewQuery(sql)
	if(!query.Execute())
		world.log << "Error in [package]#[id]: [query.ErrorMsg()]"
		qdel(query)
		return FALSE
	qdel(query)
	return TRUE

/datum/migration/mysql/hasTable(var/tableName)
	return hasResult("SHOW TABLES LIKE '[tableName]'")

/datum/migration/mysql/hasColumn(var/tableName, var/columnName)
	return hasResult("SHOW COLUMNS FROM [tableName] LIKE '[columnName]'")
