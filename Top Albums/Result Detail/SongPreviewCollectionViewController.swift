//
//  SongPreviewCollectionViewController.swift
//  Top Albums
//
//  Created by Michael Redig on 5/11/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import UIKit
import NetworkHandler
import AVFoundation

protocol SongPreviewCollectionViewControllerCoordinator: AnyObject {
	func getSongPreviewLoader() -> SongPreviewLoader
}

class SongPreviewCollectionViewController: UICollectionViewController {

	let coordinator: SongPreviewCollectionViewControllerCoordinator

	var songPreviews = [SongResult]() {
		didSet {
			updateCollection()
		}
	}

	private let prototypeSongView = SongPreviewView()
	private var sizeCache = [IndexPath: CGSize]()

	private var playingSong: SongResultViewModel?
	private var currentPreviewLoad: NetworkLoadingTask?
	private var audioPlayer: AVAudioPlayer?

	init(collectionViewLayout layout: UICollectionViewLayout, coordinator: SongPreviewCollectionViewControllerCoordinator) {
		self.coordinator = coordinator
		super.init(collectionViewLayout: layout)
		commonInit()
	}

	override init(collectionViewLayout layout: UICollectionViewLayout) {
		fatalError("Not implemented")
	}

	required init?(coder: NSCoder) {
		fatalError("Not implemented")
	}

	private func commonInit() {
		configureCollectionView()

		collectionView.backgroundColor = .clear
	}

	private func configureCollectionView() {
		self.collectionView.register(SongCell.self, forCellWithReuseIdentifier: .songCellReuseIdentifier)
	}

	private func updateCollection() {
		collectionView.reloadData()
	}

}

// MARK: UICollectionViewDataSource
extension SongPreviewCollectionViewController {

	override func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		songPreviews.count
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: .songCellReuseIdentifier, for: indexPath)
		guard let songCell = cell as? SongCell else { return cell }

		let song = songPreviews[indexPath.item]
		let songVM = SongResultViewModel(songResult: song)

		songCell.artist = songVM.artistName
		songCell.title = songVM.trackName
		songCell.progress = 0

		return songCell
	}

	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let song = songPreviews[indexPath.item]
		let songVM = SongResultViewModel(songResult: song)


		// if any song is playing, stop it
		defer { stopAudio() }
		// if selected song is different than the last, start download
		guard songVM != playingSong else { return }

		let loader = coordinator.getSongPreviewLoader()
		currentPreviewLoad?.cancel()
		currentPreviewLoad = loader.fetchPreview(for: songVM, completion: { [weak self] result in
			do {
				// play song once downloaded
				let songData = try result.get()
				let player = try AVAudioPlayer(data: songData)
				self?.playAudio(with: player, song: songVM)
			} catch {
				print("Error loading song preview: \(error)")
			}
		})
	}

	private func playAudio(with player: AVAudioPlayer, song: SongResultViewModel) {
		playingSong = song
		audioPlayer = player
		audioPlayer?.play()
	}

	private func stopAudio() {
		guard let song = playingSong, let index = songPreviews.firstIndex(of: song.songResult) else { return }
		audioPlayer?.stop()
		collectionView.deselectItem(at: IndexPath(item: index, section: 0), animated: true)
		playingSong = nil
	}
}

extension SongPreviewCollectionViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if let cached = sizeCache[indexPath] {
			return cached
		}

		let song = songPreviews[indexPath.item]
		let songVM = SongResultViewModel(songResult: song)

		prototypeSongView.artist = songVM.artistName
		prototypeSongView.title = songVM.trackName
		prototypeSongView.progress = 0
		let size = prototypeSongView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
		sizeCache[indexPath] = size
		return size
	}
}

extension SongPreviewCollectionViewController: AVAudioPlayerDelegate {
	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		stopAudio()
	}
}

fileprivate extension String {
	static let songCellReuseIdentifier = "SongCell"
}
