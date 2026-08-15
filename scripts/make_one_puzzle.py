#!/usr/bin/env python3
"""Generate one valid 5x5 crossword puzzle with interlocking across/down words."""
import json, random

# 4-letter and 5-letter word lists with clues
WORDS = {
    4: [
        ("ABLE","Capable"), ("ACHE","Dull pain"), ("ACRE","Land measure"),
        ("AGED","Old"), ("AIDE","Helper"), ("AIMS","Goals"),
        ("AJAR","Slightly open"), ("ALLY","Partner"), ("ALSO","In addition"),
        ("ARCH","Curved structure"), ("AREA","Region"), ("ARMY","Military force"),
        ("ARTS","Creative works"), ("ATOM","Tiny particle"), ("AUTO","Car"),
        ("AVID","Eager"), ("AXLE","Wheel rod"), ("BACK","Rear"),
        ("BAKE","Oven cook"), ("BALD","Without hair"), ("BALE","Hay bundle"),
        ("BAND","Music group"), ("BANE","Curse"), ("BANK","Money institution"),
        ("BARE","Naked"), ("BARK","Dog sound"), ("BARN","Farm building"),
        ("BASE","Foundation"), ("BATH","Washing soak"), ("BEAD","Necklace piece"),
        ("BEAM","Light ray"), ("BEAN","Pod veggie"), ("BEAR","Forest animal"),
        ("BEAT","Rhythm"), ("BEER","Pub drink"), ("BELL","Chiming object"),
        ("BELT","Waist band"), ("BEND","Curve"), ("BEST","Top quality"),
        ("BIRD","Feathered flyer"), ("BITE","Chomp"), ("BLOW","Gust"),
        ("BLUE","Sky color"), ("BLUR","Fuzzy image"), ("BOAT","Water vessel"),
        ("BODY","Physical form"), ("BOLD","Brave"), ("BOLT","Door fastener"),
        ("BOND","Connection"), ("BONE","Skeleton part"), ("BOOK","Reading material"),
        ("BOOT","Footwear"), ("BORE","Drill or dull person"), ("BORN","Brought into life"),
        ("BOSS","Manager"), ("BOWL","Soup dish"), ("BRED","Raised animals"),
        ("BREW","Make beer"), ("BULB","Light source"), ("BULL","Male bovine"),
        ("BUMP","Small collision"), ("BURN","Fire injury"), ("BUSY","Not idle"),
        ("BUZZ","Bee sound"), ("CAFE","Coffee shop"), ("CAGE","Animal enclosure"),
        ("CAKE","Birthday treat"), ("CALF","Young cow"), ("CALM","Peaceful"),
        ("CAME","Arrived"), ("CAMP","Outdoor lodging"), ("CAPE","Superhero garment"),
        ("CARD","Playing piece"), ("CARE","Concern"), ("CART","Shopping vehicle"),
        ("CASE","Container"), ("CASH","Money"), ("CAST","Throw"),
        ("CAVE","Underground chamber"), ("CELL","Tiny unit"), ("CHEF","Professional cook"),
        ("CHIN","Face bottom"), ("CHIP","Snack"), ("CITY","Large town"),
        ("CLAM","Shellfish"), ("CLAP","Applause"), ("CLAW","Animal nail"),
        ("CLAY","Pottery material"), ("CLIP","Fasten"), ("CLUB","Social group"),
        ("CLUE","Hint"), ("COAL","Black fuel"), ("COAT","Outer garment"),
        ("CODE","Secret message"), ("COIL","Spiral"), ("COIN","Metal money"),
        ("COLD","Not hot"), ("COLT","Young horse"), ("COMB","Hair groomer"),
        ("COME","Arrive"), ("CONE","Ice cream holder"), ("COOK","Prepare food"),
        ("COOL","Somewhat cold"), ("COPE","Deal with"), ("CORD","Thick string"),
        ("CORE","Center"), ("CORK","Bottle stopper"), ("CORN","Yellow veggie"),
        ("COST","Price"), ("COZY","Warm and snug"), ("CRAB","Beach creature"),
        ("CREW","Team"), ("CROP","Farm product"), ("CROW","Black bird"),
        ("CUBE","3D square"), ("CURE","Remedy"), ("CURL","Spiral shape"),
        ("DALE","Valley"), ("DAME","Lady"), ("DAMP","Slightly wet"),
        ("DARE","Challenge"), ("DARK","Without light"), ("DART","Throwing missile"),
        ("DASH","Sprint"), ("DATA","Information"), ("DATE","Calendar day"),
        ("DAWN","Daybreak"), ("DEAL","Bargain"), ("DEAR","Beloved"),
        ("DECK","Ship floor"), ("DEED","Action"), ("DEEM","Consider"),
        ("DEEP","Profound"), ("DEER","Forest animal"), ("DENT","Small depression"),
        ("DENY","Refuse"), ("DESK","Work surface"), ("DIAL","Phone face"),
        ("DICE","Gaming cubes"), ("DIET","Food plan"), ("DIME","Ten cents"),
        ("DINE","Eat formally"), ("DIRE","Desperate"), ("DIRT","Soil"),
        ("DISH","Plate"), ("DOCK","Ship berth"), ("DOES","Performs"),
        ("DOME","Rounded roof"), ("DONE","Finished"), ("DOOM","Terrible fate"),
        ("DOOR","Room entrance"), ("DOSE","Medicine amount"), ("DOVE","Peace bird"),
        ("DOWN","Opposite of up"), ("DRAG","Pull along"), ("DRAW","Sketch"),
        ("DRIP","Water drop"), ("DROP","Let fall"), ("DRUM","Percussion instrument"),
        ("DUAL","Double"), ("DUCK","Pond bird"), ("DUEL","One-on-one fight"),
        ("DUKE","Nobleman"), ("DULL","Boring"), ("DUMP","Discard"),
        ("DUNE","Sand hill"), ("DUSK","Twilight"), ("DUST","Fine particles"),
        ("DUTY","Obligation"), ("EACH","Every one"), ("EARL","British nobleman"),
        ("EARN","Make money"), ("EASE","Comfort"), ("EAST","Sunrise direction"),
        ("EASY","Not hard"), ("ECHO","Sound reflection"), ("EDGE","Border"),
        ("EDIT","Revise text"), ("ELSE","Otherwise"), ("EMIT","Give off"),
        ("EPIC","Grand story"), ("EVEN","Level"), ("EVER","At any time"),
        ("EVIL","Wicked"), ("EXAM","Test"), ("EXIT","Way out"),
        ("EYES","Sight organs"), ("FACE","Front of head"), ("FACT","Truth"),
        ("FADE","Lose color"), ("FAIL","Not succeed"), ("FAIR","Just"),
        ("FAKE","Not real"), ("FALL","Autumn"), ("FAME","Celebrity"),
        ("FARE","Ticket price"), ("FARM","Agricultural land"), ("FAST","Quick"),
        ("FATE","Destiny"), ("FEAR","Dread"), ("FEAT","Achievement"),
        ("FEED","Give food"), ("FEEL","Sense"), ("FEET","Walking appendages"),
        ("FELL","Dropped"), ("FELT","Sensed"), ("FERN","Forest plant"),
        ("FILE","Document holder"), ("FILL","Make full"), ("FILM","Movie"),
        ("FIND","Discover"), ("FINE","Excellent"), ("FIRE","Flames"),
        ("FIRM","Company"), ("FISH","Aquatic animal"), ("FIST","Clenched hand"),
        ("FLAG","National banner"), ("FLAT","Level"), ("FLAW","Defect"),
        ("FLEA","Tiny pest"), ("FLED","Ran away"), ("FLEW","Soared"),
        ("FLIP","Turn over"), ("FLOW","Stream along"), ("FOAM","Frothy bubbles"),
        ("FOIL","Thin metal"), ("FOLD","Bend over"), ("FOLK","People"),
        ("FOND","Affectionate"), ("FOOD","Nourishment"), ("FOOL","Silly person"),
        ("FOOT","12 inches"), ("FORK","Eating utensil"), ("FORM","Shape"),
        ("FORT","Military base"), ("FOUL","Unfair play"), ("FOUR","After three"),
        ("FREE","No cost"), ("FROG","Pond amphibian"), ("FUEL","Energy source"),
        ("FULL","Not empty"), ("FUND","Money pool"), ("FURY","Intense anger"),
        ("FUSE","Electrical safety"), ("FUSS","Unnecessary worry"),
        ("GALE","Strong wind"), ("GAME","Sport"), ("GANG","Group"),
        ("GATE","Fence opening"), ("GAVE","Donated"), ("GAZE","Stare"),
        ("GEAR","Equipment"), ("GIFT","Present"), ("GIST","Main point"),
        ("GIVE","Donate"), ("GLAD","Happy"), ("GLEE","Joy"),
        ("GLOW","Soft light"), ("GLUE","Adhesive"), ("GOAT","Farm animal"),
        ("GOES","Travels"), ("GOLD","Precious metal"), ("GOLF","Club sport"),
        ("GONE","Departed"), ("GOOD","Not bad"), ("GOWN","Formal dress"),
        ("GRAB","Seize"), ("GRAM","Weight unit"), ("GRAY","Between black and white"),
        ("GREW","Got bigger"), ("GRID","Crisscross pattern"), ("GRIM","Stern"),
        ("GRIN","Big smile"), ("GRIP","Hold tight"), ("GRIT","Determination"),
        ("GROW","Get bigger"), ("GULF","Large bay"), ("GUST","Wind burst"),
        ("HACK","Break in"), ("HAIL","Ice pellets"), ("HAIR","Head covering"),
        ("HALE","Healthy"), ("HALF","50 percent"), ("HALL","Corridor"),
        ("HALT","Stop"), ("HAND","Five fingers"), ("HARE","Fast rabbit"),
        ("HARM","Injury"), ("HATE","Despise"), ("HAUL","Drag"),
        ("HAVE","Possess"), ("HAZE","Light fog"), ("HEAD","Body top"),
        ("HEAL","Mend"), ("HEAP","Pile"), ("HEAR","Listen"),
        ("HEAT","Warmth"), ("HEED","Pay attention"), ("HEEL","Foot back"),
        ("HELD","Grasped"), ("HELP","Assist"), ("HERD","Group of cattle"),
        ("HERE","In this place"), ("HERO","Brave person"), ("HIDE","Conceal"),
        ("HIGH","Tall"), ("HIKE","Long walk"), ("HILL","Small mountain"),
        ("HINT","Clue"), ("HIRE","Employ"), ("HOLD","Grasp"),
        ("HOLE","Opening"), ("HOME","Dwelling"), ("HONE","Sharpen"),
        ("HOOD","Head cover"), ("HOOK","Curved fastener"), ("HOPE","Wish for"),
        ("HORN","Animal spike"), ("HOSE","Water tube"), ("HOST","Party giver"),
        ("HUGE","Enormous"), ("HUNG","Suspended"), ("HUNT","Search for prey"),
        ("HURL","Throw hard"), ("HURT","Cause pain"), ("HYMN","Church song"),
        ("IDEA","Thought"), ("IDLE","Not busy"), ("IDOL","Object of worship"),
        ("INCH","Small measure"), ("INTO","Going inside"), ("IRON","Press clothes"),
        ("ISLE","Small island"), ("ITEM","Single thing"), ("JADE","Green gem"),
        ("JAIL","Prison"), ("JAZZ","Music genre"), ("JEST","Joke"),
        ("JOIN","Connect"), ("JOKE","Funny story"), ("JOLT","Sudden shock"),
        ("JUMP","Leap"), ("JURY","Trial panel"), ("JUST","Fair"),
        ("KEEN","Eager"), ("KEEP","Retain"), ("KELP","Seaweed"),
        ("KEPT","Retained"), ("KICK","Foot strike"), ("KIND","Gentle type"),
        ("KING","Royal ruler"), ("KITE","Flying toy"), ("KNOB","Door handle"),
        ("KNOT","Tied rope"), ("KNOW","Be aware"), ("LACE","Delicate fabric"),
        ("LACK","Be without"), ("LAID","Put down"), ("LAIR","Animal den"),
        ("LAKE","Inland water"), ("LAMB","Baby sheep"), ("LAME","Weak excuse"),
        ("LAMP","Light source"), ("LAND","Ground"), ("LANE","Narrow road"),
        ("LARK","Songbird"), ("LAST","Final"), ("LATE","Not on time"),
        ("LAWN","Yard grass"), ("LEAD","Guide"), ("LEAF","Tree part"),
        ("LEAK","Drip out"), ("LEAN","Thin"), ("LEAP","Big jump"),
        ("LEFT","Opposite of right"), ("LEND","Loan"), ("LENS","Camera part"),
        ("LESS","Fewer"), ("LIFE","Existence"), ("LIFT","Raise up"),
        ("LIKE","Enjoy"), ("LIMB","Tree branch"), ("LIME","Green citrus"),
        ("LIMP","Uneven walk"), ("LINE","Straight mark"), ("LINK","Connection"),
        ("LION","King of jungle"), ("LIST","Written items"), ("LIVE","Exist"),
        ("LOAD","Cargo"), ("LOAF","Bread shape"), ("LOAN","Lend money"),
        ("LOCK","Secure"), ("LOFT","Attic space"), ("LONE","Solitary"),
        ("LONG","Extended"), ("LOOK","See"), ("LOOP","Circle shape"),
        ("LORD","Noble title"), ("LORE","Traditional knowledge"), ("LOSE","Misplace"),
        ("LOSS","Defeat"), ("LOST","Cannot find"), ("LOTS","Many"),
        ("LOUD","Noisy"), ("LOVE","Deep affection"), ("LUCK","Fortune"),
        ("LUMP","Bump"), ("LUNG","Breathing organ"), ("LURE","Entice"),
        ("LURK","Hide in wait"), ("MADE","Created"), ("MAID","Housekeeper"),
        ("MAIL","Letters"), ("MAIN","Primary"), ("MAKE","Create"),
        ("MALE","Man"), ("MALL","Shopping center"), ("MANE","Lion's hair"),
        ("MANY","A lot"), ("MARE","Female horse"), ("MARK","Sign"),
        ("MASK","Face covering"), ("MASS","Large amount"), ("MAST","Ship pole"),
        ("MATE","Partner"), ("MAZE","Puzzle path"), ("MEAL","Dinner"),
        ("MEAN","Unkind"), ("MEAT","Animal protein"), ("MELD","Merge together"),
        ("MELT","Thaw"), ("MEMO","Office note"), ("MEND","Repair"),
        ("MENU","Food choices"), ("MERE","Only"), ("MESH","Woven net"),
        ("MESS","Disorder"), ("MILD","Gentle"), ("MILE","5280 feet"),
        ("MILK","Dairy drink"), ("MILL","Grain grinder"), ("MIND","Brain"),
        ("MINE","Belonging to me"), ("MINT","Herb"), ("MISS","Fail to hit"),
        ("MIST","Light fog"), ("MOAT","Castle ditch"), ("MODE","Method"),
        ("MOLD","Fungus"), ("MOLE","Burrowing animal"), ("MOOD","Emotional state"),
        ("MOON","Night light"), ("MOOR","Open land"), ("MORE","Additional"),
        ("MOSS","Green growth"), ("MOST","Greatest amount"), ("MOTH","Night butterfly"),
        ("MOVE","Change position"), ("MUCH","A lot"), ("MULE","Hybrid animal"),
        ("MUSE","Source of inspiration"), ("MUST","Have to"), ("MUTE","Silent"),
        ("NAIL","Hammer target"), ("NAME","What you're called"), ("NAVY","Sea military"),
        ("NEAR","Close by"), ("NEAT","Tidy"), ("NECK","Body connector"),
        ("NEED","Require"), ("NEST","Bird home"), ("NEWS","Current events"),
        ("NEXT","Following"), ("NICE","Pleasant"), ("NINE","After eight"),
        ("NODE","Connection point"), ("NONE","Zero"), ("NOON","Midday"),
        ("NORM","Standard"), ("NOSE","Smell organ"), ("NOTE","Written message"),
        ("NOUN","Person place or thing"), ("NUMB","Without feeling"),
        ("OATH","Solemn promise"), ("OBEY","Follow orders"), ("ODDS","Chances"),
        ("OMEN","Sign of future"), ("OMIT","Leave out"), ("ONCE","One time"),
        ("ONLY","Sole"), ("ONTO","On top of"), ("OOZE","Seep slowly"),
        ("OPAL","Rainbow gem"), ("OPEN","Not closed"), ("OPTS","Chooses"),
        ("ORAL","Spoken"), ("ORCA","Killer whale"), ("OVEN","Baking appliance"),
        ("OVER","Above"), ("OWED","Was indebted"), ("OXEN","Draft animals"),
        ("PACE","Walking speed"), ("PACK","Bundle"), ("PAGE","Book leaf"),
        ("PAID","Compensated"), ("PAIL","Bucket"), ("PAIN","Hurt"),
        ("PAIR","Two of a kind"), ("PALE","Light colored"), ("PALM","Hand center"),
        ("PANE","Window glass"), ("PARK","Recreation area"), ("PART","Piece"),
        ("PASS","Go by"), ("PAST","Former time"), ("PATH","Trail"),
        ("PEAK","Mountain top"), ("PEAR","Fruit"), ("PEEL","Remove skin"),
        ("PEER","Equal"), ("PEST","Nuisance"), ("PICK","Choose"),
        ("PIER","Dock"), ("PILE","Heap"), ("PINE","Evergreen tree"),
        ("PINK","Light red"), ("PIPE","Tube"), ("PLAN","Strategy"),
        ("PLAY","Have fun"), ("PLEA","Request"), ("PLOW","Farm tool"),
        ("PLUG","Stopper"), ("PLUM","Purple fruit"), ("PLUS","In addition"),
        ("POEM","Verse"), ("POET","Verse writer"), ("POKE","Prod"),
        ("POLE","Long stick"), ("POLL","Survey"), ("POLO","Horse sport"),
        ("POND","Small lake"), ("POOL","Swimming hole"), ("POOR","Not rich"),
        ("PORE","Skin opening"), ("PORK","Pig meat"), ("PORT","Harbor"),
        ("POSE","Strike a stance"), ("POST","Mail or pole"), ("POUR","Flow out"),
        ("PRAY","Talk to God"), ("PREY","Hunted animal"), ("PROD","Poke"),
        ("PROP","Support"), ("PULL","Tug"), ("PUMP","Water mover"),
        ("PURE","Uncontaminated"), ("PUSH","Shove"), ("QUIT","Stop doing"),
        ("RACE","Competition"), ("RACK","Storage shelf"), ("RAFT","Floating platform"),
        ("RAGE","Fury"), ("RAID","Sudden attack"), ("RAIL","Fence bar"),
        ("RAIN","Water from sky"), ("RAKE","Leaf collector"), ("RAMP","Incline"),
        ("RANG","Phone sounded"), ("RANK","Position"), ("RARE","Uncommon"),
        ("RASH","Skin irritation"), ("RATE","Speed or price"), ("READ","Book activity"),
        ("REAL","Genuine"), ("REAR","Back"), ("REED","Marsh grass"),
        ("REEF","Coral formation"), ("REEL","Fishing spool"), ("RELY","Depend on"),
        ("RENT","Monthly payment"), ("REST","Relax"), ("RICE","Asian grain"),
        ("RICH","Wealthy"), ("RIDE","Travel on"), ("RIFT","Split"),
        ("RIND","Fruit skin"), ("RING","Finger jewelry"), ("RINK","Ice arena"),
        ("RISE","Go up"), ("RISK","Danger"), ("ROAD","Street"),
        ("ROAM","Wander"), ("ROAR","Lion sound"), ("ROBE","Long garment"),
        ("ROCK","Stone"), ("RODE","Traveled on"), ("ROLE","Part to play"),
        ("ROLL","Turn over"), ("ROOF","House top"), ("ROOM","Indoor space"),
        ("ROOT","Plant base"), ("ROPE","Thick cord"), ("ROSE","Red flower"),
        ("ROTE","Memorization"), ("RUDE","Impolite"), ("RUIN","Destroy"),
        ("RULE","Regulation"), ("RUSH","Hurry"), ("RUST","Iron decay"),
        ("SAFE","Secure"), ("SAGE","Wise person"), ("SAID","Spoke"),
        ("SAIL","Boat fabric"), ("SAKE","Purpose"), ("SALE","Discount event"),
        ("SALT","Table seasoning"), ("SAME","Identical"), ("SAND","Beach grains"),
        ("SANE","Mentally sound"), ("SANG","Performed a song"), ("SAVE","Rescue"),
        ("SEAL","Ocean mammal"), ("SEAM","Sewing joint"), ("SEAT","Chair"),
        ("SEED","Plant starter"), ("SEEK","Search for"), ("SEEM","Appear"),
        ("SEEN","Viewed"), ("SELF","One's own person"), ("SELL","Vend"),
        ("SEND","Mail off"), ("SENT","Mailed"), ("SHED","Small barn"),
        ("SHIP","Large vessel"), ("SHOE","Foot covering"), ("SHOP","Store"),
        ("SHOT","Quick photo"), ("SHOW","Display"), ("SHUT","Close"),
        ("SIDE","Edge"), ("SIGH","Deep breath"), ("SIGN","Poster"),
        ("SILK","Fine fabric"), ("SING","Vocalize"), ("SINK","Kitchen basin"),
        ("SITE","Location"), ("SIZE","Dimensions"), ("SLAB","Thick slice"),
        ("SLAM","Bang shut"), ("SLAP","Sharp hit"), ("SLED","Snow vehicle"),
        ("SLID","Moved smoothly"), ("SLIM","Thin"), ("SLIP","Slide"),
        ("SLOT","Narrow opening"), ("SLOW","Not fast"), ("SLUG","Garden pest"),
        ("SNAP","Quick break"), ("SNOB","Elitist"), ("SNOW","Winter flakes"),
        ("SNUG","Cozy fit"), ("SOAK","Drench"), ("SOAP","Cleaning bar"),
        ("SOAR","Fly high"), ("SOCK","Foot garment"), ("SODA","Fizzy drink"),
        ("SOFA","Living room seat"), ("SOFT","Not hard"), ("SOIL","Garden dirt"),
        ("SOLD","Vended"), ("SOLE","Only one"), ("SOME","A few"),
        ("SONG","Musical piece"), ("SOON","Before long"), ("SORE","Painful"),
        ("SORT","Organize"), ("SOUL","Inner spirit"), ("SOUP","Liquid meal"),
        ("SOUR","Tart taste"), ("SPAN","Stretch across"), ("SPAR","Boxing practice"),
        ("SPED","Raced"), ("SPIN","Turn around"), ("SPOT","Location"),
        ("SPUR","Motivate"), ("STAR","Night sky light"), ("STAY","Remain"),
        ("STEM","Plant stalk"), ("STEP","Footfall"), ("STEW","Slow-cooked dish"),
        ("STIR","Mix around"), ("STOP","Halt"), ("STUB","Ticket remainder"),
        ("STUN","Shock"), ("SUIT","Business attire"), ("SUNG","Performed vocally"),
        ("SURE","Certain"), ("SURF","Ride waves"), ("SWAN","Elegant bird"),
        ("SWAP","Trade"), ("SWIM","Water exercise"), ("TABS","Bar bills"),
        ("TACK","Small nail"), ("TAIL","Animal rear end"), ("TAKE","Grab"),
        ("TALE","Story"), ("TALK","Speak"), ("TALL","High"),
        ("TAME","Domesticated"), ("TANK","Large container"), ("TAPE","Adhesive strip"),
        ("TART","Sour pastry"), ("TASK","Job to do"), ("TAXI","Hired car"),
        ("TEAK","Tropical wood"), ("TEAL","Blue-green"), ("TEAM","Group"),
        ("TEAR","Rip"), ("TELL","Inform"), ("TEND","Look after"),
        ("TENT","Camping shelter"), ("TERM","Time period"), ("TEST","Exam"),
        ("THAT","Demonstrative pronoun"), ("THEM","Those people"),
        ("THEN","After that"), ("THIN","Not thick"), ("THUS","Therefore"),
        ("TICK","Clock sound"), ("TIDE","Ocean rise"), ("TIDY","Neat"),
        ("TIED","Knotted"), ("TIER","Level"), ("TILE","Floor covering"),
        ("TILL","Until"), ("TILT","Lean"), ("TIME","Clock reading"),
        ("TINY","Very small"), ("TIRE","Wheel rubber"), ("TOAD","Warty amphibian"),
        ("TOIL","Hard work"), ("TOLD","Informed"), ("TOLL","Fee"),
        ("TOMB","Burial place"), ("TONE","Sound quality"), ("TOOK","Grabbed"),
        ("TOOL","Implement"), ("TOPS","Highest points"), ("TORE","Ripped"),
        ("TORN","Ripped"), ("TOSS","Throw lightly"), ("TOUR","Sightseeing trip"),
        ("TOWN","Small city"), ("TOYS","Playthings"), ("TRAP","Snare"),
        ("TRAY","Serving plate"), ("TREE","Tall plant"), ("TREK","Long journey"),
        ("TRIM","Cut edges"), ("TRIO","Group of three"), ("TRIP","Journey"),
        ("TROT","Horse gait"), ("TRUE","Not false"), ("TUBE","Hollow cylinder"),
        ("TUNA","Ocean fish"), ("TUNE","Melody"), ("TURF","Grass surface"),
        ("TURN","Rotate"), ("TUSK","Elephant tooth"), ("TWIN","One of two"),
        ("TYPE","Kind"), ("UNIT","Single piece"), ("UPON","On top of"),
        ("URGE","Strong desire"), ("USED","Not new"), ("VALE","Valley"),
        ("VANE","Wind indicator"), ("VASE","Flower holder"), ("VAST","Enormous"),
        ("VEIL","Face covering"), ("VEIN","Blood vessel"), ("VENT","Air opening"),
        ("VERB","Action word"), ("VERY","Extremely"), ("VEST","Sleeveless garment"),
        ("VIEW","Vista"), ("VINE","Climbing plant"), ("VOID","Empty space"),
        ("VOLT","Electrical unit"), ("VOTE","Cast a ballot"),
        ("WADE","Walk through water"), ("WAGE","Pay"), ("WAIT","Be patient"),
        ("WAKE","Get up"), ("WALK","Stroll"), ("WALL","Room divider"),
        ("WAND","Magic stick"), ("WANT","Desire"), ("WARD","Hospital section"),
        ("WARM","Slightly hot"), ("WARN","Alert"), ("WARP","Bend out of shape"),
        ("WASH","Clean"), ("WASP","Stinging insect"), ("WAVE","Ocean swell"),
        ("WEAK","Not strong"), ("WEAR","Put on clothes"), ("WEED","Garden pest"),
        ("WEEK","Seven days"), ("WEEP","Cry"), ("WELD","Join metals"),
        ("WELL","Water source"), ("WENT","Traveled"), ("WERE","Past plural of be"),
        ("WEST","Sunset direction"), ("WICK","Candle string"), ("WIDE","Broad"),
        ("WIFE","Married woman"), ("WILD","Untamed"), ("WILL","Future helper"),
        ("WILT","Droop"), ("WIND","Moving air"), ("WINE","Grape drink"),
        ("WING","Bird part"), ("WINK","Eye gesture"), ("WIPE","Clean off"),
        ("WIRE","Metal thread"), ("WISE","Full of wisdom"), ("WISH","Desire"),
        ("WITH","Alongside"), ("WOKE","Became alert"), ("WOLF","Wild canine"),
        ("WOOD","Tree material"), ("WOOL","Sheep fiber"), ("WORD","Language unit"),
        ("WORE","Had on"), ("WORK","Labor"), ("WORM","Crawling creature"),
        ("WORN","Used up"), ("WRAP","Cover up"), ("WREN","Small bird"),
        ("YANK","Pull sharply"), ("YARD","Outdoor area"), ("YARN","Knitting thread"),
        ("YEAR","365 days"), ("YELL","Shout"), ("YOGA","Flexibility practice"),
        ("YOKE","Oxen harness"), ("ZEAL","Enthusiasm"), ("ZERO","Nothing"),
        ("ZEST","Enthusiasm"), ("ZINC","Metal element"), ("ZONE","Area"),
    ],
    5: [
        ("ABIDE","Put up with"), ("ADAPT","Adjust"), ("ADEPT","Skilled"),
        ("ADMIT","Confess"), ("ADOPT","Take in"), ("AGENT","Representative"),
        ("AGILE","Nimble"), ("ALARM","Warning sound"), ("ALBUM","Photo book"),
        ("ALERT","Watchful"), ("ALIEN","Extraterrestrial"), ("ALIGN","Line up"),
        ("ALIKE","Similar"), ("ALIVE","Living"), ("ALLEY","Narrow street"),
        ("ALLOW","Permit"), ("ALONE","By oneself"), ("ALONG","Beside"),
        ("ALTER","Change"), ("AMPLE","Plenty"), ("ANGEL","Heavenly being"),
        ("ANGER","Fury"), ("ANGLE","Corner degree"), ("ANKLE","Foot joint"),
        ("APPLE","Red fruit"), ("APPLY","Put on"), ("ARENA","Sports venue"),
        ("ARGUE","Debate"), ("ARISE","Come up"), ("ARMOR","Protective covering"),
        ("ARRAY","Display"), ("ASIDE","To the side"), ("ASSET","Valuable thing"),
        ("ATLAS","Map book"), ("ATTIC","Top floor room"), ("AVOID","Stay away from"),
        ("AWAKE","Not sleeping"), ("AWARD","Prize"), ("AWARE","Conscious of"),
        ("BADGE","ID pin"), ("BAKER","Bread maker"), ("BASIC","Fundamental"),
        ("BASIN","Wash bowl"), ("BATCH","Group"), ("BEACH","Sandy shore"),
        ("BEAST","Wild animal"), ("BEGIN","Start"), ("BEING","Existence"),
        ("BELOW","Under"), ("BENCH","Park seat"), ("BLACK","Darkest color"),
        ("BLADE","Knife edge"), ("BLAME","Hold responsible"), ("BLANK","Empty"),
        ("BLAST","Explosion"), ("BLAZE","Intense fire"), ("BLEED","Lose blood"),
        ("BLEND","Mix together"), ("BLIND","Cannot see"), ("BLISS","Pure happiness"),
        ("BLOCK","Obstruct"), ("BLOOM","Flower"), ("BLOWN","Wind-moved"),
        ("BOARD","Wooden plank"), ("BOAST","Brag"), ("BONUS","Extra reward"),
        ("BOOTH","Small enclosure"), ("BOUND","Headed for"), ("BRAIN","Thinking organ"),
        ("BRAND","Company name"), ("BRAVE","Courageous"), ("BREAD","Bakery staple"),
        ("BREAK","Fracture"), ("BREED","Animal type"), ("BRICK","Building block"),
        ("BRIDE","Wedding woman"), ("BRIEF","Short"), ("BRING","Carry to"),
        ("BROAD","Wide"), ("BROKE","Without money"), ("BROOK","Small stream"),
        ("BROTH","Soup base"), ("BROWN","Earth color"), ("BRUSH","Hair tool"),
        ("BUILD","Construct"), ("BUNCH","Cluster"), ("BURST","Pop"),
        ("BUYER","Purchaser"), ("CABIN","Log house"), ("CAMEL","Desert animal"),
        ("CANDY","Sweet treat"), ("CARGO","Ship's load"), ("CARRY","Transport"),
        ("CATCH","Grab"), ("CAUSE","Reason"), ("CHAIN","Linked metal"),
        ("CHAIR","Seat"), ("CHALK","Writing stick"), ("CHARM","Appeal"),
        ("CHART","Graph"), ("CHASE","Pursue"), ("CHEAP","Inexpensive"),
        ("CHECK","Verify"), ("CHEER","Root for"), ("CHESS","Board game"),
        ("CHEST","Torso front"), ("CHIEF","Leader"), ("CHILD","Young one"),
        ("CHILL","Cool down"), ("CHIRP","Bird sound"), ("CHOIR","Singing group"),
        ("CHORD","Musical notes"), ("CHUNK","Large piece"), ("CLAIM","Assert"),
        ("CLASS","School group"), ("CLEAN","Not dirty"), ("CLEAR","Transparent"),
        ("CLERK","Store worker"), ("CLIFF","Steep rock face"), ("CLIMB","Go up"),
        ("CLING","Hold tight"), ("CLOCK","Timepiece"), ("CLOSE","Shut"),
        ("CLOTH","Fabric"), ("CLOUD","Sky puff"), ("CLOWN","Circus performer"),
        ("COACH","Trainer"), ("COAST","Shoreline"), ("COLOR","Hue"),
        ("COMET","Space traveler"), ("COUNT","Number up"), ("COURT","Tennis area"),
        ("COVER","Put over"), ("CRACK","Split"), ("CRAFT","Skilled trade"),
        ("CRANE","Construction machine"), ("CRASH","Collision"), ("CRATE","Shipping box"),
        ("CREAM","Coffee additive"), ("CREEK","Small stream"), ("CREST","Wave top"),
        ("CRIME","Illegal act"), ("CRISP","Crunchy"), ("CROSS","Angry"),
        ("CROWD","Large group"), ("CROWN","Royal headpiece"), ("CRUSH","Squash"),
        ("CURVE","Bend"), ("CYCLE","Repeating pattern"), ("DAILY","Every day"),
        ("DAIRY","Milk farm"), ("DANCE","Move to music"), ("DECAY","Rot"),
        ("DELTA","River mouth"), ("DENSE","Thick"), ("DEPTH","How deep"),
        ("DIRTY","Not clean"), ("DODGE","Avoid"), ("DOUBT","Uncertainty"),
        ("DOUGH","Bread mix"), ("DRAFT","First version"), ("DRAIN","Empty out"),
        ("DRAPE","Curtain"), ("DRAWN","Sketched"), ("DREAD","Fear greatly"),
        ("DREAM","Sleep vision"), ("DRESS","Woman's garment"), ("DRIFT","Float along"),
        ("DRILL","Boring tool"), ("DRINK","Beverage"), ("DRIVE","Operate a car"),
        ("DROWN","Sink in water"), ("DWARF","Small character"), ("DWELL","Reside"),
        ("EAGER","Very keen"), ("EAGLE","Bird of prey"), ("EARLY","Before time"),
        ("EARTH","Our planet"), ("EASEL","Painter's stand"), ("EIGHT","After seven"),
        ("ELECT","Choose by vote"), ("ELITE","Top tier"), ("EMBER","Glowing coal"),
        ("EMPTY","Nothing inside"), ("ENEMY","Foe"), ("ENJOY","Take pleasure in"),
        ("ENTER","Go into"), ("ENTRY","Way in"), ("EQUAL","Same amount"),
        ("ERASE","Rub out"), ("ERROR","Mistake"), ("EVENT","Happening"),
        ("EVERY","Each one"), ("EXACT","Precise"), ("EXIST","Be real"),
        ("EXTRA","Additional"), ("FABLE","Moral story"), ("FAITH","Belief"),
        ("FALSE","Not true"), ("FEAST","Big meal"), ("FENCE","Yard boundary"),
        ("FIBER","Thread"), ("FIELD","Open land"), ("FIGHT","Battle"),
        ("FINAL","Last"), ("FIRST","Before all others"), ("FLAME","Fire tongue"),
        ("FLASH","Quick light"), ("FLASK","Small bottle"), ("FLESH","Body tissue"),
        ("FLOAT","Stay on water"), ("FLOCK","Group of birds"), ("FLOOD","Water overflow"),
        ("FLOOR","Room bottom"), ("FLOUR","Baking powder"), ("FLUID","Liquid"),
        ("FLUTE","Wind instrument"), ("FOCUS","Concentrate"), ("FORCE","Power"),
        ("FORGE","Metal workshop"), ("FORUM","Discussion place"), ("FOUND","Discovered"),
        ("FRAME","Picture border"), ("FRANK","Honest"), ("FRAUD","Deception"),
        ("FRESH","New"), ("FRONT","Forward side"), ("FROST","Ice crystals"),
        ("FROZE","Became ice"), ("FRUIT","Apple or banana"), ("FUNDS","Money"),
        ("GHOST","Spirit"), ("GIANT","Very large"), ("GIVEN","Donated"),
        ("GLARE","Harsh light"), ("GLASS","Drinking vessel"), ("GLEAM","Shine"),
        ("GLOBE","World sphere"), ("GLOOM","Darkness"), ("GLOSS","Shiny finish"),
        ("GLOVE","Hand covering"), ("GOOSE","Honking bird"), ("GRACE","Elegance"),
        ("GRADE","School mark"), ("GRAIN","Wheat or rice"), ("GRAND","Magnificent"),
        ("GRANT","Give formally"), ("GRAPE","Wine fruit"), ("GRASP","Grip"),
        ("GRASS","Lawn covering"), ("GRATE","Shred cheese"), ("GRAVE","Burial site"),
        ("GRAVY","Meat sauce"), ("GREAT","Wonderful"), ("GREED","Excessive want"),
        ("GREEN","Grass color"), ("GREET","Say hello"), ("GRIEF","Deep sadness"),
        ("GRILL","Barbecue"), ("GRIND","Crush fine"), ("GROAN","Pain sound"),
        ("GROOM","Wedding man"), ("GROUP","Collection"), ("GROVE","Small forest"),
        ("GROWL","Dog warning"), ("GROWN","Matured"), ("GUARD","Protector"),
        ("GUESS","Estimate"), ("GUIDE","Leader"), ("GUILT","Blame feeling"),
        ("HAPPY","Joyful"), ("HEART","Love organ"), ("HEAVY","Weighs a lot"),
        ("HEDGE","Bush fence"), ("HONEY","Bee product"), ("HONOR","Respect"),
        ("HORSE","Riding animal"), ("HOTEL","Lodging"), ("HOUND","Hunting dog"),
        ("HOUSE","Dwelling"), ("HUMAN","Person"), ("HUMOR","Comedy"),
        ("HURRY","Rush"), ("IMAGE","Picture"), ("INDEX","List"),
        ("INNER","Inside"), ("INPUT","Data entered"), ("IVORY","Tusk material"),
        ("JEWEL","Precious gem"), ("JOKER","Card or comedian"), ("JUDGE","Court official"),
        ("JUICE","Fruit drink"), ("KAYAK","Small boat"), ("KNIFE","Cutting tool"),
        ("KNOCK","Rap on door"), ("LABEL","Tag"), ("LABOR","Hard work"),
        ("LARGE","Big"), ("LASER","Focused light"), ("LATER","After this"),
        ("LAUGH","React to humor"), ("LAYER","Coating"), ("LEARN","Study"),
        ("LEASE","Rental agreement"), ("LEAVE","Depart"), ("LEGAL","Lawful"),
        ("LEMON","Sour citrus"), ("LEVEL","Flat"), ("LEVER","Prying tool"),
        ("LIGHT","Illumination"), ("LIMIT","Boundary"), ("LINEN","Fine fabric"),
        ("LINER","Ship"), ("LOCAL","Nearby"), ("LODGE","Cabin"),
        ("LOGIC","Reasoning"), ("LOOSE","Not tight"), ("LOVER","Romantic partner"),
        ("LOWER","Bring down"), ("LOYAL","Faithful"), ("LUCKY","Fortunate"),
        ("LUNAR","Moon-related"), ("LUNCH","Midday meal"), ("MAGIC","Sorcery"),
        ("MAJOR","Significant"), ("MANOR","Large estate"), ("MAPLE","Syrup tree"),
        ("MARCH","Walk in step"), ("MATCH","Game"), ("MAYOR","City leader"),
        ("MEDAL","Award disc"), ("MEDIA","News outlets"), ("MELON","Large fruit"),
        ("MERGE","Combine"), ("MERIT","Deserve"), ("METAL","Iron or steel"),
        ("METER","Measuring device"), ("MIGHT","Power"), ("MINOR","Small"),
        ("MODEL","Example"), ("MONEY","Currency"), ("MONTH","Year division"),
        ("MOOSE","Large deer"), ("MORAL","Ethical lesson"), ("MOTOR","Engine"),
        ("MOUND","Small hill"), ("MOUNT","Climb"), ("MOUSE","Small rodent"),
        ("MOUTH","Oral opening"), ("MOVIE","Film"), ("MUSIC","Melodic art"),
        ("NERVE","Body wire"), ("NEVER","Not ever"), ("NIGHT","After dark"),
        ("NOBLE","Dignified"), ("NOISE","Loud sound"), ("NORTH","Compass direction"),
        ("NOTED","Famous"), ("NOVEL","Book"), ("NURSE","Medical caretaker"),
        ("OASIS","Desert spring"), ("OCEAN","Large body of water"),
        ("OLIVE","Green fruit"), ("ONSET","Beginning"), ("OPERA","Singing drama"),
        ("ORBIT","Space path"), ("ORDER","Command"), ("ORGAN","Body part"),
        ("OTHER","Different"), ("OUTER","External"), ("OWNER","Possessor"),
        ("PANDA","Black and white bear"), ("PANEL","Flat section"),
        ("PANIC","Sudden fear"), ("PASTE","Sticky substance"), ("PATCH","Repair piece"),
        ("PAUSE","Brief stop"), ("PEACE","No war"), ("PEACH","Fuzzy fruit"),
        ("PEARL","Oyster gem"), ("PEDAL","Bike part"), ("PENNY","One cent"),
        ("PERCH","Bird seat"), ("PHASE","Stage"), ("PHONE","Calling device"),
        ("PIANO","Keyboard instrument"), ("PIECE","Part"), ("PILOT","Plane driver"),
        ("PINCH","Squeeze"), ("PITCH","Throw"), ("PIXEL","Screen dot"),
        ("PIZZA","Italian pie"), ("PLACE","Location"), ("PLAID","Checkered pattern"),
        ("PLAIN","Simple"), ("PLANE","Aircraft"), ("PLANK","Wood board"),
        ("PLANT","Growing thing"), ("PLATE","Dinner dish"), ("PLAZA","Public square"),
        ("PLEAD","Beg"), ("PLUCK","Pick"), ("POINT","Sharp tip"),
        ("POLAR","Arctic"), ("POUCH","Small bag"), ("POUND","Weight unit"),
        ("POWER","Strength"), ("PRESS","Push"), ("PRICE","Cost"),
        ("PRIDE","Self-respect"), ("PRIME","First quality"), ("PRINT","Put on paper"),
        ("PRIOR","Before"), ("PRIZE","Award"), ("PROBE","Investigate"),
        ("PROOF","Evidence"), ("PROSE","Written text"), ("PROUD","Self-satisfied"),
        ("PROVE","Demonstrate"), ("PROWL","Creep around"), ("PRUNE","Dried plum"),
        ("PULSE","Heartbeat"), ("PUNCH","Hit with fist"), ("PUPIL","Student"),
        ("PURSE","Handbag"), ("QUAIL","Small bird"), ("QUEEN","Royal woman"),
        ("QUEST","Search"), ("QUICK","Fast"), ("QUIET","Not loud"),
        ("QUILT","Bed covering"), ("QUIRK","Oddity"), ("QUOTE","Repeat words"),
        ("RADAR","Detection system"), ("RADIO","Broadcast receiver"),
        ("RAISE","Lift up"), ("RALLY","Gathering"), ("RANCH","Large farm"),
        ("RANGE","Extent"), ("RAPID","Very fast"), ("RAVEN","Black bird"),
        ("REACH","Extend to"), ("READY","Prepared"), ("REALM","Kingdom"),
        ("REBEL","Resist authority"), ("REIGN","Rule"), ("RELAX","Unwind"),
        ("REPLY","Answer"), ("RIDER","Horseback person"), ("RIDGE","Mountain top"),
        ("RIFLE","Long gun"), ("RIGHT","Correct"), ("RIGID","Stiff"),
        ("RISEN","Gone up"), ("RIVAL","Competitor"), ("RIVER","Water flow"),
        ("ROAST","Oven cook"), ("ROBOT","Machine worker"), ("ROCKY","Full of stones"),
        ("ROUGH","Not smooth"), ("ROUND","Circular"), ("ROUTE","Path"),
        ("ROYAL","Of a king"), ("RULER","Measuring stick"), ("RURAL","Country"),
        ("SAINT","Holy person"), ("SALAD","Green dish"), ("SAUCE","Flavor liquid"),
        ("SCALE","Weighing device"), ("SCARE","Frighten"), ("SCENE","Setting"),
        ("SCENT","Smell"), ("SCOPE","Range"), ("SCORE","Points"),
        ("SCOUT","Explorer"), ("SENSE","Feeling"), ("SERVE","Help"),
        ("SEVEN","Lucky number"), ("SHADE","Shadow"), ("SHAME","Disgrace"),
        ("SHAPE","Form"), ("SHARE","Give a portion"), ("SHARK","Ocean predator"),
        ("SHARP","Pointed"), ("SHAVE","Remove beard"), ("SHEET","Bed linen"),
        ("SHELF","Storage ledge"), ("SHELL","Outer casing"), ("SHIFT","Change"),
        ("SHINE","Give off light"), ("SHOCK","Surprise"), ("SHORE","Waterfront"),
        ("SHORT","Not tall"), ("SHOUT","Yell"), ("SHOVE","Push hard"),
        ("SIGHT","Vision"), ("SILLY","Goofy"), ("SINCE","From then"),
        ("SKATE","Ice glide"), ("SKILL","Ability"), ("SKULL","Head bone"),
        ("SLATE","Rock type"), ("SLAVE","Forced worker"), ("SLEEP","Rest at night"),
        ("SLICE","Thin piece"), ("SLIDE","Playground equipment"), ("SLOPE","Incline"),
        ("SMELL","Odor"), ("SMILE","Happy face"), ("SMOKE","Fire output"),
        ("SNACK","Light meal"), ("SNAIL","Slow creature"), ("SNAKE","Legless reptile"),
        ("SNARE","Trap"), ("SNEAK","Move stealthily"), ("SOLAR","Sun-related"),
        ("SOLID","Not liquid"), ("SOLVE","Figure out"), ("SOUTH","Compass direction"),
        ("SPACE","Outer void"), ("SPARE","Extra"), ("SPARK","Tiny fire"),
        ("SPEAK","Talk"), ("SPEAR","Throwing weapon"), ("SPEED","Velocity"),
        ("SPELL","Word letters"), ("SPEND","Use money"), ("SPICE","Flavor additive"),
        ("SPILL","Accidental pour"), ("SPINE","Backbone"), ("SPOKE","Said"),
        ("SPOON","Soup utensil"), ("SPORT","Athletic game"), ("SPRAY","Mist"),
        ("STAFF","Employees"), ("STAGE","Theater platform"), ("STAIN","Spot"),
        ("STAIR","Step"), ("STAKE","Wager"), ("STALE","Not fresh"),
        ("STALK","Plant stem"), ("STALL","Delay"), ("STAMP","Postage"),
        ("STAND","Be upright"), ("STARE","Look fixedly"), ("START","Begin"),
        ("STATE","Condition"), ("STEAK","Beef cut"), ("STEAL","Take illegally"),
        ("STEAM","Hot vapor"), ("STEEL","Strong metal"), ("STEEP","Very inclined"),
        ("STEER","Guide"), ("STERN","Ship rear"), ("STICK","Branch"),
        ("STIFF","Rigid"), ("STILL","Not moving"), ("STING","Bee attack"),
        ("STOCK","Inventory"), ("STOLE","Took"), ("STONE","Rock"),
        ("STOOD","Was upright"), ("STOOL","Backless seat"), ("STORE","Shop"),
        ("STORM","Violent weather"), ("STORY","Narrative"), ("STOUT","Sturdy"),
        ("STOVE","Kitchen cooker"), ("STRAP","Fastening band"), ("STRAW","Drinking tube"),
        ("STRAY","Wander"), ("STRIP","Narrow piece"), ("STUCK","Unable to move"),
        ("STUDY","Learn"), ("STUFF","Things"), ("STYLE","Fashion"),
        ("SUGAR","Sweet crystal"), ("SUITE","Room set"), ("SUNNY","Bright weather"),
        ("SURGE","Sudden increase"), ("SWAMP","Wetland"), ("SWEAR","Promise"),
        ("SWEAT","Perspire"), ("SWEEP","Clean with broom"), ("SWEET","Sugary"),
        ("SWIFT","Very fast"), ("SWING","Playground ride"), ("SWORD","Fighting blade"),
        ("TABLE","Dining surface"), ("TASTE","Flavor sense"), ("TEACH","Instruct"),
        ("TEMPO","Music speed"), ("TENSE","Tight"), ("THICK","Not thin"),
        ("THIEF","Robber"), ("THING","Object"), ("THINK","Ponder"),
        ("THORN","Rose prickle"), ("THREE","After two"), ("THROW","Toss"),
        ("THUMB","Hand digit"), ("TIGER","Striped cat"), ("TIGHT","Snug"),
        ("TIMER","Countdown device"), ("TITLE","Name"), ("TOAST","Breakfast bread"),
        ("TODAY","This day"), ("TOKEN","Symbol"), ("TOTAL","Sum"),
        ("TOUCH","Feel"), ("TOUGH","Hard"), ("TOWER","Tall structure"),
        ("TOXIC","Poisonous"), ("TRACE","Follow"), ("TRACK","Path"),
        ("TRADE","Exchange"), ("TRAIL","Hiking path"), ("TRAIN","Railroad vehicle"),
        ("TRAIT","Characteristic"), ("TRASH","Garbage"), ("TREAT","Special reward"),
        ("TREND","Fashion direction"), ("TRIAL","Court case"), ("TRICK","Prank"),
        ("TROUT","Freshwater fish"), ("TRUCK","Large vehicle"), ("TRULY","Honestly"),
        ("TRUNK","Tree base"), ("TRUST","Have faith"), ("TRUTH","Fact"),
        ("TULIP","Spring flower"), ("TWICE","Two times"), ("TWIST","Turn"),
        ("ULTRA","Extreme"), ("UNCLE","Parent's brother"), ("UNDER","Below"),
        ("UNION","Workers group"), ("UNITE","Join together"), ("UNITY","Togetherness"),
        ("UNTIL","Up to"), ("UPPER","Higher"), ("UPSET","Disturbed"),
        ("URBAN","City"), ("USUAL","Normal"), ("UTTER","Speak"),
        ("VALID","Legitimate"), ("VALUE","Worth"), ("VAPOR","Steam"),
        ("VAULT","Secure room"), ("VIDEO","Moving pictures"), ("VIGOR","Energy"),
        ("VINYL","Record material"), ("VIOLA","String instrument"),
        ("VISIT","Go see"), ("VITAL","Essential"), ("VIVID","Bright"),
        ("VOCAL","Outspoken"), ("VOICE","Speech sound"), ("VOTER","Ballot caster"),
        ("WASTE","Throw away"), ("WATCH","Timepiece"), ("WATER","H2O"),
        ("WEAVE","Make fabric"), ("WHALE","Ocean giant"), ("WHEAT","Bread grain"),
        ("WHEEL","Round disc"), ("WHERE","What place"), ("WHILE","During"),
        ("WHITE","Snow color"), ("WHOLE","Entire"), ("WIDTH","How wide"),
        ("WITCH","Halloween figure"), ("WOMAN","Adult female"), ("WORLD","Earth"),
        ("WORST","Least good"), ("WORTH","Value"), ("WOUND","Injury"),
        ("WRIST","Hand joint"), ("WROTE","Put on paper"), ("YACHT","Luxury boat"),
        ("YIELD","Produce"), ("ZEBRA","Striped animal"),
    ]
}

