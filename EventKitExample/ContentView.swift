//
//  ContentView.swift
//  EventKitExample
//
//  Created by yjc on 10/1/24.
//

import SwiftUI
import EventKit

struct ContentView: View {
    private let repository = CalendarEventRepository()
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(60 * 30)
    @State private var id = ""
    @State private var title = ""
    @State private var memo = ""
    @State private var showEventEdit = false
    
    var body: some View {
        List {
            DatePicker("date", selection: $startDate)
            DatePicker("date", selection: $endDate)
            TextField("id", text: $id)
            TextField("title", text: $title)
            TextField("memo", text: $memo)
            Button("Save") {
                Task {
                    await save()
                    startDate = Date()
                    endDate = Date().addingTimeInterval(60 * 30)
                    id = ""
                    title = ""
                    memo = ""
                }
            }
            Button("Remove") {
                Task {
                    await remove()
                }
            }
        }
    }
    
    private func save() async {
        do {
            let event = EKEvent(eventStore: repository.eventStore)
            event.title = title
            event.startDate = startDate
            event.endDate = endDate
            event.calendar = repository.eventStore.defaultCalendarForNewEvents
            event.url = URL(string: "https://\(id)")
            event.notes = memo
            try await repository.addEvent(event)
        } catch {
            print(error)
        }
    }
    
    private func remove() async {
        do {
            guard let target = try await repository.fetchEvent(identifier: id) else { return }
        } catch {
            print(error)
        }
    }
}

#Preview {
    ContentView()
}
