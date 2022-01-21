/obj/item/weapon/cartridge/medical
	name = "\improper Med-U Cartridge"
	icon_state = "cart-m"
	access_medical = 1
	radio_type = /obj/item/radio/integrated/signal/bot/medbot
	starting_apps = list(
        /datum/pda_app/cart/medical_records,
        /datum/pda_app/cart/scanner/medical,
    )

/datum/pda_app/cart/medical_records
    name = "Medical Records"
    desc = "Access the crew medical records history."
    category = "Medical Functions"
    icon = "pda_medical"
    var/mode = 0
    var/datum/data/record/active1 = null //General
    var/datum/data/record/active2 = null //Medical

/datum/pda_app/cart/medical_records/get_dat()
    var/menu = ""
    switch(mode)
        if (0) //This thing only displays a single screen so it's hard to really get the sub-menu stuff working.
            menu = "<h4><span class='pda_icon pda_medical'></span> Medical Record List</h4>"
            if(!isnull(data_core.general))
                for (var/datum/data/record/R in sortRecord(data_core.general))
                    menu += "<a href='byond://?src=\ref[src];Medical Records=\ref[R]'>[R.fields["id"]]: [R.fields["name"]]<br>"
            menu += "<br>"
        if(1)
            menu = "<h4><span class='pda_icon pda_medical'></span> Medical Record</h4>"

            if (istype(active1, /datum/data/record) && (active1 in data_core.general))

                menu += {"Name: [active1.fields["name"]] ID: [active1.fields["id"]]<br>
                    Sex: [active1.fields["sex"]]<br>
                    Age: [active1.fields["age"]]<br>
                    Rank: [active1.fields["rank"]]<br>
                    Fingerprint: [active1.fields["fingerprint"]]<br>
                    Physical Status: [active1.fields["p_stat"]]<br>
                    Mental Status: [active1.fields["m_stat"]]<br>"}
            else
                menu += "<b>Record Lost!</b><br>"


            menu += {"<br>
                <h4><span class='pda_icon pda_medical'></span> Medical Data</h4>"}
            if (istype(active2, /datum/data/record) && (active2 in data_core.medical))

                menu += {"Blood Type: [active2.fields["b_type"]]<br><br>
                    Minor Disabilities: [active2.fields["mi_dis"]]<br>
                    Details: [active2.fields["mi_dis_d"]]<br><br>
                    Major Disabilities: [active2.fields["ma_dis"]]<br>
                    Details: [active2.fields["ma_dis_d"]]<br><br>
                    Allergies: [active2.fields["alg"]]<br>
                    Details: [active2.fields["alg_d"]]<br><br>
                    Current Diseases: [active2.fields["cdi"]]<br>
                    Details: [active2.fields["cdi_d"]]<br><br>
                    Important Notes: [active2.fields["notes"]]<br>"}
            else
                menu += "<b>Record Lost!</b><br>"

            menu += "<br>"
    return menu

/datum/pda_app/cart/medical_records/Topic(href, href_list)
    if(href_list["Medical Records"])
        var/datum/data/record/R = locate(href_list["Medical Records"])
        var/datum/data/record/M = locate(href_list["Medical Records"])
        mode = 1
        if (R in data_core.general)
            for (var/datum/data/record/E in data_core.medical)
                if ((E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
                    M = E
                    break
            active1 = R
            active2 = M

/datum/pda_app/cart/scanner/medical
    base_name = "Medical Scanner"
    desc = "Use a built in health analyzer."
    category = "Medical Functions"
    icon = "pda_scanner"
    app_scanmode = SCANMODE_MEDICAL

/obj/item/weapon/cartridge/chemistry
	name = "\improper ChemWhiz Cartridge"
	icon_state = "cart-chem"
	starting_apps = list(/datum/pda_app/cart/scanner/reagent)

/datum/pda_app/cart/scanner/reagent
    base_name = "Reagent Scanner"
    desc = "Use a built in reagent scanner."
    category = "Utilities"
    icon = "pda_reagent"
    app_scanmode = SCANMODE_REAGENT