#!/usr/bin/env python3
"""Generate real crossword puzzles with interlocking across/down words."""

import json
import os
import random

# Curated word list with clues, organized by length
WORDS_WITH_CLUES = {
    3: [
        ("ACE", "Top card or expert"), ("ACT", "Stage performance"), ("ADD", "Sum up"),
        ("AGE", "How old you are"), ("AID", "Help out"), ("AIM", "Take target"),
        ("AIR", "What we breathe"), ("ALE", "Pub brew"), ("ANT", "Picnic pest"),
        ("APE", "Primate"), ("ARC", "Curved line"), ("ARE", "Exist (plural)"),
        ("ARK", "Noah's vessel"), ("ARM", "Body limb"), ("ART", "Gallery display"),
        ("ATE", "Had dinner"), ("AWE", "Wonder"), ("AXE", "Chopping tool"),
        ("BAD", "Not good"), ("BAG", "Carry-all"), ("BAN", "Prohibit"),
        ("BAR", "Pub counter"), ("BAT", "Baseball stick"), ("BED", "Sleep spot"),
        ("BET", "Wager"), ("BIG", "Large"), ("BIT", "Small piece"),
        ("BOW", "Archer's weapon"), ("BOX", "Container"), ("BOY", "Young male"),
        ("BUD", "Flower beginning"), ("BUG", "Insect"), ("BUS", "Public transport"),
        ("BUT", "However"), ("BUY", "Purchase"), ("CAB", "Taxi"),
        ("CAN", "Tin container"), ("CAP", "Head covering"), ("CAR", "Automobile"),
        ("CAT", "Feline pet"), ("COP", "Police officer"), ("COT", "Baby bed"),
        ("COW", "Farm animal"), ("CRY", "Weep"), ("CUB", "Bear young"),
        ("CUP", "Drinking vessel"), ("CUT", "Slice"), ("DAD", "Father"),
        ("DAM", "River barrier"), ("DAY", "24 hours"), ("DEN", "Cozy room"),
        ("DEW", "Morning moisture"), ("DID", "Past of do"), ("DIG", "Excavate"),
        ("DIM", "Not bright"), ("DIP", "Quick swim"), ("DOC", "Physician"),
        ("DOG", "Canine pet"), ("DOT", "Small point"), ("DRY", "Not wet"),
("DUE", "Owed"), ("DUG", "Excavated"),
        ("EAR", "Hearing organ"), ("EAT", "Consume food"), ("EEL", "Slippery fish"),
        ("EGG", "Breakfast item"), ("ELF", "Santa's helper"), ("ELM", "Shade tree"),
        ("EMU", "Large bird"), ("END", "Finish"), ("ERA", "Time period"),
        ("EVE", "Night before"), ("EWE", "Female sheep"), ("EYE", "Sight organ"),
        ("FAN", "Cooling device"), ("FAR", "Distant"), ("FAT", "Not thin"),
        ("FAX", "Old office machine"), ("FED", "Gave food to"), ("FEW", "Not many"),
        ("FIG", "Sweet fruit"), ("FIN", "Fish part"), ("FIT", "In good shape"),
        ("FIX", "Repair"), ("FLY", "Soar"), ("FOB", "Key chain"),
        ("FOG", "Thick mist"), ("FOR", "In favor of"), ("FOX", "Clever animal"),
        ("FRY", "Cook in oil"), ("FUN", "Good time"), ("FUR", "Animal coat"),
        ("GAP", "Opening"), ("GAS", "Fuel"), ("GEL", "Hair product"),
        ("GEM", "Precious stone"), ("GET", "Obtain"), ("GNU", "African antelope"),
        ("GOD", "Supreme being"), ("GOT", "Obtained"), ("GUM", "Chewing treat"),
        ("GUN", "Firearm"), ("GUT", "Stomach"), ("GUY", "Fellow"),
        ("GYM", "Workout place"), ("HAD", "Possessed"), ("HAM", "Pork cut"),
        ("HAS", "Possesses"), ("HAT", "Head wear"), ("HAY", "Dried grass"),
        ("HEN", "Female chicken"), ("HER", "She possessive"), ("HEW", "Chop"),
        ("HID", "Concealed"), ("HIM", "He objective"), ("HIP", "Body joint"),
        ("HIS", "Male possessive"), ("HIT", "Strike"), ("HOG", "Pig"),
        ("HOP", "Small jump"), ("HOT", "Very warm"), ("HOW", "In what way"),
        ("HUB", "Center point"), ("HUE", "Color shade"), ("HUG", "Embrace"),
        ("HUM", "Sing without words"), ("HUT", "Small shelter"),
        ("ICE", "Frozen water"), ("ICY", "Very cold"), ("ILL", "Sick"),
        ("IMP", "Little devil"), ("INK", "Pen fluid"), ("INN", "Small hotel"),
        ("ION", "Charged atom"), ("IRE", "Anger"), ("IRK", "Annoy"),
        ("IVY", "Climbing plant"), ("JAB", "Quick punch"), ("JAM", "Fruit spread"),
        ("JAR", "Glass container"), ("JAW", "Mouth bone"), ("JAY", "Blue bird"),
        ("JET", "Fast plane"), ("JIG", "Lively dance"), ("JOB", "Employment"),
        ("JOG", "Slow run"), ("JOT", "Write quickly"), ("JOY", "Happiness"),
        ("JUG", "Pouring vessel"), ("KEY", "Lock opener"), ("KID", "Child"),
        ("KIN", "Relatives"), ("KIT", "Set of tools"), ("LAB", "Science room"),
        ("LAD", "Young man"), ("LAP", "Circuit of a track"), ("LAW", "Legal rule"),
        ("LAY", "Put down"), ("LED", "Guided"), ("LEG", "Walking limb"),
        ("LET", "Allow"), ("LID", "Cover"), ("LIE", "Falsehood"),
        ("LIP", "Mouth edge"), ("LIT", "Illuminated"), ("LOG", "Wood piece"),
        ("LOT", "Great deal"), ("LOW", "Not high"), ("MAD", "Angry"),
        ("MAN", "Adult male"), ("MAP", "Atlas page"), ("MAT", "Floor covering"),
        ("MAY", "Spring month"), ("MEN", "Adult males"), ("MET", "Encountered"),
        ("MIX", "Blend"), ("MOB", "Rowdy crowd"), ("MOM", "Mother"),
        ("MOP", "Floor cleaner"), ("MUD", "Wet earth"), ("MUG", "Coffee cup"),
        ("NAB", "Catch"), ("NAP", "Short sleep"), ("NET", "Mesh fabric"),
        ("NEW", "Not old"), ("NIT", "Small louse"), ("NOD", "Head gesture"),
        ("NOR", "And not"), ("NOT", "Negative"), ("NOW", "At present"),
        ("NUB", "Core point"), ("NUN", "Convent sister"), ("NUT", "Hard-shelled fruit"),
        ("OAK", "Sturdy tree"), ("OAR", "Rowing blade"), ("OAT", "Cereal grain"),
        ("ODD", "Strange"), ("ODE", "Lyric poem"), ("OIL", "Lubricant"),
        ("OLD", "Not young"), ("ONE", "Single"), ("OPT", "Choose"),
        ("ORB", "Sphere"), ("ORE", "Metal-bearing rock"), ("OUR", "Belonging to us"),
        ("OUT", "Not in"), ("OWE", "Be indebted"), ("OWL", "Night bird"),
        ("OWN", "Possess"), ("PAD", "Writing tablet"), ("PAN", "Cooking vessel"),
        ("PAT", "Gentle tap"), ("PAW", "Animal foot"), ("PAY", "Compensate"),
        ("PEA", "Green veggie"), ("PEG", "Clothesline fastener"), ("PEN", "Writing tool"),
        ("PET", "Companion animal"), ("PIE", "Baked dessert"), ("PIG", "Farm animal"),
        ("PIN", "Sewing fastener"), ("PIT", "Deep hole"), ("PLY", "Layer of wood"),
        ("POD", "Pea holder"), ("POP", "Soda"), ("POT", "Cooking vessel"),
        ("PRY", "Snoop"), ("PUB", "British bar"), ("PUG", "Small dog breed"),
        ("PUN", "Play on words"), ("PUP", "Young dog"), ("PUT", "Place"),
        ("RAG", "Torn cloth"), ("RAM", "Male sheep"), ("RAN", "Sprinted"),
        ("RAP", "Knock sharply"), ("RAT", "Rodent"), ("RAW", "Uncooked"),
        ("RAY", "Beam of light"), ("RED", "Fire truck color"), ("REF", "Game official"),
        ("RIB", "Chest bone"), ("RID", "Free from"), ("RIG", "Truck or setup"),
        ("RIM", "Edge of a cup"), ("RIP", "Tear apart"), ("ROB", "Steal from"),
        ("ROD", "Fishing pole"), ("ROT", "Decay"), ("ROW", "Argument or line"),
        ("RUB", "Massage"), ("RUG", "Floor covering"), ("RUN", "Sprint"),
        ("RUT", "Groove"), ("RYE", "Bread grain"), ("SAD", "Unhappy"),
        ("SAP", "Tree fluid"), ("SAT", "Was seated"), ("SAW", "Cutting tool"),
        ("SAY", "Speak"), ("SEA", "Ocean"), ("SET", "Group or place"),
        ("SEW", "Stitch"), ("SHE", "Female pronoun"), ("SHY", "Timid"),
        ("SIN", "Transgression"), ("SIP", "Drink slowly"), ("SIS", "Sister, informally"),
        ("SIT", "Take a seat"), ("SIX", "Half dozen"), ("SKI", "Snow sport"),
        ("SKY", "Overhead blue"), ("SLY", "Crafty"), ("SOB", "Cry hard"),
        ("SOD", "Turf"), ("SON", "Male child"), ("SOP", "Something soaked"),
        ("SOT", "Heavy drinker"), ("SOW", "Plant seeds"), ("SOY", "Bean type"),
        ("SPA", "Relaxation spot"), ("SPY", "Secret agent"), ("STY", "Pig pen"),
        ("SUB", "Sandwich or substitute"), ("SUM", "Total"), ("SUN", "Our star"),
        ("SUP", "Dine"), ("TAB", "Bar bill"), ("TAG", "Label"),
        ("TAN", "Sun-kissed"), ("TAP", "Faucet"), ("TAR", "Road material"),
        ("TAX", "Government levy"), ("TEA", "Hot beverage"), ("TEN", "Decade number"),
        ("THE", "Common article"), ("TIE", "Neck accessory"), ("TIN", "Metal can"),
        ("TIP", "Gratuity"), ("TOE", "Foot digit"), ("TON", "2000 pounds"),
        ("TOO", "Also"), ("TOP", "Highest point"), ("TOW", "Pull along"),
        ("TOY", "Plaything"), ("TUB", "Bathing vessel"), ("TUG", "Pull hard"),
        ("TWO", "A pair"), ("URN", "Vase"), ("USE", "Employ"),
        ("VAN", "Delivery vehicle"), ("VAT", "Large tank"), ("VET", "Animal doctor"),
        ("VIA", "By way of"), ("VIE", "Compete"), ("VOW", "Solemn promise"),
        ("WAR", "Armed conflict"), ("WAX", "Candle material"), ("WAY", "Path"),
        ("WEB", "Spider's creation"), ("WED", "Marry"), ("WET", "Not dry"),
        ("WHO", "What person"), ("WIG", "Hairpiece"), ("WIN", "Victory"),
        ("WIT", "Humor"), ("WOE", "Grief"), ("WOK", "Asian pan"),
        ("WON", "Was victorious"), ("WOO", "Court"), ("WOW", "Exclamation"),
        ("YAK", "Tibetan ox"), ("YAM", "Sweet potato"), ("YAP", "Small bark"),
        ("YAW", "Veer off course"), ("YEA", "Affirmative vote"), ("YES", "Affirmative"),
        ("YET", "Still"), ("YEW", "Evergreen tree"), ("ZAP", "Zap with energy"),
        ("ZEN", "Buddhist meditation"), ("ZIP", "Zipper or speed"), ("ZIT", "Blemish"),
        ("ZOO", "Animal park"),
    ],
    4: [
        ("ABLE", "Capable"), ("ACHE", "Dull pain"), ("ACID", "Sour substance"),
        ("ACRE", "Land measure"), ("AGED", "Old"), ("AIDE", "Helper"),
        ("AIMS", "Goals"), ("AIRY", "Breezy"), ("AJAR", "Slightly open"),
        ("ALLY", "Partner"), ("ALSO", "In addition"), ("AMID", "In the middle of"),
        ("ARCH", "Curved structure"), ("AREA", "Region"), ("ARMY", "Military force"),
        ("ARTS", "Creative works"), ("ATOM", "Tiny particle"), ("AUTO", "Car"),
        ("AVID", "Eager"), ("AWAY", "Not here"), ("AXLE", "Wheel rod"),
        ("BABE", "Infant"), ("BACK", "Rear"), ("BAKE", "Oven cook"),
        ("BALD", "Without hair"), ("BALE", "Hay bundle"), ("BALL", "Round toy"),
        ("BAND", "Music group"), ("BANE", "Curse"), ("BANK", "Money institution"),
        ("BARE", "Naked"), ("BARK", "Dog sound"), ("BARN", "Farm building"),
        ("BASE", "Foundation"), ("BATH", "Washing soak"), ("BEAD", "Necklace piece"),
        ("BEAM", "Light ray"), ("BEAN", "Pod veggie"), ("BEAR", "Forest animal"),
        ("BEAT", "Rhythm"), ("BEER", "Pub drink"), ("BELL", "Chiming object"),
        ("BELT", "Waist band"), ("BEND", "Curve"), ("BEST", "Top quality"),
        ("BILE", "Bitter fluid"), ("BIND", "Tie together"), ("BIRD", "Feathered flyer"),
        ("BITE", "Chomp"), ("BLOT", "Ink stain"), ("BLOW", "Gust"),
        ("BLUE", "Sky color"), ("BLUR", "Fuzzy image"), ("BOAR", "Wild pig"),
        ("BOAT", "Water vessel"), ("BODY", "Physical form"), ("BOLD", "Brave"),
        ("BOLT", "Door fastener"), ("BOMB", "Explosive"), ("BOND", "Connection"),
        ("BONE", "Skeleton part"), ("BOOK", "Reading material"), ("BOOT", "Footwear"),
        ("BORE", "Drill or dull person"), ("BORN", "Brought into life"),
        ("BOSS", "Manager"), ("BOTH", "The two"), ("BOWL", "Soup dish"),
        ("BRED", "Raised animals"), ("BREW", "Make beer or coffee"),
        ("BRIM", "Hat edge"), ("BULB", "Light source"), ("BULK", "Large quantity"),
        ("BULL", "Male bovine"), ("BUMP", "Small collision"), ("BURN", "Fire injury"),
        ("BURP", "Stomach noise"), ("BURY", "Inter"), ("BUSH", "Shrub"),
        ("BUSY", "Not idle"), ("BUZZ", "Bee sound"),
        ("CAFE", "Coffee shop"), ("CAGE", "Animal enclosure"), ("CAKE", "Birthday treat"),
        ("CALF", "Young cow"), ("CALM", "Peaceful"), ("CAME", "Arrived"),
        ("CAMP", "Outdoor lodging"), ("CANE", "Walking stick"), ("CAPE", "Superhero garment"),
        ("CARD", "Playing piece"), ("CARE", "Concern"), ("CART", "Shopping vehicle"),
        ("CASE", "Container or situation"), ("CASH", "Money"), ("CAST", "Throw"),
        ("CAVE", "Underground chamber"), ("CELL", "Prison room or tiny unit"),
        ("CHEF", "Professional cook"), ("CHIN", "Face bottom"), ("CHIP", "Snack"),
        ("CHOP", "Cut with axe"), ("CITY", "Large town"), ("CLAD", "Dressed"),
        ("CLAM", "Shellfish"), ("CLAP", "Applause"), ("CLAW", "Animal nail"),
        ("CLAY", "Pottery material"), ("CLIP", "Fasten"), ("CLOD", "Lump of earth"),
        ("CLUB", "Social group"), ("CLUE", "Hint"), ("COAL", "Black fuel"),
        ("COAT", "Outer garment"), ("CODE", "Secret message"), ("COIL", "Spiral"),
        ("COIN", "Metal money"), ("COLD", "Not hot"), ("COLT", "Young horse"),
        ("COMB", "Hair groomer"), ("COME", "Arrive"), ("CONE", "Ice cream holder"),
        ("COOK", "Prepare food"), ("COOL", "Somewhat cold"), ("COPE", "Deal with"),
        ("COPY", "Duplicate"), ("CORD", "Thick string"), ("CORE", "Center"),
        ("CORK", "Bottle stopper"), ("CORN", "Yellow veggie"), ("COST", "Price"),
        ("COZY", "Warm and snug"), ("CRAB", "Beach creature"), ("CREW", "Team"),
        ("CROP", "Farm product"), ("CROW", "Black bird"), ("CUBE", "3D square"),
        ("CURE", "Remedy"), ("CURL", "Spiral shape"),
        ("DALE", "Valley"), ("DAME", "Lady"), ("DAMP", "Slightly wet"),
        ("DARE", "Challenge"), ("DARK", "Without light"), ("DART", "Throwing missile"),
        ("DASH", "Sprint"), ("DATA", "Information"), ("DATE", "Calendar day"),
        ("DAWN", "Daybreak"), ("DAYS", "Time periods"), ("DEAF", "Cannot hear"),
        ("DEAL", "Bargain"), ("DEAR", "Beloved"), ("DECK", "Ship floor"),
        ("DEED", "Action"), ("DEEM", "Consider"), ("DEEP", "Profound"),
        ("DEER", "Forest animal"), ("DEMO", "Trial version"), ("DENT", "Small depression"),
        ("DENY", "Refuse"), ("DESK", "Work surface"), ("DIAL", "Phone face"),
        ("DICE", "Gaming cubes"), ("DIET", "Food plan"), ("DIME", "Ten cents"),
        ("DINE", "Eat formally"), ("DIRE", "Desperate"), ("DIRT", "Soil"),
        ("DISC", "Flat circle"), ("DISH", "Plate"), ("DISK", "Storage medium"),
        ("DOCK", "Ship berth"), ("DOES", "Performs"), ("DOME", "Rounded roof"),
        ("DONE", "Finished"), ("DOOM", "Terrible fate"), ("DOOR", "Room entrance"),
        ("DOSE", "Medicine amount"), ("DOTS", "Small points"), ("DOVE", "Peace bird"),
        ("DOWN", "Opposite of up"), ("DOZE", "Light sleep"), ("DRAB", "Dull"),
        ("DRAG", "Pull along"), ("DRAW", "Sketch"), ("DREW", "Sketched"),
        ("DRIP", "Water drop"), ("DROP", "Let fall"), ("DRUM", "Percussion instrument"),
        ("DUAL", "Double"), ("DUB", "Name"), ("DUCK", "Pond bird"),
        ("DUEL", "One-on-one fight"), ("DUET", "Song for two"), ("DUKE", "Nobleman"),
        ("DULL", "Boring"), ("DUMB", "Speechless"), ("DUMP", "Discard"),
        ("DUNE", "Sand hill"), ("DUNK", "Dip into liquid"), ("DUSK", "Twilight"),
        ("DUST", "Fine particles"), ("DUTY", "Obligation"),
        ("EACH", "Every one"), ("EARL", "British nobleman"), ("EARN", "Make money"),
        ("EASE", "Comfort"), ("EAST", "Sunrise direction"), ("EASY", "Not hard"),
        ("ECHO", "Sound reflection"), ("EDGE", "Border"), ("EDIT", "Revise text"),
        ("EELS", "Slippery fish"), ("ELKS", "Large deer"), ("ELSE", "Otherwise"),
        ("EMIT", "Give off"), ("ENVY", "Jealousy"), ("EPIC", "Grand story"),
        ("EVEN", "Level or also"), ("EVER", "At any time"), ("EVIL", "Wicked"),
        ("EXAM", "Test"), ("EXIT", "Way out"), ("EYED", "Looked at"),
        ("EYES", "Sight organs"),
        ("FACE", "Front of head"), ("FACT", "Truth"), ("FADE", "Lose color"),
        ("FAIL", "Not succeed"), ("FAIR", "Just or carnival"), ("FAKE", "Not real"),
        ("FALL", "Autumn"), ("FAME", "Celebrity"), ("FANG", "Vampire tooth"),
        ("FARE", "Ticket price"), ("FARM", "Agricultural land"), ("FAST", "Quick"),
        ("FATE", "Destiny"), ("FAWN", "Young deer"), ("FEAR", "Dread"),
        ("FEAT", "Achievement"), ("FEED", "Give food"), ("FEEL", "Sense"),
        ("FEET", "Walking appendages"), ("FELL", "Dropped"), ("FELT", "Sensed"),
        ("FERN", "Forest plant"), ("FEST", "Festival"), ("FEUD", "Family fight"),
        ("FILE", "Document holder"), ("FILL", "Make full"), ("FILM", "Movie"),
        ("FIND", "Discover"), ("FINE", "Penalty or excellent"), ("FIRE", "Flames"),
        ("FIRM", "Company"), ("FISH", "Aquatic animal"), ("FIST", "Clenched hand"),
        ("FLAG", "National banner"), ("FLAP", "Wing motion"), ("FLAT", "Level"),
        ("FLAW", "Defect"), ("FLEA", "Tiny pest"), ("FLED", "Ran away"),
        ("FLEW", "Soared"), ("FLIP", "Turn over"), ("FLOG", "Whip"),
        ("FLOW", "Stream along"), ("FOAM", "Frothy bubbles"), ("FOIL", "Thin metal"),
        ("FOLD", "Bend over"), ("FOLK", "People"), ("FOND", "Affectionate"),
        ("FONT", "Typeface"), ("FOOD", "Nourishment"), ("FOOL", "Silly person"),
        ("FOOT", "12 inches"), ("FORD", "River crossing"), ("FORE", "Front"),
        ("FORK", "Eating utensil"), ("FORM", "Shape"), ("FORT", "Military base"),
        ("FOUL", "Unfair play"), ("FOUR", "After three"), ("FREE", "No cost"),
        ("FROG", "Pond amphibian"), ("FROM", "Starting point"), ("FUEL", "Energy source"),
        ("FULL", "Not empty"), ("FUME", "Toxic gas"), ("FUND", "Money pool"),
        ("FURY", "Intense anger"), ("FUSE", "Electrical safety device"),
        ("FUSS", "Unnecessary worry"), ("FUZZ", "Soft fibers"),
        ("GALE", "Strong wind"), ("GAME", "Sport or play"), ("GANG", "Group"),
        ("GAPE", "Stare open-mouthed"), ("GARB", "Clothing"), ("GASH", "Deep cut"),
        ("GASP", "Sharp breath"), ("GATE", "Fence opening"), ("GAVE", "Donated"),
        ("GAZE", "Stare"), ("GEAR", "Equipment"), ("GERM", "Microbe"),
        ("GIFT", "Present"), ("GIST", "Main point"), ("GIVE", "Donate"),
        ("GLAD", "Happy"), ("GLEE", "Joy"), ("GLEN", "Narrow valley"),
        ("GLOW", "Soft light"), ("GLUE", "Adhesive"), ("GNAW", "Chew on"),
        ("GOAT", "Farm animal"), ("GOES", "Travels"), ("GOLD", "Precious metal"),
        ("GOLF", "Club sport"), ("GONE", "Departed"), ("GOOD", "Not bad"),
        ("GOWN", "Formal dress"), ("GRAB", "Seize"), ("GRAM", "Weight unit"),
        ("GRAY", "Between black and white"), ("GREW", "Got bigger"),
        ("GRID", "Crisscross pattern"), ("GRIM", "Stern"), ("GRIN", "Big smile"),
        ("GRIP", "Hold tight"), ("GRIT", "Determination"), ("GROW", "Get bigger"),
        ("GULF", "Large bay"), ("GULL", "Seabird"), ("GUST", "Wind burst"),
        ("GURU", "Expert teacher"),
        ("HACK", "Computer break-in"), ("HAIL", "Ice pellets"), ("HAIR", "Head covering"),
        ("HALE", "Healthy"), ("HALF", "50 percent"), ("HALL", "Corridor"),
        ("HALT", "Stop"), ("HAND", "Five fingers"), ("HANG", "Suspend"),
        ("HARE", "Fast rabbit"), ("HARP", "Stringed instrument"), ("HARM", "Injury"),
        ("HASH", "Chopped mix"), ("HATE", "Despise"), ("HAUL", "Drag"),
        ("HAVE", "Possess"), ("HAZE", "Light fog"), ("HEAD", "Body top"),
        ("HEAL", "Mend"), ("HEAP", "Pile"), ("HEAR", "Listen"),
        ("HEAT", "Warmth"), ("HEED", "Pay attention to"), ("HEEL", "Foot back"),
        ("HELD", "Grasped"), ("HELP", "Assist"), ("HEMP", "Plant fiber"),
        ("HERD", "Group of cattle"), ("HERE", "In this place"), ("HERO", "Brave person"),
        ("HIDE", "Conceal"), ("HIGH", "Tall"), ("HIKE", "Long walk"),
        ("HILL", "Small mountain"), ("HILT", "Sword handle"), ("HIND", "Rear"),
        ("HINT", "Clue"), ("HIRE", "Employ"), ("HOLD", "Grasp"),
        ("HOLE", "Opening"), ("HOME", "Dwelling"), ("HONE", "Sharpen"),
        ("HOOD", "Head cover"), ("HOOK", "Curved fastener"), ("HOPE", "Wish for"),
        ("HORN", "Animal spike"), ("HOSE", "Water tube"), ("HOST", "Party giver"),
        ("HOWL", "Wolf cry"), ("HUGE", "Enormous"), ("HULL", "Ship body"),
        ("HUNG", "Suspended"), ("HUNT", "Search for prey"), ("HURL", "Throw hard"),
        ("HURT", "Cause pain"), ("HUSH", "Be quiet"), ("HYMN", "Church song"),
        ("IDEA", "Thought"), ("IDLE", "Not busy"), ("IDOL", "Object of worship"),
        ("INCH", "Small measure"), ("INTO", "Going inside"), ("IRON", "Metal or press clothes"),
        ("ISLE", "Small island"), ("ITCH", "Need to scratch"), ("ITEM", "Single thing"),
        ("JADE", "Green gem"), ("JAIL", "Prison"), ("JARS", "Glass containers"),
        ("JAZZ", "Music genre"), ("JEST", "Joke"), ("JOBS", "Employment"),
        ("JOIN", "Connect"), ("JOKE", "Funny story"), ("JOLT", "Sudden shock"),
        ("JUMP", "Leap"), ("JURY", "Trial panel"), ("JUST", "Fair or only"),
        ("KEEN", "Eager"), ("KEEP", "Retain"), ("KELP", "Seaweed"),
        ("KEPT", "Retained"), ("KEYS", "Lock openers"), ("KICK", "Foot strike"),
        ("KIDS", "Children"), ("KILL", "End life"), ("KIND", "Gentle type"),
        ("KING", "Royal ruler"), ("KISS", "Lip touch"), ("KITE", "Flying toy"),
        ("KNOB", "Door handle"), ("KNOT", "Tied rope"), ("KNOW", "Be aware"),
        ("LACE", "Delicate fabric"), ("LACK", "Be without"), ("LAID", "Put down"),
        ("LAIR", "Animal den"), ("LAKE", "Inland water"), ("LAMB", "Baby sheep"),
        ("LAME", "Weak excuse"), ("LAMP", "Light source"), ("LAND", "Ground"),
        ("LANE", "Narrow road"), ("LARK", "Songbird"), ("LASH", "Whip stroke"),
        ("LASS", "Young woman"), ("LAST", "Final"), ("LATE", "Not on time"),
        ("LAWN", "Yard grass"), ("LEAD", "Guide or metal"), ("LEAF", "Tree part"),
        ("LEAK", "Drip out"), ("LEAN", "Thin or tilt"), ("LEAP", "Big jump"),
        ("LEFT", "Opposite of right"), ("LEND", "Loan"), ("LENS", "Camera part"),
        ("LESS", "Fewer"), ("LIED", "Told a fib"), ("LIFE", "Existence"),
        ("LIFT", "Raise up"), ("LIKE", "Enjoy"), ("LIMB", "Tree branch or arm"),
        ("LIME", "Green citrus"), ("LIMP", "Uneven walk"), ("LINE", "Straight mark"),
        ("LINK", "Connection"), ("LION", "King of jungle"), ("LIST", "Written items"),
        ("LIVE", "Exist"), ("LOAD", "Cargo"), ("LOAF", "Bread shape"),
        ("LOAN", "Lend money"), ("LOCK", "Secure"), ("LOFT", "Attic space"),
        ("LOGO", "Brand symbol"), ("LONE", "Solitary"), ("LONG", "Extended"),
        ("LOOK", "See"), ("LOOP", "Circle shape"), ("LORD", "Noble title"),
        ("LORE", "Traditional knowledge"), ("LOSE", "Misplace"), ("LOSS", "Defeat"),
        ("LOST", "Cannot find"), ("LOTS", "Many"), ("LOUD", "Noisy"),
        ("LOVE", "Deep affection"), ("LUCK", "Fortune"), ("LULL", "Calm period"),
        ("LUMP", "Bump"), ("LUNG", "Breathing organ"), ("LURE", "Entice"),
        ("LURK", "Hide in wait"), ("LUSH", "Rich vegetation"),
        ("MACE", "Medieval weapon"), ("MADE", "Created"), ("MAID", "Housekeeper"),
        ("MAIL", "Letters"), ("MAIN", "Primary"), ("MAKE", "Create"),
        ("MALE", "Man"), ("MALL", "Shopping center"), ("MALT", "Beer ingredient"),
        ("MANE", "Lion's hair"), ("MANY", "A lot"), ("MAPS", "Navigation aids"),
        ("MARE", "Female horse"), ("MARK", "Sign or stain"), ("MARS", "Red planet"),
        ("MASH", "Crush"), ("MASK", "Face covering"), ("MASS", "Large amount"),
        ("MAST", "Ship pole"), ("MATE", "Partner"), ("MATH", "Numbers subject"),
        ("MAZE", "Puzzle path"), ("MEAL", "Dinner or lunch"), ("MEAN", "Unkind"),
        ("MEAT", "Animal protein"), ("MELD", "Merge together"), ("MELT", "Thaw"),
        ("MEMO", "Office note"), ("MEND", "Repair"), ("MENU", "Food choices"),
        ("MERE", "Only"), ("MESA", "Flat-topped hill"), ("MESH", "Woven net"),
        ("MESS", "Disorder"), ("MICE", "Small rodents"), ("MILD", "Gentle"),
        ("MILE", "5280 feet"), ("MILK", "Dairy drink"), ("MILL", "Grain grinder"),
        ("MIME", "Silent actor"), ("MIND", "Brain"), ("MINE", "Belonging to me"),
        ("MINT", "Herb or candy"), ("MISS", "Fail to hit"), ("MIST", "Light fog"),
        ("MOAT", "Castle ditch"), ("MOCK", "Ridicule"), ("MODE", "Method"),
        ("MOLD", "Fungus"), ("MOLE", "Burrowing animal"), ("MOLT", "Shed feathers"),
        ("MONK", "Religious brother"), ("MOOD", "Emotional state"), ("MOON", "Night light"),
        ("MOOR", "Open land"), ("MORE", "Additional"), ("MOSS", "Green growth"),
        ("MOST", "Greatest amount"), ("MOTH", "Night butterfly"), ("MOVE", "Change position"),
        ("MUCH", "A lot"), ("MULE", "Hybrid animal"), ("MUSE", "Source of inspiration"),
        ("MUST", "Have to"), ("MUTE", "Silent"),
        ("NAIL", "Hammer target"), ("NAME", "What you're called"), ("NAVY", "Sea military"),
        ("NEAR", "Close by"), ("NEAT", "Tidy"), ("NECK", "Body connector"),
        ("NEED", "Require"), ("NEST", "Bird home"), ("NEWS", "Current events"),
        ("NEXT", "Following"), ("NICE", "Pleasant"), ("NINE", "After eight"),
        ("NODE", "Connection point"), ("NONE", "Zero"), ("NOON", "Midday"),
        ("NORM", "Standard"), ("NOSE", "Smell organ"), ("NOTE", "Written message"),
        ("NOUN", "Person place or thing"), ("NUMB", "Without feeling"),
        ("OAKS", "Sturdy trees"), ("OATH", "Solemn promise"), ("OBEY", "Follow orders"),
        ("ODDS", "Chances"), ("OGRE", "Fairy tale monster"), ("OILS", "Lubricants"),
        ("OKAY", "All right"), ("OMEN", "Sign of future"), ("OMIT", "Leave out"),
        ("ONCE", "One time"), ("ONLY", "Sole"), ("ONTO", "On top of"),
        ("OOZE", "Seep slowly"), ("OPAL", "Gem with rainbow colors"), ("OPEN", "Not closed"),
        ("OPTS", "Chooses"), ("ORAL", "Spoken"), ("ORCA", "Killer whale"),
        ("OVEN", "Baking appliance"), ("OVER", "Above"), ("OWED", "Was indebted"),
        ("OWLS", "Night birds"), ("OXEN", "Draft animals"),
        ("PACE", "Walking speed"), ("PACK", "Bundle"), ("PAGE", "Book leaf"),
        ("PAID", "Compensated"), ("PAIL", "Bucket"), ("PAIN", "Hurt"),
        ("PAIR", "Two of a kind"), ("PALE", "Light colored"), ("PALM", "Hand center or tree"),
        ("PANE", "Window glass"), ("PARK", "Recreation area"), ("PART", "Piece"),
        ("PASS", "Go by"), ("PAST", "Former time"), ("PATH", "Trail"),
        ("PEAK", "Mountain top"), ("PEAL", "Bell ring"), ("PEAR", "Fruit"),
        ("PEAT", "Bog fuel"), ("PEEL", "Remove skin"), ("PEER", "Equal or look closely"),
        ("PELT", "Animal skin"), ("PERK", "Benefit"), ("PEST", "Nuisance"),
        ("PICK", "Choose"), ("PIER", "Dock"), ("PIKE", "Long spear"),
        ("PILE", "Heap"), ("PINE", "Evergreen tree"), ("PINK", "Light red"),
        ("PIPE", "Tube"), ("PLAN", "Strategy"), ("PLAY", "Have fun"),
        ("PLEA", "Request"), ("PLOW", "Farm tool"), ("PLOY", "Tactic"),
        ("PLUG", "Stopper"), ("PLUM", "Purple fruit"), ("PLUS", "In addition"),
        ("POEM", "Verse"), ("POET", "Verse writer"), ("POKE", "Prod"),
        ("POLE", "Long stick"), ("POLL", "Survey"), ("POLO", "Horse sport"),
        ("POND", "Small lake"), ("POOL", "Swimming hole"), ("POOR", "Not rich"),
        ("POPE", "Catholic leader"), ("PORE", "Skin opening"), ("PORK", "Pig meat"),
        ("PORT", "Harbor"), ("POSE", "Strike a stance"), ("POST", "Mail or pole"),
        ("POUR", "Flow out"), ("PRAY", "Talk to God"), ("PREP", "Get ready"),
        ("PREY", "Hunted animal"), ("PROD", "Poke"), ("PROP", "Support"),
        ("PROW", "Ship front"), ("PRUNE", "Dried plum"), ("PULL", "Tug"),
        ("PULP", "Soft mass"), ("PUMP", "Water mover"), ("PURE", "Uncontaminated"),
        ("PUSH", "Shove"), ("QUIT", "Stop doing"),
        ("RACE", "Competition"), ("RACK", "Storage shelf"), ("RAFT", "Floating platform"),
        ("RAGE", "Fury"), ("RAID", "Sudden attack"), ("RAIL", "Fence bar"),
        ("RAIN", "Water from sky"), ("RAKE", "Leaf collector"), ("RAMP", "Incline"),
        ("RANG", "Phone sounded"), ("RANK", "Position"), ("RARE", "Uncommon"),
        ("RASH", "Skin irritation"), ("RATE", "Speed or price"), ("RAVE", "Praise wildly"),
        ("READ", "Book activity"), ("REAL", "Genuine"), ("REAM", "500 sheets"),
        ("REAR", "Back"), ("REEF", "Coral formation"), ("REEL", "Fishing spool"),
        ("RELY", "Depend on"), ("RENT", "Monthly payment"), ("REST", "Relax"),
        ("RICE", "Asian grain"), ("RICH", "Wealthy"), ("RIDE", "Travel on"),
        ("RIFT", "Split"), ("RIGS", "Trucks"), ("RIND", "Fruit skin"),
        ("RING", "Finger jewelry"), ("RINK", "Ice arena"), ("RIOT", "Violent protest"),
        ("RISE", "Go up"), ("RISK", "Danger"), ("ROAD", "Street"),
        ("ROAM", "Wander"), ("ROAR", "Lion sound"), ("ROBE", "Long garment"),
        ("ROCK", "Stone"), ("RODE", "Traveled on"), ("ROLE", "Part to play"),
        ("ROLL", "Turn over"), ("ROOF", "House top"), ("ROOM", "Indoor space"),
        ("ROOT", "Plant base"), ("ROPE", "Thick cord"), ("ROSE", "Red flower"),
        ("ROTE", "Memorization"), ("ROVE", "Wander"), ("RUDE", "Impolite"),
        ("RUIN", "Destroy"), ("RULE", "Regulation"), ("RUMP", "Backside"),
        ("RUNG", "Ladder step"), ("RUSH", "Hurry"), ("RUST", "Iron decay"),
        ("SAFE", "Secure"), ("SAGE", "Wise person"), ("SAID", "Spoke"),
        ("SAIL", "Boat fabric"), ("SAKE", "Purpose"), ("SALE", "Discount event"),
        ("SALT", "Table seasoning"), ("SAME", "Identical"), ("SAND", "Beach grains"),
        ("SANE", "Mentally sound"), ("SANG", "Performed a song"), ("SANK", "Went under"),
        ("SASH", "Window frame"), ("SAVE", "Rescue"), ("SEAL", "Ocean mammal"),
        ("SEAM", "Sewing joint"), ("SEAT", "Chair"), ("SEED", "Plant starter"),
        ("SEEK", "Search for"), ("SEEM", "Appear"), ("SEEN", "Viewed"),
        ("SELF", "One's own person"), ("SELL", "Vend"), ("SEND", "Mail off"),
        ("SENT", "Mailed"), ("SHED", "Small barn"), ("SHIN", "Front of leg"),
        ("SHIP", "Large vessel"), ("SHOE", "Foot covering"), ("SHOP", "Store"),
        ("SHOT", "Quick photo"), ("SHOW", "Display"), ("SHUT", "Close"),
        ("SIDE", "Edge"), ("SIGH", "Deep breath"), ("SIGN", "Poster"),
        ("SILK", "Fine fabric"), ("SILT", "River sediment"), ("SING", "Vocalize"),
        ("SINK", "Kitchen basin"), ("SIRE", "Father"), ("SITE", "Location"),
        ("SIZE", "Dimensions"), ("SKIT", "Short comedy"), ("SLAB", "Thick slice"),
        ("SLAM", "Bang shut"), ("SLAP", "Sharp hit"), ("SLAW", "Cabbage salad"),
        ("SLED", "Snow vehicle"), ("SLEW", "Killed"), ("SLID", "Moved smoothly"),
        ("SLIM", "Thin"), ("SLIP", "Slide"), ("SLIT", "Narrow cut"),
        ("SLOB", "Messy person"), ("SLOT", "Narrow opening"), ("SLOW", "Not fast"),
        ("SLUG", "Garden pest"), ("SLUM", "Run-down area"), ("SMOG", "Dirty air"),
        ("SNAP", "Quick break"), ("SNIP", "Small cut"), ("SNOB", "Elitist"),
        ("SNOW", "Winter flakes"), ("SNUB", "Cold shoulder"), ("SNUG", "Cozy fit"),
        ("SOAK", "Drench"), ("SOAP", "Cleaning bar"), ("SOAR", "Fly high"),
        ("SOCK", "Foot garment"), ("SODA", "Fizzy drink"), ("SOFA", "Living room seat"),
        ("SOFT", "Not hard"), ("SOIL", "Garden dirt"), ("SOLD", "Vended"),
        ("SOLE", "Only one"), ("SOME", "A few"), ("SONG", "Musical piece"),
        ("SOON", "Before long"), ("SORE", "Painful"), ("SORT", "Organize"),
        ("SOUL", "Inner spirit"), ("SOUP", "Liquid meal"), ("SOUR", "Tart taste"),
        ("SPAN", "Stretch across"), ("SPAR", "Boxing practice"), ("SPEC", "Specification"),
        ("SPED", "Raced"), ("SPIN", "Turn around"), ("SPIT", "Eject from mouth"),
        ("SPOT", "Location"), ("SPUR", "Motivate"), ("STAB", "Pierce"),
        ("STAG", "Male deer"), ("STAR", "Night sky light"), ("STAY", "Remain"),
        ("STEM", "Plant stalk"), ("STEP", "Footfall"), ("STEW", "Slow-cooked dish"),
        ("STIR", "Mix around"), ("STOP", "Halt"), ("STUB", "Ticket remainder"),
        ("STUD", "Wall support"), ("STUN", "Shock"), ("SUCH", "Of that kind"),
        ("SUIT", "Business attire"), ("SULK", "Brood"), ("SUNG", "Performed vocally"),
        ("SUNK", "Went down"), ("SURE", "Certain"), ("SURF", "Ride waves"),
        ("SWAN", "Elegant bird"), ("SWAP", "Trade"), ("SWIM", "Water exercise"),

        ("TABS", "Bar bills"), ("TACK", "Small nail"), ("TACT", "Diplomacy"),
        ("TAIL", "Animal rear end"), ("TAKE", "Grab"), ("TALE", "Story"),
        ("TALK", "Speak"), ("TALL", "High"), ("TAME", "Domesticated"),
        ("TANK", "Large container"), ("TAPE", "Adhesive strip"), ("TAPS", "Faucets"),
        ("TART", "Sour pastry"), ("TASK", "Job to do"), ("TAXI", "Hired car"),
        ("TEAK", "Tropical wood"), ("TEAL", "Blue-green color"), ("TEAM", "Group"),
        ("TEAR", "Rip"), ("TELL", "Inform"), ("TEND", "Look after"),
        ("TENT", "Camping shelter"), ("TERM", "Time period"), ("TEST", "Exam"),
        ("TEXT", "Written words"), ("THAT", "Demonstrative pronoun"), ("THEM", "Those people"),
        ("THEN", "After that"), ("THEY", "Those people"), ("THIN", "Not thick"),
        ("THIS", "Demonstrative pronoun"), ("THUS", "Therefore"), ("TICK", "Clock sound"),
        ("TIDE", "Ocean rise"), ("TIDY", "Neat"), ("TIED", "Knotted"),
        ("TIER", "Level or row"), ("TILE", "Floor covering"), ("TILL", "Until"),
        ("TILT", "Lean"), ("TIME", "Clock reading"), ("TINE", "Fork prong"),
        ("TINY", "Very small"), ("TIRE", "Wheel rubber"), ("TOAD", "Warty amphibian"),
        ("TOIL", "Hard work"), ("TOLD", "Informed"), ("TOLL", "Bell sound or fee"),
        ("TOMB", "Burial place"), ("TONE", "Sound quality"), ("TOOK", "Grabbed"),
        ("TOOL", "Implement"), ("TOPS", "Highest points"), ("TORE", "Ripped"),
        ("TORN", "Ripped"), ("TORT", "Legal wrong"), ("TOSS", "Throw lightly"),
        ("TOUR", "Sightseeing trip"), ("TOWN", "Small city"), ("TOYS", "Playthings"),
        ("TRAP", "Snare"), ("TRAY", "Serving plate"), ("TREE", "Tall plant"),
        ("TREK", "Long journey"), ("TRIM", "Cut edges"), ("TRIO", "Group of three"),
        ("TRIP", "Journey"), ("TROD", "Walked on"), ("TROT", "Horse gait"),
        ("TRUE", "Not false"), ("TUBE", "Hollow cylinder"), ("TUCK", "Fold under"),
        ("TUFT", "Small cluster"), ("TUNA", "Ocean fish"), ("TUNE", "Melody"),
        ("TURF", "Grass surface"), ("TURN", "Rotate"), ("TUSK", "Elephant tooth"),
        ("TWIN", "One of two"), ("TYPE", "Kind or keyboard"),
        ("UGLY", "Not attractive"), ("UNIT", "Single piece"), ("UPON", "On top of"),
        ("URGE", "Strong desire"), ("USED", "Not new"), ("USER", "Person who uses"),
        ("VALE", "Valley"), ("VANE", "Wind direction indicator"), ("VASE", "Flower holder"),
        ("VAST", "Enormous"), ("VEIL", "Face covering"), ("VEIN", "Blood vessel"),
        ("VENT", "Air opening"), ("VERB", "Action word"), ("VERY", "Extremely"),
        ("VEST", "Sleeveless garment"), ("VETO", "Presidential rejection"),
        ("VIEW", "Vista"), ("VINE", "Climbing plant"), ("VISA", "Travel document"),
        ("VOID", "Empty space"), ("VOLT", "Electrical unit"), ("VOTE", "Cast a ballot"),
        ("WADE", "Walk through water"), ("WAGE", "Pay"), ("WAIL", "Cry loudly"),
        ("WAIT", "Be patient"), ("WAKE", "Get up"), ("WALK", "Stroll"),
        ("WALL", "Room divider"), ("WAND", "Magic stick"), ("WANT", "Desire"),
        ("WARD", "Hospital section"), ("WARM", "Slightly hot"), ("WARN", "Alert"),
        ("WARP", "Bend out of shape"), ("WART", "Skin bump"), ("WASH", "Clean"),
        ("WASP", "Stinging insect"), ("WAVE", "Ocean swell"), ("WAVY", "Not straight"),
        ("WAXY", "Like a candle"), ("WEAK", "Not strong"), ("WEAR", "Put on clothes"),
        ("WEED", "Garden pest"), ("WEEK", "Seven days"), ("WEEP", "Cry"),
        ("WELD", "Join metals"), ("WELL", "Water source"), ("WENT", "Traveled"),
        ("WERE", "Past plural of be"), ("WEST", "Sunset direction"), ("WHAT", "Which thing"),
        ("WHEN", "At what time"), ("WHIM", "Sudden idea"), ("WHIP", "Crack tool"),
        ("WHOM", "Objective who"), ("WICK", "Candle string"), ("WIDE", "Broad"),
        ("WIFE", "Married woman"), ("WILD", "Untamed"), ("WILL", "Future tense helper"),
        ("WILT", "Droop"), ("WILY", "Cunning"), ("WIMP", "Coward"),
        ("WIND", "Moving air"), ("WINE", "Grape drink"), ("WING", "Bird part"),
        ("WINK", "Eye gesture"), ("WIPE", "Clean off"), ("WIRE", "Metal thread"),
        ("WISE", "Full of wisdom"), ("WISH", "Desire"), ("WISP", "Thin strand"),
        ("WITH", "Alongside"), ("WOKE", "Became alert"), ("WOLF", "Wild canine"),
        ("WOMB", "Uterus"), ("WOOD", "Tree material"), ("WOOL", "Sheep fiber"),
        ("WORD", "Language unit"), ("WORE", "Had on"), ("WORK", "Labor"),
        ("WORM", "Crawling creature"), ("WORN", "Used up"), ("WOVE", "Made fabric"),
        ("WRAP", "Cover up"), ("WREN", "Small bird"), ("YANK", "Pull sharply"),
        ("YARD", "Outdoor area"), ("YARN", "Knitting thread"), ("YEAR", "365 days"),
        ("YELL", "Shout"), ("YOGA", "Flexibility practice"), ("YOKE", "Oxen harness"),
        ("YOUR", "Belonging to you"), ("ZEAL", "Enthusiasm"), ("ZERO", "Nothing"),
        ("ZEST", "Lemon peel or enthusiasm"), ("ZINC", "Metal element"),
        ("ZONE", "Area"),
    ],
    5: [
        ("ABIDE", "Put up with"), ("ABOUT", "Approximately"), ("ABOVE", "Higher than"),
        ("ABUSE", "Mistreat"), ("ACUTE", "Sharp"), ("ADAPT", "Adjust"),
        ("ADEPT", "Skilled"), ("ADMIT", "Confess"), ("ADOPT", "Take in"),
        ("ADULT", "Grown-up"), ("AFTER", "Following"), ("AGAIN", "Once more"),
        ("AGENT", "Representative"), ("AGILE", "Nimble"), ("AGING", "Getting older"),
        ("AGREE", "See eye to eye"), ("AHEAD", "In front"), ("AISLE", "Theater walkway"),
        ("ALARM", "Warning sound"), ("ALBUM", "Photo book or music collection"),
        ("ALERT", "Watchful"), ("ALIEN", "Extraterrestrial"), ("ALIGN", "Line up"),
        ("ALIKE", "Similar"), ("ALIVE", "Living"), ("ALLEY", "Narrow street"),
        ("ALLOT", "Distribute"), ("ALLOW", "Permit"), ("ALONE", "By oneself"),
        ("ALONG", "Beside"), ("ALTER", "Change"), ("AMPLE", "Plenty"),
        ("ANGEL", "Heavenly being"), ("ANGER", "Fury"), ("ANGLE", "Corner degree"),
        ("ANKLE", "Foot joint"), ("APPLE", "Red fruit"), ("APPLY", "Put on or request"),
        ("ARENA", "Sports venue"), ("ARGUE", "Debate"), ("ARISE", "Come up"),
        ("ARMOR", "Protective covering"), ("ARRAY", "Impressive display"),
        ("ASIDE", "To the side"), ("ASSET", "Valuable thing"), ("ATLAS", "Map book"),
        ("ATTIC", "Top floor room"), ("AVOID", "Stay away from"), ("AWAKE", "Not sleeping"),
        ("AWARD", "Prize"), ("AWARE", "Conscious of"),
        ("BADGE", "ID pin"), ("BAKER", "Bread maker"), ("BASIC", "Fundamental"),
        ("BASIN", "Wash bowl"), ("BASIS", "Foundation"), ("BATCH", "Group produced together"),
        ("BEACH", "Sandy shore"), ("BEAST", "Wild animal"), ("BEGIN", "Start"),
        ("BEING", "Existence"), ("BELOW", "Under"), ("BENCH", "Park seat"),
        ("BLACK", "Darkest color"), ("BLADE", "Knife edge"), ("BLAME", "Hold responsible"),
        ("BLAND", "Without flavor"), ("BLANK", "Empty"), ("BLAST", "Explosion"),
        ("BLAZE", "Intense fire"), ("BLEAK", "Gloomy"), ("BLEED", "Lose blood"),
        ("BLEND", "Mix together"), ("BLESS", "Give thanks"), ("BLIND", "Cannot see"),
        ("BLISS", "Pure happiness"), ("BLOCK", "Obstruct"), ("BLOOM", "Flower"),
        ("BLOWN", "Wind-moved"), ("BOARD", "Wooden plank"), ("BOAST", "Brag"),
        ("BONUS", "Extra reward"), ("BOOTH", "Small enclosure"), ("BOUND", "Headed for"),
        ("BRAIN", "Thinking organ"), ("BRAND", "Company name"), ("BRAVE", "Courageous"),
        ("BREAD", "Bakery staple"), ("BREAK", "Fracture"), ("BREED", "Animal type"),
        ("BRICK", "Building block"), ("BRIDE", "Wedding woman"), ("BRIEF", "Short"),
        ("BRING", "Carry to"), ("BRISK", "Quick and energetic"), ("BROAD", "Wide"),
        ("BROKE", "Without money"), ("BROOK", "Small stream"), ("BROTH", "Soup base"),
        ("BROWN", "Earth color"), ("BRUSH", "Hair tool"), ("BUILD", "Construct"),
        ("BUILT", "Constructed"), ("BUNCH", "Cluster"), ("BURST", "Pop"),
        ("BUYER", "Purchaser"),
        ("CABIN", "Log house"), ("CAMEL", "Desert animal"), ("CANDY", "Sweet treat"),
        ("CARGO", "Ship's load"), ("CARRY", "Transport"), ("CATCH", "Grab"),
        ("CAUSE", "Reason"), ("CEASE", "Stop"), ("CHAIN", "Linked metal"),
        ("CHAIR", "Seat"), ("CHALK", "Writing stick"), ("CHAMP", "Winner"),
        ("CHAOS", "Total disorder"), ("CHARM", "Appeal"), ("CHART", "Graph"),
        ("CHASE", "Pursue"), ("CHEAP", "Inexpensive"), ("CHEAT", "Deceive"),
        ("CHECK", "Verify"), ("CHEEK", "Face side"), ("CHEER", "Root for"),
        ("CHESS", "Board game"), ("CHEST", "Torso front"), ("CHIEF", "Leader"),
        ("CHILD", "Young one"), ("CHILL", "Cool down"), ("CHINA", "Porcelain"),
        ("CHIRP", "Bird sound"), ("CHOIR", "Singing group"), ("CHORD", "Musical notes"),
        ("CHUNK", "Large piece"), ("CLAIM", "Assert"), ("CLASH", "Conflict"),
        ("CLASP", "Fastener"), ("CLASS", "School group"), ("CLEAN", "Not dirty"),
        ("CLEAR", "Transparent"), ("CLERK", "Store worker"), ("CLIFF", "Steep rock face"),
        ("CLIMB", "Go up"), ("CLING", "Hold tight"), ("CLOCK", "Timepiece"),
        ("CLOSE", "Shut"), ("CLOTH", "Fabric"), ("CLOUD", "Sky puff"),
        ("CLOWN", "Circus performer"), ("COACH", "Trainer"), ("COAST", "Shoreline"),
        ("COLOR", "Hue"), ("COMET", "Space traveler with tail"), ("COMIC", "Funny"),
        ("CORAL", "Reef material"), ("COUNT", "Number up"), ("COURT", "Tennis area or legal place"),
        ("COVER", "Put over"), ("CRACK", "Split"), ("CRAFT", "Skilled trade"),
        ("CRANE", "Construction machine"), ("CRASH", "Collision"), ("CRATE", "Shipping box"),
        ("CRAZE", "Fad"), ("CRAZY", "Insane"), ("CREAM", "Coffee additive"),
        ("CREEK", "Small stream"), ("CREST", "Wave top"), ("CRIME", "Illegal act"),
        ("CRISP", "Crunchy"), ("CROSS", "Angry or go across"), ("CROWD", "Large group"),
        ("CROWN", "Royal headpiece"), ("CRUDE", "Rough"), ("CRUSH", "Squash"),
        ("CURVE", "Bend"), ("CYCLE", "Repeating pattern"),
        ("DAILY", "Every day"), ("DAIRY", "Milk farm"), ("DANCE", "Move to music"),
        ("DECAY", "Rot"), ("DELTA", "River mouth"), ("DENSE", "Thick"),
        ("DEPTH", "How deep"), ("DERBY", "Horse race"), ("DEVIL", "Evil spirit"),
        ("DIRTY", "Not clean"), ("DITCH", "Roadside trench"), ("DIZZY", "Light-headed"),
        ("DODGE", "Avoid"), ("DOUBT", "Uncertainty"), ("DOUGH", "Bread mix"),
        ("DRAFT", "First version"), ("DRAIN", "Empty out"), ("DRAPE", "Curtain"),
        ("DRAWN", "Sketched"), ("DREAD", "Fear greatly"), ("DREAM", "Sleep vision"),
        ("DRESS", "Woman's garment"), ("DRIED", "Dehydrated"), ("DRIFT", "Float along"),
        ("DRILL", "Boring tool"), ("DRINK", "Beverage"), ("DRIVE", "Operate a car"),
        ("DROWN", "Sink in water"), ("DRUMS", "Percussion set"), ("DRUNK", "Intoxicated"),
        ("DWARF", "Small fairy tale character"), ("DWELL", "Reside"),
        ("EAGER", "Very keen"), ("EAGLE", "Bird of prey"), ("EARLY", "Before time"),
        ("EARTH", "Our planet"), ("EASEL", "Painter's stand"), ("EIGHT", "After seven"),
        ("ELECT", "Choose by vote"), ("ELITE", "Top tier"), ("EMBER", "Glowing coal"),
        ("EMPTY", "Nothing inside"), ("ENEMY", "Foe"), ("ENJOY", "Take pleasure in"),
        ("ENTER", "Go into"), ("ENTRY", "Way in"), ("EQUAL", "Same amount"),
        ("ERASE", "Rub out"), ("ERROR", "Mistake"), ("EVENT", "Happening"),
        ("EVERY", "Each one"), ("EXACT", "Precise"), ("EXILE", "Banishment"),
        ("EXIST", "Be real"), ("EXTRA", "Additional"),
        ("FABLE", "Moral story"), ("FACED", "Confronted"), ("FAITH", "Belief"),
        ("FALSE", "Not true"), ("FEAST", "Big meal"), ("FENCE", "Yard boundary"),
        ("FIBER", "Thread"), ("FIELD", "Open land"), ("FIERY", "Like fire"),
        ("FIGHT", "Battle"), ("FINAL", "Last"), ("FIRST", "Before all others"),
        ("FLAME", "Fire tongue"), ("FLANK", "Side of body"), ("FLARE", "Bright signal"),
        ("FLASH", "Quick light"), ("FLASK", "Small bottle"), ("FLESH", "Body tissue"),
        ("FLOAT", "Stay on water"), ("FLOCK", "Group of birds"), ("FLOOD", "Water overflow"),
        ("FLOOR", "Room bottom"), ("FLORA", "Plant life"), ("FLOUR", "Baking powder"),
        ("FLOWN", "Traveled by air"), ("FLUID", "Liquid"), ("FLUTE", "Wind instrument"),
        ("FOCAL", "Central"), ("FOCUS", "Concentrate"), ("FORCE", "Power"),
        ("FORGE", "Metal workshop"), ("FORTH", "Forward"), ("FORUM", "Discussion place"),
        ("FOUND", "Discovered"), ("FRAME", "Picture border"), ("FRANK", "Honest"),
        ("FRAUD", "Deception"), ("FREED", "Liberated"), ("FRESH", "New"),
        ("FRONT", "Forward side"), ("FROST", "Ice crystals"), ("FROZE", "Became ice"),
        ("FRUIT", "Apple or banana"), ("FULLY", "Completely"), ("FUNDS", "Money"),
        ("FUZZY", "Not clear"),
        ("GAUGE", "Measuring tool"), ("GHOST", "Spirit"), ("GIANT", "Very large"),
        ("GIVEN", "Donated"), ("GLAND", "Body organ"), ("GLARE", "Harsh light"),
        ("GLASS", "Drinking vessel"), ("GLEAM", "Shine"), ("GLOBE", "World sphere"),
        ("GLOOM", "Darkness"), ("GLOSS", "Shiny finish"), ("GLOVE", "Hand covering"),
        ("GOOSE", "Honking bird"), ("GRACE", "Elegance"), ("GRADE", "School mark"),
        ("GRAIN", "Wheat or rice"), ("GRAND", "Magnificent"), ("GRANT", "Give formally"),
        ("GRAPE", "Wine fruit"), ("GRASP", "Grip"), ("GRASS", "Lawn covering"),
        ("GRATE", "Shred cheese"), ("GRAVE", "Burial site"), ("GRAVY", "Meat sauce"),
        ("GRAZE", "Feed on grass"), ("GREAT", "Wonderful"), ("GREED", "Excessive want"),
        ("GREEN", "Grass color"), ("GREET", "Say hello"), ("GRIEF", "Deep sadness"),
        ("GRILL", "Barbecue"), ("GRIND", "Crush fine"), ("GROAN", "Pain sound"),
        ("GROOM", "Wedding man"), ("GROUP", "Collection"), ("GROVE", "Small forest"),
        ("GROWL", "Dog warning"), ("GROWN", "Matured"), ("GUARD", "Protector"),
        ("GUESS", "Estimate"), ("GUIDE", "Leader"), ("GUILT", "Blame feeling"),
        ("GULCH", "Narrow ravine"), ("GUMMY", "Chewy candy"),
        ("HAPPY", "Joyful"), ("HARDY", "Tough"), ("HASTE", "Hurry"),
        ("HAVEN", "Safe place"), ("HEART", "Love organ"), ("HEAVY", "Weighs a lot"),
        ("HEDGE", "Bush fence"), ("HEIST", "Robbery"), ("HERON", "Wading bird"),
        ("HONEY", "Bee product"), ("HONOR", "Respect"), ("HORSE", "Riding animal"),
        ("HOTEL", "Lodging"), ("HOUND", "Hunting dog"), ("HOUSE", "Dwelling"),
        ("HUMAN", "Person"), ("HUMOR", "Comedy"), ("HURRY", "Rush"),
        ("IMAGE", "Picture"), ("IMPLY", "Suggest"), ("INBOX", "Email folder"),
        ("INDEX", "Alphabetical list"), ("INNER", "Inside"), ("INPUT", "Data entered"),
        ("IVORY", "Tusk material"),
        ("JEWEL", "Precious gem"), ("JOKER", "Card or comedian"), ("JOLLY", "Merry"),
        ("JUDGE", "Court official"), ("JUICE", "Fruit drink"),
        ("KAYAK", "Small boat"), ("KNIFE", "Cutting tool"), ("KNOCK", "Rap on door"),

        ("LABEL", "Tag"), ("LABOR", "Hard work"), ("LARGE", "Big"),
        ("LASER", "Focused light"), ("LATCH", "Door fastener"), ("LATER", "After this"),
        ("LAUGH", "React to humor"), ("LAYER", "Coating"), ("LEAFY", "Full of leaves"),
        ("LEAPT", "Jumped"), ("LEARN", "Study"), ("LEASE", "Rental agreement"),
        ("LEAVE", "Depart"), ("LEGAL", "Lawful"), ("LEMON", "Sour citrus"),
        ("LEVEL", "Flat"), ("LEVER", "Prying tool"), ("LIGHT", "Illumination"),
        ("LILAC", "Purple flower"), ("LIMIT", "Boundary"), ("LINEN", "Fine fabric"),
        ("LINER", "Ship"), ("LOCAL", "Nearby"), ("LODGE", "Cabin"),
        ("LOGIC", "Reasoning"), ("LOOSE", "Not tight"), ("LOVER", "Romantic partner"),
        ("LOWER", "Bring down"), ("LOYAL", "Faithful"), ("LUCKY", "Fortunate"),
        ("LUNAR", "Moon-related"), ("LUNCH", "Midday meal"),
        ("MAGIC", "Sorcery"), ("MAJOR", "Significant"), ("MANOR", "Large estate"),
        ("MAPLE", "Syrup tree"), ("MARCH", "Walk in step"), ("MATCH", "Game or equal"),
        ("MAYOR", "City leader"), ("MEDAL", "Award disc"), ("MEDIA", "News outlets"),
        ("MELON", "Large fruit"), ("MERGE", "Combine"), ("MERIT", "Deserve"),
        ("METAL", "Iron or steel"), ("METER", "Measuring device"), ("MICRO", "Very small"),
        ("MIGHT", "Power"), ("MINOR", "Small or underage"), ("MINUS", "Less"),
        ("MIRTH", "Amusement"), ("MODEL", "Example"), ("MONEY", "Currency"),
        ("MONTH", "Year division"), ("MOOSE", "Large deer"), ("MORAL", "Ethical lesson"),
        ("MOTOR", "Engine"), ("MOUND", "Small hill"), ("MOUNT", "Climb"),
        ("MOUSE", "Small rodent"), ("MOUTH", "Oral opening"), ("MOVIE", "Film"),
        ("MUDDY", "Dirty"), ("MUSIC", "Melodic art"),
        ("NAIVE", "Innocent"), ("NERVE", "Body wire"), ("NEVER", "Not ever"),
        ("NIGHT", "After dark"), ("NOBLE", "Dignified"), ("NOISE", "Loud sound"),
        ("NORTH", "Compass direction"), ("NOTED", "Famous"), ("NOVEL", "Book"),
        ("NURSE", "Medical caretaker"),
        ("OASIS", "Desert spring"), ("OCEAN", "Large body of water"),
        ("OLIVE", "Green fruit"), ("ONSET", "Beginning"), ("OPERA", "Singing drama"),
        ("ORBIT", "Space path"), ("ORDER", "Command"), ("ORGAN", "Body part or instrument"),
        ("OTHER", "Different"), ("OUTER", "External"), ("OWNER", "Possessor"),
        ("OXIDE", "Chemical compound"),
        ("PANDA", "Black and white bear"), ("PANEL", "Flat section"),
        ("PANIC", "Sudden fear"), ("PASTE", "Sticky substance"), ("PATCH", "Repair piece"),
        ("PAUSE", "Brief stop"), ("PEACE", "No war"), ("PEACH", "Fuzzy fruit"),
        ("PEARL", "Oyster gem"), ("PEDAL", "Bike part"), ("PENNY", "One cent"),
        ("PERCH", "Bird seat"), ("PHASE", "Stage"), ("PHONE", "Calling device"),
        ("PIANO", "Keyboard instrument"), ("PIECE", "Part"), ("PILOT", "Plane driver"),
        ("PINCH", "Squeeze"), ("PITCH", "Throw or sound"), ("PIXEL", "Screen dot"),
        ("PIZZA", "Italian pie"), ("PLACE", "Location"), ("PLAID", "Checkered pattern"),
        ("PLAIN", "Simple"), ("PLANE", "Aircraft"), ("PLANK", "Wood board"),
        ("PLANT", "Growing thing"), ("PLATE", "Dinner dish"), ("PLAZA", "Public square"),
        ("PLEAD", "Beg"), ("PLEAT", "Fabric fold"), ("PLUCK", "Pick"),
        ("PLUMB", "Straight down"), ("PLUME", "Feather"), ("PLUMP", "Chubby"),
("POINT", "Sharp tip"), ("POLAR", "Arctic"),
        ("POOCH", "Pet dog"), ("PORCH", "House front"), ("POSSE", "Sheriff's group"),
        ("POUCH", "Small bag"), ("POUND", "Weight unit"), ("POWER", "Strength"),
        ("PRESS", "Push or media"), ("PRICE", "Cost"), ("PRIDE", "Self-respect"),
        ("PRIME", "First quality"), ("PRINT", "Put on paper"), ("PRIOR", "Before"),
        ("PRIZE", "Award"), ("PROBE", "Investigate"), ("PROOF", "Evidence"),
        ("PROSE", "Written text"), ("PROUD", "Self-satisfied"), ("PROVE", "Demonstrate"),
        ("PROWL", "Creep around"), ("PRUNE", "Dried plum"), ("PULSE", "Heartbeat"),
        ("PUNCH", "Hit with fist"), ("PUPIL", "Student"), ("PURSE", "Handbag"),
        ("QUAIL", "Small bird"), ("QUEEN", "Royal woman"), ("QUERY", "Question"),
        ("QUEST", "Search"), ("QUICK", "Fast"), ("QUIET", "Not loud"),
        ("QUILT", "Bed covering"), ("QUIRK", "Oddity"), ("QUOTA", "Set amount"),
        ("QUOTE", "Repeat words"),
        ("RADAR", "Detection system"), ("RADIO", "Broadcast receiver"), ("RAISE", "Lift up"),
        ("RALLY", "Gathering"), ("RANCH", "Large farm"), ("RANGE", "Extent"),
        ("RAPID", "Very fast"), ("RAVEN", "Black bird"), ("REACH", "Extend to"),
        ("READY", "Prepared"), ("REALM", "Kingdom"), ("REBEL", "Resist authority"),
        ("REIGN", "Rule"), ("RELAX", "Unwind"), ("RENAL", "Kidney-related"),
        ("REPLY", "Answer"), ("RIDER", "Horseback person"), ("RIDGE", "Mountain top"),
        ("RIFLE", "Long gun"), ("RIGHT", "Correct"), ("RIGID", "Stiff"),
        ("RIPEN", "Mature"), ("RISEN", "Gone up"), ("RIVAL", "Competitor"),
        ("RIVER", "Water flow"), ("ROAST", "Oven cook"), ("ROBOT", "Machine worker"),
        ("ROCKY", "Full of stones"), ("ROGUE", "Scoundrel"), ("ROUGH", "Not smooth"),
        ("ROUND", "Circular"), ("ROUTE", "Path"), ("ROYAL", "Of a king"),
        ("RULER", "Measuring stick"), ("RURAL", "Country"),
        ("SAINT", "Holy person"), ("SALAD", "Green dish"), ("SAUCE", "Flavor liquid"),
        ("SCALE", "Weighing device"), ("SCARE", "Frighten"), ("SCARF", "Neck wrap"),
        ("SCENE", "Setting"), ("SCENT", "Smell"), ("SCOPE", "Range"),
        ("SCORE", "Points"), ("SCOUT", "Explorer"), ("SCRAP", "Small piece"),
        ("SENSE", "Feeling"), ("SERVE", "Help or tennis start"), ("SEVEN", "Lucky number"),
        ("SHADE", "Shadow"), ("SHALL", "Will"), ("SHAME", "Disgrace"),
        ("SHAPE", "Form"), ("SHARE", "Give a portion"), ("SHARK", "Ocean predator"),
        ("SHARP", "Pointed"), ("SHAVE", "Remove beard"), ("SHEET", "Bed linen"),
        ("SHELF", "Storage ledge"), ("SHELL", "Outer casing"), ("SHIFT", "Change"),
        ("SHINE", "Give off light"), ("SHOCK", "Surprise"), ("SHORE", "Waterfront"),
        ("SHORT", "Not tall"), ("SHOUT", "Yell"), ("SHOVE", "Push hard"),
        ("SHRUB", "Small bush"), ("SIGHT", "Vision"), ("SILLY", "Goofy"),
        ("SINCE", "From then"), ("SIXTH", "After fifth"), ("SIXTY", "Six tens"),
        ("SKATE", "Ice glide"), ("SKILL", "Ability"), ("SKIRT", "Lower garment"),
        ("SKULL", "Head bone"), ("SLATE", "Rock type"), ("SLAVE", "Forced worker"),
        ("SLEEP", "Rest at night"), ("SLICE", "Thin piece"), ("SLIDE", "Playground equipment"),
        ("SLOPE", "Incline"), ("SMELL", "Odor"), ("SMILE", "Happy face"),
        ("SMOKE", "Fire output"), ("SNACK", "Light meal"), ("SNAIL", "Slow creature"),
        ("SNAKE", "Legless reptile"), ("SNARE", "Trap"), ("SNEAK", "Move stealthily"),
        ("SOLAR", "Sun-related"), ("SOLID", "Not liquid"), ("SOLVE", "Figure out"),
        ("SOUTH", "Compass direction"), ("SPACE", "Outer void"), ("SPARE", "Extra"),
        ("SPARK", "Tiny fire"), ("SPEAK", "Talk"), ("SPEAR", "Throwing weapon"),
        ("SPEED", "Velocity"), ("SPELL", "Word letters"), ("SPEND", "Use money"),
        ("SPICE", "Flavor additive"), ("SPILL", "Accidental pour"), ("SPINE", "Backbone"),
        ("SPOKE", "Said"), ("SPOON", "Soup utensil"), ("SPORT", "Athletic game"),
        ("SPRAY", "Mist"), ("STAFF", "Employees"), ("STAGE", "Theater platform"),
        ("STAIN", "Spot"), ("STAIR", "Step"), ("STAKE", "Wager or post"),
        ("STALE", "Not fresh"), ("STALK", "Plant stem"), ("STALL", "Delay"),
        ("STAMP", "Postage"), ("STAND", "Be upright"), ("STARE", "Look fixedly"),
        ("START", "Begin"), ("STATE", "Condition or region"), ("STAYS", "Remains"),
        ("STEAK", "Beef cut"), ("STEAL", "Take illegally"), ("STEAM", "Hot vapor"),
        ("STEEL", "Strong metal"), ("STEEP", "Very inclined"), ("STEER", "Guide"),
        ("STERN", "Ship rear"), ("STICK", "Branch"), ("STIFF", "Rigid"),
        ("STILL", "Not moving"), ("STING", "Bee attack"), ("STINK", "Bad smell"),
        ("STOCK", "Inventory"), ("STOLE", "Took"), ("STONE", "Rock"),
        ("STOOD", "Was upright"), ("STOOL", "Backless seat"), ("STORE", "Shop"),
        ("STORK", "Baby-bringing bird"), ("STORM", "Violent weather"),
        ("STORY", "Narrative"), ("STOUT", "Sturdy"), ("STOVE", "Kitchen cooker"),
        ("STRAP", "Fastening band"), ("STRAW", "Drinking tube"), ("STRAY", "Wander"),
        ("STRIP", "Narrow piece"), ("STUCK", "Unable to move"), ("STUDY", "Learn"),
        ("STUFF", "Things"), ("STUMP", "Tree remnant"), ("STYLE", "Fashion"),
        ("SUGAR", "Sweet crystal"), ("SUITE", "Room set"), ("SUNNY", "Bright weather"),
        ("SUPER", "Great"), ("SURGE", "Sudden increase"), ("SWAMP", "Wetland"),
        ("SWARM", "Large group"), ("SWEAR", "Promise"), ("SWEAT", "Perspire"),
        ("SWEEP", "Clean with broom"), ("SWEET", "Sugary"), ("SWEPT", "Cleaned"),
        ("SWIFT", "Very fast"), ("SWING", "Playground ride"), ("SWIRL", "Spin around"),
        ("SWORD", "Fighting blade"),
        ("TABLE", "Dining surface"), ("TASTE", "Flavor sense"), ("TEACH", "Instruct"),
        ("TEETH", "Mouth bones"), ("TEMPO", "Music speed"), ("TENSE", "Tight"),
        ("THICK", "Not thin"), ("THIEF", "Robber"), ("THING", "Object"),
        ("THINK", "Ponder"), ("THORN", "Rose prickle"), ("THREE", "After two"),
        ("THREW", "Tossed"), ("THROW", "Toss"), ("THUMB", "Hand digit"),
        ("TIGER", "Striped cat"), ("TIGHT", "Snug"), ("TIMER", "Countdown device"),
        ("TITLE", "Name"), ("TOAST", "Breakfast bread"), ("TODAY", "This day"),
        ("TOKEN", "Symbol"), ("TOTAL", "Sum"), ("TOUCH", "Feel"),
        ("TOUGH", "Hard"), ("TOWER", "Tall structure"), ("TOXIC", "Poisonous"),
        ("TRACE", "Follow"), ("TRACK", "Path"), ("TRADE", "Exchange"),
        ("TRAIL", "Hiking path"), ("TRAIN", "Railroad vehicle"), ("TRAIT", "Characteristic"),
        ("TRASH", "Garbage"), ("TREAT", "Special reward"), ("TREND", "Fashion direction"),
        ("TRIAL", "Court case"), ("TRIBE", "Native group"), ("TRICK", "Prank"),
        ("TROUT", "Freshwater fish"), ("TRUCK", "Large vehicle"), ("TRULY", "Honestly"),
        ("TRUMP", "Outdo"), ("TRUNK", "Tree base or car storage"), ("TRUST", "Have faith"),
        ("TRUTH", "Fact"), ("TUMOR", "Growth"), ("TUNER", "Radio adjuster"),
        ("TULIP", "Spring flower"), ("TWICE", "Two times"), ("TWIST", "Turn"),
        ("ULTRA", "Extreme"), ("UNCLE", "Parent's brother"), ("UNDER", "Below"),
        ("UNION", "Workers group"), ("UNITE", "Join together"), ("UNITY", "Togetherness"),
        ("UNTIL", "Up to"), ("UPPER", "Higher"), ("UPSET", "Disturbed"),
        ("URBAN", "City"), ("USUAL", "Normal"), ("UTTER", "Speak or complete"),
        ("VALID", "Legitimate"), ("VALUE", "Worth"), ("VAPOR", "Steam"),
        ("VAULT", "Secure room"), ("VERSE", "Poem section"), ("VIDEO", "Moving pictures"),
        ("VIGOR", "Energy"), ("VINYL", "Record material"), ("VIOLA", "String instrument"),
        ("VIPER", "Poisonous snake"), ("VISIT", "Go see"), ("VITAL", "Essential"),
        ("VIVID", "Bright"), ("VOCAL", "Outspoken"), ("VOICE", "Speech sound"),
        ("VOTER", "Ballot caster"),
        ("WASTE", "Throw away"), ("WATCH", "Timepiece"), ("WATER", "H2O"),
        ("WEAVE", "Make fabric"), ("WEDGE", "V-shaped piece"), ("WHALE", "Ocean giant"),
        ("WHEAT", "Bread grain"), ("WHEEL", "Round disc"), ("WHERE", "What place"),
        ("WHILE", "During"), ("WHITE", "Snow color"), ("WHOLE", "Entire"),
        ("WIDEN", "Make broader"), ("WIDTH", "How wide"), ("WITCH", "Halloween figure"),
        ("WOMAN", "Adult female"), ("WORLD", "Earth"), ("WORST", "Least good"),
        ("WORTH", "Value"), ("WOULD", "Past of will"), ("WOUND", "Injury"),
        ("WRIST", "Hand joint"), ("WROTE", "Put on paper"),
        ("YACHT", "Luxury boat"), ("YIELD", "Produce or give way"),
        ("ZEBRA", "Striped animal"),
    ],
}

