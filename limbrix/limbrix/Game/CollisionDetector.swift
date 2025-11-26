//
//  CollisionDetector.swift
//  limbrix
//
//  Protocol and implementation for collision detection between flakes and arm rectangles
//

import SwiftUI

// MARK: - Protocol (Interface Segregation Principle)
protocol CollisionDetectorProtocol {
    func checkCollision(flake: Flake, armRect: ArmRectangle) -> CGPoint? // Returns collision point if collision detected
    func getArmRectangles(
        leftShoulder: CGPoint?,
        leftWrist: CGPoint?,
        rightShoulder: CGPoint?,
        rightWrist: CGPoint?,
        geometrySize: CGSize
    ) -> [ArmRectangle]
}

// MARK: - Arm Rectangle Model
struct ArmRectangle {
    let type: ArmType
    let corners: [CGPoint] // [corner1, corner2, corner3, corner4]
}

// MARK: - Implementation (Single Responsibility Principle)
class CollisionDetector: CollisionDetectorProtocol {
    private let rectangleWidth: CGFloat = 40
    
    func checkCollision(flake: Flake, armRect: ArmRectangle) -> CGPoint? {
        // Check if flake's center is within the arm rectangle
        // Using point-in-polygon algorithm for the rectangle
        if isPointInPolygon(point: flake.position, polygon: armRect.corners) {
            // Return the flake's current position as the catch point
            // Flake sticks exactly where it was when collision was detected
            return flake.position
        }
        return nil
    }
    
    func getArmRectangles(
        leftShoulder: CGPoint?,
        leftWrist: CGPoint?,
        rightShoulder: CGPoint?,
        rightWrist: CGPoint?,
        geometrySize: CGSize
    ) -> [ArmRectangle] {
        var rectangles: [ArmRectangle] = []
        
        // Left arm rectangle
        if let leftShoulder = leftShoulder,
           let leftWrist = leftWrist {
            if let rect = createArmRectangle(
                from: leftShoulder,
                to: leftWrist,
                geometrySize: geometrySize,
                type: .left
            ) {
                rectangles.append(rect)
            }
        }
        
        // Right arm rectangle
        if let rightShoulder = rightShoulder,
           let rightWrist = rightWrist {
            if let rect = createArmRectangle(
                from: rightShoulder,
                to: rightWrist,
                geometrySize: geometrySize,
                type: .right
            ) {
                rectangles.append(rect)
            }
        }
        
        return rectangles
    }
    
    // MARK: - Private Helpers
    
    private func createArmRectangle(
        from shoulder: CGPoint,
        to wrist: CGPoint,
        geometrySize: CGSize,
        type: ArmType
    ) -> ArmRectangle? {
        let shoulderPoint = CGPoint(
            x: shoulder.x * geometrySize.width,
            y: shoulder.y * geometrySize.height
        )
        let wristPoint = CGPoint(
            x: wrist.x * geometrySize.width,
            y: wrist.y * geometrySize.height
        )
        
        // Calculate the vector from shoulder to wrist
        let dx = wristPoint.x - shoulderPoint.x
        let dy = wristPoint.y - shoulderPoint.y
        let length = sqrt(dx * dx + dy * dy)
        
        guard length > 0 else { return nil }
        
        // Calculate perpendicular vector for rectangle width
        let perpX = -dy / length * rectangleWidth
        let perpY = dx / length * rectangleWidth
        
        // Calculate rectangle corners (no special "top" edge - all edges can catch)
        let corner1 = CGPoint(
            x: shoulderPoint.x + perpX,
            y: shoulderPoint.y + perpY
        )
        let corner2 = CGPoint(
            x: shoulderPoint.x - perpX,
            y: shoulderPoint.y - perpY
        )
        let corner3 = CGPoint(
            x: wristPoint.x - perpX,
            y: wristPoint.y - perpY
        )
        let corner4 = CGPoint(
            x: wristPoint.x + perpX,
            y: wristPoint.y + perpY
        )
        
        return ArmRectangle(
            type: type,
            corners: [corner1, corner2, corner3, corner4]
        )
    }
    
    private func isPointInPolygon(point: CGPoint, polygon: [CGPoint]) -> Bool {
        guard polygon.count >= 3 else { return false }
        
        var inside = false
        var j = polygon.count - 1
        
        for i in 0..<polygon.count {
            let xi = polygon[i].x
            let yi = polygon[i].y
            let xj = polygon[j].x
            let yj = polygon[j].y
            
            let intersect = ((yi > point.y) != (yj > point.y)) &&
                           (point.x < (xj - xi) * (point.y - yi) / (yj - yi) + xi)
            
            if intersect {
                inside = !inside
            }
            
            j = i
        }
        
        return inside
    }
}

