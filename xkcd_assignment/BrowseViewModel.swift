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
    var latestComicNum: Int?
    
    func getPreviousComic() async {
        guard var currentComicNum = comic?.num, let highestComicNum = latestComicNum, currentComicNum <= highestComicNum else { return }
        currentComicNum -= 1
        comic = try? await ComicAPI.shared.getComic(withNum: currentComicNum)
    }
    
    func getLatestComic() async {
        comic = try? await ComicAPI.shared.getLatestComic()
        latestComicNum = comic?.num
    }
    
    func getNextComic() async {
        guard var currentComicNum = comic?.num, let highestComicNum = latestComicNum, currentComicNum < highestComicNum else { return }
        currentComicNum += 1
        comic = try? await ComicAPI.shared.getComic(withNum: currentComicNum)
    }
}