def build_word_index(words_with_clues):
    """Index words by length and by letter at each position."""
    by_length = {}
    by_letter_pos = {}

    for length, word_list in words_with_clues.items():
        by_length[length] = word_list
        for word, clue in word_list:
            for i, ch in enumerate(word):
                key = (length, i, ch)
                if key not in by_letter_pos:
                    by_letter_pos[key] = []
                by_letter_pos[key].append((word, clue))

    return by_length, by_letter_pos


def extract_slots(grid):
    """Extract all word slots (across and down) from a grid template."""
    rows = len(grid)
    cols = len(grid[0])
    slots = []

    # Across slots
    for r in range(rows):
        c = 0
        while c < cols:
            if grid[r][c] != '#':
                start = c
                while c < cols and grid[r][c] != '#':
                    c += 1
                length = c - start
                if length >= 3:
                    cells = [(r, start + i) for i in range(length)]
                    slots.append(('across', cells, length))
            else:
                c += 1

    # Down slots
    for c in range(cols):
        r = 0
        while r < rows:
            if grid[r][c] != '#':
                start = r
                while r < rows and grid[r][c] != '#':
                    r += 1
                length = r - start
                if length >= 3:
                    cells = [(start + i, c) for i in range(length)]
                    slots.append(('down', cells, length))
            else:
                r += 1

    return slots


