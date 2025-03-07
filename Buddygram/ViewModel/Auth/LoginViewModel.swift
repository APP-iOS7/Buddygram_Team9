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

