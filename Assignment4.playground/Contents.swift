// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Splits a line into fields.
/// fields("crate:101:120")            -> ["crate", "101", "120"]
/// fields("livestock:lab mice:12:2")  -> ["livestock", "lab mice", "12", "2"]
/// fields("junk")                     -> ["junk"]
func fields(_ line: String, separatedBy separator: Character = ":") -> [String] {
    var result: [String] = []
    var current = ""
    for character in line {
        if character == separator {
            result.append(current)
            current = ""
        } else {
            current.append(character)
        }
    }
    result.append(current)
    return result
}

/// Cargo manifest as recovered from the damaged recorder.
let rawManifest = [
    "crate:101:120",
    "container:KZ-ALM-7:340",
    "livestock:lab mice:12:2",
    "???-corrupted-line",
    "crate:102:75",
    "container:KZ-ALM-9:410",
    "livestock:ficus:3:5",
    "crate:103:260",
    "crate:104:abc",
    ""
]

/// Oxygen readings. One of these deck names is not a real deck.
let deckReadings: [(deck: String, oxygen: Int)] = [
    (deck: "bridge",     oxygen: 78),
    (deck: "lab",        oxygen: 64),
    (deck: "greenhouse", oxygen: 55),
    (deck: "cargo",      oxygen: 12),
    (deck: "medbay",     oxygen: 90),
    (deck: "engine",     oxygen: 41)
]

/// Crew records, straight from the personnel file.
let crewData: [(name: String, deck: String, oxygen: Int)] = [
    (name: "Timur",   deck: "engine", oxygen: 62),
    (name: "Dana",    deck: "lab",    oxygen: 48),
    (name: "Aigerim", deck: "bridge", oxygen: 91),
    (name: "Nurlan",  deck: "cargo",  oxygen: 17)
]

print("ALMA-7 recorder online: \(rawManifest.count) manifest lines, \(deckReadings.count) readings, \(crewData.count) crew records.")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================

// MARK: Level 1 · The Deck Register
// 1.1
enum Deck: String, CaseIterable {
    case bridge, lab, cargo, medbay, engine
    var evacuationPriority: Int {
        switch self {
        case .bridge: return 1
        case .medbay: return 2
        case .lab:    return 3
        case .engine: return 4
        case .cargo:  return 5
        }
    }
}

print("Level 1.1: decks ")
for deck in Deck.allCases {
    print("\(deck.rawValue): evacuation priority \(deck.evacuationPriority)")
}

// 1.2
enum AlarmLevel: Int {
    case green = 0, yellow, orange, red

    static func level(forTotalMass mass: Int) -> AlarmLevel {
        let steps = min(max(mass, 0) / 500, 3)
        return AlarmLevel(rawValue: steps) ?? .red
    }
}

print("Level 1.2: alarm levels ")
print("0 kg    -> \(AlarmLevel.level(forTotalMass: 0))")
print("940 kg  -> \(AlarmLevel.level(forTotalMass: 940))")
print("4000 kg -> \(AlarmLevel.level(forTotalMass: 4000))")


// MARK: Level 2 · The Manifest
// 2.1
enum ManifestEntry {
    case crate(id: Int, massKg: Int)
    case container(code: String, massKg: Int)
    case livestock(species: String, count: Int, massPerUnitKg: Int)
    case unknown(raw: String)
}

// 2.2
func parseEntry(_ line: String) -> ManifestEntry {
    let parts = fields(line)
    switch parts[0] {
    case "crate":
        if parts.count == 3, let id = Int(parts[1]), let massKg = Int(parts[2]) {
            return .crate(id: id, massKg: massKg)
        }
    case "container":
        if parts.count == 3, let massKg = Int(parts[2]) {
            return .container(code: parts[1], massKg: massKg)
        }
    case "livestock":
        if parts.count == 4, let count = Int(parts[2]), let perUnit = Int(parts[3]) {
            return .livestock(species: parts[1], count: count, massPerUnitKg: perUnit)
        }
    default:
        break
    }
    return .unknown(raw: line)
}

// 2.3
func mass(of entry: ManifestEntry) -> Int {
    switch entry {
    case .crate(_, let massKg):
        return massKg
    case .container(_, let massKg):
        return massKg
    case .livestock(_, let count, let massPerUnitKg):
        return count * massPerUnitKg
    case .unknown:
        return 0
    }
}

