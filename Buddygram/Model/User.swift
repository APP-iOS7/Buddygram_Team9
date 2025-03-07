//
//  User.swift
//  Buddygram
//
//  Created by KimJunsoo on 3/6/25.
//

import Foundation
import SwiftUI
import Combine
import Firebase

struct User: Identifiable, Codable {
    var id: String
    var username: String
    var email: String
    var profileImageURL: String?
    var createdAt: Date
    var likedPostIDs: [String] = []
    var password: String // 로컬 테스트용, Firebase 사용 시 제거
}
