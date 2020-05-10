//
//  MusicResult.swift
//  Top Albums
//
//  Created by Michael Redig on 5/6/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import Foundation

struct Genre: Decodable, Equatable {
	let name: String
}

struct MusicResults: Decodable {
	let results: [MusicResult]
}

struct MusicResult: Decodable {
	let artistName: String?
	let id: String
	let releaseDate: String?
	let name: String
	let kind: String
	let copyright: String?
	let artistId: String?
	let artistUrl: URL?
	let artworkUrl100: URL
	let genres: [Genre]
	let url: URL
}
