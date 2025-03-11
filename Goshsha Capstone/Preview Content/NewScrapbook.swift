//
//  NewScrapbook.swift
//  Goshsha Capstone
//
//  Created by Amber Chang on 2/26/25.
//

import UIKit
import FirebaseStorage

class NewScrapbook: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var isAddingToPanel = false
    var isDeleteModeActive = false
    var contentPanel: UIView!
    var stickerPanel: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white

        // Title Label
        let titleLabel = createTitleLabel()
        view.addSubview(titleLabel)

        // Content Panel
        contentPanel = createContentPanel()
        view.addSubview(contentPanel)

        // Chat Button
        let chatButton = setupButton(imageName: "goshi", action: #selector(chatTapped))
        contentPanel.addSubview(chatButton)

        // Toolbar
        let toolbar = createToolbar()
        view.addSubview(toolbar)

        // Constraints
        setupConstraints(titleLabel: titleLabel, chatButton: chatButton, toolbar: toolbar)
    }

    private func createTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = "Your Scrapbook"
        titleLabel.textColor = .white
        titleLabel.backgroundColor = .black
        titleLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }

    private func createContentPanel() -> UIView {
        let panel = UIView()
        panel.backgroundColor = UIColor(white: 0.95, alpha: 1)
        panel.layer.cornerRadius = 10
        panel.layer.shadowColor = UIColor.black.cgColor
        panel.layer.shadowOpacity = 0.1
        panel.layer.shadowOffset = CGSize(width: 0, height: 2)
        panel.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openColorPicker))
        panel.addGestureRecognizer(tapGesture)
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
        
        toolbar.items = [
            createToolbarButton(#selector(stickerButton), "face.smiling"),
            .flexibleSpace(),
            createToolbarButton(#selector(selectImageFromLibrary), "scribble"),
            .flexibleSpace(),
            createToolbarButton(#selector(cameraTapped), "camera"),
            .flexibleSpace(),
            createToolbarButton(#selector(frameTapped), "square"),
            .flexibleSpace(),
            createToolbarButton(#selector(toggleDeleteMode), "eraser")
        ]
        
        return toolbar
    }

    private func createToolbarButton(_ action: Selector, _ imageName: String) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: imageName), for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFit
        return UIBarButtonItem(customView: button)
    }

    private func setupConstraints(titleLabel: UILabel, chatButton: UIButton, toolbar: UIToolbar) {
        NSLayoutConstraint.activate([
            // Title
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 80),

            // Content Panel
            contentPanel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            contentPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contentPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            contentPanel.bottomAnchor.constraint(equalTo: toolbar.topAnchor, constant: -16),

            // Toolbar
            toolbar.heightAnchor.constraint(equalToConstant: 80),
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Chat Button
            chatButton.trailingAnchor.constraint(equalTo: contentPanel.trailingAnchor, constant: -16),
            chatButton.bottomAnchor.constraint(equalTo: contentPanel.bottomAnchor, constant: -16),
            chatButton.widthAnchor.constraint(equalToConstant: 200),
            chatButton.heightAnchor.constraint(equalToConstant: 200)
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

        // Delete button setup
        let deleteButton = UIButton(type: .system)
        deleteButton.setTitle("✖", for: .normal)
        deleteButton.isHidden = true
        deleteButton.backgroundColor = .red
        deleteButton.setTitleColor(.white, for: .normal)
        deleteButton.layer.cornerRadius = 10
        deleteButton.frame = CGRect(x: container.frame.width - 10, y: -10, width: 20, height: 20)
        deleteButton.addTarget(self, action: #selector(deleteImage(_:)), for: .touchUpInside)

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

                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.stickerTapped(_:)))
                imageView.addGestureRecognizer(tapGesture)

                self.stickerPanel.addSubview(imageView)
            }
        }.resume()
    }

    @objc private func stickerTapped(_ sender: UITapGestureRecognizer) {
        guard let imageView = sender.view as? UIImageView,
              let image = imageView.image else { return }

        addStickerToContentPanel(image: image)
        
        // Hide sticker panel after selection
        stickerPanel.removeFromSuperview()
        stickerPanel = nil
    }

    private func addStickerToContentPanel(image: UIImage){
        guard let panel = contentPanel else { return }

        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: panel.bounds.midX - 40, y: panel.bounds.midY - 40, width: 80, height: 80)
        imageView.isUserInteractionEnabled = true

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleImagePan(_:)))
        imageView.addGestureRecognizer(panGesture)

        panel.addSubview(imageView)
    }

    private func setBackgroundImage(image: UIImage) {
        guard let panel = contentPanel else { return }
        panel.subviews.first(where: { $0 is UIImageView })?.removeFromSuperview()
        let backgroundImageView = UIImageView(image: image)
         backgroundImageView.contentMode = .scaleAspectFill
         backgroundImageView.clipsToBounds = true
         backgroundImageView.layer.cornerRadius = 20
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

    @objc private func deleteImage(_ sender: UIButton) {
        sender.superview?.removeFromSuperview()
        print("Delete Image")
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
