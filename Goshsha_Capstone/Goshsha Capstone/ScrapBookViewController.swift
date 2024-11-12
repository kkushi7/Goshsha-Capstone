//
//  ScrapBookViewController.swift
//  Goshsha Capstone
//
//  Created by Athena Yap on 10/23/24.
//

import Foundation
import UIKit
import Firebase

class ScrapBookViewController: UIViewController {
    
    var bottomToolbar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //FirebaseApp.configure()
        //print("Configured Firebase")
        
        // Main view background color
        view.backgroundColor = UIColor(red: 0.167, green: 0.216, blue: 0.6, alpha: 0.6)
        view.clipsToBounds = true
        
        
        
        // Scrapbook page
        /*let scrapbookView = UIView(frame: CGRect(x: 25, y: 70, width:350, height: 700))
        scrapbookView.backgroundColor = UIColor(red: 0.167, green: 0.216, blue: 0.6, alpha: 0.6)
        scrapbookView.clipsToBounds = true
        view.addSubview(scrapbookView)
        
        NSLayoutConstraint.activate([
            scrapbookView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrapbookView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])*/
        
        
        // Set bottom tool bar
        setupBottomToolbar()
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
            bottomToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 10),
            bottomToolbar.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Create a back button (backButton) to add to the toolbar
        let backButton = UIBarButtonItem(image: UIImage(systemName: "arrow.backward"), style: .plain, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .blue
        
        // Create a edit button (editButton) to add to the toolbar
        let editButton = UIBarButtonItem(image: UIImage(systemName: "pencil"), style: .plain, target: self, action: #selector(editButtonTapped))
        editButton.tintColor = .blue
        
        // Create a edit button (shareButton) to add to the toolbar
        let shareButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareButtonTapped))
        shareButton.tintColor = .blue
        
        // Set the buttons on the toolbar
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        bottomToolbar.setItems([backButton, flexibleSpace, editButton, flexibleSpace, shareButton], animated: false)
    }

    
    // Set up the editing toolbar
    func setupEditToolbar() {
        // Create the toolbar
        bottomToolbar = UIToolbar()
        bottomToolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomToolbar)
        
        // Set constraints to position the toolbar slightly above the bottom of the view
        NSLayoutConstraint.activate([
            bottomToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 10),
            bottomToolbar.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        let textboxButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(textboxButtonTapped))
        textboxButton.tintColor = .blue
        
        let imageButton = UIBarButtonItem(image: UIImage(systemName: "photo.on.rectangle.angled"), style: .plain, target: self, action: #selector(imageButtonTapped))
        imageButton.tintColor = .blue
        
        let stickerButton = UIBarButtonItem(image: UIImage(systemName: "face.smiling"), style: .plain, target: self, action: #selector(stickerButtonTapped))
        stickerButton.tintColor = .blue
        
        let saveButton = UIBarButtonItem(image: UIImage(systemName: "lock"), style: .plain, target: self, action: #selector(saveButtonTapped))
        saveButton.tintColor = .blue
        
        // Set the buttons on the toolbar
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        bottomToolbar.setItems([textboxButton, flexibleSpace, imageButton, flexibleSpace, stickerButton, flexibleSpace, saveButton], animated: false)
    }

    
    

     // Function to handle when the backButton is tapped
     @objc func backButtonTapped() {
         //close current page, back to main page
         dismiss(animated: true, completion: nil)
    }
    
    // Function to handle when the editButton is tapped
    @objc func editButtonTapped() {
        // Update bottom toolbar to add scrapbook buttons
        setupEditToolbar()
    }
    
    // Function to handle when the shareButton is tapped
    @objc func shareButtonTapped() {
        // Update bottom toolbar to add scrapbook buttons
        setupEditToolbar()
    }
    
    // Function to handle when the textboxButton is tapped
    @objc func textboxButtonTapped() {
        // Create textbox
        let textbox = UITextField(frame : CGRect(x: 50, y: 50, width: 150, height: 40))
        textbox.placeholder = "Enter text..."
        textbox.borderStyle = .roundedRect
        textbox.keyboardType = .default
        
        // Add element to view as a subview
        view.addSubview(textbox)
    }
    
    // Function to handle when the imageButton is tapped
    @objc func imageButtonTapped() {
        // Open user's gallery
    }
    
    // Function to handle when the stickerButton is tapped
    @objc func stickerButtonTapped() {
        // Open sticker menu
    }
    
    // Function to handle when the saveButton is tapped
    @objc func saveButtonTapped() {
        // Save current scrapbook
        
        //set bottom tool bar
        setupBottomToolbar()
    }
}

#Preview {
    ScrapBookViewController()
}
