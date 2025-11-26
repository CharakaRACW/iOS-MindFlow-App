//
//  PhotoSenseApp.swift
//  PhotoSense
//
//  Created by Charaka Ilangarathne on 2025-11-26.
//

import SwiftUI
import CoreData

@main
struct PhotoSenseApp: App {
    let persistenceController = PersistenceController.shared

    @Environment(\.scenePhase) private var scenePhase
    @State private var showSplash: Bool = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                MainTabView()
                    .opacity(showSplash ? 0 : 1)

                if showSplash {
                    SplashView()
                        .transition(.opacity)
                }
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .tint(DesignSystem.Colors.primaryStart)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation(.easeInOut) {
                        showSplash = false
                    }
                }
            }
            .onChange(of: scenePhase) { newPhase in
                switch newPhase {
                case .background:
                    saveContext()
                default:
                    break
                }
            }
        }
    }

    private func saveContext() {
        let context = persistenceController.container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // In a production app, log this error.
            }
        }
    }
}
