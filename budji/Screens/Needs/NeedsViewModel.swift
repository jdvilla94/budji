//
//  NeedsViewModel.swift
//  budji
//
//  Created by JD Villanueva on 6/5/24.
//

import SwiftUI

struct NeedsViewModel: View {
    
    @State var progressBar = SmallProgressBar()
    @State var percent:CGFloat = 100
    
    @State var needsAmount: Double
    @State var percentageVar: Double
    @State var totalAmount: Double
    
    
    
    var body: some View {
        
        let amountLeftToSpend = totalAmount * percentageVar - needsAmount
        let remainingPercentage = min(1 - amountLeftToSpend / (totalAmount * percentageVar), 1) * 100
        let multiplier = progressBar.width/100
        
        VStack {
            // Rectangle with specified size, corner radius, shadow, border, and inner content
            ZStack(alignment: .leading) {
                // Rectangle with specified size, corner radius, shadow, and border
                Rectangle()
                    .fill(Color.clear) // Set the fill color of the rectangle
                    .frame(width: 300, height: 100) // Set the width and height
                    .cornerRadius(20) // Set the corner radius
                    .shadow(radius: 10) // Set the shadow radius
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray, lineWidth: 2) // Set border color and width
                    )
                
                // Inner content
                VStack(alignment: .leading) {
                    HStack{
                        Image("needs")
                            .resizable()
                            .scaledToFit()
                        
                        Text("Needs")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Text("$\(String(format: "%.2f",(totalAmount * percentageVar)))")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                    }
                    
                    
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: progressBar.height, style: .continuous)
                            .frame(width: progressBar.width, height: progressBar.height)
                            .foregroundStyle(Color.black.opacity(0.1))
                        
                        RoundedRectangle(cornerRadius: progressBar.height, style: .continuous)
                            .frame(width: remainingPercentage * multiplier, height: progressBar.height)
                            .background(Color.cyan)
                            .clipShape(RoundedRectangle(cornerRadius: 20.0, style: .continuous))
                            
                            .foregroundStyle(.clear)
                    }
                    
                    HStack{
                        Text("Left to budget")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text("$\(String(format:"%.2f",(totalAmount * percentageVar) - needsAmount))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
            
                 
                   
                }
                .padding()
            }
            .frame(width: 300, height: 100)
        }
    }
}

#Preview {
    NeedsViewModel( needsAmount: 0.0, percentageVar: 0.0, totalAmount: 0.0)
}
