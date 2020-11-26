//
//  TrackTableViewCell.swift
//  KumuExam
//
//  Created by Bryan Vivo on 11/26/20.
//

import UIKit

class TrackTableViewCell: UITableViewCell, ReusableView {

    private lazy var trackNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 18)
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
    
    open lazy var trackImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    open lazy var labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fill
          stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .leading
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    func configureCell(track: Track) {
        if labelStackView.superview == nil {
            contentView.addSubview(trackImage)
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
                labelStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                labelStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
            ])
            
        }
    }

}
