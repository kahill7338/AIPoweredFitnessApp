import SwiftUI
import SceneKit

struct ContentView: View {
    @State private var showProfile = false
    @State private var isModelFocused = false
    @State private var selectedMuscleInfo: MuscleInfo? = nil
    @State private var showAIChat = false
    @State private var aiTitle = "Ask AI"
    @State private var aiContext = "General fitness help."
    @AppStorage("themeColorName") private var themeColorName = "Gray"
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                
                HStack {
                    if !isModelFocused {
                        Text("Anatomy Fitness")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    if isModelFocused {
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                isModelFocused = false
                                selectedMuscleInfo = nil
                            }
                        } label: {
                            Image(systemName: "arrow.down.right.and.arrow.up.left")
                                .font(.title3)
                                .frame(width: 38, height: 38)
                                .background(cardFill(themeColorName))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Button {
                        showProfile = true
                    } label: {
                        Image(systemName: "person.crop.circle")
                            .font(.title)
                    }
                    .buttonStyle(.plain)
                }
                
                // Big anatomy card
                RoundedRectangle(cornerRadius: 30)
                    .fill(.clear)
                    .frame(maxWidth: .infinity)
                    .frame(height: isModelFocused ? 680 : 520)
                    .overlay {
                        AnatomyModelView(
                            modelName: "Male_Full_Body_Ecorche",
                            isModelFocused: $isModelFocused
                        ) { muscleInfo in
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                selectedMuscleInfo = muscleInfo
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                    }
                    .animation(.spring(response: 0.35, dampingFraction: 0.85), value: isModelFocused)
                
                if !isModelFocused {
                    // Main cards
                    HStack(spacing: 14) {
                        NavigationLink {
                            CaloriesView()
                        } label: {
                            fitnessCard(icon: "fork.knife", title: "Calories")
                        }
                        
                        NavigationLink {
                            WorkoutsView()
                        } label: {
                            fitnessCard(icon: "dumbbell.fill", title: "Workouts")
                        }
                    }
                    .frame(height: 115)
                    .buttonStyle(.plain)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    
                    // AI search/input bar
                    Button {
                        openAIChat(
                            title: "Workout AI",
                            context: "The user is on the home screen and wants general workout, anatomy, nutrition, or recovery help."
                        )
                    } label: {
                        Capsule()
                            .fill(cardFill(themeColorName))
                            .frame(height: 70)
                            .overlay {
                                HStack(spacing: 15) {
                                    Text("Ask AI about your workout...")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.up.circle.fill")
                                        .font(.title2)
                                }
                                .padding(.horizontal, 18)
                            }
                    }
                    .buttonStyle(.plain)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                } else {
                    if selectedMuscleInfo == nil {
                        HStack {
                            Spacer()
                            
                            Button {
                                openAIChat(
                                    title: "Anatomy AI",
                                    context: "The user is viewing the interactive anatomy model. Help explain muscles, workouts, form, soreness, and recovery."
                                )
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "sparkles")
                                    Text("Ask AI")
                                }
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 11)
                                .background(cardFill(themeColorName))
                                .cornerRadius(22)
                            }
                            .buttonStyle(.plain)
                        }
                        .transition(.opacity)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 22)
            .padding(.top, 18)
            .background(themeColor(themeColorName).opacity(0.06).ignoresSafeArea())
            .overlay(alignment: .bottom) {
                if isModelFocused, let selectedMuscleInfo {
                    MuscleInfoPopup(
                        info: selectedMuscleInfo,
                        onClose: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                self.selectedMuscleInfo = nil
                            }
                        },
                        onAskAI: {
                            openAIChat(
                                title: selectedMuscleInfo.name,
                                context: "The user tapped \(selectedMuscleInfo.name) on the anatomy model. Description: \(selectedMuscleInfo.description) Suggested workouts: \(selectedMuscleInfo.workouts.joined(separator: ", ")). Recovery guidance: \(selectedMuscleInfo.recovery)"
                            )
                        }
                    )
                    .padding(.horizontal, 18)
                    .padding(.bottom, 18)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
            .sheet(isPresented: $showAIChat) {
                AIChatSheet(title: aiTitle, context: aiContext)
            }
        }
    }
    
    func fitnessCard(icon: String, title: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 34))
            
            Text(title)
                .font(.headline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(cardFill(themeColorName))
        .cornerRadius(22)
    }
    
    private func openAIChat(title: String, context: String) {
        aiTitle = title
        aiContext = context
        showAIChat = true
    }
}

