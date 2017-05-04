//*********************************************************
// AddLocationViewController.swift
// On The Map
//
// Created by Matthew Mueller on 4/21/17.
// Copyright © 2017 Matthew Mueller. All rights reserved.
//*********************************************************

import UIKit
import MapKit

class AddLocationViewController: UIViewController, UsesGeolocation, UITextFieldDelegate {
	//******************************************************
	// MARK: - IB Outlets
	//******************************************************
	
	@IBOutlet weak var locationTextField: UITextField!
	@IBOutlet weak var findButton: UIButton!
	
	
	//******************************************************
	// MARK: - Public Properties
	//******************************************************
	
	weak var geolocationService: GeolocationService!

	
	//******************************************************
	// MARK: - Private Properties
	//******************************************************
	
	private var locationResult: Location!
	
	
	//******************************************************
	// MARK: - Life Cycle
	//******************************************************
	
	override func viewDidLoad() {
		super.viewDidLoad()
		configureViews()
	}
	
	func configureViews() {
		locationTextField.attributedPlaceholder = NSAttributedString(string: locationTextField.placeholder ?? "", attributes: [NSForegroundColorAttributeName: UIColor.white])
		findButton.isEnabled = validateAddress(address: locationTextField.text)
	}
	
	func validateAddress(address: String?) -> Bool {
		guard let address = address else {
			return false
		}
		return !address.isEmpty
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "ShareLinkSegue" {
			let vc = segue.destination as! ShareLinkViewController
			vc.locationToShare = locationResult
		}
	}
	
	
	//******************************************************
	// MARK: - IB Actions
	//******************************************************
	
	@IBAction func findLocation(_ sender: Any) {
		let locationString = locationTextField.text!
		
		geolocationService.locationForString(locationString) { result in
			switch result {
			case .Success(let location):
				self.locationResult = location
				self.performSegue(withIdentifier: "ShareLinkSegue", sender: nil)
			case .Failure(let error):
				if case GeolocationServiceError.ambiguousResult = error {
					let alertController = UIAlertController(title: "Multiple Found", message: "Which \"\(locationString)\" do you mean? Can you be more specific?", preferredStyle: .alert)
					
					let okAction = UIAlertAction(title: "OK", style: .default) {
						(result : UIAlertAction) -> Void in
						// do nothing
					}
					
					alertController.addAction(okAction)
					self.present(alertController, animated: true, completion: nil)
				} else if case GeolocationServiceError.noResultReturned = error {
					let alertController = UIAlertController(title: "Location Not Found", message: "Could not find that location.", preferredStyle: .alert)
					
					let okAction = UIAlertAction(title: "OK", style: .default) {
						(result : UIAlertAction) -> Void in
						// do nothing
					}
					
					alertController.addAction(okAction)
					self.present(alertController, animated: true, completion: nil)
				} else {
					let alertController = UIAlertController(title: "Problem Finding You", message: "Encountered a problem when trying to find your location.\(error)", preferredStyle: .alert)
					
					let okAction = UIAlertAction(title: "OK", style: .default) {
						(result : UIAlertAction) -> Void in
						// do nothing
					}
					
					alertController.addAction(okAction)
					self.present(alertController, animated: true, completion: nil)
				}
			
			}
		}
	}
	
	@IBAction func cancel(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
	
	//***************************************************************************
	// MARK: - TextField Delegate
	//***************************************************************************
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		let newString = NSString(string: textField.text ?? "").replacingCharacters(in: range, with: string)
		findButton.isEnabled = validateAddress(address: newString)
		return true
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true;
	}
}
