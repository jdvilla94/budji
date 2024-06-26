//
//  needsDetailView.swift
//  budji
//
//  Created by JD Villanueva on 6/6/24.
//

import SwiftUI

struct needsDetailView: View {
    
    @Binding var amount: [expense]
    @Binding var amountTwo: [expense]
    @Binding var amountThree: [expense]
    @State private var monthText = ""
    
    @StateObject var viewModel = ListViewCellModel()
    
    @State private var selectedValue = 0
    
    func currentMonth() {
        let date = Date() // Step 1: Get the current date
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM" // Step 2: Set the format to "MMM"
        monthText = formatter.string(from: date)
        print("The current month in needs view is: \(monthText)")
        /*return formatter.string(from: date)*/ // Step 3: Format the date and return the string
    }
  
    private func populateCategories() {
        // Use viewModel.options directly to populate categories
        viewModel.options = Array(Set(viewModel.amount.map { $0.category }))
    }
    
    let months = ["Jan", "Feb","Mar","Apr", "May", "Jun","Jul", "Aug", "Sep", "Oct", "Nov","Dec"]
    
    @State private var isMenuVisible = false

    var body: some View {
        
        VStack(spacing: 30){
            HStack(spacing: 20){
                HStack{
                    VStack{
                        HStack{
                            Image("leave")
                                .resizable()
                                .frame(width: 50, height: 50)
                            Text("$640")
                            Spacer()
                        }
                        
                        Text("Your monthly expense for utilities")
                    }
                }
                .padding()
                .frame(width: 275, height: 100)
                .background(Color.gray) // Set the VStack background color
                .cornerRadius(20) // Apply corner radius to the VStack
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray, lineWidth: 2) // Set border color and width
                )
                
                VStack {
                    Menu {
                        ForEach(months, id: \.self) { month in
                            Button(action: {
                                monthText = month
                                selectedValue = 0 // Reset selected value when the month changes
                                viewModel.getNeedsData(currentMonth: month)
                                print("The month selected is: \(monthText)")
                                
                                
                            }) {
                                Text(month)
                            }
                        }
                    } label: {
                        VStack {
                            Image(systemName: "chevron.up")
                                .padding(10)
                            Text(monthText)
                                .font(.system(size: 10))
                                .bold()
                            Image(systemName: "chevron.down")
                                .padding(10)
                        }
                        .frame(width: 55, height: 100)
                        .background(Color.gray)
                        .cornerRadius(20)
                        .foregroundStyle(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray, lineWidth: 2)
                        )
                    }
                }
                
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(0..<viewModel.options.count, id: \.self) { index in
                        Text(viewModel.options[index])
                            .frame(width: 75, height: 10)
                            .padding()
                            .background(self.selectedValue == index ? Color.cyan : Color.gray)
                            .foregroundColor(Color.white)
                            .cornerRadius(10)
                            .onTapGesture {
                                self.selectedValue = index
                            }
                    }
                }
            }
            
            if viewModel.isDataEmpty {
                // Display an empty scene
                Text("No data available for \(monthText)")
                    .font(.system(size: 25))
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
            }
            else{
                
                VStack(alignment: .leading) {
                    Text("\(monthText) Expenses")
                        .font(.system(size: 25))
                        .fontWeight(.bold)
                    
                    
                    //                List(viewModel.amount.filter { $0.category == options[selectedValue] }) { exp in
                    //                    ListViewCell(sample: exp)
                    //                        .listRowBackground(Color.gray)
                    //                        .listRowSeparator(.hidden)
                    //                        .listRowInsets(EdgeInsets())
                    //                }
                    List(viewModel.amount.filter { exp in
                        if selectedValue < viewModel.options.count {
                            return exp.category == viewModel.options[selectedValue]
                        } else {
                            return false
                        }
                    }) { exp in
                        ListViewCell(sample: exp)
                            .listRowBackground(Color.gray)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(PlainListStyle())
                }
                .padding()
                .frame(width: 350, height: 450) // Ensure the VStack matches the rectangle size
                .background(Color.gray) // Set the VStack background color
                .cornerRadius(20) // Apply corner radius to the VStack
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray, lineWidth: 2) // Set border color and width
                )
                
                
                .onAppear(perform: {
                    currentMonth()
                    viewModel.getNeedsData(currentMonth: monthText)
                    populateCategories()
                })
            }
        }
                .padding()
        }
    
    
}


struct NeedsDetailView_Previews: PreviewProvider {
    @State static var sampleExpenses = expense.sampleExpenses
    static var previews: some View {
        needsDetailView(amount: $sampleExpenses,amountTwo: $sampleExpenses, amountThree: $sampleExpenses)
    }
}


