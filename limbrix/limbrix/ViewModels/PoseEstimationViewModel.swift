//
//  PoseEstimationViewModel.swift
//  limbrix
//
//  Pose estimation using Vision framework
//

import SwiftUI
import Vision
import AVFoundation
import Observation

struct BodyConnection: Identifiable {
    let id = UUID()
    let from: VNHumanBodyPoseObservation.JointName
    let to: VNHumanBodyPoseObservation.JointName
}

@Observable
class PoseEstimationViewModel: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var detectedBodyParts: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
    var bodyConnections: [BodyConnection] = []
    
    override init() {
        super.init()
        setupBodyConnections()
    }
    
    private func setupBodyConnections() {
        bodyConnections = [
            BodyConnection(from: .nose, to: .neck),
            BodyConnection(from: .neck, to: .rightShoulder),
            BodyConnection(from: .neck, to: .leftShoulder),
            BodyConnection(from: .rightShoulder, to: .rightHip),
            BodyConnection(from: .leftShoulder, to: .leftHip),
            BodyConnection(from: .rightHip, to: .leftHip),
            BodyConnection(from: .rightShoulder, to: .rightElbow),
            BodyConnection(from: .rightElbow, to: .rightWrist),
            BodyConnection(from: .leftShoulder, to: .leftElbow),
            BodyConnection(from: .leftElbow, to: .leftWrist),
            BodyConnection(from: .rightHip, to: .rightKnee),
            BodyConnection(from: .rightKnee, to: .rightAnkle),
            BodyConnection(from: .leftHip, to: .leftKnee),
            BodyConnection(from: .leftKnee, to: .leftAnkle)
        ]
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        Task {
            if let detectedPoints = await processFrame(sampleBuffer) {
                await MainActor.run {
                    self.detectedBodyParts = detectedPoints
                }
            }
        }
    }
    
    private func processFrame(_ sampleBuffer: CMSampleBuffer) async -> [VNHumanBodyPoseObservation.JointName: CGPoint]? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        
        let request = VNDetectHumanBodyPoseRequest()
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform pose detection: \(error.localizedDescription)")
            return nil
        }
        
        guard let observation = request.results?.first as? VNHumanBodyPoseObservation else {
            return nil
        }
        
        return extractPoints(from: observation)
    }
    
    private func extractPoints(from observation: VNHumanBodyPoseObservation) -> [VNHumanBodyPoseObservation.JointName: CGPoint] {
        var points: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
        
        for connection in bodyConnections {
            // Extract from point
            if let fromPoint = try? observation.recognizedPoint(connection.from),
               fromPoint.confidence > 0.3 {
                points[connection.from] = CGPoint(x: fromPoint.location.x, y: 1 - fromPoint.location.y)
            }
            
            // Extract to point
            if let toPoint = try? observation.recognizedPoint(connection.to),
               toPoint.confidence > 0.3 {
                points[connection.to] = CGPoint(x: toPoint.location.x, y: 1 - toPoint.location.y)
            }
        }
        
        return points
    }
}


