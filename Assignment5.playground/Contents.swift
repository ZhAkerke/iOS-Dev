// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Drone records recovered from the fleet registry.
/// One `kind` does not correspond to any drone type you will build.
let fleetData: [(kind: String, id: String, charge: Int)] = [
    (kind: "welder",  id: "W-1", charge: 80),
    (kind: "scanner", id: "S-1", charge: 45),
    (kind: "cargo",   id: "C-1", charge: 100),
    (kind: "welder",  id: "W-2", charge: 15),
    (kind: "scanner", id: "S-2", charge: 60),
    (kind: "tug",     id: "T-1", charge: 50)
]

/// Hull sensors. These are NOT drones — they never move and never work a shift.
let sensorData: [(id: String, charge: Int)] = [
    (id: "hull-cam", charge: 12),
    (id: "thermal",  charge: 77)
]

/// Hardware from the original station. You may not add anything to this
/// declaration — no methods, no protocols, no properties.
struct LegacyBeacon {
    let name: String
    let signalStrength: Int
}

let beacon = LegacyBeacon(name: "ALMA-BEACON", signalStrength: 8)

print("Fleet registry online: \(fleetData.count) drone records, \(sensorData.count) sensors, beacon \(beacon.name).")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================

// MARK: Level 1 · The Power Cell
final class PowerCell {
    private var charge: Int

    init(charge: Int) {
        self.charge = Swift.min(Swift.max(charge, 0), 100)   // clamp into 0...100
    }

    func level() -> Int { charge }

    func spend(_ amount: Int) -> Bool {
        guard amount > 0, amount <= charge else { return false }
        charge -= amount
        return true
    }

    func recharge(by amount: Int) {
        guard amount > 0 else { return }
        charge = Swift.min(charge + amount, 100)
    }
}

// Encapsulation proof
// let cell = PowerCell(charge: 50)
// cell.charge = 100
// error: 'charge' is inaccessible due to 'private' protection level


// MARK: Level 2 · The Fleet
// 2.1
class Drone {
    let id: String
    let cell: PowerCell

    init(id: String, cell: PowerCell) {
        self.id = id
        self.cell = cell
    }

    var powerCost: Int { 10 }

    var statusLine: String {
        "\(id): \(cell.level())% \(cell.level().powerBar)"
    }

    func performTask() -> Int { 0 }
    var canRunAnotherTask: Bool { cell.level() >= powerCost }

    final func runOnce() -> Int {
        guard cell.spend(powerCost) else { return 0 }
        return performTask()
    }
}

// 2.2
final class WelderDrone: Drone {
    override var powerCost: Int { 25 }
    override func performTask() -> Int { 40 }
    func weldSeam() -> String { "\(id) welded a seam" }
}

class ScannerDrone: Drone {
    override var powerCost: Int { 10 }
    override func performTask() -> Int { 15 }
    override var statusLine: String { super.statusLine + " [scanner]" }
}

final class CargoDrone: Drone {
    override var powerCost: Int { 20 }
    override func performTask() -> Int { 25 }
}

// 2.3
func makeDrone(kind: String, id: String, charge: Int) -> Drone? {
    let cell = PowerCell(charge: charge)
    switch kind {
    case "welder":  return WelderDrone(id: id, cell: cell)
    case "scanner": return ScannerDrone(id: id, cell: cell)
    case "cargo":   return CargoDrone(id: id, cell: cell)
    default:        return nil
    }
}

var fleet: [Drone] = []
for record in fleetData {
    if let drone = makeDrone(kind: record.kind, id: record.id, charge: record.charge) {
        fleet.append(drone)
    } else {
        print("WARNING: skipped record \(record.id) - unknown kind \"\(record.kind)\"")
    }
}


// MARK: Level 3 · The Shift

func runShift(_ fleet: [Drone], rounds: Int) -> Int {
    var total = 0
    for _ in 0..<Swift.max(rounds, 0) {
        for drone in fleet {
            total += drone.runOnce()
        }
    }
    return total
}

let A = runShift(fleet, rounds: 3)

print("After the shift ")
for drone in fleet {
    print(drone.statusLine)
}

var B = 0
var C = 0
for drone in fleet {
    B += drone.cell.level()
    if drone.canRunAnotherTask { C += 1 }
}
print("Drones with enough charge for one more task: \(C)")


// MARK: Level 4 · Diagnostics
// 4.1
protocol Diagnosable {
    var componentID: String { get }
    var statusCode: Int { get }
    func diagnose() -> String
}

// 4.2
protocol Rechargeable {
    mutating func recharge(by amount: Int)
}

extension Drone: Diagnosable, Rechargeable {
    var componentID: String { id }
    var statusCode: Int { healthCode(for: cell.level()) }    // uses the single Health Rule helper
    func recharge(by amount: Int) { cell.recharge(by: amount) }
}

struct SensorModule: Diagnosable, Rechargeable {
    let id: String
    var chargeLevel: Int

    var componentID: String { id }
    var statusCode: Int { healthCode(for: chargeLevel) }

    mutating func recharge(by amount: Int) {
        guard amount > 0 else { return }
        chargeLevel = Swift.min(chargeLevel + amount, 100)
    }
}

var sensors: [SensorModule] = []
for data in sensorData {
    sensors.append(SensorModule(id: data.id, chargeLevel: data.charge))
}

