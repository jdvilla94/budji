//
//  GraphView.swift
//  budji
//
//  Created by JD Villanueva on 5/25/24.
//

import SwiftUI
import Charts
import Firebase
import FirebaseFirestore

struct GraphView: View {
    
    @State private var amount: [expense] = []
    @State private var amountTwo: [expense] = []
    @State private var amountThree: [expense] = []
    @State private var error: Error? = nil
    @State private var selectedExpense: expense?
    
    @State private var currentMonthString: String?
    

    
    
    
    func currentMonth() {
        let date = Date() // Step 1: Get the current date
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM" // Step 2: Set the format to "MMM"
        currentMonthString = formatter.string(from: date)
        print("The current month is: \(currentMonthString)")
        /*return formatter.string(from: date)*/ // Step 3: Format the date and return the string
    }
    
    
    var needsPercentage = 0.50
    var wantsPercentage = 0.30
    var savingsPercentage = 0.20
    
    @State private var selectedCount: Int?
    
    @State private var monthlyBudget: Double  = 0.0

    
    
    // Computed property to calculate the sum of all amounts in the `amount` array
    private var totalAmount: Double {
        amount.reduce(0) { $0 + $1.amount } +  amountTwo.reduce(0) { $0 + $1.amount } +  amountThree.reduce(0) { $0 + $1.amount }
    }
    
    private var needsAmount : Double{
        amount.reduce(0) { $0 + $1.amount }
    }
    
    private var wantsAmount : Double{
        amountTwo.reduce(0) { $0 + $1.amount }
    }
    