# Index words by length, and by (length, position, letter)
word_index = {}
for length, wlist in WORDS.items():
    for word, clue in wlist:
        for i, ch in enumerate(word):
            key = (length, i, ch)
            word_index.setdefault(key, []).append((word, clue))


def solve(grid, slots, used, idx=0):
    """Backtracking solver."""
    if idx >= len(slots):
        return True

    direction, cells, length = slots[idx]

    # Get constraints
    constraints = {}
    for i, (r, c) in enumerate(cells):
        if grid[r][c] != '.':
            constraints[i] = grid[r][c]

    # Build candidate list using index
    if constraints:
        # Start with the most constrained position
        pos, letter = next(iter(constraints.items()))
        key = (length, pos, letter)
        candidates = word_index.get(key, [])
    else:
        candidates = WORDS.get(length, [])

    random.shuffle(candidates)

    for word, clue in candidates[:200]:
        if word in used:
            continue
        if len(word) != length:
            continue

        # Check all constraints
        ok = True
        for pos, letter in constraints.items():
            if word[pos] != letter:
                ok = False
                break
        if not ok:
            continue

        # Place word
        saved = [(r, c, grid[r][c]) for r, c in cells]
        for i, (r, c) in enumerate(cells):
            grid[r][c] = word[i]
        used.add(word)

        if solve(grid, slots, used, idx + 1):
            return True

        # Backtrack
        used.discard(word)
        for r, c, v in saved:
            grid[r][c] = v

    return False


