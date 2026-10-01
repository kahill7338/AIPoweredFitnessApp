import SwiftUI

struct WorkoutsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("themeColorName") private var themeColorName = "Gray"
    @State private var weeklyPlans: [WorkoutDayPlan] = WorkoutDayPlan.emptyWeek
    @State private var showEditPlan = false
    @State private var showAIChat = false
    @State private var aiTitle = "Workout AI"
    @State private var aiContext = "Help improve the weekly workout plan."
    
    var body: some View {
        TabView {
            ScrollView {
                weeklyPlanSlide
                    .padding(.bottom, 70)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            ScrollView {
                progressLogsSlide
                    .padding(.bottom, 70)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .background(themeColor(themeColorName).opacity(0.06).ignoresSafeArea())
        .sheet(isPresented: $showEditPlan) {
            EditWeeklyPlanSheet(plans: $weeklyPlans)
        }
        .sheet(isPresented: $showAIChat) {
            AIChatSheet(title: aiTitle, context: aiContext)
        }
    }
    
    var weeklyPlanSlide: some View {
        VStack(spacing: 16) {
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
                
                Text("Weekly Plan")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button {
                    showEditPlan = true
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.primary)
                }
                .buttonStyle(.plain)
            }
            
            weeklyHeroCard
            
            VStack(spacing: 10) {
                ForEach($weeklyPlans) { $plan in
                    NavigationLink {
                        WorkoutDetailView(plan: $plan)
                    } label: {
                        workoutDayCard(plan: plan)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 22)
        .padding(.top, 8)
    }
    
    var progressLogsSlide: some View {
        VStack(spacing: 18) {
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
                
                Text("Progress & Logs")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .opacity(0)
            }
            
            progressStatsRow
            
            RoundedRectangle(cornerRadius: 28)
                .fill(cardFill(themeColorName))
                .frame(height: 250)
                .overlay {
                    VStack(spacing: 12) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 55))
                        
                        Text("Muscle Group Progress")
                            .font(.headline)
                        
                        Text("Your graph will appear after you log sets.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
            
            VStack(alignment: .leading, spacing: 14) {
                Text("Logs")
                    .font(.headline)
                
                if workoutLogs.isEmpty {
                    emptyLogCard
                } else {
                    ForEach(workoutLogs) { log in
                        logCard(log: log)
                    }
                }
            }
        }
        .padding(.horizontal, 22)
        .padding(.top, 8)
    }
    
    var weeklyHeroCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("This Week")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(weeklySummaryText)
                        .font(.headline)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                Button {
                    openAIChat(
                        title: "Workout AI",
                        context: workoutAIContext(reason: "The user wants help making their weekly workout plan better and more personalized.")
                    )
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                        Text("Ask AI")
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemBackground).opacity(0.65))
                    .cornerRadius(14)
                }
                .buttonStyle(.plain)
            }
            
            HStack(spacing: 10) {
                miniStat(title: "Planned", value: "\(plannedDaysCount)/7")
                miniStat(title: "Rest", value: "\(restDaysCount)")
                miniStat(title: "Logged", value: "\(completedDaysCount)")
                miniStat(title: "Sets", value: "\(totalSetsLogged)")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(cardFill(themeColorName))
        .cornerRadius(24)
    }
    
    var progressStatsRow: some View {
        HStack(spacing: 10) {
            miniStat(title: "Workout", value: "\(plannedDaysCount)")
            miniStat(title: "Rest", value: "\(restDaysCount)")
            miniStat(title: "Done", value: "\(completedDaysCount)")
            miniStat(title: "Sets", value: "\(totalSetsLogged)")
        }
    }
    
    var emptyLogCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("No logs yet")
                .font(.headline)
            
            Text("Open a workout day, tap Log Set beside an exercise, then add reps and weight.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(cardFill(themeColorName))
        .cornerRadius(18)
    }
    
    var workoutLogs: [WorkoutLogEntry] {
        var logs: [WorkoutLogEntry] = []
        
        for plan in weeklyPlans where !plan.isRestDay {
            for exercise in plan.exercises {
                for set in exercise.sets {
                    logs.append(
                        WorkoutLogEntry(
                            day: plan.day,
                            exercise: exercise.name,
                            reps: set.reps,
                            weight: set.weight
                        )
                    )
                }
            }
        }
        
        return logs
    }
    
    func workoutDayCard(plan: WorkoutDayPlan) -> some View {
        HStack(spacing: 14) {
            Image(systemName: planStatusIcon(plan))
                .font(.title3)
                .frame(width: 34, height: 34)
                .background(Color(.systemBackground).opacity(0.55))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Text(plan.day)
                        .font(.headline)
                    
                    Text(planStatusText(plan))
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemBackground).opacity(0.55))
                        .cornerRadius(10)
                }
                
                Text(plan.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(plan.details)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(plan.isRestDay ? "Recovery" : "\(setsLogged(for: plan)) sets")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(cardFill(themeColorName))
        .cornerRadius(18)
    }
    
    func logCard(log: WorkoutLogEntry) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(log.exercise)
                    .font(.headline)
                
                Text("\(log.day) • \(log.reps) reps completed")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(log.weight)
                .font(.headline)
        }
        .padding()
        .background(cardFill(themeColorName))
        .cornerRadius(18)
    }
    
    var plannedDaysCount: Int {
        weeklyPlans.filter { !$0.isRestDay && (!$0.exercises.isEmpty || !$0.muscleGroups.isEmpty) }.count
    }
    
    var restDaysCount: Int {
        weeklyPlans.filter { $0.isRestDay }.count
    }
    
    var completedDaysCount: Int {
        weeklyPlans.filter { !$0.isRestDay && setsLogged(for: $0) > 0 }.count
    }
    
    var totalSetsLogged: Int {
        weeklyPlans.reduce(0) { total, plan in
            total + setsLogged(for: plan)
        }
    }
    
    var weeklySummaryText: String {
        if plannedDaysCount == 0 && restDaysCount == 0 {
            return "Build your first weekly split"
        }
        
        if plannedDaysCount == 0 && restDaysCount > 0 {
            return "\(restDaysCount) recovery day\(restDaysCount == 1 ? "" : "s") planned"
        }
        
        if completedDaysCount == 0 {
            return "\(plannedDaysCount) workout day\(plannedDaysCount == 1 ? "" : "s") ready"
        }
        
        return "\(completedDaysCount) of \(plannedDaysCount) workout days logged"
    }
    
    func miniStat(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(.systemBackground).opacity(0.55))
        .cornerRadius(14)
    }
    
    func setsLogged(for plan: WorkoutDayPlan) -> Int {
        guard !plan.isRestDay else { return 0 }
        
        return plan.exercises.reduce(0) { total, exercise in
            total + exercise.sets.count
        }
    }
    
    func planStatusIcon(_ plan: WorkoutDayPlan) -> String {
        if plan.isRestDay {
            return "moon.zzz.fill"
        }
        
        if setsLogged(for: plan) > 0 {
            return "checkmark.circle.fill"
        }
        
        if !plan.exercises.isEmpty || !plan.muscleGroups.isEmpty {
            return "circle.dotted"
        }
        
        return "plus.circle"
    }
    
    func planStatusText(_ plan: WorkoutDayPlan) -> String {
        if plan.isRestDay {
            return "REST"
        }
        
        if setsLogged(for: plan) > 0 {
            return "LOGGED"
        }
        
        if !plan.exercises.isEmpty || !plan.muscleGroups.isEmpty {
            return "PLANNED"
        }
        
        return "EMPTY"
    }
    
    private func openAIChat(title: String, context: String) {
        aiTitle = title
        aiContext = context
        showAIChat = true
    }
    
    private func workoutAIContext(reason: String) -> String {
        let planSummary = weeklyPlans.map { plan in
            if plan.isRestDay {
                return "\(plan.day): Rest Day"
            }
            
            let exercises = plan.exercises.isEmpty ? "No exercises" : plan.exercises.map { $0.name }.joined(separator: ", ")
            return "\(plan.day): \(plan.title). Exercises: \(exercises). Sets logged: \(setsLogged(for: plan))"
        }.joined(separator: " | ")
        
        return """
        \(reason)
        Planned workout days: \(plannedDaysCount)/7.
        Rest days: \(restDaysCount).
        Completed days with logged sets: \(completedDaysCount).
        Total sets logged: \(totalSetsLogged).
        Weekly plan: \(planSummary)
        Help make the plan more balanced, motivating, and personalized.
        """
    }
}

