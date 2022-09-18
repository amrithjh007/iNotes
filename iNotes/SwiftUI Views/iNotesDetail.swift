//
//  iNotesDetail.swift
//  iNotes
//
//  Created by Amrith on 17/09/22.
//

import SwiftUI

struct iNotesDetail: View {
    
    var service : iNotesService = iNotesService()
    var title: String
    var bodyString: String
    var createdTime: Int
    var imageUI: UIImage
    @State private var displayImage: Bool = false
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading, spacing: 10){
                if checkIfImageIsAvailable(image: imageUI) {
                    withAnimation {
                        imageView()
                            .scaleEffect(displayImage ? 5 : 1)
                            .animation(.linear(duration: 1), value: 5)
                    }
                }
                textView()
                    .opacity(displayImage ? 0 : 1)
            }
            .sheet(isPresented: $displayImage) {
                displayImage = false
            } content: {
                iNotesPhotoDisplay(image: imageUI)
            }
        }
    }
    
    @ViewBuilder func textView() -> some View {
        Text(title)
            .font(.title)
            .bold()
            .padding([.leading, .trailing], 15)
        
        Text(service.convertIntToDateString(inputTime: createdTime))
            .font(.subheadline)
            .padding([.leading, .trailing], 15)
        
        Text(.init(bodyString))
            .font(.title3.leading(.loose))
            .padding([.leading, .trailing], 15)
            .lineSpacing(20)
    }
    
    @ViewBuilder func imageView() -> some View {
        Image(uiImage: imageUI)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .onTapGesture {
                displayImage = true
            }
    }
    
    func checkIfImageIsAvailable(image: UIImage?) -> Bool{
        let cgref = image?.cgImage
        let cim = image?.ciImage
        if cim == nil && cgref == nil {
            return false
        }
        return true
    }
}

struct iNotesDetail_Previews: PreviewProvider {
    static var previews: some View {
        iNotesDetail(service: iNotesService(), title: Constants.emptyString, bodyString:  Constants.emptyString, createdTime: 0, imageUI: UIImage())
    }
}
