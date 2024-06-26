//
//  userData.swift
//  budji
//
//  Created by JD Villanueva on 5/21/24.
//


import SwiftUI
import Combine

class UserData: ObservableObject {
    
    @Published var username: String = UserDefaults.standard.string(forKey: "username") ?? "No username"
    @Published var profileImage: String = UserDefaults.standard.string(forKey: "profileImage") ?? ""
    
}
