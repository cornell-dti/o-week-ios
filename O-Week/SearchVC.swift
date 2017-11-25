//
//  SearchVC.swift
//  O-Week
//
//  Created by David Chu on 2017/11/25.
//  Copyright © 2017年 Cornell SA Tech. All rights reserved.
//

import UIKit

/**
	Search for events.
*/
class SearchVC:UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate
{
	let searchController = UISearchController(searchResultsController: nil)
	
	/**
		Create a `SearchVC` with a NavigationController as its parent and its title 	set.
		- returns: NavigationController with a `SearchVC` child.
	*/
	static func createWithNavBar() -> UINavigationController
	{
		let navController = UINavigationController(rootViewController: SearchVC())
		navController.navigationBar.topItem?.title = "Search"
		return navController
	}
	/**
		Initializer. Add any constant values here.
	*/
	convenience init()
	{
		self.init(nibName: nil, bundle: nil)
	}
	/**
		Configure the search controller.
	*/
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		configureSearchBar()
	}
	/**
		Sets the look of the search bar and links it up to the nav bar.
	*/
	private func configureSearchBar()
	{
		//set search bar appearances
		searchController.searchBar.tintColor = UIColor.white
		searchController.searchBar.barTintColor = UIColor.white
		searchController.dimsBackgroundDuringPresentation = false
		
		if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField
		{
			if let backgroundview = textfield.subviews.first
			{
				// Background color
				backgroundview.backgroundColor = UIColor.white
				// Rounded corner
				backgroundview.layer.cornerRadius = 10;
				backgroundview.clipsToBounds = true;
			}
		}
		
		//connection search controller to nav bar
		searchController.delegate = self
		searchController.searchResultsUpdater = self
		if #available(iOS 11.0, *)
		{
			navigationItem.searchController = searchController
			navigationItem.hidesSearchBarWhenScrolling = false
		}
		else
		{
			// Fallback on earlier versions
			navigationItem.titleView = searchController.searchBar
		}
	}
	/**
		Called whenever the user changes input in the search bar. Update the results view.
		- parameter searchController: Same as global variable.
	*/
	func updateSearchResults(for searchController: UISearchController)
	{
	}
}
