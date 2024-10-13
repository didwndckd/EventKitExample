//
//  CalendarEventUseCase.swift
//  EventKitExample
//
//  Created by yjc on 10/12/24.
//

import Foundation
import Combine
import EventKit

protocol CalendarEventUseCase {
    func syncEvent(existingEvent: CalendarEvent?, newEvent: CalendarEvent) async throws -> Void
}

extension CalendarEventUseCase {
    func syncEvent(newEvent: CalendarEvent) async throws {
        try await syncEvent(existingEvent: nil, newEvent: newEvent)
    }
}

final class DefaultCalendarEventUseCase {
    private let repository: CalendarEventRepository
    init(repository: CalendarEventRepository) {
        self.repository = repository
    }
}

extension DefaultCalendarEventUseCase: CalendarEventUseCase {
    func syncEvent(existingEvent: CalendarEvent?, newEvent: CalendarEvent) async throws {
        guard try await repository.verifyFullAccessAuthorization() else { return }
        
        if let existing = repository.fetchEvent(existingEvent ?? newEvent) {
            try repository.updateEvent(target: existing, newEvent: newEvent)
        } else {
            try repository.createEvent(newEvent)
        }
    }
}
