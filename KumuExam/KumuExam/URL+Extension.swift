//
//  URL+Extension.swift
//  KumuExam
//
//  Created by Bryan Vivo on 11/27/20.
//

import Foundation

extension URL {
    func addQueryParams(newParams: [URLQueryItem]) -> URL? {
        guard let urlComponents = NSURLComponents.init(url: self, resolvingAgainstBaseURL: false) else {return nil}
        if (urlComponents.queryItems == nil) {
            urlComponents.queryItems = []
        }
        urlComponents.queryItems!.append(contentsOf: newParams)
        return urlComponents.url
    }
}
