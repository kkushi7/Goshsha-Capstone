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

class EditScrapbookViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var topToolbar: UIToolbar!
    var canvasView: UIView!
    var bottomToolbar: UIToolbar!
    var currentFont: UIFont = UIFont.systemFont(ofSize: 18)
    
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
        //loadScrapbookData()
        
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
        var texts = [[String: Any]]()
            
        for subview in canvasView.subviews {
            if let textField = subview as? UITextField, let text = textField.text {
                let textData: [String: Any] = [
                    "content": text,
                    "x": textField.frame.origin.x,
                    "y": textField.frame.origin.y,
                    "fontSize": textField.font?.pointSize ?? 18,
                    "fontName": textField.font?.fontName ?? UIFont.systemFont(ofSize: 18).fontName,
                    "color": textField.textColor?.toHexString() ?? "#000000"
                ]
                texts.append(textData)
                print(texts)
            }
        }

        let scrapbookData: [String: Any] = [
            "texts": texts,
            "photos": [],
            "stickers": []
        ]
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userDoc = db.collection("users").document(uid)
        userDoc.updateData([
            "scrapbooks": scrapbookData
        ]) { error in
            if let error = error {
                print("Error saving scrapbook: \(error.localizedDescription)")
            } else {
                print("Scrapbook saved successfully!")
            }
        }
    }
    
    @objc func exportButtonTapped() {
        print("Export button tapped")
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
        picker.dismiss(animated: true, completion: nil)
    }

    
    // add stickers
    @objc func addSticker() {
        print("Add Sticker tapped")
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
        sender.superview?.removeFromSuperview()
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


