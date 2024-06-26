//
//  FIrebaseAuth.swift
//  budji
//
//  Created by JD Villanueva on 5/20/24.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth
//import Firebase
import FirebaseFirestore
import Firebase

class FirebaseAuth{
    static let shared = FirebaseAuth()
    
    private init(){}
    
    func signInWithGoogle(presenting: UIViewController,completion: @escaping(Error?) -> Void){
        GIDSignIn.sharedInstance.signIn(withPresenting: presenting) { authentication, error in
            if let error = error {
                print("There is an error signing the user in ==> \(error)")
                completion(error)
                return
            }
            guard let user = authentication?.user, let idToken = user.idToken?.tokenString else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            let registerUserRequest = registerUserRequest(username: user.profile?.name ?? "no name",
                                                          email: user.profile?.email ?? "no email",
                                                          password: "nopassword",
                                                          profileImage: ""
            )
            
            let db = Firestore.firestore()
            let usersCollection = db.collection("users")
            
            print("The email is: \(registerUserRequest.email)")
            
            
            // Query to find a document where the "email" field matches the given email
            usersCollection.whereField("email", isEqualTo: user.profile?.email ?? "").getDocuments { (querySnapshot, error) in
                if let error {
                    print("Error fetching documents: \(error)")
                    return
                } else if querySnapshot?.documents.isEmpty == false {
                    // Email exists in Firestore
                    Auth.auth().signIn(with: credential) { authresult, error in
                        if let error = error {
                            print("Sign in error: \(error)")
                            completion(error)
                        } else {
                            print("Sign In successful")
                            if let profile = user.profile {
                                UserDefaults.standard.set(profile.name, forKey: "username")
                                UserDefaults.standard.set(profile.imageURL(withDimension: 100)?.absoluteString, forKey: "profileImage")
                            }
                            UserDefaults.standard.set(true, forKey: "signIn")
                            completion(nil)
                        }
                    }
                    return
                } else {
                    // Email doesn't exist in Firestore
                    print("email doesnt exist in firestore")
                    FirebaseAuth.shared.registerUser(with: registerUserRequest) { [weak self]  wasRegistered, error in
                        guard let _ = self else {return}//stops retain cycles
                        
                        if let error{
                            print("couldnt log you into firestore-> \(error)")
                            return
                        }
                        
                        if wasRegistered{
                            print("SUCCESSFULLY ADDED USER TO FIREBASE")
                            Auth.auth().signIn(with: credential) { authresult, error in
                                print("Sign In successful")
                                if let profile = user.profile {
                                    UserDefaults.standard.set(profile.name, forKey: "username")
                                    UserDefaults.standard.set(profile.imageURL(withDimension: 100)?.absoluteString, forKey: "profileImage")
                                }
                                UserDefaults.standard.set(true, forKey: "signIn")
                                completion(nil)                            }
                        }else{
                            print("THE ERROR WAS\(String(describing: error))")
                        }
                    }
                    return
                }
            }
            
            
            //                print("Sign In")
            //                UserDefaults.standard.set(true, forKey: "signIn")
            //                //                        if error != nil {
            //                //                            print(error)
            //                //                        } else {
            //                //                            self.email = authResult?.user.email
            //                //                            self.photoURL = authResult?.user.photoURL!.absoluteString
            //                //                            self.checkIfUserAccountExists()
            //                //                        }
            //            }
        }
    }
    
