//
//  Track+CoreDataClass.swift
//  KumuExam
//
//  Created by Bryan Vivo on 11/26/20.
//
//

import Foundation
import CoreData

extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")
}

enum CoreDataNames: String {
    case containerName = "KumuExam"
    case entityName = "Track"
}


public struct RawServerResponse: Decodable {
    let resultCount: Int
    let results: [Track]

}

@objc(Track)
public class Track: NSManagedObject, Codable {

    @NSManaged public var artistName: String?
    @NSManaged public var artworkUrl100: String?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var longDescription: String?
    @NSManaged public var primaryGenreName: String?
    @NSManaged public var trackId: Int64
    @NSManaged public var trackName: String?
    @NSManaged public var trackPrice: Double
   

    
    enum CodingKeys: String, CodingKey {
      
        case artistName
        case artworkUrl100
        case isFavorite
        case longDescription
        case primaryGenreName
        case trackId
        case trackName
        case trackPrice
      
    }
    
    public required convenience init(from decoder: Decoder) throws {
        
        guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext,
            let managedObjectContext = decoder.userInfo[codingUserInfoKeyManagedObjectContext] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: CoreDataNames.entityName.rawValue, in: managedObjectContext) else {
                fatalError("Failed to decode User")
        }
    
        self.init(entity: entity, insertInto: managedObjectContext)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        artistName = try container.decode(String.self, forKey: .artistName)
        artworkUrl100 = try container.decodeIfPresent(String.self, forKey: .artworkUrl100) ?? ""
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
        primaryGenreName = try container.decode(String.self, forKey: .primaryGenreName)
        longDescription = try container.decodeIfPresent(String.self, forKey: .longDescription) ?? ""
        trackId = try container.decode(Int64.self, forKey: .trackId)
        trackName = try container.decode(String.self, forKey: .trackName)
        trackPrice = try container.decode(Double.self, forKey: .trackPrice)
    }
    
    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(artistName, forKey: .artistName)
        try container.encode(artworkUrl100, forKey: .artworkUrl100)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encode(primaryGenreName, forKey: .primaryGenreName)
        try container.encode(longDescription, forKey: .longDescription)
        try container.encode(trackId, forKey: .trackId)
        try container.encode(trackName, forKey: .trackName)
        try container.encode(trackPrice, forKey: .trackPrice)
      
    }
}
