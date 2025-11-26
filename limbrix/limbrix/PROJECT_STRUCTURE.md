# Project Structure

## Folder Organization

```
limbrix/
├── App/
│   └── limbrixApp.swift          # Main app entry point
│
├── Views/
│   ├── ContentView.swift          # Main view coordinator
│   ├── PoseOverlayView.swift      # Pose visualization overlay
│   ├── CameraPreviewView.swift    # Camera preview wrapper
│   └── FlakeView.swift            # Individual flake rendering
│
├── ViewModels/
│   ├── CameraViewModel.swift      # Camera session management
│   └── PoseEstimationViewModel.swift  # Pose detection logic
│
├── Game/
│   ├── FlakeSystem.swift          # Main game coordinator
│   ├── Flake.swift                # Flake model
│   ├── FlakeGenerator.swift       # Flake creation
│   ├── FlakePhysics.swift         # Physics engine
│   └── CollisionDetector.swift    # Collision detection
│
└── Resources/
    ├── Info.plist                 # App configuration
    └── Assets.xcassets/           # Images and assets
```

## Folder Descriptions

### App/
Contains the main application entry point and app-level configuration.

### Views/
All SwiftUI views that handle the user interface and visual rendering.

### ViewModels/
View models that manage business logic and state for the views.

### Game/
All game-related logic including flake system, physics, and collision detection.

### Resources/
Static resources like configuration files and asset catalogs.

