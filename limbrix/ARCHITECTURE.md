# Limbrix App Architecture

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         ContentView                              │
│  (Main SwiftUI View - Coordinates everything)                   │
└────────────┬────────────────────────────────────────────────────┘
             │
             ├─────────────────────────────────────────────────────┐
             │                                                      │
             ▼                                                      ▼
┌────────────────────────┐                    ┌─────────────────────────────┐
│   CameraViewModel      │                    │  PoseEstimationViewModel    │
│  - Camera Session      │                    │  - Vision Framework         │
│  - Permissions        │                    │  - Body Pose Detection      │
│  - Video Output       │───────────────────▶ │  - Joint Extraction         │
└────────────────────────┘   Delegate         └───────────┬─────────────────┘
                                                           │
                                                           ▼
                                          ┌─────────────────────────────────┐
                                          │   Detected Body Parts           │
                                          │   [JointName: CGPoint]          │
                                          └─────────────────────────────────┘
             │
             │
             ▼
┌─────────────────────────────────────────────────────────────────┐
│                      PoseOverlayView                            │
│  - Renders skeleton joints and connections                      │
│  - Draws arm rectangles                                         │
│  - Displays flakes                                               │
└────────────┬────────────────────────────────────────────────────┘
             │
             │
             ▼
┌─────────────────────────────────────────────────────────────────┐
│                        FlakeSystem                              │
│  (Main Coordinator - @Observable)                                │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Dependencies (Dependency Inversion Principle)          │  │
│  │  - FlakePhysicsProtocol                                   │  │
│  │  - CollisionDetectorProtocol                              │  │
│  │  - FlakeGeneratorProtocol                                 │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  State:                                                          │
│  - flakes: [Flake]                                               │
│  - leftShoulder, leftWrist, rightShoulder, rightWrist          │
│                                                                  │
│  Methods:                                                        │
│  - update(deltaTime, geometrySize)                              │
│  - spawnFlakesIfNeeded()                                         │
│  - updateFlakes()                                                 │
│  - removeOffScreenFlakes()                                       │
└──────────────────────────────────────────────────────────────────┘
             │
             │ Uses
             │
             ├─────────────────────────────────────────────────────┐
             │                                                     │
             ▼                                                     ▼
┌────────────────────────┐                    ┌─────────────────────────────┐
│   FlakePhysics         │                    │  CollisionDetector          │
│  (Physics Engine)      │                    │  (Collision Detection)      │
│                        │                    │                             │
│  - updatePosition()    │                    │  - checkCollision()          │
│  - applyGravity()      │                    │  - getArmRectangles()       │
│                        │                    │  - createArmRectangle()     │
│  Gravity: Horizontal  │                    │  - isPointInPolygon()       │
│  (Right direction)     │                    │                             │
└────────────────────────┘                    └─────────────────────────────┘
             │
             │
             ▼
┌────────────────────────┐
│   FlakeGenerator       │
│  (Flake Creation)      │
│                        │
│  - generateFlake()     │
│  - getRandomColor()    │
│                        │
│  Spawns from: Left     │
│  Falls: Right          │
└────────────────────────┘
```

## Component Details

### 1. **ContentView** (Main Coordinator)
- **Responsibility**: Main view coordinator
- **Manages**:
  - CameraViewModel
  - PoseEstimationViewModel
  - FlakeSystem
  - Game loop timer (60 FPS)
- **Updates**: Arm positions to FlakeSystem

### 2. **CameraViewModel**
- **Responsibility**: Camera session management
- **Features**:
  - Permission handling
  - AVCaptureSession setup
  - Video frame output
- **Output**: Sends frames to PoseEstimationViewModel via delegate

### 3. **PoseEstimationViewModel**
- **Responsibility**: Body pose detection
- **Uses**: Vision framework (VNDetectHumanBodyPoseRequest)
- **Output**: Detected body parts dictionary
- **Connections**: Defines skeleton connections

### 4. **PoseOverlayView**
- **Responsibility**: Visual rendering
- **Renders**:
  - Skeleton joints (white circles)
  - Skeleton connections (green lines)
  - Arm rectangles (blue semi-transparent)
  - Flakes (colored squares)

### 5. **FlakeSystem** (Core Game Logic)
- **Responsibility**: Flake lifecycle management
- **SOLID Principles**:
  - **Single Responsibility**: Manages flake state and updates
  - **Dependency Inversion**: Depends on protocols, not concrete classes
- **State Management**: @Observable for SwiftUI reactivity
- **Game Loop**: Updates at 60 FPS

### 6. **Flake Model**
```swift
struct Flake {
    let id: UUID
    var position: CGPoint
    var color: Color
    var size: CGFloat
    var velocity: CGVector
    var isCaught: Bool
    var caughtByArm: ArmType?
    var catchPosition: CGPoint?  // Where it stuck
}
```

### 7. **FlakePhysics**
- **Responsibility**: Physics calculations
- **Protocol**: FlakePhysicsProtocol
- **Features**:
  - Horizontal gravity (landscape mode)
  - Terminal velocity
  - Position updates

### 8. **CollisionDetector**
- **Responsibility**: Collision detection
- **Protocol**: CollisionDetectorProtocol
- **Features**:
  - Point-in-polygon detection
  - Arm rectangle creation
  - Returns collision point (not just boolean)

### 9. **FlakeGenerator**
- **Responsibility**: Flake creation
- **Protocol**: FlakeGeneratorProtocol
- **Features**:
  - Random color selection
  - Spawns from left side
  - Configurable size and speed

## Data Flow

```
Camera Frame
    │
    ▼
