//
//  ContentView.swift
//  PhotoSense
//
//  Created by Charaka Ilangarathne on 2025-11-26.
//

import SwiftUI
import CoreData

struct ContentView: View {
    // TODO: Remove this wrapper if you no longer need ContentView.
    var body: some View {
        HomeView()
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
