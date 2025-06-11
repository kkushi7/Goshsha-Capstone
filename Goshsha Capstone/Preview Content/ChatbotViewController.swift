//
//  ChatbotViewController.swift
//  Goshsha Capstone
//
//  Created by Yu-Shin Chang and Kushi Kumbagowdanaon on 2/26/25.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

class ChatbotViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - UI Components
    private var helpBox: UIView?
    private var goshiImageView: UIImageView?

    // MARK: - State Flags
    private var findMatch = false
    private var buyProduct = false
    private var isShowingFinalProduct = false

    // MARK: - Constraints
    private var helpBoxBottomConstraint: NSLayoutConstraint?
    private var helpBoxTrailingConstraint: NSLayoutConstraint?
    private var goshiBottomConstraint: NSLayoutConstraint?
    private var goshiTrailingConstraint: NSLayoutConstraint?

    // MARK: - Data
    private var baseHexColor: String?
    private var selectedMatchView: ScrapbookImageView?

    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupBackground()
        setupGestureRecognizer()
        setupGoshiImage()
        setupHelpBox()
        updateHelpBox(with: "Hi! What can I help you with?", fontSize: 18, buttons: [
            ("Find my match", #selector(findMatchTapped)),
            ("Buy a product", #selector(buyProductTapped))
        ])
        setHelpBoxPositionToCorner()
    }
    
    private func setupBackground() {
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
    }

    private func setupGestureRecognizer() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissChatbot)))
    }
    
    private func setupGoshiImage() {
        let goshi = UIImageView(image: UIImage(named: "goshi"))
        goshi.translatesAutoresizingMaskIntoConstraints = false
        goshi.contentMode = .scaleAspectFit
        view.addSubview(goshi)
        goshiImageView = goshi
    }

    private func setupHelpBox() {
        helpBox = UIView()
        helpBox?.backgroundColor = UIColor(red: 1.0, green: 0.95, blue: 0.75, alpha: 1.0)
        helpBox?.layer.cornerRadius = 25
        helpBox?.layer.borderWidth = 2
        helpBox?.layer.borderColor = UIColor(red: 0.85, green: 0.65, blue: 0.0, alpha: 1.0).cgColor
        helpBox?.translatesAutoresizingMaskIntoConstraints = false
        helpBox?.clipsToBounds = true
        view.addSubview(helpBox!)
    }
    
    // MARK: - Help Box Positioning
    private func setHelpBoxPositionToCorner() {
        deactivateHelpConstraints()

        helpBoxBottomConstraint = helpBox!.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        helpBoxTrailingConstraint = helpBox!.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        goshiBottomConstraint = goshiImageView!.bottomAnchor.constraint(equalTo: helpBox!.topAnchor, constant: 16)
        goshiTrailingConstraint = goshiImageView!.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)

        NSLayoutConstraint.activate([
            helpBoxBottomConstraint!, helpBoxTrailingConstraint!,
            helpBox!.widthAnchor.constraint(equalToConstant: 300),
            goshiBottomConstraint!, goshiTrailingConstraint!,
            goshiImageView!.widthAnchor.constraint(equalToConstant: 300),
            goshiImageView!.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func setHelpBoxPositionToCenter() {
        deactivateHelpConstraints()

        helpBoxBottomConstraint = helpBox!.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 120)
        helpBoxTrailingConstraint = helpBox!.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        goshiBottomConstraint = goshiImageView!.bottomAnchor.constraint(equalTo: helpBox!.topAnchor, constant: 0)
        goshiTrailingConstraint = goshiImageView!.centerXAnchor.constraint(equalTo: view.centerXAnchor)

        NSLayoutConstraint.activate([
            helpBoxBottomConstraint!, helpBoxTrailingConstraint!,
            goshiBottomConstraint!, goshiTrailingConstraint!
        ])

        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func deactivateHelpConstraints() {
        [helpBoxBottomConstraint, helpBoxTrailingConstraint, goshiBottomConstraint, goshiTrailingConstraint].forEach { $0?.isActive = false }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            if let image = info[.originalImage] as? UIImage {
                self.setHelpBoxPositionToCorner()

                // Then show color picker
                self.presentColorSelection(for: image) { hex in
                    self.baseHexColor = hex
                    self.startImageSelectionFlow()
                }
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
        if isShowingFinalProduct {
            return // Prevent taps from doing anything
        }
        if !findMatch {
            dismiss(animated: true)
        } else if !buyProduct {
            buyProduct = true
        } else {
            showFinalSelectedImage()
            updateHelpBox(
                with: "Would you like to buy this product?",
                fontSize: 17,
                buttons: [
                    ("YES! PLEASE!", #selector(buyConfirmedTapped)),
                    ("No Thank you!", #selector(buyDeclined))
                ]
            )
        }
    }
    
    private func showFinalSelectedImage() {
        isShowingFinalProduct = true

        guard let stack = view.subviews.first(where: { $0.tag == 9999 }) as? UIStackView else { return }

        // Remove the losing image
        if stack.arrangedSubviews.count == 2 {
            let betterImage = selectedMatchView?.image
            let first = stack.arrangedSubviews[0] as? UIImageView
            let second = stack.arrangedSubviews[1] as? UIImageView

            if let first = first, let second = second {
                if first.image != betterImage {
                    stack.removeArrangedSubview(first)
                    first.removeFromSuperview()
                } else {
                    stack.removeArrangedSubview(second)
                    second.removeFromSuperview()
                }
            }
        }

        // Adjust the stack layout to center the remaining image
        stack.axis = .vertical
        stack.spacing = 0
        stack.distribution = .fill
        stack.alignment = .center

        // Optionally resize the image slightly if desired
        if let imageView = stack.arrangedSubviews.first as? UIImageView {
            imageView.layer.borderWidth = 0

            NSLayoutConstraint.deactivate(imageView.constraints)
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 200),
                imageView.heightAnchor.constraint(equalToConstant: 240)
            ])
        }

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
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

        // Check product image count first
        checkProductImageCount { hasEnough in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if hasEnough {
                    // Proceed with tutorial flow
                    self.setHelpBoxPositionToCenter()
                    self.updateHelpBox(
                        with: "We need a photo of your face to find your perfect shade.\nPlease make sure you’re not wearing any makeup products, and are in a well-lit space.",
                        fontSize: 18,
                        buttons: [
                            ("Take Picture", #selector(self.takeBareFacePicture)),
                            ("Cancel", #selector(self.cancelBareFaceFlow))
                        ]
                    )
                } else {
                    self.setHelpBoxPositionToCenter()
                    self.goshiImageView?.image = UIImage(named: "goshi_thinking")
                    self.updateHelpBox(
                        with: "No Products to Analyze\n\nYou don’t have enough pictures of products in your Try-On Room yet. Add at least two PRODUCT images to compare shades and find your match. No images of your face!",
                        fontSize: 17,
                        buttons: [
                            ("Go to Try-On Page", #selector(self.redirectToTryOnPage)),
                            ("Cancel", #selector(self.cancelBareFaceFlow))
                        ]
                    )
                }
            }
        }
    }
    
    private func checkProductImageCount(completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }

        let db = Firestore.firestore()
        let userDocRef = db.collection("users").document(uid)

        userDocRef.getDocument { snapshot, error in
            if let error = error {
                print("Error fetching user data:", error)
                completion(false)
                return
            }

            guard let data = snapshot?.data(),
                  let scrapbook = data["scrapbooks"] as? [String: Any],
                  let photos = scrapbook["photos"] as? [[String: Any]] else {
                completion(false)
                return
            }

            completion(photos.count >= 2)
        }
    }
    
    @objc private func redirectToTryOnPage() {
        // Dismiss all presented view controllers to return to root
        if let rootVC = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            rootVC.dismiss(animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let tryonController = storyboard.instantiateViewController(withIdentifier: "TryOnWebViewController") as? TryOnWebViewController {
                        let navController = UINavigationController(rootViewController: tryonController)
                        navController.modalPresentationStyle = .fullScreen
                        rootVC.present(navController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @objc private func takeBareFacePicture() {
        setHelpBoxPositionToCorner()
        presentCameraForBaseTone()
    }

    @objc private func cancelBareFaceFlow() {
        setHelpBoxPositionToCorner()
        dismiss(animated: true)
    }

    @objc private func buyProductTapped() {
        updateHelpBox(with: "Let me find that for you!", fontSize: 30)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.redirectToTryOnPage()
        }
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
        GoogleLensService.searchWithGoogleLens(imageURL: url) { result in
            switch result {
            case .success(let data):
                print("Search success:", data)

                if let dict = data as? [String: Any],
                   let visualMatches = dict["visual_matches"] as? [[String: Any]] {

                    let results = visualMatches.compactMap { match -> LensResult? in
                        if let imageUrl = match["image"] as? String,
                           let linkUrl = match["link"] as? String,
                           let title = match["title"] as? String,
                           let source = match["source"] as? String {
                            
                            return LensResult(imageUrl: imageUrl, linkUrl: linkUrl, title: title, source: source)
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
                    DispatchQueue.main.async {
                        self.updateHelpBox(
                            with: "Oh no, looks like no products were found. Make sure you’re using clear product images. Would you like to try selecting two images again?",
                            fontSize: 17,
                            buttons: [
                                ("Yes, try again", #selector(self.retryImageSelection)),
                                ("No", #selector(self.dismissAfterPause))
                            ]
                        )
                        self.setHelpBoxPositionToCenter()
                    }
                }

            case .failure(let error):
                print("Search failed:", error)
            }
        }
    }
    
    @objc private func retryImageSelection() {
        setHelpBoxPositionToCorner()
        
        let findMatchVC = FindMatchViewController()
        findMatchVC.modalPresentationStyle = .fullScreen
        findMatchVC.onMatchAnalysisComplete = { hex1, hex2, view1, view2 in
            self.shadeAnalyzeBot(hex1: hex1, hex2: hex2, view1: view1, view2: view2)
        }
        self.present(findMatchVC, animated: true)
    }

    @objc private func dismissAfterPause() {
        self.updateHelpBox(with: "Alright, closing the assistant...", fontSize: 17)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dismiss(animated: true)
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
        showComparisonImages(image1: view1.image, image2: view2.image, highlightFirst: diff1 < diff2)
        self.isShowingFinalProduct = false
    }
    
    private func showComparisonImages(image1: UIImage?, image2: UIImage?, highlightFirst: Bool) {
        guard let image1 = image1, let image2 = image2 else { return }

        // Remove existing image preview
        view.subviews.filter { $0.tag == 9999 }.forEach { $0.removeFromSuperview() }

        let container = UIStackView()
        container.axis = .horizontal
        container.spacing = 16
        container.distribution = .fillEqually
        container.translatesAutoresizingMaskIntoConstraints = false
        container.tag = 9999
        view.addSubview(container)

        let imageView1 = UIImageView(image: image1)
        let imageView2 = UIImageView(image: image2)

        [imageView1, imageView2].forEach {
            $0.contentMode = .scaleAspectFit
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 12
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.black.cgColor
            $0.heightAnchor.constraint(equalToConstant: 280).isActive = true
        }

        // Emphasize the winner
        if highlightFirst {
            imageView1.layer.borderWidth = 5
        } else {
            imageView2.layer.borderWidth = 5
        }

        container.addArrangedSubview(imageView1)
        container.addArrangedSubview(imageView2)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.widthAnchor.constraint(equalToConstant: 350),
            container.heightAnchor.constraint(equalToConstant: 300)
        ])

        if let goshi = goshiImageView, let help = helpBox {
            view.bringSubviewToFront(goshi)
            view.bringSubviewToFront(help)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            self.presentingViewController?.dismiss(animated: true)
        }
    }
    
    private func presentCameraForBaseTone() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self

        if UIImagePickerController.isCameraDeviceAvailable(.front) {
            picker.cameraDevice = .front
        }

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
        helpLabel.textColor = .black
        helpLabel.textAlignment = .center
        helpLabel.font = UIFont.systemFont(ofSize: fontSize)
        helpLabel.numberOfLines = 0
        helpLabel.translatesAutoresizingMaskIntoConstraints = false
        helpLabel.setContentHuggingPriority(.required, for: .vertical)
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
            button.layer.cornerRadius = 10
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: action, for: .touchUpInside)
            if title == "Go to Try-On Page" || title == "Take Picture" {
                button.setTitleColor(.white, for: .normal)
                button.backgroundColor = .systemBlue
            } else {
                button.setTitleColor(.black, for: .normal)
                button.backgroundColor = .white
                button.layer.borderWidth = 1
                button.layer.borderColor = UIColor.black.cgColor
            }
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

extension UIApplication {
    static func getTopViewController(base: UIViewController? =
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return getTopViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}
