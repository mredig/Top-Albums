//
//  ServerSideSimulator.swift
//  Top AlbumsTests
//
//  Created by Michael Redig on 5/9/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import Foundation
import NetworkHandler

class ServerSideSimulator {

	/// A closure by which a dictionary lookup is used to confirm a resource exists at a given url.
	let serverSessionSimulator: NetworkMockingSession = {
		let session = NetworkMockingSession { request -> (Data?, Int, Error?) in
			guard let data = ServerSideSimulator.serverTable[request.url] else {
				print("Unrecognized test URL: \(request.url as Any)")
				return (nil, 404, nil)
			}

			return (data, 200, nil)
		}
		return session
	}()

	private static let serverTable: [URL?: Data?] = {
		let urls = [
			URL(string: "https://rss.itunes.apple.com/api/v1/us/apple-music/top-albums/all/10/non-explicit.json"),
			URL(string: "https://rss.itunes.apple.com/api/v1/us/apple-music/top-albums/all/10/explicit.json"),
			URL(string: "https://rss.itunes.apple.com/api/v1/us/apple-music/coming-soon/all/10/non-explicit.json"),
			URL(string: "https://is5-ssl.mzstatic.com/image/thumb/Music123/v4/e8/cb/4a/e8cb4a95-7b2b-d490-0ff6-519e77129381/886448462880.jpg/200x200bb.png"),
			URL(string: "https://is5-ssl.mzstatic.com/image/thumb/Music123/v4/e8/cb/4a/e8cb4a95-7b2b-d490-0ff6-519e77129381/886448462880.jpg/1024x1024bb.png"),
			URL(string: "https://itunes.apple.com/lookup?id=1511995770&entity=song"),
			URL(string: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview113/v4/2b/b0/3e/2bb03ea0-ac15-f265-633c-9acf88f71928/mzaf_746631026398828737.plus.aac.p.m4a")
			].compactMap { $0 }

		let data = [
			top10AppleMusicAlbumsNE,
			top10AppleMusicAlbumsE,
			top10AppleMusicComingSoonNE,
			try? Data(contentsOf: sampleFileURL(for: "sampleImage", fileExtension: "png")),
			try? Data(contentsOf: sampleFileURL(for: "sampleImageLarge", fileExtension: "png")),
			sampleSongPreviewsJSON,
			try? Data(contentsOf: sampleFileURL(for: "samplePreview", fileExtension: "m4a")),
		]

		var dict: [URL?: Data?] = [:]
		zip(urls, data).forEach { dict[$0.0] = $0.1 }
		return dict
	}()

	private static func sampleFileURL(for resourceNamed: String, fileExtension: String) -> URL {
		let bundle = Bundle(for: Self.self)
		guard let url = bundle.url(forResource: resourceNamed, withExtension: fileExtension) else { fatalError("Missing file named: \(resourceNamed)") }
		return url
	}

}
