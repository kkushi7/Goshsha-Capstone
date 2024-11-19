//
//  ScrapBookViewController.swift
//  Goshsha Capstone
//
//  Created by Athena Yap on 10/23/24.
//

import Foundation
import UIKit
import Firebase
import SwiftUI

class ScrapBookViewController: UIViewController, UITextViewDelegate{
    
    var bottomToolbar: UIToolbar!
    
    // new stuff
    /*
    let journalFont = UIFont.systemFont(ofSize: 14)
    let journalText = "Type Here"
    
    let journalHeight: CGFloat = 100
    
    lazy var JournalView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var JournalTextView: UITextView = {
        let tv = UITextView()
        tv.font = journalFont
        tv.text = journalText
        tv.backgroundColor = .lightGray
        return tv
    }()*/
    
    var textBox: UITextView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //FirebaseApp.configure()
        //print("Configured Firebase")Color("AccentColor")
        
        //Show a label in ScrapBook page
        view.backgroundColor = UIColor(red: CGFloat(255.0/255.0), green: CGFloat(209.0/255.0), blue: CGFloat(220.0/255.0), alpha: CGFloat(1.0))
       
        /*
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
        ])*/

        //set bottom tool bar
        setupBottomToolbar()
        textBoxThing()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textBoxThing() {
        textBox = UITextView()
        textBox.isEditable = true
        textBox.text = "Hello"
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
            bottomToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 15),
            bottomToolbar.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Adding a backbutton to the toolbar
        let backButton = UIBarButtonItem(image: UIImage(systemName: "arrow.backward"), style: .plain, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .blue
        
        // Adding Save Button
        let saveButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.down"), style: .plain, target: self, action: #selector(saveButtonTapped))
        saveButton.tintColor = .blue
        
        let photoButton = UIBarButtonItem(image: UIImage(systemName: "photo.artframe"), style: .plain, target: self, action: #selector(photoButtonTapped))
        saveButton.tintColor = .blue
        
        // Set the buttons on the toolbar
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        bottomToolbar.setItems([backButton,flexibleSpace, saveButton,flexibleSpace, photoButton], animated: false)
        
    }
     
     // Function to handle when the backButton is tapped
     @objc func backButtonTapped() {
         //close current page, back to main page
         dismiss(animated: true, completion: nil)
     }
    //Save functionality, yet to be implemented
     @objc func saveButtonTapped(){
            print("Save")
        }
    // Photo functionality, yet to be implemented
     @objc func photoButtonTapped(){
            print("Photo")
        }
}

#Preview{
    ScrapBookViewController()
}
