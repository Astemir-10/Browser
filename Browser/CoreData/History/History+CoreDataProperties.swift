//
//  History+CoreDataProperties.swift
//  Browser
//
//  Created by Astemir Shibzuhov on 11/24/20.
//
//

import Foundation
import CoreData


extension History {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<History> {
        return NSFetchRequest<History>(entityName: "History")
    }

    @NSManaged public var date: Date?
    @NSManaged public var url: URL?

}

extension History : Identifiable {

}
