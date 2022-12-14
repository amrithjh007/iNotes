//
//  iNoteAdd.swift
//  iNotes
//
//  Created by Amrith on 17/09/22.
//

import SwiftUI

struct iNoteAdd: View {
    @State var title : String = Constants.emptyString
    @State var bodyString : String = Constants.emptyString
    @State var placeHolderText: String = Constants.placeHolder
    @StateObject var service = iNotesService()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var showImagePicker: Bool = false
    @State var image: Data? = nil
    @State var imageIsSelected: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10){
            TextField(Constants.title,text: $title)
                .padding()
                .font(.title)
                .onReceive(title.publisher.collect()) {
                    self.title = String($0.prefix(20))
                }
            ZStack {
                if self.bodyString.isEmpty {
                    TextEditor(text: $placeHolderText)
                        .font(.body)
                        .foregroundColor(.gray)
                        .disabled(true)
                        .padding()
                        .opacity(0.7)
                }
                TextEditor(text: $bodyString)
                    .font(.title3)
                    .opacity(self.bodyString.isEmpty ? 0.25 : 1)
                    .padding()
            }
        } .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: .photoLibrary) { image in
                self.image = image.pngData()
                imageIsSelected = true
            }
        }
        .navigationTitle(Constants.addNotes)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    self.showImagePicker.toggle()
                } label: {
                    Image(systemName: Constants.plus)
                }
                .background(imageIsSelected ? .green : .clear)
                .clipShape(Capsule())
                
                Button {
                    service.addNote(title: title, bodyString: bodyString, image: image){ isSuccess in
                        if isSuccess {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                } label: {
                    Text(Constants.save)
                }.disabled(title.isEmpty ? true : false)
            }
        }
    }
}


struct iNoteAdd_Previews: PreviewProvider {
    static var previews: some View {
        iNoteAdd()
    }
}

