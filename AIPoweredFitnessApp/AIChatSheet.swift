//
//  AIChatSheet.swift
//  AIPoweredFitnessApp
//
//  Created by kyle cahill on 2026-06-29.
//


import SwiftUI

struct AIChatSheet: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("themeColorName") private var themeColorName = "Gray"
    
    let title: String
    let context: String
    
    @State private var messageText = ""
    @State private var messages: [AIChatMessage] = []
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        AIContextCard(title: title, context: context)
                        
                        ForEach(messages) { message in
                            AIMessageBubble(message: message)
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 16)
                    .padding(.bottom, 12)
                }
                
                HStack(spacing: 10) {
                    TextField("Ask AI...", text: $messageText, axis: .vertical)
                        .lineLimit(1...4)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 11)
                        .background(cardFill(themeColorName))
                        .cornerRadius(18)
                    
                    Button {
                        sendMessage()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                    }
                    .buttonStyle(.plain)
                    .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.4 : 1)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
            }
            .background(themeColor(themeColorName).opacity(0.06).ignoresSafeArea())
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if messages.isEmpty {
                    messages = [
                        AIChatMessage(
                            text: starterResponse,
                            isUser: false
                        )
                    ]
                }
            }
            .presentationDetents([.fraction(0.55), .large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(28)
        }
    }
    
    private var starterResponse: String {
        "AI Coach Preview is ready. Ask a fitness, calorie, workout, or muscle question and I’ll show how the assistant will respond once real AI is enabled."
    }
    
    private func sendMessage() {
        let cleanedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedMessage.isEmpty else { return }
        
        messages.append(AIChatMessage(text: cleanedMessage, isUser: true))
        messageText = ""
        
        messages.append(
            AIChatMessage(
                text: previewResponse(for: cleanedMessage),
                isUser: false
            )
        )
    }
    
    private func previewResponse(for message: String) -> String {
        let lowercasedMessage = message.lowercased()
        let lowercasedContext = context.lowercased()
        
        if lowercasedContext.contains("calorie") || lowercasedMessage.contains("calorie") || lowercasedMessage.contains("protein") || lowercasedMessage.contains("food") {
            return "AI Coach Preview: I’d help estimate calories/macros from your food, compare it to your daily goals, and suggest what to eat next. Real AI responses can be enabled later."
        }
        
        if lowercasedContext.contains("quadriceps") || lowercasedMessage.contains("quad") {
            return "AI Coach Preview: For quadriceps, I’d suggest movements like squats, lunges, leg press, or leg extensions, plus recovery tips based on soreness and training volume."
        }
        
        if lowercasedContext.contains("biceps") || lowercasedMessage.contains("bicep") {
            return "AI Coach Preview: For biceps, I’d suggest curls, hammer curls, controlled tempo, and enough rest between sessions for recovery."
        }
        
        if lowercasedContext.contains("workout") || lowercasedMessage.contains("workout") || lowercasedMessage.contains("exercise") {
            return "AI Coach Preview: I’d help build or adjust a workout plan using your goals, selected muscles, and logged progress. Real AI can be connected later."
        }
        
        return "AI Coach Preview: This is where a personalized AI response would appear. For now, the app is showing a realistic demo response without using paid API credits."
    }
}

struct AIChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

struct AIContextCard: View {
    let title: String
    let context: String
    @AppStorage("themeColorName") private var themeColorName = "Gray"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                Text(title)
                    .fontWeight(.semibold)
            }
            .font(.headline)
            
            Text(context)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(cardFill(themeColorName))
        .cornerRadius(18)
    }
}

struct AIMessageBubble: View {
    let message: AIChatMessage
    @AppStorage("themeColorName") private var themeColorName = "Gray"
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer(minLength: 40)
            }
            
            Text(message.text)
                .font(.subheadline)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(message.isUser ? cardFill(themeColorName) : Color(.systemBackground).opacity(0.85))
                .cornerRadius(18)
            
            if !message.isUser {
                Spacer(minLength: 40)
            }
        }
    }
}

#Preview {
    AIChatSheet(
        title: "Ask AI",
        context: "The user tapped Quadriceps. Explain workouts, recovery, and form tips."
    )
}
