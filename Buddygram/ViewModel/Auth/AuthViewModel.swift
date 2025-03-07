//
//  AuthViewModel.swift
//  Buddygram
//
//  Created by KimJunsoo on 3/6/25.
//

import Foundation
import SwiftUI
import Firebase
import Combine

class AuthViewModel: ObservableObject {
    @Published var userSession: Firebase.User?
    
}
