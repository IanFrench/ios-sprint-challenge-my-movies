//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData
enum NetworkError: Error {
    case noIdentifier
    case otherError
    case noData
    case noDecode
    case noEncode
    case noRep
    case failedDecode
}

class MovieController {
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    
    typealias CompletionHandler = (Result<Bool, NetworkError>) -> Void
    
    // MARK: - Properties
    
    var searchedMovies: [MovieDBMovie] = []
    
    // MARK: - TheMovieDB API
    
    func searchForMovie(with searchTerm: String, completion: @escaping CompletionHandler) {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        let queryParameters = ["query": searchTerm,
                               "api_key": apiKey]
        components?.queryItems = queryParameters.map({URLQueryItem(name: $0.key, value: $0.value)})
        
        guard let requestURL = components?.url else {
            completion(.failure(.otherError))
            return
        }
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                NSLog("Error searching for movie with search term \(searchTerm): \(error)")
                completion(.failure(.otherError))
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from data task")
                completion(.failure(.noData))
                return
            }
            
            do {
                let movieDBMovies = try JSONDecoder().decode(MovieDBResults.self, from: data).results
                self.searchedMovies = movieDBMovies
                completion(.success(true))
            } catch {
                NSLog("Error decoding JSON data: \(error)")
                completion(.failure(.failedDecode))
            }
        }.resume()
    }

    // Add functions for firebase interaction

    // Fetch Movies from firebase
        func fetchMoviesFromServer(completion: @escaping CompletionHandler = { _ in }) {
        let requestURL = baseURL.appendingPathExtension("json")

        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                print("Error fetching tasks: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(.otherError))
                }
                return
            }


            guard let data = data else {
                print("No data returned by data task")
                DispatchQueue.main.async {
                    completion(.failure(.noData))
                }
                return
            }

            do {
                let movieRepresentations = Array(try JSONDecoder().decode([String : MovieRepresentation].self, from: data).values)

                try self.updateMovies(with: movieRepresentations)
                DispatchQueue.main.async {
                    completion(.success(true))
                }
            } catch {
                print("Error decoding movie representations: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(.noDecode))
                }
                return
            }
        }.resume()
    }


    func sendMovieToServer(movie: Movie, completion: @escaping CompletionHandler = { _ in }) {

           guard let uuid = movie.identifier else {
               completion(.failure(.noIdentifier))
               return
           }

           //[unique identifier here].json
           let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")

           var request = URLRequest(url: requestURL)
           request.httpMethod = "PUT"

           do {
               guard let representation = movie.movieRepresentation else {
                   completion(.failure(.noRep))
                   return
               }
               request.httpBody = try JSONEncoder().encode(representation)
           } catch {
               print("Error encoding movie \(movie): \(error)")
               completion(.failure(.noEncode))
               return
           }

           URLSession.shared.dataTask(with: request) { (data, _, error) in
               if let error = error {
                   print("Error PUTting movie to server: \(error)")
                   DispatchQueue.main.async {
                       completion(.failure(.otherError))
                   }
                   return
               }

               DispatchQueue.main.async {
                   completion(.success(true))
               }
           }.resume()
       }

       // Update/Create Movies with Representations
       private func updateMovies(with representations: [MovieRepresentation]) throws {
           let context = CoreDataStack.shared.container.newBackgroundContext()
           // Array of UUIDs
           let identifiersToFetch = representations.compactMap({ UUID(uuidString: $0.identifier )})

           let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
           var moviesToCreate = representationsByID

           let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
           fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
           context.perform {
               do {
                   let existingMovies = try context.fetch(fetchRequest)

                   // For already existing tasks
                   for movie in existingMovies {
                       guard let id = movie.identifier,
                           let representation = representationsByID[id] else { continue }
                       self.update(movie: movie, with: representation)
                       moviesToCreate.removeValue(forKey: id)
                   }

                   // For new tasks
                   for representation in moviesToCreate.values {
                       Movie(movieRepresentation: representation, context: context)
                   }
               } catch {
                   print("error fetching movies for UUIDs: \(error)")
               }
               do {

                   try CoreDataStack.shared.save(context: context)
               } catch {
                   print("error saving)")
               }
           }

       }

       private func update(movie: Movie, with representation: MovieRepresentation) {
           movie.title = representation.title
           movie.hasWatched = representation.hasWatched

       }


       func deleteMovieFromServer(_ movie: Movie, completion: @escaping CompletionHandler = { _ in }) {
           guard let uuid = movie.identifier else {
               completion(.failure(.noIdentifier))
               return
           }

           let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
           var request = URLRequest(url: requestURL)
           request.httpMethod = "DELETE"

           URLSession.shared.dataTask(with: request) { (data, response, error) in
               print(response!)
               completion(.success(true))
           }.resume()
       }









}
