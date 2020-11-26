//
//  APResponse.swift
//  KumuExam
//
//  Created by Bryan Vivo on 11/26/20.
//

enum APIResponse<T> {
    case success(T)
    case failure(Error)
}
