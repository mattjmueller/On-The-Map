//*********************************************************
// ShareLinkViewController.swift
// On The Map
//
// Created by Matthew Mueller on 4/21/17.
// Copyright © 2017 Matthew Mueller. All rights reserved.
//*********************************************************

import UIKit
import MapKit

class ShareLinkViewController: UIViewController, AccessesStudentLocations, UITextFieldDelegate, MKMapViewDelegate {
	//******************************************************
	// MARK: - IB Outlets
	//******************************************************
	
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var shareLinkTextField: UITextField!
	@IBOutlet weak var submitButton: UIButton!
	
	
	//******************************************************
	// MARK: - Public Properties
	//******************************************************
	
	weak var studentLocationService: StudentLocationService!
	var locationToShare: Location!
	
	
	//******************************************************
	// MARK: - Life Cycle
	//******************************************************
	
	override func viewDidLoad() {
		super.viewDidLoad()
		configureViews()
		mapLocation(locationToShare)
	}
	
	func configureViews() {
		shareLinkTextField.attributedPlaceholder = NSAttributedString(string: shareLinkTextField.placeholder ?? "", attributes: [NSForegroundColorAttributeName: UIColor.white])
		submitButton.isEnabled = validateURL(urlString: shareLinkTextField.text)
	}
	
	func validateURL(urlString: String?) -> Bool {
		guard let urlString = urlString,
				URL.validate(urlString: urlString) == true else {
			return false
		}
		return true
	}
	
	func mapLocation(_ location: Location) {
		// Create the coordinate for the annotation
		let lat = CLLocationDegrees(location.latitude)
		let long = CLLocationDegrees(location.longitude)
		let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
		
		// Create the annotation and set its properties
		let annotation = MKPointAnnotation()
		annotation.coordinate = coordinate
		annotation.title = location.name
		
		// add to map
		mapView.addAnnotation(annotation)
	}
	
	
	//******************************************************
	// MARK: - IB Actions
	//******************************************************
	
	@IBAction func submit(_ sender: Any) {
		studentLocationService.setMyLocation(locationToShare, sharingURL: shareLinkTextField.text!) { result in
			DispatchQueue.main.async {
				switch result {
				case .Success:
					self.dismiss(animated: true, completion: nil)
				case .Failure:
					let alertController = UIAlertController(title: "Could not Post Location.", message: "There was an error posting your location.", preferredStyle: .alert)
					let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
					
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
		submitButton.isEnabled = validateURL(urlString: newString)
		return true
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true;
	}
}
