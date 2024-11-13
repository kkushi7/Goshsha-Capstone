//
//  EditScrapbookViewController.swift
//  Goshsha Capstone
//
//  Created by Dingxin Tao on 11/12/24.
//

import UIKit

class EditScrapbookViewController: UIViewController {
    
    var topToolbar: UIToolbar!
    var canvasView: UIView!
    var bottomToolbar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        //show user's ScrapBook name
        showScrapBookNameLabel()
        
        //set top tool bar
        setupTopToolbar()
        
        //set Scarpbook canvas
        canvasView  = setupCanvas(below: topToolbar)
        
        //set bottom tool bar
        setupBottomToolbar()
    }
    
    func showScrapBookNameLabel() {
        let label = UILabel()
        label.text = "Your SCRAPBOOK"
        label.textAlignment = .center
        label.font = UIFont(name: "Helvetica-Bold", size: 34)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    // this will be replaced by UIkit api tools
    func setupTopToolbar() {
            topToolbar = UIToolbar()
            topToolbar.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(topToolbar)
            
            NSLayoutConstraint.activate([
                topToolbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
                topToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                topToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                topToolbar.heightAnchor.constraint(equalToConstant: 40)
            ])
            
            // "Text" button
            let textButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(addText))
            textButton.tintColor = .blue
            
            // "Photo" button
            let photoButton = UIBarButtonItem(image: UIImage(systemName: "photo.on.rectangle.angled"), style: .plain, target: self, action: #selector(addPhoto))
            photoButton.tintColor = .blue
            
            // "Sticker" button
            let stickerButton = UIBarButtonItem(image: UIImage(systemName: "face.smiling"), style: .plain, target: self, action: #selector(addSticker))
            stickerButton.tintColor = .blue
            
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            topToolbar.setItems([textButton, flexibleSpace, photoButton, flexibleSpace, stickerButton], animated: false)
    }
    
    func setupBottomToolbar() {
            bottomToolbar = UIToolbar()
            bottomToolbar.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(bottomToolbar)
            
            NSLayoutConstraint.activate([
                bottomToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                bottomToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                bottomToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
                bottomToolbar.heightAnchor.constraint(equalToConstant: 40)
            ])
            
            let backButton = UIBarButtonItem(image: UIImage(systemName: "arrow.backward"), style: .plain, target: self, action: #selector(backButtonTapped))
            backButton.tintColor = .blue
            
            let saveButton = UIBarButtonItem(image: UIImage(systemName: "lock"), style: .plain, target: self, action: #selector(saveButtonTapped))
            saveButton.tintColor = .blue
            
            let exportButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(exportButtonTapped))
            exportButton.tintColor = .blue
            
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            bottomToolbar.setItems([backButton, flexibleSpace, saveButton, flexibleSpace, exportButton], animated: false)
        }
        
    @objc func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func saveButtonTapped() {
        print("Save button tapped")
    }
    
    @objc func exportButtonTapped() {
        print("Export button tapped")
    }

    @objc func addText() {
        let textbox = UITextField(frame : CGRect(x: 50, y: 50, width: 150, height: 40))
        textbox.placeholder = "Enter text..."
        textbox.borderStyle = .roundedRect
        textbox.keyboardType = .default
        
        // Add element to view as a subview
        view.addSubview(textbox)
    }
        
    @objc func addPhoto() {
        print("Add Photo tapped")
    }
    
    @objc func addSticker() {
        print("Add Sticker tapped")
    }
}
