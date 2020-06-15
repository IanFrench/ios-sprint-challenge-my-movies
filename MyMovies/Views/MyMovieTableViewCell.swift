//
//  MyMovieTableViewCell.swift
//  MyMovies
//
//  Created by Ian French on 6/14/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

protocol MyMoviesTableViewCellDelegate: class {
    func didUpdateMovie(movie: Movie)
}

class MyMoviesTableViewCell: UITableViewCell {

    @IBOutlet weak var movieTitleLabel: UILabel!
    
    @IBOutlet weak var hasWatchedButton: UIButton!

    @IBAction func hasWatchedButtonTapped(_ sender: UIButton) {
        guard let movie = movie else { return }

        movie.hasWatched.toggle()
        hasWatchedButton.setImage(movie.hasWatched ? UIImage(systemName: "film.fill") : UIImage(systemName: "film"), for: .normal)
        delegate?.didUpdateMovie(movie: movie)
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }
    
    weak var delegate: MyMoviesTableViewCellDelegate?
    static let reuseIdentifier = "MyMovieCell"

    var movie: Movie? {
        didSet {
            updateViews()
        }
    }
    func updateViews() {
        guard let movie = movie else { return }
        movieTitleLabel.text = movie.title
        hasWatchedButton.setImage(movie.hasWatched ? UIImage(systemName: "film.fill") : UIImage(systemName: "film"), for: .normal)
    }
}
