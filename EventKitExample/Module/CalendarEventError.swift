//
//  CalendarEventError.swift
//  EventKitExample
//
//  Created by yjc on 10/10/24.
//

import Foundation

enum CalendarEventError: Error {
    case denied
    case restricted
    case unknown
    case upgrade
}

extension CalendarEventError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .denied:
            return "권한 없음"
        case .restricted:
            return "캘린더 액세스 불가"
        case .unknown:
            return "알수없음"
        case .upgrade:
            return "쓰기 전용 권한임 전체 권한 부여 바람"
        }
    }
}
