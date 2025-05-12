//
//  Landmark.swift
//  CashUp
//
//  Created by Gustavo Souto Pereira on 08/05/25.
//

import SwiftUI


struct LandmarkRow: View {
    var landmark: Landmark


    var body: some View {
        HStack {
            landmark.image
                .resizable()
                .frame(width: 50, height: 50)
            Text(landmark.name)


            Spacer()
        }
    }
}


#Preview{
    Group{
        LandmarkRow(landmark: landmarks[0]) //turtle rock
        LandmarkRow(landmark: landmarks[1]) //salmon
    }
}

