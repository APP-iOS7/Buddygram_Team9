//
//  ProfileView.swift
//  Buddygram
//
//  Created by KimJunsoo on 3/6/25.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var postViewModel: PostViewModel
    @Binding var selectedTab: Int
    
    @State private var userPosts: [Post] = []
    @State private var userPostCount: Int = 0 // 추가 : 게시물 카운트용
    @State private var isLoading = false
    @State private var isRefreshing = false
    @State private var showingPasswordDialog = false
    @State private var showingDeleteConfirmation = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var deletePassword = ""
    
    var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    var body: some View {
<<<<<<< HEAD
<<<<<<< HEAD
        VStack (spacing: 20) {
            
            Text("프로필 화면")
                .font(.largeTitle)
            
            if let user = authViewModel.currentUser {
                VStack(alignment: .leading, spacing: 10) {
                    Text("사용자 이름: \(user.username)")
                    Text("이메일: \(user.email)")
=======
=======
>>>>>>> 9eb3c03a24707d8588b2551d8a301b0977aafea9
        NavigationView {
            ScrollView {
                VStack (spacing: 20) {
                    // 사용자 정보 섹션
                    if let user = authViewModel.currentUser {
                        // 프로필 헤더
                        HStack {
                            // 프로필 이미지
                            if let profileURL = user.profileImageURL, let url = URL(string: profileURL) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    case .failure:
                                        Image(systemName: "person.crop.circle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(.gray)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .padding(.trailing, 20)
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.gray)
                                    .frame(width: 80, height: 80)
                                    .padding(.trailing, 20)
                            }
                            
                            // 게시물, 팔로워 등 정보
                            VStack(alignment: .leading, spacing: 8) {
                                Text(user.username)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                HStack(spacing: 20) {
                                    VStack {
                                        Text("\(user.postCount)")
                                            .font(.headline)
                                        Text("게시물")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    // 팔로워/팔로잉 기능은 나중에 구현
                                    VStack {
                                        Text("0")
                                            .font(.headline)
                                        Text("팔로워")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    VStack {
                                        Text("0")
                                            .font(.headline)
                                        Text("팔로잉")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // 프로필 수정 버튼
                        Button(action: {
                            // 프로필 수정 기능 (나중에 구현)
                        }) {
                            Text("프로필 수정")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                        .padding(.top, 4)
                        
                        // 이메일 정보
                        Text("이메일: \(user.email)")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        // 게시물 섹션
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding(50)
                        } else {
                            // 게시물 그리드
                            VStack(alignment: .leading) {
                                Text("내 게시물")
                                    .font(.headline)
                                    .padding(.horizontal)
                                    .padding(.top)
                                
                                LazyVGrid(columns: columns, spacing: 2) {
                                    ForEach(postViewModel.posts.filter { $0.ownerUid == user.id }) { post in
                                        NavigationLink(destination: PostDetailView(post: post)) {
                                            PostGridItem(post: post)
                                                .frame(width: 120, height: 120)
                                        }
                                    }
                                }
                                .padding(.horizontal, 2)
                            }
                        }
                        
                        Spacer()
                        
                        // 로그아웃 및 회원탈퇴 버튼
                        VStack(spacing: 16) {
                            Button(action: {
                                authViewModel.signOut()
                                selectedTab = 0
                            }) {
                                Text("로그아웃")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: btnHeight)
                                    .background(Color.blue)
                                    .cornerRadius(btnCornerRadius)
                            }
                            
                            // 회원탈퇴 버튼
                            Button(action: {
                                showingPasswordDialog = true
                                deletePassword = ""
                            }) {
                                Text("회원탈퇴")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: btnHeight)
                                    .background(Color.red)
                                    .cornerRadius(btnCornerRadius)
                            }
                        }
                        .padding()
                    }
<<<<<<< HEAD
>>>>>>> 9eb3c03 (기능구현 최신화)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("프로필")
            .onAppear {
                fetchUserPosts()
            }
            .onChange(of: selectedTab) { _, newValue in
                if newValue == 4 {
                    fetchUserPosts()
                }
            }
            
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
            .alert("정말 탈퇴하시겠습니까?", isPresented: $showingDeleteConfirmation) {
                Button("취소", role: .cancel) {}
                Button("탈퇴", role: .destructive) {
                    deleteAccount()
                }
            } message: {
                Text("모든 데이터가 삭제되며, 이 작업은 되돌릴 수 없습니다.")
            }
            
=======
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("프로필")
            .onAppear {
                fetchUserPosts()
            }
            .onChange(of: selectedTab) { _, newValue in
                if newValue == 4 {
                    fetchUserPosts()
                }
            }
            
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
            .alert("정말 탈퇴하시겠습니까?", isPresented: $showingDeleteConfirmation) {
                Button("취소", role: .cancel) {}
                Button("탈퇴", role: .destructive) {
                    deleteAccount()
                }
            } message: {
                Text("모든 데이터가 삭제되며, 이 작업은 되돌릴 수 없습니다.")
            }
            
>>>>>>> 9eb3c03a24707d8588b2551d8a301b0977aafea9
            // 오류 알림창
            .alert("오류", isPresented: $showingErrorAlert) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            
        }
    }
    
    private func fetchUserPosts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        
        postViewModel.fetchUserPosts(uid: uid) { posts in
            self.userPosts = posts
            self.isLoading = false
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

// 그리드 아이템 뷰
struct PostGridItem: View {
    let post: Post
    @State private var showingDeleteOptions = false
    @State private var isDeleting = false
    @EnvironmentObject var postViewModel: PostViewModel
    
    var body: some View {
        ZStack {
            if let url = URL(string: post.imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .aspectRatio(1, contentMode: .fill)
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(1, contentMode: .fill)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                .aspectRatio(1, contentMode: .fill)
                .frame(minWidth: 0, maxWidth: .infinity)
                .frame(minHeight: 0, maxHeight: .infinity)
                .clipped()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(1, contentMode: .fill)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            
            // 좋아요 수 표시
            VStack {
                Spacer()
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.white)
                    Text("\(post.likeCount)")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(Color.black.opacity(0.5))
            }
            
            // 삭제 중일 때 오버레이
            if isDeleting {
                Color.black.opacity(0.7)
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
        }
        .contentShape(Rectangle()) // 전체 영역 탭 가능하게
        .onLongPressGesture {
            // 본인 게시물만 삭제 옵션 표시
            if post.ownerUid == Auth.auth().currentUser?.uid {
                showingDeleteOptions = true
            }
        }
        .actionSheet(isPresented: $showingDeleteOptions) {
            ActionSheet(
                title: Text("게시물 관리"),
                message: Text("이 게시물을 어떻게 하시겠습니까?"),
                buttons: [
                    .destructive(Text("삭제")) {
                        deletePost()
                    },
                    .cancel(Text("취소"))
                ]
            )
        }
    }
    
    // 게시물 삭제 함수
    private func deletePost() {
        isDeleting = true
        postViewModel.deletePost(postId: post.id) { success in
            DispatchQueue.main.async {
                isDeleting = false
                
                if !success {
                    // 삭제 실패 시 처리 (추가 가능)
                    print("게시물 삭제 실패: \(postViewModel.errorMessage)")
                }
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
<<<<<<< HEAD
<<<<<<< HEAD
#Preview {
    ProfileView(selectedTab: .constant(0))
        .environmentObject(AuthViewModel())
}
=======

>>>>>>> 9eb3c03 (기능구현 최신화)
=======

>>>>>>> 9eb3c03a24707d8588b2551d8a301b0977aafea9
