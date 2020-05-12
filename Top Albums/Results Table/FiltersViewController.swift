//
//  FiltersViewController.swift
//  Top Albums
//
//  Created by Michael Redig on 5/8/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import UIKit

protocol FiltersViewControllerCoordinator: AnyObject {
	var searchOptions: MediaType { get }
	var allowExplicitResults: Bool { get }

	func didFinishSelectingSearchFilters(on filtersViewController: FiltersViewController, searchFilter: MediaType, showExplicit: Bool)
}

class FiltersViewController: UIViewController {

	// MARK: - Properties
	let coordinator: FiltersViewControllerCoordinator

	// MARK: - Subviews
	let serviceSegmentedControl = UISegmentedControl()
	let feedPicker = UIPickerView()
	let explicitToggle = UISwitch()

	var currentOptions = MediaType.appleMusic(type: .topAlbums)

	// MARK: - Lifecycle
	init(controller: FiltersViewControllerCoordinator) {
		self.coordinator = controller
		super.init(nibName: nil, bundle: nil)
		configureLayout()
		configureViews()
	}

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		fatalError("init(nibName:bundle:) has not been implemented")
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func configureLayout() {
		preferredContentSize = CGSize(width: preferredContentSize.width, height: 250)

		let rootStack = UIStackView()
		rootStack.axis = .vertical
		rootStack.alignment = .fill
		rootStack.distribution = .fill
		rootStack.spacing = UIStackView.spacingUseSystem
		rootStack.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(rootStack)

		rootStack.addArrangedSubview(serviceSegmentedControl)
		rootStack.addArrangedSubview(feedPicker)

		feedPicker.delegate = self
		feedPicker.dataSource = self

		NSLayoutConstraint.activate([
			rootStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
			rootStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),
			rootStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			rootStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
		])

		let explicitToggleStack = UIStackView()
		explicitToggleStack.axis = .horizontal
		explicitToggleStack.alignment = .lastBaseline
		explicitToggleStack.distribution = .fill
		explicitToggleStack.spacing = UIStackView.spacingUseSystem
		rootStack.addArrangedSubview(explicitToggleStack)

		let label = UILabel()
		label.text = "Include Explicit Results"
		explicitToggleStack.addArrangedSubview(label)

		explicitToggleStack.addArrangedSubview(explicitToggle)
	}

	private func configureViews() {
		serviceSegmentedControl.insertSegment(withTitle: "Music", at: 0, animated: false)
		serviceSegmentedControl.insertSegment(withTitle: "iTunes", at: 1, animated: false)
		serviceSegmentedControl.addTarget(self, action: #selector(serviceSegmentedControlChanged(_:)), for: .valueChanged)
		serviceSegmentedControl.setupAccessibilityIdentifier(on: self, id: "ServiceSelector")

		currentOptions = coordinator.searchOptions

		let pickerRow: Int
		switch coordinator.searchOptions {
		case .appleMusic(type: let type):
			serviceSegmentedControl.selectedSegmentIndex = 0
			pickerRow = MediaType.AppleMusicType.allCases.firstIndex(of: type) ?? 0
		case .iTunesMusic(type: let type):
			serviceSegmentedControl.selectedSegmentIndex = 1
			pickerRow = MediaType.iTunesMusicFeedType.allCases.firstIndex(of: type) ?? 0
		}
		feedPicker.selectRow(pickerRow, inComponent: 0, animated: false)
		feedPicker.setupAccessibilityIdentifier(on: self, id: "OptionPicker")

		explicitToggle.isOn = coordinator.allowExplicitResults
		explicitToggle.setupAccessibilityIdentifier(on: self, id: "ExplicitnessToggle")
	}

	private func updateCurrentOptions(selectingFirstRow: Bool = false) {
		if selectingFirstRow {
			feedPicker.selectRow(0, inComponent: 0, animated: true)
		}
		let selectedFeedIndex = feedPicker.selectedRow(inComponent: 0)
		switch serviceSegmentedControl.selectedSegmentIndex {
		case 1:
			let type = MediaType.iTunesMusicFeedType.allCases[selectedFeedIndex, default: .topAlbums]
			currentOptions = .iTunesMusic(type: type)
		default:
			let type = MediaType.AppleMusicType.allCases[selectedFeedIndex, default: .topAlbums]
			currentOptions = .appleMusic(type: type)
		}
		feedPicker.reloadAllComponents()
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		coordinator.didFinishSelectingSearchFilters(on: self, searchFilter: currentOptions, showExplicit: explicitToggle.isOn)
	}

	@objc func serviceSegmentedControlChanged(_ sender: UISegmentedControl) {
		updateCurrentOptions(selectingFirstRow: true)
	}
}

extension FiltersViewController: UIPickerViewDataSource, UIPickerViewDelegate, UIPickerViewAccessibilityDelegate {

	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		let mediaType: MediaType

		switch currentOptions {
		case .appleMusic:
			let type = MediaType.AppleMusicType.allCases[row]//, default: .topAlbums]
			mediaType = .appleMusic(type: type)
		case .iTunesMusic:
			let type = MediaType.iTunesMusicFeedType.allCases[row]//, default: .topAlbums]
			mediaType = .iTunesMusic(type: type)
		}

		return MediaTypeViewModel(mediaType: mediaType).feedTypeString
	}

	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		switch currentOptions {
		case .appleMusic:
			return MediaType.AppleMusicType.allCases.count
		case .iTunesMusic:
			return MediaType.iTunesMusicFeedType.allCases.count
		}
	}

	func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		updateCurrentOptions()
	}
}
