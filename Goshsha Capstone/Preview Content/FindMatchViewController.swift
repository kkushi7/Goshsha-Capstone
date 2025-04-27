//
//  FindMatchViewController.swift
//  Goshsha Capstone
//
//  Created by Amber Chang on 2/27/25.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

class FindMatchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private var selectedProductIndex: IndexPath? // Track selected product
    private var titleLabel: UILabel! // Title label
    private var gridView: UICollectionView! // Collection view for the grid of images
    private var doneButton: UIButton!
    private var firstSelectedImage: UIImage?
    private var secondSelectedImage: UIImage?

    private var productImages: [UIImage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadImagesFromFirebase()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Title Label
        titleLabel = UILabel()
        titleLabel.text = "Select the first image"
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
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        let spacing: CGFloat = 10
        let itemsPerRow: CGFloat = 2
        let totalSpacing = (itemsPerRow + 1) * spacing
        let itemWidth = (view.bounds.width - totalSpacing) / itemsPerRow

        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)

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
        doneButton.isEnabled = false
        doneButton.alpha = 0.5
        view.addSubview(doneButton)
        
        // Constraints for the Done button
        NSLayoutConstraint.activate([
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.heightAnchor.constraint(equalToConstant: 50),
            doneButton.widthAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    private func loadImagesFromFirebase() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not logged in.")
            return
        }
        
        let storageRef = Storage.storage().reference().child("scrapbook_photos/\(uid)")
        
        storageRef.listAll { (result, error) in
            if let error = error {
                print("Error listing files: \(error.localizedDescription)")
                return
            }
            
            guard let items = result?.items else {
                print("No images found.")
                return
            }
            
            let dispatchGroup = DispatchGroup()
            var loadedImages: [UIImage] = []
            
            for item in items {
                dispatchGroup.enter()
                item.getData(maxSize: 5 * 1024 * 1024) { data, error in
                    if let data = data, let image = UIImage(data: data) {
                        loadedImages.append(image)
                    } else {
                        print("Failed to load image from \(item.fullPath)")
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self.productImages = loadedImages
                self.gridView.reloadData()
                print("Loaded \(loadedImages.count) images from Firebase!")
            }
        }
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
        if selectedProductIndex == indexPath {
            selectedProductIndex = nil
        } else {
            selectedProductIndex = indexPath
        }
        
        // Done button enabled ONLY if something is selected
        doneButton.isEnabled = selectedProductIndex != nil
        doneButton.alpha = selectedProductIndex != nil ? 1.0 : 0.5

        collectionView.reloadData()
    }
    
    // Done button action
    @objc private func doneButtonTapped() {
        guard let selectedIndex = selectedProductIndex else {
            print("No image selected.")
            return
        }

        if titleLabel.text == "Select the first image" {
            // Save the first selected image
            firstSelectedImage = productImages[selectedIndex.item]

            // Remove it from productImages
            productImages.remove(at: selectedIndex.item)

            // Update title to select second
            titleLabel.text = "Select the second image"

            // Reset selected index
            selectedProductIndex = nil
            doneButton.isEnabled = false
            doneButton.alpha = 0.5

            // Reload grid
            gridView.reloadData()
            
        } else if titleLabel.text == "Select the second image" {
            // Save the second selected image
            secondSelectedImage = productImages[selectedIndex.item]
            dismiss(animated: true, completion: nil)
        }
    }
}
