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
        image = image.normalized()
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
        // Bubble
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

        // Pan gesture
        let pan = UIPanGestureRecognizer(target: self, action: #selector(dragBubble(_:)))
        colorPreview.addGestureRecognizer(pan)

        // Label
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

        // Save button
        saveButton = UIButton(type: .system)
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        saveButton.layer.cornerRadius = 10
        saveButton.frame = CGRect(x: colorPreview.frame.maxX + 5, y: colorPreview.frame.minY, width: 50, height: 30)
        saveButton.addTarget(self, action: #selector(saveColorTapped), for: .touchUpInside)
        view.addSubview(saveButton)

        // Initial color
        updateBubbleColor(at: colorPreview.center)
    }

    @objc private func dragBubble(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)

        colorPreview.center.x += translation.x
        colorPreview.center.y += translation.y
        gesture.setTranslation(.zero, in: view)

        colorInfoLabel.center = CGPoint(x: colorPreview.center.x, y: colorPreview.center.y + 40)
        saveButton.frame.origin = CGPoint(x: colorPreview.frame.maxX + 5, y: colorPreview.frame.minY)

        let pointInView = colorPreview.center
        updateBubbleColor(at: pointInView)
    }

    private func updateBubbleColor(at point: CGPoint) {
        if let color = image.color(at: point, in: imageView) {
            colorPreview.backgroundColor = color
            let hex = colorToHex(color)
            selectedHex = hex
            colorInfoLabel.text = "\(hex)"
        } else {
            colorPreview.backgroundColor = .clear
            colorInfoLabel.text = "Out of bounds"
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

    private func colorToHex(_ color: UIColor) -> String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }

    private func colorToRGBString(_ color: UIColor) -> String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "RGB(%d, %d, %d)", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}

extension UIImage {
    func color(at viewPoint: CGPoint, in imageView: UIImageView) -> UIColor? {
        guard let cgImage = self.cgImage else { return nil }
        let displayedFrame = UIImage.displayedImageFrame(for: self, in: imageView)

        guard displayedFrame.contains(viewPoint) else { return nil }

        let normalizedX = (viewPoint.x - displayedFrame.origin.x) / displayedFrame.size.width
        let normalizedY = (viewPoint.y - displayedFrame.origin.y) / displayedFrame.size.height

        let pixelX = Int(normalizedX * CGFloat(cgImage.width))
        let pixelY = Int((1 - normalizedY) * CGFloat(cgImage.height))

        guard pixelX >= 0, pixelY >= 0,
              pixelX < cgImage.width, pixelY < cgImage.height else { return nil }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var pixelData = [UInt8](repeating: 0, count: 4)

        guard let context = CGContext(
            data: &pixelData,
            width: 1,
            height: 1,
            bitsPerComponent: 8,
            bytesPerRow: 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }

        context.translateBy(x: -CGFloat(pixelX), y: -CGFloat(pixelY))
        context.draw(cgImage, in: CGRect(origin: .zero, size: CGSize(width: cgImage.width, height: cgImage.height)))

        return UIColor(
            red: CGFloat(pixelData[0]) / 255.0,
            green: CGFloat(pixelData[1]) / 255.0,
            blue: CGFloat(pixelData[2]) / 255.0,
            alpha: CGFloat(pixelData[3]) / 255.0
        )
    }

    static func displayedImageFrame(for image: UIImage, in imageView: UIImageView) -> CGRect {
        let viewSize = imageView.bounds.size
        let imageSize = image.size

        let imageRatio = imageSize.width / imageSize.height
        let viewRatio = viewSize.width / viewSize.height

        if imageRatio > viewRatio {
            let scale = viewSize.width / imageSize.width
            let height = imageSize.height * scale
            let y = (viewSize.height - height) / 2
            return CGRect(x: 0, y: y, width: viewSize.width, height: height)
        } else {
            let scale = viewSize.height / imageSize.height
            let width = imageSize.width * scale
            let x = (viewSize.width - width) / 2
            return CGRect(x: x, y: 0, width: width, height: viewSize.height)
        }
    }

    func normalized() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(origin: .zero, size: self.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return normalizedImage
    }
}
