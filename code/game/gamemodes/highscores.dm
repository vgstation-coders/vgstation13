/datum/record/money
	var/ckey
	var/role
	var/cash
	var/shift_duration
	var/date

/datum/record/money/New(ckey, role, cash, shift_duration = worldtime2text(), date = SQLtime())
	src.ckey = ckey
	src.role = role
	src.cash = cash
	src.shift_duration = shift_duration
	src.date = date
