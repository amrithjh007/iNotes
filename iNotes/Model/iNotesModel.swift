//
//  iNotesModel.swift
//  iNotes
//
//  Created by Amrith on 17/09/22.
//

import Foundation

// MARK: - iNotesModel
struct iNotesModel: Codable, Hashable {
    let id: String
    let archived: Bool
    let title, body: String
    let createdTime: Int
    let image: String?
    let expiryTime: Int?
    let imageData: Data?

    enum CodingKeys: String, CodingKey {
        case id, archived, title, body
        case createdTime = "created_time"
        case image
        case expiryTime = "expiry_time"
        case imageData
    }
}
