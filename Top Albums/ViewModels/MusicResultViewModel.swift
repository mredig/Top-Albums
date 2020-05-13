//
//  MusicResultViewModel.swift
//  Top Albums
//
//  Created by Michael Redig on 5/8/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import Foundation

struct MusicResultViewModel {
	let musicResult: MusicResult

	private static let dateFormatterToDate: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		return formatter
	}()

	private static let dateFormatterToString: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		return dateFormatter
	}()

	var artistName: String? {
		musicResult.artistName
	}
	var id: Int? {
		Int(musicResult.id)
	}
	var releaseDate: Date? {
		Self.dateFormatterToDate.date(from: musicResult.releaseDate ?? "")
	}
	var formattedReleaseDate: String? {
		guard let date = releaseDate else { return nil }
		return Self.dateFormatterToString.string(from: date)
	}
	var name: String {
		musicResult.name
	}
	var kind: String {
		musicResult.kind
	}
	var copyright: String? {
		musicResult.copyright
	}
	var artistID: Int? {
		Int(musicResult.artistId ?? "nan")
	}
	var artistURL: URL? {
		musicResult.artistUrl
	}
	var normalArtworkURL: URL {
		musicResult.artworkUrl100
	}
	var highResArtworkURL: URL {
		// This is accessing undocumented aspects of the API
		var url = normalArtworkURL
		url.deleteLastPathComponent()
		url.appendPathComponent("1024x1024bb")
		url.appendPathExtension("png")
		return url
	}
	var genres: [Genre] {
		musicResult.genres
	}
	var url: URL {
		musicResult.url
	}

}
