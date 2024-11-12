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
        label.text = "SCRAPBOOK NAME"
        label.textAlignment = .center
        label.font = UIFont(name: "Helvetica-Bold", size: 34)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        setupCanvas(below: label)
        
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
        
        let backButton = UIBarButtonItem(image: UIImage(systemName: "arrow.backward"), style: .plain, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .blue
        
        let newButton = UIBarButtonItem(image: UIImage(systemName: "pencil.tip.crop.circle.badge.plus"), style: .plain, target: self, action: #selector(newButtonTapped))
        newButton.tintColor = .blue

        let exportButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(exportButtonTapped))
        exportButton.tintColor = .blue
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        bottomToolbar.setItems([backButton, flexibleSpace, newButton, flexibleSpace, exportButton], animated: false)
        
    }
    
    @objc func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func newButtonTapped() {
        print("New button tapped")
        // Direct to EditScrapbook page
        let editScrapbookVC = EditScrapbookViewController()
        editScrapbookVC.modalPresentationStyle = .fullScreen
        present(editScrapbookVC, animated: true, completion: nil)
    }

    @objc func exportButtonTapped() {
        print("Export button tapped")
    }
}
