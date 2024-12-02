//
//  ScrapBookViewTests.swift
//  Goshsha Capstone
//
//  Created by Joana Ugarte on 12/1/24.
//

import XCTest
@testable import Goshsha_Capstone

final class ScrapBookViewControllerTests: XCTestCase {
    var controller: ScrapBookViewController!

    override func setUpWithError() throws {
        controller = ScrapBookViewController()
        controller.loadViewIfNeeded()
    }

    override func tearDownWithError() throws {
        controller = nil
    }

    func testViewInitialization() {
        XCTAssertEqual(controller.view.backgroundColor, .white, "Background color should be white.")
    }

    func testLabelSetup() {
        // test if the label is set up correctly
        let label = controller.view.subviews.compactMap { $0 as? UILabel }.first
        XCTAssertNotNil(label, "Label should be added to the view.")
        XCTAssertEqual(label?.text, "SCRAPBOOK NAME", "Label text should be 'SCRAPBOOK NAME'.")
        XCTAssertEqual(label?.textAlignment, .center, "Label text alignment should be center.")
        XCTAssertEqual(label?.font.fontName, "Helvetica-Bold", "Label font should be Helvetica-Bold.")
        XCTAssertEqual(label?.font.pointSize, 34, "Label font size should be 34.")
    }

    func testToolbarSetup() {
        // test if the bottom toolbar is set up correctly
        XCTAssertNotNil(controller.bottomToolbar, "Bottom toolbar should be initialized.")
        XCTAssertEqual(controller.bottomToolbar.items?.count, 5, "Toolbar should have 5 items.")
        
        // verify toolbar buttons
        let items = controller.bottomToolbar.items
        XCTAssertEqual(items?[0].image, UIImage(systemName: "arrow.backward"), "First button should be the back button.")
        XCTAssertEqual(items?[2].image, UIImage(systemName: "pencil.tip.crop.circle.badge.plus"), "Third button should be the new button.")
        XCTAssertEqual(items?[4].image, UIImage(systemName: "square.and.arrow.up"), "Last button should be the export button.")
    }

    func testBackButtonAction() {
        let backButton = controller.bottomToolbar.items?.first { $0.image == UIImage(systemName: "arrow.backward") }
        XCTAssertNotNil(backButton, "Back button should exist in the toolbar.")
        XCTAssertNotNil(backButton?.action, "Back button should have an action.")
        
        controller.backButtonTapped()
    }

    func testEditButtonAction() {
        // use the testable class
        let testController = TestableScrapBookView()
        testController.loadViewIfNeeded()
        
        testController.newButtonTapped()
        
        XCTAssertNotNil(testController.capturedPresentedViewController, "Edit button should present a view controller.")
        XCTAssertTrue(testController.capturedPresentedViewController is EditScrapbookViewController, "Presented view controller should be of type EditScrapbookViewController.")
    }

    func testExportButtonAction() {
        // simulate export button tap
        let exportButton = controller.bottomToolbar.items?.first { $0.image == UIImage(systemName: "square.and.arrow.up") }
        XCTAssertNotNil(exportButton, "Export button should exist in the toolbar.")
        XCTAssertNotNil(exportButton?.action, "Export button should have an action.")
        
        controller.exportButtonTapped()
    }
}
