//
//  PoseOverlayView.swift
//  limbrix
//
//  SwiftUI overlay for drawing detected body pose joints and connections
//

import SwiftUI
import Vision

struct PoseOverlayView: View {
    let bodyParts: [VNHumanBodyPoseObservation.JointName: CGPoint]
    let connections: [BodyConnection]
    let flakeSystem: FlakeSystem?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Draw flakes first (behind everything)
                if let flakeSystem = flakeSystem {
                    ForEach(flakeSystem.flakes) { flake in
                        FlakeView(flake: flake)
                    }
                }
                
                // Draw arm rectangles (behind connections)
                drawArmRectangles(geometry: geometry)
                
                // Draw skeleton connections
                ForEach(connections) { connection in
                    if let fromPoint = bodyParts[connection.from],
                       let toPoint = bodyParts[connection.to] {
                        Path { path in
                            let fromPointInView = CGPoint(
                                x: fromPoint.x * geometry.size.width,
                                y: fromPoint.y * geometry.size.height
                            )
                            let toPointInView = CGPoint(
                                x: toPoint.x * geometry.size.width,
                                y: toPoint.y * geometry.size.height
                            )
                            
                            path.move(to: fromPointInView)
                            path.addLine(to: toPointInView)
                        }
                        .stroke(Color.green, lineWidth: 3)
                    }
                }
                ForEach(Array(bodyParts.keys), id: \.self) { jointName in
                    if let point = bodyParts[jointName] {
                        let pointInView = CGPoint(
                            x: point.x * geometry.size.width,
                            y: point.y * geometry.size.height
                        )
                        
                        Circle()
                            .fill(.white)
                            .frame(width: 10, height: 10)
                            .position(pointInView)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 1)
                                    .frame(width: 12, height: 12)
                            )
                    }
                }
            }
        }
    }
    
    // Draw rectangles around arms (shoulder to wrist)
    @ViewBuilder
    private func drawArmRectangles(geometry: GeometryProxy) -> some View {
        Group {
            // Left arm rectangle
            if let leftShoulder = bodyParts[.leftShoulder],
               let leftWrist = bodyParts[.leftWrist] {
                armRectangle(
                    from: leftShoulder,
                    to: leftWrist,
                    geometry: geometry,
                    color: Color.blue.opacity(0.3)
                )
            }
            
            // Right arm rectangle
            if let rightShoulder = bodyParts[.rightShoulder],
               let rightWrist = bodyParts[.rightWrist] {
                armRectangle(
                    from: rightShoulder,
                    to: rightWrist,
                    geometry: geometry,
                    color: Color.blue.opacity(0.3)
                )
            }
        }
    }
    
    // Helper function to create a rectangle around an arm segment
    @ViewBuilder
    private func armRectangle(
        from shoulder: CGPoint,
        to wrist: CGPoint,
        geometry: GeometryProxy,
        color: Color
    ) -> some View {
        let shoulderPoint = CGPoint(
            x: shoulder.x * geometry.size.width,
            y: shoulder.y * geometry.size.height
        )
        let wristPoint = CGPoint(
            x: wrist.x * geometry.size.width,
            y: wrist.y * geometry.size.height
        )
        
        // Calculate the vector from shoulder to wrist
        let dx = wristPoint.x - shoulderPoint.x
        let dy = wristPoint.y - shoulderPoint.y
        let length = sqrt(dx * dx + dy * dy)
        
        // Calculate perpendicular vector for rectangle width
        // Perpendicular to the arm direction
        let width: CGFloat = 40 // Rectangle width (adjust as needed)
        let perpX = -dy / length * width
        let perpY = dx / length * width
        
        // Calculate rectangle corners
        let topLeft = CGPoint(
            x: shoulderPoint.x + perpX,
            y: shoulderPoint.y + perpY
        )
        let topRight = CGPoint(
            x: shoulderPoint.x - perpX,
            y: shoulderPoint.y - perpY
        )
        let bottomLeft = CGPoint(
            x: wristPoint.x + perpX,
            y: wristPoint.y + perpY
        )
        let bottomRight = CGPoint(
            x: wristPoint.x - perpX,
            y: wristPoint.y - perpY
        )
        
        Path { path in
            path.move(to: topLeft)
            path.addLine(to: topRight)
            path.addLine(to: bottomRight)
            path.addLine(to: bottomLeft)
            path.closeSubpath()
        }
        .fill(color)
        .overlay(
            Path { path in
                path.move(to: topLeft)
                path.addLine(to: topRight)
                path.addLine(to: bottomRight)
                path.addLine(to: bottomLeft)
                path.closeSubpath()
            }
            .stroke(Color.blue, lineWidth: 2)
        )
    }
}
