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
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
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
		let horizStack = UIStackView()
		contentView.addSubview(horizStack)
		horizStack.axis = .horizontal
		horizStack.alignment = .center
		horizStack.spacing = Layout.MARGIN
		horizStack.distribution = .fill
		horizStack.autoPinEdgesToSuperviewMargins()
		
		// 10:30 ~~~ ~ StackView to hold time
		//  1:00 ~~~ ~
		let timeStack = UIStackView()
		horizStack.addArrangedSubview(timeStack)
		timeStack.axis = .vertical
		timeStack.alignment = .trailing
		timeStack.spacing = Layout.TEXT_VERTICAL_SPACING
		timeStack.distribution = .equalSpacing
		timeStack.autoSetDimension(.width, toSize: 56)
		
		eventStartTime.textAlignment = .right
		eventStartTime.textColor = UIColor.black
		eventStartTime.alpha = 0.5
		eventStartTime.font = UIFont(name: Font.REGULAR, size: 12)
		timeStack.addArrangedSubview(eventStartTime)
		
		eventEndTime.textAlignment = .right
		eventEndTime.textColor = UIColor.black
		eventEndTime.alpha = 0.5
		eventEndTime.font = UIFont(name: Font.REGULAR, size: 12)
		timeStack.addArrangedSubview(eventEndTime)
		
		// ~~ Event name	~ StackView to hold event title & caption
		// ~~ Event caption ~
		let eventNameStack = UIStackView()
		horizStack.addArrangedSubview(eventNameStack)
		eventNameStack.axis = .vertical
		eventNameStack.alignment = .leading
		eventNameStack.spacing = Layout.TEXT_VERTICAL_SPACING
		eventNameStack.distribution = .equalSpacing
		
		eventTitle.textAlignment = .left
		eventTitle.textColor = UIColor.black
		eventTitle.alpha = 0.8
		eventTitle.font = UIFont(name: Font.BOLD, size: 16)
		eventTitle.lineBreakMode = .byTruncatingTail
		eventTitle.setContentHuggingPriority(.defaultLow, for: .horizontal)
		eventTitle.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		eventNameStack.addArrangedSubview(eventTitle)
		
		eventCaption.textAlignment = .left
		eventCaption.textColor = UIColor.black
		eventCaption.alpha = 0.5
		eventCaption.font = UIFont(name: Font.REGULAR, size: 12)
		eventCaption.setContentHuggingPriority(.defaultLow, for: .horizontal)
		eventCaption.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		eventNameStack.addArrangedSubview(eventCaption)
		
		// ~ ~~~ (RQ)	"RQ" label
		requiredText.textAlignment = .center
		requiredText.textColor = UIColor.white
		requiredText.backgroundColor = Colors.RED
		requiredText.text = "RQ"
		requiredText.font = UIFont(name: Font.BOLD, size: 12)
		requiredText.isUserInteractionEnabled = false
		requiredText.autoSetDimensions(to: CGSize(width: 24, height: 24))
		requiredText.layer.cornerRadius = 12
		horizStack.addArrangedSubview(requiredText)
	}
	
	/**
		Sets the current event to display.
		- parameter event: The `Event` that this cell will represent.
	*/
    func configure(event:Event)
	{
		eventTitle.text = event.title
		eventCaption.text = event.caption
		eventStartTime.text = event.startTime.description
		eventEndTime.text = event.endTime.description
		requiredText.isHidden = !(event.required || event.categoryRequired)
    }
}
