//
//  FlakeSystem.swift
//  limbrix
//
//  Main coordinator for flake system following SOLID principles
//  Uses Dependency Inversion Principle - depends on abstractions (protocols)
//

import SwiftUI

// MARK: - Flake System (Dependency Inversion Principle)
@Observable
class FlakeSystem {
    // Dependencies injected via protocols (Dependency Inversion)
    private let physics: FlakePhysicsProtocol
    private let collisionDetector: CollisionDetectorProtocol
    private let generator: FlakeGeneratorProtocol
    
    // State
    var flakes: [Flake] = []
    private var lastSpawnTime: Date = Date()
    
    // Configuration
    private let spawnInterval: TimeInterval = 1.5 // Spawn a flake every 1.5 seconds
    
    // Arm positions (updated from outside)
    var leftShoulder: CGPoint?
    var leftWrist: CGPoint?
    var rightShoulder: CGPoint?
    var rightWrist: CGPoint?
    
    init(
        physics: FlakePhysicsProtocol = FlakePhysics(),
        collisionDetector: CollisionDetectorProtocol = CollisionDetector(),
        generator: FlakeGeneratorProtocol = FlakeGenerator()
    ) {
        self.physics = physics
        self.collisionDetector = collisionDetector
        self.generator = generator
    }
    
    // MARK: - Public Methods
    
    func update(deltaTime: TimeInterval, geometrySize: CGSize) {
        // Spawn new flakes
        spawnFlakesIfNeeded(geometrySize: geometrySize)
        
        // Update existing flakes
        updateFlakes(deltaTime: deltaTime, geometrySize: geometrySize)
        
        // Remove flakes that fell off screen
        removeOffScreenFlakes(geometrySize: geometrySize)
    }
    
    // MARK: - Private Methods
    
    private func spawnFlakesIfNeeded(geometrySize: CGSize) {
        let now = Date()
        if now.timeIntervalSince(lastSpawnTime) >= spawnInterval {
            // In landscape mode, flakes spawn at random Y positions on the left side
            let randomY = CGFloat.random(in: 0...geometrySize.height)
            let bounds = CGRect(origin: .zero, size: geometrySize)
            let newFlake = generator.generateFlake(at: randomY, bounds: bounds)
            flakes.append(newFlake)
            lastSpawnTime = now
        }
    }
    
    private func updateFlakes(deltaTime: TimeInterval, geometrySize: CGSize) {
        // Get arm rectangles for collision detection
        let armRectangles = collisionDetector.getArmRectangles(
            leftShoulder: leftShoulder,
            leftWrist: leftWrist,
            rightShoulder: rightShoulder,
            rightWrist: rightWrist,
            geometrySize: geometrySize
        )
        
        for index in flakes.indices {
            var flake = flakes[index]
            
            // Check collision with arm rectangles
            if !flake.isCaught {
                for armRect in armRectangles {
                    if let catchPoint = collisionDetector.checkCollision(flake: flake, armRect: armRect) {
                        // Flake is caught - stick it at the collision point
                        flake.isCaught = true
                        flake.caughtByArm = armRect.type
                        flake.catchPosition = catchPoint
                        flake.position = catchPoint // Stick at collision point
                        flake.velocity = CGVector(dx: 0, dy: 0) // Stop falling
                        flakes[index] = flake
                        break
                    }
                }
            }
            
            // Update physics for non-caught flakes
            if !flake.isCaught {
                let bounds = CGRect(origin: .zero, size: geometrySize)
                physics.updatePosition(&flakes[index], deltaTime: deltaTime, bounds: bounds)
            } else if let catchPosition = flake.catchPosition {
                // Keep caught flakes at their catch position (they stick where touched)
                flakes[index].position = catchPosition
            }
        }
    }
    
    private func removeOffScreenFlakes(geometrySize: CGSize) {
        flakes.removeAll { flake in
            // In landscape mode, remove if beyond right edge of screen and not caught
            if !flake.isCaught && flake.position.x > geometrySize.width + 100 {
                return true
            }
            return false
        }
    }
}