#Preview {
    ContentView()
}

struct AnatomyModelView: UIViewRepresentable {
    let modelName: String
    @Binding var isModelFocused: Bool
    var onMuscleSelected: (MuscleInfo) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = FocusSceneView()
        sceneView.onInteraction = {
            context.coordinator.focusModel()
        }
        sceneView.onBodyTap = { nodeNames in
            context.coordinator.selectMuscle(from: nodeNames)
        }
        
        sceneView.backgroundColor = .clear
        sceneView.isOpaque = false
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.defaultCameraController.interactionMode = .orbitTurntable
        sceneView.defaultCameraController.inertiaEnabled = true
        
        let pinchOutGesture = UIPinchGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePinchOut)
        )
        pinchOutGesture.delegate = context.coordinator
        pinchOutGesture.cancelsTouchesInView = false
        sceneView.addGestureRecognizer(pinchOutGesture)
        
        let bodyTapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleBodyTap)
        )
        bodyTapGesture.delegate = context.coordinator
        bodyTapGesture.cancelsTouchesInView = false
        sceneView.addGestureRecognizer(bodyTapGesture)
        
        let scene = SCNScene()
        scene.background.contents = UIColor.clear
        
        if let modelScene = SCNScene(named: "\(modelName).usdz") {
            let containerNode = SCNNode()
            
            for child in modelScene.rootNode.childNodes {
                child.enumerateChildNodes { node, _ in
                    node.geometry?.materials.forEach { material in
                        material.isDoubleSided = true
                        material.transparencyMode = .dualLayer
                        material.writesToDepthBuffer = true
                        material.readsFromDepthBuffer = true
                    }
                }
                
                child.geometry?.materials.forEach { material in
                    material.isDoubleSided = true
                    material.transparencyMode = .dualLayer
                    material.writesToDepthBuffer = true
                    material.readsFromDepthBuffer = true
                }
                
                containerNode.addChildNode(child)
            }
            
            containerNode.name = "anatomyContainer"
            containerNode.position = isModelFocused ? SCNVector3(0, -1.08, 0) : SCNVector3(0, -1.1, 0)
            containerNode.scale = isModelFocused ? SCNVector3(0.32, 0.32, 0.32) : SCNVector3(0.34, 0.34, 0.34)
            scene.rootNode.addChildNode(containerNode)
        }
        
        let cameraNode = SCNNode()
        cameraNode.name = "anatomyCamera"
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.automaticallyAdjustsZRange = true
        cameraNode.camera?.zNear = 0.01
        cameraNode.camera?.zFar = 10000
        cameraNode.position = isModelFocused ? SCNVector3(0, -13, 80) : SCNVector3(0, -15, 95)
        scene.rootNode.addChildNode(cameraNode)
        sceneView.pointOfView = cameraNode
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(0, 3, 4)
        scene.rootNode.addChildNode(lightNode)
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.intensity = 600
        scene.rootNode.addChildNode(ambientLightNode)
        
        sceneView.scene = scene
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        guard let scene = uiView.scene else { return }
        
        let containerNode = scene.rootNode.childNode(withName: "anatomyContainer", recursively: true)
        let cameraNode = scene.rootNode.childNode(withName: "anatomyCamera", recursively: true)
        
        let targetModelPosition: SCNVector3
        let targetModelScale: SCNVector3
        let targetCameraPosition: SCNVector3
        let targetModelRotation: SCNVector3
        let targetCameraRotation: SCNVector3
        
        if isModelFocused {
            targetModelPosition = SCNVector3(0, -1.08, 0)
            targetModelScale = SCNVector3(0.32, 0.32, 0.32)
            targetCameraPosition = SCNVector3(0, -13, 80)
            targetModelRotation = containerNode?.eulerAngles ?? SCNVector3Zero
            targetCameraRotation = cameraNode?.eulerAngles ?? SCNVector3Zero
        } else {
            targetModelPosition = SCNVector3(0, -1.1, 0)
            targetModelScale = SCNVector3(0.34, 0.34, 0.34)
            targetCameraPosition = SCNVector3(0, -15, 95)
            targetModelRotation = SCNVector3Zero
            targetCameraRotation = SCNVector3Zero
            
            uiView.defaultCameraController.stopInertia()
            uiView.defaultCameraController.clearRoll()
            uiView.defaultCameraController.target = SCNVector3(0, -1.1, 0)
        }
        
        let modelMove = SCNAction.move(to: targetModelPosition, duration: 0.85)
        modelMove.timingMode = .easeInEaseOut
        
        let modelScale = SCNAction.scale(to: CGFloat(targetModelScale.x), duration: 0.85)
        modelScale.timingMode = .easeInEaseOut
        
        let cameraMove = SCNAction.move(to: targetCameraPosition, duration: 0.85)
        cameraMove.timingMode = .easeInEaseOut
        
        let modelRotate = SCNAction.rotateTo(
            x: CGFloat(targetModelRotation.x),
            y: CGFloat(targetModelRotation.y),
            z: CGFloat(targetModelRotation.z),
            duration: 0.85,
            usesShortestUnitArc: true
        )
        modelRotate.timingMode = .easeInEaseOut

        let cameraRotate = SCNAction.rotateTo(
            x: CGFloat(targetCameraRotation.x),
            y: CGFloat(targetCameraRotation.y),
            z: CGFloat(targetCameraRotation.z),
            duration: 0.85,
            usesShortestUnitArc: true
        )
        cameraRotate.timingMode = .easeInEaseOut
        
        containerNode?.removeAction(forKey: "modelMove")
        containerNode?.removeAction(forKey: "modelScale")
        cameraNode?.removeAction(forKey: "cameraMove")
        containerNode?.removeAction(forKey: "modelRotate")
        cameraNode?.removeAction(forKey: "cameraRotate")
        
        containerNode?.runAction(modelMove, forKey: "modelMove")
        containerNode?.runAction(modelScale, forKey: "modelScale")
        cameraNode?.runAction(cameraMove, forKey: "cameraMove")
        containerNode?.runAction(modelRotate, forKey: "modelRotate")
        cameraNode?.runAction(cameraRotate, forKey: "cameraRotate")
        
        if !isModelFocused, let cameraNode {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.86) {
                uiView.defaultCameraController.stopInertia()
                uiView.defaultCameraController.clearRoll()
                cameraNode.position = SCNVector3(0, -15, 95)
                cameraNode.eulerAngles = SCNVector3Zero
                uiView.pointOfView = cameraNode
            }
        }
    }
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var parent: AnatomyModelView
        
        init(parent: AnatomyModelView) {
            self.parent = parent
        }
        
        func focusModel() {
            DispatchQueue.main.async {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    self.parent.isModelFocused = true
                }
            }
        }
        
        func selectMuscle(from nodeNames: [String]) {
            guard let info = MuscleInfo.info(forNodeNames: nodeNames) else {
                return
            }
            
            DispatchQueue.main.async {
                if self.parent.isModelFocused {
                    self.parent.onMuscleSelected(info)
                } else {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        self.parent.isModelFocused = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        self.parent.onMuscleSelected(info)
                    }
                }
            }
        }

        @objc func handleBodyTap(_ gesture: UITapGestureRecognizer) {
            guard gesture.state == .ended,
                  let sceneView = gesture.view as? SCNView else {
                return
            }
            
            let location = gesture.location(in: sceneView)
            let hitResults = sceneView.hitTest(location, options: [
                .boundingBoxOnly: false,
                .searchMode: SCNHitTestSearchMode.all.rawValue
            ])
            
            guard let firstHit = hitResults.first else {
                print("Tapped anatomy node: no hit")
                return
            }
            
            let tappedNodeNames = collectNodeNames(from: firstHit.node)
            print("Tapped anatomy node:")
            print(tappedNodeNames.joined(separator: " -> "))
            selectMuscle(from: tappedNodeNames)
        }
        
        private func collectNodeNames(from node: SCNNode) -> [String] {
            var currentNode: SCNNode? = node
            var names: [String] = []
            
            while let node = currentNode {
                names.append(node.name ?? "unnamed")
                currentNode = node.parent
            }
            
            return names
        }
        
        func resetModel() {
            DispatchQueue.main.async {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    self.parent.isModelFocused = false
                }
            }
        }
        
        @objc func handlePinchOut(_ gesture: UIPinchGestureRecognizer) {
            if gesture.scale < 0.82 && gesture.state == .ended {
                resetModel()
            }
        }
        
        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            true
        }
    }
}