print("Level 2: manifest ")
var manifestMass = 0
var unknownCount = 0
for line in rawManifest {
    let entry = parseEntry(line)
    manifestMass += mass(of: entry)
    if case .unknown = entry { unknownCount += 1 }
    print("\"\(line)\" -> \(entry) (\(mass(of: entry)) kg)")
}
print("Total manifest mass: \(manifestMass) kg")
print("Unknown lines: \(unknownCount)")

let A = manifestMass


// MARK: Level 3 · Crew Snapshots
// 3.1
struct CrewSnapshot {
    let name: String
    var deck: Deck
    var oxygen: Int

    mutating func breathe(_ amount: Int) {
        oxygen = max(0, oxygen - amount)
    }

    mutating func move(to deck: Deck) {
        self.deck = deck
    }

    mutating func reviveInMedbay() {
        self = CrewSnapshot(name: name, deck: .medbay, oxygen: 100)
    }

    static func rookie(named name: String) -> CrewSnapshot {
        return CrewSnapshot(name: name, deck: .bridge, oxygen: 100)
    }
}

// 3.2
var crewRoster: [CrewSnapshot] = []
for record in crewData {
    guard let deck = Deck(rawValue: record.deck) else {
        print("WARNING: \(record.name) is on unknown deck '\(record.deck)', skipped")
        continue
    }
    crewRoster.append(CrewSnapshot(name: record.name, deck: deck, oxygen: record.oxygen))
}
print("Level 3.2: roster ")
for member in crewRoster {
    print("\(member.name) on \(member.deck.rawValue), oxygen \(member.oxygen)")
}

// 3.3 · Value-semantics demonstration
func drain(_ snapshot: CrewSnapshot) {
    var local = snapshot
    local.breathe(30)
    print("  inside drain (plain): \(local.oxygen)")
}

func drainInPlace(_ snapshot: inout CrewSnapshot) {
    snapshot.breathe(30)
}

print("Level 3.3: structs are values ")
var original = CrewSnapshot.rookie(named: "Test")
var copy = original
print("1. before: original \(original.oxygen), copy \(copy.oxygen)")
copy.breathe(50)
print("1. after modifying copy: original \(original.oxygen), copy \(copy.oxygen)")

print("2. before plain function: original \(original.oxygen)")
drain(original)
print("2. after plain function:  original \(original.oxygen)  (unchanged)")

print("3. before inout: original \(original.oxygen)")
drainInPlace(&original)
print("3. after inout:  original \(original.oxygen)  (changed)")


// MARK: Level 4 · The Teleport Pod
// 4.1
final class TeleportPod {
    let id: String
    var chargeLevel: Int
    var occupant: CrewSnapshot?

    init(id: String, chargeLevel: Int) {
        self.id = id
        self.chargeLevel = chargeLevel
        self.occupant = nil
    }

    deinit {
        print("Pod \(id) deinitialized")
    }

    func load(_ crew: CrewSnapshot) -> Bool {
        if occupant != nil || chargeLevel < 20 {
            return false
        }
        occupant = crew
        return true
    }

    func fire() -> CrewSnapshot? {
        guard let passenger = occupant else {
            return nil
        }
        chargeLevel -= 20
        occupant = nil
        return passenger
    }
}

// 4.2 · Charge ledger
func crewMember(named name: String, in roster: [CrewSnapshot]) -> CrewSnapshot? {
    for member in roster where member.name == name {
        return member
    }
    return nil
}

print("Level 4.2: charge ledger ")
let podP1 = TeleportPod(id: "P-1", chargeLevel: 100)
for name in ["Timur", "Dana", "Nurlan"] {
    if let member = crewMember(named: name, in: crewRoster) {
        let loaded = podP1.load(member)
        let sent = podP1.fire()
        print("load \(name): \(loaded), fired: \(sent?.name ?? "nobody"), charge now \(podP1.chargeLevel)")
    }
}
let emptyShot = podP1.fire()
print("fire empty pod: \(emptyShot?.name ?? "nil"), charge now \(podP1.chargeLevel)")

let C = podP1.chargeLevel

