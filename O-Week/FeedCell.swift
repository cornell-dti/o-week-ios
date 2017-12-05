//
//  FeedCell.swift
//  O-Week
//
//  Created by Vicente Caycedo on 3/17/17.
//  Copyright © 2017 Cornell D&TI. All rights reserved.
//

import UIKit
import PureLayout

/**
	Holds data and reference pointers to `View`s for an `Event`.
	`event`: The event that this object currently represents.
	- seeAlso: `FeedVC`
*/
class FeedCell:UITableViewCell
{
    let eventStartTime = UILabel.newAutoLayout()
    let eventEndTime = UILabel.newAutoLayout()
    let eventTitle = UILabel.newAutoLayout()
    let eventCaption = UILabel.newAutoLayout()
	let requiredText = UITextField.newAutoLayout()
    
    var event:Event?
	
	//must be written since we provided `init()`. Will not be used.
	required init?(coder aDecoder: NSCoder) {super.init(coder: aDecoder)}
	
	/**
		Call this to manually initialize.
	*/
	convenience init()
	{
		self.init(style: .default, reuseIdentifier: nil)
	}
	
	/**
		Sets up all subviews of the FeedCell.
		|								|
		| 	10:30 Move-in		(RQ)	|
		| 	 4:00 RPCC					|
		|								|
	*/
	override init(style: UITableViewCellStyle, reuseIdentifier: String?)
	{
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		// [ ~~~ ] StackView to hold everything
		let horizStack = UIStackView.newAutoLayout()
		contentView.addSubview(horizStack)
		horizStack.axis = .horizontal
		horizStack.alignment = .center
		horizStack.spacing = Layout.MARGIN
		horizStack.distribution = .fill
		horizStack.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: Layout.MARGIN, bottom: 0, right: 24))
		
		// 10:30 Event name    ~ View to hold time & event info
		//  1:00 Event caption ~
		let container = UIView.newAutoLayout()
		horizStack.addArrangedSubview(container)
		
		eventStartTime.textColor = UIColor.black
		eventStartTime.alpha = 0.6
		eventStartTime.font = UIFont(name: Font.MEDIUM, size: 12)
		eventStartTime.setContentHuggingPriority(.defaultHigh, for: .horizontal)
		eventStartTime.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
		container.addSubview(eventStartTime)
		eventStartTime.autoPinEdge(toSuperviewEdge: .left)
		
		eventEndTime.textColor = UIColor.black
		eventEndTime.alpha = 0.3
		eventEndTime.font = UIFont(name: Font.MEDIUM, size: 12)
		eventEndTime.setContentHuggingPriority(.defaultHigh, for: .horizontal)
		eventEndTime.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
		container.addSubview(eventEndTime)
		eventEndTime.autoPinEdge(toSuperviewEdge: .left)
		eventEndTime.autoPinEdge(.top, to: .bottom, of: eventStartTime, withOffset: 4)
		
		eventTitle.textAlignment = .left
		eventTitle.textColor = UIColor.black
		eventTitle.alpha = 0.8
		eventTitle.font = UIFont(name: Font.DEMIBOLD, size: 14)
		eventTitle.lineBreakMode = .byTruncatingTail
		eventTitle.setContentHuggingPriority(.defaultLow, for: .horizontal)
		eventTitle.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		container.addSubview(eventTitle)
		eventTitle.autoPinEdge(toSuperviewEdge: .top)
		eventTitle.autoPinEdge(toSuperviewEdge: .right)
		eventTitle.autoPinEdge(.left, to: .right, of: eventStartTime, withOffset: Layout.MARGIN)
		eventTitle.autoPinEdge(.bottom, to: .bottom, of: eventStartTime)
		
		eventCaption.textAlignment = .left
		eventCaption.textColor = UIColor.black
		eventCaption.alpha = 0.75
		eventCaption.font = UIFont(name: Font.REGULAR, size: 12)
		eventCaption.setContentHuggingPriority(.defaultLow, for: .horizontal)
		eventCaption.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		container.addSubview(eventCaption)
		eventCaption.autoPinEdge(toSuperviewEdge: .bottom)
		eventCaption.autoPinEdge(toSuperviewEdge: .right)
		eventCaption.autoPinEdge(.left, to: .right, of: eventEndTime, withOffset: Layout.MARGIN)
		eventCaption.autoPinEdge(.top, to: .top, of: eventEndTime)
		
		// ~ ~~~ (RQ)	"RQ" label
		requiredText.textAlignment = .center
		requiredText.textColor = UIColor.white
		requiredText.backgroundColor = Colors.RED
		requiredText.text = "RQ"
		requiredText.font = UIFont(name: Font.DEMIBOLD, size: 14)
		requiredText.isUserInteractionEnabled = false
		requiredText.autoSetDimensions(to: CGSize(width: 32, height: 32))
		requiredText.layer.cornerRadius = 16
		requiredText.setContentHuggingPriority(.defaultHigh, for: .horizontal)
		requiredText.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
		horizStack.addArrangedSubview(requiredText)
	}
	
	/**
		Sets the current event to display.
		- parameter event: The `Event` that this cell will represent.
	*/
    func configure(event:Event)
	{
		self.event = event
		
		eventTitle.text = event.title
		eventCaption.text = event.caption
		eventStartTime.text = event.startTime.description
		eventEndTime.text = event.endTime.description
		requiredText.isHidden = !UserData.requiredForUser(event: event)
    }
}