def fill_grid(grid, slots, by_length, by_letter_pos, used_words=None, slot_idx=0):
    """Fill grid slots using backtracking."""
    if used_words is None:
        used_words = set()

    if slot_idx >= len(slots):
        return True  # All slots filled

    direction, cells, length = slots[slot_idx]

    if length not in by_length:
        return False

    # Get constraints from already-filled cells
    constraints = {}
    for i, (r, c) in enumerate(cells):
        if grid[r][c] != '.':
            constraints[i] = grid[r][c]

    # Filter candidates
    candidates = []
    for word, clue in by_length.get(length, []):
        if word in used_words:
            continue
        if len(word) != length:
            continue
        match = True
        for pos, letter in constraints.items():
            if pos >= len(word) or word[pos] != letter:
                match = False
                break
        if match:
            candidates.append((word, clue))

    random.shuffle(candidates)

    for word, clue in candidates[:50]:  # Limit candidates to avoid long searches
        # Save state
        old_values = [(r, c, grid[r][c]) for r, c in cells]

        # Place word
        for i, (r, c) in enumerate(cells):
            grid[r][c] = word[i]

        used_words.add(word)

        if fill_grid(grid, slots, by_length, by_letter_pos, used_words, slot_idx + 1):
            return True

        # Backtrack
        used_words.discard(word)
        for r, c, val in old_values:
            grid[r][c] = val

    return False


