//
//  xkcd_assignment_UITests.swift
//  xkcd_assignment_UITests
//
//  Created by Tijana on 04/03/2023.
//

import XCTest

final class xkcd_assignment_UITests: XCTestCase {
    
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    override func tearDownWithError() throws {
        app.terminate()
    }

    func testBasicNavigation() throws {
        let latestComicValue = app.staticTexts[AccessibilityIdentifier.comicNum.rawValue].firstMatch.label
        app.buttons[AccessibilityIdentifier.prevButton.rawValue].firstMatch.tap()
        
        let prevComicValue = app.staticTexts[AccessibilityIdentifier.comicNum.rawValue].firstMatch.label
        XCTAssertNotEqual(prevComicValue, latestComicValue) // assert that we navigated from the page and the comic num has changed

        app.buttons[AccessibilityIdentifier.latestButton.rawValue].firstMatch.tap()
        
        let newLatestComicValue = app.staticTexts[AccessibilityIdentifier.comicNum.rawValue].firstMatch.label
        XCTAssertEqual(newLatestComicValue, latestComicValue) // assert that we navigated back to the latest comic
        
        app.buttons[AccessibilityIdentifier.prevButton.rawValue].firstMatch.tap()
        app.buttons[AccessibilityIdentifier.nextButton.rawValue].firstMatch.tap()
        
        let currentComicValue = app.staticTexts[AccessibilityIdentifier.comicNum.rawValue].firstMatch.label
        XCTAssertEqual(currentComicValue, latestComicValue) // verify that we moved to previous and back to the latest
    }
}