def extract_slots(grid, rows, cols):
    """Get all word slots (3+ letters)."""
    slots = []
    # Across
    for r in range(rows):
        c = 0
        while c < cols:
            if grid[r][c] != '#':
                start = c
                while c < cols and grid[r][c] != '#':
                    c += 1
                length = c - start
                if length >= 3:
                    slots.append(('across', [(r, start + i) for i in range(length)], length))
            else:
                c += 1
    # Down
    for c in range(cols):
        r = 0
        while r < rows:
            if grid[r][c] != '#':
                start = r
                while r < rows and grid[r][c] != '#':
                    r += 1
                length = r - start
                if length >= 3:
                    slots.append(('down', [(start + i, c) for i in range(length)], length))
            else:
                r += 1
    return slots


def number_grid(grid, rows, cols):
    """Compute clue numbers per NYT rules."""
    numbers = {}
    num = 1
    for r in range(rows):
        for c in range(cols):
            if grid[r][c] == '#':
                continue
            starts_across = (c == 0 or grid[r][c-1] == '#') and (c+1 < cols and grid[r][c+1] != '#')
            starts_down = (r == 0 or grid[r-1][c] == '#') and (r+1 < rows and grid[r+1][c] != '#')
            if starts_across or starts_down:
                numbers[(r, c)] = num
                num += 1
    return numbers


