//
//  MapVC.swift
//  bussin
//
//  Created by Rafał Gawlik on 19/12/2022.
//

import Foundation
import UIKit
import GoogleMaps
import BackgroundTasks

class MapVC: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - Properties
    struct RoutesModel: Decodable{
        let route_id : String
    }
    struct BusModel: Decodable{
        let id : String
        let linia : String
        let brygada: String
        let trasa: String
        let z : String
        let `do` : String?
        let kierunek: String!
        let lat : String
        let lon: String
        let punktualnosc1: String!
        let punktualnosc2: String
        
    }
//    struct StopsData: Decodable {
//        let stop_id: String
//        let stop_lat: String
//        let stop_lon: String
//        let stop_name: String
//    }
    struct StopsData: Decodable {
        let id: Int
        let szerokoscgeo, dlugoscgeo: Double
        let nazwa: String
        let nrzespolu: Int
        let nrslupka: String
    }
    enum MyError: Error {
        case fileNotFound
        case invalidData
        case otherError(String)
    }
    let mapInfoWindow = MapInfoWindow(frame: CGRect(x: 10, y: 75, width: 370, height: 90))

    private let locationManager = CLLocationManager()
    
    private let updateInterval: TimeInterval = 5
    private var timer: Timer?
    private var buses = [String: BusModel]()
    private var updBuses = [String: BusModel]()
    private var markers = [GMSMarker]()
    private var updMarkers = [GMSMarker]()
    private var markersDict = [String: GMSMarker]()
    private var updMarkersDict = [String: GMSMarker]()
    private var selectedRoutes = [String]()
    
    private var stops = [String: StopsData]()
    // MARK: - Outlets
    
    @IBOutlet weak var linesLabel: UILabel!

    @IBOutlet weak var mapView: GMSMapView!
    
    // MARK: - View Lifecycle
    var getStopsFinished = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        mapInfoWindow.isHidden = true

        
        getStops { [self] result in
            switch result {
            case .success(let stopElements):
                // stopElements is an array of StopElement structs
                // do something with the stop elements
                print("blipblop")
                self.getStopsFinished = true
                //self.getStopsCompletion?(stopElements)
            case .failure(let error):
                // an error occurred
                print(error)
            }
        }

        print(selectedRoutes)
 
        
        updateMapStyle()
        view.addSubview(mapInfoWindow)

    }
    override func viewDidAppear(_ animated: Bool) {
        selectedRoutes = UserDefaults.standard.object(forKey: "selectedLines") as? [String] ?? []
        
        if selectedRoutes.isEmpty {
            linesLabel.text = "brak wybranych linii"
        }else{
            linesLabel.text = "linie: \(selectedRoutes.joined(separator: ", "))"

        }
        if getStopsFinished {
            fetchBuses{

            }
            startTimer()

            //self.startTimer()
            //scheduleBackgroundTask()
        }
//        getStopsCompletion = { stopElements in
//            // Use the stopElements from getStops here
//            print(stopElements)
//            self.fetchBuses {
//                self.startTimer()
//            }
//        }
    
    }
    override  func viewWillDisappear(_ animated: Bool) {
        mapView.clear()
    }
    
    func setupView(){
        mapView.delegate = self


        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: 53.441881238054975, longitude: 14.484995963343623, zoom: 13.0)
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        //mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 25)
        mapView.camera = camera
