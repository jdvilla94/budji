//
//  NeedsView.swift
//  budji
//
//  Created by JD Villanueva on 5/27/24.
//

import SwiftUI

struct NeedsView: View {
    
    
    @State private var categoryName = ""
    @State private var amount = ""
    @State private var nameOfBill = ""
    @State private var selectedDate: Date = Date()
    
    @State private var isSheetShown = false
    @State var segment = 0
    
    @Binding var showModal: Bool
    
    @FocusState private var focusedTextField: FormTextField?
    enum FormTextField{
        case firstName, lastName, email
    }
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            HStack(spacing: 50){
                Text("Category")
                    .font(.system(size: 25))
                    .fontWeight(.bold)
                
                Button{
                    isSheetShown.toggle()
                    segment = 0
                }label: {
                    if categoryName == ""{
                        Text("Select A Category")
                            .font(.system(size: 12))
                    }else{
                        Text("\(categoryName)")
                            .font(.system(size: 12))
        
                    }
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                    
                }
                .foregroundStyle(.white)
                .fontWeight(.bold)
                .frame(width: 150, height: 30)
                .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.cyan]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(10)
                .padding()
                
            }
            
            Text("Add Expense")
                .font(.system(size: 25))
                .fontWeight(.bold)
                .padding(.bottom, 5)
            
            HStack {
                Text("$")
                    .font(.headline)
                    .padding(.leading, 5)
                
                TextField("Enter The Amount", text: $amount)
                    .keyboardType(.decimalPad)
                    .padding(10)
                    .background(Color.clear)
                    .padding(.trailing, 5)
                    .fontWeight(.bold)
            }
            .frame(height: 50)
            
            
            
            Text("Name")
                .font(.system(size: 25))
                .fontWeight(.bold)
            
            
            TextField("Enter the Bill Name", text: $nameOfBill)
//                .keyboardType(.decimalPad)
                .background(Color.clear)
                .fontWeight(.bold)
            
        
            DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
            //                       .datePickerStyle(GraphicalDatePickerStyle())
                .font(.system(size: 25))
                .fontWeight(.bold)
           
                
            
            HStack {
                Spacer()
                
                Button {
                    // Save action
                    let expense = expense(category: categoryName, amount: Double(amount)!, name: nameOfBill, date: selectedDate)
                    FirebaseAuth.shared.saveExpense(with: expense, type: "needs") { success, error in
                        if success {
                            // Handle successful save
                            showModal = false
                            print("success")
                        } else if let error = error {
                            // Handle error
                            print("Error saving expense: \(error.localizedDescription)")
                        }
                        
                    }
                } label: {
                    Text("Save")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .frame(width: 225, height: 50)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.cyan]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(10)
                }
                
                Spacer()
            }
            
            Spacer()
                 
        }
        
        .padding(.leading)
        .sheet(isPresented: $isSheetShown) {
            PresentScreen(segment:$segment, categoryName: $categoryName)
                .presentationDetents([.fraction(0.85)]) // 3/4 of the screen height
                .presentationDragIndicator(.visible) // Optional, to show the drag indicator
        }
        

        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NeedsView(showModal: .constant(false))
}



struct PresentScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = NeedsGridView()
    @Binding var segment: Int
    @Binding var categoryName: String
    
    
    
    var body: some View {
        VStack {
            Text("Select a Category")
                .font(.headline)
                .padding()
            
            
            NavigationView{
                ScrollView{
                    LazyVGrid(columns: viewModel.columns) {
                        if segment == 0{
                            ForEach(NeedsData.needsData) { framework in
                                CardViewTitles(cardTitle: framework)
                                    .onTapGesture {
                                        categoryName = framework.name
                                        print("the category name is: \(categoryName)")
                                        presentationMode.wrappedValue.dismiss()
                                    }
                            }
                        } else if segment == 1{
                            ForEach(WantsData.wantsData) { framework in
                                CardViewTitles(cardTitle: framework)
                                    .onTapGesture {
                                        categoryName = framework.name
                                        print("the category name is: \(categoryName)")
                                        presentationMode.wrappedValue.dismiss()
                                    }
                            }
                        }else if segment == 2{
                            ForEach(SavingsData.savingsData) { framework in
                                CardViewTitles(cardTitle: framework)
                                    .onTapGesture {
                                        categoryName = framework.name
                                        print("the category name is: \(categoryName)")
                                        presentationMode.wrappedValue.dismiss()
                                        
                                    }
                            }
                        }

                    }
                }
            }

            

            
        }
        
        .padding()
        
        
    }
}
