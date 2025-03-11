//
//  UploadView.swift
//  Buddygram
//
//  Created by KimJunsoo on 3/6/25.
//

import SwiftUI
import PhotosUI
import Firebase
import UIKit
import AVFoundation

// UIImagePickerController를 SwiftUI에서 사용하기 위한 래퍼
// 사용자가 사진을 선택하거나 촬영할 수 있도록 UIKit의 UIImagePickerController를 활용
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    var sourceType: UIImagePickerController.SourceType
    
    // Coordinator: UIKit의 Delegate 패턴을 처리하기 위한 클래스
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        // 사용자가 사진을 선택했을 때 호출되는 함수
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        // 사용자가 취소 버튼을 눌렀을 때 호출되는 함수
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    // Coordinator 인스턴스 생성
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    // UIImagePickerController 인스턴스 생성 및 설정
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }
    
    // 업데이트가 필요할 경우 수행 (현재는 필요 없음)
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

struct UploadView: View {
    @State var caption = ""
    @Binding var selectedTab: Int
    @State var selectedItem: PhotosPickerItem?
    @State var postImage: Image?
    @State private var uiImage: UIImage?
    @State private var isUploading = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    // 이미지 선택 관련 상태 변수 추가
    @State private var showImageSourceOptions = false
    @State private var showCamera = false
    @State private var showPhotoLibrary = false
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var postViewModel: PostViewModel
    
    func convertItem(item: PhotosPickerItem?) async {
        guard let item = item else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: data) else { return }
        self.uiImage = uiImage
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
            
            // 이미지 표시 영역
            VStack {
                if let image = self.postImage {
                    image
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(maxWidth: .infinity)
                } else {
                    Button(action: {
                        showImageSourceOptions = true
                    }) {
                        VStack(spacing: 12) {
                            Image(systemName: "photo.on.rectangle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                                .foregroundColor(.blue)
                            
                            Text("사진 선택하기")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        .frame(height: 300)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal)
            
            // 사진 촬영 또는 선택 관련 버튼 (이미지가 없을 때만 표시)
            if postImage == nil {
                HStack(spacing: 20) {
                    Button(action: {
                        checkCameraPermission()
                    }) {
                        VStack {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 22))
                            Text("촬영하기")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        .frame(width: 100, height: 60)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        showPhotoLibrary = true
                    }) {
                        VStack {
                            Image(systemName: "photo.fill")
                                .font(.system(size: 22))
                            Text("앨범에서 선택")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        .frame(width: 100, height: 60)
                        .background(Color.green)
                        .cornerRadius(10)
                    }
                }
                .padding()
            } else {
                // 이미지가 있을 때 변경 버튼 표시
                Button(action: {
                    showImageSourceOptions = true
                }) {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("사진 변경하기")
                    }
                    .foregroundColor(.blue)
                    .padding(.vertical, 8)
                }
            }
            
            TextField("문구 추가...", text: $caption)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
            
            Spacer()
            
            // 공유 버튼
            Button {
                uploadPost()
            } label: {
                if isUploading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(width: 363, height: 42)
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                } else {
                    Text("공유하기")
                        .frame(width: 363, height: 42)
                        .foregroundStyle(.white)
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
            .padding()
            .disabled(postImage == nil && caption.isEmpty || isUploading)
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(image: $uiImage, sourceType: .camera)
                .onDisappear {
                    if let uiImage = uiImage {
                        postImage = Image(uiImage: uiImage)
                    }
                }
        }
        .sheet(isPresented: $showPhotoLibrary) {
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Text("앨범에서 선택")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .onChange(of: selectedItem) { oldValue, newValue in
                Task {
                    await convertItem(item: newValue)
                }
            }
            .presentationDetents([.medium])
        }
        .actionSheet(isPresented: $showImageSourceOptions) {
            ActionSheet(
                title: Text("이미지 선택"),
                message: Text("사진을 어떻게 선택할까요?"),
                buttons: [
                    .default(Text("카메라로 촬영")) {
                        checkCameraPermission()
                    },
                    .default(Text("앨범에서 선택")) {
                        showPhotoLibrary = true
                    },
                    .cancel(Text("취소"))
                ]
            )
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("확인")) {
                    if alertTitle == "업로드 완료" {
                        selectedTab = 0 // 업로드 성공 시 홈으로 이동
                    }
                }
            )
        }
        .onDisappear {
            resetUploadState()
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            if oldValue == 2 && newValue != 2 {
                resetUploadState()
            }
        }
    }
    
    // 카메라 권한 확인 함수
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // 이미 권한 획득
            showCamera = true
        case .notDetermined:
            // 아직 권한 요청 안 함
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.showCamera = true
                    }
                }
            }
        case .denied, .restricted:
            // 권한 거부됨
            alertTitle = "카메라 권한 필요"
            alertMessage = "설정에서 Buddygram 앱의 카메라 접근 권한을 허용해주세요."
            showAlert = true
        @unknown default:
            break
        }
    }
    
    private func resetUploadState() {
        DispatchQueue.main.async {
            self.caption = ""
            self.postImage = nil
            self.uiImage = nil
            self.selectedItem = nil  // 혹은 seletectedItem - 오타 수정 필요
        }
    }
    
    // 게시물 업로드 함수
    private func uploadPost() {
        guard let currentUser = authViewModel.currentUser else {
            alertTitle = "오류"
            alertMessage = "사용자 정보를 가져올 수 없습니다."
            showAlert = true
            return
        }
        
        guard uiImage != nil || !caption.isEmpty else {
            alertTitle = "오류"
            alertMessage = "이미지나 텍스트 중 하나는 선택해주세요."
            showAlert = true
            return
        }
        
        isUploading = true
        
        // 이미지가 없는 경우 기본 이미지(텍스트 아이콘) 사용
        let imageToUpload = uiImage ?? (UIImage(systemName: "text.below.photo") ?? UIImage())
        
        postViewModel.uploadPost(image: imageToUpload, caption: caption, user: currentUser) { success in
            self.isUploading = false
            
            if success {
                self.alertTitle = "업로드 완료"
                self.alertMessage = "게시물이 성공적으로 업로드되었습니다."
                self.showAlert = true
                self.resetUploadState()
            } else {
                self.alertTitle = "오류"
                self.alertMessage = self.postViewModel.errorMessage.isEmpty ? "게시물 업로드 중 오류가 발생했습니다." : self.postViewModel.errorMessage
                self.showAlert = true
            }
        }
    }
}

#Preview {
    UploadView(selectedTab: .constant(2))
        .environmentObject(AuthViewModel())
        .environmentObject(PostViewModel())
}
