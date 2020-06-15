//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Ian French on 6/14/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    var movieRepresentation: MovieRepresentation? {
        guard let  title = title
            else { return nil }

        return MovieRepresentation (title: title,
                                    hasWatched: hasWatched,
                                    identifier: identifier?.uuidString ?? "")
    }

    @discardableResult convenience init(identifier: UUID = UUID(), title: String, hasWatched: Bool = false, context: NSManagedObjectContext = CoreDataStack.shared.mainContext)  {

        self.init(context: context)
        self.identifier = identifier
        self.title = title
        self.hasWatched = hasWatched
    }

    @discardableResult convenience init?(movieRepresentation: MovieRepresentation,
                                         context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let identifier = UUID(uuidString: movieRepresentation.identifier) else { return nil }

        self.init(identifier: identifier, title: movieRepresentation.title, hasWatched: movieRepresentation.hasWatched ,
                  context: context)
    }
}