    private var savingsAmount : Double{
        amountThree.reduce(0) { $0 + $1.amount }
    }
    
    
    var body: some View {
        HStack{
            Spacer()
            Text("Monthly Budget: $\(String(format: "%.2f",monthlyBudget))")
                .padding(.trailing,30)

        }
        
//        Spacer()
        
        VStack {
            if amount.isEmpty && amountTwo.isEmpty && amountThree.isEmpty{
                Text("Loading...")
                         ProgressView()
                             .progressViewStyle(CircularProgressViewStyle())
                             .scaleEffect(1.5) // Adjust the size if needed
            } else {
                Chart {
                    ForEach(amount) { expense in
                        SectorMark(
                            angle: .value("Amount", expense.amount),
                            innerRadius: .ratio(0.65),
                            outerRadius: selectedExpense?.name == expense.name ? 125 : 100,
                            angularInset: 1
                        )
                        .foregroundStyle(.cyan)
                        .cornerRadius(10)
         
                    }
                    
                    ForEach(amountTwo) { expense in
                        SectorMark(
                            angle: .value("Amount", expense.amount),
                            innerRadius: .ratio(0.65),
                            outerRadius: selectedExpense?.name == expense.name ? 125 : 100,
                            angularInset: 1
                        )
                        .foregroundStyle(.orange)
                        .cornerRadius(10)
                    }
                    ForEach(amountThree) { expense in
                        SectorMark(
                            angle: .value("Amount", expense.amount),
                            innerRadius: .ratio(0.65),
                            outerRadius: selectedExpense?.name == expense.name ? 125 : 100,
                            angularInset: 1
                        )
                        .foregroundStyle(.green)
                        .cornerRadius(10)
                    }
                }
                
                .chartAngleSelection(value: $selectedCount)
                .chartBackground { _ in
                    VStack{
                        Text("$\(String(format: "%.2f",monthlyBudget - totalAmount))")
                        Text("Left to spend")
                    }
                    
                    
//                        if let selectedExpense {
//                            VStack {
//
//                                Text("$\(String(format: "%.2f", selectedExpense.amount))")
////                                Image(systemName: "wineglass.fill")
////                                    .font(.largeTitle)
////                                    .foregroundStyle(Color(.blue))
////                                Text(selectedExpense.name)
////                                    .font(.largeTitle)
////                                Text("In Stock: \(String(format: "%.2f", selectedExpense.amount))")
//
//                            }
//                        } else {
//                            VStack {
//                                Image(systemName: "wineglass.fill")
//                                    .font(.largeTitle)
//                                    .foregroundColor(.red)
//                                Text("Select a segment")
//                            }
//                        }
                }
                .frame(height: 250)
      
                ///display text for every selected expense chosen
                if let selectedExpense = selectedExpense {
                    Text("Selected Expense: \(selectedExpense.name)")
                    Text("Amount: \(String(format: "%.2f", selectedExpense.amount))")
                    Text("Category: \(selectedExpense.category)")
             
                }

                Spacer()
                
                VStack(spacing: 20){
                    NavigationLink(destination: needsDetailView(amount: $amount,amountTwo: $amountTwo, amountThree: $amountThree)) {
                        NeedsViewModel(needsAmount: needsAmount, percentageVar: needsPercentage, totalAmount: monthlyBudget)
                            .contentShape(Rectangle()) // Ensures the entire area of the NeedsViewModel is clickable
                    }
                    
                    NavigationLink(destination: wantsDetailView(amount: $amount, amountTwo: $amountTwo, amountThree: $amountThree)) {
                        WantsViewModel(wantsAmount: .constant(wantsAmount), percentageVar: wantsPercentage, totalAmount: monthlyBudget)
                            .contentShape(Rectangle()) // Ensures the entire area of the NeedsViewModel is clickable
                    }
                    
                    NavigationLink(destination: savingsDetailView(amount: $amount, amountTwo: $amountTwo, amountThree: $amountThree)) {
                        SavingsViewModel(savingAmount: .constant(savingsAmount), percentageVar: savingsPercentage, totalAmount: monthlyBudget)
                            .contentShape(Rectangle()) // Ensures the entire area of the NeedsViewModel is clickable
                    }
                    
                }
                
                Spacer()
                
            }
            Spacer()
        }
        .onChange(of: selectedCount) { oldValue, newValue in
            if let newValue{
                withAnimation{
                    print("the new value is: \(Double(newValue))")
                    getSelectedExpense(value: Double(newValue))
                }
                
            }
        }
        
        
        .padding()
//        .navigationTitle("Donut Chart")
        .onAppear {
            retrieveData()
            checkAndAddCurrentBudget()
//            currentMonth()
        }
        .navigationBarTitleDisplayMode(.inline)
        .contentShape(Rectangle())
           .onTapGesture {
               selectedExpense = nil
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
                if let currentBudget = data?["currentBudget"] as? Double {
                    monthlyBudget = currentBudget
                } else {
                    print("currentBudget field is missing")
                }
            } else {
                print("Document does not exist")
            }
        }
    }

    

    
    
    private func getSelectedExpense(value: Double) {
        var cumulativeTotal = 0.0
        
        for expense in amount {
            cumulativeTotal += expense.amount
            if value <= cumulativeTotal {
                selectedExpense = expense
                return
            }
        }
        
        for expense in amountTwo {
            cumulativeTotal += expense.amount
            if value <= cumulativeTotal {
                selectedExpense = expense
                return
            }
        }
        
        for expense in amountThree {
            cumulativeTotal += expense.amount
            if value <= cumulativeTotal {
                selectedExpense = expense
                return
            }
        }
        
        selectedExpense = nil // If nothing is found, set to nil
    }
    
    private func retrieveData(){
        currentMonth()
        FirebaseAuth.shared.getNeedVariable(month: currentMonthString, year: String(Date.now.yearInt)) { (needs, error) in
            if let error = error {
                // Handle error
                self.error = error
            } else if let needs = needs {
                // Log the needs data
                print("Fetched needs data: \(needs)")

                // Assign fetched needs directly to 'amount'
                DispatchQueue.main.async {
                    self.amount = needs // Ensure to update the state on the main thread
                }

                // Log the mapped amount data
                print("Mapped amount data: \(self.amount)")
            }
        }
        
        FirebaseAuth.shared.getWantVariable(month: currentMonthString, year: String(Date.now.yearInt)) { (wants, error) in
            if let error = error {
                // Handle error
                self.error = error
            } else if let wants = wants {
                // Log the needs data
                print("Fetched wants data: \(wants)")

                // Assign fetched needs directly to 'amount'
                DispatchQueue.main.async {
                    self.amountTwo = wants // Ensure to update the state on the main thread

                }

                // Log the mapped amount data
                print("Mapped amount data: \(self.amountTwo)")
            }
        }
        
        FirebaseAuth.shared.getSavingVariable(month: currentMonthString, year: String(Date.now.yearInt)) { (saving, error) in
            if let error = error {
                // Handle error
                self.error = error
            } else if let saving = saving {
                // Log the needs data
                print("Fetched savings data: \(saving)")

                // Assign fetched needs directly to 'amount'
                DispatchQueue.main.async {
                    self.amountThree = saving // Ensure to update the state on the main thread

                }

                // Log the mapped amount data
                print("Mapped amount data: \(self.amountThree)")
            }
        }
        
        

        
    }
    
    
}


#Preview {
    GraphView()
}


// DateFormatter extension to handle Firestore date format
extension DateFormatter {
    static let firestoreDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}

