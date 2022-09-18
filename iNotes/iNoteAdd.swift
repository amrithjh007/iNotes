//
//  iNoteAdd.swift
//  iNotes
//
//  Created by C2075387 on 17/09/22.
//

import SwiftUI

struct iNoteAdd: View {
    @State var title : String = ""
    @State var bodyString : String = ""
    @State var placeHolderText: String = "TypeSomething..."
    @StateObject var service = iNotesService()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var showImagePicker: Bool = false
    @State var image: Data? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10){
            TextField("Title",text: $title)
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
                //self.image = Image(uiImage: image)
                self.image = image.pngData()
            }
        }
        .navigationTitle("Add Notes")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    self.showImagePicker.toggle()
                } label: {
                    Image(systemName: "plus")
                }
                
                Button {
                    print("Save button was tapped")
                    service.addNote(title: title, bodyString: bodyString, image: image){ isSuccess in
                        if isSuccess {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                } label: {
                    Text("Save")
                }
            }
        }
    }
}


struct iNoteAdd_Previews: PreviewProvider {
    static var previews: some View {
        iNoteAdd()
    }
}


extension Binding where Value == String {
    func max(_ limit: Int) -> Self {
        if self.wrappedValue.count > limit {
            DispatchQueue.main.async {
                self.wrappedValue = String(self.wrappedValue.dropLast())
            }
        }
        return self
    }
}

