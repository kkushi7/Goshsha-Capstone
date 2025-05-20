//
//  TryOnWebViewController.swift
//  Goshsha
//
//  Created by chui peng Yap on 1/9/25.
//  Copyright © 2025 chui peng Yap. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import WebKit

class TryOnWebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    var webView: WKWebView!
    var urlString: String!
    var tryOnButton: UIBarButtonItem?
    var doneButton: UIBarButtonItem!
    var saveButton: UIBarButtonItem!
    var scrapbookButton: UIBarButtonItem!
    var tutorialManager: TutorialManager?
    let saveToScrapbookButton = UIButton(type: .system)
    
    let db = Firestore.firestore();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customize the navigation bar to have a solid white background
        print(self.navigationController == nil ? "No Navigation Controller" : "Navigation Controller exists")
        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.barTintColor = .white // Set the bar's background color
            navigationBar.isTranslucent = false // Make the bar opaque
            navigationBar.backgroundColor = .white // Set the background color
            navigationBar.shadowImage = UIImage() // Remove the shadow line (if needed)
            navigationBar.setBackgroundImage(UIImage(), for: .default) // Ensure no background image is applied
            navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black] // Set the title color
        }
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 170, height: 40))
        
        // Add save button
        saveToScrapbookButton.setTitle("Save to Try-On Room \u{2605}", for: .normal)
        saveToScrapbookButton.addTarget(self, action: #selector(saveToScrapbookTapped), for: .touchUpInside)
        saveToScrapbookButton.frame = CGRect(x: 0, y: 0, width: 170, height: 40)
        
        titleView.addSubview(saveToScrapbookButton)
        self.navigationItem.titleView = titleView
        
        // Add the "Done" button to the navigation bar
        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        // Set the tint color of the done button to black
        doneButton.tintColor = .black
        self.navigationItem.leftBarButtonItem = doneButton
        
        // Create the "Share Try-On" button
        let shareButton = UIButton(type: .system)
        shareButton.setTitle("Try-On", for: .normal)
        shareButton.setImage(UIImage(systemName: "paperplane"), for: .normal) // Use the camera icon
        shareButton.tintColor = .black // Customize the color as needed
        shareButton.sizeToFit() // Adjust size to fit content
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        
        // Adjust insets to add space between the image and title
        shareButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0) // Add space on the right side of the image
        shareButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -60, bottom: 0, right: 5) // Add space on the left side of the title
        
        // Align image and title
        shareButton.semanticContentAttribute = .forceRightToLeft
        shareButton.contentHorizontalAlignment = .right
        
        let shareBarButtonItem = UIBarButtonItem(customView: shareButton)
        self.navigationItem.rightBarButtonItems = [shareBarButtonItem]
        
        // Initialize the web view with custom configuration
        let webConfiguration = WKWebViewConfiguration()
        
        // Inject JavaScript to intercept and override full-screen requests
        let scriptSource = """
        (function() {
            // Override full-screen API
            var noop = function() {};
            document.addEventListener('fullscreenchange', function() {
                if (document.fullscreenElement) {
                    document.exitFullscreen().catch(noop);
                }
            });
            document.addEventListener('webkitfullscreenchange', function() {
                if (document.webkitFullscreenElement) {
                    document.webkitExitFullscreen().catch(noop);
                }
            });
            var overrideFullscreen = function() {
                Element.prototype.requestFullscreen = noop;
                Element.prototype.webkitRequestFullscreen = noop;
                Element.prototype.mozRequestFullScreen = noop;
                Element.prototype.msRequestFullscreen = noop;
            };
            document.addEventListener('DOMContentLoaded', overrideFullscreen);
            overrideFullscreen();
        })();
        """
        let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        webConfiguration.userContentController.addUserScript(script)
        
        // Configure the web view to align more with standard mobile browser behavior
        webConfiguration.allowsInlineMediaPlayback = true
        webConfiguration.mediaTypesRequiringUserActionForPlayback = []
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.uiDelegate = self // Set the UI delegate to handle window creation
        view.addSubview(webView)
        
        // Set up constraints for the web view
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // Load the URL
        if let url = URL(string: "https://goshha.com") {
            webView.load(URLRequest(url: url))
        }
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let uid = Auth.auth().currentUser?.uid else {
            print("No logged-in user.")
            return
        }

        let tutorialKey = "hasSeenTryonTutorial_\(uid)"

        if !UserDefaults.standard.bool(forKey: tutorialKey) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let steps = [
                    TutorialStep(
                        title: "Save to Try-On Room",
                        description: "Save screenshots of try-ons and products to the Try-on room.",
                        targetView: self.saveToScrapbookButton
                    )
                ]
                self.tutorialManager = TutorialManager(steps: steps, tutorialKey: tutorialKey)
                self.tutorialManager?.start(in: self.view)
            }
        }
    }
    
    @objc func openScrapbookEditPage() {
        let scrapbookEditVC = NewScrapbook()
        scrapbookEditVC.modalPresentationStyle = .fullScreen
        present(scrapbookEditVC, animated: true, completion: nil)
    }
    
    private func fetchScrapbookCounts(completion: @escaping (Int, Int) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(0, 0)
            return
        }

        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching scrapbook counts: \(error.localizedDescription)")
                completion(0, 0)
                return
            }

            guard let data = snapshot?.data()?["scrapbooks"] as? [String: Any] else {
                completion(0, 0)
                return
            }

            let photos = data["photos"] as? [[String: Any]] ?? []
            let stickers = data["stickers"] as? [[String: Any]] ?? []
            completion(photos.count, stickers.count)
        }
    }
    
    @objc func saveToScrapbookTapped() {
        print("URL: \(webView.url?.absoluteString ?? "No URL loaded")")
        guard let screenshot = captureScreenshot() else {
            print("Failed to capture screenshot")
            return
        }

        uploadPhoto(image: screenshot) { [weak self] url in
            guard let self = self, let downloadURL = url else { return }

            self.fetchScrapbookCounts { photoCount, stickerCount in
                let zIndex = photoCount + stickerCount

                let centerX = screenshot.size.width / 2
                let centerY = screenshot.size.height / 2

                let photoData: [String: Any] = [
                    "id": UUID().uuidString,
                    "url": downloadURL.absoluteString,
                    "x": centerX,
                    "y": centerY,
                    "scaleX": 1,
                    "scaleY": 1,
                    "rotation": 0,
                    "zIndex": zIndex,
                    "frame": false
                ]

                self.saveToScrapbook(photoData: photoData) {
                    self.showSavedAlert()
                }
            }
        }
    }
    
    private func showSavedAlert() {
        let alert = UIAlertController(title: "Saved", message: "Image has been added to your scrapbook.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.openScrapbookEditPage()
        })
        present(alert, animated: true, completion: nil)
    }

    @objc func tryOnButtonTapped() {
        
        // Load the URL
        if let url = URL(string: "https://goshha.com") {
            webView.load(URLRequest(url: url))
        }
        // Remove the "Try On" button when tapped
        self.navigationItem.leftBarButtonItem = doneButton
        tryOnButton = nil
        
    }
    
    @objc func shareButtonTapped() {
        // Take a snapshot of the current web view content
        let config = WKSnapshotConfiguration()
        webView.takeSnapshot(with: config) { [weak self] image, error in
            guard let self = self, let snapshot = image, error == nil else {
                print("Snapshot error: \(String(describing: error))")
                return
            }
            
            // Text to accompany the snapshot with a visible reference to "Goshsha App"
            let textToShare = """
            Virtual try-on with Goshsha. Apple App Store: [Goshsha App](https://apps.apple.com/us/app/goshsha/id1521800052).
            """
            
            // Create the activity view controller with the image and text
            let activityViewController = UIActivityViewController(activityItems: [snapshot, textToShare], applicationActivities: nil)
            
            // Exclude certain activity types if needed
            activityViewController.excludedActivityTypes = [.addToReadingList, .assignToContact, .print]
            
            // Present the activity view controller
            if let popoverController = activityViewController.popoverPresentationController {
                popoverController.barButtonItem = self.navigationItem.rightBarButtonItem
            }
            
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    @objc func doneButtonTapped() {
        // Dismiss the web view controller and go back to the previous screen
        NotificationCenter.default.post(name: Notification.Name("ReloadScrapbookData"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    // Hide or show doneButton based on tryOnButton presence
    private func updateLeftButton(title: String, action: Selector) {
        let backButton = UIBarButtonItem(title: title, style: .plain, target: self, action: action)
        backButton.tintColor = .black
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    // Handle navigation actions to manage the "Try On" button visibility
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let requestURL = navigationAction.request.url
        
        // Show "Try On" button when user taps a link
        if navigationAction.navigationType == .linkActivated {
            if tryOnButton == nil {
                updateLeftButton(title: "Back", action: #selector(backButtonTapped))
            }
        }
        
        decisionHandler(.allow)
    }
    
    @objc func backButtonTapped() {
        if webView.canGoBack {
            webView.goBack()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // capture screenshot
    func captureScreenshot() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: self.view.bounds.size)
        return renderer.image { _ in
            self.view.drawHierarchy(in: self.view.bounds, afterScreenUpdates: true)
        }
    }
    
    // save screenshot to Firebase
    func saveToScrapbook(photoData: [String: Any], completion: @escaping () -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }

        let userRef = db.collection("users").document(uid)

        userRef.updateData([
            "scrapbooks.photos": FieldValue.arrayUnion([photoData])
        ]) { error in
            if let error = error {
                print("Error saving photo to scrapbook: \(error.localizedDescription)")
            } else {
                print("Photo successfully added to scrapbook!")
                completion()
            }
        }
    }
    
    // upload to Firebase storage
    func uploadPhoto(image: UIImage, completion: @escaping (URL?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to data")
            completion(nil)
            return
        }
        
        let storageRef = Storage.storage().reference()
        let photoRef = storageRef.child("scrapbook_photos/\(uid)/\(UUID().uuidString).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        photoRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                print("Error uploading photo: \(error.localizedDescription)")
                completion(nil)
            } else {
                photoRef.downloadURL { url, error in
                    if let error = error {
                        print("Error fetching download URL: \(error.localizedDescription)")
                        completion(nil)
                    } else {
                        completion(url)
                    }
                }
            }
        }
    }
}
