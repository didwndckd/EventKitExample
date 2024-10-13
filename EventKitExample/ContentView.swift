//
//  ContentView.swift
//  EventKitExample
//
//  Created by yjc on 10/1/24.
//

import SwiftUI
import EventKit

struct ContentView: View {
    private let useCase = DefaultCalendarEventUseCase(repository: .init(eventStore: .init()))
    @State private var existing: CalendarEvent?
    
    @State private var startDate = Date()
    @State private var id = ""
    @State private var title = ""
    @State private var memo = ""
    @State private var showEventEdit = false
    
    var body: some View {
        List {
            DatePicker("date", selection: $startDate)
            TextField("id", text: $id)
            TextField("title", text: $title)
            TextField("memo", text: $memo)
            Button("Sync") {
                Task {
                    do {
                        try await sync()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    private func sync() async throws {
        let event = AnyCalendarEvent(
            title: title,
            startDate: startDate,
            endDate: startDate.addingTimeInterval(60 * 30),
            memo: memo,
            url: URL(string: "http://\(id)")
        )
        
        if existing?.url == event.url {
            try await useCase.syncEvent(existingEvent: existing, newEvent: event)
        } else {
            try await useCase.syncEvent(newEvent: event)
        }
        existing = event
    }
}

#Preview {
    ContentView()
}
