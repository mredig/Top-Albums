//
//  iTunesAPI.swift
//  Top Albums
//
//  Created by Michael Redig on 5/6/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import Foundation
import NetworkHandler

class iTunesAPIController {

	private static let iTunesPreviewAPIBaseURL = "https://itunes.apple.com/lookup"

	private static let pathComponentAll = "all"
	private static let pathComponentExplicit = "explicit"
	private static let pathComponentNonExplicit = "non-explicit"
	private static let pathExtensionJson = "json"

	private static let resultsDictionaryKey = "feed"

	private let networkHandler = NetworkHandler.default
	private let session: NetworkLoader

	var mediaSearch = MediaType.appleMusic(type: .topAlbums)
	var allowExplicitResults = false
	var maxResults = 100

	/// There should only ever be one operation fetching the feed at a time. Allows cancelling previous prior to starting a new one.
	private var currentResultOperation: NetworkLoadingTask?

	private let baseURL: URL
	init(baseURLString: String, session: NetworkLoader = URLSession.shared) {
		guard let baseURL = URL(string: baseURLString) else {
			fatalError("Base URL is invalid (\(baseURLString)) \(#file): \(#line)")
		}
		self.baseURL = baseURL
		self.session = session
	}

	func generateUrl() -> URL {
		let feedType: String
		switch mediaSearch {
		case .appleMusic(type: let type):
			feedType = type.rawValue
		case .iTunesMusic(type: let type):
			feedType = type.rawValue
		}

		return baseURL
			.appendingPathComponent(MediaTypeViewModel(mediaType: mediaSearch).urlComponent)
			.appendingPathComponent(feedType)
			.appendingPathComponent(Self.pathComponentAll)
			.appendingPathComponent("\(maxResults)")
			.appendingPathComponent(allowExplicitResults ? Self.pathComponentExplicit : Self.pathComponentNonExplicit)
			.appendingPathExtension(Self.pathExtensionJson)
	}

	func fetchResults(completion: @escaping (Result<[MusicResult], NetworkError>) -> Void) {
		currentResultOperation?.cancel()
		let request = generateUrl().request

		currentResultOperation = networkHandler.transferMahCodableDatas(with: request, session: session) { (result: Result<[String: MusicResults], NetworkError>) in
			switch result {
			case .success(let resultsDict):
				guard let results = resultsDict[Self.resultsDictionaryKey] else {
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
	func fetchImage(for musicResultVM: MusicResultViewModel, attemptHighRes: Bool = false, completion: @escaping (Result<Data, NetworkError>) -> Void) -> NetworkLoadingTask? {
		let request: NetworkRequest
		if attemptHighRes {
			request = musicResultVM.highResArtworkURL.request
		} else {
			request = musicResultVM.normalArtworkURL.request
		}
		return networkHandler.transferMahDatas(with: request, usingCache: true, session: session, completion: completion)
	}
}

extension iTunesAPIController: SongPreviewLoader {
	private static let queryItemID = "id"
	private static let queryItemEntity = "entity"
	private static let queryItemValueSong = "song"

	func fetchPreviewList(for album: MusicResultViewModel, completion: @escaping (Result<[SongResult], NetworkError>) -> Void) {
		guard album.kind == MusicResultViewModel.ResultKind.album, let id = album.id else { return }

		var components = URLComponents(string: Self.iTunesPreviewAPIBaseURL)
		let idQuery = URLQueryItem(name: Self.queryItemID, value: "\(id)")
		let entityQuery = URLQueryItem(name: Self.queryItemEntity, value: Self.queryItemValueSong)
		components?.queryItems = [idQuery, entityQuery]

		guard let url = components?.url else { return }

		networkHandler.transferMahCodableDatas(with: url.request, session: session) { (result: Result<SongResults, NetworkError>) in
			switch result {
			case .success(let allResults):
				completion(.success(allResults.results))
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}

	@discardableResult func fetchPreview(for song: SongResultViewModel, completion: @escaping (Result<Data, NetworkError>) -> Void) -> NetworkLoadingTask {
		let request = song.previewURL.request
		return networkHandler.transferMahDatas(with: request, usingCache: true, session: session, completion: completion)
	}
}