def get_clue(word):
    """Look up clue."""
    for length, wlist in WORDS.items():
        for w, c in wlist:
            if w == word:
                return c
    return f"({len(word)} letters)"


# 5x5 grid with blacks at (0,4) and (4,0) — 180° symmetric
template = [
    list("....#"),
    list("....."),
    list("....."),
    list("....."),
    list("#...."),
]

rows, cols = 5, 5
slots = extract_slots(template, rows, cols)
# Sort by most constrained (longest first)
slots.sort(key=lambda s: -s[2])

print(f"Slots: {len(slots)}")
for d, cells, length in slots:
    print(f"  {d}: {length} letters at {cells}")

# Try to fill
best = None
for attempt in range(100):
    grid = [row[:] for row in template]
    random.seed(42 + attempt)
    if solve(grid, slots, set()):
        # Verify no unfilled cells
        all_filled = all(grid[r][c] != '.' for r in range(rows) for c in range(cols) if grid[r][c] != '#')
        if all_filled:
            best = [row[:] for row in grid]
            print(f"\nSolved on attempt {attempt}!")
            break

if not best:
    print("Failed to generate puzzle")
    exit(1)

# Print grid
print("\nGrid:")
for row in best:
    print(" ".join(row))

# Build puzzle JSON
numbers = number_grid(best, rows, cols)
across_clues = []
down_clues = []

