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
    // 인증 상태
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading: Bool = false
    
    // 로그인, 회원가입 입력 필드
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var username: String = ""
    @Published var confirmPassword = ""
    @Published var agreeToTerms = false
    
    // 유효성 검사 및 오류 처리
    @Published var errorMessage: String = ""
    @Published var isEmailValid: Bool = false
    @Published var isPasswordValid: Bool = false
    @Published var isUsernameValid = false
    
    // Firebase 연결전 로컬 시뮬레이션용 테스트 기본 사용자
    private var users: [User] = [
        User(id: UUID().uuidString,
             username: "test",
             email: "test@test.com",
             profileImageURL: nil,
             createdAt: Date(),
             password: "Qwer12!@")
    ]
    
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupValidations()
    }
    
    // 유효성 검사 설정
    private func setupValidations() {
        $email
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { email in
                let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
                let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
                return emailPredicate.evaluate(with: email)
            }
            .assign(to: \.isEmailValid, on: self)
            .store(in: &cancellables)
        
        $password
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { password in
                let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$"
                let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
                return passwordPredicate.evaluate(with: password)
            }
            .assign(to: \.isPasswordValid, on: self)
            .store(in: &cancellables)
        
        $username
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { username in
                return username.count >= 3
            }
            .assign(to: \.isUsernameValid, on: self)
            .store(in: &cancellables)
    }
    
    // SignIn 로그인
    func signIn(completion: @escaping (Bool) -> Void = {_ in}) {
        guard !email.isEmpty else {
            errorMessage = "이메일을 입력해주세요."
            completion(false)
        }
    }
    
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
            createdAt: Date(),
            password: password
        )
        
        // 사용자 배열에 추가 (실제로는 DB에 저장)
        users.append(newUser)
        
        // 로그인 처리
        currentUser = newUser
        isAuthenticated = true
        return true
    }
    
    
    // SignOut 로그아웃
    func signOut() {
        currentUser = nil
        isAuthenticated = false
    }
}
