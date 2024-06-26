//
//  NeedsGridView.swift
//  budji
//
//  Created by JD Villanueva on 5/29/24.
//

import SwiftUI

final class NeedsGridView: ObservableObject{
    
    var selectedFramework: AnyCategory?{
        didSet{isShowingDetailView = true}
    }

    @Published var isShowingDetailView = false
    
    let columns: [GridItem] = [GridItem(.flexible()),
                               GridItem(.flexible())
                                ]
    
    
}

