//
//  MusicResult.swift
//  Top Albums
//
//  Created by Michael Redig on 5/6/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import Foundation

struct Genre: Decodable {
	let genreId: Int
	let name: String
	let url: URL

	enum CodingKeys: String, CodingKey {
		case genreId
		case name
		case url
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		let genreStr = try container.decode(String.self, forKey: .genreId)
		genreId = try Int(genreStr).unwrap()
		name = try container.decode(String.self, forKey: .name)
		url = try container.decode(URL.self, forKey: .url)
	}
}

struct MusicResults: Decodable {
	let results: [MusicResult]
}

struct MusicResult: Decodable {
	let artistName: String?
	let id: String
	let releaseDate: Date?
	let name: String
	let kind: String
	let copyright: String?
	let artistId: Int?
	let artistUrl: URL?
	let artworkUrl100: URL
	let genres: [Genre]
	let url: URL

	enum CodingKeys: String, CodingKey {
		case artistName
		case id
		case releaseDate
		case name
		case kind
		case copyright
		case artistId
		case artistUrl
		case artworkUrl100
		case genres
		case url
	}

	private static var dateFormatter: DateFormatter {
		let formatter = DateFormatter()
		formatter.dateFormat = "YYYY-MM-dd"
		return formatter
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		artistName = try container.decodeIfPresent(String.self, forKey: .artistName)
		id = try container.decode(String.self, forKey: .id)
		let releaseDateStr = try container.decodeIfPresent(String.self, forKey: .releaseDate)
		releaseDate = MusicResult.dateFormatter.date(from: releaseDateStr ?? "")
		name = try container.decode(String.self, forKey: .name)
		kind = try container.decode(String.self, forKey: .kind)
		copyright = try container.decodeIfPresent(String.self, forKey: .copyright)
		let artistIdStr = try container.decodeIfPresent(String.self, forKey: .artistId)
		artistId = try? Int(artistIdStr ?? "nan").unwrap()
		artistUrl = try container.decodeIfPresent(URL.self, forKey: .artistUrl)
		artworkUrl100 = try container.decode(URL.self, forKey: .artworkUrl100)
		genres = try container.decode([Genre].self, forKey: .genres)
		url = try container.decode(URL.self, forKey: .url)
	}
}
