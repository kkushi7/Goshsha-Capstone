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
    var chatButton: UIButton!
    private var dismissOverlay: UIView?
    private var actionStack: [EditorAction] = []

    let db = Firestore.firestore();

    enum EditorAction {
        case add(view: UIView)
        case move(view: UIView, from: CGPoint, to: CGPoint)
        case delete(view: UIView, fromSuperview: UIView)
        case resize(view: UIView, from: CGAffineTransform, to: CGAffineTransform)
        case backgroundChange(from: UIColor?, to: UIColor?)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadAllLayersInOrder()
        loadBackground()
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
        chatButton = setupButton(imageName: "goshi", action: #selector(chatTapped))
        view.addSubview(chatButton)
        view.bringSubviewToFront(chatButton)

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
            .flexibleSpace(),
            createLabeledToolbarItem(imageName: "sticker", title: "STICKERS", action: #selector(stickerButton)),
            .flexibleSpace(),
            createLabeledToolbarItem(imageName: "bg", title: "BACKGROUND", action: #selector(openColorPicker)),
            .flexibleSpace(),
            createLabeledToolbarItem(imageName: "image", title: "IMAGES", action: #selector(cameraTapped)),
            .flexibleSpace(),
            createLabeledToolbarItem(imageName: "undo", title: "UNDO", action: #selector(undoButtonTapped)),
            .flexibleSpace()
        ]
        
        return toolbar
    }

    private func createLabeledToolbarItem(imageName: String, title: String, action: Selector) -> UIBarButtonItem {
        // Frame
        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 90))
        outerView.isUserInteractionEnabled = true

        // Gesture recognizer
        let tap = UITapGestureRecognizer(target: self, action: action)
        outerView.addGestureRecognizer(tap)

        // Icon
        let imageView = UIImageView(image: UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 36).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 36).isActive = true

        // Label
        let label = UILabel()
        label.text = title
        label.font = UIFont(name: "RobotoFlex", size: 24)
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        label.translatesAutoresizingMaskIntoConstraints = false

        // Stack
        let stack = UIStackView(arrangedSubviews: [imageView, label])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false

        outerView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: outerView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: outerView.centerYAnchor),
            stack.widthAnchor.constraint(lessThanOrEqualTo: outerView.widthAnchor),
            stack.heightAnchor.constraint(lessThanOrEqualTo: outerView.heightAnchor)
        ])

        return UIBarButtonItem(customView: outerView)
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
            
            let layeredSubviews = panel.subviews
                .filter { !($0 is UIButton) }

            // Process all images and stickers
            for (index, subview) in layeredSubviews.enumerated() {
                if let container = subview as? UIView,
                   let imageView = container.subviews.first(where: { $0 is ScrapbookImageView }) as? ScrapbookImageView {

                    var itemData: [String: Any] = [
                        "id": UUID().uuidString,
                        "scaleX": container.transform.a,
                        "scaleY": container.transform.d,
                        "rotation": atan2(container.transform.b, container.transform.a),
                        "zIndex": index
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
                                if let imageView = container.subviews.first as? ScrapbookImageView {
                                    imageView.firebaseURL = url.absoluteString
                                }
                                itemData["url"] = url.absoluteString
                                itemData["x"] = container.center.x
                                itemData["y"] = container.center.y
                                itemData["frame"] = imageView.hasPolaroidFrame

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
                            
                            let alert = UIAlertController(title: "Saved", message: "Your scrapbook has been saved!", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alert, animated: true)
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
                    print("Download URL: \(url.absoluteString)")
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
        container.clipsToBounds = false

        let imageView = ScrapbookImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.sizeToFit()
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true

        actionStack.append(.add(view: container))


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
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(showDeleteButton(_:)))
        container.addGestureRecognizer(longPress)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTap(_:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)

        let deleteButton = UIButton(type: .custom)
        let deleteImage = UIImage(named: "delete")

        deleteButton.setImage(deleteImage, for: .normal)
        deleteButton.isHidden = true
        deleteButton.addTarget(self, action: #selector(deleteItem(_:)), for: .touchUpInside)

        let buttonSize: CGFloat = 50
        deleteButton.frame = CGRect(
            x: container.bounds.width - buttonSize * 0.9,
            y: -buttonSize * 0.1,
            width: buttonSize,
            height: buttonSize
        )
        container.addSubview(deleteButton)
        
        let frameButton = UIButton(type: .custom)
        let frameImage = UIImage(named: "frame")
        frameButton.setImage(frameImage, for: .normal)
        frameButton.isHidden = true
        frameButton.addTarget(self, action: #selector(applyFrame(_:)), for: .touchUpInside)
        frameButton.frame = CGRect(
            x: deleteButton.frame.minX - buttonSize * 0.65,
            y: deleteButton.frame.origin.y,
            width: buttonSize,
            height: buttonSize
        )
        container.addSubview(frameButton)

        // Center the container inside the panel
        if x == nil || y == nil {
            container.center = CGPoint(x: panel.bounds.midX, y: panel.bounds.midY)
        } else {
            container.center = CGPoint(x: x!, y: y!)
        }

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleImagePan(_:)))
        container.addGestureRecognizer(panGesture)
        
    }
    
    @objc private func applyFrame(_ sender: UIButton) {
        guard let container = sender.superview,
              let imageView = container.subviews.first(where: { $0 is ScrapbookImageView }) as? ScrapbookImageView else {
            return
        }
        applyFrame(to: imageView)
    }
    
    func applyFrame(to imageView: ScrapbookImageView) {
        guard let container = imageView.superview else { return }

        if let existingFrame = container.viewWithTag(1234) {
            existingFrame.removeFromSuperview()
            imageView.hasPolaroidFrame = false
            return
        }

        let polaroidColor = UIColor(red: 251/255.0, green: 239/255.0, blue: 244/255.0, alpha: 1.0)

        let frameView = UIView()
        frameView.tag = 1234
        frameView.backgroundColor = polaroidColor
        frameView.layer.cornerRadius = 0
        frameView.layer.shadowColor = UIColor.black.cgColor
        frameView.layer.shadowOpacity = 0.1
        frameView.layer.shadowOffset = CGSize(width: 2, height: 2)
        frameView.layer.shadowRadius = 3
        frameView.clipsToBounds = true
        frameView.isUserInteractionEnabled = false

        let paddingTop: CGFloat = 20
        let paddingSides: CGFloat = 15
        let paddingBottom: CGFloat = 60

        let frameX = imageView.frame.origin.x - paddingSides
        let frameY = imageView.frame.origin.y - paddingTop
        let frameWidth = imageView.frame.width + 2 * paddingSides
        let frameHeight = imageView.frame.height + paddingTop + paddingBottom

        frameView.frame = CGRect(x: frameX, y: frameY, width: frameWidth, height: frameHeight)

        let captionLabel = UILabel()
        captionLabel.text = "Fujifilm Instax\nMini Format"
        captionLabel.numberOfLines = 2
        captionLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        captionLabel.textAlignment = .center
        captionLabel.textColor = .darkGray
        captionLabel.translatesAutoresizingMaskIntoConstraints = false

        frameView.addSubview(captionLabel)
        container.insertSubview(frameView, belowSubview: imageView)

        NSLayoutConstraint.activate([
            captionLabel.bottomAnchor.constraint(equalTo: frameView.bottomAnchor, constant: -8),
            captionLabel.centerXAnchor.constraint(equalTo: frameView.centerXAnchor),
            captionLabel.widthAnchor.constraint(equalTo: frameView.widthAnchor, multiplier: 0.8),
            captionLabel.heightAnchor.constraint(equalToConstant: 40)
        ])

        imageView.hasPolaroidFrame = true
    }
    
    @objc private func showDeleteButton(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began,
              let container = gesture.view else { return }

        // Bring the container to front
        contentPanel.bringSubviewToFront(container)

        // Toggle visibility of all buttons inside
        for subview in container.subviews {
            if let button = subview as? UIButton {
                button.isHidden.toggle()
            }
        }
    }
    
    // get images url from firebase once stickers are made and inputted
    // imageUrl: String, replace with
    @objc private func stickerButton(){
        showStickerPanel()
    }
    
    private func showStickerPanel() {
        if stickerPanel != nil { return }

        // Create transparent dismiss overlay
        let overlay = UIView()
        overlay.backgroundColor = .clear
        overlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlay)
        dismissOverlay = overlay

        let tap = UITapGestureRecognizer(target: self, action: #selector(hideStickerPanel))
        overlay.addGestureRecognizer(tap)

        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: view.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        // Add the sticker panel
        stickerPanel = UIScrollView()
        stickerPanel.backgroundColor = UIColor(white: 0.9, alpha: 1)
        stickerPanel.layer.cornerRadius = 10
        stickerPanel.translatesAutoresizingMaskIntoConstraints = false
        stickerPanel.showsHorizontalScrollIndicator = false
        stickerPanel.isScrollEnabled = true

        overlay.addSubview(stickerPanel)

        NSLayoutConstraint.activate([
            stickerPanel.heightAnchor.constraint(equalToConstant: 100),
            stickerPanel.leadingAnchor.constraint(equalTo: overlay.leadingAnchor, constant: 16),
            stickerPanel.trailingAnchor.constraint(equalTo: overlay.trailingAnchor, constant: -16),
            stickerPanel.bottomAnchor.constraint(equalTo: overlay.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        loadStickersFromFirebase()
    }
    
    @objc private func hideStickerPanel() {
        stickerPanel?.removeFromSuperview()
        stickerPanel = nil

        dismissOverlay?.removeFromSuperview()
        dismissOverlay = nil
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
                let imageView = ScrapbookImageView(image: image)
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
        hideStickerPanel()
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

        let imageView = ScrapbookImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = container.bounds
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.accessibilityIdentifier = url

        actionStack.append(.add(view: container))

        // Delete button
        let deleteButton = UIButton(type: .custom)
        let deleteImage = UIImage(named: "delete")?.withRenderingMode(.alwaysOriginal)
        deleteButton.setImage(deleteImage, for: .normal)
        deleteButton.isHidden = true
        deleteButton.frame = CGRect(
            x: container.bounds.width - 40,
            y: -10,
            width: 40,
            height: 40
        )
        deleteButton.addTarget(self, action: #selector(deleteItem(_:)), for: .touchUpInside)

        // Add subviews
        container.addSubview(imageView)
        container.addSubview(deleteButton)
        panel.addSubview(container)
        panel.bringSubviewToFront(container)

        // Gestures
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleImagePan(_:)))
        container.addGestureRecognizer(panGesture)

        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handleImagePinch(_:)))
        container.addGestureRecognizer(pinchGesture)

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(showDeleteButton(_:)))
        container.addGestureRecognizer(longPressGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleStickerTap(_:)))
        container.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleStickerTap(_ gesture: UITapGestureRecognizer) {
        if let container = gesture.view {
            contentPanel.bringSubviewToFront(container)
        }
    }
    
    private func loadAllLayersInOrder() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not logged in.")
            return
        }

        db.collection("users").document(uid).getDocument { (document, error) in
            if let error = error {
                print("Error getting document: \(error)")
                return
            }

            guard let document = document, document.exists,
                  let scrapbooks = document.data()?["scrapbooks"] as? [String: Any] else {
                print("No scrapbook data found.")
                return
            }

            var allItems: [[String: Any]] = []

            if let photosData = scrapbooks["photos"] as? [[String: Any]] {
                for var photo in photosData {
                    photo["type"] = "photo"
                    allItems.append(photo)
                }
            }

            if let stickersData = scrapbooks["stickers"] as? [[String: Any]] {
                for var sticker in stickersData {
                    sticker["type"] = "sticker"
                    allItems.append(sticker)
                }
            }

            // Prepare to load all images
            let sortedItems = allItems.sorted {
                ($0["zIndex"] as? Int ?? 0) < ($1["zIndex"] as? Int ?? 0)
            }

            let dispatchGroup = DispatchGroup()
            var loadedViews: [(Int, UIView)] = []

            for item in sortedItems {
                guard let type = item["type"] as? String,
                      let urlString = item["url"] as? String,
                      let url = URL(string: urlString),
                      let zIndex = item["zIndex"] as? Int else {
                    continue
                }

                dispatchGroup.enter()
                URLSession.shared.dataTask(with: url) { data, _, error in
                    defer { dispatchGroup.leave() }
                    guard let data = data, let image = UIImage(data: data), error == nil else {
                        print("Failed to load image at \(urlString)")
                        return
                    }

                    DispatchQueue.main.async {
                        var view: UIView?
                        if type == "photo" {
                            view = self.createLoadedPhotoView(from: item, with: image, urlString: urlString)
                        } else {
                            view = self.createLoadedStickerView(from: item, with: image, urlString: urlString)
                        }

                        if let view = view {
                            loadedViews.append((zIndex, view))
                        }
                    }
                }.resume()
            }

            dispatchGroup.notify(queue: .main) {
                // Add views in sorted order
                let sortedViews = loadedViews.sorted { $0.0 < $1.0 }
                for (_, view) in sortedViews {
                    self.contentPanel.addSubview(view)
                }
            }
        }
    }
    
    private func createLoadedPhotoView(from data: [String: Any], with image: UIImage, urlString: String) -> UIView {
        guard let x = data["x"] as? CGFloat,
              let y = data["y"] as? CGFloat,
              let scaleX = data["scaleX"] as? CGFloat,
              let scaleY = data["scaleY"] as? CGFloat,
              let rotation = data["rotation"] as? CGFloat else {
            return UIView()
        }

        let hasFrame = data["frame"] as? Bool ?? false
        self.addImageToContentPanel(image: image, x: x, y: y, scaleX: scaleX, scaleY: scaleY, rotation: rotation)

        if let lastContainer = self.contentPanel.subviews.last,
           let loadedImageView = lastContainer.subviews.first as? ScrapbookImageView {
            loadedImageView.firebaseURL = urlString
            if hasFrame {
                self.applyFrame(to: loadedImageView)
            }
            return lastContainer
        }

        return UIView()
    }

    private func createLoadedStickerView(from data: [String: Any], with image: UIImage, urlString: String) -> UIView {
        guard let x = data["x"] as? CGFloat,
              let y = data["y"] as? CGFloat,
              let scaleX = data["scaleX"] as? CGFloat,
              let scaleY = data["scaleY"] as? CGFloat,
              let rotation = data["rotation"] as? CGFloat else {
            return UIView()
        }

        self.addStickerToContentPanel(image: image, url: urlString, x: x, y: y, scaleX: scaleX, scaleY: scaleY, rotation: rotation)

        return self.contentPanel.subviews.last ?? UIView()
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
        let hasFrame = data["frame"] as? Bool ?? false
        print("Photo x: \(x), y: \(y), scaleX: \(scaleX), scaleY: \(scaleY), rotation: \(rotation)") // Print values

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, let image = UIImage(data: data), error == nil else {
                print("Failed to load photo image from URL: \(url)")
                return
            }

            DispatchQueue.main.async {
                self.addImageToContentPanel(image: image, x: x, y: y, scaleX: scaleX, scaleY: scaleY, rotation: rotation)
                
                if let lastContainer = self.contentPanel.subviews.last,
                   let loadedImageView = lastContainer.subviews.first as? ScrapbookImageView {
                    loadedImageView.firebaseURL = urlString
                    if hasFrame {
                        self.applyFrame(to: loadedImageView)
                    }
                }
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

    @objc private func handleImagePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let container = gesture.view,
              let panel = contentPanel else { return }

        guard let imageView = container.subviews.first(where: { $0 is UIImageView }) else { return }

        struct PinchState {
            static var initialTransform: CGAffineTransform = .identity
        }

        if gesture.state == .began {
            PinchState.initialTransform = container.transform
            contentPanel.bringSubviewToFront(container)
        }

        let currentTransform = container.transform
        var newScaleX = currentTransform.a * gesture.scale
        var newScaleY = currentTransform.d * gesture.scale

        let baseWidth = imageView.bounds.width
        let baseHeight = imageView.bounds.height
        let maxWidth = panel.bounds.width * 0.8
        let maxHeight = panel.bounds.height * 0.8
        let maxAllowedScale = min(maxWidth / baseWidth, maxHeight / baseHeight)

        newScaleX = min(maxAllowedScale, max(0.7, newScaleX))
        newScaleY = min(maxAllowedScale, max(0.7, newScaleY))
        gesture.scale = 1.0

        let rotation = atan2(currentTransform.b, currentTransform.a)
        let newTransform = CGAffineTransform.identity
            .scaledBy(x: newScaleX, y: newScaleY)
            .rotated(by: rotation)

        container.transform = newTransform

        if gesture.state == .ended {
            actionStack.append(.resize(view: container, from: PinchState.initialTransform, to: newTransform))
        }
    }
    
    @objc private func handleImageTap(_ sender: UITapGestureRecognizer) {
        guard let imageView = sender.view as? ScrapbookImageView,
              let container = imageView.superview else {
            print("Tapped image has no stored URL.")
            return
        }

        // Bring the tapped container to the front
        contentPanel.bringSubviewToFront(container)

        UIView.animate(withDuration: 0.15, animations: {
            container.transform = container.transform.scaledBy(x: 1.05, y: 1.05)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                container.transform = .identity
            }
        }

        if let urlString = imageView.firebaseURL {
            print("Tapped image URL: \(urlString)")
        }
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

    private func hexToRGB(_ hex: String) -> (r: Int, g: Int, b: Int)? {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        
        if hexString.count == 3 {
            hexString = hexString.map { "\($0)\($0)" }.joined()
        }

        guard hexString.count == 6,
              let hexValue = Int(hexString, radix: 16) else { return nil }

        let r = (hexValue >> 16) & 0xFF
        let g = (hexValue >> 8) & 0xFF
        let b = hexValue & 0xFF

        return (r, g, b)
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
        guard let container = sender.superview else { return }
        actionStack.append(.delete(view: container, fromSuperview: contentPanel))
        container.removeFromSuperview()
    }

    // MARK: - Gesture Handling
    @objc private func handleImagePan(_ gesture: UIPanGestureRecognizer) {
        guard let movingView = gesture.view, let panel = contentPanel else { return }

        // Store the original center only once when gesture begins
        struct PanState {
            static var originalCenter = CGPoint.zero
        }

        if gesture.state == .began {
            PanState.originalCenter = movingView.center
            panel.bringSubviewToFront(movingView)
        }

        let translation = gesture.translation(in: panel)
        var newCenter = CGPoint(
            x: PanState.originalCenter.x + translation.x,
            y: PanState.originalCenter.y + translation.y
        )

        // Clamp to content panel bounds
        let transformedFrame = movingView.transformedBounds
        let halfWidth = transformedFrame.width / 2
        let halfHeight = transformedFrame.height / 2

        let paddingTop: CGFloat = 20
        let paddingBottom: CGFloat = 20

        let minX = halfWidth
        let maxX = panel.bounds.width - halfWidth
        let minY = halfHeight + paddingTop
        let maxY = panel.bounds.height - halfHeight - paddingBottom

        newCenter.x = max(minX, min(newCenter.x, maxX))
        newCenter.y = max(minY, min(newCenter.y, maxY))


        movingView.center = newCenter

        if gesture.state == .ended {
            actionStack.append(.move(view: movingView, from: PanState.originalCenter, to: newCenter))
        }
    }

    // MARK: - Button Actions
    @objc private func frameTapped() {
    }
    @objc private func chatTapped() {
        let chatView = ChatbotViewController()
        chatView.modalPresentationStyle = .overCurrentContext
        chatView.modalTransitionStyle = .crossDissolve
        present(chatView, animated: true, completion: nil)
    }

    private func uploadToFirebase(image: UIImage, completion: @escaping (Result<String, Error>) -> Void){
        let storageRef = Storage.storage().reference().child("cropped_images/\(UUID().uuidString).jpg")
        if let imageData = image.jpegData(compressionQuality: 0.9){
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                storageRef.downloadURL { url, error in
                    if let url = url {
                        completion(.success(url.absoluteString))
                    } else {
                        completion(.failure(error ?? NSError(domain: "", code: -1)))
                    }
                }
            }
        }
    }

    @objc private func undoButtonTapped(){
        guard let lastAction = actionStack.popLast() else { return }

        switch lastAction {
        case .add(let view):
            view.removeFromSuperview()
        case .move(let view, let from, _):
            view.center = from
        case .delete(let view, let fromSuperview):
            fromSuperview.addSubview(view)
        case .resize(let view, let from, _):
            view.transform = from
        case .backgroundChange(let fromColor, _):
            if let color = fromColor {
                setBackgroundColor(color: color)
            } else {
                contentPanel.backgroundColor = nil
            }
        }
    }
}

extension NewScrapbook: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        guard let panel = contentPanel else { return }
        let previousColor = panel.backgroundColor
        let newColor = viewController.selectedColor

        // Only track changes
        if previousColor != newColor {
            setBackgroundColor(color: newColor)
            actionStack.append(.backgroundChange(from: previousColor, to: newColor))
        }
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

extension UIView {
    var transformedBounds: CGRect {
        return self.bounds.applying(self.transform)
    }
}
