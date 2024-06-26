//
//  budjiApp.swift
//  budji
//
//  Created by JD Villanueva on 5/17/24.
//

import SwiftUI
import Firebase

@main
struct budjiApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @AppStorage("signIn") var isSignOn = false
    
    var body: some Scene {
        WindowGroup {
            
//            Login(isShowingDetail: .constant(false))
            if !isSignOn {
                Login(isShowingDetail: .constant(false))
//                    .preferredColorScheme(.light)
            }else{
                BudjiTabView()
//                    .preferredColorScheme(.light)
            }
        }
        
    }
}
