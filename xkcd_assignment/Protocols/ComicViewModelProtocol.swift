//
//  ComicViewModelProtocol.swift
//  xkcd_assignment
//
//  Created by Tijana on 03/03/2023.
//

import Foundation
import UIKit

protocol ComicViewModel {
    func getPreviousComic() async
    func getLatestComic() async
    func getNextComic() async
    func comicImageURL() -> URL?
    func comicImage() -> UIImage?
    func saveToFavourites(withImage image: UIImage)
    func loadFromFavourites()
    func favouriteButtonTapped(comicImage: UIImage)
    func checkIfLiked() -> Bool
    func getComicTitle() -> String
    func getComicNum() -> String
    func getComicDescription() -> String
    func getPreviousButtonState() -> Bool
    func getLatestButtonState() -> Bool
    func getNextButtonState() -> Bool
}

extension ComicViewModel {
    func comicImageURL() -> URL? {
        return nil
    }
    
    func comicImage() -> UIImage? {
        return UIImage()
    }
    
    func saveToFavourites(withImage image: UIImage) {}
    
    func favouriteButtonTapped(comicImage: UIImage) {}
    
    func checkIfLiked() -> Bool {
        return false
    }
}
