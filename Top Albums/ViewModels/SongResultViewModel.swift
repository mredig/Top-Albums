//
//  SongResultViewModel.swift
//  Top Albums
//
//  Created by Michael Redig on 5/11/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import Foundation

struct SongResultViewModel {
	let songResult: SongResult
	var loader: ImageLoader?

	private static let currencyFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.locale = NSLocale.current
		return formatter
	}()

	var artistName: String {
		songResult.artistName
	}

	var collectionName: String {
		songResult.collectionName
	}

	var trackName: String {
		songResult.trackName
	}

	var previewURL: URL {
		songResult.previewUrl
	}

	var price: String? {
		Self.currencyFormatter.string(from: songResult.trackPrice as NSNumber)
	}

	var previewData: Data?

	func loadPreview() {
		guard loader != nil else {
			print("Can't get preview data for song without a loader")
			return
		}
		// do the loading here
	}
}