def compute_clue_numbers(grid):
    """Compute clue numbers for cells that start across or down words."""
    rows = len(grid)
    cols = len(grid[0])
    numbers = {}
    num = 1

    for r in range(rows):
        for c in range(cols):
            if grid[r][c] == '#':
                continue

            starts_across = False
            starts_down = False

            # Starts across word?
            if (c == 0 or grid[r][c-1] == '#') and (c + 1 < cols and grid[r][c+1] != '#'):
                # Check it's at least 3 letters
                length = 0
                cc = c
                while cc < cols and grid[r][cc] != '#':
                    length += 1
                    cc += 1
                if length >= 3:
                    starts_across = True

            # Starts down word?
            if (r == 0 or grid[r-1][c] == '#') and (r + 1 < rows and grid[r+1][c] != '#'):
                length = 0
                rr = r
                while rr < rows and grid[rr][c] != '#':
                    length += 1
                    rr += 1
                if length >= 3:
                    starts_down = True

            if starts_across or starts_down:
                numbers[(r, c)] = num
                num += 1

    return numbers


# Grid templates with 180-degree rotational symmetry
TEMPLATES = {
    5: [
        # Template 1: Open 5x5 with corner blocks
        [
            "..#..",
            ".....",
            "#...#",
            ".....",
            "..#..",
        ],
        # Template 2: Diagonal blocks
        [
            "...#.",
            ".....",
            ".....",
            ".....",
            ".#...",
        ],
        # Template 3: Center column blocks
        [
            ".#...",
            ".....",
            "..#..",
            ".....",
            "...#.",
        ],
        # Template 4: minimal blacks
        [
            ".....",
            ".#.#.",
            ".....",
            ".#.#.",
            ".....",
        ],
        # Template 5: L-shape
        [
            "..#..",
            ".....",
            ".....",
            ".....",
            "..#..",
        ],
    ],
    7: [
        [
            "..#.#..",
            ".......",
            "#.....#",
            "..#.#..",
            "#.....#",
            ".......",
            "..#.#..",
        ],
        [
            ".#...#.",
            ".......",
            "...#...",
            ".......",
            "...#...",
            ".......",
            ".#...#.",
        ],
        [
            "...#...",
            ".......",
            ".#...#.",
            ".......",
            ".#...#.",
            ".......",
            "...#...",
        ],
        [
            "#....#.",
            ".......",
            "..#.#..",
            ".......",
            "..#.#..",
            ".......",
            ".#....#",
        ],
        [
            "..#....",
            ".......",
            "....#..",
            ".#...#.",
            "..#....",
            ".......",
            "....#..",
        ],
    ],
    9: [
        [
            "...#.....",
            ".#.....#.",
            ".........",
            "#...#...#",
            "....#....",
            "#...#...#",
            ".........",
            ".#.....#.",
            ".....#...",
        ],
        [
            "..#..#...",
            ".........",
            ".....#...",
            "#..#....#",
            ".........",
            "#....#..#",
            "...#.....",
            ".........",
            "...#..#..",
        ],
        [
            ".#...#...",
            ".........",
            "...#.....",
            ".........",
            "..#...#..",
            ".........",
            ".....#...",
            ".........",
            "...#...#.",
        ],
    ],
}