struct EditWeeklyPlanSheet: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("themeColorName") private var themeColorName = "Gray"
    @Binding var plans: [WorkoutDayPlan]
    
    @State private var selectedDayIndex = 0
    @State private var muscleText = ""
    @State private var exerciseText = ""
    @State private var isRestDay = false
    
    var body: some View {
        VStack(spacing: 18) {
            HStack {
                Text("Edit Plan")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button {
                    saveSelectedDay()
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.headline)
                }
                .buttonStyle(.plain)
            }
            
            HStack {
                Button {
                    moveDayBack()
                } label: {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(plans[selectedDayIndex].day)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(isRestDay ? "Recovery setup" : "Workout setup")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button {
                    moveDayForward()
                } label: {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 6)
            
            Button {
                isRestDay.toggle()
                
                if isRestDay {
                    muscleText = ""
                    exerciseText = ""
                    plans[selectedDayIndex].muscleGroups = []
                    plans[selectedDayIndex].exercises = []
                }
                
                plans[selectedDayIndex].isRestDay = isRestDay
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: isRestDay ? "checkmark.circle.fill" : "moon.zzz")
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Rest Day")
                            .font(.headline)
                        
                        Text("Mark this day for recovery instead of training.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(cardFill(themeColorName))
                .cornerRadius(18)
            }
            .buttonStyle(.plain)
            
            if !isRestDay {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Muscle Groups")
                        .font(.headline)
                    
                    TextField("Example: Chest and Triceps", text: $muscleText)
                        .textFieldStyle(.roundedBorder)
                    
                    Text("This becomes: \(formattedMusclePreview)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Exercises")
                        .font(.headline)
                    
                    HStack {
                        TextField("Add exercise", text: $exerciseText)
                            .textFieldStyle(.roundedBorder)
                        
                        Button {
                            addExercise()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.primary)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    if plans[selectedDayIndex].exercises.isEmpty {
                        Text("No exercises added yet.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(cardFill(themeColorName))
                            .cornerRadius(16)
                    } else {
                        ForEach(plans[selectedDayIndex].exercises) { exercise in
                            HStack {
                                Text(exercise.name)
                                    .font(.headline)
                                
                                Spacer()
                                
                                Button {
                                    removeExercise(exercise)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(.primary)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding()
                            .background(cardFill(themeColorName))
                            .cornerRadius(16)
                        }
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recovery Focus")
                        .font(.headline)
                    
                    Text("Take it easy today. Stretch, walk, hydrate, sleep, or do light mobility work.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(cardFill(themeColorName))
                .cornerRadius(18)
            }
            
            Spacer()
        }
        .padding(.horizontal, 22)
        .padding(.top, 18)
        .background(themeColor(themeColorName).opacity(0.06).ignoresSafeArea())
        .onAppear {
            loadSelectedDay()
        }
    }
    
    var formattedMusclePreview: String {
        let muscles = normalizeMuscleGroups(muscleText)
        return muscles.isEmpty ? "No muscle groups yet" : muscles.joined(separator: " + ")
    }
    
    func moveDayBack() {
        saveSelectedDay()
        selectedDayIndex = selectedDayIndex == 0 ? plans.count - 1 : selectedDayIndex - 1
        loadSelectedDay()
    }
    
    func moveDayForward() {
        saveSelectedDay()
        selectedDayIndex = selectedDayIndex == plans.count - 1 ? 0 : selectedDayIndex + 1
        loadSelectedDay()
    }
    
    func loadSelectedDay() {
        isRestDay = plans[selectedDayIndex].isRestDay
        muscleText = plans[selectedDayIndex].muscleGroups.joined(separator: " + ")
    }
    
    func saveSelectedDay() {
        plans[selectedDayIndex].isRestDay = isRestDay
        
        if isRestDay {
            plans[selectedDayIndex].muscleGroups = []
            plans[selectedDayIndex].exercises = []
        } else {
            plans[selectedDayIndex].muscleGroups = normalizeMuscleGroups(muscleText)
        }
    }
    
    func addExercise() {
        let cleaned = exerciseText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleaned.isEmpty else {
            return
        }
        
        plans[selectedDayIndex].exercises.append(
            WorkoutExercise(name: cleaned)
        )
        
        exerciseText = ""
    }
    
    func removeExercise(_ exercise: WorkoutExercise) {
        plans[selectedDayIndex].exercises.removeAll { $0.id == exercise.id }
    }
    
    func normalizeMuscleGroups(_ input: String) -> [String] {
        input
            .replacingOccurrences(of: " and ", with: ",", options: .caseInsensitive)
            .replacingOccurrences(of: " + ", with: ",")
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { muscle in
                muscle.prefix(1).uppercased() + muscle.dropFirst().lowercased()
            }
    }
}

struct WorkoutDetailView: View {
    @AppStorage("themeColorName") private var themeColorName = "Gray"
    @Binding var plan: WorkoutDayPlan
    
    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(plan.day)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(plan.title)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if plan.isRestDay {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 10) {
                            Image(systemName: "moon.zzz.fill")
                                .font(.title2)
                            
                            Text("Recovery Day")
                                .font(.headline)
                        }
                        
                        Text("No workout needed today. Focus on recovery, hydration, mobility, light walking, and sleep.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(cardFill(themeColorName))
                    .cornerRadius(18)
                } else if plan.exercises.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("No exercises yet")
                            .font(.headline)
                        
                        Text("Use the pencil on the Weekly Plan page to add exercises for this day.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(cardFill(themeColorName))
                    .cornerRadius(18)
                } else {
                    VStack(spacing: 12) {
                        ForEach($plan.exercises) { $exercise in
                            ExerciseRow(exercise: $exercise)
                        }
                    }
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
        .navigationTitle(plan.title)
        .navigationBarTitleDisplayMode(.inline)
        .background(themeColor(themeColorName).opacity(0.06).ignoresSafeArea())
    }
}

struct ExerciseRow: View {
    @AppStorage("themeColorName") private var themeColorName = "Gray"
    @Binding var exercise: WorkoutExercise
    @State private var showAddSet = false
    @State private var showEditExercise = false
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(exercise.name)
                        .font(.headline)
                    
                    if exercise.sets.isEmpty {
                        Text("No sets logged yet")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("\(exercise.sets.count) set(s) logged")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                Button {
                    showEditExercise = true
                } label: {
                    Text("Edit")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(cardFill(themeColorName))
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
            
            ForEach(exercise.sets) { set in
                HStack {
                    Text("\(set.reps) reps")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text(set.weight)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .padding(.top, 4)
            }
            
            Button {
                showAddSet = true
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Log Set")
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(cardFill(themeColorName))
                .cornerRadius(14)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(cardFill(themeColorName))
        .cornerRadius(18)
        .sheet(isPresented: $showAddSet) {
            AddSetSheet(exercise: $exercise)
        }
        .sheet(isPresented: $showEditExercise) {
            EditExerciseSheet(exercise: $exercise)
        }
    }
}

struct EditExerciseSheet: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("themeColorName") private var themeColorName = "Gray"
    @Binding var exercise: WorkoutExercise
    
    @State private var exerciseName = ""
    
    var body: some View {
        VStack(spacing: 18) {
            HStack {
                Text("Edit Exercise")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button {
                    saveChanges()
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.headline)
                }
                .buttonStyle(.plain)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Exercise Name")
                    .font(.headline)
                
                TextField("Exercise name", text: $exerciseName)
                    .textFieldStyle(.roundedBorder)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Logged Sets")
                    .font(.headline)
                
                if exercise.sets.isEmpty {
                    Text("No sets logged yet.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(cardFill(themeColorName))
                        .cornerRadius(16)
                } else {
                    ForEach($exercise.sets) { $set in
                        VStack(spacing: 10) {
                            HStack {
                                TextField("Reps", text: $set.reps)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(.roundedBorder)
                                
                                TextField("Weight", text: $set.weight)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.roundedBorder)
                                
                                Button {
                                    removeSet(set)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(.primary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                        .background(cardFill(themeColorName))
                        .cornerRadius(16)
                    }
                }
            }
            
            Spacer()
        }
        .padding(22)
        .background(themeColor(themeColorName).opacity(0.06).ignoresSafeArea())
        .onAppear {
            exerciseName = exercise.name
        }
    }
    
    func saveChanges() {
        let cleanedName = exerciseName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !cleanedName.isEmpty {
            exercise.name = cleanedName
        }
    }
    
    func removeSet(_ set: ExerciseSet) {
        exercise.sets.removeAll { $0.id == set.id }
    }
}

struct AddSetSheet: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("themeColorName") private var themeColorName = "Gray"
    @Binding var exercise: WorkoutExercise
    
    @State private var reps = ""
    @State private var weight = ""
    @State private var weightUnit = "lb"
    
    let units = ["lb", "kg"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                Text(exercise.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Reps")
                        .font(.headline)
                    
                    TextField("Example: 8", text: $reps)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Weight")
                        .font(.headline)
                    
                    HStack {
                        TextField("Example: 95", text: $weight)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                        
                        Picker("Unit", selection: $weightUnit) {
                            ForEach(units, id: \.self) { unit in
                                Text(unit)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 110)
                    }
                }
                
                Button {
                    addSet()
                } label: {
                    Text("Add Set")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(cardFill(themeColorName))
                        .cornerRadius(16)
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
            .padding(22)
            .background(themeColor(themeColorName).opacity(0.06).ignoresSafeArea())
            .navigationTitle("Log Set")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func addSet() {
        let cleanedReps = reps.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedWeight = weight.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanedReps.isEmpty || !cleanedWeight.isEmpty else {
            return
        }
        
        exercise.sets.append(
            ExerciseSet(
                reps: cleanedReps.isEmpty ? "0" : cleanedReps,
                weight: cleanedWeight.isEmpty ? "0 \(weightUnit)" : "\(cleanedWeight) \(weightUnit)"
            )
        )
        
        dismiss()
    }
}

struct WorkoutDayPlan: Identifiable, Hashable {
    var id: String { day }
    var day: String
    var muscleGroups: [String]
    var exercises: [WorkoutExercise]
    var isRestDay: Bool = false
    
    var title: String {
        if isRestDay {
            return "Rest Day"
        }
        
        return muscleGroups.isEmpty ? "No workout set" : muscleGroups.joined(separator: " + ")
    }
    
    var details: String {
        if isRestDay {
            return "Recovery, mobility, stretching, or light walking"
        }
        
        return exercises.isEmpty ? "Tap to view or edit exercises" : exercises.map { $0.name }.joined(separator: ", ")
    }
    
    static let emptyWeek: [WorkoutDayPlan] = [
        WorkoutDayPlan(day: "Monday", muscleGroups: [], exercises: []),
        WorkoutDayPlan(day: "Tuesday", muscleGroups: [], exercises: []),
        WorkoutDayPlan(day: "Wednesday", muscleGroups: [], exercises: []),
        WorkoutDayPlan(day: "Thursday", muscleGroups: [], exercises: []),
        WorkoutDayPlan(day: "Friday", muscleGroups: [], exercises: []),
        WorkoutDayPlan(day: "Saturday", muscleGroups: [], exercises: []),
        WorkoutDayPlan(day: "Sunday", muscleGroups: [], exercises: [])
    ]
}

struct WorkoutExercise: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var sets: [ExerciseSet] = []
}

struct ExerciseSet: Identifiable, Hashable {
    var id = UUID()
    var reps: String
    var weight: String
}

struct WorkoutLogEntry: Identifiable {
    var id = UUID()
    var day: String
    var exercise: String
    var reps: String
    var weight: String
}

#Preview {
    NavigationStack {
        WorkoutsView()
    }
}
