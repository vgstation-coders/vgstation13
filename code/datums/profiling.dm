var/list/PROFILE_STORE
var/PROFILE_LINE
var/PROFILE_FILE
var/PROFILE_SLEEPCHECK
var/PROFILE_TIME

/proc/profile_show(var/user, var/sort = /proc/cmp_profile_avg_time_dsc)
	sortTim(PROFILE_STORE, sort, TRUE)

	var/list/lines = list()

	for(var/entry in PROFILE_STORE)
		var/list/data = PROFILE_STORE[entry]
		lines += "[entry] => [num2text(data[PROFILE_ITEM_TIME], 10)]ms ([data[PROFILE_ITEM_COUNT]]) (avg:[num2text(data[PROFILE_ITEM_TIME]/(data[PROFILE_ITEM_COUNT] || 1), 99)])"
	user << browse("<ol><li>[lines.Join("</li><li>")]</li></ol>", "window=\ref[user]-profiling")