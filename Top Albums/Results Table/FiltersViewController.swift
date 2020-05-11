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
	let picker = UIPickerView()
	let explicitToggle = UISwitch()

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

		let stack = UIStackView()
		stack.axis = .vertical
		stack.alignment = .fill
		stack.distribution = .fill
		stack.spacing = UIStackView.spacingUseSystem
		stack.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(stack)

		stack.addArrangedSubview(picker)

		picker.delegate = self
		picker.dataSource = self

		NSLayoutConstraint.activate([
			stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
			stack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
			stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
		])

		let substack = UIStackView()
		substack.axis = .horizontal
		substack.alignment = .fill
		substack.distribution = .fill
		substack.spacing = UIStackView.spacingUseSystem
		stack.addArrangedSubview(substack)

		let label = UILabel()
		label.text = "Show Explicit Results"
		substack.addArrangedSubview(label)

		substack.addArrangedSubview(explicitToggle)
	}

	private func configureViews() {
		let comp1: Int
		let comp0: Int
		switch coordinator.searchOptions {
		case .appleMusic(type: let type):
			comp0 = 0
			comp1 = MediaType.AppleMusicType.allCases.firstIndex(of: type) ?? 0
		case .iTunesMusic(type: let type):
			comp0 = 1
			comp1 = MediaType.iTunesMusicFeedType.allCases.firstIndex(of: type) ?? 0
		}
		picker.selectRow(comp0, inComponent: 0, animated: false)
		picker.selectRow(comp1, inComponent: 1, animated: false)
		picker.setupAccessibilityIdentifier(on: self, id: "OptionPicker")

		explicitToggle.isOn = coordinator.allowExplicitResults
		explicitToggle.setupAccessibilityIdentifier(on: self, id: "ExplicitnessToggle")
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)

		let newSearch: MediaType
		switch picker.selectedRow(inComponent: 0) {
		case 0:
			newSearch = .appleMusic(type: MediaType.AppleMusicType.allCases[picker.selectedRow(inComponent: 1)])
		default:
			newSearch = .iTunesMusic(type: MediaType.iTunesMusicFeedType.allCases[picker.selectedRow(inComponent: 1)])
		}

		coordinator.didFinishSelectingSearchFilters(on: self, searchFilter: newSearch, showExplicit: explicitToggle.isOn)
	}
}

extension FiltersViewController: UIPickerViewDataSource, UIPickerViewDelegate, UIPickerViewAccessibilityDelegate {
	// component 0 determines service
	// component 1 determines which feed from said service

	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		if component == 0 {
			switch row {
			case 0:
				return "Music"
			default:
				return "iTunes"
			}
		}

		let mediaTypeVM: MediaTypeViewModel
		
		switch pickerView.selectedRow(inComponent: 0) {
		case 0: // MediaType.appleMusic
			let search = MediaType.appleMusic(type: MediaType.AppleMusicType.allCases[row])
			mediaTypeVM = MediaTypeViewModel(mediaType: search)
		case 1: // MediaType.iTunesMusic
			let search = MediaType.iTunesMusic(type: MediaType.iTunesMusicFeedType.allCases[row])
			mediaTypeVM = MediaTypeViewModel(mediaType: search)
		default:
			let search = MediaType.appleMusic(type: MediaType.AppleMusicType.allCases[row])
			mediaTypeVM = MediaTypeViewModel(mediaType: search)
		}
		return mediaTypeVM.feedTypeString
	}

	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		guard component == 1 else { return 2 }
		switch pickerView.selectedRow(inComponent: 0) {
		case 0: // MediaType.appleMusic
			return MediaType.AppleMusicType.allCases.count
		case 1: // MediaType.iTunesMusic
			return MediaType.iTunesMusicFeedType.allCases.count
		default:
			return MediaType.AppleMusicType.allCases.count
		}
	}

	func numberOfComponents(in pickerView: UIPickerView) -> Int { 2 }

	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		guard component == 0 else { return }
		pickerView.reloadComponent(1)
	}
}
