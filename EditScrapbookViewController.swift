//
//  EditScrapbookViewController.swift
//  Goshsha Capstone
//
//  Created by Dingxin Tao on 11/12/24.
//

import UIKit

class EditScrapbookViewController: UIViewController {
    
    var bottomToolbar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let label = UILabel()
        label.text = "EDIT SCRAPBOOK"
        label.textAlignment = .center
        label.font = UIFont(name: "Helvetica-Bold", size: 34)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        let topToolbar = setupTopToolbar()
        view.addSubview(topToolbar)
        
        NSLayoutConstraint.activate([
            topToolbar.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
            topToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            topToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        //set Scarpbook canvas
        setupCanvas(below: topToolbar)
        
        //set bottom tool bar
        setupBottomToolbar()
    }
    
    func setupTopToolbar() -> UIStackView {
            let topToolbar = UIStackView()
            topToolbar.axis = .horizontal
            topToolbar.alignment = .fill
            topToolbar.distribution = .equalSpacing
            topToolbar.translatesAutoresizingMaskIntoConstraints = false
            
            // "Text" button
            let textButton = UIButton(type: .system)
            textButton.setTitle("Text", for: .normal)
            textButton.addTarget(self, action: #selector(addText), for: .touchUpInside)
            
            // Create "Photo" button
            let photoButton = UIButton(type: .system)
            photoButton.setTitle("Photo", for: .normal)
            photoButton.addTarget(self, action: #selector(addPhoto), for: .touchUpInside)
            
            // Create "Sticker" button
            let stickerButton = UIButton(type: .system)
            stickerButton.setTitle("Sticker", for: .normal)
            stickerButton.addTarget(self, action: #selector(addSticker), for: .touchUpInside)
            
            // Add buttons to the topToolbar
            topToolbar.addArrangedSubview(textButton)
            topToolbar.addArrangedSubview(photoButton)
            topToolbar.addArrangedSubview(stickerButton)
            
            return topToolbar
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
            
            let saveButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.down"), style: .plain, target: self, action: #selector(saveButtonTapped))
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
                print("Add Text tapped")
            }
            
        @objc func addPhoto() {
            print("Add Photo tapped")
        }
        
        @objc func addSticker() {
            print("Add Sticker tapped")
        }
}