//        if traitCollection.userInterfaceStyle == .dark{
//            do{
//                googleMap.mapStyle = try GMSMapStyle(jsonString: MapStyle)
//
//                } catch {
//                    NSLog("failed to load dark mode map :C")
//                }
//
//            }

    }
    // MARK: - Private Methods
    
    private func fetchBuses(completion: @escaping ()->()) {
        //print(selectedRoutes.count)
        if selectedRoutes.count == 0{
            return
        }
        
            let urlString = "https://www.zditm.szczecin.pl/json/pojazdy.inc.php"
            guard let url = URL(string: urlString) else { return }
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                    if let error = error {
                        print("Error fetching buses:", error)
                        return
                    }
                    
                    guard let data = data else { return }
                    
                    do {
                        var buses = try JSONDecoder().decode([BusModel].self, from: data)
                        buses = buses.filter { self.selectedRoutes.contains($0.linia) }
                        for bus in buses {
                            self.buses[bus.id] = bus
                            
                            let marker = GMSMarker()
                            let markerPin = self.createMarker(text: bus.linia, inImage: UIImage.init(named: "marker")!, color: .systemBlue, opoznienie: bus.punktualnosc2, stopLat: 0.0,stopLon: 0.0,markerLat: Double(bus.lat)!,markerLon: Double(bus.lon)!)
                            marker.icon = markerPin
                            marker.title = bus.id
                            //marker.rotation = 90
                            marker.position = CLLocationCoordinate2D(latitude: Double(bus.lat) ?? 0.0, longitude: Double(bus.lon) ?? 0.0)
                            let usrData: [String:String] = ["id": bus.id,"linia": bus.linia, "brygada": bus.brygada,"z":bus.z,"do":bus.do!,"trasa":bus.trasa,"opoznienie":bus.punktualnosc2,"opoznienieInfo":bus.punktualnosc1,"kierunek":bus.kierunek]
                            marker.userData = usrData
                            marker.map = self.mapView
                            self.markers.append(marker)
                            self.markersDict[bus.id] = marker
                            
//                            //WIP
//
//                            if let markerValue = bus.do {
//                                if let key = self.stops.keys.first(where: { (key) -> Bool in
//                                    return key == markerValue
//                                }) {
//                                    if let value = self.stops[key] {
//                                        print(value.dlugoscgeo)
//                                        print(value.szerokoscgeo)// prints "value1"
//
//                                        let marker = GMSMarker()
//                                        let markerPin = self.createMarker(text: bus.linia, inImage: UIImage.init(named: "marker")!, color: .systemBlue, opoznienie: bus.punktualnosc2, stopLat: value.szerokoscgeo,stopLon: value.dlugoscgeo,markerLat: Double(bus.lat)!,markerLon: Double(bus.lon)!)
//                                        if let markerPin = self.createMarkers(text: bus.linia, inImage: UIImage.init(named: "marker")!, color: .systemBlue, opoznienie: bus.punktualnosc2, stopLat: value.szerokoscgeo,stopLon: value.dlugoscgeo,markerLat: Double(bus.lat)!,markerLon: Double(bus.lon)!){
//                                            marker.icon = markerPin
//
//                                        }
//
//                                        marker.icon = markerPin
//                                        marker.title = bus.id
//                                        //marker.rotation = 90
//                                        marker.position = CLLocationCoordinate2D(latitude: Double(bus.lat) ?? 0.0, longitude: Double(bus.lon) ?? 0.0)
//                                        let usrData: [String:String] = ["id": bus.id,"linia": bus.linia, "brygada": bus.brygada,"z":bus.z,"do":bus.do!,"trasa":bus.trasa,"opoznienie":bus.punktualnosc2,"opoznienieInfo":bus.punktualnosc1,"kierunek":bus.kierunek]
//                                        marker.userData = usrData
//                                        marker.map = self.mapView
//                                        self.markers.append(marker)
//                                        self.markersDict[bus.id] = marker
//
//                                    }
//                                }
//                            }
                            


                            
//                            DispatchQueue.main.async {
//                                let imageView = UIImageView(image: markerPin)
//                                imageView.transform = CGAffineTransform(rotationAngle: 90)
//                                let rotatedImage = imageView.image
//
//                                let marker = GMSMarker()
//                                marker.title = bus.id
//                                marker.icon = rotatedImage
//                                //marker.rotation = 90
//                                marker.position = CLLocationCoordinate2D(latitude: Double(bus.lat) ?? 0.0, longitude: Double(bus.lon) ?? 0.0)
//                                let usrData: [String:String] = ["id": bus.id,"linia": bus.linia, "brygada": bus.brygada,"z":bus.z,"do":bus.do,"trasa":bus.trasa,"opoznienie":bus.punktualnosc2,"opoznienieInfo":bus.punktualnosc1,"kierunek":bus.kierunek]
//                                marker.userData = usrData
//                                marker.map = self.mapView
//                                self.markers.append(marker)
//                                self.markersDict[bus.id] = marker
//                            }

                            
//                            let marker = GMSMarker()
//                            marker.title = bus.id
//                            marker.icon =
//                            //marker.rotation = 90
//                            marker.position = CLLocationCoordinate2D(latitude: Double(bus.lat) ?? 0.0, longitude: Double(bus.lon) ?? 0.0)
//                            let usrData: [String:String] = ["id": bus.id,"linia": bus.linia, "brygada": bus.brygada,"z":bus.z,"do":bus.do!,"trasa":bus.trasa,"opoznienie":bus.punktualnosc2,"opoznienieInfo":bus.punktualnosc1,"kierunek":bus.kierunek]
//                            marker.userData = usrData
//                            marker.map = self.mapView
//                            self.markers.append(marker)
//                            self.markersDict[bus.id] = marker
                        }
                        completion()
                        //self.createMarkers()
                        //print(buses)
                        print("buses count", buses.count)

                    } catch let jsonError {
                        print("Error parsing JSON:", jsonError)
                    }
                }.resume()
            }
        
    
    @objc private func updateBuses() {
        if selectedRoutes.count == 0 {
            return
        }
        
        let urlString = "https://www.zditm.szczecin.pl/json/pojazdy.inc.php"
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error fetching buses:", error)
                return
            }
            
            guard let data = data else { return }
            
            do {
                var updBuses = try JSONDecoder().decode([BusModel].self, from: data)
                updBuses = updBuses.filter { self.selectedRoutes.contains($0.linia) }
                
                for bus in updBuses {
                    self.updBuses[bus.id] = bus
                }
                
                // Find new and missing keys
                //let newKeys = Set(updBuses.keys).subtracting(self.buses.keys)
                let updBusesKeys = updBuses.map { $0.id }
                let newKeys = Set(updBusesKeys).subtracting(Set(self.buses.keys))
                let missingKeys = Set(self.buses.keys).subtracting(Set(updBusesKeys))

                // Update positions of existing markers
                for (id, bus) in self.buses {
                    if let updBus = self.updBuses[id] {
                        // Check if coordinates have changed
                        if updBus.lat != bus.lat || updBus.lon != bus.lon {
                            if let marker = self.markersDict[id]{
//                                let markerPin = self.createMarker(text: bus.linia, inImage: UIImage.init(named: "marker")!, color: .systemBlue, opoznienie: bus.punktualnosc2, stopLat: 0.0,stopLon: 0.0,markerLat: Double(bus.lat)!,markerLon: Double(bus.lon)!)
//                                marker.icon = markerPin
                                CATransaction.begin()
                                CATransaction.setAnimationDuration(2.0)
                                marker.position = CLLocationCoordinate2D(latitude: Double(updBus.lat) ?? 0.0, longitude: Double(updBus.lon) ?? 0.0)
                                
                                CATransaction.commit()
                            }
//
//                            if let markerValue = updBus.do {
//                                if let key = self.stops.keys.first(where: { (key) -> Bool in
//                                    return key == markerValue
//                                }) {
//                                    if let value = self.stops[key] {
//
//                                        // Update marker position
//                                        if let marker = self.markersDict[id] {
//                                            //WIP
////                                            if let markerPin = self.createMarkers(text: bus.linia, inImage: UIImage.init(named: "marker")!, color: .systemBlue, opoznienie: bus.punktualnosc2, stopLat: value.szerokoscgeo,stopLon: value.dlugoscgeo,markerLat: Double(bus.lat)!,markerLon: Double(bus.lon)!){
////                                                marker.icon = markerPin
////
////                                            }
//
//                                        }
//                                    }
//                                }
//                            }
  
                        }
                    }
                }
                
                // Add new markers for new objects
                for id in newKeys {
                    if let bus = self.updBuses[id] {
                        let marker = GMSMarker()
                        let markerPin = self.createMarker(text: bus.linia, inImage: UIImage.init(named: "marker")!, color: .systemBlue, opoznienie: bus.punktualnosc2, stopLat: 0.0,stopLon: 0.0,markerLat: Double(bus.lat)!,markerLon: Double(bus.lon)!)

                        marker.title = bus.id
                        marker.icon = markerPin
                        //marker.rotation = 90
                        marker.position = CLLocationCoordinate2D(latitude: Double(bus.lat) ?? 0.0, longitude: Double(bus.lon) ?? 0.0)
                        let usrData: [String:String] = ["id": bus.id,"linia": bus.linia, "brygada": bus.brygada,"z":bus.z,"do":bus.do!,"trasa":bus.trasa,"opoznienie":bus.punktualnosc2,"opoznienieInfo":bus.punktualnosc1,"kierunek":bus.kierunek]
                        marker.userData = usrData
                        marker.map = self.mapView
                        self.markers.append(marker)
                        self.markersDict[bus.id] = marker
//                        if let markerValue = bus.do {
//                            if let key = self.stops.keys.first(where: { (key) -> Bool in
//                                return key == markerValue
//                            }) {
//                                if let value = self.stops[key] {
//                                    //print(value.dlugoscgeo)
//                                    //print(value.szerokoscgeo)// prints "value1"
//                                    let marker = GMSMarker()
//                                    //WIP
////                                    if let markerPin = self.createMarkers(text: bus.linia, inImage: UIImage.init(named: "marker")!, color: .systemBlue, opoznienie: bus.punktualnosc2, stopLat: value.szerokoscgeo,stopLon: value.dlugoscgeo,markerLat: Double(bus.lat)!,markerLon: Double(bus.lon)!){
////                                        marker.icon = markerPin
////
////                                    }
//                                    let markerPin = self.createMarker(text: bus.linia, inImage: UIImage.init(named: "marker")!, color: .systemBlue, opoznienie: bus.punktualnosc2, stopLat: value.szerokoscgeo,stopLon: value.dlugoscgeo,markerLat: Double(bus.lat)!,markerLon: Double(bus.lon)!)
//
//                                    marker.title = bus.id
//                                    marker.icon = markerPin
//                                    //marker.rotation = 90
//                                    marker.position = CLLocationCoordinate2D(latitude: Double(bus.lat) ?? 0.0, longitude: Double(bus.lon) ?? 0.0)
//                                    let usrData: [String:String] = ["id": bus.id,"linia": bus.linia, "brygada": bus.brygada,"z":bus.z,"do":bus.do!,"trasa":bus.trasa,"opoznienie":bus.punktualnosc2,"opoznienieInfo":bus.punktualnosc1,"kierunek":bus.kierunek]
//                                    marker.userData = usrData
//                                    marker.map = self.mapView
//                                    self.markers.append(marker)
//                                    self.markersDict[bus.id] = marker
//
//                                }
//                            }
//                        }
                        

                    }
                }
                
                // Remove markers for missing objects
                for id in missingKeys {
                    if let marker = self.markersDict[id] {
                        marker.map = nil
                        self.markers.removeAll(where: { $0.title == id })
                        self.markersDict.removeValue(forKey: id)
                    }
                }
                
                // Update local copy of data
                self.buses = self.updBuses
                self.updBuses.removeAll()
            }
            catch let jsonError {
                print("Error parsing JSON:", jsonError)
            }
        }.resume()
    }
          
    private func getStops(completion: @escaping (Result<[StopsData], Error>) -> ()) {
        if let stopsJSON = Bundle.main.url(forResource: "stops", withExtension: "json") {
            do {
                let jsonData = try Data(contentsOf: stopsJSON)
                do {
                    
                    let stopElements = try JSONDecoder().decode([StopsData].self, from: jsonData)
                    
                    for stop in stopElements{
                        self.stops[stop.nazwa] = stop
                    }
                    completion(.success(stopElements))
                } catch {
                    completion(.failure(error))
                }
            } catch {
                completion(.failure(error))
            }
        } else {
            completion(.failure(MyError.fileNotFound))
        }
    }

    



    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: updateInterval, target: self, selector: #selector(updateBuses), userInfo: nil, repeats: true)
    }
    

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
      super.traitCollectionDidChange(previousTraitCollection)
      updateMapStyle()
    }

    func updateMapStyle() {
      if self.traitCollection.userInterfaceStyle == .dark {
        do {
          // Load the dark mode style JSON file
          if let styleURL = Bundle.main.url(forResource: "dark_mode_style", withExtension: "json") {
            mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
          } else {
            NSLog("Unable to find dark_mode_style.json")
          }
        } catch {
          NSLog("One or more of the map styles failed to load. \(error)")
        }
      } else {
        // Use the default light mode style
        mapView.mapStyle = nil
      }
    }


    func createMarker(text:String, inImage:UIImage,color: UIColor,opoznienie: String,stopLat: Double, stopLon: Double,markerLat: Double, markerLon: Double) -> UIImage? {
      let newOpoznienie: String
        let textColor: UIColor

        
        
      if opoznienie.prefix(7) == "&minus;" {
        newOpoznienie = opoznienie.replacingOccurrences(of: "&minus;", with: "-")
        textColor = .red
      } else if opoznienie == "0" {
        newOpoznienie = opoznienie
        textColor = .systemGreen
      } else {
        textColor = .systemGreen
        newOpoznienie = opoznienie
        //return nil
      }

        let font = UIFont.boldSystemFont(ofSize: 10)
        let delayFont = UIFont.boldSystemFont(ofSize: 8)
        let size = inImage.size
        let skala = 0.5
        let newSize = CGSize(width: size.width * skala, height: size.height * skala)
        let scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: newSize, format: .preferred())
        let image = renderer.image { context in
          let cgContext = context.cgContext

          // Draw the tinted image
          inImage.withTintColor(color, renderingMode: .alwaysTemplate).draw(in: CGRect(origin: .zero, size: newSize))

          // Set up the style and attributes for drawing text
          let style = NSMutableParagraphStyle()
          style.alignment = .center
          let attributes: NSDictionary = [      NSAttributedString.Key.font: font,      NSAttributedString.Key.paragraphStyle: style,      NSAttributedString.Key.foregroundColor: UIColor.black    ]
          let opoznienieAttributes: NSDictionary = [      NSAttributedString.Key.font: delayFont,      NSAttributedString.Key.paragraphStyle: style,      NSAttributedString.Key.foregroundColor: textColor    ]
            // Draw the rounded rectangle
            let rect = CGRect(origin: .zero, size: newSize)
        let desiredColor = UIColor.white
          let fillRect = CGRect(x: (rect.size.width) / 4 + 0.23, y: (rect.size.height) / 4 - 8, width: newSize.width / 2, height: newSize.height / 2)
          desiredColor.setFill()
          let roundedRect = UIBezierPath(roundedRect: fillRect, cornerRadius: 50).fill()
           

          // Draw the text and opoznienie string
          let textSize = text.size(withAttributes: attributes as? [NSAttributedString.Key: Any])
          
          let textRect = CGRect(x: (rect.size.width - textSize.width) / 2 - 6, y: (rect.size.height - textSize.height) / 2 - 6, width: textSize.width, height: textSize.height)
          text.draw(in: textRect.integral, withAttributes: attributes as? [NSAttributedString.Key: Any])
          let opoznienieRect = CGRect(x: (rect.size.width - textSize.width) / 2, y: (rect.size.height - textSize.height) / 2 - 5, width: textSize.width + 15, height: textSize.height)
          newOpoznienie.draw(in: opoznienieRect.integral, withAttributes: opoznienieAttributes as? [NSAttributedString.Key: Any])

            }

            return image
          }
    func arrowRot(inImage: UIImage,color: UIColor)->UIImage?{
        let size = inImage.size
        let skala = 0.5
        let newSize = CGSize(width: size.width * skala, height: size.height * skala)

        let scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: newSize, format: .preferred())
        let image = renderer.image { context in
            let cgContext = context.cgContext
            
            // Draw the tinted image
            inImage.withTintColor(color, renderingMode: .alwaysTemplate).draw(in: CGRect(origin: .zero, size: newSize))
            
        }
        return image

    }
    func createMarkers(text:String, inImage:UIImage,color: UIColor,opoznienie: String,stopLat: Double, stopLon: Double,markerLat: Double, markerLon: Double) -> UIImage? {
            let newOpoznienie: String
            let textColor: UIColor

        
        
          if opoznienie.prefix(7) == "&minus;" {
            newOpoznienie = opoznienie.replacingOccurrences(of: "&minus;", with: "-")
            textColor = .red
          } else if opoznienie == "0" {
            newOpoznienie = opoznienie
            textColor = .systemGreen
          } else {
            textColor = .systemGreen
            return nil
          }
        let font = UIFont.boldSystemFont(ofSize: 10)
        let delayFont = UIFont.boldSystemFont(ofSize: 8)
        let size = inImage.size
        let skala = 0.5
        let newSize = CGSize(width: size.width * skala, height: size.height * skala)
        let scale = UIScreen.main.scale
        let testSize = CGSize(width: size.width*1.5, height: size.height * 1.5)
        let location1 = CLLocation(latitude: stopLat, longitude: stopLon)
        let location2 = CLLocation(latitude: markerLat, longitude: markerLon)
//        let bearing = location1.bearingToLocationRadian(location2)
//        let rotatedImg = inImage.rotate(radians: bearing)
        
        let bearing = location1.bearing(to: location2)
       // let angle = -1 * bearing * 180 / .pi
        //let rotatedImg = inImage.rotate(radians: angle)
        //pin img

            //print(scale)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)

        inImage.withTintColor(.systemPurple, renderingMode: .alwaysTemplate).draw(in: CGRect(origin: CGPoint(x: 0, y: 17), size: size ))
        let desiredColor = UIColor.white
        let fillRect = CGRect(x: 15,y: 19 ,width: newSize.width/2+3, height: newSize.height/2+3)
        desiredColor.setFill()
        let roundedRect = UIBezierPath(roundedRect: fillRect, cornerRadius: 50).fill()
        
        let markerPin = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        let rotatedMarkerPin = markerPin?.rotate(radians: bearing)
            //define styles, attribites for text
            let style : NSMutableParagraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            style.alignment = .center
            let attributes:NSDictionary = [ NSAttributedString.Key.font : font, NSAttributedString.Key.paragraphStyle : style, NSAttributedString.Key.foregroundColor : UIColor.black ]
            let opoznienieAttributes:NSDictionary = [ NSAttributedString.Key.font : font, NSAttributedString.Key.paragraphStyle : style, NSAttributedString.Key.foregroundColor : UIColor.systemGreen ]
            let textSize = text.size(withAttributes: attributes as? [NSAttributedString.Key : Any])
            let rect = CGRect(x: 0, y: 0, width: newSize.width+5, height: newSize.height)
            
            //filled round rectangle
            //let fillRect = CGRect(x: (rect.size.width)/4+0.23,y: (rect.size.height)/4-8 ,width: newSize.width/2, height: newSize.height/2)

            //add text and opoznienie
            let textRect = CGRect(x: (rect.size.width - textSize.width)/2-7, y: (rect.size.height - textSize.height)/2 - 6, width: textSize.width+5, height: textSize.height)
            
            let opoznienieRect = CGRect(x: (rect.size.width - textSize.width)/2 + 5, y: (rect.size.height - textSize.height)/2 - 6, width: textSize.width, height: textSize.height)
            UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        rotatedMarkerPin?.draw(in: CGRect(origin: .zero, size: newSize))
            text.draw(in: textRect.integral, withAttributes: attributes as? [NSAttributedString.Key : Any])
            opoznienie.draw(in: opoznienieRect.integral, withAttributes: opoznienieAttributes as? [NSAttributedString.Key : Any])

            let resultImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            return resultImage
        }
    
    func drawMarker(text:String, inImage:UIImage,color: UIColor,opoznienie: String) -> UIImage? {
            let newOpoznienie: String

            print(opoznienie)
            if opoznienie.prefix(7) == "&minus;"{
                let opoznienieColor: CGColor
                
                newOpoznienie = opoznienie.replacingOccurrences(of: "&minus;", with: "-")
                print(newOpoznienie)
                let newImg = inImage.withTintColor(color, renderingMode: .alwaysTemplate)
                //let font = UIFont.systemFont(ofSize: 12)
                let font = UIFont.boldSystemFont(ofSize: 11)
                let size = inImage.size
                let skala = 0.5
                let newSize = CGSize(width: size.width * skala, height: size.height * skala)
                //print(size)
                
                //UIGraphicsBeginImageContext(size)
                let scale = UIScreen.main.scale
                //print(scale)
                UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
                newImg.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
                let style : NSMutableParagraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
                style.alignment = .center
                let attributes:NSDictionary = [ NSAttributedString.Key.font : font, NSAttributedString.Key.paragraphStyle : style, NSAttributedString.Key.foregroundColor : UIColor.black ]
                let opoznienieAttributes:NSDictionary = [ NSAttributedString.Key.font : font, NSAttributedString.Key.paragraphStyle : style, NSAttributedString.Key.foregroundColor : UIColor.red ]
                
                let textSize = text.size(withAttributes: attributes as? [NSAttributedString.Key : Any])
                let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
       
                
                let desiredColor = UIColor.white
                let fillRect = CGRect(x: (rect.size.width)/4+0.23,y: (rect.size.height)/4-8 ,width: newSize.width/2, height: newSize.height/2)
                desiredColor.setFill()
                let roundedRect = UIBezierPath(roundedRect: fillRect, cornerRadius: 50).fill()
                
                let textRect = CGRect(x: (rect.size.width - textSize.width)/2-6, y: (rect.size.height - textSize.height)/2 - 6, width: textSize.width, height: textSize.height)
                text.draw(in: textRect.integral, withAttributes: attributes as? [NSAttributedString.Key : Any])
            
                let opoznienieRect = CGRect(x: (rect.size.width - textSize.width)/2 , y: (rect.size.height - textSize.height)/2 - 6, width: textSize.width + 15, height: textSize.height)
                newOpoznienie.draw(in: opoznienieRect.integral, withAttributes: opoznienieAttributes as? [NSAttributedString.Key : Any])
                let resultImage = UIGraphicsGetImageFromCurrentImageContext()

                UIGraphicsEndImageContext()

                return resultImage
            }else if opoznienie == "0"{
                
                
                newOpoznienie = opoznienie.replacingOccurrences(of: "&minus;", with: "-")
                print(newOpoznienie)
                let newImg = inImage.withTintColor(.systemPurple, renderingMode: .alwaysTemplate)
                //let font = UIFont.systemFont(ofSize: 12)
                let font = UIFont.boldSystemFont(ofSize: 12)
                let size = inImage.size
                let skala = 0.5
                let newSize = CGSize(width: size.width * skala, height: size.height * skala)
                //print(size)
                
                //UIGraphicsBeginImageContext(size)
                let scale = UIScreen.main.scale
                //print(scale)
                UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
                newImg.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
                let style : NSMutableParagraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
                style.alignment = .center
                let attributes:NSDictionary = [ NSAttributedString.Key.font : font, NSAttributedString.Key.paragraphStyle : style, NSAttributedString.Key.foregroundColor : UIColor.black ]
                let opoznienieAttributes:NSDictionary = [ NSAttributedString.Key.font : font, NSAttributedString.Key.paragraphStyle : style, NSAttributedString.Key.foregroundColor : UIColor.systemGreen ]
                
                let textSize = text.size(withAttributes: attributes as? [NSAttributedString.Key : Any])
                let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
       
                
                let desiredColor = UIColor.white
                let fillRect = CGRect(x: (rect.size.width)/4+0.23,y: (rect.size.height)/4-8 ,width: newSize.width/2, height: newSize.height/2)
                desiredColor.setFill()
                let roundedRect = UIBezierPath(roundedRect: fillRect, cornerRadius: 50).fill()
                
                let textRect = CGRect(x: (rect.size.width - textSize.width)/2-7, y: (rect.size.height - textSize.height)/2 - 6, width: textSize.width, height: textSize.height)
                text.draw(in: textRect.integral, withAttributes: attributes as? [NSAttributedString.Key : Any])
            
                let opoznienieRect = CGRect(x: (rect.size.width - textSize.width)/2 + 5, y: (rect.size.height - textSize.height)/2 - 6, width: textSize.width + 10, height: textSize.height)
                newOpoznienie.draw(in: opoznienieRect.integral, withAttributes: opoznienieAttributes as? [NSAttributedString.Key : Any])
                let resultImage = UIGraphicsGetImageFromCurrentImageContext()

                UIGraphicsEndImageContext()

                return resultImage
            }
        
        else{
                
                
                let newImg = inImage.withTintColor(.systemPurple, renderingMode: .alwaysTemplate)
                //let font = UIFont.systemFont(ofSize: 12)
                let font = UIFont.boldSystemFont(ofSize: 10)
                let size = inImage.size
                let skala = 0.5
                let newSize = CGSize(width: size.width * skala, height: size.height * skala)
                //print(size)
                
                //UIGraphicsBeginImageContext(size)
                let scale = UIScreen.main.scale
                //print(scale)
                UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
                newImg.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
                let style : NSMutableParagraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
                style.alignment = .center
                let attributes:NSDictionary = [ NSAttributedString.Key.font : font, NSAttributedString.Key.paragraphStyle : style, NSAttributedString.Key.foregroundColor : UIColor.black ]
                let opoznienieAttributes:NSDictionary = [ NSAttributedString.Key.font : font, NSAttributedString.Key.paragraphStyle : style, NSAttributedString.Key.foregroundColor : UIColor.systemGreen ]
                
                let textSize = text.size(withAttributes: attributes as? [NSAttributedString.Key : Any])
                let rect = CGRect(x: 0, y: 0, width: newSize.width+5, height: newSize.height)
                
                
                let desiredColor = UIColor.white
                let fillRect = CGRect(x: (rect.size.width)/4+0.23,y: (rect.size.height)/4-8 ,width: newSize.width/2, height: newSize.height/2)
                desiredColor.setFill()
                let roundedRect = UIBezierPath(roundedRect: fillRect, cornerRadius: 50).fill()
                
                let textRect = CGRect(x: (rect.size.width - textSize.width)/2-7, y: (rect.size.height - textSize.height)/2 - 6, width: textSize.width+5, height: textSize.height)
                text.draw(in: textRect.integral, withAttributes: attributes as? [NSAttributedString.Key : Any])
                
                let opoznienieRect = CGRect(x: (rect.size.width - textSize.width)/2 + 5, y: (rect.size.height - textSize.height)/2 - 6, width: textSize.width, height: textSize.height)
                opoznienie.draw(in: opoznienieRect.integral, withAttributes: opoznienieAttributes as? [NSAttributedString.Key : Any])
                let resultImage = UIGraphicsGetImageFromCurrentImageContext()
                
                UIGraphicsEndImageContext()
                
                return resultImage
            }
    }


    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
      switch manager.authorizationStatus {
      case .notDetermined:
        // Request authorization if necessary
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
      case .authorizedWhenInUse, .authorizedAlways:
        // Start updating the location if the app has authorization
        locationManager.startUpdatingLocation()
      default:
        break
      }
    }

    func scheduleBackgroundTask() {
        // register the app for background task scheduling
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "rafalgawlik.bussin.fooBackgroundAppRefreshIdentifier", using: nil) { task in
          // code to execute when the task runs goes here
            // schedule the task
            self.scheduleTask(task: task)
          }
        }
    func scheduleTask(task: BGTask) {
        // create a task request
        let request = BGProcessingTaskRequest(identifier: "rafalgawlik.bussin.fooBackgroundProcessingIdentifier")
        request.requiresNetworkConnectivity = true // requires network connectivity
        request.earliestBeginDate = Date(timeIntervalSinceNow: self.updateInterval) // schedule the task to run in the future

        // schedule the task
        do {
          try BGTaskScheduler.shared.submit(request)
        } catch {
          // an error occurred while scheduling the task
          // handle the error here
        }
      }



}
extension MapVC : GMSMapViewDelegate{

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print("didTap Marker \(marker.title ?? "nothing")")
        
