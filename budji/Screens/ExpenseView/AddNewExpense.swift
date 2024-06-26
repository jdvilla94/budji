//
//  AddNewExpense.swift
//  budji
//
//  Created by JD Villanueva on 5/25/24.
//

import SwiftUI

struct AddNewExpense: View {
    
    @Binding var showModal: Bool
    @State private var selectedCategory = 0
    let categories = ["Needs","Wants","Savings"]
    
    
    var body: some View {
        HStack{
            XDismissButton(isShowingDetailView: $showModal)
        }
        
        VStack {
            CustomPicker(selectedCategory: $selectedCategory, categories: categories)
            
            if selectedCategory == 0 {
                NeedsView(showModal: $showModal)
            } else if selectedCategory == 1 {
                WantsView(showModal: $showModal)
            } else if selectedCategory == 2 {
                SavingsView(showModal: $showModal)
            }
                
            
            
        }
      
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CustomPicker: View {
    @Binding var selectedCategory: Int
    let categories: [String]
    
    var body: some View {
        HStack {
            ForEach(0..<categories.count, id: \.self) { index in
                Button(action: {
                    withAnimation {
                        selectedCategory = index
                    }
                }) {
                    VStack {
                        Text(categories[index])
                            .foregroundColor(selectedCategory == index ? .cyan : .gray)
                        
                        Rectangle()
                            .fill(selectedCategory == index ? LinearGradient(colors: [.blue,.cyan], startPoint: .leading, endPoint: .trailing): LinearGradient(colors: [.clear], startPoint: .leading, endPoint: .trailing))
                            .frame(height: 2)
                    }
                }
                .frame(width: 75)
            }
        }
        .padding()
    }
}


#Preview {
    AddNewExpense(showModal: .constant(false))
}
