//
//  CalendarView.swift
//  budji
//
//  Created by JD Villanueva on 6/17/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct CalendarView: View {
    
//    @State private var date = Date.now
    let date: Date
    @State private var error: Error? = nil
//    @State private var yearsArray : [String] = []
//    @State private var monthsArray : [String] = []
//
//    @State private var selectedMonth = Date.now.monthInt
//    @State private var selectedYear = Date.now.yearInt
    
    
    let daysOfTheWeek = Date.capitalizedFirstLettersOfWeekdays
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    @State private var counts = [Int:Int]()
    @State private var amount: [expense] = []
    @State private var amountTwo: [expense] = []
    @State private var amountThree: [expense] = []
    @State private var selectedExpense: expense?
    @State private var arrayOfExpenses: [expense] = []
  
    
    @State private var days: [Date] = []
    @State private var currentDayTapped = Date.now.dayInt
    
    @Binding var selectedYear: Int
    @Binding var selectedMonth: Int
    
    
    // Explicit initializer
    init(selectedYear: Binding<Int>, selectedMonth: Binding<Int>, date: Date, amount: [expense]) {
        self._selectedYear = selectedYear
        self._selectedMonth = selectedMonth
        self.date = date
        self._amount = State(initialValue: amount)
    }
    
    
    var body: some View {
        VStack{
//            LabeledContent("Date/Time"){
//                DatePicker("",selection: $date)
//            }
            
            HStack{
                ForEach(daysOfTheWeek, id:\.self) { dayOfWeek in
                    Text(dayOfWeek)
                        .fontWeight(.black)
                        .frame(maxWidth: .infinity)
                }
            }
            
            LazyVGrid(columns: columns) {
                ForEach(days, id: \.self){ day in
                    if day.monthInt != date.monthInt{
                        Text("")
                    }else{
                        Text(day.formatted(.dateTime.day()))
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity , maxHeight: 40)
                            .background(
                                Circle()
                                    .foregroundStyle(
                                        Date.now.startOfDay == day.startOfDay
                                        ? .red.opacity(counts[day.dayInt] != nil ? 0.8 : 0.3)
                                        :  .cyan.opacity(counts[day.dayInt] != nil ? 0.8 : 0.3)                                    )
                            )
                            .overlay(alignment: .bottomTrailing) {
                                if let count = counts[day.dayInt] {
                                    Image(systemName: count <= 50 ? "\(count).circle.fill" : "plus.circle.fill")
                                        .foregroundColor(.secondary)
                                        .imageScale(.medium)
                                        .background (
                                            Color(.systemBackground)
                                                .clipShape(.circle)
                                        )
                                        .offset(x: 5, y: 5)
                                }
                            }
                        
                            .onTapGesture {
                                handleDayTap(day: day)
                            }
                    }
     
                }
            }
            if !arrayOfExpenses.isEmpty {
                 Text("Expenses for: \(getMonthName(month: selectedMonth)) \(currentDayTapped)")
                 List {
                     ForEach(arrayOfExpenses) { expense in
                         VStack(alignment: .leading) {
                             Text("Expense: \(expense.name)")
                             Text("Amount: \(String(format: "%.2f", expense.amount))")
                             Text("Category: \(expense.category)")
                             Text("Date: \(expense.date.formatted(.dateTime.day().month().year()))")
                         }
                         .padding()
                     }
                 }
            }else{
                List{
                    Text("There are no expenses for: \(getMonthName(month: selectedMonth)) \(currentDayTapped) ")
                }
            }
            
        }
        
        .padding()
        .onAppear {
            fetchData()
            days = date.calendarDisplayDays
//            handleDayTap(day: date)
            
        }
        .onChange(of: date) {
            arrayOfExpenses.removeAll()
            fetchData()
            days = date.calendarDisplayDays
//            handleDayTap(day: date)
       
        }
        
    }
    
    func fetchData() {
        let monthName = getMonthName(month: selectedMonth)
        print("Fetching data for month: \(monthName), year: \(selectedYear)")
        FirebaseAuth.shared.getNeedVariable(month: monthName, year: String(selectedYear)) { (needs, error) in
            if let error = error {
                self.error = error
                DispatchQueue.main.async {
             
                    self.amount = []  // Reset amount to empty array if needs is nil
                
                    self.setUpCount()
                    
                    self.updateCurrentDayExpenses()
                    
                    print("Amount after fetch:", self.amount)
                    print("Counts after setup:", self.counts)
                }
                print("Error fetching data:", error.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    if let needs = needs {
                        self.amount = needs  // Update amount with new data
                    } else {
                        self.amount = []  // Reset amount to empty array if needs is nil
                    }
                    self.setUpCount()
                    
                    self.updateCurrentDayExpenses()
                    
                    print("Amount after fetch:", self.amount)
                    print("Counts after setup:", self.counts)
                }
            }
        }
        
        FirebaseAuth.shared.getWantVariable(month: monthName, year: String(selectedYear)) { (wants, error) in
            if let error = error {
                self.error = error
                DispatchQueue.main.async {
             
                    self.amountTwo = []  // Reset amount to empty array if needs is nil
                
                    self.setUpCount()
                    
                    self.updateCurrentDayExpenses()
                    
                    print("Amount after fetch:", self.amount)
                    print("Counts after setup:", self.counts)
                }
                print("Error fetching data:", error.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    if let wants = wants {
                        self.amountTwo = wants  // Update amount with new data
                    } else {
                        self.amountTwo = []  // Reset amount to empty array if needs is nil
                    }
                    self.setUpCount()
                    
                    self.updateCurrentDayExpenses()
                    
                    print("Amount after fetch:", self.amount)
                    print("Counts after setup:", self.counts)
                }
            }
        }
        
        FirebaseAuth.shared.getSavingVariable(month: monthName, year: String(selectedYear)) { (saving, error) in
            if let error = error {
                self.error = error
                DispatchQueue.main.async {
             
                    self.amountThree = []  // Reset amount to empty array if needs is nil
                
                    self.setUpCount()
                    
                    self.updateCurrentDayExpenses()
                    
                    print("Amount after fetch:", self.amount)
                    print("Counts after setup:", self.counts)
                }
                print("Error fetching data:", error.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    if let saving = saving {
                        self.amountThree = saving  // Update amount with new data
                    } else {
                        self.amountThree = []  // Reset amount to empty array if needs is nil
                    }
                    self.setUpCount()
                    
                    self.updateCurrentDayExpenses()
                    
                    print("Amount after fetch:", self.amount)
                    print("Counts after setup:", self.counts)
                }
            }
        }
    }

    
