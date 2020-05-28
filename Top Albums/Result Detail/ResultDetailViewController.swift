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

	private static let accessibilityIDResultCellString = "Result Cell"
	private static let accessibilityIDResultAlbumImageView = "AlbumImageView"
	private static let accessibilityIDResultArtistLabel = "ArtistLabel"
	private static let accessibilityIDResultGenreLabel = "GenreLabel"
	private static let accessibilityIDResultReleaseDateLabel = "ReleaseDateLabel"
	private static let accessibilityIDResultCopyrightLabel = "CopyrightLabel"
	private static let accessibilityIDResultiTunesStoreButton = "iTunesStoreButton"

	private static let iTunesStoreButtonTitle = "iTunes Store"
	private static let iTunesStoreImage = UIImage(systemName: "cart")

	private static let albumImageViewDefaultImage = UIImage(systemName: "music.note")
	private static let artistNameDefault = "Unknown artist"
	private static let releaseDateDefault = "Unknown Release Date"
	private static let copyrightDefault = "Unknown copyright"

	private let artistLabelFontSize: CGFloat = 19
	private let genreLabelFontSize: CGFloat = 17
	private let genreLabelFontMinimumScale: CGFloat = 0.65
	private let releaseDateLabelFontSize: CGFloat = 12
	private let copyrightLabelFontSize: CGFloat = 10

	private let smallInsetConstant: CGFloat = 8
	private let mediumInsetConstant: CGFloat = 16
	private let largeInsetConstant: CGFloat = 24
	private let iTunesButtonInsetConstant: CGFloat = 20
	private let iTunesButtonBackgroundHInsetConstant: CGFloat = 16
	private let iTunesButtonBackgroundVInsetConstant: CGFloat = 8
	private let iTunesButtonBackgroundCornerRadius: CGFloat = 10
	private let previewCollectionHeightConstant: CGFloat = 250

	private let scrollViewBottomInsetOverflowConstant: CGFloat = -150
	private let bottomSpacerSizeConstant: CGFloat = 75

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
		albumImageView.setupAccessibilityIdentifier(on: self, id: Self.accessibilityIDResultAlbumImageView)

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
		let bottomSpacer = UIView()
		let stack = UIStackView(arrangedSubviews: [genreLabel,
												   releaseDateLabel,
												   previewCollectionVC.view,
												   copyrightLabel,
												   bottomSpacer
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

		let iTunesButtonBacking = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))

		view.addSubview(iTunesButtonBacking)
		iTunesButtonBacking.contentView.addSubview(itunesStoreButton)
		iTunesButtonBacking.constrain(subview: itunesStoreButton,
									  inset: UIEdgeInsets(horizontal: iTunesButtonBackgroundHInsetConstant,
														  vertical: iTunesButtonBackgroundVInsetConstant))
		iTunesButtonBacking.translatesAutoresizingMaskIntoConstraints = false
		iTunesButtonBacking.layer.cornerRadius = iTunesButtonBackgroundCornerRadius
		iTunesButtonBacking.layer.cornerCurve = .continuous
		iTunesButtonBacking.clipsToBounds = true
		itunesStoreButton.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			// constrain image view to always stay within parent
			albumImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			albumImageView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor),
			view.trailingAnchor.constraint(greaterThanOrEqualTo: albumImageView.trailingAnchor),
			view.bottomAnchor.constraint(greaterThanOrEqualTo: albumImageView.bottomAnchor),
			// constrain image view to center horizontally
			albumImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			// constrain image view to fill in all dimensions possible, without extending outside parent
			albumImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).withPriority(.defaultHigh),
			view.trailingAnchor.constraint(equalTo: albumImageView.trailingAnchor).withPriority(.defaultHigh),
			albumImageView.heightAnchor.constraint(equalTo: albumImageView.widthAnchor),

			clearView.topAnchor.constraint(equalTo: scrollView.topAnchor),
			clearView.heightAnchor.constraint(equalTo: albumImageView.heightAnchor, constant: -smallInsetConstant),

			previewCollectionVC.view.heightAnchor.constraint(equalToConstant: previewCollectionHeightConstant),

			bottomSpacer.heightAnchor.constraint(equalToConstant: bottomSpacerSizeConstant),

			scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

			wrapper.topAnchor.constraint(equalTo: clearView.bottomAnchor),
			wrapper.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
			wrapper.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
			wrapper.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
			wrapper.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

			stack.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: smallInsetConstant),
			stack.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: scrollViewBottomInsetOverflowConstant),
			stack.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: largeInsetConstant),
			stack.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -largeInsetConstant),

			itunesStoreButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -iTunesButtonInsetConstant),
			iTunesButtonBacking.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: iTunesButtonInsetConstant),
			view.safeAreaLayoutGuide.trailingAnchor.constraint(greaterThanOrEqualTo: iTunesButtonBacking.trailingAnchor, constant: iTunesButtonInsetConstant),
			iTunesButtonBacking.centerXAnchor.constraint(equalTo: view.centerXAnchor)
		])

		navigationItem.title = musicResultVM.name
		navigationItem.titleView = artistLabel

		scrollView.contentInset = UIEdgeInsets(bottom: scrollViewBottomInsetOverflowConstant)
	}

	private func configureLabels() {
		artistLabel.font = UIFont.systemFont(ofSize: artistLabelFontSize, weight: .medium)
		artistLabel.textColor = .secondaryLabel
		artistLabel.setupAccessibilityIdentifier(on: self, id: Self.accessibilityIDResultArtistLabel)
		genreLabel.font = UIFont.systemFont(ofSize: genreLabelFontSize, weight: .light)
		genreLabel.adjustsFontSizeToFitWidth = true
		genreLabel.minimumScaleFactor = genreLabelFontMinimumScale
		genreLabel.setupAccessibilityIdentifier(on: self, id: Self.accessibilityIDResultGenreLabel)
		releaseDateLabel.font = UIFont.systemFont(ofSize: releaseDateLabelFontSize, weight: .regular)
		releaseDateLabel.setupAccessibilityIdentifier(on: self, id: Self.accessibilityIDResultReleaseDateLabel)
		copyrightLabel.font = UIFont.systemFont(ofSize: copyrightLabelFontSize, weight: .medium)
		copyrightLabel.textColor = .secondaryLabel
		copyrightLabel.setupAccessibilityIdentifier(on: self, id: Self.accessibilityIDResultCopyrightLabel)

		itunesStoreButton.setTitle(Self.iTunesStoreButtonTitle, for: .normal)
		itunesStoreButton.setImage(Self.iTunesStoreImage, for: .normal)
		itunesStoreButton.setTitleColor(.systemBlue, for: .normal)
		itunesStoreButton.setupAccessibilityIdentifier(on: self, id: Self.accessibilityIDResultiTunesStoreButton)
	}

	private func configureInteraction() {
		itunesStoreButton.addTarget(self, action: #selector(itunesButtonPressed(_:)), for: .touchUpInside)
	}

	private func configureSongPreviews() {
		let loader = coordinator.getSongPreviewLoader()
		switch musicResultVM.kind {
		case MusicResultViewModel.ResultKind.album:
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
		case MusicResultViewModel.ResultKind.song:
			print("load song preview")
		default:
			break
		}
	}

	private func updateViews() {
		albumImageView.image = Self.albumImageViewDefaultImage

		navigationItem.title = musicResultVM.name
		artistLabel.text = musicResultVM.artistName ?? Self.artistNameDefault
		genreLabel.text = musicResultVM.genres
			.map { $0.name }
//			.filter { $0 != "Music" }
			.joined(separator: ", ")
		releaseDateLabel.text = musicResultVM.formattedReleaseDate ?? Self.releaseDateDefault
		copyrightLabel.text = musicResultVM.copyright ?? Self.copyrightDefault

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
