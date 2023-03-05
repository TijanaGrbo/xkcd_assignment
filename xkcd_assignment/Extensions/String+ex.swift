//
//  Localised.swift
//  xkcd_assignment
//
//  Created by Tijana on 05/03/2023.
//

import Foundation

extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}

