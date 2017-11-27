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
	`emptyStateLoaded`: True if layout of `emptyState` was completed. Used to ensure layout is only done once.
*/
class EmptyStateTableVC: UITableViewController
{
	private var emptyStateImage:UIImage!
	private var emptyStateText:String!
	private var emptyStateLoaded = false
	
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
		guard !emptyStateLoaded else {
			return
		}
		emptyStateLoaded = true
		
		let emptyState = UIView.newAutoLayout()
		initEmptyState(emptyState, image: emptyStateImage, text:emptyStateText)
		if let emptyStateTable = tableView as? EmptyStateTable
		{
			emptyStateTable.setEmptyState(emptyState)
		}
		
		//remove dividers that show when the table is empty
		tableView.tableFooterView = UIView.newAutoLayout()
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
		//default height
		return 35.0
	}
	/**
		Set up the empty state.
		- parameters:
			- emptyState: View to contain image & text.
			- image: Image for the empty state.
			- text: Text to display under the image.
	*/
	func initEmptyState(_ emptyState:UIView, image:UIImage, text:String)
	{
		emptyState.isHidden = true	//defaults to hidden
		view.addSubview(emptyState)
		emptyState.autoPin(toTopLayoutGuideOf: self, withInset: 0)
		emptyState.autoPin(toBottomLayoutGuideOf: self, withInset: 0)
		emptyState.autoAlignAxis(toSuperviewAxis: .vertical)
		
		let imageView = UIImageView(image: image.withRenderingMode(.alwaysTemplate))
		emptyState.addSubview(imageView)
		imageView.autoMatch(.width, to: .width, of: view, withMultiplier: 1/3)
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
}
/**
	A `UITableView` that displays a custom image and text when the table is empty.

	`emptyState`: The view that will appear when the table is empty.
*/
class EmptyStateTable: UITableView
{
	private var emptyState:UIView!
	
	func setEmptyState(_ view:UIView)
	{
		self.emptyState = view
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