class FocusSceneView: SCNView {
    var onInteraction: (() -> Void)?
    var onBodyTap: (([String]) -> Void)?
    private var didMoveDuringTouch = false
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        didMoveDuringTouch = false
        onInteraction?()
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        didMoveDuringTouch = true
        
        if event?.allTouches?.count == 1 {
            onInteraction?()
        }
        
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !didMoveDuringTouch, let touch = touches.first {
            let location = touch.location(in: self)
            
            let hitResults = hitTest(location, options: [
                .boundingBoxOnly: false,
                .searchMode: SCNHitTestSearchMode.all.rawValue
            ])
            
            if let firstHit = hitResults.first {
                let tappedNodeNames = collectNodeNames(from: firstHit.node)
                print("Tapped anatomy node:")
                print(tappedNodeNames.joined(separator: " -> "))
                onBodyTap?(tappedNodeNames)
            } else {
                print("Tapped anatomy node: no hit")
            }
        }
        
        super.touchesEnded(touches, with: event)
    }
    
    private func collectNodeNames(from node: SCNNode) -> [String] {
        var currentNode: SCNNode? = node
        var names: [String] = []
        
        while let node = currentNode {
            names.append(node.name ?? "unnamed")
            currentNode = node.parent
        }
        
        return names
    }
}

