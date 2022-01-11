//
//  NavigatorUITestsLaunchTests.swift
//  NavigatorUITests
//
//  Created by Sean Najera on 1/10/22.
//

import XCTest
@testable import Navigator

class NavigatorUITestsLaunchTests: XCTestCase {

    let app = XCUIApplication()

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        false
    }

    override func setUpWithError() throws {
        continueAfterFailure = false

        app.launch()
    }

    func testNavigationScreen() {

        let rootScreenText = app.staticTexts["Roots Screen"]
        XCTAssert(rootScreenText.exists)

        let greenButton = app.buttons["Green Screen"]
        XCTAssert(greenButton.exists)

        let blueButton = app.buttons["Blue Screen"]
        XCTAssert(blueButton.exists)

        blueButton.tap()
        let blueScreenText = app.staticTexts["Blue Screen"]
        XCTAssert(blueScreenText.exists)

        let popButton = app.buttons["Pop"]
        popButton.tap()

        XCTAssert(app.staticTexts["Root Screen"].exists)

        app.buttons["Green Screen"].tap()
        let greenScreenText = app.staticTexts["Green Screen"]
        XCTAssert(greenScreenText.exists)

        app.buttons["To Green Screen"].tap()
        XCTAssert(app.staticTexts["Green Screen"].exists)

        let popToButton = app.buttons["Pop To Root"]
        popToButton.tap()

        XCTAssert(app.staticTexts["Root Screen"].exists)
    }
}
