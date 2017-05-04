//*********************************************************
// StudentMapViewController.swift
// On The Map
//
// Created by Matthew Mueller on 4/19/17.
// Copyright © 2017 Matthew Mueller. All rights reserved.
//*********************************************************

import UIKit
import MapKit

class StudentMapViewController: UIViewController, ManagesLogin, AccessesStudentLocations, MKMapViewDelegate {
	//******************************************************
	// MARK: - IB Outlets
	//******************************************************
	
	@IBOutlet weak var mapView: MKMapView!

	
	//******************************************************
	// MARK: - Public Properties
	//******************************************************
	
	weak var udacityService: UdacityService!
	weak var studentLocationService: StudentLocationService!
	var studentLocations = [StudentLocation]()
	
	
	//******************************************************
	// MARK: - Life Cycle
	//******************************************************
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		studentLocationService.getStudentLocations(page: 1, perPage: 5) { result in
			
			switch result {
			case .Success(let studentLocations):
				DispatchQueue.main.async {
					self.studentLocations = studentLocations
					self.reloadMapData()
				}
			case .Failure:
				self.studentLocations = []
			}
		}
	}
	
	func reloadMapData() {
		mapView.addAnnotations(studentLocations.map { studentLocation in
			// Create the coordinate for the annotation
			let lat = CLLocationDegrees(studentLocation.location.latitude)
			let long = CLLocationDegrees(studentLocation.location.longitude)
			let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)

			// Create the annotation and set its properties
			let annotation = MKPointAnnotation()
			annotation.coordinate = coordinate
			annotation.title = studentLocation.fullName
			annotation.subtitle = studentLocation.sharedURL?.absoluteString
			
			// return the finished annotation
			return annotation
		})
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "" && studentLocationService.userHasLocation {
			let alertController = UIAlertController(title: "Update Location", message: "You already have a location set. Would you like to change it?", preferredStyle: .alert)
			let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
				(result : UIAlertAction) -> Void in
					// do nothing
				}
			
			let changeAction = UIAlertAction(title: "Change", style: .default) {
				(result : UIAlertAction) -> Void in
					// do nothing
			}
			
			alertController.addAction(cancelAction)
			alertController.addAction(changeAction)
			present(alertController, animated: true, completion: nil)
		}
	}

	
	//******************************************************
	// MARK: - Map View Delegate
	//******************************************************
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		let reuseId = "pin"
		
		var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
		
		if pinView == nil {
			pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
			pinView!.canShowCallout = true
			pinView!.pinTintColor = .orange
			pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
		}
		else {
			pinView!.annotation = annotation
		}
		
		return pinView
	}
	
	func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		if control == view.rightCalloutAccessoryView {
			let app = UIApplication.shared

			if let urlString = view.annotation?.subtitle, let urlToOpen = URL(string: urlString!) {
				app.open(urlToOpen, options: [:], completionHandler: nil)
			}
		}
	}

	
	//******************************************************
	// MARK: - IB Actions
	//******************************************************

	@IBAction func logout(_ sender: Any) {
		studentLocationService.currentUser = nil
		udacityService.logout()
		dismiss(animated: true, completion: nil)
	}
}

