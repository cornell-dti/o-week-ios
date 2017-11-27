//
//  EmptyStateTableVC.swift
//  O-Week
//
//  Created by David Chu on 2017/11/26.
//  Copyright © 2017年 Cornell SA Tech. All rights reserved.
//

import UIKit

/**
	A UITableViewController that displays a custom image with custom text when it is empty.

	`emptyStateImage`: Image for the empty state.
	`emptyStateText`: Text to display under the image.
*/
class EmptyStateTableVC: UITableViewController
{
	private var emptyStateImage:UIImage!
	private var emptyStateText:String!
	
	/**
		This MUST be called to provide the empty state with the correct parameters.
		- parameters:
			- image: Image for the empty state.
			- text: Text beneathe the image in the empty state.
			- style: Plain or grouped.
	*/
	convenience init(image:UIImage, text:String, style:UITableViewStyle)
	{
		self.init(style: style)
		emptyStateImage = image
		emptyStateText = text
	}
	/**
		Use the custom `EmptyStateTable`, which overrides `reloadData()` to detect when it is empty.
	*/
	override func loadView()
	{
		super.loadView()
		tableView = EmptyStateTable(frame: tableView.frame, style: tableView.style)
	}
	/**
		Init empty state on load. If this is done within init, the view controller life cycle is thrown off and bad things can happen.
	*/
	override func viewDidLoad()
	{
		super.viewDidLoad()
		if let emptyStateTable = tableView as? EmptyStateTable
		{
			emptyStateTable.initEmptyState(image:emptyStateImage, text:emptyStateText)
		}
	}
	/**
		Returns 0 height for sections that have no rows (as to hide the titles when the empty state is showing).
		- parameters:
			- tableView: Same as global variable.
			- section: Section number.
		- returns: Height for header in section.
	*/
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
	{
		if (tableView.numberOfRows(inSection: section) == 0)
		{
			return 0.0
		}
		return super.tableView(tableView, heightForHeaderInSection: section)
	}
}
/**
	A `UITableView` that displays a custom image and text when the table is empty.

	`emptyState`: The view that will appear when the table is empty.
	`emptyStateLoaded`: True if layout of `emptyState` was completed. Used to ensure layout is only done once.
*/
class EmptyStateTable: UITableView
{
	private let emptyState = UIView.newAutoLayout()
	private var emptyStateLoaded = false
	
	/**
		Set up the empty state TableView.
		- parameter:
			- image: Image for the empty state.
			- text: Text to display under the image.
	*/
	func initEmptyState(image:UIImage, text:String)
	{
		guard !emptyStateLoaded else {
			return
		}
		emptyStateLoaded = true
		
		emptyState.isHidden = true	//defaults to hidden
		
		backgroundView = emptyState
		emptyState.autoMatch(.width, to: .width, of: self)
		emptyState.autoMatch(.height, to: .height, of: self)
		
		let imageView = UIImageView(image: image.withRenderingMode(.alwaysTemplate))
		emptyState.addSubview(imageView)
		imageView.autoMatch(.width, to: .width, of: self, withMultiplier: 1/3)
		imageView.autoMatch(.height, to: .width, of: imageView)
		imageView.autoAlignAxis(toSuperviewAxis: .horizontal)
		imageView.autoAlignAxis(toSuperviewAxis: .vertical)
		imageView.tintColor = UIColor.gray
		
		let subtitle = UILabel.newAutoLayout()
		emptyState.addSubview(subtitle)
		subtitle.text = text
		subtitle.textColor = UIColor.gray
		subtitle.textAlignment = .center
		subtitle.numberOfLines = 0
		subtitle.font = UIFont.systemFont(ofSize: 14)
		subtitle.autoAlignAxis(.vertical, toSameAxisOf: imageView)
		subtitle.autoPinEdge(.top, to: .bottom, of: imageView, withOffset: Layout.MARGIN)
	}
	/**
		Show/hide the empty state based on whether the table is empty.
	*/
	override func reloadData()
	{
		super.reloadData()
		
		emptyState.isHidden = !isEmpty()
	}
	/**
		Returns true if the table has 0 rows in all sections.
		- returns: See above.
	*/
	private func isEmpty() -> Bool
	{
		for i in 0..<numberOfSections
		{
			if (numberOfRows(inSection: i) > 0)
			{
				return false
			}
		}
		return true
	}
}
