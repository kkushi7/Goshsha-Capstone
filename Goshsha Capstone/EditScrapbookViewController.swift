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
        label.text = "Edit Scrapbook"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
        
        //set Scarpbook canvas
        setupCanvas()
        
        //set bottom tool bar
        setupBottomToolbar()
    }
    
    func setupCanvas() {
        let canvasView = UIImageView()
        canvasView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        canvasView.layer.borderWidth = 1
        canvasView.layer.borderColor = UIColor.lightGray.cgColor
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(canvasView)
        
        NSLayoutConstraint.activate([
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            canvasView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            canvasView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80)
        ])
        
        // Implement Edit functions here
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
}
