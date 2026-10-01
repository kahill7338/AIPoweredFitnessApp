# Anatomy Fitness

Anatomy Fitness is an iOS fitness application that combines interactive 3D anatomy, workout planning, nutrition tracking, and an AI coaching interface. Built with Swift, SwiftUI, and SceneKit.

## Features

### Interactive 3D Anatomy
- Explore a detailed 3D anatomical model.
- Rotate and zoom the model using touch gestures.
- Select muscle regions using SceneKit hit testing.
- View muscle-specific descriptions, exercises, and recovery information.
- Ask the AI Coach about the selected muscle group.

### Workout Planning
- Create and organize a weekly workout schedule.
- Plan workouts for individual training days.
- View upcoming workouts from the main dashboard.

### Nutrition Tracking
- Set a daily calorie goal.
- Track protein, carbohydrates, and fat targets.
- View calorie and macronutrient information from a dedicated nutrition dashboard.

### AI Coach
- Conversational interface for fitness, workout, muscle, and nutrition questions.
- Receives context from selected muscle groups within the 3D anatomy interface.
- Currently uses local predefined responses as a prototype.
- Designed for future integration with a live AI service.

### Profile & Customization
- Customize the application's accent colour.
- Configure fitness goals and training preferences.
- Store personalized calorie and training settings.

## Technologies

- Swift
- SwiftUI
- SceneKit
- Xcode
- iOS
- USDZ 3D Models
- Git / GitHub

## Technical Highlights

The interactive anatomy system integrates a USDZ anatomical model into SwiftUI using SceneKit and `SCNView`.

SceneKit hit testing allows the application to determine which part of the 3D model a user selects. Individual model objects are mapped to muscle groups, allowing the app to display contextual exercise, anatomy, and recovery information.

The application also implements custom camera movement, model rotation, pinch-to-zoom interaction, SwiftUI navigation, persistent user preferences, and contextual communication between the anatomy interface and AI Coach.

## Project Structure

`ContentView.swift`  
Main application interface and interactive SceneKit anatomy system.

`AIChatSheet.swift`  
AI Coach interface and local prototype response system.

`CaloriesView.swift`  
Calorie and macronutrient tracking interface.

`WorkoutsView.swift`  
Weekly workout planning interface.

`ProfileView.swift`  
User fitness preferences and application customization.

`AppTheme.swift`  
Shared application theme configuration.

`Male_Full_Body_Ecorche.usdz`  
3D anatomical model used by the SceneKit anatomy interface.

## Running the Project

1. Clone the repository.
2. Open the project in Xcode.
3. Select an iOS Simulator or compatible iOS device.
4. Build and run the application.

## Future Development

- Live AI service integration
- Expanded anatomical muscle selection
- Workout history and progress tracking
- Nutrition history
- Additional food logging functionality
- Expanded exercise database

## 3D Model Attribution

The anatomical model used in this project is **"Male Full Body Ecorche" by Diego Luján García**, sourced from Sketchfab and used under a Creative Commons Attribution (CC BY) license.

Original model:  
https://sketchfab.com/3d-models/male-full-body-ecorche-ab11ebff89224f03bd75efede1164cf6

## Author

**Kyle Cahill**  
Biomedical Mechanical Engineering & Computing Technology Student  
University of Ottawa
