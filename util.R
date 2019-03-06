# util.R
#

# === Packages =================================================================

# if (! requireNamespace("writexl", quietly = TRUE)) {
#   install.packages("writexl")
# }

if (! requireNamespace("readxl", quietly = TRUE)) {
  install.packages("readxl")
}

if (! requireNamespace("qrandom", quietly = TRUE)) {
  install.packages("qrandom")
}


# === Scripts ==================================================================

source("toBrowser.R")

# === Functions ================================================================

pBar <- function(i, l, nCh = 50) {
  # Draw a progress bar in the console
  # i: the current iteration
  # l: the total number of iterations
  # nCh: width of the progress bar
  ticks <- round(seq(1, l-1, length.out = nCh))
  if (i < l) {
    if (any(i == ticks)) {
      p <- which(i == ticks)[1]  # use only first, in case there are ties
      p1 <- paste(rep("#", p), collapse = "")
      p2 <- paste(rep("-", nCh - p), collapse = "")
      cat(sprintf("\r|%s%s|", p1, p2))
      flush.console()
    }
  }
  else { # done
    cat("\n")
  }
}


QQID <- function(n = 1) {
  # Fetch quantum random UUIDs in QQ format.
  # n: (numeric) Number of random values to return. Must be in [1, 1e5].
  #              Default 1.
  # value: (char) A vector of n QQ formatted UUIDs.
  #
  # Note: Requesting more than 1024 numbers may be inefficient since this
  #       will be processed in batches by qrandom::qrandom().

  if (! is.numeric(n) || n < 1 || n > 1e5) {
    stop("qrandom::qUUID requires n to be in [1, 1e5].")
  }

  w1024 <- c("love", "maps", "ease", "fist", "wasp", "rice", "work", "stag",
             "hush", "here", "wing", "grip", "dams", "seen", "eats", "pork",
             "date", "sunk", "heal", "mesh", "bump", "lurk", "cold", "ride",
             "ruin", "jets", "claw", "slug", "legs", "bans", "boar", "sums",
             "flaw", "wash", "cite", "cake", "ramp", "loud", "puff", "maze",
             "bond", "font", "loan", "toad", "pole", "soft", "skip", "knee",
             "zinc", "hiss", "wind", "bars", "soil", "bear", "rope", "flat",
             "lack", "club", "snow", "guts", "fame", "pain", "hill", "fork",
             "drop", "some", "drip", "thus", "limb", "cars", "flop", "malt",
             "suit", "herd", "till", "rank", "leak", "name", "post", "mail",
             "pick", "kept", "smug", "node", "swap", "dash", "tubs", "chip",
             "wish", "them", "crew", "soup", "mock", "root", "door", "vast",
             "weld", "goat", "lame", "pint", "woes", "tank", "core", "dish",
             "trim", "bent", "note", "move", "reed", "food", "herb", "spun",
             "melt", "brew", "coup", "nine", "joys", "show", "logs", "reap",
             "farm", "bulk", "tine", "snap", "mark", "hose", "horn", "bare",
             "salt", "pane", "time", "bark", "hurt", "reef", "clip", "cool",
             "dome", "lots", "that", "pair", "golf", "wipe", "fell", "hint",
             "arts", "tied", "ship", "home", "flow", "jobs", "flux", "term",
             "torn", "stub", "nets", "fish", "main", "spur", "poll", "leek",
             "shim", "pail", "paid", "feel", "fins", "dark", "task", "pale",
             "tool", "bowl", "fare", "vine", "rule", "lint", "raid", "pope",
             "fast", "cubs", "docs", "lynx", "rush", "pays", "clad", "sale",
             "pure", "wait", "ring", "wolf", "mule", "mole", "flag", "odds",
             "bold", "tops", "duct", "pour", "gust", "loaf", "lisp", "wage",
             "bath", "case", "hens", "rose", "neat", "self", "chew", "face",
             "crab", "flew", "warp", "rain", "cash", "pods", "cage", "else",
             "bays", "star", "bead", "boot", "slap", "file", "told", "sung",
             "saws", "fold", "haul", "bits", "haze", "tube", "fort", "fuse",
             "view", "hoax", "prey", "tell", "fall", "dame", "aunt", "kiln",
             "deaf", "whip", "flex", "mood", "just", "cell", "glue", "turf",
             "palm", "gone", "path", "pave", "arch", "says", "talk", "tail",
             "wars", "burr", "whey", "wife", "beer", "leap", "hunt", "fled",
             "high", "mold", "word", "pike", "dare", "gale", "sins", "grow",
             "mine", "sing", "grew", "heat", "hear", "wave", "laid", "flip",
             "fume", "fuss", "bird", "dent", "wrap", "glad", "pots", "mint",
             "rare", "hull", "hand", "site", "foot", "hard", "pill", "beef",
             "hymn", "doom", "fail", "plus", "pack", "dues", "more", "film",
             "dock", "shoe", "whom", "code", "mode", "noon", "your", "snip",
             "heel", "carp", "crow", "most", "text", "soul", "swim", "ball",
             "hair", "does", "norm", "plow", "mane", "shot", "fuel", "rats",
             "less", "dean", "sort", "pool", "gift", "quit", "skid", "bids",
             "help", "rift", "felt", "worm", "gate", "last", "rate", "sign",
             "made", "real", "stir", "game", "lace", "slim", "silk", "head",
             "tier", "vase", "hack", "robe", "june", "mild", "thee", "whim",
             "glow", "flee", "duck", "lens", "lift", "dorm", "caps", "want",
             "type", "oath", "sold", "cues", "cape", "oils", "kits", "trip",
             "stem", "with", "moth", "warm", "folk", "mime", "coal", "peat",
             "byte", "isle", "mess", "deed", "dull", "grub", "hour", "bone",
             "hits", "long", "nick", "cows", "cove", "gold", "flax", "pens",
             "walk", "ones", "leaf", "laud", "grog", "junk", "rise", "once",
             "card", "tear", "sigh", "coin", "were", "wide", "quiz", "tray",
             "bank", "sled", "dies", "harm", "blur", "sole", "land", "wear",
             "jaws", "plum", "thru", "lose", "rash", "bend", "what", "lead",
             "zoom", "reel", "used", "dawn", "meal", "teas", "this", "chef",
             "spam", "trap", "tack", "hall", "thaw", "sell", "wool", "bean",
             "owns", "peer", "lore", "tent", "need", "pith", "gram", "spot",
             "plan", "rays", "jars", "heir", "song", "took", "tide", "wigs",
             "loss", "lung", "gown", "clay", "heed", "lips", "dive", "toys",
             "read", "knit", "thin", "coop", "bolt", "free", "play", "rake",
             "side", "toll", "wine", "hope", "cork", "lamb", "sure", "lure",
             "pulp", "pits", "asks", "host", "muse", "bike", "hail", "five",
             "pray", "pull", "slid", "chow", "void", "pies", "knew", "grim",
             "ears", "mens", "moat", "huts", "dead", "bile", "hawk", "load",
             "give", "cave", "goes", "soak", "coat", "gull", "mist", "chop",
             "burn", "hold", "slip", "sand", "rant", "seem", "dump", "keen",
             "look", "tick", "tang", "urge", "brag", "king", "fool", "step",
             "part", "drug", "they", "sits", "vain", "sane", "shin", "warn",
             "nose", "germ", "peas", "fine", "bows", "sway", "fees", "cart",
             "tend", "shut", "roll", "grid", "like", "vise", "band", "grab",
             "gong", "form", "barb", "ties", "tern", "pond", "will", "sore",
             "foal", "boys", "lies", "tile", "book", "well", "grin", "hike",
             "sock", "risk", "seed", "true", "lord", "moon", "curb", "peel",
             "plot", "hats", "line", "fear", "done", "tape", "have", "foam",
             "shed", "edge", "toil", "span", "swan", "cult", "said", "tall",
             "loop", "wall", "rode", "mute", "acts", "girl", "bill", "find",
             "then", "room", "pins", "verb", "mice", "veil", "know", "yarn",
             "tort", "foul", "mile", "been", "send", "cats", "curl", "lull",
             "cube", "must", "neck", "lend", "halt", "cook", "beds", "fond",
             "brow", "came", "dear", "fake", "surf", "ploy", "kiss", "maid",
             "tuck", "both", "zone", "huge", "calf", "belt", "inns", "camp",
             "dart", "barn", "harp", "week", "poor", "lied", "swat", "twin",
             "lawn", "sons", "cast", "from", "stew", "arms", "team", "joke",
             "stay", "boat", "lone", "same", "feat", "newt", "slot", "seas",
             "bets", "cord", "page", "next", "pose", "soot", "kite", "laws",
             "damp", "buds", "laps", "cans", "roar", "dirt", "dust", "live",
             "guys", "feet", "jail", "tips", "hugs", "bugs", "east", "sail",
             "lump", "ware", "prod", "rear", "slow", "deal", "gait", "aims",
             "jade", "math", "mink", "weak", "lock", "loft", "gain", "miss",
             "full", "bail", "each", "volt", "rugs", "watt", "much", "alps",
             "limp", "fair", "desk", "husk", "dogs", "sent", "rock", "jams",
             "yawn", "dusk", "rows", "gall", "seal", "toes", "slab", "cost",
             "road", "take", "blue", "bins", "ends", "wren", "news", "mean",
             "gang", "lush", "wore", "scan", "fans", "gill", "mash", "gray",
             "beam", "webs", "goal", "dune", "moss", "dose", "eggs", "tram",
             "tint", "list", "heap", "died", "gems", "beak", "lent", "test",
             "toss", "tune", "tilt", "gulf", "bred", "mare", "fade", "none",
             "wand", "nice", "foil", "back", "bees", "fill", "bald", "taps",
             "mite", "peak", "wake", "bull", "loom", "thug", "dine", "monk",
             "drag", "deem", "bard", "lost", "pier", "ripe", "keep", "bite",
             "hare", "mind", "quay", "cone", "prop", "cute", "doll", "sage",
             "sift", "boss", "male", "debt", "turn", "late", "drum", "cope",
             "kind", "gear", "fits", "sets", "lids", "base", "hood", "bats",
             "shop", "teak", "rest", "gave", "skin", "wail", "myth", "such",
             "sees", "cups", "milk", "oaks", "peek", "pawn", "raft", "hide",
             "ribs", "days", "wade", "pets", "clan", "helm", "near", "bell",
             "tomb", "care", "calm", "pace", "rich", "rang", "tone", "fund",
             "firm", "cane", "tabs", "clue", "cure", "mugs", "suns", "chin",
             "tons", "make", "lake", "ward", "lime", "port", "balm", "went",
             "lark", "crib", "wild", "scar", "link", "pear", "coil", "rail",
             "mall", "keys", "feed", "gage", "spar", "rink", "lean", "tale",
             "wins", "mead", "tags", "frog", "good", "vent", "pipe", "life",
             "left", "hoop", "mask", "seek", "meet", "year", "twig", "pine",
             "rust", "kick", "prep", "boil", "dots", "runs", "deep", "paws",
             "vote", "peck", "wood", "half", "mere", "hang", "gene", "sink",
             "bulb", "feud", "held", "pest", "yell", "mill", "vest", "labs",
             "seam", "bore", "sang", "disk", "fern", "born", "draw", "pile",
             "fact", "lute", "safe", "stab", "when", "fawn", "hemp", "rage",
             "rave", "bind", "past", "wise", "luck", "lamp", "mate", "fate",
             "cuff", "deer", "tree", "town", "yard", "park", "corn", "comb",
             "join", "than", "four", "best", "soon", "seat", "bake", "soar",
             "tong", "nest", "size", "push", "owls", "blot", "temp", "pant",
             "gaze", "keel", "jest", "crop", "down", "noun", "vows", "hook",
             "hash", "west", "dove", "nail", "chat", "soap", "lane", "teal",
             "plea", "tour", "knot", "wink", "howl", "flea", "mast", "stop",
             "spin", "kids", "jump", "duke", "bout", "gaps", "beat", "fang",
             "role", "ants", "worn", "rods", "deck", "scam", "sect", "call",
             "rent", "earn", "roof", "figs", "save", "hive", "rook", "pump")

  x5int <- function(x) {
    # x: a 5 digit hex number
    # return: a 2 integer vector from 2 * 10 bits - in the range [0, 1023]
    #
    # |--0x[1]--| |--0x[2]--| |--0x[3]--| |--0x[4]--| |--0x[5]--|
    # 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    # |----------int[1]-----------| |----------int[2]-----------|

    pow2 <- 2^(0:9)
    x <- intToBits(strtoi(x))[c(17:20,13:16,9:12,5:8,1:4)]
    int <- sum(as.integer(x[1:10]) * pow2)
    int[2] <- sum(as.integer(x[11:20]) * pow2)
    return(int)
  }

  uu2qq <- function(x) {
    # format a vector of UUIDs as QQID
    # x (character) UUID
    # value: (character) same UUIDs in QQID format

    u2q <- function(x) {
      # format one single UUID to QQID
      qHead <- paste0("0x", substring(x, 1, 5))
      qHead <- x5int(qHead) + 1  # range [0, 1023] -> [1, 1024]
      qHead <- w1024[qHead]
      qq <- paste0(qHead[1], ".", qHead[2], "-", substring(x, 6, 36))
      return(qq)
    }
    QQ <- sapply(x, FUN = u2q, USE.NAMES = FALSE)
    return(QQ)
  }

  return(uu2qq(qrandom::qUUID(n)))

}


