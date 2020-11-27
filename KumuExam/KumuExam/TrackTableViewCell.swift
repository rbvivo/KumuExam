//
//  TrackTableViewCell.swift
//  KumuExam
//
//  Created by Bryan Vivo on 11/26/20.
//

import UIKit

class TrackTableViewCell: UITableViewCell, ReusableView {
   
    private var viewModel: TrackTableViewModel?
    
    private lazy var trackNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var genreNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private lazy var trackImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    private lazy var labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fill
          stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .leading
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    private lazy var favoriteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .red
        button.addTarget(self, action: #selector(favPressed), for: .touchUpInside)
        return button
    }()
    
    func configureCell(track: Track) {
        self.viewModel = TrackTableViewModel(track: track)
        if labelStackView.superview == nil {
            contentView.addSubview(trackImage)
            contentView.addSubview(labelStackView)
            contentView.addSubview(favoriteButton)
            labelStackView.addArrangedSubview(trackNameLabel)
            labelStackView.addArrangedSubview(genreNameLabel)
            labelStackView.addArrangedSubview(priceLabel)
            
            NSLayoutConstraint.activate([
                trackImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                trackImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                
                trackImage.widthAnchor.constraint(equalToConstant: 60),
                trackImage.heightAnchor.constraint(equalToConstant: 60),
                
                labelStackView.leadingAnchor.constraint(equalTo: trackImage.trailingAnchor, constant: 20),
                labelStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                labelStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
                
                favoriteButton.leadingAnchor.constraint(greaterThanOrEqualTo: labelStackView.trailingAnchor, constant: 20),
                favoriteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                favoriteButton.widthAnchor.constraint(equalToConstant: 20),
                favoriteButton.heightAnchor.constraint(equalToConstant: 20)
                
            ])
            
        }
        trackImage.image = nil
        trackNameLabel.text = track.trackName
        genreNameLabel.text = track.primaryGenreName
        priceLabel.text = String(format:"%.2f", track.trackPrice)
        favoriteButton.setImage(track.isFavorite ? UIImage(imageLiteralResourceName: "FavoriteIcon").withRenderingMode(.alwaysTemplate) :  UIImage(imageLiteralResourceName: "UnFavoriteIcon").withRenderingMode(.alwaysTemplate), for: .normal)
        
        if let url = URL(string: track.artworkUrl100 ?? "") {
            viewModel?.loadImage(imageURL: url)
        }
        
        viewModel?.fetchImageComplete = { [weak self] data in
            self?.trackImage.image = UIImage(data: data)
        }
        
        viewModel?.fetchImageFailed = { [weak self] in
            self?.trackImage.image = nil
        }
    }

    
    @objc private func favPressed() {
        guard let viewModel = viewModel else {return}
       
        viewModel.saveTrackCompleted = { [weak self] in
            guard let `self` = self else { return }
            self.favoriteButton.setImage(viewModel.track.isFavorite ? UIImage(imageLiteralResourceName: "FavoriteIcon").withRenderingMode(.alwaysTemplate) :  UIImage(imageLiteralResourceName: "UnFavoriteIcon").withRenderingMode(.alwaysTemplate), for: .normal)
        }
        
        viewModel.saveTrack()
        
    }
}


class TrackTableViewModel {
    let trackServiceProviding: TrackServiceProviding
    var fetchImageComplete: ((_ data: Data) -> Void)?
    var fetchImageFailed: (() -> Void)?
    var track: Track
    var saveTrackCompleted: (() -> Void)?
    var saveTrackFailed: (() -> Void)?
    
    init(track: Track, trackServiceProviding: TrackServiceProviding = TrackService()) {
        self.trackServiceProviding = trackServiceProviding
        self.track = track
    }
    
    func loadImage(imageURL: URL) {
        trackServiceProviding.getImage(imageUrl: imageURL, completion: { [weak self] response in
            switch response {
            case .success(let data):
                self?.fetchImageComplete?(data)
            case .failure(_):
                self?.fetchImageFailed?()
            }
        })
    
    }
    
    func saveTrack() {
        //saves favorite
        do {
           self.track.isFavorite = !self.track.isFavorite
            try self.track.managedObjectContext?.save()
            self.saveTrackCompleted?()
        } catch {
            self.saveTrackFailed?()
        }
    }
    
}
