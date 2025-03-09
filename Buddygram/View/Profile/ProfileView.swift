//
//  ProfileView.swift
//  Buddygram
//
//  Created by KimJunsoo on 3/6/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingPasswordDialog = false
    @State private var showingDeleteConfirmation = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var deletePassword = ""
    
    var body: some View {
        VStack (spacing: 20) {
            Text("프로필 화면")
                .font(.largeTitle)
            
            if let user = authViewModel.currentUser {
                VStack(alignment: .leading, spacing: 10) {
                    Text("사용자 이름: \(user.username)")
                    Text("이메일: \(user.email)")
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            
            Button(action: {
                authViewModel.signOut()
            }) {
                Text("로그아웃")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 200, height: 150)
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
            
            // 회원탈퇴 버튼 추가
            Button(action: {
                showingPasswordDialog = true
                deletePassword = ""
            }) {
                Text("회원탈퇴")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 200, height: 100)
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
        }
        .padding()
        
        // 비밀번호 입력 다이어로그
        .sheet(isPresented: $showingPasswordDialog) {
            PasswordInputView(
                password: $deletePassword,
                onSubmit: {
                    showingPasswordDialog = false
                    showingDeleteConfirmation = true
                }
            )
        }
        
        // 회원탈퇴 확인 창
        .alert("정말 탈퇴하시겠습니까?",isPresented: $showingDeleteConfirmation) {
            Button("취소", role: .cancel) {}
            Button("탈퇴", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("모든 데이터가 삭제되며, 이 작업은 되돌릴 수 없습니다.")
        }
        
        // 오류 알림창
        .alert("오류", isPresented: $showingErrorAlert) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    // 회원탈퇴 함수
    private func deleteAccount() {
        authViewModel.deleteAccount(password: deletePassword) { success, message in
            if success {
                
            } else if let message = message {
                errorMessage = message
                showingErrorAlert = true
            }
            
        }
    }
    
}

// 비밀번호 입력 뷰
struct PasswordInputView: View {
    @Binding var password: String
    var onSubmit: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("비밀번호 확인")
                .font(.headline)
                .padding(.top)
            
            Text("회원탈퇴를 위해 비밀번호를 입력해주세요.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            SecureField("비밀번호", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            HStack {
                Button("취소") {
                    dismiss()
                }
                .foregroundColor(.blue)
                .padding()
                
                Button("확인") {
                    onSubmit()
                }
                .foregroundColor(.blue)
                .padding()
                .disabled(password.isEmpty)
            }
        }
        .padding()
        .frame(width: 300, height: 250)
        .background(Color(.systemBackground))
        .cornerRadius(20)
    }
}

#Preview {
    ProfileView()
}
