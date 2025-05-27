/datum/data/record/money
	fields = list(
		"ckey" = "",
		"role" = "",
		"cash" = -999999,
		"shift_duration" = -999999,
		"date" = "0000-00-00",
	)

/datum/data/record/money/New(ckey, role, cash, shift_duration = worldtime2text(), date = SQLtime())
	fields["ckey"] = ckey
	fields["role"] = role
	fields["cash"] = cash
	fields["shift_duration"]= shift_duration
	fields["date"] = date
