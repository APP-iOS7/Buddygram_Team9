//
//  AuthViewModel.swift
//  Buddygram
//
//  Created by KimJunsoo on 3/6/25.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
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
    
    private var cancellables = Set<AnyCancellable>()
    private var handle: AuthStateDidChangeListenerHandle?
    
    init() {
        setupValidations()
        setupAuthStateListener()
    }
    
    // 추가 : Firebase, 메모리 관리
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    // 추가 : Firebase 인증 상태 리스너 설정 함수
    private func setupAuthStateListener() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let self = self else { return }
            
            if let firebaseUser = user {
                self.fetchUserData(uid: firebaseUser.uid)
            } else {
                self.isAuthenticated = false
                self.currentUser = nil
            }
        }
    }
    
    // 추가 : Firebase Firestore에서 사용자 정보 가져오는 함수
    private func fetchUserData(uid: String) {
        let db = Firestore.firestore()
        
        db.collection("users").document(uid).getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("사용자 정보 가져오기 오류: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists, let userData = document.data() {
                let user = User(
                    id: uid,
                    username: userData["username"] as? String ?? "",
                    email: userData["email"] as? String ?? "",
                    profileImageURL: userData["profileImageURL"] as? String,
                    createdAt: (userData["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                    likedPostIDs: userData["likedPostIDs"] as? [String] ?? []
                )
                
                DispatchQueue.main.async {
                    self.currentUser = user
                    self.isAuthenticated = true
                }
            }
        }
    }
    
    // 이메일, 패스워드 유효성 검사 설정
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
        
        // 추가: Firebase 인증 로그인 로직
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (authResult, error) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = self.handleFirebaseError(error)
                    completion(false)
                    return
                }
                completion(true)
            }
        }
    }
    
    // SignUp 회원가입
    func signUp(completion: @escaping (Bool) -> Void = {_ in}) {
        // 유효성 검사
        guard !username.isEmpty else {
            errorMessage = "사용자 이름을 입력해주세요."
            completion(false)
            return
        }
        
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
        
        guard !confirmPassword.isEmpty else {
            errorMessage = "비밀번호 확인을 입력해주세요."
            completion(false)
            return
        }
        
        guard isUsernameValid else {
            errorMessage = "사용자 이름은 3자 이상이어야 합니다."
            completion(false)
            return
        }
        
        guard isEmailValid else {
            errorMessage = "올바른 이메일 형식이 아닙니다."
            completion(false)
            return
        }
        
        guard isPasswordValid else {
            errorMessage = "비밀번호는 8자 이상, 대소문자, 숫자, 특수문자를 포함해야 합니다."
            completion(false)
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "비밀번호가 일치하지 않습니다."
            completion(false)
            return
        }
        
        guard agreeToTerms else {
            errorMessage = "이용약관에 동의해주세요."
            completion(false)
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        // 추가: Firebase 회원가입 로직
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (authResult, error) in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = self.handleFirebaseError(error)
                    completion(false)
                }
                return
            }
            
            guard let user = authResult?.user else {
                DispatchQueue.amin.async {
                    self.isLoading = false
                    self.errorMessage = "계정 생성 중 오류가 발생했습니다."
                    completion(false)
                }
                return
            }
            
            // Firestore에 사용자 정보 저장
            let db = Firestore.firestore()
            let userData: [String: Any] = [
                "username": self.username,
                "email": self.email,
                "createdAt": Timestamp(date: Date()),
                "likedPostIDs": []
            ]
            
            db.collection("users").document(user.uid).setData(userData) { error in
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if let error = error {
                        print("Firestore 사용자 저장 오류: \(error.localizedDescription)")
                        self.errorMessage = "
                    }
                }
            }
        }
        
        
    }
    
    // 소셜 로그인 함수
    func socialLogin(provider: String, completion: @escaping (Bool) -> Void = {_ in }) {
        isLoading = true
        errorMessage = ""
        
        // 테스트를 위한 지연 시뮬레이션
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            
            self.isLoading = false
            
            // 테스트용 사용자
            let socialUser = User(
                id: UUID().uuidString,
                username: "\(provider)User",
                email: "\(provider)@example.com",
                profileImageURL: nil,
                createdAt: Date(),
                password: ""
            )
            
            self.currentUser = socialUser
            self.isAuthenticated = true
            completion(true)
        }
    }
    
    // SignOut 로그아웃
    func signOut() {
        currentUser = nil
        isAuthenticated = false
        resetFields()
    }
    
    func resetFields() {
        email = ""
        password = ""
        username = ""
        confirmPassword = ""
        agreeToTerms = false
        errorMessage = ""
    }
}
