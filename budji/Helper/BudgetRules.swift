//
//  BudgetRules.swift
//  budji
//
//  Created by JD Villanueva on 5/25/24.
//

import Foundation

struct FiftyThirtyTwenty: Identifiable{
    var name:String
    let fifty: Int
    let thirty: Int
    let twenty: Int
    var id: String{
        name
    }
    
    
    static var all: [FiftyThirtyTwenty] {
        [
            
        ]
    }
}
