//
//  expense.swift
//  budji
//
//  Created by JD Villanueva on 6/3/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct expense: Identifiable {
    var category: String
    var amount: Double
    var name: String
    var date: Date
    var id: String {
           name
       }
    

    
    
    func toDictionary() -> [String: Any] {
            return [
                "category": category,
                "amount": amount,
                "name": name,
                "date": Timestamp(date: date)
            ]
        }
    
    static var sampleExpenses = [
        expense(category: "wants", amount: 10.00, name: "coffee", date: Date())
        ]
    
    static var sampleExpense = expense(category: "", amount: 0.0, name: "", date: Date())
}


