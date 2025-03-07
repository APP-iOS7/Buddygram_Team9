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
            return
        }
        
        guard !password.isEmpty else {
            errorMessage = "비밀번호를 입력해주세요."
            completion(false)
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            
            self.isLoading = false
            
            if let user = self.users.first(where: { $0.email == self.email && $0.password == self.password}) {
                self.currentUser = user
                self.isAuthenticated = true
                completion(true)
            } else {
                self.errorMessage = "이메일 또는 비밀번호가 올바르지 않습니다."
                completion(false)
            }
        }
    }
    
    // SignUp 회원가입
    func signUp(completion: @escaping (Bool) -> Void = {_ in}) {
        // 유효성 검사
        guard !email.isEmpty else {
            errorMessage = "이메일을 입력해주세요."
            return
        }
        
        guard !password.isEmpty else {
            errorMessage = "비밀번호를 입력해주세요."
            return
        }
        
        guard isEmailValid else {
            errorMessage = "올바른 이메일 형식이 아닙니다."
            return
        }
        
        guard isPasswordValid else {
            errorMessage = "비밀번호는 8자 이상, 대소문자, 숫자, 특수문자를 포함해야 합니다."
            return
        }
        
    }
    
    
    // SignOut 로그아웃
    func signOut() {
        currentUser = nil
        isAuthenticated = false
    }
}
