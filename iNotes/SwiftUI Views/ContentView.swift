//
//  ContentView.swift
//  iNotes
//
//  Created by Amrith on 17/09/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) var viewContext
    
    @FetchRequest(
        entity: Item.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.createdTime, ascending: true)],
        animation: .default)
    
    private var items: FetchedResults<Item>
    @StateObject var service = iNotesService()
    @State var enableAddNote: Bool = false
    @State private var isAnimating: Bool = false
    @State private var isShowAlert: Bool = false
    @State private var errorMessage: String = Constants.emptyString
    
    var foreverAnimation: Animation {
        Animation.linear(duration: 2.0)
            .repeatForever(autoreverses: false)
    }
    
    private var columns: [GridItem] = [
        GridItem(.flexible(minimum: 100)),
        GridItem(.flexible())
    ]
    
    let colorArray: [Color] = [.red, .yellow, .gray, .green, .blue, .brown, .cyan, .indigo, .mint, .orange, .pink]
    
    var body: some View {
        Spacer(minLength: 5)
        NavigationView {
            ZStack(alignment: .bottomTrailing){
                ScrollView{
                    lazyGridView()
                }
                addNewNoteView()
                NavigationLink.init(Constants.emptyString, isActive: $enableAddNote) {
                    iNoteAdd(service: self.service)
                }
            }
            .alert(isPresented: $isShowAlert){
                Alert(title: Text(Constants.emptyString), message: Text(self.errorMessage), dismissButton: .default(Text(Constants.ok), action: {
                    self.isShowAlert = false
                }))
            }
            .toolbar(content: {
                Button {
                    resetAllRecords(in: Constants.entity) { isSuccess in
                        if isSuccess {
                            service.notesList.removeAll()
                        }
                    }
                } label: {
                    Text(Constants.deleteAll)
                }.opacity(0)
            })
            .navigationTitle(Constants.iNotes)
            .navigationBarTitleDisplayMode(.automatic)
        }
        .onAppear {
            if !isAppAlreadyLaunchedOnce() {
                service.fetchNotes()
            }
        }
        .onChange(of: service.notesList, perform: { newValue in
            for notes in service.notesList{
                let value = printAllValues()
                if !value.contains(notes.title){
                    addItem(notes: notes)
                }
            }
        })
        .preferredColorScheme(.dark)
    }
    
    @ViewBuilder func lazyGridView() -> some View {
        LazyVGrid(columns: columns, spacing: 5) {
            ForEach(items) { item in
                NavigationLink {
                    if let item = item{
                        if item.title != nil && item.title != Constants.emptyString{
                            iNotesDetail(service: self.service, title: item.title ?? Constants.emptyString, bodyString: item.body ?? Constants.emptyString, createdTime: Int(item.createdTime), imageUI: loadImage(notesImageData: item.imageData))
                        }
                    }
                } label: {
                    if let item = item{
                        if item.title != nil && item.title != Constants.emptyString{
                            iNotesCell(title: item.title ?? Constants.emptyString, createdTime: Int(item.createdTime))
                                .background(colorArray.randomElement())
                                .cornerRadius(10)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder func addNewNoteView() -> some View {
        Button {
            enableAddNote.toggle()
        } label: {
            Image(systemName: Constants.plus)
                .foregroundColor(.white)
                .rotationEffect(Angle(degrees: self.isAnimating ? 360 : 0.0))
                .animation(self.isAnimating ? foreverAnimation : .default, value: self.isAnimating)
                .onAppear { self.isAnimating = true }
                .onDisappear { self.isAnimating = false }
        }
        .scaleEffect(enableAddNote ? 1.5 : 1.0)
        .frame(width: 50, height: 50)
        .buttonStyle(PlainButtonStyle())
        .background(Color.gray)
        .clipShape(Capsule())
        .padding(.trailing, 15)
        .scaledToFill()
    }
}

extension ContentView{
    //MARK: Convert Data to UIImage
    func loadImage(notesImageData: Data?) -> UIImage {
        if let imgData = notesImageData{
            return fetchImage(imageData: imgData)
        } else {
            return UIImage()
        }
    }
    
    // MARK: Convert Data to Image
    func fetchImage(imageData: Data) -> UIImage{
        return UIImage(data: imageData) ?? UIImage()
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL, completionHandler: @escaping ( _ isSuccess: Data) -> Void){
        var imageData: Data = Data()
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            imageData = data
            completionHandler(imageData)
        }
    }
    
    //MARK: Convert Image/Image String to Data
    func loadDataFromURL(notes: iNotesModel, completion: @escaping (_ isSuccess: Data) -> ()) {
        if notes.image != Constants.emptyString && notes.image != nil {
            var data = Data()
            if let url = URL(string: notes.image ?? Constants.emptyString) {
                downloadImage(from: url) { imgdata in
                    data = imgdata
                    if checkIfImageIsAvailable(image: UIImage(data: data)) {
                        completion(data)
                    } else{
                        completion( notes.imageData ?? Data() )
                    }
                }
            }
        } else {
            completion( notes.imageData ?? Data() )
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
    
    //Check if App is launched for first time
    func isAppAlreadyLaunchedOnce()->Bool{
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: Constants.appLaunch){
            return true
        }else{
            defaults.set(true, forKey: Constants.appLaunch)
            return false
        }
    }
}

extension ContentView {
    //MARK: Core data methods
    //Save values to Entity
    func addItem(notes: iNotesModel) {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.id = notes.id
            newItem.archived = notes.archived
            newItem.title = notes.title
            newItem.body = notes.body
            newItem.createdTime = Int64(notes.createdTime )
            newItem.expiryTime = Int64(notes.expiryTime ?? 0)
            loadDataFromURL(notes: notes) { imgData in
                newItem.imageData = imgData
            }
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                self.errorMessage = nsError.localizedDescription
                isShowAlert = true
            }
        }
    }
    
    //Delete all values from Entity
    private func resetAllRecords(in entity : String, completionHandler: @escaping ( _ isSuccess: Bool) -> Void)
    {
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do
        {
            try viewContext.execute(deleteRequest)
            try viewContext.save()
        }
        catch
        {
            let nsError = error as NSError
            self.errorMessage = nsError.localizedDescription
            isShowAlert = true
        }
        completionHandler(true)
    }
    
    //Delete values at particular indexSet
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                self.errorMessage = nsError.localizedDescription
                isShowAlert = true
            }
        }
    }
    
    //Print all titles of values present
    func printAllValues() -> [String]{
        var titleArr: [String] = []
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.entity)
            request.returnsObjectsAsFaults = false
            let results = try viewContext.fetch(request) as [Item]
            if (results.count > 0) {
                for result in results {
                    titleArr.append(result.title ?? Constants.emptyString)
                }
            } else {
                self.errorMessage = Constants.errorMessage
                isShowAlert = true
            }
        } catch let error as NSError {
            let nsError = error as NSError
            self.errorMessage = nsError.localizedDescription
            isShowAlert = true
        }
        return titleArr
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
