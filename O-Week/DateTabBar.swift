//
//  DateTabBar.swift
//  O-Week
//
//  Created by David Chu on 2017/10/10.
//  Copyright © 2017年 Cornell SA Tech. All rights reserved.
//

import UIKit
import PureLayout

class DateTabBar:UIView
{
	static let DAYS = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
	
	let scrollView = UIScrollView()
	var dateButtons = [UIView]()
	
	//TODO: remove this
	func todoRemove()
	{
		let contentView = UIView()
		contentView.addSubview(scrollView)
		scrollView.showsHorizontalScrollIndicator = false
		scrollView.autoPinEdgesToSuperviewEdges()
		scrollView.autoSetDimension(.height, toSize: 64)
		let scrollContent = UIStackView()
		scrollView.addSubview(scrollContent)
		scrollContent.autoPinEdgesToSuperviewEdges()
		scrollContent.axis = .horizontal
		scrollContent.alignment = .center
		
		for i in 0..<UserData.DATES.count
		{
			let date = UserData.DATES[i]
			let day = UserData.userCalendar.component(.day, from: date)
			let weekday = "12"
			
			let dateButton = UIStackView()
			dateButton.autoSetDimension(.width, toSize: 75)
			scrollContent.addArrangedSubview(dateButton)
			dateButton.axis = .vertical
			dateButton.alignment = .center
			dateButton.distribution = .equalSpacing
			dateButton.spacing = 3
			
			let weekdayLabel = UILabel()
			weekdayLabel.textAlignment = .center
			weekdayLabel.textColor = UIColor.white
			weekdayLabel.font = UIFont(name: "AvenirNext-Medium", size: 12)
			weekdayLabel.text = weekday
			weekdayLabel.sizeToFit()
			dateButton.addArrangedSubview(weekdayLabel)
			
			let dayLabel = UILabel()
			dayLabel.autoSetDimension(.height, toSize: 32)
			dayLabel.autoSetDimension(.width, toSize: 32)
			dayLabel.textAlignment = .center
			dayLabel.textColor = UIColor.white
			dayLabel.font = UIFont(name: "AvenirNext-Medium", size: 18)
			dayLabel.text = "\(day)"
			dayLabel.sizeToFit()
			dateButton.addArrangedSubview(dayLabel)
			
			dateButtons.append(dateButton)
		}
	}
}
