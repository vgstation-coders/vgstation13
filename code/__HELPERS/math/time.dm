
// -- Add minutes to an HH:MM time and returns a new HH:MM time
/proc/add_minutes(var/init_time, var/minutes_to_add)
	var/list/split_time = splittext(init_time, ":")
	var/hours = text2num(split_time[1])
	var/minutes = text2num(split_time[2])
	minutes += minutes_to_add
	hours += round(minutes / 60)
	minutes %= 60
	hours %= 24
	return "[hours]:[num2text(minutes, 2, 10)]" //Uses the radix form of num2text() even though the radix is 10 so we can use the minimum digits feature
