//
//  SongPreviewCollectionViewController.swift
//  Top Albums
//
//  Created by Michael Redig on 5/11/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import UIKit

class SongPreviewCollectionViewController: UICollectionViewController {

	var songPreviews = [SongResult]()

	private let prototypeSongView = SongPreviewView()
	private var sizeCache = [IndexPath: CGSize]()

	override init(collectionViewLayout layout: UICollectionViewLayout) {
		super.init(collectionViewLayout: layout)
		commonInit()
	}

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		commonInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}

	private func commonInit() {
		configureCollectionView()

		collectionView.backgroundColor = .systemBackground
	}

	private func configureCollectionView() {
		self.collectionView.register(SongCell.self, forCellWithReuseIdentifier: .songCellReuseIdentifier)
	}

}

// MARK: UICollectionViewDataSource
extension SongPreviewCollectionViewController {

	override func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		songPreviews.count + 15
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: .songCellReuseIdentifier, for: indexPath)
		guard let songCell = cell as? SongCell else { return cell }

//		let song = songPreviews[indexPath.item]
		let song = SongResult(wrapperType: "", kind: "", artistId: 0, collectionId: 0, trackId: 0, artistName: "Taylor Swift", collectionName: "", trackName: "Shake it Off", previewUrl: URL(fileURLWithPath: "/"), trackPrice: 0, discCount: 0, discNumber: 0, trackNumber: 0, trackCount: 0, isStreamable: false)
		let songVM = SongResultViewModel(songResult: song, loader: nil, previewData: nil)

		songCell.artist = songVM.artistName
		songCell.title = songVM.trackName
		songCell.progress = 0

		return songCell
	}
}

extension SongPreviewCollectionViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if let cached = sizeCache[indexPath] {
			return cached
		}

//		let song = songPreviews[indexPath.item]
		let song = SongResult(wrapperType: "", kind: "", artistId: 0, collectionId: 0, trackId: 0, artistName: "Taylor Swift", collectionName: "", trackName: "Shake it Off", previewUrl: URL(fileURLWithPath: "/"), trackPrice: 0, discCount: 0, discNumber: 0, trackNumber: 0, trackCount: 0, isStreamable: false)

		let songVM = SongResultViewModel(songResult: song, loader: nil, previewData: nil)

		prototypeSongView.artist = songVM.artistName
		prototypeSongView.title = songVM.trackName
		prototypeSongView.progress = 0
		let size = prototypeSongView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
		sizeCache[indexPath] = size
		return size
	}
}

fileprivate extension String {
	static let songCellReuseIdentifier = "SongCell"
}
