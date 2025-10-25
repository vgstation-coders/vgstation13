
/proc/get_color_matrix()
	var/color_matrix
	var/choice = alert("Create the matrix by using the color wheel or entering individual values?", "New Color Matrix", "color wheel", "individual values")
	if (choice == "color wheel")
		var/red_row = input(usr, "Choose the color for the RED component (cancel to keep as default)", "New Color Matrix", null) as null|color
		var/green_row = input(usr, "Choose the color for the GREEN component (cancel to keep as default)", "New Color Matrix", null) as null|color
		var/blue_row = input(usr, "Choose the color for the BLUE component (cancel to keep as default)", "New Color Matrix", null) as null|color
		var/alpha_row = input(usr, "Choose the color for the ALPHA component (cancel to keep as default)", "New Color Matrix", null) as null|color
		var/add_row = input(usr, "Choose the color for the ADDITIONAL component (cancel to keep as default)", "New Color Matrix", null) as null|color
		color_matrix = list(red_row, green_row, blue_row, alpha_row, add_row)
	else
		var/rr = input(usr, "Choose the RED color for the RED component", "New Color Matrix", 1) as null|num
		var/rg = input(usr, "Choose the GREEN color for the RED component", "New Color Matrix", 0) as null|num
		var/rb = input(usr, "Choose the BLUE color for the RED component", "New Color Matrix", 0) as null|num
		var/ra = input(usr, "Choose the ALPHA for the RED component", "New Color Matrix", 0) as null|num
		var/gr = input(usr, "Choose the RED color for the GREEN component", "New Color Matrix", 0) as null|num
		var/gg = input(usr, "Choose the GREEN color for the GREEN component", "New Color Matrix", 1) as null|num
		var/gb = input(usr, "Choose the BLUE color for the GREEN component", "New Color Matrix", 0) as null|num
		var/ga = input(usr, "Choose the ALPHA for the GREEN component", "New Color Matrix", 0) as null|num
		var/br = input(usr, "Choose the RED color for the BLUE component", "New Color Matrix", 0) as null|num
		var/bg = input(usr, "Choose the GREEN color for the BLUE component", "New Color Matrix", 0) as null|num
		var/bb = input(usr, "Choose the BLUE color for the BLUE component", "New Color Matrix", 1) as null|num
		var/ba = input(usr, "Choose the ALPHA for the BLUE component", "New Color Matrix", 0) as null|num
		var/ar = input(usr, "Choose the RED color for the ALPHA component", "New Color Matrix", 0) as null|num
		var/ag = input(usr, "Choose the GREEN color for the ALPHA component", "New Color Matrix", 0) as null|num
		var/ab = input(usr, "Choose the BLUE color for the ALPHA component", "New Color Matrix", 0) as null|num
		var/aa = input(usr, "Choose the ALPHA for the ALPHA component", "New Color Matrix", 1) as null|num
		var/cr = input(usr, "Choose the RED color for the ADDITIONAL component", "New Color Matrix", 0) as null|num
		var/cg = input(usr, "Choose the GREEN color for the ADDITIONAL component", "New Color Matrix", 0) as null|num
		var/cb = input(usr, "Choose the BLUE color for the ADDITIONAL component", "New Color Matrix", 0) as null|num
		var/ca = input(usr, "Choose the ALPHA for the ADDITIONAL component", "New Color Matrix", 0) as null|num
		color_matrix = list(rr,rg,rb,ra, gr,gg,gb,ga, br,bg,bb,ba, ar,ag,ab,aa, cr,cg,cb,ca)
	return color_matrix
