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
        
        //Show a label in ScrapBook page
        view.backgroundColor = .white
                
        let label = UILabel()
        label.text = "ScrapBook"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24)
        label.textColor = .black
        
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        //set bottom tool bar
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
            bottomToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            bottomToolbar.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Create a favorite button (favButton) to add to the toolbar
        let backButton = UIBarButtonItem(image: UIImage(systemName: "arrow.backward"), style: .plain, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .blue
        
        // Set the buttons on the toolbar
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        bottomToolbar.setItems([flexibleSpace, backButton], animated: false)
        
    }
     
     // Function to handle when the backButton is tapped
     @objc func backButtonTapped() {
         //close current page, back to main page
         dismiss(animated: true, completion: nil)
     }
}
