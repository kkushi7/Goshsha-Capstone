//
//  TestableStreak.swift
//  Goshsha Capstone
//
//  Created by Joana Ugarte on 12/1/24.
//
//

import XCTest
@testable import Goshsha_Capstone

class TestableStreak: StreakController {
    override func increaseStreakTapped() {
        guard !hasIncrementedToday else { return }

        // simulate successful streak increment
        streakNum += 1
        streakLabel.text = "Current Streak: \(streakNum)"
        incrementButton.isEnabled = false
        incrementButton.setTitle("Already Signed In Today", for: .disabled)
    }
}
