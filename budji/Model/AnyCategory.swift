//
//  AnyCategory.swift
//  budji
//
//  Created by JD Villanueva on 5/30/24.
//

import SwiftUI


struct AnyCategory: Hashable,Identifiable{
    let id = UUID()
    var name: String
    var image: String
}

struct NeedsData {

    static let data = AnyCategory(name: "Dining Out", image: "fork.knife")
    
    static let needsData = [
        AnyCategory(name: "Rent", image: "house"),
        AnyCategory(name: "Utilities", image: "bolt"),
        AnyCategory(name: "Gas", image: "fuelpump"),
        AnyCategory(name: "Internet/Phone", image: "wifi"),
        AnyCategory(name: "Groceries", image: "bolt")
    ]
    
}

struct WantsData{
    
    
    static let data = AnyCategory(name: "Dining Out", image: "fork.knife")
    
    static let wantsData = [
        AnyCategory(name: "Dining Out", image: "fork.knife"),
        AnyCategory(name: "Clothes", image: "tshirt"),
        AnyCategory(name: "Vacation", image: "airplane.departure"),
        AnyCategory(name: "Gym", image: "figure.gymnastics"),
        AnyCategory(name: "Subscriptions", image: "dollarsign")
    ]
    
}

struct SavingsData{
    
    
    static let data = AnyCategory(name: "Dining Out", image: "fork.knife")
    
    static let savingsData = [
        AnyCategory(name: "Savings", image: "piggy"),
        AnyCategory(name: "High Yield Savings", image: "chart.pie"),
        AnyCategory(name: "Investment", image: "chart.line.uptrend.xyaxis"),

    ]
    
    
    
}



