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
	func filtersViewControllerHasCompleted(_ filtersViewController: FiltersViewController)
}

class FiltersViewController: UIViewController {

	private static let explicitResultLabelString = "Include Explicit Results"
	// get the service strings directly from the respective ViewModel's constants
	private static let appleMusicServiceString = MediaTypeViewModel(mediaType: .appleMusic(type: .comingSoon)).serviceString
	private static let iTunesServiceString = MediaTypeViewModel(mediaType: .iTunesMusic(type: .hotTracks)).serviceString

	private static let accessibilityIDServiceSelector = "ServiceSelector"
	private static let accessibilityIDServiceOptionPicker = "OptionPicker"
	private static let accessibilityIDServiceExplicitnessToggle = "ExplicitnessToggle"

	// MARK: - Properties
	let coordinator: FiltersViewControllerCoordinator

	// MARK: - Subviews
	let serviceSegmentedControl = UISegmentedControl()
	let feedPicker = UIPickerView()
	let explicitToggle = UISwitch()
	let applyButton = UIButton()

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
		view.addSubview(rootStack)

		serviceSegmentedControl.setContentCompressionResistancePriority(.init(751), for: .vertical)
		rootStack.addArrangedSubview(serviceSegmentedControl)
		rootStack.addArrangedSubview(feedPicker)

		feedPicker.delegate = self
		feedPicker.dataSource = self

		view.constrain(subview: rootStack, inset: UIEdgeInsets(horizontal: 16, vertical: 24))

		let explicitToggleStack = UIStackView()
		explicitToggleStack.axis = .horizontal
		explicitToggleStack.alignment = .lastBaseline
		explicitToggleStack.distribution = .fill
		explicitToggleStack.spacing = UIStackView.spacingUseSystem
		rootStack.addArrangedSubview(explicitToggleStack)

		let label = UILabel()
		label.text = Self.explicitResultLabelString
		explicitToggleStack.addArrangedSubview(label)

		explicitToggleStack.addArrangedSubview(explicitToggle)

		rootStack.addArrangedSubview(applyButton)
	}

	private func configureViews() {
		serviceSegmentedControl.insertSegment(withTitle: Self.appleMusicServiceString, at: 0, animated: false)
		serviceSegmentedControl.insertSegment(withTitle: Self.iTunesServiceString, at: 1, animated: false)
		serviceSegmentedControl.addTarget(self, action: #selector(serviceSegmentedControlChanged(_:)), for: .valueChanged)
		serviceSegmentedControl.setupAccessibilityIdentifier(on: self, id: Self.accessibilityIDServiceSelector)

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
		feedPicker.setupAccessibilityIdentifier(on: self, id: Self.accessibilityIDServiceOptionPicker)

		explicitToggle.isOn = coordinator.allowExplicitResults
		explicitToggle.setupAccessibilityIdentifier(on: self, id: Self.accessibilityIDServiceExplicitnessToggle)

		applyButton.setTitle("Apply", for: .normal)
		applyButton.setTitleColor(.systemBlue, for: .normal)
		applyButton.addTarget(self, action: #selector(applyButtonPressed(_:)), for: .touchUpInside)

		view.backgroundColor = .secondarySystemBackground
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

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		if UIDevice.current.orientation == .portrait {
			applyButton.isHidden = true
		} else {
			applyButton.isHidden = false
		}
	}

	@objc func serviceSegmentedControlChanged(_ sender: UISegmentedControl) {
		updateCurrentOptions(selectingFirstRow: true)
	}

	@objc func applyButtonPressed(_ sender: UIButton) {
		coordinator.filtersViewControllerHasCompleted(self)
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