//    func setUpCount(){
//        let mappedItems = amount.map { ($0.date.dayInt, 1) }
//        counts = Dictionary(mappedItems, uniquingKeysWith: +)
//        
//    }
    
    func setUpCount() {
        let combinedAmounts = amount + amountTwo + amountThree
        let mappedItems = combinedAmounts.map { ($0.date.dayInt, 1) }
        counts = Dictionary(mappedItems, uniquingKeysWith: +)
    }
    
    func updateCurrentDayExpenses() {
        let today = Date.now
        currentDayTapped = today.dayInt
        if let count = counts[today.dayInt], count > 0 {
            let expensesForDay = (amount + amountTwo + amountThree).filter { $0.date.dayInt == today.dayInt }
            arrayOfExpenses.append(contentsOf: expensesForDay)
        }
    }

    
//    func updateCurrentDayExpenses() {
//           let today = Date.now
//           currentDayTapped = today.dayInt
//           if let count = counts[today.dayInt], count > 0 {
//               let expensesForDay = amount.filter { $0.date.dayInt == today.dayInt }
//               arrayOfExpenses.append(contentsOf: expensesForDay)
//           }
//       }
    
    func getMonthName(month: Int) -> String {
        switch month {
        case 1: return "Jan"
        case 2: return "Feb"
        case 3: return "Mar"
        case 4: return "Apr"
        case 5: return "May"
        case 6: return "Jun"
        case 7: return "Jul"
        case 8: return "Aug"
        case 9: return "Sep"
        case 10: return "Oct"
        case 11: return "Nov"
        case 12: return "Dec"
        default: return ""
        }
    }
    
    func handleDayTap(day: Date) {
        arrayOfExpenses.removeAll()
        currentDayTapped = day.dayInt
        
        if let count = counts[day.dayInt], count > 0 {
            let combinedAmounts = amount + amountTwo + amountThree
            let expensesForDay = combinedAmounts.filter { $0.date.dayInt == day.dayInt }
            arrayOfExpenses.append(contentsOf: expensesForDay)
        }
    }

    
//    func handleDayTap(day: Date) {
//        arrayOfExpenses.removeAll()
//        currentDayTapped = day.dayInt
//        if let count = counts[day.dayInt], count > 0 {
//            let expensesForDay = amount.filter { $0.date.dayInt == day.dayInt }
//            arrayOfExpenses.append(contentsOf: expensesForDay)
//        }
//    }



}



#Preview {
    CalendarView(selectedYear: .constant(Date.now.yearInt), selectedMonth: .constant(Date.now.monthInt), date: Date.now, amount: [])
}
