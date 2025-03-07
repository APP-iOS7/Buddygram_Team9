//
//  UploadView.swift
//  Buddygram
//
//  Created by KimJunsoo on 3/6/25.
//

import SwiftUI
import PhotosUI

struct UploadView: View {
    @State var caption = ""
    @Binding var selectedTab: Int
    @State var seletectedItem: PhotosPickerItem?
    @State var postImage: Image?
    
    func convertItem(item: PhotosPickerItem?) async {
        guard let item = item else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: data) else { return }
        self.postImage = Image(uiImage: uiImage)
    }
    
    var body: some View {
        VStack{
            HStack {
                Button {
                    selectedTab = 0 // 홈으로 이동
                } label: {
                    Image(systemName: "xmark")
                        .tint(.black)
                }
                Spacer()
                Text("새 게시물")
                    .font(.title2)
                    .fontWeight(.heavy)
                Spacer()
            }
            .padding(.horizontal)
            
            PhotosPicker(selection: $seletectedItem) {
                if let image = self.postImage { // self.postImage가 nil이 아니면, PhotoPicker로 사진을 장착한 후
                    image
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(maxWidth: .infinity)
                    
                    
                } else { // 장착 전
                    Image(systemName: "photo.on.rectangle")
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 300, height: 150)
                        .padding()
                        .tint(.black)
                    
                }
            }
            .onChange(of: seletectedItem) { oldvalue, newvalue in
                Task {
                    await convertItem(item: newvalue)
                }
            }
            
            TextField("문구 추가...", text: $caption)
                .padding()
            
            Spacer()
            
            Button {
                print("사진 공유")
                selectedTab = 0 // 홈으로 이동
            } label: {
                Text("공유하기")
                    .frame(width: 363, height: 42)
                    .foregroundStyle(.white)
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .padding()
            
            
            
            
        }
    }
}

#Preview {
    UploadView(selectedTab: .constant(2))
}
