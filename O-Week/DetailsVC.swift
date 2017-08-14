//
//  DetailsVC.swift
//  O-Week
//
//  Created by Vicente Caycedo on 3/13/17.
//  Copyright © 2017 Cornell SA Tech. All rights reserved.
//

import UIKit
import MapKit

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
    
    override func viewDidLoad()
	{
        super.viewDidLoad()
        configure(event: event!)
    }
    
    override func viewWillDisappear(_ animated: Bool)
	{
        if (changed)
		{
            NotificationCenter.default.post(name: .reloadData, object: nil)
        }
    }
    
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
	
	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
	{
		let center = CLLocationCoordinate2DMake(event!.latitude, event!.longitude)
		let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: center))
		mapItem.name = event!.caption
		mapItem.openInMaps(launchOptions: nil)
	}
    
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
    
    private func setButtonImage(_ added:Bool)
	{
        UIView.animate(withDuration: 0.5) {
            self.add_button.alpha = 0
            let image = added ? Constants.Images.whiteImageAdded : Constants.Images.whiteImageNotAdded
            self.add_button.setImage(image, for: .normal)
            self.add_button.alpha = 1
        }
    }
}