def generate_puzzle(puzzle_id, size, difficulty, theme, tag, template_idx=0):
    """Generate a single valid crossword puzzle."""
    templates = TEMPLATES[size]
    template = templates[template_idx % len(templates)]

    # Convert template to mutable grid
    grid = [list(row) for row in template]

    # Replace '.' with '.' (already done) for unfilled cells
    for r in range(size):
        for c in range(size):
            if grid[r][c] != '#':
                grid[r][c] = '.'

    by_length, by_letter_pos = build_word_index(WORDS_WITH_CLUES)

    slots = extract_slots(grid)
    # Sort slots by most constrained first (longer words first, then by crossing count)
    slots.sort(key=lambda s: -s[2])

    # Filter out any slots that don't have words in our dictionary
    slots = [s for s in slots if s[2] in by_length]

    random.seed(hash(puzzle_id) + template_idx * 1000)

    success = fill_grid(grid, slots, by_length, by_letter_pos)
    if not success:
        # Try with different random seed
        for attempt in range(20):
            # Reset grid
            for r in range(size):
                for c in range(size):
                    if grid[r][c] != '#':
                        grid[r][c] = '.'
            random.seed(hash(puzzle_id) + attempt * 777 + template_idx * 1000)
            if fill_grid(grid, slots, by_length, by_letter_pos):
                success = True
                break

    if not success:
        return None

    # Compute clue numbers
    numbers = compute_clue_numbers(grid)

    # Build clues
    across_clues = []
    down_clues = []

    # Re-extract slots to get words in reading order
    rows = len(grid)
    cols = len(grid[0])

    # Across
    for r in range(rows):
        c = 0
        while c < cols:
            if grid[r][c] != '#':
                start = c
                word = ""
                while c < cols and grid[r][c] != '#':
                    word += grid[r][c]
                    c += 1
                if len(word) >= 3 and (r, start) in numbers:
                    # Find clue for this word
                    clue_text = get_clue(word)
                    across_clues.append({
                        "number": numbers[(r, start)],
                        "clue": clue_text,
                        "answer": word,
                        "row": r,
                        "col": start
                    })
            else:
                c += 1

    # Down
    for c in range(cols):
        r = 0
        while r < rows:
            if grid[r][c] != '#':
                start = r
                word = ""
                while r < rows and grid[r][c] != '#':
                    word += grid[r][c]
                    r += 1
                if len(word) >= 3 and (start, c) in numbers:
                    clue_text = get_clue(word)
                    down_clues.append({
                        "number": numbers[(start, c)],
                        "clue": clue_text,
                        "answer": word,
                        "row": start,
                        "col": c
                    })
            else:
                r += 1

    puzzle = {
        "id": puzzle_id,
        "version": 1,
        "size": {"rows": size, "cols": size},
        "difficulty": difficulty,
        "theme": theme,
        "date": None,
        "grid": grid,
        "clues": {
            "across": across_clues,
            "down": down_clues
        },
        "tags": [tag],
        "author": "CouchWord"
    }

    return puzzle


