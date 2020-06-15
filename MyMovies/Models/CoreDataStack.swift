//
//  CoreDataStack.swift
//  MyMovies
//
//  Created by Ian French on 6/14/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    // Static makes it a class property
    static let shared = CoreDataStack()

    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Movie")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }

    func save(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) throws {
        //A
        var error: Error?


        context.performAndWait {
            do {
                try context.save()
            } catch let saveError {
                error = saveError
            }
        }

        if let error = error { throw error }
    }
}
