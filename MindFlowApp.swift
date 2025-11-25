//
//  MindFlowApp.swift
//  MindFlow
//
//  Created by Charaka Ilangarathne on 2025-11-25.
//

import SwiftUI

@main
struct MindFlowApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
