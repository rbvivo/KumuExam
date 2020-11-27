//
//  MainTableViewModel.swift
//  KumuExam
//
//  Created by Bryan Vivo on 11/26/20.
//

import Foundation
import CoreData

class MainTableViewModel {
    
    private let trackServiceProviding: TrackServiceProviding
    private var appDelegate: AppDelegate
    var trackList: [Track] = []
    private var newFetchedTracks: [Track] = []
    var fetchTracksCompleted: (() -> Void)?
    var fetchTracksFailedHandler: ((_ error: Error) -> Void)?
    var saveContextSuccessHandler: (() -> Void)?
    var isSearching = false
    var searchList: [Track] = []
    var favoriteList: [Track] = []
    
    init(appDelegate: AppDelegate, trackServiceProviding: TrackServiceProviding = TrackService()) {
        self.trackServiceProviding = trackServiceProviding
        self.appDelegate = appDelegate
    }
    
    func retrieveTracks() {
        //retrieve users
     
        trackServiceProviding.getTracks(completion: { [weak self] response in
            guard let `self` = self else { return }

            switch response {
            case .success(let data):
               
                let tracks = self.fetchFromStorage()
                if let tracksToAppend = tracks {
                    //fetch stored tracks and add to memory
                    self.trackList.append(contentsOf: tracksToAppend)
                }
                
                
                if self.parseTrack(data: data) {
                    
                    let newTracks = self.filterNewFetchedTracks(self.newFetchedTracks)
                    if newTracks.count > 0 {
                        //add not stored tracks
                        self.trackList.append(contentsOf: newTracks)
                    }
                    self.fetchTracksCompleted?()
                } else {
                    //failed ot parse
                    self.fetchTracksCompleted?()
                }
            case .failure(let error):
                //offline or error. use stored
                self.fetchTracksFailedHandler?(error)
            
                let tracks = self.fetchFromStorage()
                if let tracksToAppend = tracks {
                    //fetch stored tracks and add to memory
                    self.trackList.append(contentsOf: tracksToAppend)
                }
                
                self.fetchTracksCompleted?()
            }
        })
    }
    
    func fetchFromStorage() -> [Track]? {
        //fetch tracks from local storage
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Track>(entityName: CoreDataNames.entityName.rawValue)
        fetchRequest.includesPendingChanges = false
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.fetchLimit = 50
        do {
            let tracks = try managedObjectContext.fetch(fetchRequest)
            return tracks
        } catch let error {
            print(error)
            return nil
        }
    }
    
    private func parseTrack(data: Data) -> Bool {
        //parse Track

        do {
            guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext else {
                fatalError("Failed to retrieve context")
            }
            let managedObjectContext = appDelegate.persistentContainer.viewContext
            let decoder = JSONDecoder()
            decoder.userInfo[codingUserInfoKeyManagedObjectContext] = managedObjectContext
            let rawResponse = try decoder.decode(RawServerResponse.self, from: data)
            newFetchedTracks = rawResponse.results
            return true
        } catch {
            return false
        }
    }
    
    private func filterNewFetchedTracks(_ tracks: [Track]) -> [Track] {
        //put user core data to model
        
        var newTracks: [Track] = []
        for track in tracks {
            
            if let oldTrack = trackList.first(where: {$0.trackId == track.trackId}) {
                // update stored track
                updateTracks(oldTrack: oldTrack, newTrack: track)
            } else {
                //add and store not stored track
                newTracks.append(track)
            }
        }
      
        return newTracks
    }
    
    private func updateTracks(oldTrack: Track, newTrack: Track) {
        //update stored tracks
        
        oldTrack.trackId = newTrack.trackId
        oldTrack.artistName = newTrack.artistName
        oldTrack.artworkUrl100 = newTrack.artworkUrl100
        oldTrack.primaryGenreName = newTrack.primaryGenreName
        oldTrack.longDescription = newTrack.longDescription
        oldTrack.trackName = newTrack.trackName
        oldTrack.trackPrice = newTrack.trackPrice
    
    }
    
    func saveContext() {
        do {
            try self.appDelegate.persistentContainer.viewContext.save()
            saveContextSuccessHandler?()
        } catch {
            
        }
    }
    
    func searchTracks(searchString: String) {
        //search
        searchList.removeAll()
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Track>(entityName: CoreDataNames.entityName.rawValue)
        let sortDescriptor = NSSortDescriptor(key: "trackId", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let predicateNote = NSPredicate(format: "trackName contains[c] %@ or artistName contains[c] %@", searchString, searchString)
        
        fetchRequest.predicate = predicateNote
        fetchRequest.includesPendingChanges = false
        fetchRequest.returnsObjectsAsFaults = false
        do {
            searchList = try managedObjectContext.fetch(fetchRequest)
            
        } catch {
            searchList = []
        }
    }
    
    func fetchFavorites() {
        //fetch favorites
        favoriteList.removeAll()
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Track>(entityName: CoreDataNames.entityName.rawValue)
        let sortDescriptor = NSSortDescriptor(key: "trackId", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let predicateNote = NSPredicate(format: "isFavorite == true")
        
        fetchRequest.predicate = predicateNote
        fetchRequest.includesPendingChanges = false
        fetchRequest.returnsObjectsAsFaults = false
        do {
            favoriteList = try managedObjectContext.fetch(fetchRequest)
            
        } catch {
            favoriteList = []
        }
    }
}