// 4.3 · Reference-semantics demonstration
print("Level 4.3: classes are references ")
let demoPod = TeleportPod(id: "P-2", chargeLevel: 100)
let podAlias = demoPod
podAlias.chargeLevel = 55
print("pod: demoPod \(demoPod.chargeLevel), podAlias \(podAlias.chargeLevel)")

let snapA = CrewSnapshot.rookie(named: "Same")
var snapB = snapA
snapB.oxygen = 10
print("snapshot: snapA \(snapA.oxygen), snapB \(snapB.oxygen)")


// MARK: Level 5 · Station Systems
// 5.1
final class Station {
    let callSign: String

    var hullIntegrity: Int = 100 {
        willSet {
            print("Hull integrity: \(hullIntegrity) -> \(newValue)")
        }
        didSet {
            if hullIntegrity > 100 {
                hullIntegrity = 100
            } else if hullIntegrity < 0 {
                hullIntegrity = 0
            }
        }
    }

    var oxygenByDeck: [Deck: Int] = [:]

    lazy var fullDiagnostics: String = {
        print("Running full scan...")
        return "Diagnostics for \(self.callSign): hull \(self.hullIntegrity)%, total oxygen \(self.totalOxygen)"
    }()

    var totalOxygen: Int {
        var total = 0
        for (_, value) in oxygenByDeck {
            total += value
        }
        return total
    }

    var averageOxygen: Int {
        get {
            if oxygenByDeck.isEmpty { return 0 }
            return totalOxygen / oxygenByDeck.count
        }
        set {
            for deck in Array(oxygenByDeck.keys) {
                oxygenByDeck[deck] = newValue
            }
        }
    }

    init(callSign: String, readings: [(deck: String, oxygen: Int)]) {
        self.callSign = callSign
        for reading in readings {
            if let deck = Deck(rawValue: reading.deck) {
                oxygenByDeck[deck] = reading.oxygen
            } else {
                print("WARNING: reading for unknown deck '\(reading.deck)' skipped")
            }
        }
    }
}

print("Level 5.1: station ")
let station = Station(callSign: "ALMA-7", readings: deckReadings)
let B = station.averageOxygen
print("Total oxygen: \(station.totalOxygen), average: \(station.averageOxygen)")

print("Station created; fullDiagnostics not touched yet (no scan so far)")
print(station.fullDiagnostics)
print(station.fullDiagnostics)

station.averageOxygen = 70
print("After setting average to 70: \(station.oxygenByDeck.count) decks, total \(station.totalOxygen)")

// 5.2 · The clamp trap
print("Level 5.2: clamp ")
station.hullIntegrity = 130
print("hull: \(station.hullIntegrity)")
station.hullIntegrity = -40
print("hull: \(station.hullIntegrity)")
station.hullIntegrity = 55
print("hull: \(station.hullIntegrity)")


// MARK: Level 6 · Incident Reports
// Report 1 · compiles, wrong
// Expected: every crew member in `roster` loses 10 oxygen.
// Actual: prints the unchanged oxygen. `for var member in roster` gives a COPY of
// each struct (value semantics); the loop changes copies, then throws them away.
// (The compiler also warns that `var roster` is never mutated.)
// Rule: structs are copied on assignment/iteration.
// Fix:
//   var roster = crewRoster
//   for index in roster.indices { roster[index].oxygen -= 10 }

// Report 2 · compiles, wrong
// Expected: podA stays at 100.
// Actual: prints 0. TeleportPod is a class, so `let podB = podA` copies the
// reference; both names point at the same object.
// Rule: classes are reference types.
// Fix: make an independent pod, e.g. `let podB = TeleportPod(id: "B", chargeLevel: podA.chargeLevel)`,
// or make the pod a struct if sharing was never wanted.

// Report 3 · does not compile
// Error: "cannot use mutating member on immutable value: 'self' is immutable".
// Methods on structs are non-mutating by default, so `self` is constant inside them.
// Rule: a method that changes a struct's properties must be marked `mutating`.
// Fix:
struct Logbook {
    var entries: [String] = []
    mutating func add(_ entry: String) {
        entries.append(entry)
    }
}
var logbook = Logbook()
logbook.add("Teleporter test")
print("Logbook entries: \(logbook.entries.count), first: \(logbook.entries[0])")

