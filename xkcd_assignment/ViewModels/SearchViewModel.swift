//
//  SearchViewModel.swift
//  xkcd_assignment
//
//  Created by Tijana on 02/03/2023.
//

import Foundation

class SearchViewModel {
    @Published var comic: Comic?
    var latestComicNum: Int?
    
    func getLatestComic() async {
        comic = try? await ComicAPI.shared.getLatestComic()
        latestComicNum = comic?.num
    }
    
    func getComic(withNum num: Int) async {
        comic = try? await ComicAPI.shared.getComic(withNum: num)
    }
}
