//
//  iTunesAPI.swift
//  Top Albums
//
//  Created by Michael Redig on 5/6/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import Foundation
import NetworkHandler

enum MediaType: Equatable {

	enum AppleMusicType: String, CaseIterable {
		case comingSoon = "coming-soon"
		case hotTracks = "hot-tracks"
		case newReleases = "new-releases"
		case topAlbums = "top-albums"
		case topSongs = "top-songs"
	}

	enum iTunesMusicFeedType: String, CaseIterable {
		case hotTracks = "hot-tracks"
		case newMusic = "new-music"
		case recentReleases = "recent-releases"
		case topAlbums = "top-albums"
		case topSongs = "top-songs"
	}

	case appleMusic(type: AppleMusicType)
	case iTunesMusic(type: iTunesMusicFeedType)

	var urlComponent: String {
		switch self {
		case .appleMusic:
			return "apple-music"
		case .iTunesMusic:
			return "itunes-music"
		}
	}
}

//https://rss.itunes.apple.com/api/v1/us/apple-music	/hot-tracks/all/100/explicit.json
//https://rss.itunes.apple.com/api/v1/us/itunes-music	/hot-tracks/all/100/explicit.json
//https://rss.itunes.apple.com/api/v1/us/ios-apps		/new-apps-we-love/all/100/explicit.json
//https://rss.itunes.apple.com/api/v1/us/audiobooks		/top-audiobooks/all/100/explicit.json
//https://rss.itunes.apple.com/api/v1/us/books			/top-free/all/100/explicit.json
//https://rss.itunes.apple.com/api/v1/us/tv-shows		/top-tv-episodes/all/100/explicit.json
//https://rss.itunes.apple.com/api/v1/us/movies			/top-movies/all/100/explicit.json

class iTunesAPIController {
	private let networkHandler = NetworkHandler.default

	var mediaSearch = MediaType.appleMusic(type: .topAlbums)
	var allowExplicitResults = false
	var maxResults = 100

	var isResultsLoadInProgress: Bool {
		currentResultOperation?.state == .running
	}

	private var currentResultOperation: URLSessionDataTask?

	init() {}

	func generateUrl() -> URL {
		guard let baseURL = URL(string: "https://rss.itunes.apple.com/api/v1/us/") else { fatalError("Base URL is broken! \(#file): \(#line)")}

		let feedType: String
		switch mediaSearch {
		case .appleMusic(type: let type):
			feedType = type.rawValue
		case .iTunesMusic(type: let type):
			feedType = type.rawValue
		}

		return baseURL
			.appendingPathComponent(mediaSearch.urlComponent)
			.appendingPathComponent(feedType)
			.appendingPathComponent("all")
			.appendingPathComponent("\(maxResults)")
			.appendingPathComponent(allowExplicitResults ? "explicit" : "non-explicit")
			.appendingPathExtension("json")
	}

	func fetchResults(completion: @escaping (Result<[MusicResult], NetworkError>) -> Void) {
		currentResultOperation?.cancel()
		let request = generateUrl().request

		currentResultOperation = networkHandler.transferMahCodableDatas(with: request) { (result: Result<[String: MusicResults], NetworkError>) in
			switch result {
			case .success(let resultsDict):
				guard let results = resultsDict["feed"] else {
					completion(.failure(NetworkError.dataWasNull))
					print("iTunes has changed their results feed format.")
					return
				}
				completion(.success(results.results))
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}
}

extension iTunesAPIController: ImageLoader {
	func fetchImage(for musicResult: MusicResult, attemptHighRes: Bool = false, completion: @escaping (Result<Data, NetworkError>) -> Void) -> ImageLoadOperation? {
		if attemptHighRes {
			// This is accessing undocumented aspects of the API
			var url = musicResult.artworkUrl100
			url.deleteLastPathComponent()
			url.appendPathComponent("1024x1024bb")
			url.appendPathExtension("png")
			let highRequest = url.request

			return networkHandler.transferMahDatas(with: highRequest, usingCache: true, completion: completion)
		} else {
			let request = musicResult.artworkUrl100.request
			return networkHandler.transferMahDatas(with: request, usingCache: true, completion: completion)
		}
	}
}
