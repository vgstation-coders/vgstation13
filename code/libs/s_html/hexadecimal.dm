/**************************************
Hexadecimal Number Manipulation
             by Jeremy "Spuzzum" Gibson
***************************************
12345678901234567890123456789012345678901234567890
These are hexadecimal manipulation procs that let
you convert between decimals and hexadecimals.
Note well that you can already convert numbers
into an HTML colour string with BYOND's rgb()
proc.  This is designed for hexadecimal, which
encompasses a larger field.

**************************************/

proc/hex2num(hex)
	//Converts a hexadecimal string (eg. "9F") into a numeral (eg. 159).

	if(!istext(hex))
		CRASH("hex2num not given a hexadecimal string argument (user error)")
		return

	var/num = 0
	var/power = 0

	for(var/i = lentext(hex), i > 0, i--)
		var/char = copytext(hex, i, i+1) //extract hexadecimal character from string
		switch(char)
			if("0")
				power++  //We don't do anything with a zero, so we'll just increase the power,
				continue // then go onto the next iteration.

			if("1","2","3","4","5","6","7","8","9")
				num += text2num(char) * (16 ** power)

			if("A","a")
				num += 10 * (16 ** power)
			if("B","b")
				num += 11 * (16 ** power)
			if("C","c")
				num += 12 * (16 ** power)
			if("D","d")
				num += 13 * (16 ** power)
			if("E","e")
				num += 14 * (16 ** power)
			if("F","f")
				num += 15 * (16 ** power)

			else
				CRASH("hex2num given non-hexadecimal string (user error)")
				return

		power++

	return(num)

//Returns the hex value of a decimal number
//len == length of returned string
//if len < 0 then the returned string will be as long as it needs to be to contain the data
//Only supports positive numbers
//if an invalid number is provided, it assumes num==0
/proc/num2hex(var/num, var/len = 2)
	if(!isnum(num))
		num = 0
	num = round(abs(num))
	. = ""
	var/i=0
	while(1)
		if(len<=0)
			if(!num)
				break
		else
			if(i>=len)
				break
		var/remainder = num/16
		num = round(remainder)
		remainder = (remainder - num) * 16
		switch(remainder)
			if(1 to 9)
				. = "[remainder]" + .
			if(10 to 15)
				. = ascii2text(remainder+55) + .
			else
				. = "0" + .
		i++
