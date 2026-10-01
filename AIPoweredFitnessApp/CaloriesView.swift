import SwiftUI
import UIKit

struct CaloriesView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("themeColorName") private var themeColorName = "Gray"
    
    @State private var showEditGoals = false
    @State private var showAddFood = false
    @State private var showAIChat = false
    @State private var showImageSourceOptions = false
    @State private var showImagePicker = false
    @State private var selectedImageSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedFoodImage: UIImage? = nil
    @State private var aiTitle = "Calories AI"
    @State private var aiContext = "Help estimate calories, macros, meals, and nutrition."
    
    @State private var calorieGoal = 3000
    @State private var caloriesEaten = 0
    @State private var proteinEaten = 0
    @State private var carbsEaten = 0
    @State private var fatEaten = 0
    
    @State private var calorieUnit = "kcal"
    @State private var calorieColor: Color = .orange
    
    @State private var proteinGoal = 140
    @State private var proteinUnit = "g"
    @State private var proteinColor: Color = .blue
    
    @State private var carbsGoal = 350
    @State private var carbsUnit = "g"
    @State private var carbsColor: Color = .green
    
    @State private var fatGoal = 90
    @State private var fatUnit = "g"
    @State private var fatColor: Color = .orange
    
    @State private var foodLogs: [FoodLog] = []
    
    var caloriesRemaining: Int {
        max(calorieGoal - caloriesEaten, 0)
    }
    
    var progress: Double {
        guard calorieGoal > 0 else { return 0 }
        return min(Double(caloriesEaten) / Double(calorieGoal), 1.0)
    }

    var proteinCalories: Double {
        Double(proteinEaten * 4)
    }

    var carbsCalories: Double {
        Double(carbsEaten * 4)
    }

    var fatCalories: Double {
        Double(fatEaten * 9)
    }

    var totalMacroCalories: Double {
        proteinCalories + carbsCalories + fatCalories
    }

    var proteinRingEnd: Double {
        guard totalMacroCalories > 0 else { return 0 }
        return progress * (proteinCalories / totalMacroCalories)
    }

    var carbsRingEnd: Double {
        guard totalMacroCalories > 0 else { return 0 }
        return proteinRingEnd + progress * (carbsCalories / totalMacroCalories)
    }

    var fatRingEnd: Double {
        guard totalMacroCalories > 0 else { return progress }
        return carbsRingEnd + progress * (fatCalories / totalMacroCalories)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                
                // Top bar
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Text("Calories")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button {
                        showEditGoals = true
                    } label: {
                        Text("Edit")
                            .font(.headline)
                    }
                    .buttonStyle(.plain)
                }
                
                // Circle + goals
                HStack(spacing: 16) {
                    
                    ZStack {
                        Circle()
                            .stroke(.gray.opacity(0.18), lineWidth: 18)

                        if totalMacroCalories == 0 {
                            Circle()
                                .trim(from: 0, to: progress)
                                .stroke(calorieColor, style: StrokeStyle(lineWidth: 18, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                        } else {
                            Circle()
                                .trim(from: 0, to: proteinRingEnd)
                                .stroke(proteinColor, style: StrokeStyle(lineWidth: 18, lineCap: .round))
                                .rotationEffect(.degrees(-90))

                            Circle()
                                .trim(from: proteinRingEnd, to: carbsRingEnd)
                                .stroke(carbsColor, style: StrokeStyle(lineWidth: 18, lineCap: .butt))
                                .rotationEffect(.degrees(-90))

                            Circle()
                                .trim(from: carbsRingEnd, to: fatRingEnd)
                                .stroke(fatColor, style: StrokeStyle(lineWidth: 18, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                        }

                        VStack(spacing: 6) {
                            Text("\(caloriesEaten)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("of \(calorieGoal) \(calorieUnit)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Text("\(caloriesRemaining) left")
                                .font(.headline)
                            if totalMacroCalories > 0 {
                                Text("P • C • F")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .frame(width: 190, height: 190)
                    
                    VStack(spacing: 12) {
                        goalCard(title: "Goal", value: "\(calorieGoal)", icon: "target")
                        goalCard(title: "Eaten", value: "\(caloriesEaten)", icon: "flame.fill")
                        goalCard(title: "Meals", value: "\(foodLogs.count)", icon: "fork.knife")
                    }
                    .frame(maxWidth: .infinity)
                }
                
                // Macros
                VStack(alignment: .leading, spacing: 14) {
                    Text("Macros")
                        .font(.headline)
                    
                    macroCard(
                        title: "Protein",
                        value: "\(proteinEaten)\(proteinUnit)",
                        goal: "Goal: \(proteinGoal)\(proteinUnit)",
                        icon: "bolt.fill",
                        color: proteinColor
                    )
                    
                    macroCard(
                        title: "Carbs",
                        value: "\(carbsEaten)\(carbsUnit)",
                        goal: "Goal: \(carbsGoal)\(carbsUnit)",
                        icon: "leaf.fill",
                        color: carbsColor
                    )
                    
                    macroCard(
                        title: "Fat",
                        value: "\(fatEaten)\(fatUnit)",
                        goal: "Goal: \(fatGoal)\(fatUnit)",
                        icon: "drop.fill",
                        color: fatColor
                    )
                }
                
                // Food log
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Today’s Food")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button {
                            showAddFood = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.primary)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    if foodLogs.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("No food logged yet")
                                .font(.headline)
                            
                            Text("Scan food, add food manually, or ask AI to estimate calories.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(cardFill(themeColorName))
                        .cornerRadius(18)
                    } else {
                        ForEach(foodLogs) { food in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(food.name)
                                        .font(.headline)
                                    
                                    Text("\(food.protein)g protein • \(food.carbs)g carbs • \(food.fat)g fat")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Text("\(food.calories) \(calorieUnit)")
                                    .font(.headline)
                            }
                            .padding()
                            .background(cardFill(themeColorName))
                            .cornerRadius(18)
                        }
                    }
                }
                
                // AI scan bar
                HStack(spacing: 10) {
                    Button {
                        openAIChat(
                            title: "Calories AI",
                            context: caloriesAIContext(reason: "The user wants to ask AI to estimate food calories or macros.")
                        )
                    } label: {
                        Capsule()
                            .fill(cardFill(themeColorName))
                            .frame(height: 58)
                            .overlay {
                                HStack(spacing: 12) {
                                    Text("Ask AI to scan or estimate food...")
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
                    
                    Button {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                            showImageSourceOptions.toggle()
                        }
                    } label: {
                        Image(systemName: "camera.fill")
                            .font(.title2)
                            .frame(width: 58, height: 58)
                            .background(cardFill(themeColorName))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 8)
            .padding(.bottom, 30)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showEditGoals) {
            EditCalorieGoalsSheet(
                calorieGoal: $calorieGoal,
                calorieUnit: $calorieUnit,
                calorieColor: $calorieColor,
                proteinGoal: $proteinGoal,
                proteinUnit: $proteinUnit,
                proteinColor: $proteinColor,
                carbsGoal: $carbsGoal,
                carbsUnit: $carbsUnit,
                carbsColor: $carbsColor,
                fatGoal: $fatGoal,
                fatUnit: $fatUnit,
                fatColor: $fatColor
            )
        }
        .sheet(isPresented: $showAddFood) {
            AddFoodSheet(
                foodLogs: $foodLogs,
                caloriesEaten: $caloriesEaten,
                proteinEaten: $proteinEaten,
                carbsEaten: $carbsEaten,
                fatEaten: $fatEaten
            )
        }
        .sheet(isPresented: $showAIChat) {
            AIChatSheet(title: aiTitle, context: aiContext)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: selectedImageSource, selectedImage: $selectedFoodImage)
        }
        .onChange(of: selectedFoodImage) { _, newImage in
            guard newImage != nil else { return }
            openAIChat(
                title: "Food Scan AI",
                context: caloriesAIContext(reason: "The user selected a food image. The image picker works, but real image analysis still needs to be connected to the AI backend. Ask the user to describe the food if needed and help estimate calories/macros.")
            )
        }
        .overlay(alignment: .bottomTrailing) {
            if showImageSourceOptions {
                VStack(alignment: .leading, spacing: 0) {
                    Button {
                        selectedImageSource = .camera
                        showImageSourceOptions = false
                        showImagePicker = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "camera.fill")
                                .frame(width: 22)
                            Text("Camera")
                            Spacer()
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.plain)
                    
                    Divider()
                    
                    Button {
                        selectedImageSource = .photoLibrary
                        showImageSourceOptions = false
                        showImagePicker = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "photo.on.rectangle")
                                .frame(width: 22)
                            Text("Photo Library")
                            Spacer()
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.plain)
                }
                .frame(width: 190)
                .background(.regularMaterial)
                .cornerRadius(18)
                .shadow(radius: 12)
                .padding(.trailing, 22)
                .padding(.bottom, 98)
                .transition(.opacity.combined(with: .scale(scale: 0.92, anchor: .bottomTrailing)))
            }
        }
    }
    
    func goalCard(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.headline)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(value)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .frame(height: 55)
        .background(cardFill(themeColorName))
        .cornerRadius(16)
    }
    
    func macroCard(title: String, value: String, goal: String, icon: String, color: Color) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(goal)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
        }
        .padding()
        .background(color.opacity(0.15))
        .cornerRadius(18)
    }

    private func openAIChat(title: String, context: String) {
        aiTitle = title
        aiContext = context
        showAIChat = true
    }
    
    private func caloriesAIContext(reason: String) -> String {
        let loggedFoods: String
        
        if foodLogs.isEmpty {
            loggedFoods = "No foods have been logged yet today."
        } else {
            loggedFoods = foodLogs.map { food in
                "\(food.name): \(food.calories) \(calorieUnit), \(food.protein)g protein, \(food.carbs)g carbs, \(food.fat)g fat"
            }.joined(separator: "; ")
        }
        
        return """
        \(reason)
        Current calorie goal: \(calorieGoal) \(calorieUnit).
        Calories eaten: \(caloriesEaten) \(calorieUnit).
        Calories remaining: \(caloriesRemaining) \(calorieUnit).
        Protein: \(proteinEaten)\(proteinUnit) of \(proteinGoal)\(proteinUnit).
        Carbs: \(carbsEaten)\(carbsUnit) of \(carbsGoal)\(carbsUnit).
        Fat: \(fatEaten)\(fatUnit) of \(fatGoal)\(fatUnit).
        Logged foods: \(loggedFoods)
        Help the user estimate food, understand macros, or decide what to eat next.
        """
    }
}

