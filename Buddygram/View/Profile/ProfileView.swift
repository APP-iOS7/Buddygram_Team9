//
//  ProfileView.swift
//  Buddygram
//
//  Created by KimJunsoo on 3/6/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
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
        }
        .padding()
    }
}

#Preview {
    ProfileView()
}
