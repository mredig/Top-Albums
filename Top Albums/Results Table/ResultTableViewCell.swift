//
//  ResultTableViewCell.swift
//  Top Albums
//
//  Created by Michael Redig on 5/7/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import UIKit

class ResultTableViewCell: UITableViewCell {

	private static let defaultImage = UIImage(systemName: "smallcircle.circle.fill")
	private let albumArtView = UIImageView()
	private let albumNameLabel = UILabel()
	private let artistNameLabel = UILabel()

	var musicResult: MusicResult? {
		didSet {
			updateViews()
		}
	}

	var imageLoader: ImageLoader?
	private var imageLoadOperation: ImageLoadOperation?

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		commonInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}

	private func commonInit() {
		configureLayout()
		configureLabels()
	}

	private func configureLayout() {
		accessoryType = .disclosureIndicator

		let rootStack = UIStackView()
		rootStack.axis = .horizontal
		rootStack.alignment = .fill
		rootStack.distribution = .fill
		rootStack.spacing = 16
		contentView.addSubview(rootStack)
		rootStack.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			rootStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
			rootStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
			rootStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
			rootStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),

			albumArtView.heightAnchor.constraint(equalToConstant: 76),
			albumArtView.widthAnchor.constraint(equalTo: albumArtView.heightAnchor),
		])

		rootStack.addArrangedSubview(albumArtView)
		albumArtView.image = ResultTableViewCell.defaultImage
		let nestedStackView = UIStackView()
		nestedStackView.axis = .vertical
		nestedStackView.alignment = .fill
		nestedStackView.distribution = .fill
		nestedStackView.spacing = UIStackView.spacingUseDefault
		rootStack.addArrangedSubview(nestedStackView)

		artistNameLabel.setContentHuggingPriority(.init(rawValue: 251), for: .vertical)
		nestedStackView.addArrangedSubview(albumNameLabel)
		nestedStackView.addArrangedSubview(artistNameLabel)
	}

	private func configureLabels() {
		albumNameLabel.font = UIFont.systemFont(ofSize: 19, weight: .medium)
		albumNameLabel.lineBreakMode = .byTruncatingMiddle
		albumNameLabel.adjustsFontSizeToFitWidth = true
		albumNameLabel.minimumScaleFactor = 0.85
		artistNameLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
		artistNameLabel.textColor = .secondaryLabel
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		musicResult = nil
		albumArtView.image = ResultTableViewCell.defaultImage
		albumNameLabel.text = ""
		artistNameLabel.text = ""
		imageLoadOperation?.cancel()
	}

	private func updateViews() {
		guard let musicResult = musicResult else { return }

		artistNameLabel.text = musicResult.artistName
		albumNameLabel.text = musicResult.name

		imageLoadOperation = imageLoader?.fetchImage(for: musicResult, attemptHighRes: false, completion: { [weak self] result in
			DispatchQueue.main.async {
				do {
					let imageData = try result.get()
					let image = UIImage(data: imageData)
					self?.albumArtView.image = image
				} catch {
					print("Error fetching image for \(musicResult.name)-\(musicResult.artistName ?? ""): \(error)")
				}
			}
		})
	}

}
