--HELLO FRIENDS, IF YOU WANT TO ADD AN ITEM THEN ADD TO THE TOP OF THE ITEM STOCKING LIST BELOW, REBOOT, AND RUN "autostocker"
--The script checks if the current stock (including any stock that is current being crafted) is *less than* the checkLvl
--format: {name="Example",damage="0",checkLvl=10,craftAmt=1000},
    --DONT FORGET THE COMMA
--damage is the number after the colon in an item's extended name. Only use to distinguish between 2 items with same name
    --eg. for "Plastic Circuit Board 7124:32007", the damage is "32007"
--Essentia and fluids are represented as drops (1 drop = 1 mB)
--make a request trigger when all players are offline with offlineOnly=true
--make an item able to occupy multiple CPUs even if its already being crafted with multCPU=true
    --it will consider the amount thats already crafting when checking stock

    local itemStock_l={

        --Power
        {label="High Density Plutonium",checkLvl=1600,craftAmt=32},
        {label="High Density Uranium",checkLvl=3200,craftAmt=64},
        {label="drop of Gelid Cryotheum",checkLvl=6000000,craftAmt=600000},
        {label="drop of Molten Atomic Separation Catalyst",checkLvl=460800,craftAmt=46080},
        --{label="Atomic Separation Catalyst Dust",checkLvl=32000,craftAmt=3200},
        --{label="drop of Naquadah Based Liquid Fuel MkII",checkLvl=32000,craftAmt=16000},
    
        --Automated processing
        {label="drop of Ether",checkLvl=32001,craftAmt=32000},
        {label="drop of P-507",checkLvl=32001,craftAmt=32000},
        {label="Reinforced Glass Tube",checkLvl=1000000,craftAmt=1000},
        {label="Mars Stone Dust",checkLvl=100,craftAmt=1000},
        --{label="Enceladus Stone Dust",checkLvl=65,craftAmt=640},
        {label="Agar",checkLvl=10000,craftAmt=10000},
        {label="Biocells",checkLvl=10-00,craftAmt=10000},
        {label="Mince Meat",checkLvl=100000,craftAmt=100000},
        {label="T Ceti E Seaweed",damage=0,checkLvl=128000,craftAmt=64000},
        --{label="Naquadah Dust",checkLvl=501,craftAmt=500},
        --{label="Naquadahine Dust",checkLvl=19201,craftAmt=19200},
        {label="Pyrotheum Dust",damage=2843,checkLvl=100,craftAmt=1000},
        {label="Cryotheum Dust",damage=2898,checkLvl=100,craftAmt=500},
        --{label="Quicklime Dust",damage=2622,checkLvl=10000,craftAmt=2000},
        --{label="Saltpeter Dust",checkLvl=10000,craftAmt=5000},
        --{label="Sulfur Dust",damage=2022,checkLvl=641,craftAmt=640},
        --{label="Blaze Powder",checkLvl=1281,craftAmt=1280},
        {label="Raw Neutronium Dust",checkLvl=6400,craftAmt=640},
    
        --Fluid Stocking (drops)
        {label="drop of Unknown Nutrient Agar",checkLvl=2000000,craftAmt=1000000},
        {label="drop of Hydrochloric Acid",checkLvl=192000000,craftAmt=64000000},
        {label="drop of Molten Silver",checkLvl=1000000,craftAmt=100000},
        {label="drop of Phthalic Acid",checkLvl=320000000,craftAmt=32000000},
        {label="drop of Formic Acid",checkLvl=1000000,craftAmt=1000000},
        {label="drop of Wet Concrete",checkLvl=224001,craftAmt=32000},
        {label="drop of Molten Polybenzimidazole",checkLvl=64000000,craftAmt=64000,offlineOnly=false},
        {label="drop of Ammonia",checkLvl=128000000,craftAmt=6400000},
        {label="drop of Nitric Acid",checkLvl=72000000,craftAmt=3200000},
        {label="drop of Acetic Acid",checkLvl=1000001,craftAmt=1000000},
        {label="drop of Phosphoric Acid",checkLvl=100000,craftAmt=200000},
        {label="drop of Mercury",checkLvl=1000000,craftAmt=2000000},
        {label="drop of Hydrogen Sulfide",checkLvl=32000,craftAmt=100000},
        {label="drop of Drilling Fluid",checkLvl=32000000,craftAmt=32000000},
        {label="drop of Molten Silicone Rubber",checkLvl=32000000,craftAmt=3200000},
        {label="drop of Molten Polyethylene",checkLvl=3200000,craftAmt=320000},
        {label="drop of Molten Polyphenylene Sulfide",checkLvl=1600000,craftAmt=160000},
        {label="drop of Lubricant",checkLvl=32000000,craftAmt=3200000},
        {label="drop of Radon",checkLvl=64000000,craftAmt=640000},
        
        --Fluid Stocking (cells)
        {label="Lubricant Cell",checkLvl=33,craftAmt=32},
        {label="Water Cell",checkLvl=10000,craftAmt=10000},
        {label="Oxygen Cell",checkLvl=10000,craftAmt=10000},
        {label="Chlorine Cell",checkLvl=10000,craftAmt=10000},
        {label="Fluorine Cell",checkLvl=10000,craftAmt=10000},
        {label="Sulfuric Acid Cell",checkLvl=10000,craftAmt=10000},
        {label="Nitric Acid Cell",checkLvl=10000,craftAmt=10000},
    
        --Fusion
        {label="drop of Helium Plasma",checkLvl=1250000,craftAmt=125000},
        {label="drop of Molten Europium",checkLvl=1000000,craftAmt=32768}, 
        {label="drop of Molten Duranium",checkLvl=500000,craftAmt=32768},
        {label="drop of Molten Tritanium",checkLvl=500000,craftAmt=32768},
        --{label="drop of Molten Americium",checkLvl=1000000,craftAmt=32768}, --automated by bees
        
        --Circuit Stocking
        {label="Microprocessor",checkLvl=2560,craftAmt=256,offlineOnly=false}, --lv
        {label="Integrated Processor",checkLvl=2560,craftAmt=256,offlineOnly=false}, --mv
        {label="Nanoprocessor",checkLvl=131072,craftAmt=64,offlineOnly=false}, --hv
        {label="Quantumprocessor",checkLvl=1024,craftAmt=64,offlineOnly=false}, --ev
        {label="Crystalprocessor",checkLvl=1024,craftAmt=64,offlineOnly=true}, --iv
        {label="Wetwareprocessor",checkLvl=32768,craftAmt=64,offlineOnly=true}, --luv
        {label="Bioprocessor",checkLvl=4096,craftAmt=64,offlineOnly=true}, --zpm 
        
        --Metal Stocking
        {label="Bedrockium Ingot",checkLvl=1280,craftAmt=2,offlineOnly=false},
        {label="Iridium Ingot",checkLvl=64000,craftAmt=64,offlineOnly=false},
        {label="Naquadah Ingot",checkLvl=64000,craftAmt=64},
        {label="Naquadah Dust",checkLvl=64000,craftAmt=640},
        {label="Enriched Naquadah Ingot",checkLvl=128000,craftAmt=64},
        {label="Enriched Naquadah Dust",checkLvl=640000,craftAmt=6400},
        {label="Naquadria Ingot",checkLvl=64000,craftAmt=64},
        {label="Naquadria Dust",checkLvl=640000,craftAmt=6400},
        {label="Naquadah Alloy Ingot",checkLvl=64000,craftAmt=64,offlineOnly=true},
        {label="Aluminium Ingot",checkLvl=51200,craftAmt=5120,offlineOnly=false},
        {label="Stainless Steel Ingot",checkLvl=6400,craftAmt=640,offlineOnly=false},
        {label="Tungstensteel Ingot",checkLvl=32000,craftAmt=64,offlineOnly=false},
        {label="Tungsten Ingot",checkLvl=6400,craftAmt=64,offlineOnly=false},
        {label="HSS-S Ingot",checkLvl=16000,craftAmt=64,offlineOnly=false},
        {label="Ruridit Ingot",checkLvl=16000,craftAmt=64,offlineOnly=false},
        {label="Trinium Ingot",checkLvl=16000,craftAmt=64,offlineOnly=true},
        {label="Europium Ingot",checkLvl=10000,craftAmt=400},
        {label="Neutronium Ingot",checkLvl=32768,craftAmt=128,offlineOnly=true},
        {label="Silicon Solar Grade (Poly SI) Ingot",checkLvl=128000,craftAmt=640,offlineOnly=true},
        {label="Electrum Ingot",checkLvl=19200,craftAmt=19200},
        {label="Cosmic Neutronium Ingot",checkLvl=1000,craftAmt=128,offlineOnly=true},
        {label="Tritanium Ingot",checkLvl=10000,craftAmt=500},
        {label="Block of Ichorium",checkLvl=200,craftAmt=1},
        {label="Ichorium Ingot",checkLvl=1000,craftAmt=10},
        
       
        --Supply stocking
        {label="Quicklime Dust",checkLvl=1280000,craftAmt=128000},
        {label="Sodium Hydroxide Dust",checkLvl=1920000,craftAmt=192000},
        {label="Americium doped Wafer",checkLvl=32768,craftAmt=256,offlineOnly=true},
        {label="Naquadah doped Wafer",checkLvl=32768,craftAmt=256,offlineOnly=true},
        {label="Lapotronic Energy Orb Cluster",damage=32599,checkLvl=2000,craftAmt=8,offlineOnly=true},
        --{label="Lapotron Crystal",damage=32767,checkLvl=100000,craftAmt=512,offlineOnly=true},
        {label="Ultra Bio Mutated Circuit Board",checkLvl=6400,craftAmt=80},
        {label="Extreme Wetware Lifesupport Circuit Board",checkLvl=10000,craftAmt=120}, --long waits for basic crafts without this
        {label="Elite Circuit Board",checkLvl=10000,craftAmt=160},
        {label="Advanced Circuit Board",checkLvl=20000,craftAmt=0320},
        {label="Americium Rod",checkLvl=100,craftAmt=1000},
        {label="Data Orb",hasTag=false,checkLvl=5,craftAmt=4},
        {label="BrainTech Aerospace Advanced Reinforced Duct Tape FAL-84",checkLvl=33,craftAmt=32},
        {label="Steel Screw",checkLvl=321,craftAmt=320},
        {label="High Power Casing",checkLvl=65,craftAmt=64},
        {label="Laser Vacuum Pipe",checkLvl=65,craftAmt=64},
        {label="Superconducting Coil Block",checkLvl=4,craftAmt=1},
        {label="Active Transformer",hasTag=false,checkLvl=4,craftAmt=1},
        {label="Wireless Connector",checkLvl=17,craftAmt=16},
        {label="ME Conduit",checkLvl=33,craftAmt=32},
        {label="Item Conduit",checkLvl=33,craftAmt=32},
        {label="Stellar Ender Fluid Conduit",checkLvl=33,craftAmt=32},
        {label="ME Fluid Level Emitter",checkLvl=9,craftAmt=8},
        {label="ME Level Emitter",checkLvl=9,craftAmt=8},
        {label="Raw Crystal Chip Parts",checkLvl=500,craftAmt=64,multCPU=true},
        {label="Large Chemical Reactor",checkLvl=2,craftAmt=1},
        {label="Chemically Inert Machine Casing",checkLvl=17,craftAmt=16},
        {label="Solid Steel Machine Casing",checkLvl=33,craftAmt=32},
        {label="Text Card",hasTag=false,checkLvl=8,craftAmt=1},
        {label="Advanced Panel Extender",checkLvl=32,craftAmt=8},
        {label="Advanced Information Panel",checkLvl=8,craftAmt=4},
        {label="Wireless Setup Kit",hasTag=false,checkLvl=3,craftAmt=1},
        {label="Auto-Taping Maintenance Hatch",checkLvl=4,craftAmt=1,offlineOnly=false},
        {label="Extreme Industrial Greenhouse",checkLvl=2,craftAmt=1},
        {label="Clean Stainless Steel Machine Casing",checkLvl=33,craftAmt=32},
        {label="Robust Tungstensteel Machine Casing",checkLvl=19,craftAmt=18},
        {label="Processing Array",checkLvl=2,craftAmt=1},
        {label="Stocking Input Bus (ME)",checkLvl=5,craftAmt=4},
        {label="Output Bus (ME)",checkLvl=5,craftAmt=4},
        {label="Output Hatch (ME)",checkLvl=5,craftAmt=4},
        {label="Melodic Alloy Grinding Ball",hasTag=false,checkLvl=25,craftAmt=24},
        {label="ME Covered Cable - Fluix",checkLvl=33,craftAmt=32},
        {label="ME Dense Smart Cable - Fluix",checkLvl=33,craftAmt=32},
        {label="Blank Pattern",checkLvl=33,craftAmt=32},
        {label="ME Interface",damage=0,hasTag=false,checkLvl=2,craftAmt=3},
        {label="ME Dual Interface",damage=0,hasTag=false,name="ae2fc:fluid_interface",checkLvl=2,craftAmt=3},
        {label="Pattern Capacity Card",checkLvl=9,craftAmt=8},
        {label="Cable Anchor",checkLvl=41,craftAmt=100},
        {label="Memory (Tier 3.5)",hasTag=false,checkLvl=4,craftAmt=4},
        {label="Internet Card",hasTag=false,checkLvl=1,craftAmt=1},
        {label="Graphics Card (Tier 3)",hasTag=false,checkLvl=1,craftAmt=1},
        {label="Rack",hasTag=false,checkLvl=1,craftAmt=1},
        {label="Adapter",hasTag=false,checkLvl=1,craftAmt=1},
        {label="Keyboard",hasTag=false,checkLvl=1,craftAmt=1},
        {label="Central Processing Unit (CPU) (Tier 3)",hasTag=false,checkLvl=1,craftAmt=1},
        {label="Hard Disk Drive (Tier 3) (4MB)",hasTag=false,checkLvl=1,craftAmt=1},
        {label="Screen (Tier 3)",hasTag=false,checkLvl=6,craftAmt=6},
        {label="Server (Tier 3)",hasTag=false,checkLvl=1,craftAmt=1},
        {label="Computer Case (Tier 3)",hasTag=false,checkLvl=1,craftAmt=1},
        {label="1x Superconductor LuV Wire",checkLvl=150,craftAmt=15,offlineOnly=true},
        {label="1x Superconductor ZPM Wire",checkLvl=4800,craftAmt=18,offlineOnly=true},
        {label="1x Superconductor UV Wire",checkLvl=210,craftAmt=21,offlineOnly=true},
        {label="1x Superconductor UHV Wire",checkLvl=1200,craftAmt=24,offlineOnly=true},
        {label="Paint Ball - White",checkLvl=33,craftAmt=32},
        {label="Paint Ball - Orange",checkLvl=33,craftAmt=32},
        {label="Paint Ball - Magenta",checkLvl=33,craftAmt=32},
        {label="Paint Ball - Light Blue",checkLvl=33,craftAmt=32},
        {label="Paint Ball - Yellow",checkLvl=33,craftAmt=32},  
        {label="Paint Ball - Lime",checkLvl=33,craftAmt=32},
        {label="Paint Ball - Pink",checkLvl=33,craftAmt=32},
        {label="Paint Ball - Gray",checkLvl=33,craftAmt=32},
        {label="Paint Ball - Light Gray",checkLvl=33,craftAmt=32},
        {label="Paint Ball - Cyan",checkLvl=33,craftAmt=32},
        {label="Paint Ball - Purple",checkLvl=33,craftAmt=32},
        {label="Paint Ball - Blue",checkLvl=33,craftAmt=32},
        {label="Paint Ball - Brown",checkLvl=33,craftAmt=32},
        {label="Paint Ball - Green",checkLvl=33,craftAmt=32},
        {label="Paint Ball - Red",checkLvl=33,craftAmt=32},
        {label="Paint Ball - Black",checkLvl=33,craftAmt=32},
        {label="Acceleration Card",checkLvl=33,craftAmt=32},
        {label="Genetics Labware",checkLvl=64,craftAmt=128},
        
        --Crafting goals
        {label="Ultimate Battery",checkLvl=8,craftAmt=1,offlineOnly=true},
        {label="Infinity Coil Block",checkLvl=2112,craftAmt=1,offlineOnly=true},
        --{label="Advanced Field Restriction Coil",checkLvl=32,craftAmt=1,offlineOnly=true},
        {label="Grandmaster Essentia Diffusion Cell",checkLvl=100,craftAmt=1},
        {label="Draconium Fusion Casing",checkLvl=32,craftAmt=1},
    
      -- Essentia
        {label="drop of Aer Gas",checkLvl=12800000,craftAmt=32768},
        {label="drop of Ignis Gas",checkLvl=12800000,craftAmt=32768},
        {label="drop of Terra Gas",checkLvl=12800000,craftAmt=32768},
        {label="drop of Aqua Gas",checkLvl=12800000,craftAmt=32768},
        {label="drop of Ordo Gas",checkLvl=12800000,craftAmt=32768},
        {label="drop of Perditio Gas",checkLvl=12800000,craftAmt=32768},
        {label="drop of Vacuos Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Lux Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Tempestas Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Motus Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Gelum Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Vitreus Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Victus Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Venenum Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Potentia Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Permutatio Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Metallum Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Mortuus Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Volatus Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Tenebrae Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Spiritus Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Sano Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Iter Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Alienis Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Praecantatio Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Auram Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Vitium Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Limus Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Herba Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Arbor Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Bestia Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Corpus Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Exanimis Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Cognitio Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Sensus Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Humanus Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Messis Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Instrumentum Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Meto Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Telum Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Tutamen Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Fames Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Lucrum Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Fabrico Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Pannus Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Machina Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Vinculum Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Strontio Gas",checkLvl=128000,craftAmt=32768},
        {label="drop of Nebrisum Gas",checkLvl=128000,craftAmt=32768},
        {label="drop of Electrum Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Luxuria Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Radio Gas",checkLvl=128000,craftAmt=32768},
        {label="drop of Infernus Gas",checkLvl=2560000,craftAmt=32768},
        {label="drop of Ira Gas",checkLvl=128000,craftAmt=32768},
        {label="drop of Terminus Gas",checkLvl=12800,craftAmt=32768},
        {label="drop of Superbia Gas",checkLvl=2500000,craftAmt=32768},
    
    
    --BM
        {label="Concentrated Catalyst",checkLvl=100,craftAmt=10},
        {label="Simple Catalyst",checkLvl=100,craftAmt=10},
        {label="Strengthened Catalyst",checkLvl=100,craftAmt=10},
        {label="Sanctus",checkLvl=100,craftAmt=10},
        {label="Incendium",checkLvl=100,craftAmt=10},
        {label="Tenebrae",checkLvl=100,craftAmt=10},
        {label="Magicales",checkLvl=100,craftAmt=10},
        {label="Aether",checkLvl=100,craftAmt=10},
        {label="Standard Binding Agent",checkLvl=100,craftAmt=10},
        {label="Weak Binding Agent",checkLvl=100,craftAmt=10},
        {label="Fractured Bone",checkLvl=100,craftAmt=10},
        {label="Crystallos",checkLvl=100,craftAmt=10},
        {label="Terrae",checkLvl=100,craftAmt=10},
        {label="Aquasalus",checkLvl=100,craftAmt=10},
        {label="Potentia",checkLvl=100,craftAmt=10},
        {label="Crepitous",checkLvl=100,craftAmt=10},
        {label="Blank Slate",checkLvl=500,craftAmt=100},
        {label="Reinforced Slate",checkLvl=1000,craftAmt=100},
        {label="Demonic Slate",checkLvl=1000,craftAmt=100},
        {label="Imbued Slate",checkLvl=1000,craftAmt=100},
        {label="Ethereal Slate",checkLvl=1000,craftAmt=100}   
     
    
    }
    
    return itemStock_l
