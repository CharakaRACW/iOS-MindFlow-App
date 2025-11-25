//
//  AnalyticsView.swift
//  MindFlow
//
//  Created by Charaka Ilangarathne on 2025-11-25.
//

import SwiftUI
import Charts

struct AnalyticsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MoodEntry.date, ascending: true)],
        animation: .spring(response: 0.4, dampingFraction: 0.8))
    private var entries: FetchedResults<MoodEntry>
    
    @State private var appearAnimation = false
    @State private var chartAnimation = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.darkBg
                    .ignoresSafeArea()
                
                if entries.isEmpty {
                    emptyStateView
                        .opacity(appearAnimation ? 1 : 0)
                        .scaleEffect(appearAnimation ? 1 : 0.9)
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Stats Summary
                            statsSummaryCard
                                .opacity(appearAnimation ? 1 : 0)
                                .offset(y: appearAnimation ? 0 : 20)
                            
                            // Weekly Mood Trend Chart
                            weeklyTrendCard
                                .opacity(appearAnimation ? 1 : 0)
                                .offset(y: appearAnimation ? 0 : 30)
                            
                            // Mood Distribution
                            moodDistributionCard
                                .opacity(appearAnimation ? 1 : 0)
                                .offset(y: appearAnimation ? 0 : 40)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.darkBg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                appearAnimation = true
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.4)) {
                chartAnimation = true
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 64))
                .foregroundColor(Color.primaryOrange.opacity(0.6))
                .symbolEffect(.pulse, options: .repeating)
            
            Text("No Data Yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("Start logging your mood to see\ninsights and trends here")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Stats Summary Card
    private var statsSummaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overview")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                StatBox(
                    title: "Total Entries",
                    value: "\(entries.count)",
                    icon: "list.bullet.clipboard"
                )
                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1), value: appearAnimation)
                
                StatBox(
                    title: "This Week",
                    value: "\(entriesThisWeek)",
                    icon: "calendar"
                )
                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.15), value: appearAnimation)
                
                StatBox(
                    title: "Avg Mood",
                    value: String(format: "%.1f", averageSentiment),
                    icon: "heart.fill"
                )
                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2), value: appearAnimation)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cardBg)
        )
    }
    
    // MARK: - Weekly Trend Card
    private var weeklyTrendCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Weekly Trend")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("Last 7 days")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            if weeklyData.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.xyaxis.line")
                        .font(.system(size: 32))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("Not enough data for chart")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
            } else {
                Chart {
                    ForEach(weeklyData, id: \.date) { dataPoint in
                        LineMark(
                            x: .value("Date", dataPoint.date, unit: .day),
                            y: .value("Sentiment", chartAnimation ? dataPoint.averageSentiment : 0)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.primaryOrange, Color.lightOrange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                        
                        AreaMark(
                            x: .value("Date", dataPoint.date, unit: .day),
                            y: .value("Sentiment", chartAnimation ? dataPoint.averageSentiment : 0)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.primaryOrange.opacity(0.3), Color.primaryOrange.opacity(0.0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        
                        PointMark(
                            x: .value("Date", dataPoint.date, unit: .day),
                            y: .value("Sentiment", chartAnimation ? dataPoint.averageSentiment : 0)
                        )
                        .foregroundStyle(Color.primaryOrange)
                        .symbolSize(chartAnimation ? 50 : 0)
                    }
                }
                .chartYScale(domain: -1...1)
                .chartYAxis {
                    AxisMarks(position: .leading, values: [-1, -0.5, 0, 0.5, 1]) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [5]))
                            .foregroundStyle(Color.mediumGray)
                        AxisValueLabel()
                            .foregroundStyle(Color.gray)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [5]))
                            .foregroundStyle(Color.mediumGray)
                        AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                            .foregroundStyle(Color.gray)
                    }
                }
                .chartPlotStyle { plotArea in
                    plotArea
                        .background(Color.darkBg.opacity(0.5))
                }
                .frame(height: 200)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cardBg)
        )
    }
    
    // MARK: - Mood Distribution Card
    private var moodDistributionCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Mood Distribution")
                .font(.headline)
                .foregroundColor(.white)
            
            if moodCounts.isEmpty {
                Text("No mood data available")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(moodCounts.sorted(by: { $0.value > $1.value }).enumerated()), id: \.element.key) { index, item in
                        MoodDistributionRow(
                            emoji: item.key,
                            count: item.value,
                            total: entries.count,
                            animated: chartAnimation
                        )
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.1),
                            value: chartAnimation
                        )
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cardBg)
        )
    }
    
    // MARK: - Computed Properties
    
    /// Calculate entries from this week
    private var entriesThisWeek: Int {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return entries.filter { ($0.date ?? Date()) >= weekAgo }.count
    }
    
    /// Calculate average sentiment score
    private var averageSentiment: Double {
        guard !entries.isEmpty else { return 0.0 }
        let total = entries.reduce(0.0) { $0 + $1.sentimentScore }
        return total / Double(entries.count)
    }
    
    /// Get weekly data points for chart
    private var weeklyData: [DailyMoodData] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Get last 7 days
        var dailyData: [DailyMoodData] = []
        
        for dayOffset in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            
            // Filter entries for this day
            let dayEntries = entries.filter { entry in
                guard let entryDate = entry.date else { return false }
                return calendar.isDate(entryDate, inSameDayAs: date)
            }
            
            // Calculate average sentiment for the day
            if !dayEntries.isEmpty {
                let avgSentiment = dayEntries.reduce(0.0) { $0 + $1.sentimentScore } / Double(dayEntries.count)
                dailyData.append(DailyMoodData(date: date, averageSentiment: avgSentiment, entryCount: dayEntries.count))
            } else {
                // Include days with no entries as nil/zero for continuity
                dailyData.append(DailyMoodData(date: date, averageSentiment: 0, entryCount: 0))
            }
        }
        
        // Filter out days with no entries for cleaner chart
        return dailyData.filter { $0.entryCount > 0 }
    }
    
    /// Count occurrences of each mood emoji
    private var moodCounts: [String: Int] {
        var counts: [String: Int] = [:]
        for entry in entries {
            if let emoji = entry.moodEmoji {
                counts[emoji, default: 0] += 1
            }
        }
        return counts
    }
}

// MARK: - Data Models

struct DailyMoodData {
    let date: Date
    let averageSentiment: Double
    let entryCount: Int
}

// MARK: - Supporting Views

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Color.primaryOrange)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.primaryOrange)
                .contentTransition(.numericText())
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.mediumGray.opacity(0.5))
        )
    }
}

struct MoodDistributionRow: View {
    let emoji: String
    let count: Int
    let total: Int
    let animated: Bool
    
    private var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(count) / Double(total)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Emoji
            Text(emoji)
                .font(.title2)
                .frame(width: 40)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.mediumGray)
                        .frame(height: 12)
                    
                    // Fill with animation
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [Color.primaryOrange, Color.lightOrange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: animated ? geometry.size.width * percentage : 0, height: 12)
                }
            }
            .frame(height: 12)
            
            // Count and percentage
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(count)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.primaryOrange)
                    .contentTransition(.numericText())
                
                Text("\(Int(percentage * 100))%")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .frame(width: 44)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    AnalyticsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
