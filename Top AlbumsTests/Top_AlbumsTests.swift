//
//  Top_AlbumsTests.swift
//  Top AlbumsTests
//
//  Created by Michael Redig on 5/6/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import XCTest
@testable import Top_Albums

class Top_AlbumsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

	func testURLGeneration() {
		let itunesController = iTunesAPIController()
		itunesController.allowExplicitResults = false

		itunesController.mediaSearch = .appleMusic(type: .topAlbums)
		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/apple-music/top-albums/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)
		itunesController.mediaSearch = .appleMusic(type: .comingSoon)
		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/apple-music/coming-soon/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)
		itunesController.mediaSearch = .appleMusic(type: .hotTracks)
		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/apple-music/hot-tracks/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)
		itunesController.mediaSearch = .appleMusic(type: .newReleases)
		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/apple-music/new-releases/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)
		itunesController.mediaSearch = .appleMusic(type: .topSongs)
		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/apple-music/top-songs/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)

		itunesController.allowExplicitResults = true
		itunesController.mediaSearch = .appleMusic(type: .topAlbums)
		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/apple-music/top-albums/all/100/explicit.json", itunesController.generateUrl().absoluteString)

		itunesController.allowExplicitResults = false
		itunesController.mediaSearch = .iTunesMusic(type: .hotTracks)
		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/itunes-music/hot-tracks/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)
		itunesController.mediaSearch = .iTunesMusic(type: .newMusic)
		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/itunes-music/new-music/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)
		itunesController.mediaSearch = .iTunesMusic(type: .recentReleases)
		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/itunes-music/recent-releases/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)
		itunesController.mediaSearch = .iTunesMusic(type: .topAlbums)
		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/itunes-music/top-albums/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)
		itunesController.mediaSearch = .iTunesMusic(type: .topSongs)
		XCTAssertEqual("https://rss.itunes.apple.com/api/v1/us/itunes-music/top-songs/all/100/non-explicit.json", itunesController.generateUrl().absoluteString)
	}

}
