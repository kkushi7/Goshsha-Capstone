//
//  StreakTests.swift
//  Goshsha Capstone
//
//  Created by Joana Ugarte on 12/1/24.
//

import XCTest
@testable import Goshsha_Capstone

final class StreakControllerTests: XCTestCase {
    var controller: TestableStreak!

    override func setUpWithError() throws {
        controller = TestableStreak()
        controller.loadViewIfNeeded()
    }

    override func tearDownWithError() throws {
        controller = nil
    }

    func testStreakLabelInitialization() {
        XCTAssertEqual(controller.streakLabel.text, "Current Streak: 0", "Streak label should display 'Current Streak: 0' on initialization.")
    }

    func testIncrementStreak() {
        controller.streakNum = 0

        // simulate tapping the increment button
        controller.incrementButton.sendActions(for: UIControl.Event.touchUpInside)

        // verify state changes
        XCTAssertEqual(controller.streakNum, 1, "Streak number should increment by 1.")
        XCTAssertEqual(controller.streakLabel.text, "Current Streak: 1", "Streak label should update to reflect the incremented streak.")
        XCTAssertFalse(controller.incrementButton.isEnabled, "Increment button should be disabled after incrementing.")
    }

    func testButtonDisabledAfterIncrement() {
        controller.streakNum = 5

        controller.incrementButton.sendActions(for: UIControl.Event.touchUpInside)

        XCTAssertFalse(controller.incrementButton.isEnabled, "Button should be disabled after incrementing.")
        XCTAssertEqual(controller.incrementButton.title(for: .disabled), "Already Signed In Today", "Button title should indicate the streak was already incremented.")
    }
}
