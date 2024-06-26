//
//  CardViewTitles.swift
//  budji
//
//  Created by JD Villanueva on 5/29/24.
//

import SwiftUI

struct CardViewTitles : View{
    
   
    
//    let cardTtitle: NeedsCategories
    let cardTitle : AnyCategory
    
    var body: some View {
  
        VStack(spacing: 10){
            if UIImage(systemName: cardTitle.image) != nil {
                   Image(systemName: cardTitle.image)
                       .resizable()
                       .aspectRatio(contentMode: .fit)
                       .frame(width: 50, height: 50, alignment: .center)
               } else {
                   Image(cardTitle.image.isEmpty ? "defaultAssetName" : cardTitle.image) // Replace "defaultAssetName" with the name of your default image asset
                       .resizable()
                       .aspectRatio(contentMode: .fit)
                       .frame(width: 50, height: 50, alignment: .center)
               }
               
            Text(cardTitle.name)
                .fontWeight(.bold)
                .font(.system(size:20))
//                .scaledToFit()
                .minimumScaleFactor(0.6)
        }
        .frame(width: 150, height: 150)
        .background(Color.white) // Add background color to ensure the shadow and border are visible
        .cornerRadius(10)
        .shadow(color: .gray, radius: 5, x: 0, y: 5)
        .padding()
    }
}
#Preview {
    CardViewTitles(cardTitle: NeedsData.data
    )
}