PoseEstimationViewModel
    │
    ▼
Detected Body Parts [JointName: CGPoint]
    │
    ├─────────────────▶ PoseOverlayView (Rendering)
    │
    └─────────────────▶ FlakeSystem (Arm Positions)
                            │
                            ├──▶ CollisionDetector (Check collisions)
                            │
                            ├──▶ FlakePhysics (Update positions)
                            │
                            └──▶ FlakeGenerator (Spawn new flakes)
```

## SOLID Principles Implementation

### Single Responsibility Principle ✅
- Each class has one clear responsibility:
  - `FlakePhysics`: Only physics calculations
  - `CollisionDetector`: Only collision detection
  - `FlakeGenerator`: Only flake creation
  - `FlakeSystem`: Only coordination

### Open/Closed Principle ✅
- Protocols allow extension without modification
- New physics engines can be added by implementing `FlakePhysicsProtocol`
- New generators can be added by implementing `FlakeGeneratorProtocol`

### Liskov Substitution Principle ✅
- Any implementation of a protocol can be substituted
- `FlakePhysics`, `CollisionDetector`, `FlakeGenerator` are interchangeable

### Interface Segregation Principle ✅
- Small, focused protocols:
  - `FlakePhysicsProtocol`: Only physics methods
  - `CollisionDetectorProtocol`: Only collision methods
  - `FlakeGeneratorProtocol`: Only generation methods

### Dependency Inversion Principle ✅
- `FlakeSystem` depends on protocol abstractions
- Dependencies injected via initializer
- Easy to test with mock implementations

## Game Flow

```
1. App Starts
   │
   ├─▶ Request Camera Permissions
   ├─▶ Initialize Camera Session
   ├─▶ Initialize FlakeSystem
   └─▶ Start Game Loop (60 FPS)
   
2. Game Loop (Every Frame)
   │
   ├─▶ Camera captures frame
   │   └─▶ PoseEstimationViewModel processes frame
   │       └─▶ Updates detectedBodyParts
   │
   ├─▶ FlakeSystem.update()
   │   ├─▶ Spawn new flakes (every 1.5s)
   │   ├─▶ Update flake physics
   │   ├─▶ Check collisions with arm rectangles
   │   ├─▶ Stick caught flakes at collision point
   │   └─▶ Remove off-screen flakes
   │
   └─▶ PoseOverlayView renders
       ├─▶ Skeleton
       ├─▶ Arm rectangles
       └─▶ Flakes
```

## Key Features

### Landscape Mode
- Flakes fall horizontally (left to right)
- Gravity applies horizontally
- Arm rectangles catch flakes from any edge

### Flake Behavior
- **Spawn**: Random Y position on left side
- **Fall**: Horizontal with gravity acceleration
- **Catch**: Sticks at exact collision point
- **Colors**: 9 different colors (random)
- **Size**: 20x20 points

### Arm Rectangle
- **Shape**: Rectangle from shoulder to wrist
- **Width**: 40 points
- **Catching**: Any part of rectangle can catch flakes
- **Sticking**: Flakes stick where they touch

## File Structure

```
limbrix/
├── ContentView.swift              # Main view
├── CameraViewModel.swift          # Camera management
├── PoseEstimationViewModel.swift  # Pose detection
├── PoseOverlayView.swift          # Visual rendering
│
├── FlakeSystem.swift              # Game coordinator
├── Flake.swift                    # Flake model
├── FlakePhysics.swift             # Physics engine
├── CollisionDetector.swift        # Collision detection
├── FlakeGenerator.swift           # Flake creation
└── FlakeView.swift                # Flake rendering
```

## Configuration

- **Spawn Rate**: 1.5 seconds per flake
- **Game Loop**: 60 FPS
- **Flake Size**: 20x20 points
- **Fall Speed**: 30 pixels/second (initial)
- **Gravity**: 50 pixels/second²
- **Terminal Velocity**: 100 pixels/second
- **Arm Rectangle Width**: 40 points
- **Orientation**: Landscape (left/right)

