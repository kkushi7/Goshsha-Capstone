//
//  ChatbotViewController.swift
//  Goshsha Capstone
//
//  Created by Amber Chang on 2/26/25.
//

import UIKit

class ChatbotViewController: UIViewController {
    
    var helpBox: UIView?
    var findMatch: Bool = false
    var buyProduct: Bool = false

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

    @objc private func dismissChatbot() {
        if !findMatch {
            dismiss(animated: true)
        } else if !buyProduct {
            presentFindMatch()
            shadeAnalyzeBot()
            buyProduct = true
        } else {
            updateHelpBox(
                with: "Would you like to buy this product?",
                fontSize: 18,
                buttons: [
                    ("YES! PLEASE!", #selector(buyConfirmed)),
                    ("No Thank you!", #selector(buyDeclined))
                ]
            )
        }
    }

    @objc private func findMatchTapped() {
        updateHelpBox(with: "Shore-ly! I can do that for you", fontSize: 30)
        findMatch = true
    }

    @objc private func buyProductTapped() {
        updateHelpBox(with: "Let me find that for you!", fontSize: 30)
    }

    @objc private func buyConfirmed() {
        updateHelpBox(with: "Great! Redirecting you now...", fontSize: 26)
    }

    @objc private func buyDeclined() {
        dismiss(animated: true, completion: nil)
    }

    private func shadeAnalyzeBot() {
        updateHelpBox(with: "Between these two, I think the second one is your tidal match!", fontSize: 26)
    }

    private func presentFindMatch() {
        let findMatchVC = FindMatchViewController()
        findMatchVC.modalPresentationStyle = .fullScreen
        present(findMatchVC, animated: true)
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
