//
//  ResultDetailViewController.swift
//  Top Albums
//
//  Created by Michael Redig on 5/7/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import UIKit

protocol ResultDetailViewControllerCoordinator {
	func getImageLoader() -> ImageLoader
	func getSongPreviewLoader() -> SongPreviewLoader
	func createSongPreviewCollectionVC() -> SongPreviewCollectionViewController
}

class ResultDetailViewController: UIViewController {

	// MARK: - Properties
	let musicResultVM: MusicResultViewModel
	let coordinator: ResultDetailViewControllerCoordinator

	private static let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		return dateFormatter
	}()

	// MARK: - Subviews
	private let albumImageView = UIImageView()
	private let artistLabel = UILabel()
	private let genreLabel = UILabel()
	private let releaseDateLabel = UILabel()
	private let copyrightLabel = UILabel()
	private let itunesStoreButton = UIButton()
	private lazy var previewCollectionVC = coordinator.createSongPreviewCollectionVC()

	// MARK: - Lifecycle
	init(musicResultVM: MusicResultViewModel, coordinator: ResultDetailViewControllerCoordinator) {
		self.musicResultVM = musicResultVM
		self.coordinator = coordinator
		super.init(nibName: nil, bundle: nil)
		configureLayout()
		configureLabels()
		configureInteraction()
		configureSongPreviews()

		updateViews()
	}

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		fatalError("init(nibName:bundle:) has not been implemented")
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		view.backgroundColor = .systemBackground
    }

	private func configureLayout() {
		view.addSubview(albumImageView)
		albumImageView.translatesAutoresizingMaskIntoConstraints = false
		albumImageView.setupAccessibilityIdentifier(on: self, id: "AlbumImageView")

		let scrollView = UIScrollView()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.showsVerticalScrollIndicator = false
		scrollView.showsHorizontalScrollIndicator = false
		view.addSubview(scrollView)

		let clearView = UIView()
		clearView.backgroundColor = .clear // UIColor.systemRed.withAlphaComponent(0.3)
		clearView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.addSubview(clearView)

		addChild(previewCollectionVC)
		let stack = UIStackView(arrangedSubviews: [genreLabel,
												   releaseDateLabel,
												   previewCollectionVC.view,
												   copyrightLabel
		])
		stack.axis = .vertical
		stack.alignment = .fill
		stack.distribution = .fill
		stack.spacing = UIStackView.spacingUseSystem
		stack.translatesAutoresizingMaskIntoConstraints = false
		previewCollectionVC.didMove(toParent: self)

		let wrapper = UIView()
		wrapper.translatesAutoresizingMaskIntoConstraints = false
		wrapper.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.85)
		wrapper.addSubview(stack)
		scrollView.addSubview(wrapper)
		scrollView.translatesAutoresizingMaskIntoConstraints = false

		view.addSubview(itunesStoreButton)
		itunesStoreButton.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			albumImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			albumImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			albumImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			albumImageView.heightAnchor.constraint(equalTo: albumImageView.widthAnchor),

			clearView.topAnchor.constraint(equalTo: scrollView.topAnchor),
			clearView.heightAnchor.constraint(equalTo: albumImageView.heightAnchor, constant: -8),

			previewCollectionVC.view.heightAnchor.constraint(equalToConstant: 250),

			scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			scrollView.bottomAnchor.constraint(equalTo: itunesStoreButton.topAnchor, constant: -16),

			wrapper.topAnchor.constraint(equalTo: clearView.bottomAnchor),
			wrapper.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
			wrapper.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
			wrapper.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
			wrapper.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

			stack.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 8),
			stack.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -8),
			stack.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 24),
			stack.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -24),

			itunesStoreButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
			itunesStoreButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
			itunesStoreButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
		])

		navigationItem.title = musicResultVM.name
		navigationItem.titleView = artistLabel
	}

	private func configureLabels() {
		artistLabel.font = UIFont.systemFont(ofSize: 19, weight: .medium)
		artistLabel.textColor = .secondaryLabel
		artistLabel.setupAccessibilityIdentifier(on: self, id: "ArtistLabel")
		genreLabel.font = UIFont.systemFont(ofSize: 17, weight: .light)
		genreLabel.adjustsFontSizeToFitWidth = true
		genreLabel.minimumScaleFactor = 0.65
		genreLabel.setupAccessibilityIdentifier(on: self, id: "GenreLabel")
		releaseDateLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
		releaseDateLabel.setupAccessibilityIdentifier(on: self, id: "ReleaseDateLabel")
		copyrightLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
		copyrightLabel.textColor = .secondaryLabel
		copyrightLabel.setupAccessibilityIdentifier(on: self, id: "CopyrightLabel")

		itunesStoreButton.setTitle("iTunes Store", for: .normal)
		itunesStoreButton.setImage(UIImage(systemName: "cart"), for: .normal)
		itunesStoreButton.setTitleColor(.systemBlue, for: .normal)
		itunesStoreButton.setupAccessibilityIdentifier(on: self, id: "iTunesStoreButton")
	}

	private func configureInteraction() {
		itunesStoreButton.addTarget(self, action: #selector(itunesButtonPressed(_:)), for: .touchUpInside)
	}

	private func configureSongPreviews() {
		let loader = coordinator.getSongPreviewLoader()
		switch musicResultVM.kind {
		case "album":
			loader.fetchPreviewList(for: musicResultVM) { [weak self] result in
				switch result {
				case .success(let results):
					DispatchQueue.main.async {
						self?.previewCollectionVC.songPreviews = results
					}
				case .failure(let error):
					print("Error loading song preview info: \(error)")
				}
			}
		case "song":
			print("load song preview")
		default:
			break
		}
	}

	private func updateViews() {
		albumImageView.image = UIImage(systemName: "music.note")

		navigationItem.title = musicResultVM.name
		artistLabel.text = musicResultVM.artistName ?? "Unknown artist"
		genreLabel.text = musicResultVM.genres.map { $0.name }.filter { $0 != "Music" }.joined(separator: ", ")
		releaseDateLabel.text = musicResultVM.formattedReleaseDate ?? "Unknown Release Date"
		copyrightLabel.text = musicResultVM.copyright ?? "Unknown copyright"

		let imageLoader = coordinator.getImageLoader()
		_ = imageLoader.fetchImage(for: musicResultVM, attemptHighRes: true) { [weak self] result in
			DispatchQueue.main.async {
				do {
					let imageData = try result.get()
					self?.albumImageView.image = UIImage(data: imageData)
				} catch {
					NSLog("Error loading image in detail VC: \(error)")
				}
			}
		}
	}

	// MARK: - User Interaction
	@objc func itunesButtonPressed(_ sender: UITapGestureRecognizer) {
		if UIApplication.shared.canOpenURL(musicResultVM.url) {
			UIApplication.shared.open(musicResultVM.url, options: [:])
		}
	}
}
