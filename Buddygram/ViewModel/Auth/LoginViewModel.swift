//
//  LoginViewModel.swift
//  Buddygram
//
//  Created by KimJunsoo on 3/6/25.
//

import Foundation
import SwiftUI
import Combine

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var isEmailValid: Bool = false
    @Published var isPasswordValid: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupValidations()
    }
    
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
    }
    
    func login() {
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
    
}

