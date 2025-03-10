//
//  ProfileView.swift
//  Buddygram
//
//  Created by KimJunsoo on 3/6/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var selectedTab: Int
    @State private var showingPasswordDialog = false
    @State private var showingDeleteConfirmation = false
    @State private var showingErrorAlert = false
    @State private var showingProfileImagePicker = false
    @State private var errorMessage = ""
    @State private var deletePassword = ""

    var body: some View {
        VStack {
            // 상단 네비게이션 바
            HStack {
                
                Text("프로필")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    showingProfileImagePicker = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                        .foregroundStyle(.gray)
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)

            // 프로필 섹션
            VStack(spacing: 10) {
                // 프로필 이미지
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundStyle(.gray)

                // 사용자 정보
                if let user = authViewModel.currentUser {
                    Text(user.username)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(user.email)
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                }
            }
            .padding(.top, 10)

            // 로그아웃 & 회원탈퇴 버튼
            VStack(spacing: 10) {
                Button(action: {
                    authViewModel.signOut()
                    selectedTab = 0
                }) {
                    Text("로그아웃")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(minWidth: 200, maxWidth: .infinity, minHeight: 40)                        .background(Color.red)
                        .cornerRadius(8)
                }

                Button(action: {
                    showingPasswordDialog = true
                    deletePassword = ""
                }) {
                    Text("회원탈퇴")
                        .fontWeight(.semibold)
                        .foregroundStyle(.red)
                }
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)

            Spacer()
        }
        .padding()
        .sheet(isPresented: $showingPasswordDialog) {
            PasswordInputView(
                password: $deletePassword,
                onSubmit: {
                    showingPasswordDialog = false
                    showingDeleteConfirmation = true
                }
            )
        }
        .alert("정말 탈퇴하시겠습니까?", isPresented: $showingDeleteConfirmation) {
            Button("취소", role: .cancel) {}
            Button("탈퇴", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("모든 데이터가 삭제되며, 이 작업은 되돌릴 수 없습니다.")
        }
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
                selectedTab = 0
            } else if let message = message {
                errorMessage = message
                showingErrorAlert = true
            }
        }
    }
}
// 프로필 이미지 변경 뷰
struct ProfileImagePickder: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text("프로필 사진 변경")
                .font(.title2)
                .fontWeight(.bold)
                .padding()
            
            Button("사진 선택") {
                
            }
            .padding()
            
            Button("취소") {
                dismiss()
            }
            .foregroundColor(.red)
        }
        .frame(width: 300, height: 200)
        .background(Color(.systemBackground))
        .cornerRadius(20)
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
