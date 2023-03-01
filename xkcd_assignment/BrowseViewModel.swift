//
//  BrowseViewModel.swift
//  xkcd_assignment
//
//  Created by Tijana on 01/03/2023.
//

import Foundation
import Kingfisher

class BrowseViewModel {
    @Published var comic: Comic?
    
    func getLatestComic() async {
        comic = try? await ComicAPI.shared.getLatestComic()
    }
}
