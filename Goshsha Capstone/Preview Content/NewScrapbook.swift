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
    let db = Firestore.firestore();

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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
        setupConstraints(titleContainer: titleContainer, titleLabel: titleLabel, saveButton: saveButton, chatButton: chatButton, toolbar: toolbar)
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
        panel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openColorPicker)))
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
            createToolbarButton(#selector(selectImageFromLibrary), "bg"),
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

    private func setupConstraints(titleContainer: UIView, titleLabel: UILabel, saveButton: UIButton, chatButton: UIButton, toolbar: UIToolbar) {
        NSLayoutConstraint.activate([
            titleContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -20),
            titleContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleContainer.heightAnchor.constraint(equalToConstant: 80),

            // Title Label
            titleLabel.centerXAnchor.constraint(equalTo: titleContainer.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: titleContainer.centerYAnchor),

            // Save Button
            saveButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            saveButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 10),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
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
            chatButton.bottomAnchor.constraint(equalTo: contentPanel.bottomAnchor, constant: 0),
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
        
        clearExistingData(uid: uid)

        var photos: [[String: Any]] = []
        let dispatchGroup = DispatchGroup()

        for subview in panel.subviews where !(subview is UIButton) {
            if let container = subview as? UIView,
               let imageView = container.subviews.first(where: { $0 is UIImageView }) as? UIImageView {

                var photoData: [String: Any] = [
                    "id": UUID().uuidString,
                    "x": container.frame.origin.x,
                    "y": container.frame.origin.y,
                    "scaleX": container.transform.a,
                    "scaleY": container.transform.d,
                    "rotation": atan2(container.transform.b, container.transform.a)
                ]

                if let image = imageView.image {
                    dispatchGroup.enter()
                    uploadPhoto(image: image) { url in
                        if let url = url {
                            photoData["url"] = url.absoluteString
                            imageView.accessibilityIdentifier = url.absoluteString
                            photos.append(photoData)
                        }
                        dispatchGroup.leave()
                    }
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.getBackgroundInfo { background in
                let scrapbookData: [String: Any] = [
                    "photos": photos,
                    "background": background
                ]

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
    
    private func clearExistingData(uid: String) {
        let userDoc = db.collection("users").document(uid)
        let folderRef = Storage.storage().reference().child("scrapbook_photos/\(uid)")

        folderRef.listAll { result, error in
            if let error = error {
                print("Error listing files: \(error.localizedDescription)")
                return
            }

            guard let items = result?.items, !items.isEmpty else {
                print("No items found in folder")
                return
            }

            let dispatchGroup = DispatchGroup()

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

            dispatchGroup.notify(queue: .main) {
                print("All files deleted for user \(uid)")

                userDoc.updateData([
                    "scrapbooks": [:]
                ]) { error in
                    if let error = error {
                        print("Error clearing Firestore scrapbook data: \(error.localizedDescription)")
                    } else {
                        print("Firestore scrapbook data cleared for user \(uid)")
                    }
                }
            }
        }
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

    private func addImageToContentPanel(image: UIImage) {
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

        // Add subviews
        container.addSubview(imageView)
        panel.addSubview(container)

        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handleImagePinch(_:)))
        imageView.addGestureRecognizer(pinchGesture)

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
        container.center = CGPoint(x: panel.bounds.midX, y: panel.bounds.midY)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleImagePan(_:)))
        container.addGestureRecognizer(panGesture)
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

    private func addStickerToContentPanel(image: UIImage, url: String) {
        guard let panel = contentPanel else { return }

        // Create a container for the sticker
        let container = UIView()
        container.isUserInteractionEnabled = true
        container.frame = CGRect(x: panel.bounds.midX - 40, y: panel.bounds.midY - 40, width: 80, height: 80)

        // Create the sticker image view
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.frame = container.bounds
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.accessibilityIdentifier = url

        // Create the delete button
        let deleteButton = UIButton(type: .system)
        deleteButton.setTitle("✖", for: .normal)
        deleteButton.isHidden = true
        deleteButton.backgroundColor = .red
        deleteButton.setTitleColor(.white, for: .normal)
        deleteButton.layer.cornerRadius = 10
        deleteButton.frame = CGRect(x: container.frame.width - 15, y: -10, width: 20, height: 20)
        deleteButton.addTarget(self, action: #selector(deleteItem(_:)), for: .touchUpInside)

        // Add views to the container
        container.addSubview(imageView)
        container.addSubview(deleteButton)

        // Ensure stickers always appear on top
        panel.addSubview(container)
        panel.bringSubviewToFront(container)

        // Gesture recognizers for movement and scaling
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleImagePan(_:)))
        container.addGestureRecognizer(panGesture)

        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handleImagePinch(_:)))
        container.addGestureRecognizer(pinchGesture)
    }

    @objc private func handleImagePinch(_ gesture: UIPinchGestureRecognizer){
        guard let imageView = gesture.view as? UIImageView else { return }
        imageView.transform = imageView.transform.scaledBy(x: gesture.scale, y: gesture.scale)
        gesture.scale = 1.0
    }

    private func setBackgroundImage(image: UIImage) {
        guard let panel = contentPanel else { return }
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
        let colorPicker = UIColorPickerViewController()
        colorPicker.delegate = self
        present(colorPicker, animated: true)
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