def get_clue(word):
    """Look up clue for a word."""
    word = word.upper()
    length = len(word)
    if length in WORDS_WITH_CLUES:
        for w, c in WORDS_WITH_CLUES[length]:
            if w == word:
                return c
    return f"({len(word)} letters)"


def validate_puzzle(puzzle):
    """Validate that all clues match the grid."""
    grid = puzzle["grid"]
    errors = []

    for direction in ["across", "down"]:
        for clue in puzzle["clues"][direction]:
            answer = clue["answer"]
            row, col = clue["row"], clue["col"]
            grid_word = ""
            for i in range(len(answer)):
                r = row + (i if direction == "down" else 0)
                c = col + (i if direction == "across" else 0)
                if r < len(grid) and c < len(grid[0]):
                    grid_word += grid[r][c]
                else:
                    grid_word += "?"
            if grid_word != answer:
                errors.append(f"{direction} {clue['number']}: expected {answer}, got {grid_word}")

    return errors


# Define puzzles to generate
PUZZLE_SPECS = [
    # 5x5 easy puzzles
    ("puzzle_001", 5, "easy", "Everyday Life", "daily", 0),
    ("puzzle_002", 5, "easy", "Nature", "nature", 1),
    ("puzzle_003", 5, "easy", "Food & Drink", "food", 2),
    ("puzzle_004", 5, "easy", "Animals", "animals", 3),
    ("puzzle_005", 5, "easy", "Around the House", "home", 4),
    ("puzzle_006", 5, "easy", "Sports", "sports", 0),
    ("puzzle_007", 5, "easy", "Colors & Shapes", "colors", 1),

    # 7x7 medium puzzles
    ("puzzle_008", 7, "medium", "Travel", "travel", 0),
    ("puzzle_009", 7, "medium", "Music", "music", 1),
    ("puzzle_010", 7, "medium", "Science", "science", 2),
    ("puzzle_011", 7, "medium", "History", "history", 3),
    ("puzzle_012", 7, "medium", "Movies", "movies", 4),
    ("puzzle_013", 7, "medium", "Weather", "weather", 0),

    # 9x9 medium-hard puzzles
    ("puzzle_014", 9, "medium", "Literature", "books", 0),
    ("puzzle_015", 9, "medium", "Technology", "tech", 1),
    ("puzzle_016", 9, "hard", "Geography", "geography", 2),
    ("puzzle_017", 9, "hard", "Professions", "jobs", 0),
    ("puzzle_018", 9, "hard", "Holidays", "holidays", 1),
    ("puzzle_019", 9, "hard", "Space", "space", 2),
    ("puzzle_020", 9, "hard", "Art & Culture", "art", 0),
]


