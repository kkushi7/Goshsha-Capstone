//
//  ChatbotViewController.swift
//  Goshsha Capstone
//
//  Created by Amber Chang on 2/26/25.
//

import UIKit
import FirebaseStorage

class ChatbotViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var helpBox: UIView?
    var findMatch: Bool = false
    var buyProduct: Bool = false
    private var baseHexColor: String?
    private var selectedMatchView: ScrapbookImageView?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        // Blur effect
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        
        // Dismiss chatbot on outside tap
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissChatbot)))
        
        // Goshi Image
        let goshiImageView = UIImageView(image: UIImage(named: "goshi"))
        goshiImageView.translatesAutoresizingMaskIntoConstraints = false
        goshiImageView.contentMode = .scaleAspectFit
        view.addSubview(goshiImageView)

        // Help Box
        helpBox = UIView()
        helpBox?.backgroundColor = UIColor(white: 0.9, alpha: 1)
        helpBox?.layer.cornerRadius = 10
        helpBox?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(helpBox!)

        // Initial message with buttons
        updateHelpBox(
            with: "Hi! What can I help you with?",
            fontSize: 18,
            buttons: [
                ("Find my match", #selector(findMatchTapped)),
                ("Buy a product", #selector(buyProductTapped))
            ]
        )

        // Constraints
        NSLayoutConstraint.activate([
            helpBox!.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            helpBox!.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            helpBox!.widthAnchor.constraint(equalToConstant: 300),
            helpBox!.heightAnchor.constraint(equalToConstant: 200),

            goshiImageView.bottomAnchor.constraint(equalTo: helpBox!.topAnchor),
            goshiImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            goshiImageView.widthAnchor.constraint(equalToConstant: 300),
            goshiImageView.heightAnchor.constraint(equalToConstant: 300),
        ])
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)

        if let image = info[.originalImage] as? UIImage {
            // Present color selection for face image
            presentColorSelection(for: image) { hex in
                self.baseHexColor = hex
                self.startImageSelectionFlow()
            }
        }
    }
    
    private func presentColorSelection(for image: UIImage, completion: @escaping (String) -> Void) {
        let vc = ColorSelectionViewController()
        vc.image = image
        vc.onColorSelected = completion
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func restartCameraFlow() {
        self.presentCameraForBaseTone()
    }
    
    private func startImageSelectionFlow() {
        updateHelpBox(
            with: "Select try-ons of similar products",
            fontSize: 18
        )
        
        // Delay to allow text update to render
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            let findMatchVC = FindMatchViewController()
            findMatchVC.modalPresentationStyle = .fullScreen

            findMatchVC.onMatchAnalysisComplete = { hex1, hex2, view1, view2 in
                self.shadeAnalyzeBot(hex1: hex1, hex2: hex2, view1: view1, view2: view2)
            }

            self.present(findMatchVC, animated: true)
        }
    }

    @objc private func dismissChatbot() {
        if !findMatch {
            dismiss(animated: true)
        } else if !buyProduct {
            buyProduct = true
        } else {
            updateHelpBox(
                with: "Would you like to buy this product?",
                fontSize: 18,
                buttons: [
                    ("YES! PLEASE!", #selector(buyConfirmedTapped)),
                    ("No Thank you!", #selector(buyDeclined))
                ]
            )
        }
    }
    
    @objc private func buyConfirmedTapped() {
        guard let imageView = selectedMatchView else {
            print("Error: No selected image to confirm.")
            return
        }
        buyConfirmed(for: imageView)
    }

    @objc private func findMatchTapped() {
        updateHelpBox(with: "Shore-ly! I can do that for you", fontSize: 30)
        findMatch = true
        
        // auto move on after 1.5s
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.presentCameraForBaseTone()
        }
    }

    @objc private func buyProductTapped() {
        updateHelpBox(with: "Let me find that for you!", fontSize: 30)
    }

    @objc private func buyConfirmed(for imageView: ScrapbookImageView) {
        updateHelpBox(with: "Great! Redirecting you now...", fontSize: 26)

        guard let image = imageView.image,
              let imageData = image.jpegData(compressionQuality: 0.9) else {
            print("Missing image data")
            return
        }

        let filename = "\(UUID().uuidString).jpg"
        let storageRef = Storage.storage().reference().child(filename)

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        // Upload to root
        storageRef.putData(imageData, metadata: metadata) { _, error in
            if let error = error {
                print("Upload error:", error.localizedDescription)
                return
            }

            // Get download URL
            storageRef.downloadURL { url, error in
                guard let url = url else {
                    print("Failed to get download URL:", error?.localizedDescription ?? "")
                    return
                }

                // Use for Google Lens
                self.getRelatedProducts(url: url.absoluteString)

                // Delete after a delay to let Google Lens process
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    storageRef.delete { error in
                        if let error = error {
                            print("Failed to delete uploaded image:", error.localizedDescription)
                        } else {
                            print("Temporary image deleted successfully.")
                        }
                    }
                }
            }
        }
    }

    @objc private func buyDeclined() {
        dismiss(animated: true, completion: nil)
    }
    
    // able to put any link from products
    private func getRelatedProducts(url: String){
        GoogleLensService.searchWithGoogleLens(url: url) { result in
            switch result {
            case .success(let data):
                print("Search success:", data)

                if let dict = data as? [String: Any],
                   let visualMatches = dict["visual_matches"] as? [[String: Any]] {

                    let results = visualMatches.compactMap { match -> LensResult? in
                        if let imageUrl = match["image"] as? String,
                           let linkUrl = match["link"] as? String {
                            return LensResult(imageUrl: imageUrl, linkUrl: linkUrl)
                        } else {
                            return nil
                        }
                    }

                    DispatchQueue.main.async {
                        let resultsVC = GoogleLensResultViewController()
                        resultsVC.results = results
                        resultsVC.modalPresentationStyle = .fullScreen
                        self.present(resultsVC, animated: true)
                    }
                } else {
                    print("No visual matches found!")
                }

            case .failure(let error):
                print("Search failed:", error)
            }
        }
    }

    private func shadeAnalyzeBot(hex1: String, hex2: String, view1: ScrapbookImageView, view2: ScrapbookImageView) {
        let base = baseHexColor ?? "#C68642"
        let diff1 = hexColorDifference(hex1, base)
        let diff2 = hexColorDifference(hex2, base)

        let betterView = diff1 < diff2 ? view1 : view2
        self.selectedMatchView = betterView

        let better = diff1 < diff2 ? "first" : "second"
        updateHelpBox(with: "Between these two, I think the \(better) one is your tidal match!", fontSize: 26)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            self.presentingViewController?.dismiss(animated: true)
        }
    }

    private func presentFindMatch() {
        let findMatchVC = FindMatchViewController()
        findMatchVC.modalPresentationStyle = .fullScreen

        // Set the callback to analyze and update bot
        findMatchVC.onMatchAnalysisComplete = { hex1, hex2, view1, view2 in
            self.shadeAnalyzeBot(hex1: hex1, hex2: hex2, view1: view1, view2: view2)
        }
        present(findMatchVC, animated: true)
    }
    
    private func presentCameraForBaseTone() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }

    private func hexColorDifference(_ hex1: String, _ hex2: String) -> Int {
        func hexToRGB(_ hex: String) -> (r: Int, g: Int, b: Int)? {
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

        guard let rgb1 = hexToRGB(hex1), let rgb2 = hexToRGB(hex2) else { return Int.max }

        let distance = sqrt(
            pow(CGFloat(rgb1.r - rgb2.r), 2) +
            pow(CGFloat(rgb1.g - rgb2.g), 2) +
            pow(CGFloat(rgb1.b - rgb2.b), 2)
        )

        return Int(distance.rounded())
    }

    private func updateHelpBox(with text: String, fontSize: CGFloat, buttons: [(String, Selector)] = []) {
        helpBox?.subviews.forEach { $0.removeFromSuperview() }
        
        let helpLabel = UILabel()
        helpLabel.text = text
        helpLabel.textAlignment = .center
        helpLabel.font = UIFont.systemFont(ofSize: fontSize)
        helpLabel.numberOfLines = 0
        helpLabel.translatesAutoresizingMaskIntoConstraints = false
        helpBox?.addSubview(helpLabel)

        var constraints: [NSLayoutConstraint] = [
            helpLabel.centerXAnchor.constraint(equalTo: helpBox!.centerXAnchor),
            helpLabel.topAnchor.constraint(equalTo: helpBox!.topAnchor, constant: 20),
            helpLabel.leadingAnchor.constraint(equalTo: helpBox!.leadingAnchor, constant: 16),
            helpLabel.trailingAnchor.constraint(equalTo: helpBox!.trailingAnchor, constant: -16),
        ]

        var previousButton: UIButton?
        for (title, action) in buttons {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.layer.cornerRadius = 10
            button.backgroundColor = .white
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: action, for: .touchUpInside)
            helpBox?.addSubview(button)
            
            constraints.append(contentsOf: [
                button.leadingAnchor.constraint(equalTo: helpBox!.leadingAnchor, constant: 20),
                button.trailingAnchor.constraint(equalTo: helpBox!.trailingAnchor, constant: -20),
                button.heightAnchor.constraint(equalToConstant: 40)
            ])
            
            if let previous = previousButton {
                constraints.append(button.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 10))
            } else {
                constraints.append(button.topAnchor.constraint(equalTo: helpLabel.bottomAnchor, constant: 20))
            }
            
            previousButton = button
        }

        if let lastButton = previousButton {
            constraints.append(lastButton.bottomAnchor.constraint(equalTo: helpBox!.bottomAnchor, constant: -20))
        } else {
            constraints.append(helpLabel.bottomAnchor.constraint(equalTo: helpBox!.bottomAnchor, constant: -20))
        }

        NSLayoutConstraint.activate(constraints)
    }
}
