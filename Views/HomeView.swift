//
//  HomeView.swift
//  MindFlow
//
//  Created by Charaka Ilangarathne on 2025-11-25.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MoodEntry.date, ascending: false)],
        animation: .spring(response: 0.4, dampingFraction: 0.8))
    private var entries: FetchedResults<MoodEntry>
    
    @State private var showAddEntry = false
    @State private var appearAnimation = false
    
    // Time-based greeting
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Good morning"
        case 12..<17:
            return "Good afternoon"
        case 17..<21:
            return "Good evening"
        default:
            return "Good night"
        }
    }
    
    // Greeting emoji based on time
    private var greetingEmoji: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "☀️"
        case 12..<17:
            return "🌤️"
        case 17..<21:
            return "🌅"
        default:
            return "🌙"
        }
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.darkBg
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Content
                ScrollView {
                    VStack(spacing: 20) {
                        // Greeting Card
                        greetingCard
                            .opacity(appearAnimation ? 1 : 0)
                            .offset(y: appearAnimation ? 0 : 20)
                        
                        // Recent Entries Section
                        if entries.isEmpty {
                            emptyStateView
                                .opacity(appearAnimation ? 1 : 0)
                                .scaleEffect(appearAnimation ? 1 : 0.9)
                        } else {
                            recentEntriesSection
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 100) // Space for FAB
                }
            }
            
            // Floating Action Button
            floatingActionButton
                .opacity(appearAnimation ? 1 : 0)
                .scaleEffect(appearAnimation ? 1 : 0.5)
        }
        .sheet(isPresented: $showAddEntry) {
            AddEntryView()
                .environment(\.managedObjectContext, viewContext)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                appearAnimation = true
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("MindFlow")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color.primaryOrange)
            }
            Spacer()
            
            // Profile icon placeholder
            Circle()
                .fill(Color.cardBg)
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray)
                )
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
    
    // MARK: - Greeting Card
    private var greetingCard: some View {
        HStack(spacing: 16) {
            Text(greetingEmoji)
                .font(.system(size: 44))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("How are you feeling today?")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.cardBg)
        )
    }
    
    // MARK: - Recent Entries Section
    private var recentEntriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Entries")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(entries.count) total")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .opacity(appearAnimation ? 1 : 0)
            
            LazyVStack(spacing: 12) {
                ForEach(Array(entries.prefix(10).enumerated()), id: \.element) { index, entry in
                    MoodEntryCard(entry: entry)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 30)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.8)
                            .delay(Double(index) * 0.05),
                            value: appearAnimation
                        )
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.9).combined(with: .opacity),
                            removal: .scale(scale: 0.9).combined(with: .opacity)
                        ))
                }
            }
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 60)
            
            Image(systemName: "leaf.fill")
                .font(.system(size: 64))
                .foregroundColor(Color.primaryOrange.opacity(0.6))
                .symbolEffect(.pulse, options: .repeating)
            
            Text("No entries yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("Start tracking your mood by\ntapping the + button below")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // MARK: - Floating Action Button
    private var floatingActionButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showAddEntry = true
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(Color.primaryOrange)
                        )
                        .shadow(color: Color.primaryOrange.opacity(0.5), radius: 12, x: 0, y: 6)
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.trailing, 24)
                .padding(.bottom, 24)
            }
        }
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Mood Entry Card
struct MoodEntryCard: View {
    let entry: MoodEntry
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Emoji
            Text(entry.moodEmoji ?? "😊")
                .font(.system(size: 36))
                .frame(width: 50, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.mediumGray)
                )
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                // Date
                Text(formattedDate)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                // Text preview
                if let text = entry.moodText, !text.isEmpty {
                    Text(text)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            // Sentiment indicator
            sentimentIndicator
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.cardBg)
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .contextMenu {
            Button(role: .destructive) {
                deleteEntry()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                deleteEntry()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    // Format date nicely
    private var formattedDate: String {
        guard let date = entry.date else { return "Unknown date" }
        
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return "Today, \(formatter.string(from: date))"
        } else if calendar.isDateInYesterday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return "Yesterday, \(formatter.string(from: date))"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, h:mm a"
            return formatter.string(from: date)
        }
    }
    
    // Sentiment color indicator
    private var sentimentIndicator: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(sentimentColor)
                .frame(width: 12, height: 12)
            
            Text(sentimentLabel)
                .font(.system(size: 10))
                .foregroundColor(.gray)
        }
    }
    
    private var sentimentColor: Color {
        let score = entry.sentimentScore
        switch score {
        case 0.3...1.0:
            return Color.green
        case 0.0..<0.3:
            return Color.yellow
        case -0.3..<0.0:
            return Color.orange
        default:
            return Color.red
        }
    }
    
    private var sentimentLabel: String {
        let score = entry.sentimentScore
        switch score {
        case 0.3...1.0:
            return "Good"
        case 0.0..<0.3:
            return "Okay"
        case -0.3..<0.0:
            return "Low"
        default:
            return "Bad"
        }
    }
    
    private func deleteEntry() {
        // Haptic feedback
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.warning)
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            viewContext.delete(entry)
            do {
                try viewContext.save()
            } catch {
                print("Error deleting entry: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
