//
//  MovieRepresentation.swift
//  MyMovies
//
//  Created by Ian French on 6/14/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

struct MovieRepresentation: Codable {
    var title: String
    var hasWatched: Bool
    var identifier: String
}