struct MuscleInfo: Identifiable, Equatable {
    var id: String { objectID }
    let objectID: String
    let name: String
    let description: String
    let workouts: [String]
    let recovery: String
    
    static func info(forNodeNames nodeNames: [String]) -> MuscleInfo? {
        let tappedObjectIDs = Set(nodeNames.compactMap { extractObjectID(from: $0) })
        
        print("Matched object IDs:", tappedObjectIDs.sorted().joined(separator: ", "))
        
        for objectID in priorityOrder {
            if tappedObjectIDs.contains(objectID), let info = infoByObjectID[objectID] {
                return info
            }
        }
        
        return nil
    }
    
    private static func extractObjectID(from nodeName: String) -> String? {
        let parts = nodeName.split(separator: "_")
        guard parts.count >= 2, parts[0] == "Object" else { return nil }
        return "Object_\(parts[1])"
    }

    private static let priorityOrder: [String] = [
        "Object_23", // Chest / Abs
        "Object_33", // Biceps / Triceps
        "Object_31", // Forearms
        "Object_21", // Forearms
        "Object_17", // Quadriceps
        "Object_7",  // Calves
        "Object_9",  // Hamstrings
        "Object_27", // Adductors
        "Object_25", // Front legs / Feet
        "Object_3",  // Glutes
        "Object_13", // Back
        "Object_19", // Neck
        "Object_5",  // Shoulders
        "Object_15"  // Face / Head
    ]
    