// Report 4 · first assignment does not compile
// `snapshot.oxygen = 40` -> error: cannot assign to property: 'snapshot' is a 'let' constant.
// `pod.chargeLevel = 10` is fine.
// Rule: `let` on a struct freezes the whole value (every property, since the value IS
// the properties). `let` on a class freezes only the reference (which object the name
// points to); the object's own `var` properties stay mutable.
// Fix: `var snapshot = ...` for the struct; the pod line needs no change.


// MARK: Level 7 · Sealing the Black Box

final class FlightRecorder {
    private var storedEntries: [String] = []

    private(set) var isSealed = false

    internal var entryCount: Int { storedEntries.count }

    internal var transcript: String {
        var text = ""
        for (index, entry) in storedEntries.enumerated() {
            text += "#\(index + 1): \(entry)\n"
        }
        return text
    }

    internal func record(_ entry: String) {
        if isSealed { return }
        storedEntries.append(entry)
    }

    internal func seal() {
        isSealed = true
    }

    fileprivate func entriesCopy() -> [String] {
        return storedEntries
    }
}

func auditTranscript(of recorder: FlightRecorder) -> String {
    let copy = recorder.entriesCopy()
    return "AUDIT: \(copy.count) entries, sealed: \(recorder.isSealed)"
}

print("Level 7: black box ")
let recorder = FlightRecorder()
recorder.record("Teleporter online")
recorder.record("Crew transfer started")
print(auditTranscript(of: recorder))
recorder.seal()
recorder.record("This must be ignored")
print("Entries after sealing: \(recorder.entryCount), sealed: \(recorder.isSealed)")
print(recorder.transcript)
print(auditTranscript(of: recorder))


// MARK: Finale: Integrity Code
let D = AlarmLevel.level(forTotalMass: A).rawValue
let integrityCode = "\(A)-\(B)-\(C)-\(D)"
print("INTEGRITY CODE: \(integrityCode)")


// MARK: Bonus
print("Bonus ")
var survivor: TeleportPod?
do {
    let temp = TeleportPod(id: "TEMP", chargeLevel: 100)
    survivor = temp
    print("inside block: temp exists")
}
print("after block: pod still alive because `survivor` holds a second reference")
survivor = nil
print("after survivor = nil")

func describeRelation(_ a: TeleportPod, _ b: TeleportPod) -> String {
    if a === b { return "same pod (one object)" }
    if a.id == b.id && a.chargeLevel == b.chargeLevel { return "two pods with equal contents" }
    return "different pods"
}
let twin = TeleportPod(id: "P-2", chargeLevel: 55)
print(describeRelation(demoPod, podAlias))
print(describeRelation(demoPod, twin))


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. A struct gets a memberwise initializer automatically because every stored
    property is known and the type has no inheritance. A class doesn't: Swift
    can't safely guess how properties (and any superclass) should be set up, so
    I write init and make sure everything is initialized, including `occupant`.

 2. `mutating` makes `self` a variable (an inout) inside the method, so the
    method can change properties or even assign a whole new value to self, and
    the change is written back to the caller's value. A struct method otherwise
    sees a constant self. Classes don't need it: self is a reference, and
    changing the object it points to doesn't change the reference itself.

 3. struct + let: the entire value is frozen, so no property can change.
    class + let: only the reference is frozen (the name can't point to another
    object); the object's `var` properties can still be modified.

 4. A lazy property is computed on first access, after the object already
    exists, so its stored value changes from "not yet computed" to "computed";
    a `let` can't change after init, so it must be `var`. Behaviour changes
    when the initializer has side effects or depends on state at access time:
    fullDiagnostics prints "Running full scan..." only when first read, and it
    captures hull/oxygen values at that moment, not at creation.

 5. In FlightRecorder, `private` on entriesCopy() would block auditTranscript(of:),
    a free function outside the class body but in the same file. fileprivate lets
    that function call it without exposing it to the rest of the module.

 Bonus. deinit fires on `survivor = nil`, because that removes the last strong
    reference (reference counting reaches zero). It does NOT fire at the end of
    the do-block, since `survivor` still holds the pod. === can't be used on
    CrewSnapshot because structs are values with no identity to compare.
*/
