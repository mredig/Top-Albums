//
//  SongCell.swift
//  Top Albums
//
//  Created by Michael Redig on 5/11/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import UIKit

class SongCell: UICollectionViewCell {
    private let songPreviewView = SongPreviewView()

	var title: String? {
		get { songPreviewView.title }
		set { songPreviewView.title = newValue }
	}

	var artist: String? {
		get { songPreviewView.artist }
		set { songPreviewView.artist = newValue }
	}

	var progress: Float {
		get { songPreviewView.progress }
		set { songPreviewView.progress = newValue }
	}

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
	}

	private func configureLayout() {
		contentView.addSubview(songPreviewView)
		contentView.constrain(subview: songPreviewView, inset: 8)
	}

	override var isSelected: Bool {
		didSet {
			selectedUpdated()
		}
	}

	private func selectedUpdated() {
		progress = 0
		songPreviewView.backingColor = isSelected ? .tertiarySystemBackground : .secondarySystemBackground
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		progress = 0
		songPreviewView.prepareForReuse()
	}
}
