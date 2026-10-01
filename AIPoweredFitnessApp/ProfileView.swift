import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("themeColorName") private var themeColorName = "Gray"
    
    @State private var openSection: ProfileSection? = nil
    
    @State private var selectedGoal = "Build muscle"
    @State private var calorieGoal = "3000"
    @State private var selectedTraining = "Gym workouts"
    
    let goalOptions = [
        "Build muscle",
        "Lose fat",
        "Maintain weight",
        "Improve strength",
        "Improve endurance",
        "General health"
    ]
    
    let trainingOptions = [
        "Gym workouts",
        "Home workouts",
        "Bodyweight",
        "Running",
        "Sports training",
        "Mixed training"
    ]
    
    var body: some View {
        VStack(spacing: 22) {
            
            HStack {
                Text("Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 90))
            
            VStack(spacing: 8) {
                Text("Kyle")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Fitness profile setup")
                    .foregroundStyle(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("App Colour")
                    .font(.headline)
                
                HStack(spacing: 12) {
                    ForEach(themeColorNames, id: \.self) { colorName in
                        Button {
                            themeColorName = colorName
                        } label: {
                            Circle()
                                .fill(themeColor(colorName))
                                .frame(width: 34, height: 34)
                                .overlay {
                                    if themeColorName == colorName {
                                        Image(systemName: "checkmark")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundStyle(.white)
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 14) {
                profileSettingCard(
                    section: .goal,
                    icon: "target",
                    title: "Goal",
                    value: selectedGoal
                ) {
                    VStack(spacing: 8) {
                        ForEach(goalOptions, id: \.self) { goal in
                            optionButton(title: goal, isSelected: selectedGoal == goal) {
                                selectedGoal = goal
                                openSection = nil
                            }
                        }
                    }
                }
                
                profileSettingCard(
                    section: .calories,
                    icon: "flame.fill",
                    title: "Calories",
                    value: "\(calorieGoal) kcal/day"
                ) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Daily calorie goal")
                            .font(.headline)
                        
                        TextField("3000", text: $calorieGoal)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                        
                        Button {
                            openSection = nil
                        } label: {
                            Text("Save")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(.gray.opacity(0.18))
                                .cornerRadius(14)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                profileSettingCard(
                    section: .training,
                    icon: "figure.strengthtraining.traditional",
                    title: "Training",
                    value: selectedTraining
                ) {
                    VStack(spacing: 8) {
                        ForEach(trainingOptions, id: \.self) { training in
                            optionButton(title: training, isSelected: selectedTraining == training) {
                                selectedTraining = training
                                openSection = nil
                            }
                        }
                    }
                }
                
                profileRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Progress",
                    value: "Coming soon"
                )
            }
            
            Spacer()
        }
        .padding(24)
    }
    
    func profileSettingCard<Content: View>(
        section: ProfileSection,
        icon: String,
        title: String,
        value: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    if openSection == section {
                        openSection = nil
                    } else {
                        openSection = section
                    }
                }
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: icon)
                        .font(.title3)
                        .frame(width: 28)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                        
                        Text(value)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: openSection == section ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
            
            if openSection == section {
                content()
                    .padding(.top, 2)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(cardFill(themeColorName))
        .cornerRadius(18)
    }
    
    func optionButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.headline)
                }
            }
            .padding()
            .background(.gray.opacity(0.16))
            .cornerRadius(14)
        }
        .buttonStyle(.plain)
    }
    
    func profileRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(cardFill(themeColorName))
        .cornerRadius(18)
    }
}

enum ProfileSection {
    case goal
    case calories
    case training
}

#Preview {
    ProfileView()
}
