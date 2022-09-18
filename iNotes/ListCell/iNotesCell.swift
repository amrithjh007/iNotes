//
//  iNotesCell.swift
//  iNotes
//
//  Created by C2075387 on 17/09/22.
//

import SwiftUI

struct iNotesCell: View {
    var service : iNotesService = iNotesService()
    var title: String
    var createdTime: Int
    
    var body: some View {
        VStack(alignment: .center){
            Spacer(minLength: 5)
            Text(title)
                .font(.title)
                .bold()
                .foregroundColor(.black)
            Text(service.convertIntToDateString(inputTime: createdTime))
                .foregroundColor(.black)
            Spacer(minLength: 5)
        }
        .cornerRadius(15)
    }
}

struct iNotesCell_Previews: PreviewProvider {
    static var previews: some View {
        iNotesCell(title: "", createdTime: 0)
    }
}


extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}


extension UIColor {
    static func random() -> UIColor {
        return UIColor(
           red:   .random(),
           green: .random(),
           blue:  .random(),
           alpha: 1.0
        )
    }
}



