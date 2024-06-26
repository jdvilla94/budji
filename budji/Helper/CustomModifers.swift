//
//  CustomModifers.swift
//  budji
//
//  Created by JD Villanueva on 5/20/24.
//

import SwiftUI

struct StandarButtonStyle: ViewModifier{
    
    func body(content: Content) -> some View {
        content
            .font(.title2)
            .fontWeight(.semibold)
            .frame(width: 300,height: 50)
            .foregroundStyle(.black)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 2)
            
    }
    
    
}
