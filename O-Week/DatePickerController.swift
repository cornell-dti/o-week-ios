//
//  DatePickerController.swift
//  O-Week
//
//  Created by David Chu and Vicente Caycedo on 5/5/17.
//  Copyright © 2017 Cornell SA Tech. All rights reserved.
//

import UIKit

class DatePickerController: NSObject, UICollectionViewDataSource, UICollectionViewDelegate
{
    
    let collectionView: UICollectionView
    
    var selectedCell: DateCell?
    
    init(collectionView: UICollectionView)
	{
        self.collectionView = collectionView
        super.init()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
	{
        return UserData.dates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
	{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dateCell", for: indexPath as IndexPath) as! DateCell
        cell.configure(date: UserData.dates[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
	{
        selectedCell?.selected(false)
        
        let cell = collectionView.cellForItem(at: indexPath) as! DateCell
        cell.selected(true)
        selectedCell = cell
		UserData.selectedDate = cell.date!
        
        NotificationCenter.default.post(name: .reloadDateData, object: nil)
    }
    
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
				NotificationCenter.default.post(name: .reloadDateData, object: nil)
			}
        }
    }
    
}
