//
//  FlakeGenerator.swift
//  limbrix
//
//  Protocol and implementation for generating flakes following SOLID principles
//

import SwiftUI

// MARK: - Protocol (Interface Segregation Principle)
protocol FlakeGeneratorProtocol {
    func generateFlake(at xPosition: CGFloat, bounds: CGRect) -> Flake
    func getRandomColor() -> Color
}

// MARK: - Implementation (Single Responsibility Principle)
class FlakeGenerator: FlakeGeneratorProtocol {
    private let flakeSize: CGFloat = 20
    private let fallSpeed: CGFloat = 30.0 // Slow speed as requested
    
    private let colors: [Color] = [
        .red, .blue, .green, .yellow, .orange, .purple, .pink, .cyan, .mint
    ]
    
    func generateFlake(at xPosition: CGFloat, bounds: CGRect) -> Flake {
        let color = getRandomColor()
        
        // In landscape mode, flakes fall from left to right
        // xPosition is actually the y position (vertical position on left side)
        return Flake(
            position: CGPoint(x: -flakeSize, y: xPosition), // Start at left side
            color: color,
            size: flakeSize,
            velocity: CGVector(dx: fallSpeed, dy: 0) // Fall horizontally to the right
        )
    }
    
    func getRandomColor() -> Color {
        colors.randomElement() ?? .blue
    }
}

