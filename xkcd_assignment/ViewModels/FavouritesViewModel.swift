//
//  FavouritesViewModel.swift
//  xkcd_assignment
//
//  Created by Tijana on 03/03/2023.
//

import Foundation
import Kingfisher
import UIKit
import CoreData

class FavouritesViewModel: ComicViewModel {
    @Published var comic: FavouriteComic?
    
    var favouriteComics: [FavouriteComic] = []
    
    var latestComicIndex: Int = 0
    var currentIndex: Int = 0
    var storageProvider: StorageProvider
    
    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
        loadFromFavourites()
        setComic()
    }
    
    func getPreviousComic() {
        guard currentIndex > 0, !favouriteComics.isEmpty else { return }
        currentIndex -= 1
        comic = favouriteComics[currentIndex]
    }
    
    func getLatestComic() {
        guard !favouriteComics.isEmpty else { return }
        latestComicIndex = favouriteComics.count - 1
        currentIndex = latestComicIndex
        comic = favouriteComics[currentIndex]
    }
    
    func getNextComic() {
        guard !favouriteComics.isEmpty, currentIndex < favouriteComics.count - 1 else { return }
        currentIndex += 1
        comic = favouriteComics[currentIndex]
    }
}

extension FavouritesViewModel {
    func loadFromFavourites() {
        favouriteComics = storageProvider.getFavouriteComics()
        getLatestComic()
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

    func comicImage() -> UIImage? {
        guard let comicImage = comic?.image else { return UIImage() }
        return comicImage
    }
    
    func checkIfFavourite() -> Bool {
        guard let num = comic?.num else { return false }
        let comicNum = Int(num)
        if storageProvider.isFavourite(comicNum: Int(comicNum)) {
            return true
        } else {
            return false
        }
    }
    
    func favouriteButtonTapped(comicImage: UIImage) {
        guard let num = comic?.num else { return }
        let comicNum = Int(num)
        if storageProvider.isFavourite(comicNum: comicNum) {
            storageProvider.removeComicFromFavourites(comicNum)
            reloadComicSelection()
        } else {
            return
        }
    }
    
    func getSharableLink() -> URL? {
        guard let imageUrlString = comic?.imgUrlString else { return nil }
        return URL(string: imageUrlString)
    }
    
    func getExplanationUrl() -> URL? {
        guard let comicNum = comic?.num, let title = comic?.title else { return nil }
        return title.formatExplanationUrl(withComicNum: Int(comicNum))
    }
    
    func hasComic() -> Bool {
        return comic != nil
    }
}

// get state methods
extension FavouritesViewModel {
    func getPreviousButtonState() -> Bool {
        return currentIndex > 0
    }
    
    func getLatestButtonState() -> Bool {
        return currentIndex != latestComicIndex
    }
    
    func getNextButtonState() -> Bool {
        return currentIndex < favouriteComics.count - 1
    }
}

// private methods
private extension FavouritesViewModel {
    func setComic() {
        guard !favouriteComics.isEmpty else { return }
        latestComicIndex = favouriteComics.count - 1
        currentIndex = latestComicIndex
        comic = favouriteComics[latestComicIndex]
    }

    func reloadComicSelection() {
        loadFromFavourites()
        latestComicIndex = favouriteComics.count - 1
        currentIndex = currentIndex - 1
        guard !favouriteComics.isEmpty else {
            comic = nil
            return }
        comic = favouriteComics[latestComicIndex]
    }
}
