//
//  iNotesPhotoDisplay.swift
//  iNotes
//
//  Created by Amrith on 19/09/22.
//

import SwiftUI

struct iNotesPhotoDisplay: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var image: UIImage
    
    var body: some View {
        VStack{
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        }
        .onTapGesture {
            withAnimation {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct iNotesPhotoDisplay_Previews: PreviewProvider {
    static var previews: some View {
        iNotesPhotoDisplay(image: UIImage())
    }
}
