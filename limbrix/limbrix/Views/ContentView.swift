//
//  ContentView.swift
//  limbrix
//
//  Main view with camera preview and pose detection overlay
//

import SwiftUI
import AVFoundation
import Vision

struct ContentView: View {
    @State private var cameraViewModel = CameraViewModel()
    @State private var poseViewModel = PoseEstimationViewModel()
    @State private var flakeSystem: FlakeSystem?
    @State private var gameTimer: Timer?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                CameraPreviewView(session: cameraViewModel.session)
                    .edgesIgnoringSafeArea(.all)
                PoseOverlayView(
                    bodyParts: poseViewModel.detectedBodyParts,
                    connections: poseViewModel.bodyConnections,
                    flakeSystem: flakeSystem
                )
            }
            .task {
                await cameraViewModel.checkPermission()
                cameraViewModel.delegate = poseViewModel
            }
            .onAppear {
                // Allow landscape orientation for the game
                AppDelegate.orientationLock = [.landscapeLeft, .landscapeRight]
                
                // Initialize flake system if not already done
                if flakeSystem == nil {
                    flakeSystem = FlakeSystem()
                }
                
                // Start game loop
                startGameLoop(geometrySize: geometry.size)
            }
            .onDisappear {
                stopGameLoop()
            }
            .onChange(of: poseViewModel.detectedBodyParts) { _, newBodyParts in
                // Update arm positions in flake system
                updateArmPositions(bodyParts: newBodyParts)
            }
        }
    }
    
    // MARK: - Game Loop
    
    private func startGameLoop(geometrySize: CGSize) {
        let targetFPS: TimeInterval = 60.0
        let frameTime = 1.0 / targetFPS
        var lastUpdateTime = Date()
        
        // Capture current flakeSystem to avoid retaining self (struct)
        let capturedFlakeSystem = flakeSystem
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: frameTime, repeats: true) { _ in
            guard let flakeSystem = capturedFlakeSystem else { return }
            
            let currentTime = Date()
            let deltaTime = currentTime.timeIntervalSince(lastUpdateTime)
            lastUpdateTime = currentTime
            
            // Get current window size
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                let size = window.bounds.size
                flakeSystem.update(deltaTime: deltaTime, geometrySize: size)
            }
        }
    }
    
    private func stopGameLoop() {
        gameTimer?.invalidate()
        gameTimer = nil
    }
    
    private func updateArmPositions(bodyParts: [VNHumanBodyPoseObservation.JointName: CGPoint]) {
        guard let flakeSystem = flakeSystem else { return }
        
        flakeSystem.leftShoulder = bodyParts[.leftShoulder]
        flakeSystem.leftWrist = bodyParts[.leftWrist]
        flakeSystem.rightShoulder = bodyParts[.rightShoulder]
        flakeSystem.rightWrist = bodyParts[.rightWrist]
    }
}

#Preview {
    ContentView()
}
