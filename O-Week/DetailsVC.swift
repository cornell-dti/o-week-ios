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
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventCaption: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var add_button: UIButton!
	@IBOutlet weak var additional: UILabel!
	@IBOutlet weak var map: MKMapView!
	
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
        startTime.text = event.startTime.description
        endTime.text = event.endTime.description
        setButtonImage(UserData.selectedEventsContains(event))
		Internet.getImageFor(event, imageView: eventImage)
		configureMap(event:event)
		if (!event.additional.isEmpty)
		{
			additional.attributedText = event.attributedAdditional()
		}
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
	/**
		Handle user selection of the event's add button. Adds/Removes `event` from selected events accordingly.
		- parameter sender: the add button.
	*/
    @IBAction func add_button_pressed(_ sender: UIButton)
	{
        if(UserData.selectedEventsContains(event!))
		{
            setButtonImage(false)
            UserData.removeFromSelectedEvents(event!)
            LocalNotifications.removeNotification(for: event!)
        }
		else
		{
            setButtonImage(true)
            UserData.insertToSelectedEvents(event!)
            LocalNotifications.addNotification(for: event!)
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
            self.add_button.alpha = 0
            let image = added ? Images.whiteImageAdded : Images.whiteImageNotAdded
            self.add_button.setImage(image, for: .normal)
            self.add_button.alpha = 1
        }
    }
}
