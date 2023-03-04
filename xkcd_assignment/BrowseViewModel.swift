//
//  BrowseViewModel.swift
//  xkcd_assignment
//
//  Created by Tijana on 01/03/2023.
//

import Foundation
import Kingfisher
import UIKit
import CoreData

class BrowseViewModel: ComicViewModel {
    @Published var comic: Comic?
    
    var latestComicNum: Int?
    var storageProvider: StorageProvider
    
    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
    }
    
    func getPreviousComic() async {
        guard var currentComicNum = comic?.num,
              currentComicNum > 0
        else { return }
        currentComicNum -= 1
        comic = try? await ComicAPI.shared.getComic(withNum: currentComicNum)
    }
    
    func getLatestComic() async {
        comic = try? await ComicAPI.shared.getLatestComic()
        latestComicNum = comic?.num
    }
    
    func getNextComic() async {
        guard var currentComicNum = comic?.num,
              let highestComicNum = latestComicNum,
              currentComicNum < highestComicNum
        else { return }
        currentComicNum += 1
        comic = try? await ComicAPI.shared.getComic(withNum: currentComicNum)
    }
}

extension BrowseViewModel {
    func comicImageURL() -> URL? {
        return comic?.imgURL
    }
    
    func loadFromFavourites() {
        _ = storageProvider.getFavouriteComics()
    }
    
    func setComicTitle() -> String {
        guard let comicTitle = comic?.title else { return "" }
        return comicTitle
    }
    
    func setComicNum() -> String {
        guard let comicNum = comic?.num else { return "" }
        return "#\(comicNum)"
    }
    
    func saveToFavourites(withImage image: UIImage) {
        guard let comic = comic else { return }
        storageProvider.saveComicToFavourites(comic, withImage: image)
        loadFromFavourites()
    }
    
    func checkIfLiked() -> Bool {
        guard let comicNum = comic?.num else { return false }
        if storageProvider.isFavourite(comicNum: comicNum) {
            return true
        } else {
            return false
        }
    }
    
    func favouriteButtonTapped(comicImage: UIImage) {
        guard let comicNum = comic?.num else { return }
        if storageProvider.isFavourite(comicNum: comicNum) {
            storageProvider.removeComicFromFavourites(comicNum)
        } else {
            guard let comic = comic else { return }
            storageProvider.saveComicToFavourites(comic, withImage: comicImage)
        }
    }
}

extension BrowseViewModel {
    func getPreviousButtonState() -> Bool {
        guard let currentComicNum = comic?.num else { return false }
        return currentComicNum > 1
    }
    
    func getLatestButtonState() -> Bool {
        guard let currentComicNum = comic?.num else { return false }
        return currentComicNum != latestComicNum
    }
    
    func getNextButtonState() -> Bool {
        guard let currentComicNum = comic?.num else { return false }
        return currentComicNum < latestComicNum ?? 0
    }
}
