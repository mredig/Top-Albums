//
//  ResultTableViewCell.swift
//  Top Albums
//
//  Created by Michael Redig on 5/7/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import UIKit

class ResultTableViewCell: UITableViewCell {

	private static let accessibilityIDResultCellString = "Result Cell"

	private static let defaultImage = UIImage(systemName: "smallcircle.circle.fill")
	private let albumArtView = UIImageView()
	private let albumNameLabel = UILabel()
	private let artistNameLabel = UILabel()

	private let stackSpacing: CGFloat = 16
	private let albumArtHeight: CGFloat = 76
	private let albumArtCornerRadius: CGFloat = 8
	private let albumNameLabelFontSize: CGFloat = 19
	private let albumNameLabelFontMinimumScale: CGFloat = 0.85
	private let artistNameLabelFontSize: CGFloat = 15
	private let artistNameLabelHuggingPriority: UILayoutPriority = 251

	var artistName: String? {
		get { artistNameLabel.text }
		set { artistNameLabel.text = newValue }
	}

	var albumName: String? {
		get { albumNameLabel.text }
		set { albumNameLabel.text = newValue }
	}

	var albumArt: UIImage? {
		get { albumArtView.image }
		set { albumArtView.image = newValue }
	}

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
		accessibilityIdentifier = Self.accessibilityIDResultCellString
	}

	private func configureLayout() {
		accessoryType = .disclosureIndicator

		let rootStack = UIStackView()
		rootStack.axis = .horizontal
		rootStack.alignment = .fill
		rootStack.distribution = .fill
		rootStack.spacing = stackSpacing
		contentView.addSubview(rootStack)
		contentView.constrain(subview: rootStack, inset: 8)

		NSLayoutConstraint.activate([
			albumArtView.heightAnchor.constraint(equalToConstant: albumArtHeight),
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

		albumArtView.layer.cornerCurve = .continuous
		albumArtView.layer.cornerRadius = albumArtCornerRadius
		albumArtView.clipsToBounds = true

		// set to 251 to tie break between labels
		artistNameLabel.setContentHuggingPriority(artistNameLabelHuggingPriority, for: .vertical)
		nestedStackView.addArrangedSubview(albumNameLabel)
		nestedStackView.addArrangedSubview(artistNameLabel)
	}

	private func configureLabels() {
		albumNameLabel.font = UIFont.systemFont(ofSize: albumNameLabelFontSize, weight: .medium)
		albumNameLabel.lineBreakMode = .byTruncatingMiddle
		albumNameLabel.adjustsFontSizeToFitWidth = true
		albumNameLabel.minimumScaleFactor = albumNameLabelFontMinimumScale
		artistNameLabel.font = UIFont.systemFont(ofSize: artistNameLabelFontSize, weight: .regular)
		artistNameLabel.textColor = .secondaryLabel
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		albumArtView.image = ResultTableViewCell.defaultImage
		albumNameLabel.text = ""
		artistNameLabel.text = ""
	}

}
