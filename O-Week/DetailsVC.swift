//
//  DetailsVC.swift
//  O-Week
//
//  Created by Vicente Caycedo on 3/13/17.
//  Copyright © 2017 Cornell D&TI. All rights reserved.
//

import UIKit
import MapKit

/**
	Displays a user-selected event.
	`event`: The event displayed to the user.
	`changed`: Indicates if the user selected/deselected the event. When this view is exiting, if this is true, then we must notify listeners for event reloads.
*/
class DetailsVC: UIViewController, MKMapViewDelegate
{
    let eventTitle = UILabel.newAutoLayout()
    let eventCaption = UILabel.newAutoLayout()
    let eventDescription = UILabel.newAutoLayout()
    let timeLabel = UILabel.newAutoLayout()
	let requiredDescription = UILabel.newAutoLayout()
	let requiredText = UITextField.newAutoLayout()
	let requiredSection = UIStackView.newAutoLayout()
    let eventImage = UIImageView.newAutoLayout()
	let addButton = UIButton.newAutoLayout()
	let additional = UILabel.newAutoLayout()
	let map = MKMapView.newAutoLayout()
	
	let MAP_ZOOM = 0.001
    var event: Event?
    var changed = false
	
	/**
		Show the event's data on screen.
	*/
    override func viewDidLoad()
	{
        super.viewDidLoad()
		guard event != nil else {
			print("DetailsVC loaded without an event provided")
			return
		}
		
        configure(event: event!)
    }
    /**
		Notify listeners if the event's selection has been changed by the user.
		- parameter animated: Ignored.
	*/
    override func viewWillDisappear(_ animated: Bool)
	{
        if (changed)
		{
            NotificationCenter.default.post(name: .reloadData, object: nil)
        }
    }
    /**
		Shows the event's data on screen. Attempts to retrieve an image from the database or from saved files.
		- parameter event: Same as the global variable, but not nil.
	*/
    private func configure(event:Event)
    {
        eventTitle.text = event.title
        eventCaption.text = event.caption
        eventDescription.text = event.description
		timeLabel.text = "\(dayOfWeek())  |  \(event.startTime) - \(event.endTime)"
        setButtonImage(UserData.selectedEventsContains(event))
		Internet.getImageFor(event, imageView: eventImage)
		configureMap(event:event)
		
		//required
		if (!(event.required || event.categoryRequired))
		{
			requiredSection.isHidden = true
		}
		else
		{
			requiredText.layer.cornerRadius = requiredText.frame.width / 2
			if (event.required)
				{requiredDescription.text = "Required for All Students"}
			else	//category required
			{
				if let category = UserData.categoryFor(event.category)
					{requiredDescription.text = "Required for \(category.name) Students"}
			}
		}
		
		//additional text
		if (!event.additional.isEmpty)
			{additional.attributedText = event.attributedAdditional()}
		else
			{additional.isHidden = true}
    }
	/**
		Set up the map such that it displays the location of the event with a marker.
		- parameter event: Same as the global variable, but not nil.
	*/
	private func configureMap(event:Event)
	{
		map.delegate = self
		
		//set center & zoom
		let center = CLLocationCoordinate2DMake(event.latitude, event.longitude)
		let span = MKCoordinateSpanMake(MAP_ZOOM, MAP_ZOOM)
		let region = MKCoordinateRegionMake(center, span)
		map.setRegion(region, animated: false)
		
		//set marker
		let marker = MKPointAnnotation()
		marker.title = event.caption
		marker.coordinate = center
		map.addAnnotation(marker)
	}
	/**
		Launch Apple maps when the user presses on the map.
		- parameters:
			- mapView: map view.
			- view: The item the user pressed on the map.
	*/
	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
	{
		let center = CLLocationCoordinate2DMake(event!.latitude, event!.longitude)
		let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: center))
		mapItem.name = event!.caption
		mapItem.openInMaps(launchOptions: nil)
	}
	private func dayOfWeek() -> String
	{
		let formatter = DateFormatter()
		formatter.dateFormat = "EEEE"
		return formatter.string(from: event!.date)
	}
	/**
		Handle user selection of the event's add button. Adds/Removes `event` from selected events accordingly.
		- parameter sender: the add button.
	*/
    @IBAction func add_button_pressed(_ sender: UIButton)
	{
        if (UserData.selectedEventsContains(event!))
		{
            setButtonImage(false)
            UserData.removeFromSelectedEvents(event!)
            LocalNotifications.removeNotification(for: event!.pk)
        }
		else
		{
            setButtonImage(true)
            UserData.insertToSelectedEvents(event!)
			LocalNotifications.createNotification(for: event!)
        }
        changed = true
    }
    /**
		Animate the add button changing.
		- parameter added: Whether or not this event is selected.
	*/
    private func setButtonImage(_ added:Bool)
	{
        UIView.animate(withDuration: 0.5) {
            self.addButton.alpha = 0
            let image = added ? Images.whiteImageAdded : Images.whiteImageNotAdded
            self.addButton.setImage(image, for: .normal)
            self.addButton.alpha = 1
        }
    }
}
