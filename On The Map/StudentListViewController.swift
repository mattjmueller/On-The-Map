//*********************************************************
// StudentListController.swift
// On The Map
//
// Created by Matthew Mueller on 4/19/17.
// Copyright © 2017 Matthew Mueller. All rights reserved.
//*********************************************************

import UIKit

class StudentListViewController: UIViewController, ManagesLogin, AccessesStudentLocations, UITableViewDelegate, UITableViewDataSource {
	//******************************************************
	// MARK: - IB Outlets
	//******************************************************
	
	@IBOutlet weak private var tableView: UITableView!
	
	
	//******************************************************
	// MARK: - Public Properties
	//******************************************************
	
	weak var studentLocationService: StudentLocationService!
	weak var udacityService: UdacityService!

	
	//******************************************************
	// MARK: - Private Properties
	//******************************************************
	
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
					self.tableView.reloadData()
				}
			case .Failure:
				self.studentLocations = []
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
	
	
	//******************************************************
	// MARK: - Table View Data Source
	//******************************************************
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return studentLocations.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let reuseID = "StudentLocationTableViewCell"
		let cell = tableView.dequeueReusableCell(withIdentifier: reuseID)!
		let locationItem = studentLocations[(indexPath as NSIndexPath).row]
		cell.textLabel?.text = locationItem.fullName
		cell.detailTextLabel?.text = locationItem.sharedURL?.absoluteString ?? ""
		return cell
	}
	
	
	//******************************************************
	// MARK: - Table View Delegate
	//******************************************************
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let app = UIApplication.shared
		let urlString = tableView.cellForRow(at: indexPath)?.detailTextLabel?.text ?? ""
		if let urlToOpen = URL(string: urlString) {
			app.open(urlToOpen, options: [:], completionHandler: nil)
		}
		tableView.deselectRow(at: indexPath, animated: true)
	}
}

