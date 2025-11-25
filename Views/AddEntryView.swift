//
//  AddEntryView.swift
//  MindFlow
//
//  Created by Charaka Ilangarathne on 2025-11-25.
//

import SwiftUI
import CoreData

struct AddEntryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    // State variables
    @State private var selectedMood: String? = nil
    @State private var moodText: String = ""
    @State private var appearAnimation = false
    @State private var isSaving = false
    
    // Available moods
    private let moods: [(emoji: String, label: String)] = [
        ("😢", "Sad"),
        ("😟", "Anxious"),
        ("😐", "Neutral"),
        ("🙂", "Good"),
        ("😄", "Great")
    ]
    
    // Check if form is valid
    private var isFormValid: Bool {
        selectedMood != nil && !isSaving
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.darkBg
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Mood Question
                    VStack(spacing: 8) {
                        Text("How are you feeling?")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text("Select your current mood")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : -20)
                    
                    // Mood Selector
                    moodSelector
                        .opacity(appearAnimation ? 1 : 0)
                        .scaleEffect(appearAnimation ? 1 : 0.8)
                    
                    // Notes Section
                    notesSection
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 20)
                    
                    Spacer()
                    
                    // Save Button
                    saveButton
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 30)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        // Haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body.weight(.medium))
                            .foregroundColor(.gray)
                            .frame(width: 32, height: 32)
                            .background(Color.cardBg)
                            .clipShape(Circle())
                    }
                }
            }
            .toolbarBackground(Color.darkBg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .presentationDragIndicator(.visible)
        .presentationDetents([.large])
        .presentationBackground(Color.darkBg)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                appearAnimation = true
            }
        }
    }
    
    // MARK: - Mood Selector
    private var moodSelector: some View {
        HStack(spacing: 12) {
            ForEach(Array(moods.enumerated()), id: \.element.emoji) { index, mood in
                moodButton(emoji: mood.emoji, label: mood.label, index: index)
            }
        }
        .padding(.horizontal, 8)
    }
    
    private func moodButton(emoji: String, label: String, index: Int) -> some View {
        Button {
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                selectedMood = emoji
            }
        } label: {
            VStack(spacing: 8) {
                Text(emoji)
                    .font(.system(size: 36))
                    .frame(width: 56, height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedMood == emoji ? Color.primaryOrange : Color.cardBg)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selectedMood == emoji ? Color.primaryOrange : Color.clear, lineWidth: 2)
                    )
                    .scaleEffect(selectedMood == emoji ? 1.15 : 1.0)
                    .shadow(color: selectedMood == emoji ? Color.primaryOrange.opacity(0.4) : .clear, radius: 8, x: 0, y: 4)
                
                Text(label)
                    .font(.caption)
                    .fontWeight(selectedMood == emoji ? .semibold : .regular)
                    .foregroundColor(selectedMood == emoji ? Color.primaryOrange : .gray)
            }
        }
        .buttonStyle(.plain)
        .opacity(appearAnimation ? 1 : 0)
        .offset(y: appearAnimation ? 0 : 20)
        .animation(
            .spring(response: 0.4, dampingFraction: 0.7).delay(Double(index) * 0.05),
            value: appearAnimation
        )
    }
    
    // MARK: - Notes Section
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Notes")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("(optional)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            ZStack(alignment: .topLeading) {
                // Placeholder
                if moodText.isEmpty {
                    Text("What's on your mind?")
                        .foregroundColor(.gray.opacity(0.6))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                }
                
                TextEditor(text: $moodText)
                    .scrollContentBackground(.hidden)
                    .foregroundColor(.white)
                    .padding(12)
                    .frame(minHeight: 140, maxHeight: 180)
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.cardBg)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.mediumGray, lineWidth: 1)
            )
        }
    }
    
    // MARK: - Save Button
    private var saveButton: some View {
        Button {
            saveEntry()
        } label: {
            HStack(spacing: 8) {
                if isSaving {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.body.weight(.semibold))
                }
                
                Text(isSaving ? "Saving..." : "Save Entry")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isFormValid ? Color.primaryOrange : Color.mediumGray)
            )
            .shadow(color: isFormValid ? Color.primaryOrange.opacity(0.4) : .clear, radius: 8, x: 0, y: 4)
        }
        .disabled(!isFormValid)
        .buttonStyle(ScaleButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFormValid)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSaving)
    }
    
    // MARK: - Save Function
    private func saveEntry() {
        guard let selectedMood = selectedMood else { return }
        
        isSaving = true
        
        // Haptic feedback - success
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        
        // Small delay for visual feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Create new MoodEntry
            let newEntry = MoodEntry(context: viewContext)
            newEntry.id = UUID()
            newEntry.date = Date()
            newEntry.moodEmoji = selectedMood
            newEntry.moodText = moodText.isEmpty ? nil : moodText.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Analyze sentiment of the text
            if !moodText.isEmpty {
                newEntry.sentimentScore = SentimentAnalyzer.analyze(text: moodText)
            } else {
                // Default sentiment based on mood emoji
                newEntry.sentimentScore = sentimentFromMood(selectedMood)
            }
            
            // Save to Core Data
            do {
                try viewContext.save()
                
                // Second haptic for confirmation
                let successFeedback = UINotificationFeedbackGenerator()
                successFeedback.notificationOccurred(.success)
                
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    dismiss()
                }
            } catch {
                print("Error saving entry: \(error.localizedDescription)")
                isSaving = false
                
                // Error haptic
                let errorFeedback = UINotificationFeedbackGenerator()
                errorFeedback.notificationOccurred(.error)
            }
        }
    }
    
    // Map mood emoji to default sentiment score
    private func sentimentFromMood(_ emoji: String) -> Double {
        switch emoji {
        case "😄":
            return 0.8
        case "🙂":
            return 0.4
        case "😐":
            return 0.0
        case "😟":
            return -0.4
        case "😢":
            return -0.8
        default:
            return 0.0
        }
    }
}

#Preview {
    AddEntryView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
