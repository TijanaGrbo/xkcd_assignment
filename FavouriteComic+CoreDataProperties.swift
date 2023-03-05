//
//  FavouriteComic+CoreDataProperties.swift
//  xkcd_assignment
//
//  Created by Tijana on 05/03/2023.
//
//

import Foundation
import CoreData
import UIKit

extension FavouriteComic {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavouriteComic> {
        return NSFetchRequest<FavouriteComic>(entityName: "FavouriteComic")
    }

    @NSManaged public var alt: String?
    @NSManaged public var image: UIImage?
    @NSManaged public var num: Int16
    @NSManaged public var title: String?
    @NSManaged public var imgUrlString: String?

}

extension FavouriteComic : Identifiable {

}
