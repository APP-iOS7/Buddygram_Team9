//
//  LoginView.swift
//  Buddygram
//
//  Created by KimJunsoo on 3/6/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var showAlert: Bool = false
    @State private var isPasswordVisible: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
//                Spacer()
                
                // 이메일 & 비밀번호 텍스트필드
                VStack(spacing: 12) {
                    TextField("Email", text: $authViewModel.email)
                        .modifier(CustomSignTextFieldModifier())
                    
                    HStack(spacing: 0) {
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
                    
                    HStack {
                        Button(action: {
                            // 비밀번호 찾기 이벤트
                        }) {
                            Text("비밀번호를 잊으셨나요?")
                                .font(.system(size: btnFontSize))
                                .foregroundStyle(Color("PlaceholderColor"))
                                .underline()
                        }
                        Spacer()
                    }
                    .padding(.top, 4)
                    
                    if !authViewModel.errorMessage.isEmpty {
                        Text(authViewModel.errorMessage)
                            .font(.system(size: 14))
                            .foregroundStyle(.red)
                            .padding(.top, 8)
                    }
                }
                
                // 로그인 & 회원가입 버튼
                VStack(spacing: 12) {
                    Button(action: {
                        // 로그인 이벤트
                        authViewModel.signIn() { success in
                            if !success && !authViewModel.errorMessage.isEmpty {
                                showAlert = true
                            }
                        }
                    }) {
                        if authViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color("TextColor")))
                        } else {
                            Text("로그인")
                                .font(.system(size: btnFontSize, weight: .bold))
                                .foregroundColor(Color("TextColor"))
                                .frame(maxWidth: .infinity)
                                .frame(height: btnHeight)
                                .background(Color("PrimaryButtonColor"))
                                .cornerRadius(btnCornerRadius)
                        }
                    }
                    
                    // 회원가입 링크
                    NavigationLink(destination: SignUpView().navigationBarHidden(true)) {
                        HStack {
                            Text("계정이 없으신가요?")
                                .font(.system(size: 14))
                                .foregroundStyle(Color("PlaceholderColor"))
                            
                            Text("가입하기")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color("PlaceholderColor"))
                        }
                    }
                    /*
                     Button(action: {
                     // 회원가입 이벤트
                     }) {
                     Text("회원가입")
                     .font(.system(size: btnFontSize, weight: .bold))
                     .foregroundColor(Color("TextColor"))
                     .frame(maxWidth: .infinity)
                     .frame(height: btnHeight)
                     .background(Color("SecondaryButtonColor"))
                     .cornerRadius(btnCornerRadius)
                     }
                     */
                }
                .padding(.horizontal)
                .padding(.vertical, 20)
                
                // 소셜 로그인 버튼
                VStack(spacing: 12) {
                    SocialLoginButton(title: "네이버")
                    SocialLoginButton(title: "카카오")
                    SocialLoginButton(title: "구글")
                    SocialLoginButton(title: "애플")
                }
                .padding(.horizontal)
                .padding(.vertical, 20)
                
                .padding(.horizontal)
                                .padding(.vertical, 20)
                                .toolbar {
                                        ToolbarItem(placement: .principal) {
                                            Text("Buddygram")
                                                .font(.largeTitle)
                                                .fontWeight(.bold)
                                                .foregroundStyle(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [
                                                            Color.green, Color.green, Color.green,
                                                            Color.pink, Color.pink, Color.purple
                                                        ]),
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                        }
                                    }
                Spacer()
                
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(action: {
                        // 버튼 누르면 키보드 내려가는 이벤트 처리
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        
                    }) {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .foregroundStyle(Color("PlaceholderColor"))
                    }
                }
            }
            /*.alert(isPresented: $showAlert) {
                Alert(
                    title: Text("로그인 오류"),
                    message: Text(authViewModel.errorMessage),
                    dismissButton: .default(Text("확인"))
                )
            }*/
        }
    } // body
}

struct SocialLoginButton: View {
    let title: String
    
    var body: some View {
        Button(action: {
            // 각 소셜 로그인 버튼 이벤트
        }) {
            Text(title)
                .font(.system(size: btnFontSize, weight: .bold))
                .foregroundColor(Color("TextColor"))
                .frame(maxWidth: .infinity)
                .frame(height: btnHeight)
                .background(Color("SecondaryButtonColor"))
                .cornerRadius(btnCornerRadius)
        }
    }
}

#Preview {
    LoginView()
}

