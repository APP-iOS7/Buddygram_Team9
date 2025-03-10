//
//  PostDetailView.swift
//  Buddygram
//
//  Created by KimJunsoo on 3/10/25.
//

import SwiftUI
import FirebaseAuth

// 게시물 상세 보기
struct PostDetailView: View {
    let post: Post
    @State private var newComment = ""
    @State private var isLiked: Bool
    @State private var showingDeleteOptions = false
    @State private var isDeleting = false
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var postViewModel: PostViewModel
    
    init(post: Post) {
        self.post = post
        self._isLiked = State(initialValue: post.likedBy.contains(Auth.auth().currentUser?.uid ?? ""))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // 헤더
                HStack {
                    if let profileURL = post.ownerProfileImageURL, let url = URL(string: profileURL) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            case .failure:
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                    }
                    
                    Text(post.ownerUsername)
                        .font(.headline)
                    
                    Spacer()
                    
                    // 본인 게시물인 경우 추가 옵션 버튼
                    if post.ownerUid == Auth.auth().currentUser?.uid {
                        Button(action: {
                            showingDeleteOptions = true
                        }) {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 8)
                        }
                    }
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                
                // 이미지
                if let url = URL(string: post.imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .aspectRatio(contentMode: .fit)
                                .overlay(ProgressView())
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        case .failure:
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .aspectRatio(contentMode: .fit)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .overlay(
                        Group {
                            if isDeleting {
                                Color.black.opacity(0.7)
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                        }
                    )
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        )
                }
                
                // 액션 버튼들
                HStack {
                    Button(action: {
                        toggleLike()
                    }) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .font(.title2)
                            .foregroundColor(isLiked ? .red : .red)
                    }
                    
                    Button(action: {
                        // 댓글 포커스 (나중에 구현)
                    }) {
                        Image(systemName: "message")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                    
                    NavigationLink(destination: ChatView(username: post.ownerUsername)) {
                        Image(systemName: "paperplane.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                }
                .padding()
                
                // 좋아요 수
                Text("\(post.likeCount)명이 좋아합니다")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                
                // 캡션
                if let caption = post.caption {
                    HStack {
                        Text(post.ownerUsername)
                            .fontWeight(.semibold) +
                        Text(" ") +
                        Text(caption)
                    }
                    .padding(.horizontal)
                    .padding(.top, 2)
                }
                
                // 날짜
                Text(post.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                    .padding(.top, 4)
                
                // 댓글 섹션 (나중에 구현)
                Divider()
                    .padding(.top)
                
                HStack {
                    TextField("댓글 추가...", text: $newComment)
                        .padding(.horizontal)
                    
                    Button(action: {
                        if !newComment.isEmpty {
                            // 댓글 추가 로직 (나중에 구현)
                            newComment = ""
                        }
                    }) {
                        Text("게시")
                            .fontWeight(.semibold)
                            .foregroundColor(!newComment.isEmpty ? .blue : .gray)
                    }
                    .padding(.trailing)
                    .disabled(newComment.isEmpty)
                }
                .padding(.vertical)
            }
        }
        .navigationBarHidden(true)
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
    
    private func toggleLike() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        isLiked.toggle() // UI 즉시 업데이트
        
        postViewModel.toggleLike(postId: post.id, userId: userId) { success in
            if !success {
                // 실패시 상태 복원
                isLiked.toggle()
            }
        }
    }
    
    // 게시물 삭제 함수
    private func deletePost() {
        isDeleting = true
        postViewModel.deletePost(postId: post.id) { success in
            DispatchQueue.main.async {
                isDeleting = false
                
                if success {
                    // 삭제 성공 시 상세 화면 닫기
                    presentationMode.wrappedValue.dismiss()
                } else {
                    // 실패 처리 (추가 가능)
                    print("게시물 삭제 실패: \(postViewModel.errorMessage)")
                }
            }
        }
    }
}
