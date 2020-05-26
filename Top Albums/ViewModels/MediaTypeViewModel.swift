//
//  MediaTypeViewModel.swift
//  Top Albums
//
//  Created by Michael Redig on 5/8/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import Foundation

struct MediaTypeViewModel {
	private let urlComponentAppleMusic = "apple-music"
	private let urlComponentiTunes = "itunes-music"
	private let serviceStringAppleMusic = "Music"
	private let serviceStringiTunes = "iTunes"

	let mediaType: MediaType

	var urlComponent: String {
		switch mediaType {
		case .appleMusic:
			return urlComponentAppleMusic
		case .iTunesMusic:
			return urlComponentiTunes
		}
	}

	var serviceString: String {
		switch mediaType {
		case .appleMusic:
			return serviceStringAppleMusic
		case .iTunesMusic:
			return serviceStringiTunes
		}
	}

	var feedTypeString: String {
		switch mediaType {
		case .appleMusic(type: let type):
			return type.rawValue.replacingOccurrences(of: "-", with: " ").capitalized
		case .iTunesMusic(type: let type):
			return type.rawValue.replacingOccurrences(of: "-", with: " ").capitalized
		}
	}

	var fullString: String {
		"\(serviceString): \(feedTypeString)"
	}
}
