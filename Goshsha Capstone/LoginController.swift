//
//  LoginController.swift
//  Goshsha Capstone
//
//  Created by Dingxin Tao on 11/13/24.
//

import UIKit
import FirebaseAuth

class LoginController: UIViewController {
    
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
                // New account created and signed in
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // Show error messages
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
