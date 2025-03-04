//
//  FindMatchViewController.swift
//  Goshsha Capstone
//
//  Created by Amber Chang on 2/27/25.
//

import UIKit

class FindMatchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private var selectedProductIndex: IndexPath? // Track selected product
    private var titleLabel: UILabel! // Title label
    private var gridView: UICollectionView! // Collection view for the grid of images
    private var doneButton: UIButton!

    // Sample data for images (replace this with Firebase data later)
    private var productImages: [UIImage] = [UIImage(named: "goshi"), UIImage(named: "goshi"), UIImage(named: "goshi"), UIImage(named: "goshi"), UIImage(named: "goshi"), UIImage(named: "goshi"), UIImage(named: "goshi"), UIImage(named: "goshi")].compactMap { $0 }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Title Label
        titleLabel = UILabel()
        titleLabel.text = "Select the first product"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Constraints for the title label
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // Create a grid view for images
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 300, height: 300) // Customize item size
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

        gridView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        gridView.backgroundColor = .clear
        gridView.translatesAutoresizingMaskIntoConstraints = false
        gridView.delegate = self
        gridView.dataSource = self
        gridView.register(ProductImageCell.self, forCellWithReuseIdentifier: "ProductImageCell")
        view.addSubview(gridView)
        
        // Constraints for the grid view
        NSLayoutConstraint.activate([
            gridView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            gridView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80),
            gridView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gridView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // Done Button
        doneButton = UIButton(type: .system)
        doneButton.backgroundColor = UIColor(white: 0.9, alpha: 1)
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(.black, for: .normal)
        doneButton.layer.cornerRadius = 10
        doneButton.layer.masksToBounds = true
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        view.addSubview(doneButton)
        
        // Constraints for the Done button
        NSLayoutConstraint.activate([
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.heightAnchor.constraint(equalToConstant: 50),
            doneButton.widthAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductImageCell", for: indexPath) as! ProductImageCell
        let image = productImages[indexPath.row]
        cell.configure(with: image, isSelected: selectedProductIndex == indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Toggle selection for the product
        if selectedProductIndex == indexPath {
            selectedProductIndex = nil
        } else {
            selectedProductIndex = indexPath
        }
        
        collectionView.reloadData()
    }
    
    // Done button action
    @objc private func doneButtonTapped() {
        if titleLabel.text == "Select the first product" {
            selectedProductIndex = nil
            titleLabel.text = "Select the second product"
            // After select first item
        } else{
            dismiss(animated: true, completion: nil)
            // Shade match api
        }
    }
}
