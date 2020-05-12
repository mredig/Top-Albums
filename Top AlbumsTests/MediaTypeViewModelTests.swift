//
//  MediaTypeViewModelTests.swift
//  Top AlbumsTests
//
//  Created by Michael Redig on 5/9/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import XCTest
@testable import Top_Albums

class MediaTypeViewModelTests: XCTestCase {

	/// Tests various MediaType output
	func testMediaType() {
		let appleMusicTopAlbums = MediaType.appleMusic(type: .topAlbums)
		let appleMusicVM = MediaTypeViewModel(mediaType: appleMusicTopAlbums)

		XCTAssertEqual("Top Albums", appleMusicVM.feedTypeString)
		XCTAssertEqual("Music", appleMusicVM.serviceString)
		XCTAssertEqual("Music: Top Albums", appleMusicVM.fullString)

		let iTunesRecentReleases = MediaType.iTunesMusic(type: .recentReleases)
		let iTunesVM = MediaTypeViewModel(mediaType: iTunesRecentReleases)

		XCTAssertEqual("Recent Releases", iTunesVM.feedTypeString)
		XCTAssertEqual("iTunes", iTunesVM.serviceString)
		XCTAssertEqual("iTunes: Recent Releases", iTunesVM.fullString)
	}
}
