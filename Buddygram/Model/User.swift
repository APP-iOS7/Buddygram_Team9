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
    let id: String  // Firebase Auth UID
    var username: String
    var email: String
    var fullName: String?
    var profileImageURL: String?
    var bio: String?
    var joinDate: Date
    var postsCount: Int
    var followersCount: Int
    var followingCount: Int
    var likedPosts: [String]  // 좋아요한 게시물 ID 목록
}
