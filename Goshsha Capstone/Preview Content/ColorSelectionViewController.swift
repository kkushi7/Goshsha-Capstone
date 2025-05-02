//
//  ColorSelectionViewController.swift
//  Goshsha Capstone
//
//  Created by Amber Chang on 5/1/25.
//

import UIKit

class ColorSelectionViewController: UIViewController {

    var image: UIImage!
    var onColorSelected: ((String) -> Void)?

    private var imageView: UIImageView!
    private var colorPreview: UIView!
    private var colorInfoLabel: UILabel!
    private var saveButton: UIButton!
    private var selectedHex: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupImageView()
        setupEyedropper()
    }

    private func setupImageView() {
        imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = view.bounds
        imageView.isUserInteractionEnabled = false
        view.addSubview(imageView)
    }

    private func setupEyedropper() {
        // Create the bubble
        colorPreview = UIView(frame: CGRect(x: view.center.x, y: view.center.y, width: 40, height: 40))
        colorPreview.layer.cornerRadius = 20
        colorPreview.layer.borderColor = UIColor.white.cgColor
        colorPreview.layer.borderWidth = 2
        colorPreview.layer.shadowColor = UIColor.black.cgColor
        colorPreview.layer.shadowOpacity = 0.3
        colorPreview.layer.shadowRadius = 4
        colorPreview.backgroundColor = .clear
        colorPreview.isUserInteractionEnabled = true
        view.addSubview(colorPreview)

        // Drag gesture
        let pan = UIPanGestureRecognizer(target: self, action: #selector(dragBubble(_:)))
        colorPreview.addGestureRecognizer(pan)

        // Color label
        colorInfoLabel = UILabel()
        colorInfoLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        colorInfoLabel.textColor = .white
        colorInfoLabel.textAlignment = .center
        colorInfoLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        colorInfoLabel.layer.cornerRadius = 6
        colorInfoLabel.layer.masksToBounds = true
        colorInfoLabel.numberOfLines = 2
        colorInfoLabel.frame = CGRect(x: colorPreview.frame.origin.x - 40, y: colorPreview.frame.maxY + 5, width: 80, height: 40)
        view.addSubview(colorInfoLabel)

        // Save button attached to the bubble
        saveButton = UIButton(type: .system)
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        saveButton.layer.cornerRadius = 10
        saveButton.frame = CGRect(x: colorPreview.frame.maxX + 5, y: colorPreview.frame.minY, width: 50, height: 30)
        saveButton.addTarget(self, action: #selector(saveColorTapped), for: .touchUpInside)
        view.addSubview(saveButton)

        // Start with initial color
        updateBubbleColor(at: colorPreview.center)
    }

    @objc private func dragBubble(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)

        // Move the bubble
        colorPreview.center.x += translation.x
        colorPreview.center.y += translation.y
        gesture.setTranslation(.zero, in: view)

        // Move label and button with it
        colorInfoLabel.center = CGPoint(x: colorPreview.center.x, y: colorPreview.center.y + 40)
        saveButton.frame.origin = CGPoint(x: colorPreview.frame.maxX + 5, y: colorPreview.frame.minY)

        // Update color
        let pointInImage = view.convert(colorPreview.center, to: imageView)
        updateBubbleColor(at: pointInImage)
    }

    private func updateBubbleColor(at point: CGPoint) {
        guard let image = imageView.image else { return }
        if let color = getPixelColor(from: image, at: point, in: imageView) {
            colorPreview.backgroundColor = color
            let hex = colorToHex(color)
            selectedHex = hex
            colorInfoLabel.text = "\(hex)\n\(colorToRGBString(color))"
        }
    }

    @objc private func saveColorTapped() {
        guard let hex = selectedHex else { return }

        let alert = UIAlertController(title: "Color Saved!", message: hex, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            alert.dismiss(animated: true) {
                self.dismiss(animated: true) {
                    self.onColorSelected?(hex)
                }
            }
        }
    }

    private func getPixelColor(from image: UIImage, at point: CGPoint, in imageView: UIImageView) -> UIColor? {
        guard let cgImage = image.cgImage else { return nil }

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
}
