//
//  MediaTypeViewModel.swift
//  Top Albums
//
//  Created by Michael Redig on 5/8/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import Foundation

struct MediaTypeViewModel {
	let mediaType: MediaType

	var urlComponent: String {
		switch mediaType {
		case .appleMusic:
			return "apple-music"
		case .iTunesMusic:
			return "itunes-music"
		}
	}

	var serviceString: String {
		switch mediaType {
		case .appleMusic:
			return "Music"
		case .iTunesMusic:
			return "iTunes"
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