# Across
for r in range(rows):
    c = 0
    while c < cols:
        if best[r][c] != '#':
            start = c
            word = ""
            while c < cols and best[r][c] != '#':
                word += best[r][c]
                c += 1
            if len(word) >= 3 and (r, start) in numbers:
                across_clues.append({
                    "number": numbers[(r, start)],
                    "clue": get_clue(word),
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
        if best[r][c] != '#':
            start = r
            word = ""
            while r < rows and best[r][c] != '#':
                word += best[r][c]
                r += 1
            if len(word) >= 3 and (start, c) in numbers:
                down_clues.append({
                    "number": numbers[(start, c)],
                    "clue": get_clue(word),
                    "answer": word,
                    "row": start,
                    "col": c
                })
        else:
            r += 1

puzzle = {
    "id": "puzzle_001",
    "version": 1,
    "size": {"rows": 5, "cols": 5},
    "difficulty": "easy",
    "theme": "Everyday Life",
    "date": None,
    "grid": best,
    "clues": {
        "across": across_clues,
        "down": down_clues
    },
    "tags": ["daily"],
    "author": "CouchWord"
}

# Validate
errors = []
for d in ["across", "down"]:
    for cl in puzzle["clues"][d]:
        word = ""
        for i in range(len(cl["answer"])):
            r = cl["row"] + (i if d == "down" else 0)
            c = cl["col"] + (i if d == "across" else 0)
            word += best[r][c]
        if word != cl["answer"]:
            errors.append(f"{d} {cl['number']}: {cl['answer']} != {word}")

if errors:
    print(f"\nVALIDATION ERRORS: {errors}")
    exit(1)

print(f"\nAcross clues: {len(across_clues)}")
for c in across_clues:
    print(f"  {c['number']}-Across: {c['answer']} — {c['clue']}")
print(f"Down clues: {len(down_clues)}")
for c in down_clues:
    print(f"  {c['number']}-Down: {c['answer']} — {c['clue']}")

# Write
outpath = "/Users/sheldon/Development/CouchWord/CouchWord/Resources/Puzzles/puzzle_001.json"
with open(outpath, 'w') as f:
    json.dump(puzzle, f, indent=2)
print(f"\nWritten to {outpath}")