        let markerData = marker.userData as? [String:String]
        print(markerData?["do"] as! String)
        
        if let markerValue = markerData?["do"] {
            if let key = stops.keys.first(where: { (key) -> Bool in
                return key == markerValue
            }) {
                if let value = stops[key] {
                    print(value) // prints "value1"
                }
            }
        }
        mapInfoWindow.isHidden = false
        //newView.configure(lineLab: marker.title!,zLab: markerData?["z"],doLab: markerData?["do"],kierunekLab: markerData?["kierunek"])
        mapInfoWindow.configure(lineLab: markerData?["linia"],kierunekLab: markerData?["kierunek"],opoznienieLab: markerData?["opoznienieInfo"],doLab: markerData?["do"])
        
        return true
    }
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        mapInfoWindow.isHidden=true
        
    }
    
    
}
extension UIImage {
    func rotate(radians: Double) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
extension CLLocation{
    func bearing(to destination: CLLocation) -> Double {
        // http://stackoverflow.com/questions/3925942/cllocation-category-for-calculating-bearing-w-haversine-function
        let lat1 = Double.pi * coordinate.latitude / 180.0
        let long1 = Double.pi * coordinate.longitude / 180.0
        let lat2 = Double.pi * destination.coordinate.latitude / 180.0
        let long2 = Double.pi * destination.coordinate.longitude / 180.0

        // Formula: θ = atan2( sin Δλ ⋅ cos φ2 , cos φ1 ⋅ sin φ2 − sin φ1 ⋅ cos φ2 ⋅ cos Δλ )
        // Source: http://www.movable-type.co.uk/scripts/latlong.html
        let rads = atan2(
            sin(long2 - long1) * cos(lat2),
            cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(long2 - long1))
        let degrees = rads * 180 / Double.pi

        return (degrees + 360).truncatingRemainder(dividingBy: 360)
    }
}


