//
//  CalendarEvent.swift
//  EventKitExample
//
//  Created by yjc on 10/12/24.
//

import Foundation

protocol CalendarEvent {
    var title: String { get }
    var startDate: Date { get }
    var endDate: Date { get }
    var memo: String { get }
    var url: URL? { get }
}

struct AnyCalendarEvent: CalendarEvent {
    let title: String
    let startDate: Date
    let endDate: Date
    let memo: String
    let url: URL?
}
