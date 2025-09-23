CharacterCondition = {
    dead=2,
    mounted=4,
    inCombat=26,
    casting=27,
    occupiedInEvent=31,
    occupiedInQuestEvent=32,
    occupied=33,
    boundByDuty34=34,
    occupiedMateriaExtractionAndRepair=39,
    betweenAreas=45,
    jumping48=48,
    jumping61=61,
    occupiedSummoningBell=50,
    betweenAreasForDuty=51,
    boundByDuty56=56,
    mounting57=57,
    mounting64=64,
    beingMoved=70,
    flying=77
}

ClassList =
{
    gla = { classId=1, className="Gladiator", isMelee=true, isTank=true },
    pgl = { classId=2, className="Pugilist", isMelee=true, isTank=false },
    mrd = { classId=3, className="Marauder", isMelee=true, isTank=true },
    lnc = { classId=4, className="Lancer", isMelee=true, isTank=false },
    arc = { classId=5, className="Archer", isMelee=false, isTank=false },
    cnj = { classId=6, className="Conjurer", isMelee=false, isTank=false },
    thm = { classId=7, className="Thaumaturge", isMelee=false, isTank=false },
    pld = { classId=19, className="Paladin", isMelee=true, isTank=true },
    mnk = { classId=20, className="Monk", isMelee=true, isTank=false },
    war = { classId=21, className="Warrior", isMelee=true, isTank=true },
    drg = { classId=22, className="Dragoon", isMelee=true, isTank=false },
    brd = { classId=23, className="Bard", isMelee=false, isTank=false },
    whm = { classId=24, className="White Mage", isMelee=false, isTank=false },
    blm = { classId=25, className="Black Mage", isMelee=false, isTank=false },
    acn = { classId=26, className="Arcanist", isMelee=false, isTank=false },
    smn = { classId=27, className="Summoner", isMelee=false, isTank=false },
    sch = { classId=28, className="Scholar", isMelee=false, isTank=false },
    rog = { classId=29, className="Rogue", isMelee=false, isTank=false },
    nin = { classId=30, className="Ninja", isMelee=true, isTank=false },
    mch = { classId=31, className="Machinist", isMelee=false, isTank=false},
    drk = { classId=32, className="Dark Knight", isMelee=true, isTank=true },
    ast = { classId=33, className="Astrologian", isMelee=false, isTank=false },
    sam = { classId=34, className="Samurai", isMelee=true, isTank=false },
    rdm = { classId=35, className="Red Mage", isMelee=false, isTank=false },
    blu = { classId=36, className="Blue Mage", isMelee=false, isTank=false },
    gnb = { classId=37, className="Gunbreaker", isMelee=true, isTank=true },
    dnc = { classId=38, className="Dancer", isMelee=false, isTank=false },
    rpr = { classId=39, className="Reaper", isMelee=true, isTank=false },
    sge = { classId=40, className="Sage", isMelee=false, isTank=false },
    vpr = { classId=41, className="Viper", isMelee=true, isTank=false },
    pct = { classId=42, className="Pictomancer", isMelee=false, isTank=false }
}

