//
//  DailyBudget.swift
//  budji
//
//  Created by JD Villanueva on 5/22/24.
//

import Foundation
import Observation

@Observable
class DailyBudget{
    var budeget: Int
    var spent: Int
    
    init(budeget: Int, spent: Int) {
        self.budeget = budeget
        self.spent = spent
    }
}
