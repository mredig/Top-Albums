//
//  FiltersViewController.swift
//  Top Albums
//
//  Created by Michael Redig on 5/8/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import UIKit

protocol FiltersViewControllerDelegate: AnyObject {
	func didFinishSelectingSearchFilters(on filtersViewController: FiltersViewController, searchFilter: MediaType)
}

class FiltersViewController: UIViewController {

	// MARK: - Properties
	let mainCoordinator: MainCoordinator

	weak var delegate: FiltersViewControllerDelegate?

	// MARK: - Subviews
	let picker = UIPickerView()

	// MARK: - Lifecycle
	init(mainCoordinator: MainCoordinator) {
		self.mainCoordinator = mainCoordinator
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

		picker.delegate = self
		picker.dataSource = self
		picker.translatesAutoresizingMaskIntoConstraints = false

		view.addSubview(picker)

		NSLayoutConstraint.activate([
			picker.topAnchor.constraint(equalTo: view.topAnchor),
			picker.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			picker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			picker.trailingAnchor.constraint(equalTo: view.trailingAnchor),
		])
	}

	private func configureViews() {
		let comp1: Int
		let comp0: Int
		switch mainCoordinator.searchOptions {
		case .appleMusic(type: let type):
			comp0 = 0
			comp1 = MediaType.AppleMusicType.allCases.firstIndex(of: type) ?? 0
		case .iTunesMusic(type: let type):
			comp0 = 1
			comp1 = MediaType.iTunesMusicFeedType.allCases.firstIndex(of: type) ?? 0
		}
		picker.selectRow(comp0, inComponent: 0, animated: false)
		picker.selectRow(comp1, inComponent: 1, animated: false)
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


		delegate?.didFinishSelectingSearchFilters(on: self, searchFilter: newSearch)
	}
}

extension FiltersViewController: UIPickerViewDataSource, UIPickerViewDelegate {
	// component 0 determines service
	// component 1 determines which feed from said service


	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		if component == 0 {
			switch row {
			case 0:
				return "Apple Music"
			default:
				return "iTunes Music"
			}

		}
		switch pickerView.selectedRow(inComponent: 0) {
		case 0: // MediaType.appleMusic
			return MediaType.AppleMusicType.allCases[row].rawValue.cleanedFromAPI
		case 1: // MediaType.iTunesMusic
			return MediaType.iTunesMusicFeedType.allCases[row].rawValue.cleanedFromAPI
		default:
			return MediaType.AppleMusicType.allCases[row].rawValue.cleanedFromAPI
		}
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


fileprivate extension String {
	var cleanedFromAPI: String {
		replacingOccurrences(of: "-", with: " ").capitalized
	}
}
