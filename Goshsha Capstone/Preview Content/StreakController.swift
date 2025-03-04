//
//  StreakController.swift
//  Goshsha Capstone
//
//  Created by Dingxin Tao on 11/13/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class StreakController: UIViewController {
    
    var streakNum: Int = 0
    let db = Firestore.firestore()
    private var hasIncrementedToday = false
    private let containerView = UIView()

    private let streakLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 24)
        return label
    }()
    
    private let incrementButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Increase Streak", for: .normal)
        button.addTarget(self, action: #selector(increaseStreakTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clear
        
        setupPopWindowStyle()
        setupDismissGesture()
        setupLayout()
        streakLabel.text = "Current Streak: \(streakNum)"
        
        loadStreakNumAndStatus()
        containerView.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.3) {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            self.containerView.alpha = 1
        }
    }
    
    private func setupPopWindowStyle() {
        
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true
        view.addSubview(containerView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalToConstant: 300),
            containerView.heightAnchor.constraint(equalToConstant: 200),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupLayout() {
        view.addSubview(streakLabel)
        view.addSubview(incrementButton)
        
        streakLabel.translatesAutoresizingMaskIntoConstraints = false
        incrementButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            streakLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            streakLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            
            incrementButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            incrementButton.topAnchor.constraint(equalTo: streakLabel.bottomAnchor, constant: 20)
        ])
    }
    
    private func loadStreakNumAndStatus() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let users = db.collection("users").document(uid)
        users.getDocument { [weak self] document, error in
            if let error = error {
                print("Error loading streak_num: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists,
               let streakNum = document.get("streak_num") as? Int,
               let streakStatus = document.get("streak_status") as? Bool,
               let lastStreakDate = document.get("last_streak_date") as? String {
                
                let todayDate = self?.getCurrentDateString() ?? ""
                let yesterdayDate = self?.getYesterdayDateString() ?? ""
                
                self?.streakNum = streakNum
                self?.streakLabel.text = "Current Streak: \(streakNum)"
                
                //if user didn't increase yesterday or today, reset streak_num
                if lastStreakDate != yesterdayDate && lastStreakDate != todayDate {
                    users.updateData([
                        "streak_num": 0,
                        "streak_status": false
                    ]) { error in
                        if let error = error {
                            print("Error resetting streak: \(error.localizedDescription)")
                        } else {
                            print("Streak reset due to missed day.")
                        }
                    }
                    self?.streakNum = 0
                    self?.streakLabel.text = "Current Streak: 0"
                    self?.incrementButton.isEnabled = true
                    self?.incrementButton.setTitle("Increase Streak", for: .normal)
                } else {
                    // If haven't increase but fulfill the condition
                    if !streakStatus && (lastStreakDate == yesterdayDate || lastStreakDate == todayDate) {
                        self?.incrementButton.isEnabled = true
                        self?.incrementButton.setTitle("Increase Streak", for: .normal)
                    } else {
                        // If already increase streak
                        self?.incrementButton.isEnabled = false
                        self?.incrementButton.setTitle("Already Signed In Today", for: .disabled)
                    }
                    self?.streakNum = streakNum
                    self?.streakLabel.text = "Current Streak: \(streakNum)"
                }
            } else {
                print("Streak number or last_streak_date not found in database.")
            }
        }
    }
    
    @objc private func increaseStreakTapped() {
        guard !hasIncrementedToday, let uid = Auth.auth().currentUser?.uid else { return }
        
        let users = db.collection("users").document(uid)
        users.updateData([
            "streak_num": streakNum + 1,
            "last_streak_date": getCurrentDateString(),
            "streak_status": true
        ]) { [weak self] error in
            if let error = error {
                print("Error updating streak: \(error.localizedDescription)")
            } else {
                self?.streakNum += 1
                self?.streakLabel.text = "Current Streak: \(self?.streakNum ?? 0)"
                self?.incrementButton.isEnabled = false
                self?.incrementButton.setTitle("Already Signed In Today", for: .disabled)
                print("Streak increased successfully!")
            }
        }
    }
    
    private func getCurrentDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: Date())
    }
    
    private func getYesterdayDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else {
            return ""
        }
        return dateFormatter.string(from: yesterday)
    }

    
    private func setupDismissGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissIfTappedOutside))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissIfTappedOutside(_ sender: UITapGestureRecognizer) {
        let loc = sender.location(in:view)
        
        if !containerView.frame.contains(loc) {
            UIView.animate(withDuration: 0.3, animations: {
                self.view.backgroundColor = UIColor.clear
                self.containerView.alpha = 0
            }) { _ in
                self.dismiss(animated:true, completion: nil)
            }
            
        }
    }
}