def main():
    output_dir = "/Users/sheldon/Development/CouchWord/CouchWord/Resources/Puzzles"

    # Clean existing
    for f in os.listdir(output_dir):
        if f.startswith("puzzle_") and f.endswith(".json"):
            os.remove(os.path.join(output_dir, f))

    generated = 0
    failed = 0

    for spec in PUZZLE_SPECS:
        puzzle_id, size, difficulty, theme, tag, template_idx = spec
        print(f"Generating {puzzle_id} ({size}x{size} {difficulty})...", end=" ")

        puzzle = None
        # Try different templates if one fails
        for t in range(len(TEMPLATES.get(size, [[]]))):
            puzzle = generate_puzzle(puzzle_id, size, difficulty, theme, tag,
                                   (template_idx + t) % len(TEMPLATES.get(size, [[]])))
            if puzzle:
                break

        if puzzle is None:
            print("FAILED to generate")
            failed += 1
            continue

        errors = validate_puzzle(puzzle)
        if errors:
            print(f"VALIDATION ERRORS: {errors}")
            failed += 1
            continue

        # Verify across and down clues exist
        n_across = len(puzzle["clues"]["across"])
        n_down = len(puzzle["clues"]["down"])

        filepath = os.path.join(output_dir, f"{puzzle_id}.json")
        with open(filepath, 'w') as f:
            json.dump(puzzle, f, indent=2)

        print(f"OK ({n_across} across, {n_down} down)")
        generated += 1

    print(f"\nDone: {generated} generated, {failed} failed")


if __name__ == "__main__":
    main()
