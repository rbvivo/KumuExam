//
//  TrackService.swift
//  KumuExam
//
//  Created by Bryan Vivo on 11/26/20.
//
import Foundation
import CoreData

protocol TrackServiceProviding {
    
    func getTracks(completion: @escaping (APIResponse<Data>) -> Void)
    func getImage(imageUrl: URL, completion: @escaping (APIResponse<Data>) -> Void)
}

struct TrackService: TrackServiceProviding {
    func getTracks(completion: @escaping (APIResponse<Data>) -> Void) {
        guard let url = URL(string: "https://itunes.apple.com/search?") else {return}
        let urlQueryItemTerm = URLQueryItem(name: "term", value: "star")
        let urlQueryItemCountry = URLQueryItem(name: "country", value: "au")
        let urlQueryItemMedia = URLQueryItem(name: "media", value: "all")
        
        guard let urlQuery = url.addQueryParams(newParams: [urlQueryItemTerm, urlQueryItemCountry, urlQueryItemMedia]) else {return}
        let request = URLRequest(url: urlQuery)
        let session = URLSession.shared

        session.dataTask(with: request) {data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                }
                
                if let data = data {
                    completion(.success(data))
                } else {
                    let error = NSError(domain: "Connection error", code: -1, userInfo: nil)
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
  
    func getImage(imageUrl: URL, completion: @escaping (APIResponse<Data>) -> Void) {
        let request = URLRequest(url: imageUrl,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: 10.0)
        let session = URLSession.shared
        
        
        session.dataTask(with: request) {data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                }
                
                if let data = data {
                    completion(.success(data))
                } else {
                    let error = NSError(domain: "Connection error", code: -1, userInfo: nil)
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}


extension URL {
    //To add Query Parameters
    func addQueryParams(newParams: [URLQueryItem]) -> URL? {
        guard let urlComponents = NSURLComponents.init(url: self, resolvingAgainstBaseURL: false) else {return nil}
        if (urlComponents.queryItems == nil) {
            urlComponents.queryItems = []
        }
        urlComponents.queryItems!.append(contentsOf: newParams)
        return urlComponents.url
    }
}
