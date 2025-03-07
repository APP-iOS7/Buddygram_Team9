//
//  SignView.swift
//  Buddygram
//
//  Created by KimJunsoo on 3/6/25.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            VStack() {
                Text("회원가입")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color("TextColor"))
                    .padding(.top, 20)
                    .padding(.bottom, 12)
                
                // 입력 필드들
                VStack(spacing: 12) {
                    TextField("닉네임", text: $authViewModel.username)
                        .modifier(CustomSignTextFieldModifier())
                    
                    TextField("Email", text: $authViewModel.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .modifier(CustomSignTextFieldModifier())
                    
                    HStack() {
                        if isPasswordVisible {
                            TextField("Password", text: $authViewModel.password)
                        } else {
                            SecureField("Password", text: $authViewModel.password)
                        }
                        
                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                .foregroundStyle(Color("PlaceholderColor"))
                                .padding(.trailing)
                        }
                    }
                    .modifier(CustomSignTextFieldModifier())
                    
                    HStack() {
                        if isPasswordVisible {
                            TextField("Confirm Password", text: $authViewModel.confirmPassword)
                        } else {
                            SecureField("Confirm Password", text: $authViewModel.confirmPassword)
                        }
                        
                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                .foregroundStyle(Color("PlaceholderColor"))
                                .padding(.trailing)
                        }
                    }
                    .modifier(CustomSignTextFieldModifier())
                    
                    if !authViewModel.errorMessage.isEmpty {
                        Text(authViewModel.errorMessage)
                            .font(.system(size: 14))
                            .foregroundStyle(.red)
                            .padding(.top, 8)
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 24)
                
                // 이용약관 동의
                VStack(spacing: 8) {
                    Toggle(isOn: $authViewModel.agreeToTerms) {
                        Text("서비스 이용약관 및 개인정보 처리방침에 동의합니다.")
                            .font(.system(size: 14))
                            .foregroundStyle(Color("PlaceholderColor"))
                    }
                    .toggleStyle(CheckboxToggleStyle())
                    .padding(.top, 16)
                }
                .padding(.horizontal)
                
                Button(action: {
                    authViewModel.signUp { success in
                        if success {
                            presentationMode.wrappedValue.dismiss()
                        } else if !authViewModel.errorMessage.isEmpty {
                            showAlert = true
                        }
                    }
                }) {
                    if authViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color("TextColor")))
                    } else {
                        Text("가입하기")
                            .font(.system(size: btnFontSize, weight: .bold))
                            .foregroundColor(Color("TextColor"))
                            .frame(maxWidth: .infinity)
                            .frame(height: btnHeight)
                            .background(Color("PrimaryButtonColor"))
                            .cornerRadius(btnCornerRadius)
                    }
                }
                
                
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                        
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundStyle(Color("TextColor"))
                    }
                }
            }
        }
        .onAppear {
            authViewModel.resetFields()
        }
    } // body
}

// 체크박스 스타일 토글
struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .foregroundStyle(configuration.isOn ? Color("PrimaryButtonColor") : Color("PlaceholderColor"))
                .font(.system(size: 20))
                .onTapGesture {
                    configuration.isOn.toggle()
                }
            configuration.label
        }
    }
}

#Preview {
    SignUpView()
}
