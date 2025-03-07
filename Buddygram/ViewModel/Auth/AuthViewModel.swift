//
//  AuthViewModel.swift
//  Buddygram
//
//  Created by KimJunsoo on 3/6/25.
//

import Foundation
import SwiftUI
import Firebase
import Combine

class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    
    // Firebase 연결전 로컬 시뮬레이션용 테스트 기본 사용자
    private var users: [User] = [
        User(id: UUID().uuidString,
             username: "test",
             email: "test@test.com",
             profileImageURL: nil,
             createdAt: Date())
    ]
    
    // SignUp 회원가입
    func signUp(username: String, email: String, password: String) -> Bool {
        // 유효성 검사 : 이메일 중복 확인
        if users.contains(where: { $0.email == email }) {
            return false
        }
        
        let newUser = User(
            id: UUID().uuidString,
            username: username,
            email: email,
            profileImageURL: nil,
            createdAt: Date()
        )
        
        // 사용자 배열에 추가 (실제로는 DB에 저장)
        users.append(newUser)
        
        // 로그인 처리
        currentUser = newUser
        isAuthenticated = true
        return true
    }
    
}
