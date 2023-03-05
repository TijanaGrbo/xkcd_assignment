//
//  StorageProvider.swift
//  xkcd_assignment
//
//  Created by Tijana on 02/03/2023.
//

import CoreData
import UIKit

class StorageProvider: ObservableObject {
    
    let persistentContainer: NSPersistentContainer
    
    init() {
        ValueTransformer.setValueTransformer(UIImageTransformer(),
                                             forName: NSValueTransformerName("UIImageTransformer"))
        persistentContainer = NSPersistentContainer(name: "xkcd")
        
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data store failed to load with error: \(error).")
                return
            }

            self.persistentContainer.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        }
    }
}

extension StorageProvider {
    func saveComicToFavourites(_ comic: Comic, withImage comicImage: UIImage) {
        let favouriteComic = FavouriteComic(context: persistentContainer.viewContext)
        favouriteComic.num = Int16(comic.num)
        favouriteComic.title = comic.title
        favouriteComic.alt = comic.alt
        favouriteComic.imgUrlString = comic.img
        favouriteComic.image = comicImage

        do {
            try persistentContainer.viewContext.save()
            print("Comic saved succesfully")
        } catch {
            persistentContainer.viewContext.rollback()
            print("Failed to save comic: \(error)")
        }
    
    }
    
    func removeComicFromFavourites(_ comicNum: Int) {
        let fetchRequest: NSFetchRequest<FavouriteComic> = FavouriteComic.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "num == %d", comicNum)

        do {
            let results = try self.persistentContainer.viewContext.fetch(fetchRequest)
            if let comic = results.first {
                persistentContainer.viewContext.delete(comic)
                do {
                    try persistentContainer.viewContext.save()
                    print("Comic deleted succesfully")
                } catch {
                    persistentContainer.viewContext.rollback()
                    print("Failed to save context: \(error)")
                }
            }
        } catch let error as NSError {
            print("Could not fetch comic: \(error), \(error.userInfo)")
        }
    }
    
    func getFavouriteComics() -> [FavouriteComic] {
        let fetchRequest: NSFetchRequest<FavouriteComic> = FavouriteComic.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "num", ascending: true)]
        
        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            print("Failed to load from Core Data with error: \(error)")
            return []
        }
    }
    
    func isFavourite(comicNum: Int) -> Bool {
        let fetchRequest: NSFetchRequest<FavouriteComic> = FavouriteComic.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %d", #keyPath(FavouriteComic.num), comicNum)
        
        do {
            guard var _ = try persistentContainer.viewContext.fetch(fetchRequest).first else { return false }
            return true
        } catch {
            return false
        }
    }
}
