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
            }

            self.persistentContainer.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        }
    }
}