makeFetchQQ <- function() {
  # Fetch QQIDs from cached store. This closure keeps a cache of new QQIDs from
  # which it shifts IDs when required. A call to the ANU server will only be
  # triggered when the cache is depleted.
  nBatch <- 1023  # largest batch that qrandom::qrandom will fetch in one call
  QQ <- QQID(nBatch)
  return(function(n = 1) {
    # shift elements from QQ, replenish QQ when it gets smaller than n
    if (length(QQ) < n) {
      QQ <<- c(QQ, QQID(nBatch))
    }
    x <- QQ[1:n]
    QQ <<- QQ[-(1:n)]
    return(x)
  })
}

fetchQQ <- makeFetchQQ()
rm(makeFetchQQ) # Clean up - we needed this factory function only once per
                # session to create the makeFetchQQ() closure.


#=== Function to initialize a system datamodel


initSysDB <- function() {
  # initialize a systems database
  initFile <- "sysDB_init_2.1.0.xlsx"
  sysDB <- list()
  sysDB$parameter <- as.data.frame(readxl::read_excel(initFile,
                                                      sheet = "parameter"))
  sysDB$type <- as.data.frame(readxl::read_excel(initFile,
                                                      sheet = "type"))

  sysDB$system <- data.frame(ID = character(),
                             code = character(),
                             name = character(),
                             def = character(),
                             description = character(),
                             stringsAsFactors = FALSE)

  sysDB$systemComponent <- data.frame(ID = character(),
                                      systemID = character(),
                                      componentID = character(),
                                      evidenceType = character(),
                                      evidenceSource = character(),
                                      role = character(),
                                      notes = character(),
                                      stringsAsFactors = FALSE)

  # sysDB$componentSystem <- data.frame(ID = character(),
  #                                     componentID = character(),
  #                                     systemID = character(),
  #                                     stringsAsFactors = FALSE)

  sysDB$component <- data.frame(ID = character(),
                                code = character(),
                                componentType = character(),
                                stringsAsFactors = FALSE)

  sysDB$componentMolecule <- data.frame(ID = character(),
                                        componentID = character(),
                                        moleculeID = character(),
                                        stringsAsFactors = FALSE)

  sysDB$molecule <- data.frame(ID = character(),
                               name = character(),
                               moleculeType = character(),
                               structure = character(),
                               stringsAsFactors = FALSE)

  sysDB$geneProduct <- data.frame(ID = character(),
                                    geneID = character(),
                                    moleculeID = character(),
                                    stringsAsFactors = FALSE)

  sysDB$gene <- data.frame(ID = character(),
                           symbol = character(),
                           name = character(),
                           stringsAsFactors = FALSE)

  sysDB$note <- data.frame(ID = character(),
                           targetID = character(),
                           typeID = character(),
                           note = character(),
                           stringsAsFactors = FALSE)

  return(sysDB)
}

getTypeID <- function(DB, key) {
  isThisKey <- DB$type$name == key
  stopifnot(sum(isThisKey) == 1)
  return(DB$type$ID[isThisKey])
}

getSystemID <- function(DB, key) {
  isThisKey <- DB$system$code == key
  stopifnot(sum(isThisKey) == 1)
  return(DB$system$code[isThisKey])
}

getComponentID <- function(DB, key) {
  isThisKey <- DB$component$code == key
  stopifnot(sum(isThisKey) == 1)
  return(DB$component$code[isThisKey])
}



# [END]
