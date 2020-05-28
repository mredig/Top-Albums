//
//  SongPreviewView.swift
//  Top Albums
//
//  Created by Michael Redig on 5/12/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import UIKit

class SongPreviewView: UIView {
	static let defaultSongProgress: Float = 0.0
	private static let progressAccessibilityID = "SongProgressView"

	private static let artistLabelHuggingPriority: UILayoutPriority = 252
	private static let artistLabelCompressionPriority: UILayoutPriority = 751
	private static let titleLabelCompressionPriority: UILayoutPriority = 752

	private let coloredBackgroundCornerRadius: CGFloat = 10
	private let titleLabelFontSize: CGFloat = 17
	private let artistLabelFontSize: CGFloat = 12

	var title: String? {
		get { titleLabel.text }
		set { titleLabel.text = newValue }
	}

	var artist: String? {
		get { artistLabel.text }
		set { artistLabel.text = newValue }
	}

	var progress: Float {
		get { progressView.progress }
		set {
			progressView.progress = newValue
			progressChanged()
		}
	}

	var backingColor: UIColor? {
		get { coloredBackground.backgroundColor }
		set { coloredBackground.backgroundColor = newValue } 
	}

	private let titleLabel = UILabel()
	private let artistLabel = UILabel()
	private let progressView = UIProgressView()
	private let coloredBackground = UIView()

	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}

	private func commonInit() {
		configureLayout()
		configureViews()
	}

	private func configureLayout() {
		addSubview(coloredBackground)
		constrain(subview: coloredBackground)

		// tie break hugging and compression
		artistLabel.setContentHuggingPriority(Self.artistLabelHuggingPriority, for: .vertical)
		artistLabel.setContentCompressionResistancePriority(Self.artistLabelCompressionPriority, for: .vertical)
		titleLabel.setContentCompressionResistancePriority(Self.titleLabelCompressionPriority, for: .vertical)
		let titleStack = UIStackView(arrangedSubviews: [titleLabel, artistLabel])
		titleStack.axis = .vertical
		titleStack.alignment = .fill
		titleStack.distribution = .fill
		titleStack.spacing = 0
		titleStack.clipsToBounds = false

		coloredBackground.backgroundColor = .secondarySystemBackground
		coloredBackground.addSubview(titleStack)
		coloredBackground.constrain(subview: titleStack, inset: 8)

		progressView.translatesAutoresizingMaskIntoConstraints = false
		coloredBackground.addSubview(progressView)
		translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			progressView.leadingAnchor.constraint(equalTo: coloredBackground.leadingAnchor),
			progressView.trailingAnchor.constraint(equalTo: coloredBackground.trailingAnchor),
			progressView.bottomAnchor.constraint(equalTo: coloredBackground.bottomAnchor),
		])
	}

	private func configureViews() {
		progressView.progress = Self.defaultSongProgress
		progressView.progressViewStyle = .bar
		progressView.accessibilityIdentifier = Self.progressAccessibilityID
		coloredBackground.layer.cornerRadius = coloredBackgroundCornerRadius
		coloredBackground.layer.cornerCurve = .continuous
		coloredBackground.clipsToBounds = true

		titleLabel.font = UIFont.systemFont(ofSize: titleLabelFontSize)
		titleLabel.textColor = .label
		artistLabel.font = UIFont.systemFont(ofSize: artistLabelFontSize)
		artistLabel.textColor = .secondaryLabel
		artistLabel.clipsToBounds = false
	}

	private func progressChanged() {
		guard progress != SongPreviewView.defaultSongProgress else { return }
		#if DEBUG
		progressView.accessibilityIdentifier = Self.progressAccessibilityID + ".progressModified"
		#endif
	}

	func prepareForReuse() {
		progressView.accessibilityIdentifier = Self.progressAccessibilityID
	}

}
