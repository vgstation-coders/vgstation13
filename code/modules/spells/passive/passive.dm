//Passive spells
//Cannot be normally cast, instead they rely on process() except for the no_clothes.dm spell

/spell/passive
    charge_type = Sp_PASSIVE
    level_max = list(Sp_TOTAL = 0) //Passive spells have no use. For the love of God, do NOT give it Sp_SPEED, it will do nothing
    charge_max = 0 //Redundancy

/spell/passive/process()
    return //Does nothing, add processes to children instead