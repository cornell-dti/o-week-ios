//
//  DatePickerController.swift
//  O-Week
//
//  Created by David Chu and Vicente Caycedo on 5/5/17.
//  Copyright © 2017 Cornell D&TI. All rights reserved.
//

import UIKit

/**
	Displays the dates that the user can select to see his/her events on that particular date.

	`selectedCell`: The cell that was last selected (by user or by machine when the app launched). This cell is deselected once a new cell is selected. This will then point to the newly selected cell.

	- seeAlso: `DateCell`
*/
class DatePickerController: NSObject, UICollectionViewDataSource, UICollectionViewDelegate
{
    let collectionView: UICollectionView
    
    var selectedCell: DateCell?
	
	/**
		Initializes the `collectionView` to hold the dates an sets the source and delegate to itself.
		- parameter collectionView: A reference to the `UICollectionView` where the date picker is placed.
	*/
    init(collectionView: UICollectionView)
	{
        self.collectionView = collectionView
        super.init()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
	
	/**
		Synchronize the selected `DateCell` with `UserData.selectedDate`, which could've been changed by other classes.
	*/
	func syncSelectedDate()
	{
		guard selectedCell?.date != nil else {
			return
		}
		
		//if our currently selected cell doesn't correspond to the selected date
		if (UserData.userCalendar.compare(selectedCell!.date!, to: UserData.selectedDate, toGranularity: .day) != .orderedSame)
		{
			let index = UserData.DATES.index(of: UserData.selectedDate)!
			
			selectedCell?.selected(false)
			if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? DateCell
			{
				cell.selected(true)
				selectedCell = cell
			}
		}
	}
	
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
	{
        return UserData.DATES.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
	{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dateCell", for: indexPath as IndexPath) as! DateCell
        cell.configure(date: UserData.DATES[indexPath.row])
        return cell
    }
	
	/**
		Switches `selectedCell` when the user selects a new `DateCell`. Changes `UserData.selectedDate` and notifies anyone who is listening for date changes.
		- parameters:
			- collectionView: Reference to the `UICollectionView` in which the `DateCell` was selected. Should be identical to the global variable.
			- indexPath: Index of cell that was selected.
	*/
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
	{
        selectedCell?.selected(false)
        
        let cell = collectionView.cellForItem(at: indexPath) as! DateCell
        cell.selected(true)
        selectedCell = cell
        let prevDate = UserData.selectedDate
        UserData.selectedDate = cell.date!
        if (UserData.userCalendar.compare(cell.date!, to: prevDate!, toGranularity: .day) == .orderedAscending)
        {
            NotificationCenter.default.post(name: .reloadAfterMovedEarlier, object: nil)
        } else {
            NotificationCenter.default.post(name: .reloadAfterMovedLater, object: nil)
        }
		
    }
	
	/**
		Sets the selected cell if none was selected. The cell that is selected will match the current value of `UserData.selectedDate`. This function should be called when the `DateCell`s are not yet visible to the user.
		- parameters:
			- collectionView: Reference to the `UICollectionView` in which the `DateCell` will appear. Should be identical to the global variable.
			- cell: The cell that will appear. Should be of type `DateCell`.
			- indexPath: Index of cell that will appear.
	*/
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
	{
        if (selectedCell == nil)
		{
            let dateCell = cell as! DateCell
			
			guard let date = dateCell.date else {
				return
			}
			
			if (UserData.userCalendar.compare(date, to: UserData.selectedDate, toGranularity: .day) == .orderedSame)
			{
				dateCell.selected(true)
				selectedCell = dateCell
				NotificationCenter.default.post(name: .reloadData, object: nil)
			}
        }
    }
    
}
