//
//  Array+extension.swift
//  My Storm
//
//  Created by Adam Ware on 27/12/21.
//

import Foundation


extension Array where Element: Hashable {
    func containsAny(searchTerms: Set<Element>) -> Bool {
        return !searchTerms.isDisjoint(with: self)
    }
}
