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
		songPreviewView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			songPreviewView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
			songPreviewView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 8),
			songPreviewView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
			songPreviewView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 8),
		])
	}

	private var _isSelected: Bool = false
	override var isSelected: Bool {
		get { _isSelected }
		set {
			_isSelected = newValue
			progress = 0
		}
	}
}
