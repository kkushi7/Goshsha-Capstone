//
//  TestableScrapBookView.swift
//  Goshsha Capstone
//
//  Created by Joana Ugarte on 12/2/24.
//

import XCTest
@testable import Goshsha_Capstone

class TestableScrapBookView: ScrapBookViewController {
    var capturedPresentedViewController: UIViewController?

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        capturedPresentedViewController = viewControllerToPresent
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
}