BicolorExchangeData =
{
    {
        shopKeepName = "Gadfrid",
        zoneName = "Old Sharlayan",
        zoneId = 962,
        aetheryteName = "Old Sharlayan",
        position=Vector3(78, 5, -37),
        shopItems =
        {
            { itemName = "Bicolor Gemstone Voucher", itemIndex = 8, price = 100 },
            { itemName = "Ovibos Milk", itemIndex = 9, price = 2 },
            { itemName = "Hamsa Tenderloin", itemIndex = 10, price = 2 },
            { itemName = "Yakow Chuck", itemIndex = 11, price = 2 },
            { itemName = "Bird of Elpis Breast", itemIndex = 12, price = 2 },
            { itemName = "Egg of Elpis", itemIndex = 13, price = 2 },
            { itemName = "Amra", itemIndex = 14, price = 2 },
            { itemName = "Dynamis Crystal", itemIndex = 15, price = 2 },
            { itemName = "Almasty Fur", itemIndex = 16, price = 2 },
            { itemName = "Gaja Hide", itemIndex = 17, price = 2 },
            { itemName = "Luncheon Toad Skin", itemIndex = 18, price = 2 },
            { itemName = "Saiga Hide", itemIndex = 19, price = 2 },
            { itemName = "Kumbhira Skin", itemIndex = 20, price = 2 },
            { itemName = "Ophiotauros Hide", itemIndex = 21, price = 2 },
            { itemName = "Berkanan Sap", itemIndex = 22, price = 2 },
            { itemName = "Dynamite Ash", itemIndex = 23, price = 2 },
            { itemName = "Lunatender Blossom", itemIndex = 24, price = 2 },
            { itemName = "Mousse Flesh", itemIndex = 25, price = 2 },
            { itemName = "Petalouda Scales", itemIndex = 26, price = 2 },
        }
    },
    {
        shopKeepName = "Beryl",
        zoneName = "Solution Nine",
        zoneId = 1186,
        aetheryteName = "Solution Nine",
        position=Vector3(-198.47, 0.92, -6.95),
        miniAethernet = {
            name = "Nexus Arcade",
            position=Vector3(-157.74, 0.29, 17.43)
        },
        shopItems =
        {
            { itemName = "Turali Bicolor Gemstone Voucher", itemIndex = 6, price = 100 },
            { itemName = "Alpaca Fillet", itemIndex = 7, price = 3 },
            { itemName = "Swampmonk Thigh", itemIndex = 8, price = 3 },
            { itemName = "Rroneek Chuck", itemIndex = 9, price = 3 },
            { itemName = "Megamaguey Pineapple", itemIndex = 10, price = 3 },
            { itemName = "Branchbearer Fruit", itemIndex = 11, price = 3 },
            { itemName = "Nopalitender Tuna", itemIndex = 12, price = 3 },
            { itemName = "Rroneek Fleece", itemIndex = 13, price = 3 },
            { itemName = "Silver Lobo Hide", itemIndex = 14, price = 3 },
            { itemName = "Hammerhead Crocodile Skin", itemIndex = 15, price = 3 },
            { itemName = "Br'aax Hide", itemIndex = 16, price = 3 },
            { itemName = "Gomphotherium Skin", itemIndex = 17, price = 3 },
            { itemName = "Gargantua Hide", itemIndex = 18, price = 3 },
            { itemName = "Ty'aitya Wingblade", itemIndex = 19, price = 3 },
            { itemName = "Poison Frog Secretions", itemIndex = 20, price = 3 },
            { itemName = "Alexandrian Axe Beak Wing", itemIndex = 21, price = 3 },
            { itemName = "Lesser Apollyon Shell", itemIndex = 22, price = 3 },
            { itemName = "Tumbleclaw Weeds", itemIndex = 23, price = 3 },
        }
    },
    {
        shopKeepName = "Rral Wuruq",
        zoneName = "Yak T'el",
        zoneId = 1189,
        aetheryteName = "Iq Br'aax",
        position=Vector3(-381, 23, -436),
        shopItems =
        {
            { itemName = "Ut'ohmu Siderite", itemIndex = 8, price = 600 }
        }
    }
}

