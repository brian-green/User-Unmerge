import Foundation

struct PhysicsCategory {
    static let none:        UInt32 = 0
    static let player:      UInt32 = 0b1          // 1
    static let ground:      UInt32 = 0b10         // 2
    static let enemy:       UInt32 = 0b100        // 4
    static let collectible: UInt32 = 0b1000       // 8
    static let powerUp:     UInt32 = 0b10000      // 16
    static let projectile:  UInt32 = 0b100000     // 32
    static let water:       UInt32 = 0b1000000    // 64
    static let boundary:    UInt32 = 0b10000000   // 128
    static let npc:         UInt32 = 0b100000000  // 256
    static let platform:    UInt32 = 0b1000000000 // 512
    static let boss:        UInt32 = 0b10000000000 // 1024
}
