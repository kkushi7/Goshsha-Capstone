//
//  EditScrapbookViewController.swift
//  Goshsha Capstone
//
//  Created by Dingxin Tao on 11/12/24.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import Photos

class EditScrapbookViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var topToolbar: UIToolbar!
    var canvasView: UIView!
    var bottomToolbar: UIToolbar!
    var currentFont: UIFont = UIFont.systemFont(ofSize: 18)
    var textsToDelete: [String] = []
    var photosToDelete: [String] = []
    var isShadeMatching: Bool = false
    
    let db = Firestore.firestore();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        // exit editing gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutside))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        //show user's ScrapBook name
        showScrapBookNameLabel()
        
        //set top tool bar
        setupTopToolbar()
        
        //load scrapbook from database
        loadScrapbookData()
        
        //set Scarpbook canvas
        canvasView  = setupCanvas(below: topToolbar)
        canvasView.isUserInteractionEnabled = true
        
        //set bottom tool bar
        setupBottomToolbar()
    }
    
    func showScrapBookNameLabel() {
        let label = UILabel()
        label.text = "YOUR SCRAPBOOK"
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
            
            // shade matches
            let shadeButton = UIBarButtonItem(image: UIImage(systemName: "play.circle"), style: .plain, target: self, action: #selector(shadeButtonTapped))
            shadeButton.tintColor = .blue
            
//            // color picker button
//            let colorPickerButton = UIBarButtonItem(image: UIImage(systemName: "eyedropper"), style: .plain, target: self, action: #selector(colorPickerTapped))
//            colorPickerButton.tintColor = .blue
        
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            topToolbar.setItems([flexibleSpace, textButton, flexibleSpace, photoButton, flexibleSpace, shadeButton, flexibleSpace], animated: false)
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
    
    func loadScrapbookData() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }

        let userDoc = db.collection("users").document(uid)
        
        userDoc.getDocument { [weak self] (document, error) in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching scrapbook: \(error.localizedDescription)")
                return
            }

            if let document = document, let data = document.data(),
               let scrapbook = data["scrapbooks"] as? [String: Any] {
                
                //print("Scrapbook data loaded: \(scrapbook)")
                
                // load text
                if let texts = scrapbook["texts"] as? [[String: Any]] {
                    self.loadTextFields(from: texts)
                }

                // load photo
                if let photos = scrapbook["photos"] as? [[String: Any]] {
                    self.loadPhotos(from: photos)
                }
            } else {
                print("No scrapbook data found for user")
            }
        }
    }

    func loadTextFields(from texts: [[String: Any]]) {
        for textData in texts {
            guard let content = textData["content"] as? String,
                  let x = textData["x"] as? CGFloat,
                  let y = textData["y"] as? CGFloat,
                  let fontSize = textData["fontSize"] as? CGFloat,
                  let fontName = textData["fontName"] as? String,
                  let colorHex = textData["color"] as? String,
                  let color = UIColor(hexString: colorHex) else {
                print("Invalid text data: \(textData)")
                continue
            }

            let textField = UITextField()
            textField.text = content
            textField.textColor = color
            textField.font = UIFont(name: fontName, size: fontSize)
            textField.backgroundColor = .clear
            textField.textAlignment = .center
            textField.frame = CGRect(x: x, y: y, width: 200, height: 40)
            textField.isUserInteractionEnabled = true
            textField.accessibilityIdentifier = textData["id"] as? String ?? UUID().uuidString

            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
            textField.addGestureRecognizer(panGesture)

            let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
            textField.addGestureRecognizer(pinchGesture)

            let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotationGesture(_:)))
            textField.addGestureRecognizer(rotationGesture)

            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
            textField.addGestureRecognizer(longPressGesture)

            canvasView.addSubview(textField)
        }
    }

    func loadPhotos(from photoData: [[String: Any]]) {
        for photo in photoData {
            guard let urlString = photo["url"] as? String,
                  let url = URL(string: urlString),
                  let x = photo["x"] as? CGFloat,
                  let y = photo["y"] as? CGFloat,
                  let scaleX = photo["scaleX"] as? CGFloat,
                  let scaleY = photo["scaleY"] as? CGFloat,
                  let rotation = photo["rotation"] as? CGFloat else {
                print("Invalid photo data: \(photo)")
                continue
            }

            URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let self = self, let data = data, error == nil,
                      let image = UIImage(data: data) else { return }

                DispatchQueue.main.async {
                    let imageView = UIImageView(image: image)
                    imageView.isUserInteractionEnabled = true
                    imageView.contentMode = .scaleAspectFit
                    imageView.frame = CGRect(x: x, y: y, width: 200, height: 200)
                    imageView.transform = CGAffineTransform.identity
                        .scaledBy(x: scaleX, y: scaleY)
                        .rotated(by: rotation)
                    imageView.accessibilityIdentifier = photo["id"] as? String ?? UUID().uuidString
                    
                    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(_:)))
                    imageView.addGestureRecognizer(panGesture)

                    let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.handlePinchGesture(_:)))
                    imageView.addGestureRecognizer(pinchGesture)

                    let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(self.handleRotationGesture(_:)))
                    imageView.addGestureRecognizer(rotationGesture)

                    let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPressGesture(_:)))
                    imageView.addGestureRecognizer(longPressGesture)
                    
                    self.canvasView.addSubview(imageView)
                }
            }.resume()
        }
    }
    
    @objc func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func saveButtonTapped() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }

        let userDoc = db.collection("users").document(uid)
        
        // delete what should be deleted first, then update rest data
        var deleteTasks = photosToDelete.count
        for photoID in photosToDelete {
            removeFromDatabase(withIdentifier: photoID)
            deleteTasks -= 1
        }
        
        // delete original photo
        if deleteTasks == 0 {
            userDoc.getDocument { [weak self] (document, error) in
                guard let self = self else { return }

                if let error = error {
                    print("Error fetching scrapbook: \(error.localizedDescription)")
                    return
                }

                if let document = document, let data = document.data(),
                   let scrapbook = data["scrapbooks"] as? [String: Any],
                   let photos = scrapbook["photos"] as? [[String: Any]] {

                    for photo in photos {
                        if let urlString = photo["url"] as? String,
                           let url = URL(string: urlString) {
                            self.deletePhotoFromStorage(url: url)
                        }
                    }
                }
                
                self.uploadNewDataToFirestore()
            }
        }
    }

    func uploadNewDataToFirestore() {
        var texts = [[String: Any]]()
        var photos = [[String: Any]]()
        let imageViews = canvasView.subviews.compactMap { $0 as? UIImageView }
        var uploadTasks = imageViews.count
        
        for subview in canvasView.subviews {
            if let textField = subview as? UITextField, let text = textField.text {
                let textData: [String: Any] = [
                    "id": textField.accessibilityIdentifier ?? UUID().uuidString,
                    "content": text,
                    "x": textField.frame.origin.x,
                    "y": textField.frame.origin.y,
                    "fontSize": textField.font?.pointSize ?? 18,
                    "fontName": textField.font?.fontName ?? UIFont.systemFont(ofSize: 18).fontName,
                    "color": textField.textColor?.toHexString() ?? "#000000"
                ]
                texts.append(textData)
            } else if let imageView = subview as? UIImageView, let image = imageView.image {
                uploadPhoto(image: image) { [weak self] url in
                    guard let self = self, let downloadURL = url else { return }
                    let photoData: [String: Any] = [
                        "id": imageView.accessibilityIdentifier ?? UUID().uuidString,
                        "url": downloadURL.absoluteString,
                        "x": imageView.frame.origin.x,
                        "y": imageView.frame.origin.y,
                        "scaleX": imageView.transform.a,
                        "scaleY": imageView.transform.d,
                        "rotation": atan2(imageView.transform.b, imageView.transform.a)
                    ]
                    photos.append(photoData)
                    
                    uploadTasks -= 1
                    
                    if uploadTasks == 0 {
                        self.saveScrapbookToFirestore(texts: texts, photos: photos)
                    }
                }
            }
        }
        
        if uploadTasks == 0 {
            saveScrapbookToFirestore(texts: texts, photos: photos)
        }
    }

    
    func uploadPhoto(image: UIImage, completion: @escaping (URL?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to data")
            completion(nil)
            return
        }
        
        let storageRef = Storage.storage().reference()
        let photoRef = storageRef.child("scrapbook_photos/\(UUID().uuidString).jpg")
        
        photoRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading photo: \(error.localizedDescription)")
                completion(nil)
            } else {
                photoRef.downloadURL { url, error in
                    if let error = error {
                        print("Error fetching download URL: \(error.localizedDescription)")
                        completion(nil)
                    } else {
                        completion(url)
                    }
                }
            }
        }
    }

    
    func saveScrapbookToFirestore(texts: [[String: Any]], photos: [[String : Any]]) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let scrapbookData: [String: Any] = [
            "texts": texts,
            "photos": photos,
        ]
        
        let userDoc = db.collection("users").document(uid)
        userDoc.setData(["scrapbooks": scrapbookData], merge: true) { error in
            if let error = error {
                print("Error saving scrapbook: \(error.localizedDescription)")
            } else {
                print("Scrapbook saved successfully!")
            }
        }
    }

    func renderViewAsImage(view: UIView) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: canvasView.bounds.size)
        return renderer.image { context in
            canvasView.layer.render(in: context.cgContext)
        }
    }
    
    @objc func exportButtonTapped() {
        guard let image = renderViewAsImage(view: canvasView) else {
            print("Error rendering view as image")
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        print("Image saved to photo library")
    }
    
    // shade match
    @objc func shadeButtonTapped() {
//        print("test shade matching")
//        isShadeMatching = true
//        let imagePicker = UIImagePickerController()
//        imagePicker.sourceType = .photoLibrary
//        imagePicker.delegate = self
//        present(imagePicker, animated: true, completion: nil)
        processImageWithGoogleLens()
    }

    
    // add text
    @objc func addText() {
        let textField = UITextField()
        textField.placeholder = "Enter text..."
        textField.textColor = .black
        textField.backgroundColor = .clear
        textField.textAlignment = .center
        textField.frame = CGRect(x: 50, y: 50, width: 200, height: 40)
        textField.isUserInteractionEnabled = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        textField.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        textField.addGestureRecognizer(pinchGesture)
        
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotationGesture(_:)))
        textField.addGestureRecognizer(rotationGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
            textField.addGestureRecognizer(longPressGesture)
        
        canvasView.addSubview(textField)
    }
    
    // add photos
    @objc func addPhoto() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            if isShadeMatching {
                processImageWithGoogleLens()
            } else {
                let imageView = UIImageView(image: image)
                imageView.isUserInteractionEnabled = true
                imageView.contentMode = .scaleAspectFit
                imageView.frame = CGRect(x: 50, y: 50, width: 200, height: 200)
                
                // drag
                let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
                imageView.addGestureRecognizer(panGesture)

                // pinch(zoom in zoom out)
                let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
                imageView.addGestureRecognizer(pinchGesture)

                // rotate
                let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotationGesture(_:)))
                imageView.addGestureRecognizer(rotationGesture)
                
                let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
                imageView.addGestureRecognizer(longPressGesture)
                
                canvasView.addSubview(imageView)
            }
        }
        isShadeMatching = false
        picker.dismiss(animated: true, completion: nil)
    }
    
    // quit text editing mode
    @objc func handleTapOutside(_ gesture: UITapGestureRecognizer) {
        view.endEditing(true)
        
        for subview in canvasView.subviews {
                // check for delete buttons by their unique tag
                if let deleteButton = subview.viewWithTag(999) {
                    UIView.animate(withDuration: 0.3) {
                        deleteButton.alpha = 0
                    } completion: { _ in
                        deleteButton.removeFromSuperview()
                    }
                }
            }
    }
    
    // gesture functions
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: canvasView)
        if let view = gesture.view {
            view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        }
        gesture.setTranslation(.zero, in: canvasView)
    }

    @objc func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        if let view = gesture.view {
            view.transform = view.transform.scaledBy(x: gesture.scale, y: gesture.scale)
            gesture.scale = 1
        }
    }

    @objc func handleRotationGesture(_ gesture: UIRotationGestureRecognizer) {
        if let view = gesture.view {
            view.transform = view.transform.rotated(by: gesture.rotation)
            gesture.rotation = 0
        }
    }
    
    @objc func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        guard let targetView = gesture.view else { return }

        if gesture.state == .began {
            addDeleteButton(to: targetView)
        }
    }
    
    func addDeleteButton(to view: UIView) {
        if view.viewWithTag(999) != nil { return }
        
        let deleteButton = UIButton(type: .custom)
        deleteButton.setTitle("X", for: .normal)
        deleteButton.setTitleColor(.white, for: .normal)
        deleteButton.backgroundColor = .red
        deleteButton.layer.cornerRadius = 10
        deleteButton.clipsToBounds = true
        let buttonSize: CGFloat = 24 // Size of the delete button
        let padding: CGFloat = 5
        deleteButton.frame = CGRect(
                x: view.bounds.width - buttonSize - padding,
                y: padding,
                width: buttonSize,
                height: buttonSize
            )
        
        deleteButton.tag = 999
        deleteButton.addTarget(self, action: #selector(handleDeleteButton(_:)), for: .touchUpInside)

        view.addSubview(deleteButton)
    }

    @objc func handleDeleteButton(_ sender: UIButton) {
        guard let targetView = sender.superview else { return }
            
        // get targetview identifier
        guard let identifier = targetView.accessibilityIdentifier else {
            print("No identifier found for view")
            targetView.removeFromSuperview()
            return
        }
        
        // delete targetview
        targetView.removeFromSuperview()
        
        // delete data from database
        if targetView is UITextField {
            textsToDelete.append(identifier)
        } else if targetView is UIImageView {
            photosToDelete.append(identifier)
        }
    }
    
    func removeFromDatabase(withIdentifier identifier: String) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }

        let userDoc = db.collection("users").document(uid)
        
        userDoc.getDocument { [weak self] (document, error) in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching scrapbook: \(error.localizedDescription)")
                return
            }

            if let document = document, let data = document.data(),
               var scrapbook = data["scrapbooks"] as? [String: Any] {
                
                var texts = scrapbook["texts"] as? [[String: Any]] ?? []
                var photos = scrapbook["photos"] as? [[String: Any]] ?? []
                
                // delete targetview from text or photo
                texts.removeAll { $0["id"] as? String == identifier }
                
                if let photoToRemove = photos.first(where: { $0["id"] as? String == identifier }) {
                    if let urlString = photoToRemove["url"] as? String,
                       let url = URL(string: urlString) {
                        self.deletePhotoFromStorage(url: url)
                    }
                    photos.removeAll { $0["id"] as? String == identifier }
                }
                
                scrapbook["texts"] = texts
                scrapbook["photos"] = photos
                
                // update database
                userDoc.setData(["scrapbooks": scrapbook], merge: true) { error in
                    if let error = error {
                        print("Error updating scrapbook: \(error.localizedDescription)")
                    } else {
                        print("Element with identifier \(identifier) removed successfully!")
                    }
                }
            } else {
                print("No scrapbook data found for user")
            }
        }
    }
    
    func deletePhotoFromStorage(url: URL) {
        let storageRef = Storage.storage().reference(forURL: url.absoluteString)
        storageRef.delete { error in
            if let error = error {
                print("Error deleting photo from storage: \(error.localizedDescription)")
            } else {
                print("Photo deleted from storage successfully!")
            }
        }
    }
    
    func processImageWithGoogleLens() {
        GoogleLensService.searchWithGoogleLens() { result in
            DispatchQueue.main.async {
                print(result)
                switch result {
                case .success(let matches):
                    print(matches)
                case .failure(let error):
                    print("error: \(error.localizedDescription)")
                }
            }
        }
    }
}



extension UIColor {
    convenience init?(hexString: String) {
        var hex = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        hex = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        
        guard hex.count == 6 else { return nil }
        
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    func toHexString() -> String? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
        
        let r = Int(red * 255.0)
        let g = Int(green * 255.0)
        let b = Int(blue * 255.0)
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
