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
import FirebaseStorage
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
                    likedPostIDs: userData["likedPostIDs"] as? [String] ?? [],
                    postCount: userData["postCount"] as? Int ?? 0 // 추가
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
                DispatchQueue.main.async {
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
                "likedPostIDs": [],
                "firstLogin": true // 추가: 첫 로그인 상태 추가 -> HomeView 첫 환영 게시물 
            ]
            
            db.collection("users").document(user.uid).setData(userData) { error in
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if let error = error {
                        print("Firestore 사용자 저장 오류: \(error.localizedDescription)")
                        self.errorMessage = "사용자 정보 저장 중 오류가 발생했습니다."
                        
                        // Firestore 저장 실패 시 계정 삭제
                        user.delete { _ in }
                        
                        completion(false)
                        return
                    }
                    
                    // 회원가입 성공 후 필드 초기화
                    self.resetFields()
                    completion(true)
                }
            }
        }
    }
    
    // 소셜 로그인 함수
    func socialLogin(provider: String, completion: @escaping (Bool) -> Void = {_ in }) {
        isLoading = true
        errorMessage = ""
        
        errorMessage = "소셜 로그인은 아직 구현되지 않았습니다."
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.isLoading = false
            completion(false)
        }
    }
    
    
    // SignOut 로그아웃
    func signOut() {
        // 추가: Firebase 로그아웃 로직
        do {
            try Auth.auth().signOut()
            resetFields()
        } catch {
            print("로그아웃 오류: \(error.localizedDescription)")
        }
        
    }
    
    func resetFields() {
        email = ""
        password = ""
        username = ""
        confirmPassword = ""
        agreeToTerms = false
        errorMessage = ""
    }
    
    // 추가: Firebase 회원탈퇴
    func deleteAccount(password: String, completion: @escaping (Bool, String?) -> Void) {
        isLoading = true
        
        guard let currentUser = Auth.auth().currentUser, let email = currentUser.email else {
            isLoading = false
            completion(false, "현재 로그인된 사용자가 없습니다.")
            return
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        currentUser.reauthenticate(with: credential) { [weak self] _, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    completion(false, "비밀번호가 일치하지 않습니다.")
                }
                return
            }
            
            let db = Firestore.firestore()
            
            // 1. 사용자의 모든 게시물을 가져옴
            db.collection("posts").whereField("ownerUid", isEqualTo: currentUser.uid).getDocuments { [weak self] (snapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("사용자 게시물 조회 오류: \(error.localizedDescription)")
                    self.deleteUserAndFinish(currentUser: currentUser, db: db, completion: completion)
                    return
                }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    // 게시물이 없으면 바로 사용자 삭제 진행
                    self.deleteUserAndFinish(currentUser: currentUser, db: db, completion: completion)
                    return
                }
                
                let storage = Storage.storage().reference()
                let group = DispatchGroup()
                
                // 2. 각 게시물에 대해 Storage의 이미지와 Firestore 문서 삭제
                for document in documents {
                    group.enter()
                    
                    // 게시물 데이터 가져오기
                    let data = document.data()
                    let postId = document.documentID
                    
                    // Firestore에서 게시물 문서 삭제
                    db.collection("posts").document(postId).delete { error in
                        if let error = error {
                            print("게시물 삭제 오류 (ID: \(postId)): \(error.localizedDescription)")
                        } else {
                            print("게시물 삭제 성공 (ID: \(postId))")
                        }
                        
                        // 이미지가 있으면 Storage에서도 삭제
                        if let imageURL = data["imageURL"] as? String, imageURL.contains("post_images/") {
                            if let imagePathStart = imageURL.range(of: "post_images/")?.upperBound {
                                let imagePath = String(imageURL[imagePathStart...])
                                
                                // 가능하면 URL에서 파일명 추출
                                let filename = imagePath.components(separatedBy: "?").first ?? imagePath
                                
                                let storageRef = storage.child("post_images/\(filename)")
                                
                                storageRef.delete { error in
                                    if let error = error {
                                        print("게시물 이미지 삭제 오류: \(error.localizedDescription)")
                                    } else {
                                        print("게시물 이미지 삭제 성공")
                                    }
                                    group.leave()
                                }
                            } else {
                                group.leave()
                            }
                        } else {
                            group.leave()
                        }
                    }
                }
                
                // 3. 모든 게시물 삭제 완료 후 사용자 삭제 진행
                group.notify(queue: .main) {
                    self.deleteUserAndFinish(currentUser: currentUser, db: db, completion: completion)
                }
            }
        }
    }

    // 사용자 계정과 데이터 삭제 후 완료 처리하는 보조 함수
    private func deleteUserAndFinish(currentUser: FirebaseAuth.User, db: Firestore, completion: @escaping (Bool, String?) -> Void) {
        // Firestore에서 사용자 문서 삭제
        db.collection("users").document(currentUser.uid).delete { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                print("Firestore 사용자 데이터 삭제 오류: \(error.localizedDescription)")
            }
            
            // Firebase Auth에서 사용자 계정 삭제
            currentUser.delete { [weak self] (error) in
                self?.isLoading = false
                
                if let error = error {
                    completion(false, "계정 삭제 중 오류가 발생했습니다.: \(error.localizedDescription)")
                    return
                }
                
                self?.currentUser = nil
                self?.isAuthenticated = false
                self?.resetFields()
                completion(true, nil)
            }
        }
    }
    
    // 추가: Firebase 오류 메시지 처리 함수
    private func handleFirebaseError(_ error: Error) -> String {
        let errorCode = (error as NSError).code
        
        switch errorCode {
        case AuthErrorCode.wrongPassword.rawValue:
            return "이메일 또는 비밀번호가 올바르지 않습니다."
        case AuthErrorCode.invalidEmail.rawValue:
            return "올바르지 않은 이메일 형식입니다."
        case AuthErrorCode.accountExistsWithDifferentCredential.rawValue:
            return "같은 이메일의 다른 계정이 이미 존재합니다."
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return "이미 사용 중인 이메일입니다."
        case AuthErrorCode.userNotFound.rawValue:
            return "이메일 또는 비밀번호가 올바르지 않습니다."
        case AuthErrorCode.networkError.rawValue:
            return "네트워크 오류가 발생했습니다. 인터넷 연결을 확인해주세요."
        case AuthErrorCode.weakPassword.rawValue:
            return "비밀번호가 너무 약합니다."
        case AuthErrorCode.userDisabled.rawValue:
            return "해당 계정은 비활성화되었습니다."
        case AuthErrorCode.tooManyRequests.rawValue:
            return "너무 많은 요청이 발생했습니다. 나중에 다시 시도해주세요."
        default:
            return "로그인에 실패했습니다: \(error.localizedDescription)"
        }
    }
}
