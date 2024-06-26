//
//  ListViewCellModel.swift
//  budji
//
//  Created by JD Villanueva on 6/10/24.
//

import SwiftUI
import Firebase

@MainActor final class ListViewCellModel: ObservableObject{
    
    @Published var amount: [expense] = []
    @Published var amountTwo: [expense] = []
    @Published var amountThree: [expense] = []
    
    @Published var options: [String] = []
    @Published var isDataEmpty: Bool = false

    @Published var selectedExpense: expense?
    
    func getNeedsData(currentMonth: String){
        
        FirebaseAuth.shared.getNeedVariable(month: currentMonth, year: String(Date.now.yearInt)) { (needs, error) in
            if let needs = needs {
                // Clear the options before populating with new data
                self.options = []
                
                // Assign fetched needs directly to 'amount'
                self.amount = needs
                
                // Populate options based on the fetched needs data
                let uniqueCategories = Set(needs.map { $0.category })
                self.options = Array(uniqueCategories)
                
                // Data is not empty
                self.isDataEmpty = false
                
                // Log the mapped amount data
                print("Mapped amount data: \(self.amount)")
            } else {
                // Clear the amount and options if there's an error or no data
                self.amount = []
                self.options = []
                self.isDataEmpty = true
                print("THE NEEDS AMOUNT IS EMPTY")
            }
        }
    }
    
    func getWantsData(currentMonth: String){
        
        FirebaseAuth.shared.getWantVariable(month: currentMonth, year: String(Date.now.yearInt)) { (wants, error) in
            if let wants = wants {
                // Clear the options before populating with new data
                self.options = []
                
                // Assign fetched needs directly to 'amount'
                self.amountTwo = wants
                
                // Populate options based on the fetched needs data
                let uniqueCategories = Set(wants.map { $0.category })
                self.options = Array(uniqueCategories)
                
                // Data is not empty
                self.isDataEmpty = false
                
                // Log the mapped amount data
                print("Mapped amount data: \(self.amountTwo)")
            } else {
                // Clear the amount and options if there's an error or no data
                self.amountTwo = []
                self.options = []
                self.isDataEmpty = true
                print("THE NEEDS AMOUNT IS EMPTY")
            }
        }
    }
    
    func getSavingsData(currentMonth: String){
        
        FirebaseAuth.shared.getSavingVariable(month: currentMonth, year: String(Date.now.yearInt)) { (savings, error) in
            if let savings = savings {
                // Clear the options before populating with new data
                self.options = []
                
                // Assign fetched needs directly to 'amount'
                self.amountThree = savings
                
                // Populate options based on the fetched needs data
                let uniqueCategories = Set(savings.map { $0.category })
                self.options = Array(uniqueCategories)
                
                // Data is not empty
                self.isDataEmpty = false
                
                // Log the mapped amount data
                print("Mapped amount data: \(self.amountThree)")
            } else {
                // Clear the amount and options if there's an error or no data
                self.amountThree = []
                self.options = []
                self.isDataEmpty = true
                print("THE NEEDS AMOUNT IS EMPTY")
            }
        }
    }
        


//        FirebaseAuth.shared.getNeedVariable { (needs, error) in
//            if let needs = needs {
//                // Log the needs data
//                print("IT GOT CALLED IN THE LISTVIEWCELLMODE")
//                print("Fetched needs data: \(needs)")
//                
//                // Map Firestore data to Expense instances and assign to 'amount'
//                self.amount = needs.compactMap { dictionary in
//                    // Log each dictionary
//                    print("Processing dictionary: \(dictionary)")
//                    
//                    guard let category = dictionary["category"] as? String,
//                          let amount = dictionary["amount"] as? Double,
//                          let name = dictionary["name"] as? String,
//                          let timestamp = dictionary["date"] as? Timestamp else {
//                        // Handle invalid data format
//                        print("Invalid data format in dictionary: \(dictionary)")
//                        return nil
//                    }
//                    let date = timestamp.dateValue()
//                    return expense(category: category, amount: amount, name: name, date: date)
//                }
//                
//                // Log the mapped amount data
//                print("Mapped amount data: \(self.amount)")
//                print("THE NEEDS AMOUNT DATA")
//                
//                
//            }
//        }
//        
//        FirebaseAuth.shared.getWantVariable { (want, error) in
//            if let want = want {
//                // Log the needs data
//                print("Fetched needs data: \(want)")
//                
//                // Map Firestore data to Expense instances and assign to 'amount'
//                self.amountTwo = want.compactMap { dictionary in
//                    // Log each dictionary
//                    print("Processing dictionary: \(dictionary)")
//                    
//                    guard let category = dictionary["category"] as? String,
//                          let amount = dictionary["amount"] as? Double,
//                          let name = dictionary["name"] as? String,
//                          let timestamp = dictionary["date"] as? Timestamp else {
//                        // Handle invalid data format
//                        print("Invalid data format in dictionary: \(dictionary)")
//                        return nil
//                    }
//                    let date = timestamp.dateValue()
//                    return expense(category: category, amount: amount, name: name, date: date)
//                }
//                
//                // Log the mapped amount data
//                print("Mapped amount data: \(self.amount)")
//                
//                
//            }
//            
//            
//        }
//        
//        FirebaseAuth.shared.getSavingVariable { (want, error) in
//            if let want = want {
//                // Log the needs data
//                print("Fetched needs data: \(want)")
//                
//                // Map Firestore data to Expense instances and assign to 'amount'
//                self.amountThree = want.compactMap { dictionary in
//                    // Log each dictionary
//                    print("Processing dictionary: \(dictionary)")
//                    
//                    guard let category = dictionary["category"] as? String,
//                          let amount = dictionary["amount"] as? Double,
//                          let name = dictionary["name"] as? String,
//                          let timestamp = dictionary["date"] as? Timestamp else {
//                        // Handle invalid data format
//                        print("Invalid data format in dictionary: \(dictionary)")
//                        return nil
//                    }
//                    let date = timestamp.dateValue()
//                    return expense(category: category, amount: amount, name: name, date: date)
//                }
//                
//                // Log the mapped amount data
//                print("Mapped amount data: \(self.amount)")
//                
//                
//            }
//            
//            
//        }
//        


    
    
    
}




