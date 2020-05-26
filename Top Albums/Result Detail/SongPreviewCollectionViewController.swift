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

	private var playingSong: SongResultViewModel?
	private var currentPreviewLoad: NetworkLoadingTask?
	private var audioPlayer: AVAudioPlayer?
	private var audioTimer: Timer?

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
		collectionView.register(SongCell.self, forCellWithReuseIdentifier: .songCellReuseIdentifier)
		collectionView.showsVerticalScrollIndicator = false
		collectionView.showsHorizontalScrollIndicator = false
	}

	private func updateCollection() {
		collectionView.reloadData()
	}

	// MARK: - Audio Controls
	private func playAudio(with player: AVAudioPlayer, song: SongResultViewModel) {
		playingSong = song
		audioPlayer = player
		audioPlayer?.delegate = self
		audioPlayer?.play()

		DispatchQueue.main.async {
			self.audioTimer = Timer.scheduledTimer(withTimeInterval: 1/30, repeats: true, block: { [weak self] _ in
				guard let self = self,
					let song = self.playingSong,
					let player = self.audioPlayer,
					let index = self.songPreviews.firstIndex(of: song.songResult),
					let cell = self.collectionView.cellForItem(at: IndexPath(item: index, section: 0)),
					let songCell = cell as? SongCell else { return }

				songCell.progress = Float(player.currentTime / player.duration)
			})
		}
	}

	private func stopAudio() {
		guard let song = playingSong, let index = songPreviews.firstIndex(of: song.songResult) else { return }
		audioPlayer?.stop()
		collectionView.deselectItem(at: IndexPath(item: index, section: 0), animated: true)
		playingSong = nil

		audioTimer?.invalidate()
		audioTimer = nil
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
		songCell.title = songVM.trackNameWithNumber
		songCell.progress = 0
		songCell.accessibilityIdentifier = "\(SongCell.songCellAccessibilityID).\(songVM.trackName)"

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
}

extension SongPreviewCollectionViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let size = collectionView.frame.size
		let newSize = CGSize(width: size.width * 0.9, height: size.height * 0.3)
		return newSize
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
