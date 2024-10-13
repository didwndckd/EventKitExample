//
//  CalendarEventRepository.swift
//  EventKitExample
//
//  Created by yjc on 10/10/24.
//

import Foundation
import EventKit

final class CalendarEventRepository {
    private let eventStore: EKEventStore
    init(eventStore: EKEventStore) {
        self.eventStore = eventStore
    }
}

// MARK: - 권한
extension CalendarEventRepository {
    private func requestFullAccess() async throws -> Bool {
        if #available(iOS 17.0, *) {
            return try await eventStore.requestFullAccessToEvents()
        } else {
            return try await eventStore.requestAccess(to: .event)
        }
    }
    
    func verifyFullAccessAuthorization() async throws -> Bool {
        let status = EKEventStore.authorizationStatus(for: .event)
        switch status {
        case .notDetermined:
            return try await requestFullAccess()
        case .restricted:
            throw CalendarEventError.restricted
        case .denied:
            throw CalendarEventError.denied
        case .fullAccess:
            return true
        case .writeOnly:
            throw CalendarEventError.upgrade
        @unknown default:
            throw CalendarEventError.unknown
        }
    }
}

// MARK: - CRUD
extension CalendarEventRepository {
    func fetchEvent(_ event: CalendarEvent) -> EKEvent? {
        guard let url = event.url else { return nil }
        let predicate = eventStore.predicateForEvents(withStart: event.startDate, end: event.endDate, calendars: nil)
        let events = eventStore.events(matching: predicate)
        return events.first(where: { $0.url == url })
    }
    
    func createEvent(_ event: CalendarEvent) throws {
        let calendarEvent = EKEvent(eventStore: eventStore)
        calendarEvent.title = event.title
        calendarEvent.startDate = event.startDate
        calendarEvent.endDate = event.endDate
        calendarEvent.url = event.url
        calendarEvent.notes = event.memo
        calendarEvent.calendar = eventStore.defaultCalendarForNewEvents
//        let alarm = EKAlarm(relativeOffset: -60)
//        calendarEvent.addAlarm(alarm)
        try eventStore.save(calendarEvent, span: .thisEvent)
    }
    
    func updateEvent(target: EKEvent, newEvent: CalendarEvent) throws {
        target.title = newEvent.title
        target.startDate = newEvent.startDate
        target.endDate = newEvent.endDate
        target.url = newEvent.url
        target.notes = newEvent.memo
        try eventStore.save(target, span: .futureEvents)
    }
}

extension CalendarEventRepository {}
