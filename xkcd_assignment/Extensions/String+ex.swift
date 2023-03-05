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
    
    func formatExplanationUrl(withComicNum num: Int) -> URL? {
        let formattedTitle = self.split(separator: " ").joined(separator: "_")
        let urlTitle = "_" + formattedTitle
        let urlArgument = "\(num):\(urlTitle)"
        return URL(string: "https://www.explainxkcd.com/wiki/index.php/\(urlArgument)")
    }
}

