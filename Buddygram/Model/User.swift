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
    let id: String  // 사용자의 고유 ID (Firebase Auth UID)
    var username: String // 사용자의 이름
    var email: String // 이메일 주소
    var fullName: String? // 전체 이름 (옵셔널)
    var profileImageURL: String? // 프로필 이미지 URL (옵셔널)
    var bio: String? // 사용자 소개 (옵셔널)
    var joinDate: Date // 가입 날짜
    var postsCount: Int // 사용자가 작성한 게시물의 수
    var followersCount: Int // 팔로워 수
    var followingCount: Int // 팔로잉 수
    var likedPosts: [String]  // 좋아요한 게시물 ID 목록
}
