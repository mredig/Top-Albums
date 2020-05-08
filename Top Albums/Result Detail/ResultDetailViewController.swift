//
//  ResultDetailViewController.swift
//  Top Albums
//
//  Created by Michael Redig on 5/7/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import UIKit

class ResultDetailViewController: UIViewController {

	// MARK: - Properties
	let musicResult: MusicResult
	let mainCoordinator: MainCoordinator

	private static let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		return dateFormatter
	}()

	// MARK: - Subviews
	private let albumImageView = UIImageView()
	private let titleLabel = UILabel()
	private let artistLabel = UILabel()
	private let genreLabel = UILabel()
	private let releaseDateLabel = UILabel()
	private let copyrightLabel = UILabel()
	private let itunesStoreButton = UIButton()

	// MARK: - Lifecycle
	init(musicResult: MusicResult, mainCoordinator: MainCoordinator) {
		self.musicResult = musicResult
		self.mainCoordinator = mainCoordinator
		super.init(nibName: nil, bundle: nil)
		configureLayout()
		configureLabels()

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

        // Do any additional setup after loading the view.
		view.backgroundColor = .secondarySystemBackground
    }

	private func configureLayout() {
		view.addSubview(albumImageView)
		albumImageView.translatesAutoresizingMaskIntoConstraints = false

		let stack = UIStackView(arrangedSubviews: [titleLabel,
												   artistLabel,
												   genreLabel,
												   releaseDateLabel,
												   UIView(),
												   itunesStoreButton,
												   copyrightLabel
		])
		stack.axis = .vertical
		stack.alignment = .fill
		stack.distribution = .fill
		stack.spacing = UIStackView.spacingUseSystem
		view.addSubview(stack)
		stack.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			albumImageView.topAnchor.constraint(equalTo: view.topAnchor),
			albumImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			albumImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			albumImageView.heightAnchor.constraint(equalTo: albumImageView.widthAnchor),

			stack.topAnchor.constraint(equalTo: albumImageView.bottomAnchor, constant: 8),
			stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
			stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
			stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
		])
	}

	private func configureLabels() {
		titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .medium)
		titleLabel.adjustsFontSizeToFitWidth = true
		titleLabel.minimumScaleFactor = 0.65
		artistLabel.font = UIFont.systemFont(ofSize: 19, weight: .medium)
		artistLabel.textColor = .secondaryLabel
		genreLabel.font = UIFont.systemFont(ofSize: 17, weight: .light)
		releaseDateLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
		copyrightLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
		copyrightLabel.textColor = .secondaryLabel

		itunesStoreButton.setTitle("iTunes Store", for: .normal)
		itunesStoreButton.setImage(UIImage(systemName: "cart"), for: .normal)
		itunesStoreButton.setTitleColor(.systemBlue, for: .normal)
	}

	private func updateViews() {
		albumImageView.image = UIImage(systemName: "music.note")

		titleLabel.text = musicResult.name
		artistLabel.text = musicResult.artistName ?? "Unknown artist"
		genreLabel.text = musicResult.genres.map { $0.name }.filter { $0 != "Music" }.joined(separator: ", ")
		if let releaseDate = musicResult.releaseDate {
			releaseDateLabel.text = Self.dateFormatter.string(from: releaseDate)
		} else {
			releaseDateLabel.text = "Unknown release date"
		}
		copyrightLabel.text = musicResult.copyright ?? "Unknown copyright"

		let imageLoader = mainCoordinator.getImageLoader()
		_ = imageLoader.fetchImage(for: musicResult) { [weak self] result in
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

}
