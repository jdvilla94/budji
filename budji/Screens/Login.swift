//
//  ContentView.swift
//  budji
//
//  Created by JD Villanueva on 5/17/24.
//

import SwiftUI
//import GoogleSignIn
//import GoogleSignInSwift
//import FirebaseAuth
//import Firebase



struct Login: View {
    
    @Binding var isShowingDetail: Bool
    
    var body: some View {
        VStack{
            Button{
                //start with the sign in flow
                FirebaseAuth.shared.signInWithGoogle(presenting: getRootViewController()) { error in
//                    print("The error is: \(String(describing: error))")
                }
            } label: {
                HStack {
                      Image("google")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(.leading,5)

                    Text("Continue With Google")
                        .font(.title3)
                        .fontWeight(.bold)
                  }
            }
            .modifier(StandarButtonStyle())
            .padding(.bottom,30)
            
            Button{
                print("you tapped me")
    
                    
                
            } label: {
                HStack {
                      Image("apple")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(.leading,5)

                    Text("Continue With Apple")
                        .font(.title3)
                        .fontWeight(.bold)
                  }
            }
            .modifier(StandarButtonStyle())
            .padding(.bottom,30)
        }
    }
}

#Preview {
    Login(isShowingDetail: .constant(false))
}
