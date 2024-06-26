//
//  ListViewCellModel.swift
//  budji
//
//  Created by JD Villanueva on 6/8/24.
//

import SwiftUI

struct ListViewCell: View {
    

    
    let sample : expense
    
    var body: some View {
        HStack(){
            Image("piggy-bank")
                .resizable()
                .frame(width: 50, height: 50)
                .aspectRatio(contentMode: .fill)

                .padding(.leading, -20)
                .padding()

            
            VStack(alignment: .leading){
                Text(sample.name)
                    .font(.system(size: 10))
                
                
                Text(formattedDate(from: "\(sample.date)"))
                    .font(.system(size: 10))
            }
            
            Text("\(String(format: "%.2f",sample.amount))")
                .font(.system(size: 10))
                .padding(.leading, 80)
                
            
        
        }
        .frame(width: 300, height: 85) // Ensure the VStack matches the rectangle size
        .background(Color.gray) // Set the VStack background color
        .cornerRadius(20) // Apply corner radius to the VStack
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray, lineWidth: 2) // Set border color and width
        )

    }
}

func formattedDate(from dateString: String) -> String {
    // Define the input date formatter
    let inputFormatter = DateFormatter()
    inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
    
    // Define the output date formatter
    let outputFormatter = DateFormatter()
    outputFormatter.dateFormat = "MMMM d, yyyy"
    
    // Parse the input string to a Date object
    if let date = inputFormatter.date(from: dateString) {
        // Format the Date object to the desired output string
        return outputFormatter.string(from: date)
    } else {
        // Handle the error case where the input string could not be parsed
        return "Invalid date"
    }
}



#Preview {
    ListViewCell(sample: expense.sampleExpense)
}