FatesData = {
    {
        zoneName = "Middle La Noscea",
        zoneId = 134,
        fatesList = {
            collectionsFates= {},
            otherNpcFates= {
                { fateName="Thwack-a-Mole" , npcName="Troubled Tiller" },
                { fateName="Yellow-bellied Greenbacks", npcName="Yellowjacket Drill Sergeant"},
                { fateName="The Orange Boxes", npcName="Farmer in Need" }
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Lower La Noscea",
        zoneId = 135,
        fatesList = {
            collectionsFates= {},
            otherNpcFates= {
                { fateName="Away in a Bilge Hold" , npcName="Yellowjacket Veteran" },
                { fateName="Fight the Flower", npcName="Furious Farmer" }
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Central Thanalan",
        zoneId = 141,
        fatesList = {
            collectionsFates= {
                { fateName="Let them Eat Cactus", npcName="Hungry Hobbledehoy"},
            },
            otherNpcFates= {
                { fateName="A Few Arrows Short of a Quiver" , npcName="Crestfallen Merchant" },
                { fateName="Wrecked Rats", npcName="Coffer & Coffin Heavy" },
                { fateName="Something to Prove", npcName="Cowardly Challenger" }
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Eastern Thanalan",
        zoneId = 145,
        fatesList = {
            collectionsFates= {},
            otherNpcFates= {
                { fateName="Attack on Highbridge: Denouement" , npcName="Brass Blade" }
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Southern Thanalan",
        zoneId = 146,
        fatesList = {
            collectionsFates= {},
            otherNpcFates= {},
            fatesWithContinuations = {},
            blacklistedFates= {}
        },
        flying = false
    },
    {
        zoneName = "Outer La Noscea",
        zoneId = 180,
        fatesList = {
            collectionsFates= {},
            otherNpcFates= {},
            fatesWithContinuations = {},
            blacklistedFates= {}
        },
        flying = false
    },
    {
        zoneName = "Coerthas Central Highlands",
        zoneId = 155,
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {},
            fatesWithContinuations = {},
            specialFates = {
                "He Taketh It with His Eyes" --behemoth
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Coerthas Western Highlands",
        zoneId = 397,
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {},
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Mor Dhona",
        zoneId = 156,
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {},
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "The Sea of Clouds",
        zoneId = 401,
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {},
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Azys Lla",
        zoneId = 402,
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {},
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "The Dravanian Forelands",
        zoneId = 398,
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {},
            fatesWithContinuations = {},
            specialFates = {
                "Coeurls Chase Boys Chase Coeurls" --coeurlregina
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName = "The Dravanian Hinterlands",
        zoneId=399,
        tpZoneId = 478,
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {},
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "The Churning Mists",
        zoneId=400,
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {},
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "The Fringes",
        zoneId = 612,
        fatesList= {
            collectionsFates= {
                { fateName="Showing The Recruits What For", npcName="Storm Commander Bharbennsyn" },
                { fateName="Get Sharp", npcName="M Tribe Youth" },
            },
            otherNpcFates= {
                { fateName="The Mail Must Get Through", npcName="Storm Herald" },
                { fateName="The Antlion's Share", npcName="M Tribe Ranger" },
                { fateName="Double Dhara", npcName="Resistence Fighter" },
                { fateName="Keeping the Peace", npcName="Resistence Fighter" }
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "The Peaks",
        zoneId = 620,
        fatesList= {
            collectionsFates= {
                { fateName="Fletching Returns", npcName="Sorry Sutler" }
            },
            otherNpcFates= {
                { fateName="Resist, Die, Repeat", npcName="Wounded Fighter" },
                { fateName="And the Bandits Played On", npcName="Frightened Villager" },
                { fateName="Forget-me-not", npcName="Coldhearth Resident" },
                { fateName="Of Mice and Men", npcName="Furious Farmer" }
            },
            fatesWithContinuations = {},
            blacklistedFates= {
                "The Magitek Is Back", --escort
                "A New Leaf" --escort
            }
        }
    },
    {
        zoneName = "The Lochs",
        zoneId = 621,
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {},
            fatesWithContinuations = {},
            specialFates = {
                "A Horse Outside" --ixion
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName = "The Ruby Sea",
        zoneId = 613,
        fatesList= {
            collectionsFates= {
                { fateName="Treasure Island", npcName="Blue Avenger" },
                { fateName="The Coral High Ground", npcName="Busy Beachcomber" }
            },
            otherNpcFates= {
                { fateName="Another One Bites The Dust", npcName="Pirate Youth" },
                { fateName="Ray Band", npcName="Wounded Confederate" },
                { fateName="Bilge-hold Jin", npcName="Green Confederate" }
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Yanxia",
        zoneId = 614,
        fatesList= {
            collectionsFates= {
                { fateName="Rice and Shine", npcName="Flabbergasted Farmwife" },
                { fateName="More to Offer", npcName="Ginko" }
            },
            otherNpcFates= {
                { fateName="Freedom Flies", npcName="Kinko" },
                { fateName="A Tisket, a Tasket", npcName="Gyogun of the Most Bountiful Catch" }
            },
            specialFates = {
                "Foxy Lady" --foxyyy
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "The Azim Steppe",
        zoneId = 622,
        fatesList= {
            collectionsFates= {
                { fateName="The Dataqi Chronicles: Duty", npcName="Altani" }
            },
            otherNpcFates= {
                { fateName="Rock for Food", npcName="Oroniri Youth" },
                { fateName="Killing Dzo", npcName="Olkund Dzotamer" },
                { fateName="They Shall Not Want", npcName="Mol Shepherd" },
                { fateName="A Good Day to Die", npcName="Qestiri Merchant" }
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Lakeland",
        zoneId = 813,
        fatesList= {
            collectionsFates= {
                { fateName="Pick-up Sticks", npcName="Crystarium Botanist" }
            },
            otherNpcFates= {
                { fateName="Subtle Nightshade", npcName="Artless Dodger" },
                { fateName="Economic Peril", npcName="Jobb Guard" }
            },
            fatesWithContinuations = {
                "Behind Anemone Lines"
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Kholusia",
        zoneId = 814,
        fatesList= {
            collectionsFates= {
                { fateName="Ironbeard Builders - Rebuilt", npcName="Tholl Engineer" }
            },
            otherNpcFates= {},
            fatesWithContinuations = {},
            specialFates = {
                "A Finale Most Formidable" --formidable
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Amh Araeng",
        zoneId = 815,
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {},
            fatesWithContinuations = {},
            blacklistedFates= {
                "Tolba No. 1", -- pathing is really bad to enemies
            }
        }
    },
    {
        zoneName = "Il Mheg",
        zoneId = 816,
        fatesList= {
            collectionsFates= {
                { fateName="Twice Upon a Time", npcName="Nectar-seeking Pixie" }
            },
            otherNpcFates= {
                { fateName="Once Upon a Time", npcName="Nectar-seeking Pixie" },
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "The Rak'tika Greatwood",
        zoneId = 817,
        fatesList= {
            collectionsFates= {
                { fateName="Picking up the Pieces", npcName="Night's Blessed Missionary" },
                { fateName="Pluck of the Draw", npcName="Myalna Bowsing" },
                { fateName="Monkeying Around", npcName="Fanow Warder" }
            },
            otherNpcFates= {
                { fateName="Queen of the Harpies", npcName="Fanow Huntress" },
                { fateName="Shot Through the Hart", npcName="Qilmet Redspear" },
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "The Tempest",
        zoneId = 818,
        fatesList= {
            collectionsFates= {
                { fateName="Low Coral Fiber", npcName="Teushs Ooan" },
                { fateName="Pearls Apart", npcName="Ondo Spearfisher" }
            },
            otherNpcFates= {
                { fateName="Where has the Dagon", npcName="Teushs Ooan" },
                { fateName="Ondo of Blood", npcName="Teushs Ooan" },
                { fateName="Lookin' Back on the Track", npcName="Teushs Ooan" },
            },
            fatesWithContinuations = {},
            specialFates = {
                "The Head, the Tail, the Whole Damned Thing" --archaeotania
            },
            blacklistedFates= {
                "Coral Support", -- escort fate
                "The Seashells He Sells", -- escort fate
            }
        }
    },
    {
        zoneName = "Labyrinthos",
        zoneId = 956,
        fatesList= {
            collectionsFates= {
                { fateName="Sheaves on the Wind", npcName="Vexed Researcher" },
                { fateName="Moisture Farming", npcName="Well-moisturized Researcher" }
            },
            otherNpcFates= {},
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Thavnair",
        zoneId = 957,
        fatesList= {
            collectionsFates= {
                { fateName="Full Petal Alchemist: Perilous Pickings", npcName="Sajabaht" }
            },
            otherNpcFates= {},
            specialFates = {
                "Devout Pilgrims vs. Daivadipa" --daveeeeee
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Garlemald",
        zoneId = 958,
        fatesList= {
            collectionsFates= {
                { fateName="Parts Unknown", npcName="Displaced Engineer" }
            },
            otherNpcFates= {
                { fateName="Artificial Malevolence: 15 Minutes to Comply", npcName="Keltlona" },
                { fateName="Artificial Malevolence: The Drone Army", npcName="Ebrelnaux" },
                { fateName="Artificial Malevolence: Unmanned Aerial Villains", npcName="Keltlona" },
                { fateName="Amazing Crates", npcName="Hardy Refugee" }
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Mare Lamentorum",
        zoneId = 959,
        fatesList= {
            collectionsFates= {
                { fateName="What a Thrill", npcName="Thrillingway" }
            },
            otherNpcFates= {
                { fateName="Lepus Lamentorum: Dynamite Disaster", npcName="Warringway" },
                { fateName="Lepus Lamentorum: Cleaner Catastrophe", npcName="Fallingway" },
            },
            fatesWithContinuations = {},
            blacklistedFates= {
                "Hunger Strikes", --really bad line of sight with rocks, get stuck not doing anything quite often
            }
        }
    },
    {
        zoneName = "Ultima Thule",
        zoneId = 960,
        fatesList= {
            collectionsFates= {
                { fateName="Omicron Recall: Comms Expansion", npcName="N-6205" }
            },
            otherNpcFates= {
                { fateName="Wings of Glory", npcName="Ahl Ein's Kin" },
                { fateName="Omicron Recall: Secure Connection", npcName="N-6205"},
                { fateName="Only Just Begun", npcName="Myhk Nehr" }
            },
            specialFates = {
                "Omicron Recall: Killing Order" --chi
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Elpis",
        zoneId = 961,
        fatesList= {
            collectionsFates= {
                { fateName="So Sorry, Sokles", npcName="Flora Overseer" }
            },
            otherNpcFates= {
                { fateName="Grand Designs: Unknown Execution", npcName="Meletos the Inscrutable" },
                { fateName="Grand Designs: Aigokeros", npcName="Meletos the Inscrutable" },
                { fateName="Nature's Staunch Protector", npcName="Monoceros Monitor" },
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Urqopacha",
        zoneId = 1187,
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {
                { fateName="Pasture Expiration Date", npcName="Tsivli Stoutstrider" },
                { fateName="Gust Stop Already", npcName="Mourning Yok Huy" },
                { fateName="Lay Off the Horns", npcName="Yok Huy Vigilkeeper" },
                { fateName="Birds Up", npcName="Coffee Farmer" },
                { fateName="Salty Showdown", npcName="Chirwagur Sabreur" },
                { fateName="Fire Suppression", npcName="Tsivli Stoutstrider"} ,
                { fateName="Panaq Attack", npcName="Pelupelu Peddler" }
            },
            fatesWithContinuations = {
                { fateName="Salty Showdown", continuationIsBoss=true }
            },
            blacklistedFates= {
                "Young Volcanoes",
                "Wolf Parade", -- multiple Pelupelu Peddler npcs, rng whether it tries to talk to the right one
                "Panaq Attack" -- multiple Pelupleu Peddler npcs
            }
        }
    },
    {
        zoneName="Kozama'uka",
        zoneId=1188,
        fatesList={
            collectionsFates={
                { fateName="Borne on the Backs of Burrowers", npcName="Moblin Forager" },
                { fateName="Combing the Area", npcName="Hanuhanu Combmaker" },

            },
            otherNpcFates= {
                { fateName="There's Always a Bigger Beast", npcName="Hanuhanu Angler" },
                { fateName="Toucalibri at That Game", npcName="Hanuhanu Windscryer" },
                { fateName="Putting the Fun in Fungicide", npcName="Bagnobrok Craftythoughts" },
                { fateName="Reeds in Need", npcName="Hanuhanu Farmer" },
                { fateName="Tax Dodging", npcName="Pelupelu Peddler" },

            },
            fatesWithContinuations = {},
            blacklistedFates= {
                "Mole Patrol",
                "Tax Dodging" -- multiple Pelupelu Peddlers
            }
        }
    },
    {
        zoneName="Yak T'el",
        zoneId=1189,
        fatesList= {
            collectionsFates= {
                { fateName="Escape Shroom", npcName="Hoobigo Forager" }
            },
            otherNpcFates= {
                --{ fateName=, npcName="Xbr'aal Hunter" }, 2 npcs names same thing....
                { fateName="La Selva se lo Llevó", npcName="Xbr'aal Hunter" },
                { fateName="Stabbing Gutward", npcName="Doppro Spearbrother" },
                { fateName="Porting is Such Sweet Sorrow", npcName="Hoobigo Porter" }
                -- { fateName="Stick it to the Mantis", npcName="Xbr'aal Sentry" }, -- 2 npcs named same thing.....
            },
            fatesWithContinuations = {
                "Stabbing Gutward"
            },
            blacklistedFates= {
                "The Departed"
            }
        }
    },
    {
        zoneName="Shaaloani",
        zoneId=1190,
        fatesList= {
            collectionsFates= {
                { fateName="Gonna Have Me Some Fur", npcName="Tonawawtan Trapper" },
                { fateName="The Serpentlord Sires", npcName="Br'uk Vaw of the Setting Sun" }
            },
            otherNpcFates= {
                { fateName="The Dead Never Die", npcName="Tonawawtan Worker" }, --22 boss
                { fateName="Ain't What I Herd", npcName="Hhetsarro Herder" }, --23 normal
                { fateName="Helms off to the Bull", npcName="Hhetsarro Herder" }, --22 boss
                { fateName="A Raptor Runs Through It", npcName="Hhetsarro Angler" }, --24 tower defense
                { fateName="The Serpentlord Suffers", npcName="Br'uk Vaw of the Setting Sun" },
                { fateName="That's Me and the Porter", npcName="Pelupelu Peddler" },
            },
            fatesWithContinuations = {
                "The Serpentlord Sires"
            },
            specialFates = {
                "The Serpentlord Seethes" -- big snake fate
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName="Heritage Found",
        zoneId=1191,
        fatesList= {
            collectionsFates= {
                { fateName="License to Dill", npcName="Tonawawtan Provider" },
                { fateName="When It's So Salvage", npcName="Refined Reforger" }
            },
            otherNpcFates= {
                { fateName="It's Super Defective", npcName="Novice Hunter" },
                { fateName="Running of the Katobleps", npcName="Novice Hunter" },
                { fateName="Ware the Wolves", npcName="Imperiled Hunter" },
                { fateName="Domo Arigato", npcName="Perplexed Reforger" },
                { fateName="Old Stampeding Grounds", npcName="Driftdowns Reforger" },
                { fateName="Pulling the Wool", npcName="Panicked Courier" }
            },
            fatesWithContinuations = {
                { fateName="Domo Arigato", continuationIsBoss=false }
            },
            blacklistedFates= {
                "When It's So Salvage", -- terrain is terrible
                "print('I hate snakes')"
            }
        }
    },
    {
        zoneName="Living Memory",
        zoneId=1192,
        fatesList= {
            collectionsFates= {
                { fateName="Seeds of Tomorrow", npcName="Unlost Sentry GX" },
                { fateName="Scattered Memories", npcName="Unlost Sentry GX" }
            },
            otherNpcFates= {
                { fateName="Canal Carnage", npcName="Unlost Sentry GX" },
                { fateName="Mascot March", npcName="The Grand Marshal" }
            },
            fatesWithContinuations =
            {
                { fateName="Plumbers Don't Fear Slimes", continuationIsBoss=true },
                { fateName="Mascot March", continuationIsBoss=true }
            },
            specialFates =
            {
                "Mascot Murder"
            },
            blacklistedFates= {
                "Plumbers Don't Fear Slimes", --Causing Script to crash
            }
        }
    }
}