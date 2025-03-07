//
//  CustomModifier.swift
//  PerrTodoList
//
//  Created by KimJunsoo on 3/4/25.
//

import SwiftUI

let textfieldHeight: CGFloat = 56
let btnCornerRadius: CGFloat = 12
let btnHeight: CGFloat = 44
let btnFontSize: CGFloat = 14

struct CustomSignTextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color("FieldBackground"))
            .foregroundStyle(Color("TextColor"))
            .frame(height: textfieldHeight)
            .cornerRadius(btnCornerRadius)
    }
}

struct CustomSignButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size:btnFontSize, weight: .bold))
            .foregroundColor(Color("TextColor"))
            .frame(maxWidth: .infinity)
            .frame(height: btnHeight)
            .cornerRadius(btnCornerRadius)
    }
}
