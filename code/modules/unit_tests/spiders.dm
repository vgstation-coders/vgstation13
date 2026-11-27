/datum/unit_test/spiders/start()

// Silicon and other bloodless mobs are cocooned but do not feed the spider.
/datum/unit_test/spiders/bloodless_cocoon_does_not_feed/start()
	var/turf/centre = locate(100, 100, 1)
	var/mob/living/simple_animal/hostile/giant_spider/nurse/queen_spider/queen = new(centre)
	var/fed_before = queen.fed

	var/mob/living/silicon/robot/borg = new(centre)
	var/obj/effect/spider/cocoon/borg_cocoon = new(centre)
	assert_eq(queen.can_digest(borg), FALSE)
	assert_eq(queen.cocoon_mob(borg, borg_cocoon), FALSE)
	assert_eq(borg.loc, borg_cocoon)

	// Golems have NO_BLOOD, so they wrap but do not feed.
	var/mob/living/carbon/human/golem = new(centre, "Golem")
	var/obj/effect/spider/cocoon/golem_cocoon = new(centre)
	assert_eq(queen.can_digest(golem), FALSE)
	assert_eq(queen.cocoon_mob(golem, golem_cocoon), FALSE)
	assert_eq(golem.loc, golem_cocoon)

	// Mechanical simple animals are not blooded either.
	var/mob/living/simple_animal/hostile/hivebot/hivebot = new(centre)
	var/obj/effect/spider/cocoon/hivebot_cocoon = new(centre)
	assert_eq(queen.can_digest(hivebot), FALSE)
	assert_eq(queen.cocoon_mob(hivebot, hivebot_cocoon), FALSE)
	assert_eq(hivebot.loc, hivebot_cocoon)

	// No meat, no viscera.
	var/mob/living/simple_animal/hostile/mining_drone/mining_drone = new(centre)
	assert_eq(queen.can_digest(mining_drone), FALSE)

	assert_eq(queen.fed, fed_before)

	qdel(borg)
	qdel(golem)
	qdel(hivebot)
	qdel(mining_drone)
	qdel(borg_cocoon)
	qdel(golem_cocoon)
	qdel(hivebot_cocoon)
	qdel(queen)

// Bloodless flesh still feeds the spider: the enzyme digests meat, not blood.
/datum/unit_test/spiders/bloodless_flesh_cocoon_feeds/start()
	var/turf/centre = locate(100, 100, 1)
	var/mob/living/simple_animal/hostile/giant_spider/nurse/queen_spider/queen = new(centre)
	var/mob/living/carbon/human/plasmaman = new(centre, "Plasmaman")
	var/obj/effect/spider/cocoon/cocoon = new(centre)

	var/fed_before = queen.fed
	assert_eq((plasmaman.species.anatomy_flags & NO_BLOOD), NO_BLOOD)
	assert_eq(queen.can_digest(plasmaman), TRUE)
	assert_eq(queen.cocoon_mob(plasmaman, cocoon), TRUE)
	assert_eq(queen.fed, fed_before + 1)
	assert_eq(plasmaman.loc, cocoon)

	qdel(plasmaman)
	qdel(cocoon)
	qdel(queen)

// Organic mobs still feed the spider.
/datum/unit_test/spiders/organic_cocoon_feeds/start()
	var/turf/centre = locate(100, 100, 1)
	var/mob/living/simple_animal/hostile/giant_spider/nurse/queen_spider/queen = new(centre)
	var/mob/living/carbon/monkey/monkey = new(centre)
	var/obj/effect/spider/cocoon/cocoon = new(centre)

	var/fed_before = queen.fed
	assert_eq(queen.can_digest(monkey), TRUE)
	assert_eq(queen.cocoon_mob(monkey, cocoon), TRUE)
	assert_eq(queen.fed, fed_before + 1)
	assert_eq(monkey.loc, cocoon)

	qdel(monkey)
	qdel(cocoon)
	qdel(queen)
