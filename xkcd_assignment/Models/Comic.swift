//
//  Comic.swift
//  xkcd_assignment
//
//  Created by Tijana on 01/03/2023.
//

import Foundation

struct Comic: Codable, Identifiable, Equatable {

    var id: Int {
        return num
    }
    
    let num: Int
    let alt: String
    let title: String
    let img: String
    
    var imgURL: URL? {
        return URL(string: img)
    }
}
