//
//  BudjTabView.swift
//  budji
//
//  Created by JD Villanueva on 5/20/24.
//

import SwiftUI

struct BudjiTabView: View {
    
    @StateObject private var userData = UserData()
    
    var body: some View {
        TabView{
            HomePageView()
                .tabItem { Label("Home", systemImage: "house") }
            
            AccountView()
                .environmentObject(userData)
                .tabItem {Label("Account", systemImage: "person")}
        }
    }
}

#Preview {
    BudjiTabView()
}
