//
//  ViewController.swift
//  Goshsha Capstone
//
//  Created by Athena Yap on 10/23/24.
//

import UIKit
//import FirebaseUI
import Photos
//import FirebaseFirestore
//import Firebase
//import FirebaseStorage
import MobileCoreServices
import ReplayKit
import SafariServices




// Extension for ReplayKit Screen recording delegate
extension ViewController: RPPreviewViewControllerDelegate {
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        dismiss(animated: true, completion: nil)
    }
}


class ViewController: UIViewController {
    
//    let db = Firestore.firestore()
    
    var bottomToolbar: UIToolbar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the bottom toolbar
        setupBottomToolbar()
        

    }

    override public func viewDidAppear(_ animated: Bool) {
    
        
    }
    
    // Set up the bottom toolbar
    func setupBottomToolbar() {
        // Create the toolbar
        bottomToolbar = UIToolbar()
        bottomToolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomToolbar)
        
        // Set constraints to position the toolbar slightly above the bottom of the view
        NSLayoutConstraint.activate([
            bottomToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10), // Move it 20 points higher
            bottomToolbar.heightAnchor.constraint(equalToConstant: 40) // Adjust toolbar height
        ])
        
        // Create a favorite button (favButton) to add to the toolbar
        let scrapBookButton = UIBarButtonItem(image: UIImage(systemName: "book"), style: .plain, target: self, action: #selector(scrapBookButtonTapped))
        scrapBookButton.tintColor = .red
        
        // Create a login/logout button with an icon
        let loginLogoutButton = UIBarButtonItem(image: UIImage(systemName: "door.right.hand.open"), style: .plain, target: self, action: #selector(loginLogoutTapped))
        loginLogoutButton.tintColor = .blue
        
        // Check if the user is logged in or not and update the icon accordingly
//        if Auth.auth().currentUser != nil {
//            // User is logged in, set to logout icon
//            loginLogoutButton.image = UIImage(systemName: "door.left.hand.open")
//        } else {
//            // User is not logged in, set to login icon
//            loginLogoutButton.image = UIImage(systemName: "door.right.hand.open")
//        }
        
        // Set the buttons on the toolbar
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        bottomToolbar.setItems([scrapBookButton, flexibleSpace, loginLogoutButton], animated: false)
        
    }
     
     // Function to handle when the favButton is tapped
     @objc func scrapBookButtonTapped() {
//         if Auth.auth().currentUser == nil {
//             // User is not logged in, segue to LoginController
//             TFtriggers.signInFromVC = true // so that the right webview is loaded
//             segueToLoginController()
//         }
        
        segueToScrapBookVC()
        
     }
    
    
    func segueToScrapBookVC() {
        let storyboard = UIStoryboard(name: "ScrapBook", bundle: nil)
             if let scrapBookController = storyboard.instantiateViewController(withIdentifier: "ScrapBookController") as? ScrapBookViewController {
                 scrapBookController.modalPresentationStyle = .fullScreen // Optional: set presentation style
                 present(scrapBookController, animated: true, completion: nil)
             }
    }
    
    // Function to login & logout
    @objc func loginLogoutTapped() {
        // Check if the user is logged in or not
//        if Auth.auth().currentUser != nil {
//            // User is logged in, log them out
//            do {
//                try Auth.auth().signOut()
//                TFtriggers.signInFromFavHis = false
//                TFtriggers.signInFromVC = false
//                // Update the button icon to login icon
//                if let toolbarItems = bottomToolbar.items {
//                    if let loginLogoutButton = toolbarItems.last {
//                        loginLogoutButton.image = UIImage(systemName: "door.right.hand.open")
//                    }
//                }
//            } catch let signOutError as NSError {
//                print("Error signing out: %@", signOutError)
//            }
//        } else {
            // User is not logged in, present the login view
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            if let loginController = storyboard.instantiateViewController(withIdentifier: "LoginController") as? LoginController {
//                loginController.modalPresentationStyle = .fullScreen
//                present(loginController, animated: true, completion: nil)
//            }
//            // After login, update the button icon to logout
//            if let toolbarItems = bottomToolbar.items {
//                if let loginLogoutButton = toolbarItems.last {
//                    loginLogoutButton.image = UIImage(systemName: "door.left.hand.open")
//                }
//            }
//        }
    }



    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
}


    

        



