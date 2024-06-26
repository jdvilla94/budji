//
//  AccountView.swift
//  budji
//
//  Created by JD Villanueva on 5/20/24.
//

import SwiftUI
import Foundation

struct AccountView: View {
    
    @EnvironmentObject var userData: UserData
    
    var body: some View {
        NavigationStack{
            VStack {
                Text("\(userData.username)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top,50)
                
                if let url = URL(string: userData.profileImage) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 75, height: 75)
                            .clipShape(Circle())
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 75, height: 75)
                        .clipShape(Circle())
                }
                
            }
            
            Spacer()
            
            VStack{
                Form{
                    Section(header: Text("Personal Info")){
                        Text("hold")
                        Button{
                            FirebaseAuth.shared.signOut()
                        }label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .tint(.black)
                                Text("Sign Out")
                                    .tint(.black)
                            }
                        }

                    }

                    
                }
            }
            .padding(.top, 30)
        }

        
        
    }
        
}


#Preview {
//    AccountView()
    AccountView().environmentObject(UserData())
}
