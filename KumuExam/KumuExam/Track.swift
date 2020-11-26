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


@objc(Track)
public class Track: NSManagedObject {

    @NSManaged public var artistName: String?
    @NSManaged public var artworkUrl100: String?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var primaryGenreName: String?
    @NSManaged public var releaseDate: String?
    @NSManaged public var trackID: Int32
    @NSManaged public var trackName: String?
    @NSManaged public var trackPrice: Double

    
    enum CodingKeys: String, CodingKey {
      
        case artistName
        case artworkUrl100
        case isFavorite
        case primaryGenreName
        case releaseDate
        case trackID
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
        artworkUrl100 = try container.decode(String.self, forKey: .artworkUrl100)
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
        primaryGenreName = try container.decode(String.self, forKey: .primaryGenreName)
        releaseDate = try container.decode(String.self, forKey: .releaseDate)
        trackID = try container.decode(Int32.self, forKey: .trackID)
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
        try container.encode(releaseDate, forKey: .releaseDate)
        try container.encode(trackID, forKey: .trackID)
        try container.encode(trackName, forKey: .trackName)
        try container.encode(trackPrice, forKey: .trackPrice)
      
    }
}
