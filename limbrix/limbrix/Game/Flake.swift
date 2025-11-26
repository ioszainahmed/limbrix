//
//  Flake.swift
//  limbrix
//
//  Model representing a falling flake
//

import SwiftUI

struct Flake: Identifiable {
    let id: UUID
    var position: CGPoint
    var color: Color
    var size: CGFloat
    var velocity: CGVector
    var isCaught: Bool
    var caughtByArm: ArmType?
    var catchPosition: CGPoint? // Position where flake was caught (sticks here)
    
    init(
        id: UUID = UUID(),
        position: CGPoint,
        color: Color,
        size: CGFloat = 20,
        velocity: CGVector = CGVector(dx: 0, dy: 1),
        isCaught: Bool = false,
        caughtByArm: ArmType? = nil,
        catchPosition: CGPoint? = nil
    ) {
        self.id = id
        self.position = position
        self.color = color
        self.size = size
        self.velocity = velocity
        self.isCaught = isCaught
        self.caughtByArm = caughtByArm
        self.catchPosition = catchPosition
    }
}

enum ArmType {
    case left
    case right
}

