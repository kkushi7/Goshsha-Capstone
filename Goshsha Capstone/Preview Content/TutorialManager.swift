//
//  TutorialManager.swift
//  Goshsha Capstone
//
//  Created by Yu-Shin Chang and Kushi Kumbagowdanaon on 5/16/25.
//

import UIKit

struct TutorialStep {
    let title: String
    let description: String
    let targetView: UIView?
}

class TutorialManager {
    private var steps: [TutorialStep]
    private var currentIndex = 0
    private weak var parentView: UIView?
    private var currentOverlay: UIView?
    private var currentBubble: UIView?
    private let tutorialKey: String

    init(steps: [TutorialStep], tutorialKey: String) {
        self.steps = steps
        self.tutorialKey = tutorialKey
    }

    func start(in parentView: UIView) {
        guard !UserDefaults.standard.bool(forKey: tutorialKey) else { return }
        self.parentView = parentView
        showStep()
    }

    private func showStep() {
        guard let parentView = parentView, currentIndex < steps.count else {
            cleanup()
            return
        }

        let step = steps[currentIndex]
        let targetFrame = step.targetView?.convert(step.targetView!.bounds, to: parentView)

        // Overlay
        let overlayView = UIView(frame: parentView.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlayView.isUserInteractionEnabled = true
        parentView.addSubview(overlayView)
        currentOverlay = overlayView

        // Bubble
        let bubble = createBubble(for: step)
        overlayView.addSubview(bubble)
        currentBubble = bubble

        if let frame = targetFrame {
            let spotlight = UIView(frame: frame)
            spotlight.layer.cornerRadius = 12
            spotlight.layer.borderColor = UIColor.white.cgColor
            spotlight.layer.borderWidth = 2
            spotlight.backgroundColor = .clear
            overlayView.addSubview(spotlight)
            positionBubble(over: frame)
        } else {
            centerBubble()
        }
    }

    private func createBubble(for step: TutorialStep) -> UIView {
        let bubble = UIView()
        bubble.backgroundColor = UIColor(red: 1, green: 0.937, blue: 0.702, alpha: 1) // #FFEFB3
        bubble.layer.cornerRadius = 20
        bubble.layer.borderWidth = 1
        bubble.layer.borderColor = UIColor(red: 1, green: 0.847, blue: 0.4, alpha: 1).cgColor
        bubble.layer.shadowColor = UIColor.black.cgColor
        bubble.layer.shadowOpacity = 0.2
        bubble.layer.shadowOffset = CGSize(width: 0, height: 4)
        bubble.layer.shadowRadius = 6
        bubble.translatesAutoresizingMaskIntoConstraints = false
        bubble.isUserInteractionEnabled = true

        // Title
        let titleLabel = UILabel()
        titleLabel.text = step.title
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        bubble.addSubview(titleLabel)

        // Description
        let descLabel = UILabel()
        descLabel.text = step.description
        descLabel.numberOfLines = 0
        descLabel.textAlignment = .center
        descLabel.font = UIFont.systemFont(ofSize: 16)
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        bubble.addSubview(descLabel)

        // Button
        let button = UIButton(type: .system)
        let isLastStep = currentIndex == steps.count - 1
        button.setTitle(isLastStep ? "Got it" : "Next", for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        bubble.addSubview(button)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -16),

            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            descLabel.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 16),
            descLabel.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -16),

            button.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 20),
            button.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -24),
            button.centerXAnchor.constraint(equalTo: bubble.centerXAnchor)
        ])

        return bubble
    }

    private func positionBubble(over targetFrame: CGRect) {
        guard let parent = parentView, let bubble = currentBubble else { return }
        let isTargetNearTop = targetFrame.minY < 200

        if isTargetNearTop {
            NSLayoutConstraint.activate([
                bubble.topAnchor.constraint(equalTo: parent.topAnchor, constant: targetFrame.maxY + 16),
                bubble.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 24),
                bubble.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -24)
            ])
        } else {
            NSLayoutConstraint.activate([
                bubble.bottomAnchor.constraint(equalTo: parent.topAnchor, constant: targetFrame.minY - 16),
                bubble.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 24),
                bubble.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -24)
            ])
        }
    }

    private func centerBubble() {
        guard let parent = parentView, let bubble = currentBubble else { return }

        NSLayoutConstraint.activate([
            bubble.centerXAnchor.constraint(equalTo: parent.centerXAnchor),
            bubble.centerYAnchor.constraint(equalTo: parent.centerYAnchor),
            bubble.leadingAnchor.constraint(greaterThanOrEqualTo: parent.leadingAnchor, constant: 24),
            bubble.trailingAnchor.constraint(lessThanOrEqualTo: parent.trailingAnchor, constant: -24)
        ])
    }

    @objc private func nextTapped() {
        currentBubble?.removeFromSuperview()
        currentOverlay?.removeFromSuperview()
        currentBubble = nil
        currentOverlay = nil
        currentIndex += 1
        showStep()
    }

    private func cleanup() {
        currentOverlay?.removeFromSuperview()
        currentBubble?.removeFromSuperview()
        UserDefaults.standard.set(true, forKey: tutorialKey)
    }
}
