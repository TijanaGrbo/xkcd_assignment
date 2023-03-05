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
    
    func getComicTitle() -> String {
        guard let comicTitle = comic?.title else { return "" }
        return comicTitle
    }

    func getComicDescription() -> String {
        guard let comicDescription = comic?.alt else { return "" }
        return comicDescription
    }
    
    func getExplanationUrl() -> URL? {
        guard let comicNum = comic?.num, let title = comic?.title else { return nil }
        return title.formatExplanationUrl(withComicNum: comicNum)
    }
}
