//
//  SongResult.swift
//  Top Albums
//
//  Created by Michael Redig on 5/11/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import Foundation

struct SongResult: Codable, Comparable {
	let wrapperType: String
	let kind: String
	let artistId: Int
	let collectionId: Int
	let trackId: Int
	let artistName: String
	let collectionName: String
	let trackName: String
	let previewUrl: URL
	let trackPrice: Double
	let discCount: Int
	let discNumber: Int
	let trackNumber: Int
	let trackCount: Int
	let isStreamable: Bool

	static func < (lhs: SongResult, rhs: SongResult) -> Bool {
		if lhs.discNumber == rhs.discNumber {
			return lhs.trackNumber < rhs.trackNumber
		} else {
			return lhs.discNumber < rhs.discNumber
		}
	}
}


struct SongResults: Codable {
	static private let wrapperTypeTrackString = "track"
	static private let kindSongString = "song"

	let results: [SongResult]

	enum CodingKeys: String, CodingKey {
		case results
	}
	enum DummyKey: String, CodingKey {
		case kind
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		var tempResults: [SongResult] = []
		var resultsContainer = try container.nestedUnkeyedContainer(forKey: .results)
		while !resultsContainer.isAtEnd {
			do {
				let result = try resultsContainer.decode(SongResult.self)
				guard result.wrapperType == Self.wrapperTypeTrackString && result.kind == Self.kindSongString else { continue }
				tempResults.append(result)
			} catch {
				// Some array elements aren't "songs" but other meta data - the only way to move forward in the
				// container is to successfully decode, so this is a simple, minimal decoding to move the index forward
				// to get the real results following
				_ = try resultsContainer.nestedContainer(keyedBy: DummyKey.self)
				continue
			}
		}
		self.results = tempResults.sorted()
	}
}
