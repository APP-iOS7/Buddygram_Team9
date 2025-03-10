//
//  LikeView.swift
//  Buddygram
//
//  Created by KimJunsoo on 3/6/25.
//

import SwiftUI

struct LikeView: View {
    @Binding var posts: [FeedPost]
    
    var likedPosts: [FeedPost] {
        posts.filter { $0.isLiked }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    LazyVStack(alignment: .leading, pinnedViews: [.sectionHeaders]) {
                        Section(header: Text("❤️ 좋아요한 게시물")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                        ) {
                            ForEach(likedPosts) { post in
                                LikedPostView(post: post)
                            }
                        }
                    }
                    .padding()
                }
            }
            
            .toolbar {
                ToolbarItem(placement: .principal) {
                        Text("Buddygram")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(LinearGradient(
                                gradient: Gradient(colors: [Color.green, Color.green, Color.pink, Color.pink, Color.purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                }
            }
        }
    }
}

struct LikedPostView: View {
    let post: FeedPost

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
                
                Text(post.username)
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()
            }
            .padding(.horizontal)

            Image(post.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 300)
                .clipped()
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}

#Preview {
    LikeView(posts: .constant([
        FeedPost(username: "user1", image: "post1", isLiked: true),
        FeedPost(username: "user2", image: "post2", isLiked: false)
    ]))
}
