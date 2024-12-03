//
//  LoginController.swift
//  Goshsha Capstone
//
//  Created by Dingxin Tao on 11/13/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginController: UIViewController {
    
    let db = Firestore.firestore();
    var backButtonToolbar: UIToolbar!
    
    // UI for email and password input
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your email"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private let signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign In / Register", for: .normal)
        button.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupLayout()
        setupbackButtonToolbar()
        backButtonToolbar.barTintColor = .white
    }
    
    private func setupLayout() {
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(signInButton)
        
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            emailTextField.widthAnchor.constraint(equalToConstant: 250),
            
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.widthAnchor.constraint(equalToConstant: 250),
            
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20)
        ])
    }
    
    private func setupbackButtonToolbar() {
        backButtonToolbar = UIToolbar()
        backButtonToolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButtonToolbar)
        
        NSLayoutConstraint.activate([
            backButtonToolbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -65),
            backButtonToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButtonToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            backButtonToolbar.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        // "back" button
        let backButton = UIBarButtonItem(image: UIImage(systemName: "arrow.backward"), style: .plain, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .blue
        
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        backButtonToolbar.setItems([backButton], animated: false)
    }
    
    @objc private func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func signInTapped() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            // Display an alert if email or password is empty
            showAlert(message: "Please enter both email and password.")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
            if let error = error as NSError? {
                // if the error is because the user doesn't have an account yet
                if error.code == AuthErrorCode.userNotFound.rawValue {
                    // Create a new account
                    self?.registerNewUser(email: email, password: password)
                } else {
                    // Show the error message
                    self?.showAlert(message: error.localizedDescription)
                }
            } else {
                // Update exist user data
                self?.saveUserData()
                // sign-in
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // Create a new user account
    private func registerNewUser(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result, error) in
            if let error = error {
                self?.showAlert(message: error.localizedDescription)
            } else {
                // Register and create user data
                self?.saveUserData()
                // New account created and signed in
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // Create user data while registering
    private func saveUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let users = db.collection("users").document(uid)
        
        users.getDocument { (document, error) in
            if let document = document, document.exists {
                print("User already exists in database.")
            } else {
                let userData: [String: Any] = [
                    "id": uid,
                    "streak_num": 0,
                    "favorites": [],
                    "last_streak_date": "",
                    "streak_status": false,
                    "scrapbooks" : []
                ]
                
                users.setData(userData) { error in
                    if let error = error {
                        print("Error saving user data: \(error.localizedDescription)")
                    } else {
                        print("User data saved successfully!")
                    }
                }
            }
        }
    }

    // Helper function to get the current date ("yyyy-MM-dd")
    private func getCurrentDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: Date())
    }
    
    // Show error messages
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