    func signOut(){
        let firebaseAuth = Auth.auth()
        do {
            UserDefaults.standard.set(false, forKey: "signIn")
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    public func registerUser(with userRequest: registerUserRequest, completion: @escaping (Bool, Error?) -> Void){//completion handler calls a function, it runs if it passes completion, asycn way of doing things. we need to upload data, and it takes a few seconds. call completion when everything happens
        let username = userRequest.username
        let password = userRequest.password
        let email = userRequest.email
        let profileImage = userRequest.profileImage
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            
            if let error = error {
                completion(false,error)
                return
            }
            
            guard let resultUser = result?.user else{
                completion(false, nil)
                return
            }
            
            let db = Firestore.firestore()
            db.collection("users")
                .document(resultUser.uid)
                .setData([
                    "username":username,
                    "password": password,
                    "email": email,
                    "profileImage": profileImage
                    
                ]) { error in
                    if let error = error {
                        completion(false,error)
                        return
                    }
                    
                    UserDefaults.standard.set(username, forKey: "username")
                    UserDefaults.standard.set(profileImage, forKey: "profileImage")
                    completion(true,nil)
                    //                    return
                }
            
        }
    }
    
    func getNeedVariable(month: String? = nil, year: String? = nil,completion: @escaping ([expense]?, Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(nil, NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        let db = Firestore.firestore()
        let documentRef: DocumentReference
        
        
        if let month = month {
            //            documentRef = db.collection("users").document(uid).collection("months").document(month)
            documentRef = db.collection("users").document(uid).collection("years").document(year!).collection("months").document(month)

        } else {
            documentRef = db.collection("users").document(uid)
        }
        
        documentRef.getDocument { (document, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let document = document, document.exists else {
                completion(nil, NSError(domain: "DataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"]))
                return
            }
            
            guard let needsData = document.data()?["needs"] as? [[String: Any]] else {
                completion(nil, NSError(domain: "DataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Needs data not found"]))
                return
            }
            
            let needs = needsData.compactMap { data -> expense? in
                guard let category = data["category"] as? String,
                      let amount = data["amount"] as? Double,
                      let name = data["name"] as? String,
                      let timestamp = data["date"] as? Timestamp else {
                    print("Failed to parse data: \(data)")
                    return nil
                }
                
                let date = timestamp.dateValue()
                return expense(category: category, amount: amount, name: name, date: date)
            }
            completion(needs, nil)
        }
    }
    
    func getWantVariable(month: String? = nil, year: String? = nil,  completion: @escaping ([expense]?, Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(nil, NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        let db = Firestore.firestore()
        let documentRef: DocumentReference
        
        if let month = month {
            //            documentRef = db.collection("users").document(uid).collection("months").document(month)
            documentRef = db.collection("users").document(uid).collection("years").document(year!).collection("months").document(month)

        } else {
            documentRef = db.collection("users").document(uid)
        }
        
        documentRef.getDocument { (document, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let document = document, document.exists else {
                completion(nil, NSError(domain: "DataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"]))
                return
            }
            
            guard let needsData = document.data()?["wants"] as? [[String: Any]] else {
                completion(nil, NSError(domain: "DataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Needs data not found"]))
                return
            }
            
            let needs = needsData.compactMap { data -> expense? in
                guard let category = data["category"] as? String,
                      let amount = data["amount"] as? Double,
                      let name = data["name"] as? String,
                      let timestamp = data["date"] as? Timestamp else {
                    print("Failed to parse data: \(data)")
                    return nil
                }
                
                let date = timestamp.dateValue()
                return expense(category: category, amount: amount, name: name, date: date)
            }
            completion(needs, nil)
        }
    }
    
    func getSavingVariable(month: String? = nil, year: String? = nil, completion: @escaping ([expense]?, Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(nil, NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        let db = Firestore.firestore()
        let documentRef: DocumentReference
        
        if let month = month {
            //            documentRef = db.collection("users").document(uid).collection("months").document(month)
            documentRef = db.collection("users").document(uid).collection("years").document(year!).collection("months").document(month)

        } else {
            documentRef = db.collection("users").document(uid)
        }
        
        documentRef.getDocument { (document, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let document = document, document.exists else {
                completion(nil, NSError(domain: "DataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"]))
                return
            }
            
            guard let needsData = document.data()?["savings"] as? [[String: Any]] else {
                completion(nil, NSError(domain: "DataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Needs data not found"]))
                return
            }
            
            let needs = needsData.compactMap { data -> expense? in
                guard let category = data["category"] as? String,
                      let amount = data["amount"] as? Double,
                      let name = data["name"] as? String,
                      let timestamp = data["date"] as? Timestamp else {
                    print("Failed to parse data: \(data)")
                    return nil
                }
                
                let date = timestamp.dateValue()
                return expense(category: category, amount: amount, name: name, date: date)
            }
            completion(needs, nil)
        }
    }
    
    func saveExpense(with expense: expense,type: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(false, NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        let db = Firestore.firestore()
        
        // Extract the month and year from the expense date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM" // Format as 'Jan'
        let monthKey = dateFormatter.string(from: expense.date)
        
        let calendar = Calendar.current
        let year = calendar.component(.year, from: expense.date)
        
        // Reference to the year document
        let yearRef = db.collection("users").document(uid).collection("years").document("\(year)")
        
        // Check if the year document exists, create it if not
        yearRef.getDocument { (document, error) in
            if let error = error {
                completion(false, error)
                return
            }
            
            if !document!.exists {
                // Year document doesn't exist, create it
                yearRef.setData([:]) { error in
                    if let error = error {
                        completion(false, error)
                    } else {
                        // Year document created, now save the expense
                        self.saveExpenseUnderMonth(uid: uid, year: year, monthKey: monthKey, type: type, expense: expense, completion: completion)
                    }
                }
            } else {
                // Year document exists, save the expense
                self.saveExpenseUnderMonth(uid: uid, year: year, monthKey: monthKey, type: type, expense: expense, completion: completion)
            }
        }
    }

    private func saveExpenseUnderMonth(uid: String, year: Int, monthKey: String,type: String, expense: expense, completion: @escaping (Bool, Error?) -> Void) {
        let db = Firestore.firestore()
        
        // Path to the user's month-specific needs array for the specific year
        let documentRef = db.collection("users").document(uid).collection("years").document("\(year)").collection("months").document(monthKey)
        
        // Merge the new expense into the needs array, creating the document if it doesn't exist
        documentRef.setData([
            type : FieldValue.arrayUnion([expense.toDictionary()])
        ], merge: true) { error in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }

    
//    func saveNeedExpense(with expense: expense, completion: @escaping (Bool, Error?) -> Void) {
//        
//        guard let uid = Auth.auth().currentUser?.uid else {
//            completion(false, NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
//            return
//        }
//        
//        let db = Firestore.firestore()
//        
//        // Extract the month and year from the expense date
//        let dateFormatter = DateFormatter()
//        //    dateFormatter.dateFormat = "yyyy-MM" // Format as Year-Month
//        dateFormatter.dateFormat = "MMM" // Format as 'Jan'
//        let monthKey = dateFormatter.string(from: expense.date)
//        
//        let calendar = Calendar.current
//        let year = calendar.component(.year, from: expense.date)
//        
//        // Path to the user's month-specific needs array
//        //        let documentPath = "users/\(uid)/months/\(monthKey)"
//        
//        // Get a reference to the document
//        //        let documentRef = db.collection("users").document(uid).collection("months").document(monthKey)
//        
//
//        
//        // Get a reference to the document
//        let documentRef = db.collection("users").document(uid).collection("years").document("\(year)").collection("months").document(monthKey)
// 
//        
//        
//        // Merge the new expense into the needs array, creating the document if it doesn't exist
//        documentRef.setData([
//            "needs": FieldValue.arrayUnion([expense.toDictionary()])
//        ], merge: true) { error in
//            if let error = error {
//                completion(false, error)
//            } else {
//                completion(true, nil)
//            }
//        }
//    }
    
    
//    func saveWantExpense(with expense: expense, completion: @escaping (Bool, Error?) -> Void) {
//        guard let uid = Auth.auth().currentUser?.uid else {
//            completion(false, NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
//            return
//        }
//        
//        let db = Firestore.firestore()
//        
//        // Extract the month and year from the expense date
//        let dateFormatter = DateFormatter()
//        //    dateFormatter.dateFormat = "yyyy-MM" // Format as Year-Month
//        dateFormatter.dateFormat = "MMM" // Format as 'Jan'
//        let monthKey = dateFormatter.string(from: expense.date)
//        
//        //        // Path to the user's month-specific needs array
//        //        let documentPath = "users/\(uid)/months/\(monthKey)"
//        //        
//        //        // Get a reference to the document
//        //        let documentRef = db.collection("users").document(uid).collection("months").document(monthKey)
//        let calendar = Calendar.current
//        let year = calendar.component(.year, from: expense.date)
//        
//        // Path to the user's month-specific needs array
//        //        let documentPath = "users/\(uid)/months/\(monthKey)"
//        
//        // Get a reference to the document
//        //        let documentRef = db.collection("users").document(uid).collection("months").document(monthKey)
//        
//        // Path to the user's month-specific needs array for the specific year
//        var documentPath = "users/\(uid)/years/\(year)/months/\(monthKey)"
//        
//        // Get a reference to the document
//        let documentRef = db.collection("users").document(uid).collection("years").document("\(year)").collection("months").document(monthKey)
//
//        
//        // Merge the new expense into the needs array, creating the document if it doesn't exist
//        documentRef.setData([
//            "wants": FieldValue.arrayUnion([expense.toDictionary()])
//        ], merge: true) { error in
//            if let error = error {
//                completion(false, error)
//            } else {
//                completion(true, nil)
//            }
//        }
//    }
//    
//    func saveSavingExpense(with expense: expense, completion: @escaping (Bool, Error?) -> Void) {
//        guard let uid = Auth.auth().currentUser?.uid else {
//            completion(false, NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
//            return
//        }
//        
//        let db = Firestore.firestore()
//        
//        // Extract the month and year from the expense date
//        let dateFormatter = DateFormatter()
//        //    dateFormatter.dateFormat = "yyyy-MM" // Format as Year-Month
//        dateFormatter.dateFormat = "MMM" // Format as 'Jan'
//        let monthKey = dateFormatter.string(from: expense.date)
//        
//        //        // Path to the user's month-specific needs array
//        //        let documentPath = "users/\(uid)/months/\(monthKey)"
//        //        
//        //        // Get a reference to the document
//        //        let documentRef = db.collection("users").document(uid).collection("months").document(monthKey)
//        
//        let calendar = Calendar.current
//        let year = calendar.component(.year, from: expense.date)
//        
//        // Path to the user's month-specific needs array
//        //        let documentPath = "users/\(uid)/months/\(monthKey)"
//        
//        // Get a reference to the document
//        //        let documentRef = db.collection("users").document(uid).collection("months").document(monthKey)
//        
//        // Path to the user's month-specific needs array for the specific year
//        var documentPath = "users/\(uid)/years/\(year)/months/\(monthKey)"
//        
//        // Get a reference to the document
//        let documentRef = db.collection("users").document(uid).collection("years").document("\(year)").collection("months").document(monthKey)
//
//
//        
//        // Merge the new expense into the needs array, creating the document if it doesn't exist
//        documentRef.setData([
//            "savings": FieldValue.arrayUnion([expense.toDictionary()])
//        ], merge: true) { error in
//            if let error = error {
//                completion(false, error)
//            } else {
//                completion(true, nil)
//            }
//        }
//    }
    

    func getMonths(for year: Int, completion: @escaping ([String]?, Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(nil, NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        let db = Firestore.firestore()
        let yearRef = db.collection("users").document(uid).collection("years").document("\(year)")
        
        yearRef.collection("months").getDocuments { (snapshot, error) in
            if let error = error {
                completion(nil, error)
            } else {
                var months: [String] = []
                for document in snapshot?.documents ?? [] {
                    months.append(document.documentID)
                }
                completion(months, nil)
            }
        }
    }
    

    func getYears(completion: @escaping ([String]?, Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(nil, NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
    
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)
        
        print("Fetching years for UID: \(uid)")
        userRef.collection("years").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching years: \(error.localizedDescription)")
                completion(nil, error)
            } else {
                var years: [String] = []
                for document in snapshot?.documents ?? [] {
                    years.append(document.documentID)
                }
                print("Years fetched: \(years)")
                completion(years, nil)
            }
        }

   }
    






}



    



