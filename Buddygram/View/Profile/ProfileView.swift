//
//  ProfileView.swift
//  Buddygram
//
//  Created by KimJunsoo on 3/6/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingDeleteConfirmation = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var showingReauthDialog = false
    @State private var reauthPassword = ""
    
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
                showingDeleteConfirmation = true
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
        // 회원 탈퇴시 확인 알림창
        .alert("정말 탈퇴하시겠습니까?", isPresented: $showingDeleteConfirmation) {
            Button("취소", role: .cancel) {}
            Button("탈퇴", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("모든 데이터가 삭제되며, 이 작업은 되돌릴 수 없습니다.")
        }
        // 오류 알림창
        .alert("오류", isPresented: $showingErrorAlert) {
            if errorMessage == "보안상의 이유로 재로그인이 필요합니다." {
                Button("재인증", role: .none) {
                    showingReauthDialog = true
                }
                Button("취소", role: .cancel) {}
            } else {
                Button("확인", role: .cancel) {}
            }
        } message: {
            Text(errorMessage)
        }
        // 재인증 다이얼로그
        .sheet(isPresented: $showingReauthDialog) {
            ReauthenticationView()
        }
    }
    
    // 회원탈퇴 함수
    private func deleteAccount() {
        authViewModel.deleteAccount { success, message in
            if !success, let message = message {
                errorMessage = message
                showingErrorAlert = true
            }
        }
    }
    
}


#Preview {
    ProfileView()
}
