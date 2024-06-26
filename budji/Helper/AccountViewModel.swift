//
//  AccountViewModel.swift
//  budji
//
//  Created by JD Villanueva on 5/21/24.

import SwiftUI

final class AccountViewModel: ObservableObject{
    
    @AppStorage("user") private var userData: Data?
    @Published var user = User()
    
    func saveChanges(){
        guard isValidForm else {return}
        
        do{
            let data = try JSONEncoder().encode(user)
            userData = data
            print("we succesfully added a user")
        }catch{
            print("we have an error saving the changes")
        }
    }
    
    func retrieveUser(){
        guard let userData = userData else { return }
        
        do{
            user = try JSONDecoder().decode(User.self, from: userData)
        }catch{
            print("we have an error retrieving the user")
        }
    }
    
    var isValidForm: Bool {
        guard !user.username.isEmpty && !user.email.isEmpty && !user.email.isEmpty else {
            print("we have an error with length")
            return false
        }

        return true
    }
    

}


