//
//  HomePageView.swift
//  budji
//
//  Created by JD Villanueva on 5/20/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct HomePageView: View {
    
    @State var progressBar = ProgressBar()
    @State var percent:CGFloat = 10
    @State var isGraphTapped = false
    @State private var showModal = false
    
    @State private var showBudgetSheet = false
    @State private var enteredBudget: String = ""
    
    
    var body: some View {
        
        let multiplier = progressBar.width/100
        
        NavigationStack{
            Image("happyFace")
                .resizable()
                .frame(width: 300, height:300)
                .aspectRatio(contentMode: .fill)
                .padding(.top,50)
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: progressBar.height, style: .continuous)
                    .frame(width: progressBar.width, height: progressBar.height)
                    .foregroundStyle(Color.black.opacity(0.1))
                
                RoundedRectangle(cornerRadius: progressBar.height, style: .continuous)
                    .frame(width: percent * multiplier, height: progressBar.height)
                    .background(LinearGradient(gradient: Gradient(colors: [progressBar.color1, progressBar.color2]), startPoint: .leading, endPoint: .trailing)
                        .clipShape(RoundedRectangle(cornerRadius: 20.0, style: .continuous))
                    )
                    .foregroundStyle(.clear)
            }
            
            VStack(spacing:10){
                Text("Daily Budget")
                    .font(.system(size: 20))
                    .fontWeight(.medium)
                    .foregroundStyle(Color.black.opacity(0.2))
                Text("$50")
                    .font(.system(size: 40))
                    .fontWeight(.bold)
                
                Label {
                    Text("$254")
                        .font(.system(size:20))
                        .fontWeight(.semibold)
                        .foregroundStyle(.green)
                } icon: {
                    Image(systemName: "arrowtriangle.up.fill")
                        .foregroundColor(.green)
                }
                
                Button(action: {
                    showModal = true
                }) {
                    Text("+ New Expense")
                        .foregroundStyle(.white)
                        .font(.title3)
                        .fontWeight(.bold)
                        .frame(width: 225, height: 50)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.cyan]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(20)
                }

                .fullScreenCover(isPresented: $showModal) {
                    
                    AddNewExpense(showModal: $showModal)
                }
                
            }
            .padding(30)
            
            Spacer()
                .navigationTitle("Home Page")
                .toolbar {
                    NavigationLink(destination: CalendarMainView()){
                        Image(systemName: "calendar")
                    }

                    NavigationLink(destination: GraphView()) {
                        Image(systemName: "chart.bar.fill")
                        }
                }
                .onAppear {
                      checkAndAddCurrentBudget()
                  }
                  .sheet(isPresented: $showBudgetSheet) {
                      VStack {
                          Text("Enter Current Monthly Budget")
                              .font(.title)
                              .padding()
                          
                          TextField("Monthly Budget", text: $enteredBudget)
                              .textFieldStyle(RoundedBorderTextFieldStyle())
                              .padding()
                              .keyboardType(.decimalPad)
                          
                          
                          Button(action: {
                              saveCurrentBudget()
                          }) {
                              Text("Save")
                                  .foregroundColor(.white)
                                  .padding()
                                  .background(Color.blue)
                                  .cornerRadius(10)
                          }
                          .padding()
                          
                          Spacer()
                      }
                      .padding()
                  }
        }
        
        

        
    }
    
    func checkAndAddCurrentBudget() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user logged in")
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)
        
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                
                if data?["currentBudget"] == nil {
                    showBudgetSheet = true
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func saveCurrentBudget() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user logged in")
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)
        
        if let budgetValue = Double(enteredBudget) {
            userRef.updateData([
                "currentBudget": budgetValue
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated with currentBudget")
                    showBudgetSheet = false
                }
            }
        } else {
            print("Invalid budget value")
        }
    }
}

#Preview {
    HomePageView()
}