// 4.3
func diagnosticsReport(_ components: [Diagnosable]) -> String {
    var report = ""
    for component in components {
        report += component.diagnose() + "\n"
    }
    return report
}

var components: [Diagnosable] = []
for drone in fleet { components.append(drone) }
for sensor in sensors { components.append(sensor) }

print("Diagnostics (drones + sensors) ")
print(diagnosticsReport(components))


// MARK: Level 5 · Shared Behaviour
// 5.1
extension Diagnosable {
    func diagnose() -> String {
        "\(componentID): code \(statusCode)"
    }

    func healthCode(for level: Int) -> Int {
        if level < 20 { return 2 }      // critical
        if level < 50 { return 1 }      // warning
        return 0                        // nominal
    }
}

// 5.2
extension LegacyBeacon: Diagnosable {
    var componentID: String { name }
    var statusCode: Int { healthCode(for: signalStrength) }

    func diagnose() -> String {
        "[LEGACY] \(componentID): code \(statusCode)"
    }
}

components.append(beacon)

print("Diagnostics (with legacy beacon) ")
print(diagnosticsReport(components))

var D = 0
for component in components {
    D += component.statusCode
}

// 5.3
extension Int {
    var powerBar: String {                // 42 -> "####......"
        let filled = Swift.min(Swift.max(self / 10, 0), 10)
        return String(repeating: "#", count: filled) + String(repeating: ".", count: 10 - filled)
    }
}


// MARK: Level 6 · Incident Reports
/*
// Report 1
class PatchDrone: Drone {
    func performTask() -> Int {
        return 30
    }
}

// Report 2
final class HeavyWelder: WelderDrone {
    override func runOnce() -> Int {
        return 999
    }
}

// Report 3
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
print(first.weldSeam())

// Report 4
protocol Labelled {
    var componentID: String { get }
}

extension Labelled {
    func label() -> String { "generic component" }
}

struct Thruster: Labelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}

let parts: [Labelled] = [Thruster(componentID: "T-1")]
print(parts[0].label())
*/

// Report 1 (does NOT compile)
//   Expected: PatchDrone produces 30 work units instead of 0.
//   Actual:   error: overriding declaration requires an 'override' keyword
//   Rule:     a subclass must write `override` when it replaces a superclass member.
//   Fix:      override func performTask() -> Int { 30 }

// Report 2 (does NOT compile)
//   Expected: HeavyWelder returns 999 every time it runs.
//   Actual:   error: inheritance from a final class 'WelderDrone'
//             error: instance method overrides a 'final' instance method
//   Rule:     `final` on a class forbids subclassing; `final` on a method forbids overriding.
//   Fix:      remove `final` from WelderDrone and override performTask(), not runOnce().

// Report 3 (does NOT compile)
//   Expected: calling weldSeam() on the welder stored in the array.
//   Actual:   error: value of type 'Drone' has no member 'weldSeam'
//   Rule:     the compiler checks calls against the declared type of the variable (Drone),
//             not the runtime type of the object inside it.
//   Fix:      a conditional cast (below). as? returns an optional because the cast can fail
//             at runtime (the element might not be a WelderDrone), so Swift gives nil instead of crashing.
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
if let welder = first as? WelderDrone {
    print(welder.weldSeam())
}

// Report 4 (compiles, but LIES)
//   Expected: "thruster T-1".
//   Actual:   prints "generic component".
//   Rule:     label() is not a requirement of the protocol, only a method in an extension.
//             Calls on a protocol-typed value to non-requirements are bound statically,
//             so the extension's version is used.
//   Fix:      declare `func label() -> String` inside the protocol so it becomes a requirement.
protocol FixedLabelled {
    var componentID: String { get }
    func label() -> String                      
}
extension FixedLabelled {
    func label() -> String { "generic component" }
}
struct FixedThruster: FixedLabelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}
let fixedParts: [FixedLabelled] = [FixedThruster(componentID: "T-1")]
print(fixedParts[0].label())


// MARK: Finale: Mission Code
let missionCode = "\(A)-\(B)-\(C)-\(D)"
print("MISSION CODE: \(missionCode)")

// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why does a class satisfy a `mutating` protocol requirement without the
    keyword, while a struct must write it?
    A class is a reference type: its methods change the object that `self` points to, never the
    reference itself, so no `mutating` is needed. A struct is a value type: a method that changes
    its properties replaces `self`, so it must be marked `mutating`, and it can only be called on a `var`.

 2. One thing inheritance does that protocols cannot, and one thing
    protocols do that inheritance cannot:
    Inheritance shares stored properties and implementation (Drone provides id, cell and runOnce()
    to all subclasses). Protocols can unite unrelated types, including structs and types we
    cannot edit (SensorModule and LegacyBeacon), in one array; a struct cannot inherit from a class.

 3. What does `final` prevent, and what did it protect in runOnce()?
    `final` prevents subclassing (on a class) or overriding (on a method). On runOnce() it protects
    the "spend power, then work" ritual: no subclass can skip the cost or change the order of steps
    (Report 2 tried to return 999 for free).

 4. In Report 4, why did the protocol extension's method win?
    label() was not declared in the protocol, so it is not a customization point. Swift picks
    the implementation from the static type of the variable (Labelled), which is the extension's.
    Declaring label() inside the protocol makes it a requirement, so the struct's own version is used.
*/
