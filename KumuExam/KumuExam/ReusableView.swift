//
//  ReusableView.swift
//  KumuExam
//
//  Created by Bryan Vivo on 11/26/20.
//

import UIKit

public protocol ReusableView {
    static var defaultReuseIdentifier: String {
        get
    }
}

extension ReusableView where Self: UIView{
    public static var defaultReuseIdentifier: String{
        return String(describing: self)
    }
}
