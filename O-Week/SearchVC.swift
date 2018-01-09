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
	`tableSections`: Sections of cells. Each element has a name, which is the section's header, and rows, cells within the section.
*/
class SearchVC: EmptyStateTableVC, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate
{
	let SECTION_MY_CALENDAR = 0
	let SECTION_ALL_EVENTS = 1
	let SEARCH_MIN_CHARS = 3
	
	let searchController = UISearchController(searchResultsController: nil)
	var detailsVC:DetailsVC!
	var tableSections:[(name:String, rows:[FeedCell])] = [(name: "My Calendar", rows:[]), (name:"All Events", rows:[])]
	
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
		self.init(image: UIImage(named:"tab_search")!, text: "Search for orientation events", style: .grouped)
		detailsVC = DetailsVC()
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
		
		if let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField
		{
			if let backgroundview = textField.subviews.first
			{
				// Background color
				backgroundview.backgroundColor = UIColor.white
				// Rounded corner
				backgroundview.layer.cornerRadius = 10
				backgroundview.clipsToBounds = true
			}
			//cursor color
			textField.tintColor = UIColor.lightGray
		}
		
		//connection search controller to nav bar
		searchController.searchBar.delegate = self
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
		Called if the user clicks the cancel button. Clear everything from the table.
	*/
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
	{
		tableSections[SECTION_MY_CALENDAR].rows.removeAll()
		tableSections[SECTION_ALL_EVENTS].rows.removeAll()
		tableView.reloadData()
	}
	/**
		Called whenever the user changes input in the search bar. Update the results view. Perform linear search over all events to find keywords.
		- parameter searchController: Same as global variable.
	*/
	func updateSearchResults(for searchController: UISearchController)
	{
		guard let searchText = searchController.searchBar.text,
			searchText.count >= SEARCH_MIN_CHARS else {
			tableSections[SECTION_MY_CALENDAR].rows.removeAll()
			tableSections[SECTION_ALL_EVENTS].rows.removeAll()
			tableView.reloadData()
			return
		}
		
		//looks at the title, caption, description, and additional info for matches
		let filteredEvents = UserData.allEvents.values.flatMap({$0})
			.filter({$0.title.localizedCaseInsensitiveContains(searchText) || $0.caption.localizedCaseInsensitiveContains(searchText) ||
				$0.description.localizedCaseInsensitiveContains(searchText) ||
				$0.additional.localizedCaseInsensitiveContains(searchText)
			})
		separateEvents(filteredEvents)
	}
	/**
		Separates the given events based on user selection and displays them in the table by setting `tableSection`.
		- parameter events: Events.
	*/
	private func separateEvents(_ events:[Event])
	{
		var events = events
		
		let partitionIndex = events.partition(by: {UserData.selectedEventsContains($0)})
		let allEvents = events[0..<partitionIndex]
		let myCalendarEvents = events[partitionIndex..<events.count]
		
		let mapping:((Event) -> FeedCell) = {
			event in
			let cell = FeedCell()
			cell.configure(event: event)
			return cell
		}
		tableSections[SECTION_MY_CALENDAR].rows = myCalendarEvents.map(mapping)
		tableSections[SECTION_ALL_EVENTS].rows = allEvents.map(mapping)
		tableView.reloadData()
	}
	
	// MARK:- Table View Methods
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
	{
		return Layout.FEED_CELL_HEIGHT
	}
	override func numberOfSections(in tableView: UITableView) -> Int
	{
		return tableSections.count
	}
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
	{
		return tableSections[section].name
	}
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return tableSections[section].rows.count
	}
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		return tableSections[indexPath.section].rows[indexPath.row]
	}
	
	/**
		Segue to `DetailsVC` with the selected event.
	
		- parameters:
			- tableView: Reference to the `UITableView` in which the `FeedCell` was selected. Should be identical to the global variable.
			- indexPath: Index of the cell that was selected.
	*/
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		let cell = tableSections[indexPath.section].rows[indexPath.row]
		detailsVC.configure(event: cell.event!)
		navigationController?.setNavigationBarHidden(false, animated: false)
		navigationController?.pushViewController(detailsVC, animated: true)
	}
}
