//
//  CalendarEventRepository.swift
//  EventKitExample
//
//  Created by yjc on 10/10/24.
//

import Foundation
import EventKit

final class CalendarEventRepository {
    let eventStore = EKEventStore()
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
    
    private func requestWriteOnlyAccess() async throws -> Bool {
        if #available(iOS 17.0, *) {
            return try await eventStore.requestWriteOnlyAccessToEvents()
        } else {
            return try await eventStore.requestAccess(to: .event)
        }
    }
    
    private func verifyFullAccessAuthorization() async throws -> Bool {
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
    
    private func verifyWriteOnlyAccessAuthorization() async throws -> Bool {
        let status = EKEventStore.authorizationStatus(for: .event)
        switch status {
        case .notDetermined:
            return try await requestWriteOnlyAccess()
        case .restricted:
            throw CalendarEventError.restricted
        case .denied:
            throw CalendarEventError.denied
        case .fullAccess, .writeOnly:
            return true
        @unknown default:
            throw CalendarEventError.unknown
        }
    }
}

extension CalendarEventRepository {
    func fetchEvent(identifier: String) async throws -> EKEvent? {
        guard try await verifyFullAccessAuthorization() else { return nil }
        return eventStore.event(withIdentifier: identifier)
    }
    
    func fetchEvents(in dateRange: DateInterval) async throws -> [EKEvent] {
        guard try await verifyFullAccessAuthorization() else { return [] }
        let predicate = eventStore.predicateForEvents(withStart: dateRange.start, end: dateRange.end, calendars: nil)
        return eventStore.events(matching: predicate)
    }
    
    func addEvent(_ event: EKEvent) async throws {
        guard try await verifyWriteOnlyAccessAuthorization() else { return }
        try eventStore.save(event, span: .futureEvents)
    }
    
    func removeEvent(_ event: EKEvent) async throws {
        guard try await verifyFullAccessAuthorization() else { return }
        try eventStore.remove(event, span: .thisEvent)
    }
}
