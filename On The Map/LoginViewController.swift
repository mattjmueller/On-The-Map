//*********************************************************
// LoginViewController.swift
// On The Map
//
// Created by Matthew Mueller on 4/19/17.
// Copyright © 2017 Matthew Mueller. All rights reserved.
//*********************************************************

import UIKit

class LoginViewController: UIViewController, ManagesLogin, AccessesStudentLocations, UITextFieldDelegate {
	//******************************************************
	// MARK: - IB Outlets
	//******************************************************
	
	@IBOutlet weak var usernameTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var loginButton: UIButton!
	@IBOutlet weak var keyboardConstraint: NSLayoutConstraint!
	
	
	//******************************************************
	// MARK: - Public Properties
	//******************************************************

	weak var udacityService: UdacityService!
	weak var studentLocationService: StudentLocationService!
	
	
	//******************************************************
	// MARK: - Life Cycle
	//******************************************************
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: .UIKeyboardWillChangeFrame, object: nil)
		configureViews()
	}

	override func viewWillDisappear(_ animated: Bool) {
		NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillChangeFrame, object: nil)
	}

	
	//******************************************************
	// MARK: - Helpers
	//******************************************************
	
	func configureViews() {
		usernameTextField.attributedPlaceholder = NSAttributedString(string: usernameTextField.placeholder ?? "", attributes: [NSForegroundColorAttributeName: UIColor.white])
		passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordTextField.placeholder ?? "", attributes: [NSForegroundColorAttributeName: UIColor.white])
		usernameTextField.text = ""
		passwordTextField.text = ""
		loginButton.isEnabled = validateCredentials(username: usernameTextField.text, password: passwordTextField.text)
	}
	
	func validateCredentials(username: String?, password: String?) -> Bool {
		guard let username = username, let password = password else {
			return false
		}
		return !(username.isEmpty || password.isEmpty)
	}
	
	func showAlert(message: String) {
		print("\n SHOWING ALERT:")
		print("\(message)\nOK\n")
	}
	
	func keyboardWillChangeFrame(_ notification: Notification) {
		let keyboardMargin: CGFloat = 10
		
		var keyboardRect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
		keyboardRect = view.window!.convert(keyboardRect, from: nil)
		let loginTop = usernameTextField.convert(usernameTextField.bounds.origin, to: nil).y
		let passwordBottom = passwordTextField.convert(CGPoint(x: passwordTextField.bounds.maxX, y: passwordTextField.bounds.maxY), to: nil).y
		let loginBottom = loginButton.convert(CGPoint(x: loginButton.bounds.maxX, y: loginButton.bounds.maxY), to: nil).y
		
		var visibleBottom: CGFloat
			
		if usernameTextField.isEditing && ((loginBottom - loginTop) + keyboardMargin > keyboardRect.origin.y) {
			visibleBottom = passwordBottom
		} else {
			visibleBottom = loginBottom
		}
		
		// login bottom if it were centered, with a bit of margin kept
		visibleBottom = visibleBottom - keyboardConstraint.constant + keyboardMargin
		// how far is that from the top of the keyboard
		let kbDistance = keyboardRect.origin.y - visibleBottom
		// if there's som distance, leave login centered, otherwise move it up
		keyboardConstraint.constant = min(0, kbDistance)
		view.layoutIfNeeded()
	}

	
	//******************************************************
	// MARK: - IB Actions
	//******************************************************
	
	@IBAction func login(_ sender: Any) {
		udacityService.login(username: usernameTextField.text!, password: passwordTextField.text!) { result in
			DispatchQueue.main.async {
				switch result {
				case .Success(let user):
					self.studentLocationService.currentUser = user
					self.performSegue(withIdentifier: "LoginSuccessSegue", sender: nil)
				case .Failure(let error):
					switch error {
					case _ as NetworkError:
						self.showAlert(message: "\(error)")
					default:
						self.showAlert(message: "Could not log in: \(error)")
					}
				}
			}
		}
	}

	
	//***************************************************************************
	// MARK: - TextField Delegate
	//***************************************************************************
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		let newString = NSString(string: textField.text ?? "").replacingCharacters(in: range, with: string)
		
		if textField == usernameTextField {
			loginButton.isEnabled = validateCredentials(username: newString, password: passwordTextField.text)
		} else if textField == passwordTextField {
			loginButton.isEnabled = validateCredentials(username: usernameTextField.text, password: newString)
		}
		
		return true
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true;
	}
}

