//
//  CalendarMainView.swift
//  budji
//
//  Created by JD Villanueva on 6/18/24.
//

import SwiftUI

struct CalendarMainView: View {
    
    @State private var monthDate = Date.now
    @State private var yearsArray : [String] = []
    @State private var monthsArray : [String] = []
    
    
    @State private var selectedMonth = Date.now.monthInt
    @State private var selectedYear = Date.now.yearInt
    let months = Date.fullMonthNames
    

    
    var body: some View {
        NavigationStack{
            VStack{
                HStack {
                    Picker("", selection: $selectedYear){
                        ForEach(yearsArray,id: \.self) { year in
                            Text(String(year))
                                .tag(Int(year) ?? 0) // Convert year string to Int or provide a default tag
                                
                        }
                    }

                    Picker("",selection: $selectedMonth){
                        ForEach(months.indices, id: \.self) { index in
                            Text(months[index]).tag(index + 1)
                        }
                    }
                }
                CalendarView(selectedYear: $selectedYear, selectedMonth: $selectedMonth, date: monthDate, amount: [])
                
//                CalendarView(date: monthDate, amount: expense.sampleExpenses)
                Spacer()
                
            }
            .onAppear {
                FirebaseAuth.shared.getYears { years, error in
                    if let error = error {
                        print("Error fetching years: \(error)")
                    } else if let years = years {
                        yearsArray = years
                        print("The length of the years is: \(years.count)")
                        
                        print("Years: \(years)")
                    } else {
                        print("No years found")
                    }
                }
               
            }
            .onChange(of: selectedYear) {
                updateDate()
            }
            .onChange(of: selectedMonth) {
                updateDate()
            }

            .navigationTitle("Calendar")
            
        }
        
        
}

    
    func updateDate() {
        monthDate = Calendar.current.date(from: DateComponents(year: selectedYear, month: selectedMonth, day: 1))!
    }
    
}



#Preview {
    CalendarMainView()
}


