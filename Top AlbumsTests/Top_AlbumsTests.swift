//
//  Top_AlbumsTests.swift
//  Top AlbumsTests
//
//  Created by Michael Redig on 5/6/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import XCTest
@testable import Top_Albums
import NetworkHandler

class Top_AlbumsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

//	func testURLGeneration() {
//		let itunesController = iTunesAPIController()
//		itunesController.allowExplicitResults = false
//
//		itunesController.mediaSearch = .appleMusic(type: .topAlbums)
//		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/apple-music/top-albums/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)
//		itunesController.mediaSearch = .appleMusic(type: .comingSoon)
//		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/apple-music/coming-soon/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)
//		itunesController.mediaSearch = .appleMusic(type: .hotTracks)
//		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/apple-music/hot-tracks/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)
//		itunesController.mediaSearch = .appleMusic(type: .newReleases)
//		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/apple-music/new-releases/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)
//		itunesController.mediaSearch = .appleMusic(type: .topSongs)
//		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/apple-music/top-songs/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)
//
//		itunesController.allowExplicitResults = true
//		itunesController.mediaSearch = .appleMusic(type: .topAlbums)
//		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/apple-music/top-albums/all/100/explicit.json", itunesController.generateUrl().absoluteString)
//
//		itunesController.allowExplicitResults = false
//		itunesController.mediaSearch = .iTunesMusic(type: .hotTracks)
//		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/itunes-music/hot-tracks/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)
//		itunesController.mediaSearch = .iTunesMusic(type: .newMusic)
//		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/itunes-music/new-music/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)
//		itunesController.mediaSearch = .iTunesMusic(type: .recentReleases)
//		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/itunes-music/recent-releases/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)
//		itunesController.mediaSearch = .iTunesMusic(type: .topAlbums)
//		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/itunes-music/top-albums/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)
//		itunesController.mediaSearch = .iTunesMusic(type: .topSongs)
//		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/itunes-music/top-songs/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)
//	}

	func testFetchTopAlbumResults() throws {
		let myExpectation = expectation(description: "netload")
		let loader = NetworkMockingSession(mockData: top100AppleMusicAlbums, mockError: nil)

		let apiController = iTunesAPIController(baseURLString: "https://rss.itunes.apple.com/api/v1/us/", session: loader)

		var firstResult: MusicResult?

		apiController.mediaSearch = .appleMusic(type: .topAlbums)
		apiController.fetchResults { result in
			do {
				let results = try result.get()
				firstResult = results.first
			} catch {
				XCTFail("There was an error mock fetching the data")
			}
			myExpectation.fulfill()
		}
		wait(for: [myExpectation], timeout: 2)
		guard let firstResultUnwrapped = firstResult else {
			XCTFail("First result was invalid")
			return
		}

		let firstResultVM = MusicResultViewModel(musicResult: firstResultUnwrapped)
		XCTAssertEqual("Lil Tjay", firstResultVM.artistName)
		XCTAssertEqual(1511995770, firstResultVM.id)
		XCTAssertEqual("May 8, 2020", firstResultVM.formattedReleaseDate)
		XCTAssertEqual("album", firstResultVM.kind)
		XCTAssertEqual("℗ 2020 Columbia Records, a Division of Sony Music Entertainment", firstResultVM.copyright)
		XCTAssertEqual(1436446949, firstResultVM.artistID)
		XCTAssertEqual(URL(string: "https://music.apple.com/us/artist/lil-tjay/1436446949?app=music"), firstResultVM.artistURL)
		XCTAssertEqual(URL(string: "https://is5-ssl.mzstatic.com/image/thumb/Music123/v4/e8/cb/4a/e8cb4a95-7b2b-d490-0ff6-519e77129381/886448462880.jpg/200x200bb.png"), firstResultVM.normalArtworkURL)
		XCTAssertEqual("Hip-Hop/Rap", firstResultVM.genres.first?.name)
		XCTAssertEqual("Music", firstResultVM.genres.last?.name)
		XCTAssertEqual(URL(string: "https://music.apple.com/us/album/state-of-emergency/1511995770?app=music"), firstResultVM.url)
	}

}