    private static let infoByObjectID: [String: MuscleInfo] = [
        "Object_23": MuscleInfo(
            objectID: "Object_23",
            name: "Chest / Abs",
            description: "Chest helps with pushing movements, while abs help stabilize your trunk and transfer force through your body.",
            workouts: ["Bench press", "Incline dumbbell press", "Cable crunches", "Planks"],
            recovery: "Usually 48–72 hours after hard chest training, 24–48 hours for core."
        ),
        "Object_33": MuscleInfo(
            objectID: "Object_33",
            name: "Biceps / Triceps",
            description: "Biceps help with pulling and elbow flexion. Triceps help with pushing and elbow extension.",
            workouts: ["Bicep curls", "Hammer curls", "Tricep pushdowns", "Dips"],
            recovery: "Usually 24–48 hours."
        ),
        "Object_5": MuscleInfo(
            objectID: "Object_5",
            name: "Shoulders",
            description: "Shoulders help raise, rotate, and stabilize your arms during pressing and pulling movements.",
            workouts: ["Overhead press", "Lateral raises", "Rear delt flyes", "Face pulls"],
            recovery: "Usually 48–72 hours after heavy pressing."
        ),
        "Object_13": MuscleInfo(
            objectID: "Object_13",
            name: "Back",
            description: "Back muscles help with pulling, posture, spinal support, and shoulder control.",
            workouts: ["Pull-ups", "Lat pulldowns", "Rows", "Deadlifts"],
            recovery: "Usually 48–72 hours after hard training."
        ),
        "Object_3": MuscleInfo(
            objectID: "Object_3",
            name: "Glutes",
            description: "Glutes help with hip extension, power, running, squatting, and lower-body stability.",
            workouts: ["Hip thrusts", "Squats", "Romanian deadlifts", "Bulgarian split squats"],
            recovery: "Usually 48–72 hours."
        ),
        "Object_9": MuscleInfo(
            objectID: "Object_9",
            name: "Hamstrings",
            description: "Hamstrings help bend the knee, extend the hip, sprint, hinge, and control lower-body movement.",
            workouts: ["Romanian deadlifts", "Leg curls", "Good mornings", "Nordic curls"],
            recovery: "Usually 48–72 hours."
        ),
        "Object_7": MuscleInfo(
            objectID: "Object_7",
            name: "Calves",
            description: "Calves help with ankle movement, balance, jumping, running, and walking.",
            workouts: ["Standing calf raises", "Seated calf raises", "Jump rope", "Incline walking"],
            recovery: "Usually 24–48 hours."
        ),
        "Object_17": MuscleInfo(
            objectID: "Object_17",
            name: "Quadriceps",
            description: "Quadriceps extend the knee and are heavily used in squats, lunges, running, and jumping.",
            workouts: ["Squats", "Leg press", "Lunges", "Leg extensions"],
            recovery: "Usually 48–72 hours."
        ),
        "Object_27": MuscleInfo(
            objectID: "Object_27",
            name: "Adductors",
            description: "Adductors help pull the legs toward the midline and stabilize the hips during lower-body work.",
            workouts: ["Copenhagen planks", "Sumo squats", "Cable adductions", "Adductor machine"],
            recovery: "Usually 24–48 hours."
        ),
        "Object_25": MuscleInfo(
            objectID: "Object_25",
            name: "Front Legs / Feet",
            description: "This area includes front lower-leg and foot muscles involved in balance, walking, running, and ankle control.",
            workouts: ["Tibialis raises", "Walking lunges", "Balance work", "Calf raises"],
            recovery: "Usually 24–48 hours."
        ),
        "Object_19": MuscleInfo(
            objectID: "Object_19",
            name: "Neck",
            description: "Neck muscles support head position, posture, and upper-body stability.",
            workouts: ["Neck isometrics", "Shrugs", "Farmer carries", "Face pulls"],
            recovery: "Usually 24–48 hours. Train gently."
        ),
        "Object_15": MuscleInfo(
            objectID: "Object_15",
            name: "Face / Head",
            description: "This area is not usually trained like a major muscle group, but posture, jaw tension, and neck control can affect comfort.",
            workouts: ["Posture drills", "Neck mobility", "Relaxed breathing", "Light stretching"],
            recovery: "Avoid heavy direct training. Focus on mobility and tension relief."
        ),
        "Object_31": MuscleInfo(
            objectID: "Object_31",
            name: "Forearms",
            description: "Forearms help with grip strength, wrist control, pulling movements, and carrying strength.",
            workouts: ["Wrist curls", "Reverse curls", "Farmer carries", "Dead hangs"],
            recovery: "Usually 24–48 hours."
        ),
        "Object_21": MuscleInfo(
            objectID: "Object_21",
            name: "Forearms",
            description: "Forearms help with grip strength, wrist control, pulling movements, and carrying strength.",
            workouts: ["Wrist curls", "Reverse curls", "Farmer carries", "Dead hangs"],
            recovery: "Usually 24–48 hours."
        )
    ]
}

struct MuscleInfoPopup: View {
    let info: MuscleInfo
    let onClose: () -> Void
    let onAskAI: () -> Void
    @AppStorage("themeColorName") private var themeColorName = "Gray"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(info.name)
                        .font(.headline)
                    
                    Text(info.recovery)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button {
                    onClose()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            Text(info.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Good workouts")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                ForEach(info.workouts, id: \.self) { workout in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                        Text(workout)
                            .font(.subheadline)
                    }
                }
            }
            
            Button {
                onAskAI()
            } label: {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Ask AI about \(info.name)")
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(cardFill(themeColorName))
                .cornerRadius(16)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(.regularMaterial)
        .cornerRadius(24)
        .shadow(radius: 12)
    }
}
