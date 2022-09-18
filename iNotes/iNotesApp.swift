//
//  iNotesApp.swift
//  iNotes
//
//  Created by Amrith on 17/09/22.
//

import SwiftUI

@main
struct iNotesApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
