//
//  NewScrapbook.swift
//  Goshsha Capstone
//
//  Created by Amber Chang on 2/26/25.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class NewScrapbook: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var isAddingToPanel = false
    var isDeleteModeActive = false
    var contentPanel: UIView!
    var stickerPanel: UIScrollView!
    private var eyedropperTargetImageView: UIImageView?
    private var colorPreview: UIView!
    private var colorInfoLabel: UILabel!
    let db = Firestore.firestore();

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadStickers()
        loadPhotos()
        loadBackground()
        setupColorPreviewBubble()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .clear
        
        // Title Container View
        let titleContainer = UIView()
        titleContainer.backgroundColor = .black
        titleContainer.translatesAutoresizingMaskIntoConstraints = false
        titleContainer.layer.cornerRadius = 10
        titleContainer.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        titleContainer.clipsToBounds = true
        view.addSubview(titleContainer)
        
        // Return Button
        let returnButton = setupButton(imageName: "return", action: #selector(returnButtonPressed))
        titleContainer.addSubview(returnButton)

        // Title Label
        let titleLabel = createTitleLabel()
        titleContainer.addSubview(titleLabel)

        // Save Button
        let saveButton = setupButton(imageName: "save", action: #selector(saveScrapbook))
        titleContainer.addSubview(saveButton)

        // Content Panel
        contentPanel = createContentPanel()
        view.addSubview(contentPanel)

        // Chat Button
        let chatButton = setupButton(imageName: "goshi", action: #selector(chatTapped))
        contentPanel.addSubview(chatButton)

        // Toolbar
        let toolbar = createToolbar()
        view.addSubview(toolbar)
        
        view.bringSubviewToFront(titleContainer)

        // Constraints
        setupConstraints(titleContainer: titleContainer, returnButton: returnButton, titleLabel: titleLabel, saveButton: saveButton, chatButton: chatButton, toolbar: toolbar)
    }

    private func createTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = "Your Scrapbook"
        titleLabel.textColor = .white
        titleLabel.backgroundColor = .black
        titleLabel.font = UIFont(name: "Poppins-Bold", size: 28)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }

    private func createContentPanel() -> UIView {
        let panel = GradientView()
        panel.translatesAutoresizingMaskIntoConstraints = false
        panel.layer.shadowColor = UIColor.black.cgColor
        panel.layer.shadowOpacity = 0.1
        panel.layer.shadowOffset = CGSize(width: 0, height: 2)
//        panel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openColorPicker)))
        panel.isUserInteractionEnabled = true
        return panel
    }

    private func setupButton(imageName: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    private func createToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.tintColor = .white
        toolbar.barTintColor = .black
        toolbar.layer.cornerRadius = 10
        toolbar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        toolbar.clipsToBounds = true
        
        toolbar.items = [
            createToolbarButton(#selector(stickerButton), "sticker"),
            .flexibleSpace(),
            createToolbarButton(#selector(openColorPicker), "bg"),
            .flexibleSpace(),
            createToolbarButton(#selector(cameraTapped), "pics"),
            .flexibleSpace(),
            createToolbarButton(#selector(frameTapped), "border"),
            .flexibleSpace(),
            createToolbarButton(#selector(toggleDeleteMode), "erase")
        ]
        
        return toolbar
    }

    private func createToolbarButton(_ action: Selector, _ imageName: String) -> UIBarButtonItem {
        let image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
        let button = UIBarButtonItem(image: image, style: .plain, target: self, action: action)
        return button
    }

    private func setupConstraints(titleContainer: UIView, returnButton: UIButton, titleLabel: UILabel, saveButton: UIButton, chatButton: UIButton, toolbar: UIToolbar) {
        NSLayoutConstraint.activate([
            titleContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -20),
            titleContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleContainer.heightAnchor.constraint(equalToConstant: 80),

            // Title Label
            titleLabel.centerXAnchor.constraint(equalTo: titleContainer.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: titleContainer.centerYAnchor),
            
            // Return Button (Modified constraints)
            returnButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            returnButton.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor, constant: 20),
            returnButton.widthAnchor.constraint(equalToConstant: 40),
            returnButton.heightAnchor.constraint(equalToConstant: 40),

            // Save Button
            saveButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            saveButton.trailingAnchor.constraint(equalTo: titleContainer.trailingAnchor, constant: -20),
            saveButton.widthAnchor.constraint(equalToConstant: 40),
            saveButton.heightAnchor.constraint(equalToConstant: 40),

            // Content Panel
            contentPanel.topAnchor.constraint(equalTo: titleContainer.bottomAnchor, constant: -20),
            contentPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            contentPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            contentPanel.bottomAnchor.constraint(equalTo: toolbar.topAnchor, constant: 20),

            // Toolbar
            toolbar.heightAnchor.constraint(equalToConstant: 80),
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            // Chat Button
            chatButton.trailingAnchor.constraint(equalTo: contentPanel.trailingAnchor, constant: 0),
            chatButton.bottomAnchor.constraint(equalTo: contentPanel.bottomAnchor, constant: -10),
            chatButton.widthAnchor.constraint(equalToConstant: 150),
            chatButton.heightAnchor.constraint(equalToConstant: 150)
        ])
    }

    // MARK: - Image Handling
    private func presentImagePicker(isForPanel: Bool) {
        isAddingToPanel = isForPanel
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    @objc private func saveScrapbook() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let panel = contentPanel else { print("Error: No panel"); return }

        clearExistingData(uid: uid) {
            var photos: [[String: Any]] = []
            var stickers: [[String: Any]] = []
            let dispatchGroup = DispatchGroup()

            // Process all images and stickers
            for subview in panel.subviews where !(subview is UIButton) {
                if let container = subview as? UIView,
                   let imageView = container.subviews.first(where: { $0 is UIImageView }) as? UIImageView {

                    var itemData: [String: Any] = [
                        "id": UUID().uuidString,
                        "scaleX": container.transform.a,
                        "scaleY": container.transform.d,
                        "rotation": atan2(container.transform.b, container.transform.a)
                    ]

                    if let imageUrl = imageView.accessibilityIdentifier {
                        // It's a sticker (URL already exists)
                        itemData["url"] = imageUrl
                        itemData["x"] = container.frame.origin.x;
                        itemData["y"] = container.frame.origin.y
                        stickers.append(itemData)
                    } else if let image = imageView.image {
                        // It's an image that needs to be uploaded
                        dispatchGroup.enter()
                        self.uploadPhoto(image: image) { url in
                            if let url = url {
                                itemData["url"] = url.absoluteString
                                itemData["x"] = container.center.x;
                                itemData["y"] = container.center.y
                                photos.append(itemData)
                            }
                            dispatchGroup.leave()
                        }
                    }
                }
            }

            // Save background, photos, and stickers
            dispatchGroup.notify(queue: .main) {
                self.getBackgroundInfo { background in
                    let scrapbookData: [String: Any] = [
                        "photos": photos,
                        "stickers": stickers,
                        "background": background
                    ]
                    print(scrapbookData)
                    let userDoc = self.db.collection("users").document(uid)
                    userDoc.setData(["scrapbooks": scrapbookData], merge: true) { error in
                        if let error = error {
                            print("Error saving scrapbook: \(error.localizedDescription)")
                        } else {
                            print("Scrapbook saved successfully!")
                        }
                    }
                }
            }
        }
    }
    
    private func getBackgroundInfo(completion: @escaping ([String: Any]) -> Void) {
        guard let panel = contentPanel else {
            completion([:])
            return
        }

        // Check for background color
        if let bgColor = panel.backgroundColor {
            let hexColor = bgColor.toHexString()
            completion(["type": "color", "value": hexColor])
            return
        }

        // Check for gradient
        if let gradientLayer = panel.layer.sublayers?.first(where: { $0 is CAGradientLayer }) as? CAGradientLayer,
           let colors = gradientLayer.colors as? [CGColor] {
            
            let hexColors = colors.map { UIColor(cgColor: $0).toHexString() }
            completion(["type": "gradient", "colors": hexColors])
            return
        }

        // Check for background image
        if let bgImageView = panel.subviews.first(where: { $0 is UIImageView }) as? UIImageView,
           let bgImage = bgImageView.image {
            
            if let existingURL = bgImageView.accessibilityIdentifier {
                // Image already has a URL
                completion(["type": "image", "url": existingURL])
            } else {
                // No URL? Upload the image and get the URL
                uploadPhoto(image: bgImage) { url in
                    completion(["type": "image", "url": url?.absoluteString ?? ""])
                }
            }
        } else {
            // No valid background found
            completion(["type": "none"])
        }
    }
    
    private func uploadPhoto(image: UIImage, completion: @escaping (URL?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        let filename = "\(UUID().uuidString).jpg"
        let path = "scrapbook_photos/\(uid)/\(filename)"
        let storageRef = Storage.storage().reference().child(path)

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        storageRef.putData(imageData, metadata: metadata) { _, error in
            if let error = error {
                print("Error uploading photo: \(error.localizedDescription)")
                completion(nil)
                return
            }

            storageRef.downloadURL { url, error in
                if let url = url {
                    completion(url)
                } else {
                    print("Error getting download URL: \(error?.localizedDescription ?? "Unknown error")")
                    completion(nil)
                }
            }
        }
    }
    
    private func clearExistingData(uid: String, completion: @escaping () -> Void) {
        let userDoc = db.collection("users").document(uid)
        let folderRef = Storage.storage().reference().child("scrapbook_photos/\(uid)")

        let dispatchGroup = DispatchGroup()

        // Delete all files in storage
        dispatchGroup.enter()
        folderRef.listAll { result, error in
            if let error = error {
                print("Error listing files: \(error.localizedDescription)")
                dispatchGroup.leave()
                return
            }

            guard let items = result?.items, !items.isEmpty else {
                print("No items found in folder. Skipping deletion.")
                dispatchGroup.leave()
                return
            }

            for item in items {
                dispatchGroup.enter()
                item.delete { error in
                    if let error = error {
                        print("Error deleting file: \(error.localizedDescription)")
                    } else {
                        print("Deleted file: \(item.fullPath)")
                    }
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.leave()
        }

        // Clear Firestore "scrapbooks" field
        dispatchGroup.enter()
        userDoc.updateData(["scrapbooks": FieldValue.delete()]) { error in
            if let error = error {
                print("Error deleting Firestore data: \(error.localizedDescription)")
            } else {
                print("Firestore scrapbook data deleted")
            }
            dispatchGroup.leave()
        }

        // Ensure all deletions are complete before continuing
        dispatchGroup.notify(queue: .main) {
            print("All previous data cleared. Ready to save new scrapbook!")
            completion()
        }
    }
    
    @objc func returnButtonPressed() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func selectImageFromLibrary() {
        presentImagePicker(isForPanel: false)
    }

    @objc private func cameraTapped() {
        presentImagePicker(isForPanel: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            isAddingToPanel ? addImageToContentPanel(image: selectedImage) : setBackgroundImage(image: selectedImage)
        }
        picker.dismiss(animated: true)
    }

    private func addImageToContentPanel(image: UIImage, x: CGFloat? = nil, y: CGFloat? = nil, scaleX: CGFloat = 1.0, scaleY: CGFloat = 1.0, rotation: CGFloat = 0.0) {
        guard let panel = contentPanel else { return }
        let container = UIView()
        container.isUserInteractionEnabled = true

        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.sizeToFit()

        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true

        // Scale down imageView to 50% of panel size
        let scaleFactor = min((panel.bounds.width * 0.5) / imageView.bounds.width,
                                (panel.bounds.height * 0.5) / imageView.bounds.height)

        imageView.frame = CGRect(x: 0, y: 0,
                                width: imageView.bounds.width * scaleFactor,
                                height: imageView.bounds.height * scaleFactor)

        // Set container's frame to match imageView
        container.frame = imageView.frame

        // Apply scaling and rotation
        container.transform = CGAffineTransform(scaleX: scaleX, y: scaleY).rotated(by: rotation)

        // Add subviews
        container.addSubview(imageView)
        panel.addSubview(container)

        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handleImagePinch(_:)))
        container.addGestureRecognizer(pinchGesture)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(showBubbleOnImage(_:)))
        imageView.addGestureRecognizer(longPress)

        // Delete button setup
        let deleteButton = UIButton(type: .system)
        deleteButton.setTitle("✖", for: .normal)
        deleteButton.isHidden = true
        deleteButton.backgroundColor = .red
        deleteButton.setTitleColor(.white, for: .normal)
        deleteButton.layer.cornerRadius = 10
        deleteButton.frame = CGRect(x: container.frame.width - 10, y: -10, width: 20, height: 20)
        deleteButton.addTarget(self, action: #selector(deleteItem(_:)), for: .touchUpInside)

        container.addSubview(deleteButton)

        // Center the container inside the panel
        if x == nil || y == nil {
            container.center = CGPoint(x: panel.bounds.midX, y: panel.bounds.midY)
        } else {
            container.center = CGPoint(x: x!, y: y!)
        }

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleImagePan(_:)))
        container.addGestureRecognizer(panGesture)
    }
    
    @objc private func showBubbleOnImage(_ gesture: UILongPressGestureRecognizer) {
        guard let imageView = gesture.view as? UIImageView,
              let image = imageView.image else { return }

        if gesture.state == .began {
            eyedropperTargetImageView = imageView

            let pointInImage = gesture.location(in: imageView)
            let globalPoint = imageView.convert(pointInImage, to: view)

            colorPreview.center = globalPoint
            colorPreview.isHidden = false

            colorInfoLabel.frame = CGRect(x: globalPoint.x - 40, y: globalPoint.y + 30, width: 80, height: 40)
            colorInfoLabel.isHidden = false

            updateBubbleColor(at: pointInImage)
        }
    }
    
    @objc private func dragBubble(_ gesture: UIPanGestureRecognizer) {
        guard let imageView = eyedropperTargetImageView,
              let image = imageView.image,
              let bubble = gesture.view else { return }

        let translation = gesture.translation(in: view)

        // Move the bubble
        bubble.center = CGPoint(x: bubble.center.x + translation.x, y: bubble.center.y + translation.y)
        gesture.setTranslation(.zero, in: view)

        // Move the label below the bubble
        colorInfoLabel.frame = CGRect(x: bubble.center.x - 40, y: bubble.center.y + 30, width: 80, height: 40)

        // Convert bubble's center to point inside imageView
        let pointInImage = view.convert(bubble.center, to: imageView)

        // Update color
        if let color = getPixelColor(from: image, at: pointInImage, in: imageView) {
            colorPreview.backgroundColor = color
            colorInfoLabel.text = "\(colorToHex(color))\n\(colorToRGBString(color))"
        }
    }
    
    private func updateBubbleColor(at point: CGPoint) {
        guard let imageView = eyedropperTargetImageView,
              let image = imageView.image else { return }

        if let color = getPixelColor(from: image, at: point, in: imageView) {
            colorPreview.backgroundColor = color
            colorInfoLabel.text = "\(colorToHex(color))\n\(colorToRGBString(color))"
        }
    }
    
    private func getPixelColor(from image: UIImage, at point: CGPoint, in imageView: UIImageView) -> UIColor? {
        guard let cgImage = image.cgImage else { return nil }

        // Calculate the pixel in the image coordinate system
        let imageSize = image.size
        let imageViewSize = imageView.bounds.size

        let scaleX = imageSize.width / imageViewSize.width
        let scaleY = imageSize.height / imageViewSize.height

        let x = Int(point.x * scaleX)
        let y = Int(point.y * scaleY)

        guard x >= 0, y >= 0, x < cgImage.width, y < cgImage.height else { return nil }

        let pixelData = cgImage.dataProvider?.data
        guard let data = CFDataGetBytePtr(pixelData) else { return nil }

        let bytesPerPixel = 4
        let pixelIndex = ((cgImage.width * y) + x) * bytesPerPixel

        let r = CGFloat(data[pixelIndex]) / 255.0
        let g = CGFloat(data[pixelIndex + 1]) / 255.0
        let b = CGFloat(data[pixelIndex + 2]) / 255.0
        let a = CGFloat(data[pixelIndex + 3]) / 255.0

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    // get images url from firebase once stickers are made and inputted
    // imageUrl: String, replace with
    @objc private func stickerButton(){
        showStickerPanel()
    }
    
    private func showStickerPanel() {
        if stickerPanel != nil { return }

        stickerPanel = UIScrollView()
        stickerPanel.backgroundColor = UIColor(white: 0.9, alpha: 1)
        stickerPanel.layer.cornerRadius = 10
        stickerPanel.translatesAutoresizingMaskIntoConstraints = false
        stickerPanel.showsHorizontalScrollIndicator = false
        stickerPanel.isScrollEnabled = true
        
        view.addSubview(stickerPanel)

        NSLayoutConstraint.activate([
            stickerPanel.heightAnchor.constraint(equalToConstant: 100),
            stickerPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stickerPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stickerPanel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        loadStickersFromFirebase()
    }
    
    private func loadStickersFromFirebase() {
        let storageRef = Storage.storage().reference().child("stickers")
        
        storageRef.listAll { result, error in
            guard let result = result else {
                print("Error listing stickers: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let dispatchGroup = DispatchGroup()
            var stickerURLs: [(String, URL)] = []
            
            for item in result.items {
                dispatchGroup.enter()
                item.downloadURL { url, error in
                    if let url = url {
                        stickerURLs.append((item.name, url)) // Collect filename + URL
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                // Sort by filename to ensure consistent order
                let sortedStickers = stickerURLs.sorted { $0.0 < $1.0 }
                
                self.stickerPanel.subviews.forEach { $0.removeFromSuperview() } // Clear previous stickers
                var xOffset: CGFloat = 10
                let imageSize: CGFloat = 80
                
                for (_, url) in sortedStickers {
                    self.loadStickerPreview(url: url, xOffset: xOffset, imageSize: imageSize)
                    xOffset += imageSize + 10
                }
                
                self.stickerPanel.contentSize = CGSize(width: xOffset, height: 100)
            }
        }
    }

    private func loadStickerPreview(url: URL, xOffset: CGFloat, imageSize: CGFloat) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, let image = UIImage(data: data), error == nil else { return }
            
            DispatchQueue.main.async {
                let imageView = UIImageView(image: image)
                imageView.frame = CGRect(x: xOffset, y: 10, width: imageSize, height: imageSize)
                imageView.contentMode = .scaleAspectFit
                imageView.layer.cornerRadius = 8
                imageView.clipsToBounds = true
                imageView.isUserInteractionEnabled = true
                imageView.accessibilityIdentifier = url.absoluteString

                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.stickerTapped(_:)))
                imageView.addGestureRecognizer(tapGesture)

                self.stickerPanel.addSubview(imageView)
            }
        }.resume()
    }

    @objc private func stickerTapped(_ sender: UITapGestureRecognizer) {
        guard let imageView = sender.view as? UIImageView,
              let image = imageView.image,
              let url = imageView.accessibilityIdentifier else { return }

        addStickerToContentPanel(image: image, url: url)
        
        // Hide sticker panel after selection
        stickerPanel.removeFromSuperview()
        stickerPanel = nil
    }
    
    private func loadStickers() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not logged in.")
            return
        }

        db.collection("users").document(uid).getDocument { (document, error) in
            if let error = error {
                print("Error getting document: \(error)")
                return
            }

            if let document = document, document.exists {
                if let scrapbooks = document.data()?["scrapbooks"] as? [String: Any],
                   let stickersData = scrapbooks["stickers"] as? [[String: Any]] {
                    for stickerData in stickersData {
                        self.loadSticker(from: stickerData)
                    }
                } else {
                    print("No stickers data found.")
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    private func loadSticker(from data: [String: Any]) {
        guard let urlString = data["url"] as? String,
              let url = URL(string: urlString),
              let x = data["x"] as? CGFloat,
              let y = data["y"] as? CGFloat,
              let scaleX = data["scaleX"] as? CGFloat,
              let scaleY = data["scaleY"] as? CGFloat,
              let rotation = data["rotation"] as? CGFloat else {
            print("Invalid sticker data")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, let image = UIImage(data: data), error == nil else {
                print("Failed to load sticker image from URL: \(url)")
                return
            }

            DispatchQueue.main.async {
                self.addStickerToContentPanel(image: image, url: urlString, x: x, y: y, scaleX: scaleX, scaleY: scaleY, rotation: rotation)
            }
        }.resume()
    }

    private func addStickerToContentPanel(image: UIImage, url: String, x: CGFloat? = nil, y: CGFloat? = nil, scaleX: CGFloat = 1.0, scaleY: CGFloat = 1.0, rotation: CGFloat = 0.0) {
        guard let panel = contentPanel else { return }

        let defaultX = panel.bounds.midX - 40
        let defaultY = panel.bounds.midY - 40

        let container = UIView()
        container.isUserInteractionEnabled = true
        container.frame = CGRect(x: x ?? defaultX, y: y ?? defaultY, width: 80, height: 80)

        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.frame = container.bounds
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.accessibilityIdentifier = url

        container.transform = CGAffineTransform(scaleX: scaleX, y: scaleY).rotated(by: rotation)

        let deleteButton = UIButton(type: .system)
        deleteButton.setTitle("✖", for: .normal)
        deleteButton.isHidden = true
        deleteButton.backgroundColor = .red
        deleteButton.setTitleColor(.white, for: .normal)
        deleteButton.layer.cornerRadius = 10
        deleteButton.frame = CGRect(x: container.frame.width - 15, y: -10, width: 20, height: 20)
        deleteButton.addTarget(self, action: #selector(deleteItem(_:)), for: .touchUpInside)

        container.addSubview(imageView)
        container.addSubview(deleteButton)

        panel.addSubview(container)
        panel.bringSubviewToFront(container)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleImagePan(_:)))
        container.addGestureRecognizer(panGesture)

        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handleImagePinch(_:)))
        container.addGestureRecognizer(pinchGesture)
    }
    
    private func loadPhotos() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not logged in.")
            return
        }

        db.collection("users").document(uid).getDocument { (document, error) in
            if let error = error {
                print("Error getting document: \(error)")
                return
            }

            if let document = document, document.exists {
                if let scrapbooks = document.data()?["scrapbooks"] as? [String: Any],
                   let photosData = scrapbooks["photos"] as? [[String: Any]] {
                    for photoData in photosData {
                        self.loadPhoto(from: photoData)
                    }
                } else {
                    print("No photo data found.")
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    private func loadPhoto(from data: [String: Any]) {
        guard let urlString = data["url"] as? String,
              let url = URL(string: urlString),
              let x = data["x"] as? CGFloat,
              let y = data["y"] as? CGFloat,
              let scaleX = data["scaleX"] as? CGFloat,
              let scaleY = data["scaleY"] as? CGFloat,
              let rotation = data["rotation"] as? CGFloat else {
            print("Invalid photo data")
            return
        }
        print("Photo x: \(x), y: \(y), scaleX: \(scaleX), scaleY: \(scaleY), rotation: \(rotation)") // Print values

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, let image = UIImage(data: data), error == nil else {
                print("Failed to load photo image from URL: \(url)")
                return
            }

            DispatchQueue.main.async {
                self.addImageToContentPanel(image: image, x: x, y: y, scaleX: scaleX, scaleY: scaleY, rotation: rotation)
            }
        }.resume()
    }
    
    private func loadBackground() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not logged in.")
            return
        }

        db.collection("users").document(uid).getDocument { (document, error) in
            if let error = error {
                print("Error getting document: \(error)")
                return
            }

            if let document = document, document.exists {
                if let scrapbooks = document.data()?["scrapbooks"] as? [String: Any],
                   let backgroundData = scrapbooks["background"] as? [String: Any] {
                    self.loadBackground(from: backgroundData)
                } else {
                    print("No background data found.")
                }
            } else {
                print("Document does not exist")
            }
        }
    }

    private func loadBackground(from data: [String: Any]) {
        if let type = data["type"] as? String {
            switch type {
            case "color":
                if let hexColor = data["value"] as? String, let color = UIColor(hexString: hexColor) {
                    DispatchQueue.main.async {
                        self.setBackgroundColor(color: color)
                    }
                }
            case "image":
                if let urlString = data["url"] as? String, let url = URL(string: urlString) {
                    URLSession.shared.dataTask(with: url) { data, _, error in
                        guard let data = data, let image = UIImage(data: data), error == nil else {
                            print("Failed to load background image from URL: \(url)")
                            return
                        }
                        DispatchQueue.main.async {
                            self.setBackgroundImage(image: image)
                        }
                    }.resume()
                }
            default:
                print("Unknown background type: \(type)")
            }
        }
    }
    
    private func setupColorPreviewBubble() {
        colorPreview = UIView(frame: CGRect(x: 50, y: 50, width: 40, height: 40))
        colorPreview.layer.cornerRadius = 20
        colorPreview.layer.borderColor = UIColor.white.cgColor
        colorPreview.layer.borderWidth = 2
        colorPreview.layer.shadowColor = UIColor.black.cgColor
        colorPreview.layer.shadowOpacity = 0.3
        colorPreview.layer.shadowRadius = 4
        colorPreview.isHidden = true
        colorPreview.isUserInteractionEnabled = true
        view.addSubview(colorPreview)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(dragBubble(_:)))
        colorPreview.addGestureRecognizer(pan)
        
        let dismissPress = UILongPressGestureRecognizer(target: self, action: #selector(hideBubble(_:)))
        colorPreview.addGestureRecognizer(dismissPress)

        colorInfoLabel = UILabel()
        colorInfoLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        colorInfoLabel.textColor = .white
        colorInfoLabel.textAlignment = .center
        colorInfoLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        colorInfoLabel.layer.cornerRadius = 6
        colorInfoLabel.layer.masksToBounds = true
        colorInfoLabel.numberOfLines = 2
        colorInfoLabel.isHidden = true
        view.addSubview(colorInfoLabel)
    }
    
    @objc private func hideBubble(_ gesture: UILongPressGestureRecognizer) {
        UIView.animate(withDuration: 0.2) {
            self.colorPreview.alpha = 0
            self.colorInfoLabel.alpha = 0
        } completion: { _ in
            self.colorPreview.isHidden = true
            self.colorInfoLabel.isHidden = true
            self.colorPreview.alpha = 1
            self.colorInfoLabel.alpha = 1
        }
        if gesture.state == .began {
            colorPreview.isHidden = true
            colorInfoLabel.isHidden = true
            eyedropperTargetImageView = nil
        }
    }

    @objc private func handleImagePinch(_ gesture: UIPinchGestureRecognizer){
        guard let imageView = gesture.view as? UIImageView else { return }
        imageView.transform = imageView.transform.scaledBy(x: gesture.scale, y: gesture.scale)
        gesture.scale = 1.0
    }

    private func setBackgroundImage(image: UIImage) {
        guard let panel = contentPanel else { return }
        panel.backgroundColor = nil
        panel.subviews.first(where: { $0 is UIImageView })?.removeFromSuperview()
        panel.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        let backgroundImageView = UIImageView(image: image)
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        panel.insertSubview(backgroundImageView, at: 0)
 
         NSLayoutConstraint.activate([
             backgroundImageView.topAnchor.constraint(equalTo: panel.topAnchor),
             backgroundImageView.bottomAnchor.constraint(equalTo: panel.bottomAnchor),
             backgroundImageView.leadingAnchor.constraint(equalTo: panel.leadingAnchor),
             backgroundImageView.trailingAnchor.constraint(equalTo: panel.trailingAnchor)
         ])
    }
    
    private func setBackgroundColor(color: UIColor) {
        guard let panel = contentPanel else { return }
        panel.subviews.first(where: { $0 is UIImageView })?.removeFromSuperview()
        panel.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        panel.backgroundColor = color
    }

    @objc private func openColorPicker(){
        if !isDeleteModeActive {
            let colorPicker = UIColorPickerViewController()
            colorPicker.delegate = self
            present(colorPicker, animated: true)
        }
    }
    
    private func colorToHex(_ color: UIColor) -> String {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return String(format: "#%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
    }

    private func colorToRGBString(_ color: UIColor) -> String {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return String(format: "RGB(%d, %d, %d)", Int(red * 255), Int(green * 255), Int(blue * 255))
    }

    // MARK: - Delete Mode
    @objc private func toggleDeleteMode() {
        isDeleteModeActive.toggle()
        for subview in contentPanel.subviews {
            if let container = subview as? UIView, let deleteButton = container.subviews.first(where: { $0 is UIButton }) as? UIButton {
                deleteButton.isHidden = !isDeleteModeActive
            }
        }
    }

    @objc private func deleteItem(_ sender: UIButton) {
        sender.superview?.removeFromSuperview()
        print("Deleted")
    }

    // MARK: - Gesture Handling
    @objc private func handleImagePan(_ gesture: UIPanGestureRecognizer) {
        guard let imageView = gesture.view else { return }
        let translation = gesture.translation(in: contentPanel)
        imageView.center = CGPoint(x: imageView.center.x + translation.x, y: imageView.center.y + translation.y)
        gesture.setTranslation(.zero, in: contentPanel)
    }

    // MARK: - Button Actions
    @objc private func frameTapped() { print("Frame button tapped") }
    @objc private func chatTapped() {
        let chatView = ChatbotViewController()
        chatView.modalPresentationStyle = .overCurrentContext
        chatView.modalTransitionStyle = .crossDissolve
        present(chatView, animated: true, completion: nil)
    }

    private func getRelatedProducts(){
        let dynamicImageUrl = "https://your-dynamic-image-url.com/image.jpg"
        GoogleLensService.searchWithGoogleLens(imageUrl: dynamicImageUrl) { result in
            switch result {
                case .success(let data):
                    print("Search success:", data)
                case .failure(let error):
                    print("Search failed:", error)
            }
        }
    }
    
}

extension NewScrapbook: UIColorPickerViewControllerDelegate{
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController){
        setBackgroundColor(color: viewController.selectedColor)
        viewController.dismiss(animated: true)
    }
}

extension UIColor {
    func toHex() -> String {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return String(format: "#%02X%02X%02X",
                      Int(red * 255),
                      Int(green * 255),
                      Int(blue * 255))
    }
}
