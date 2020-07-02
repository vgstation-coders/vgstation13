/datum/unit_test/names/start()
	//casing
	assert_eq(reject_bad_name("John Smith", 0, 20), "John Smith")
	assert_eq(reject_bad_name("john smith", 0, 20), "John Smith")
	assert_eq(reject_bad_name("JOHN SMITH", 0, 20), "JOHN SMITH")
	assert_eq(reject_bad_name("JoHn sMiTh", 0, 20), "JoHn SMiTh")

	//whitespace
	assert_eq(reject_bad_name("John  Smith", 0, 20), "John Smith")
	assert_eq(reject_bad_name("John   Smith", 0, 20), "John Smith")
	assert_eq(reject_bad_name("   John   ", 0, 20), "John")
	assert_eq(reject_bad_name("   John   Smith   ", 0, 20), "John Smith")

	//common punctuation
	assert_eq(reject_bad_name("john'smith", 0, 20), "John'smith")
	assert_eq(reject_bad_name("john-smith", 0, 20), "John-smith")
	assert_eq(reject_bad_name("john.smith", 0, 20), "John.smith")
	assert_eq(reject_bad_name("Jane A. Doe-D'Smith", 0, 20), "Jane A. Doe-D'Smith")

	//digits and specials
	assert_eq(reject_bad_name("1john smith1", 0, 20), "John Smith")
	assert_eq(reject_bad_name("1john smith1", 1, 20), "John Smith1")
	assert_eq(reject_bad_name("1john#smith1", 0, 20), "Johnsmith")
	assert_eq(reject_bad_name("1john#smith1", 1, 20), "John#smith1")
	assert_eq(reject_bad_name(" 1john#smith1", 0, 20), "Johnsmith")
	assert_eq(reject_bad_name(" 1john#smith1", 1, 20), "John#smith1")
	assert_eq(reject_bad_name("john#smith", 0, 20), "Johnsmith")
	assert_eq(reject_bad_name("john#smith", 1, 20), "John#smith")
	assert_eq(reject_bad_name("#john smith", 0, 20), "John Smith")
	assert_eq(reject_bad_name("#john smith", 1, 20), "John Smith")
	assert_eq(reject_bad_name("Robot #69", 0, 20), "Robot")
	assert_eq(reject_bad_name("Robot #69", 1, 20), "Robot #69")

	//length
	assert_eq(reject_bad_name("John Smith", 0, 0), null)
	assert_eq(reject_bad_name("n", 0, 3), null)
	assert_eq(reject_bad_name("#", 1, 3), null)
	assert_eq(reject_bad_name("##", 1, 3), null)
	assert_eq(reject_bad_name("John", 0, 3), null)
	assert_eq(reject_bad_name("Joh ", 0, 3), null)
	assert_eq(reject_bad_name("John", 0, 4), "John")
	assert_eq(reject_bad_name("A...", 0, 20), null)
	assert_eq(reject_bad_name("A###", 1, 20), null)
	assert_eq(reject_bad_name("John John John John John J", 0, 26), "John John John John John J")
	assert_eq(reject_bad_name("John John John John John Jo", 0, 26), null)

	//grief names
	assert_eq(reject_bad_name("space", 0, 20), null)
	assert_eq(reject_bad_name("  wall  ", 0, 20), null)
	assert_eq(reject_bad_name("Unknown", 0, 20), null)

	//invalid chars
	assert_eq(reject_bad_name("john^smith", 1, 20), null)
	assert_eq(reject_bad_name("john\[\]smith", 0, 20), null)
	assert_eq(reject_bad_name("john()smith", 1, 20), null)
	assert_eq(reject_bad_name("john_smith", 1, 20), null)

	//cat on keyboard
	assert_eq(reject_bad_name("  94vtw8myn0 vt 4ewy98", 0, 26), "Vtwmyn Vt Ewy")
	assert_eq(reject_bad_name("  94vtw8myn0 vt 4ewy98", 1, 26), "Vtw8myn0 Vt 4ewy98")
	assert_eq(reject_bad_name("39yc42m8mc-0uy29t3qx", 0, 26), "Ycmmc-uytqx")
	assert_eq(reject_bad_name("39yc42m8mc-0uy29t3qx", 1, 26), "Yc42m8mc-0uy29t3qx")
	assert_eq(reject_bad_name("d\]vamf\[-svmMU(V#$m\]3", 0, 26), null)
	assert_eq(reject_bad_name("d\]vamf\[-svmMU(V#$m\]3", 1, 26), null)