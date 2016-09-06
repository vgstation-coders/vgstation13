/mob/living/simple_animal/arcane_golem
	name = "arcane golem"
	desc = "A construct created by wizards who wish to avoid human contact, but still want a companion. It's inexpensive, doesn't annoy its master and never refuses to learn a new spell."

	icon = 'icons/mob/critter.dmi'
	icon_state = "arcane_golem"

	health = 50
	maxHealth = 50

	speak = list("Servio.", "Magister?", "Ego enim arcana.")
	speak_emote = list("vocalizes")

	speak_chance = 0.25

	var/mob/master

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

/mob/living/simple_animal/arcane_golem/Life()
	..()

	if(istype(master))
		if(master.isDead() || isnull(master.loc))
			master = null
			Die()
			return

		//Alive - follow the master
		if(!isDead())
			step_to(src, master, 1)

/mob/living/simple_animal/arcane_golem/Die()
	..()

	//Punish the master by putting all of his spells on cooldown
	if(ismob(master))
		to_chat(master, "<span class='warning'>As your golem is destroyed, your mana leaks away!</span>")
		for(var/spell/S in master.spell_list)
			if(S.charge_type == Sp_RECHARGE)
				S.charge_counter = 0

	visible_message("<span class='warning'>\The <b>[src]</b> shatters into pieces!</span>")
	qdel(src)
