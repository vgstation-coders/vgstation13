
// -- Add minutes to an HH:MM time and returns a new HH:MM time
// I don't think this is a very clever way to do it to tbh
/proc/add_minutes(var/init_time, var/minutes_to_add)
	var/result_time
	var/old_minutes_txt = "[init_time[length(init_time)-1]][init_time[length(init_time)]]" // last two digits
	var/new_minutes = text2num(old_minutes_txt)
	new_minutes += minutes_to_add
	var/new_minutes_txt = num2text(new_minutes)

	switch (new_minutes)
		if (0 to 9)
			var/last_digit = init_time[length(init_time)]
			result_time = init_time
			result_time = replacetext(result_time, last_digit, new_minutes_txt[1], length(result_time))
		if (10 to 59)
			result_time = init_time
			result_time = replacetext(result_time, old_minutes_txt, new_minutes_txt, length(result_time)-1)
		if (60 to 119)
			var/hour = init_time[2] // Second dgit
			hour = text2num(hour) + 1
			hour = num2text(hour)
			// Replace the hours
			result_time = init_time
			result_time = replacetext(result_time, result_time[2], hour, 2, 3)
			// Replace the minutes
			new_minutes -= 60
			new_minutes_txt = num2text(new_minutes)
			if (new_minutes < 10)
				new_minutes_txt = add_zero(new_minutes_txt, 2)
			result_time = replacetext(result_time, old_minutes_txt, new_minutes_txt, length(result_time)-1)
		if (120 to INFINITY)
			var/old_hours = "[init_time[1]][init_time[2]]" // Second dgit
			var/new_hours = text2num(old_hours) + round(new_minutes/60)
			new_hours = num2text(new_hours)
			// Replace the hours
			result_time = init_time
			result_time = replacetext(result_time, old_hours, new_hours, 1, 3)
			// Replace the minutes
			new_minutes = (new_minutes % 60)
			if (new_minutes < 10)
				new_minutes_txt = add_zero(new_minutes_txt, 2)
			new_minutes_txt = num2text(new_minutes)
			result_time = replacetext(result_time, old_minutes_txt, new_minutes_txt, length(result_time)-1)

	return result_time
