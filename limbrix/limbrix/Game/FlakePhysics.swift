//
//  FlakePhysics.swift
//  limbrix
//
//  Protocol and implementation for flake physics following SOLID principles
//

import SwiftUI

// MARK: - Protocol (Interface Segregation Principle)
protocol FlakePhysicsProtocol {
    func updatePosition(_ flake: inout Flake, deltaTime: TimeInterval, bounds: CGRect)
    func applyGravity(to flake: inout Flake, gravity: CGFloat, deltaTime: TimeInterval)
}

// MARK: - Implementation (Single Responsibility Principle)
class FlakePhysics: FlakePhysicsProtocol {
    private let gravityConstant: CGFloat = 50.0 // Pixels per second squared
    private let terminalVelocity: CGFloat = 100.0 // Maximum falling speed
    
    func updatePosition(_ flake: inout Flake, deltaTime: TimeInterval, bounds: CGRect) {
        guard !flake.isCaught else { return }
        
        // Apply gravity first (horizontal in landscape mode)
        applyGravity(to: &flake, gravity: gravityConstant, deltaTime: deltaTime)
        
        // Update position based on velocity
        flake.position.x += flake.velocity.dx * CGFloat(deltaTime)
        flake.position.y += flake.velocity.dy * CGFloat(deltaTime)
        
        // Clamp to bounds (vertical bounds only, horizontal can go beyond right edge)
        flake.position.y = max(0, min(bounds.height, flake.position.y))
    }
    
    func applyGravity(to flake: inout Flake, gravity: CGFloat, deltaTime: TimeInterval) {
        guard !flake.isCaught else { return }
        
        // In landscape mode, gravity applies horizontally (to the right)
        // Increase horizontal velocity due to gravity
        flake.velocity.dx += gravity * CGFloat(deltaTime)
        
        // Cap at terminal velocity
        flake.velocity.dx = min(flake.velocity.dx, terminalVelocity)
    }
}

