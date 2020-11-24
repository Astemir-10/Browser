//
//  CoreDataStack.swift
//  Browser
//
//  Created by Astemir Shibzuhov on 11/24/20.
//

import CoreData

class CoreDataStack {
  private let modelName: String
  
  init(modelName: String) {
    self.modelName = modelName
  }
  
  lazy var managedContext = {
    return storeContainer.viewContext
  }()
  
  lazy var storeContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: modelName)
    container.loadPersistentStores { (_, error) in
      if let error = error {
        print(error)
      }
    }
    return container
  }()
  
  func saveContext() {
    guard managedContext.hasChanges else {return}
    do {
      try managedContext.save()
    } catch {
      print(error)
    }
  }
  
}
