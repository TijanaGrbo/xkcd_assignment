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
    
    func getComicTitle() -> String {
        guard let comicTitle = comic?.title else { return "" }
        return comicTitle
    }
    
    func getComicNum() -> String {
        guard let comicNum = comic?.num else { return "" }
        return "#\(comicNum)"
    }
    
    func getComicDescription() -> String {
        guard let comicDescription = comic?.alt else { return "" }
        return comicDescription
    }
    
    func saveToFavourites(withImage image: UIImage) {
        guard let comic = comic else { return }
        storageProvider.saveComicToFavourites(comic, withImage: image)
        loadFromFavourites()
    }
    
    func checkIfFavourite() -> Bool {
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
    
    func getSharableLink() -> URL? {
        guard let imageUrlString = comic?.img else { return nil }
        return URL(string: imageUrlString)
    }
    
    func getExplanationUrl() -> URL? {
        guard let comicNum = comic?.num, let title = comic?.title else { return nil }
        return title.formatExplanationUrl(withComicNum: comicNum)
    }
    
    func hasComic() -> Bool {
        return comic != nil
    }
    
}

// extension with get state methods
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