struct EditCalorieGoalsSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var calorieGoal: Int
    @Binding var calorieUnit: String
    @Binding var calorieColor: Color
    
    @Binding var proteinGoal: Int
    @Binding var proteinUnit: String
    @Binding var proteinColor: Color
    
    @Binding var carbsGoal: Int
    @Binding var carbsUnit: String
    @Binding var carbsColor: Color
    
    @Binding var fatGoal: Int
    @Binding var fatUnit: String
    @Binding var fatColor: Color
    
    @State private var calorieText = ""
    @State private var proteinText = ""
    @State private var carbsText = ""
    @State private var fatText = ""
    
    let calorieUnits = ["kcal", "cal"]
    let macroUnits = ["g", "mg", "oz"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                HStack {
                    Text("Edit Goals")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button {
                        saveGoals()
                        dismiss()
                    } label: {
                        Text("Done")
                            .font(.headline)
                    }
                    .buttonStyle(.plain)
                }
                
                goalEditor(
                    title: "Calories",
                    text: $calorieText,
                    unit: $calorieUnit,
                    color: $calorieColor,
                    placeholder: "3000"
                )
                
                goalEditor(
                    title: "Protein",
                    text: $proteinText,
                    unit: $proteinUnit,
                    color: $proteinColor,
                    placeholder: "140"
                )
                
                goalEditor(
                    title: "Carbs",
                    text: $carbsText,
                    unit: $carbsUnit,
                    color: $carbsColor,
                    placeholder: "350"
                )
                
                goalEditor(
                    title: "Fat",
                    text: $fatText,
                    unit: $fatUnit,
                    color: $fatColor,
                    placeholder: "90"
                )
            }
            .padding(22)
        }
        .onAppear {
            calorieText = "\(calorieGoal)"
            proteinText = "\(proteinGoal)"
            carbsText = "\(carbsGoal)"
            fatText = "\(fatGoal)"
        }
    }
    
    func goalEditor(
        title: String,
        text: Binding<String>,
        unit: Binding<String>,
        color: Binding<Color>,
        placeholder: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            
            HStack {
                TextField(placeholder, text: text)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                
                Menu {
                    ForEach(unitsFor(title), id: \.self) { unitOption in
                        Button(unitOption) {
                            unit.wrappedValue = unitOption
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(unit.wrappedValue)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .frame(width: 76, height: 36)
                    .background(.gray.opacity(0.15))
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
            }
            
            ColorPicker("Card colour", selection: color)
                .padding()
                .background(color.wrappedValue.opacity(0.15))
                .cornerRadius(16)
        }
        .padding()
        .background(color.wrappedValue.opacity(0.10))
        .cornerRadius(18)
    }

    func unitsFor(_ title: String) -> [String] {
        if title == "Calories" {
            return calorieUnits
        }
        
        return macroUnits
    }
    
    func saveGoals() {
        calorieGoal = Int(calorieText) ?? calorieGoal
        proteinGoal = Int(proteinText) ?? proteinGoal
        carbsGoal = Int(carbsText) ?? carbsGoal
        fatGoal = Int(fatText) ?? fatGoal
    }
}

struct AddFoodSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var foodLogs: [FoodLog]
    @Binding var caloriesEaten: Int
    @Binding var proteinEaten: Int
    @Binding var carbsEaten: Int
    @Binding var fatEaten: Int
    
    @State private var foodName = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                HStack {
                    Text("Add Food")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button {
                        addFood()
                        dismiss()
                    } label: {
                        Text("Done")
                            .font(.headline)
                    }
                    .buttonStyle(.plain)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Food")
                        .font(.headline)
                    
                    TextField("Example: Chicken poutine", text: $foodName)
                        .textFieldStyle(.roundedBorder)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Calories")
                        .font(.headline)
                    
                    TextField("Example: 850", text: $calories)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Protein")
                        .font(.headline)
                    
                    TextField("Example: 35", text: $protein)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Carbs")
                        .font(.headline)
                    
                    TextField("Example: 90", text: $carbs)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Fat")
                        .font(.headline)
                    
                    TextField("Example: 40", text: $fat)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                }
            }
            .padding(22)
        }
    }
    
    func addFood() {
        let cleanedName = foodName.trimmingCharacters(in: .whitespacesAndNewlines)
        let calorieAmount = Int(calories) ?? 0
        let proteinAmount = Int(protein) ?? 0
        let carbsAmount = Int(carbs) ?? 0
        let fatAmount = Int(fat) ?? 0
        
        guard !cleanedName.isEmpty else { return }
        
        foodLogs.append(
            FoodLog(
                name: cleanedName,
                calories: calorieAmount,
                protein: proteinAmount,
                carbs: carbsAmount,
                fat: fatAmount
            )
        )
        
        caloriesEaten += calorieAmount
        proteinEaten += proteinAmount
        carbsEaten += carbsAmount
        fatEaten += fatAmount
    }
}

struct FoodLog: Identifiable {
    var id = UUID()
    var name: String
    var calories: Int
    var protein: Int
    var carbs: Int
    var fat: Int
}

struct ImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(sourceType) ? sourceType : .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        CaloriesView()
    }
}
