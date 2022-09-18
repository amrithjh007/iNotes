//
//  iNotesController.swift
//  iNotes
//
//  Created by Amrith on 17/09/22.
//

import Foundation
import Combine
import CoreData
import SwiftUI

class iNotesService: ObservableObject {
    @Environment(\.managedObjectContext) var viewContext
    @Published var notesList : [iNotesModel] = []
    
    func fetchNotes(){
        guard let url = URL(string: Constants.url) else { return }
        URLSession.shared.dataTask(with: url){ (data, error, _) in
            guard let data = data else { return }
            let notes = try! JSONDecoder().decode([iNotesModel].self, from: data)
            DispatchQueue.main.async {
                self.notesList = notes
            }
        }.resume()
    }
    
    func addNote(title: String, bodyString: String, image: Data?, completionHandler: @escaping ( _ isSuccess: Bool) -> Void){
        let note = iNotesModel(id: "NID\(getPropertyCount() + 1)",
                               archived: false,
                               title: title,
                               body: bodyString,
                               createdTime: converDateToInt(),
                               image: nil,
                               expiryTime: nil,
                               imageData: image)
        notesList.append(note)
        completionHandler(true)
    }
    
    func getPropertyCount() -> Int {
        let moc = PersistenceController.shared.container.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.entity)
        let count = try! moc.count(for: fetchRequest)
        return count
    }
    
    
    func convertIntToDateString(inputTime: Int) -> String {
        let timeInterval = TimeInterval(inputTime)
        let myNSDate = Date(timeIntervalSince1970: timeInterval)
        let dateFormatCoordinate = DateFormatter()
        dateFormatCoordinate.dateFormat = Constants.dateFormat
        let resultDate =  dateFormatCoordinate.string(from: myNSDate)
        return resultDate
    }
    
    func converDateToInt() -> Int{
        let someDate = Date()
        let timeInterval = someDate.timeIntervalSince1970
        let myInt = Int(timeInterval)
        return myInt
    }
    
}

