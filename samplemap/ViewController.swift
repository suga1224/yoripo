//
//  ViewController.swift
//  MapView
//
//  Created by Yusk1450 on 2017/07/19.
//  Copyright © 2017年 Yusk. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class Yoripo: NSObject
{
    public var title:String?            // 地点名
    public var point:CLLocation?        // 座標
    public var comment:String?          // コメント
}

class ViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, MKMapViewDelegate
{
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var textFiled: UITextField!
    var locationManager:CLLocationManager = CLLocationManager()
    //ピンのリスト
    var coordinateList = [CLLocationCoordinate2D]()
    var coordinatedata :[String] = []
    var csvlist:[[String]] = []
    var citems:[String] = []
    
    /* -----------------------------------------------
     * ビューが読み込まれたときに呼び出される
    ----------------------------------------------- */
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //中心座標
        let center = CLLocationCoordinate2D(latitude: 35.690553, longitude: 139.699579)
        
        //表示範囲
        let span = MKCoordinateSpanMake(0.005, 0.005)
        
        //中心座標と表示範囲をマップに登録する。
        let region = MKCoordinateRegionMake(center,span)
        self.mapView.setRegion(region,animated:true)
        
        self.mapView.setCenter(self.mapView.userLocation.coordinate, animated: true)
        self.mapView.userTrackingMode = .followWithHeading
        
        if (CLLocationManager.locationServicesEnabled())
        {
            self.locationManager.delegate = self
            self.locationManager.distanceFilter = kCLDistanceFilterNone
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
        
        self.loadData()
        
//        self.textFiled.text = "岐阜県大垣市加賀野4丁目1番地7"
    }
    
    /* -----------------------------------------------
     * 寄りポデータを読み込む
     ----------------------------------------------- */
    func loadData()
    {
        do {
            let path = Bundle.main.path(forResource:"Coordinate",ofType:"csv")
            let csv = try String(contentsOfFile: path!,encoding:String.Encoding.utf8)
            //改行区切りでデータを分割して配列に格納する
            self.coordinatedata = csv.components(separatedBy: "\n")
//            print(self.coordinatedata)
            for row in self.coordinatedata
            {
                if (row != "")
                {
//                print(row)
                    let items = row.components(separatedBy: ",")
//                print(items)
                self.csvlist.append([items[0],items[1],items[2],items[3]])
                }
            }
            
        } catch  {
            print("Load Data Error")
        }
    }
    
    
    /* -----------------------------------------------
     * 目的地を検索する
     ----------------------------------------------- */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textFiled.resignFirstResponder()
        
        let searchKey = textFiled.text
        let geocoder = CLGeocoder()
        
        // 目的地点を検索する
        geocoder.geocodeAddressString(searchKey!, completionHandler: {(placemarks,error) in

            if let placemark = placemarks?[0]
            {
                if let targetCoordinate = placemark.location?.coordinate
                {
                    self.mapView.removeOverlays(self.mapView.overlays)
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    
                    
//                    print(targetCoordinate)

                    // 目的地点にピンを立てる
                    let pin = MKPointAnnotation()
                    pin.coordinate = targetCoordinate
                    pin.title = searchKey
                    self.mapView.addAnnotation(pin)
                    self.mapView.region = MKCoordinateRegionMakeWithDistance(targetCoordinate,500.0,500.0)
                    
                    // 出発地
                    let fromCoodinate = self.mapView.userLocation.coordinate
                    // 目的地
                    let toCoodinate = targetCoordinate
                    
                    // 寄りポを検索する
                    let yoripos = self.searchYoripo(fromCoodinate: fromCoodinate, toCoodinate: toCoodinate)
                    
                    for (index, element) in yoripos.enumerated()
                    {
                        if let title = element.title,
                            let point = element.point,
                            let comment = element.comment
                        {
                            // ピンを立てる
                            let pin = MKPointAnnotation()
                            pin.coordinate = point.coordinate
                            pin.title = title
                            pin.subtitle = comment
                            self.mapView.addAnnotation(pin)
                            self.mapView.region = MKCoordinateRegionMakeWithDistance(targetCoordinate,500.0,500.0)
                        }
                    }
                    
                    // 経路表示
                    let fromPlaceMark = MKPlacemark(coordinate: fromCoodinate)
                    let toPlaceMark = MKPlacemark(coordinate: toCoodinate)
                    
                    let fromMapItem = MKMapItem(placemark: fromPlaceMark)
                    let toMapItem = MKMapItem(placemark: toPlaceMark)
                    
                    // すべての通る位置
                    var mapItems = [MKMapItem]()
                    // 出発地
                    mapItems.append(fromMapItem)
                    // 寄りポ
                    for (index, element) in yoripos.enumerated()
                    {
                        if let point = element.point
                        {
                            let placeMark = MKPlacemark(coordinate: point.coordinate)
                            let mapItem = MKMapItem(placemark: placeMark)
                            mapItems.append(mapItem)
                        }
                    }
                    // 目的地
                    mapItems.append(toMapItem)
                    
                    print(mapItems.count)
                    
                    for (index, element) in mapItems.enumerated()
                    {
                        if (index != mapItems.count - 1)
                        {
                            let request = MKDirectionsRequest()
                            request.source = mapItems[index]
                            request.destination = mapItems[index+1]
                            request.requestsAlternateRoutes = false
                            request.transportType = MKDirectionsTransportType.walking
                            
                            let directions = MKDirections(request: request)
                            directions.calculate(completionHandler: { (res, err) in
                                // 経路検索が終わったら、この中身が呼び出されるよ
                                if (err != nil || (res?.routes.isEmpty)!)
                                {
                                    print("ルート検索エラー")
                                    print(err)
                                    return
                                }
                                
                                if let route = res?.routes[0]
                                {
                                    self.mapView.add(route.polyline)
                                }
                                
                            })
                        }
        
                    }
                    
//                    let request = MKDirectionsRequest()
//                    request.source = fromMapItem
//                    request.destination = toMapItem
//                    request.requestsAlternateRoutes = false
//                    request.transportType = MKDirectionsTransportType.walking
//                    
//                    let directions = MKDirections(request: request)
//                    directions.calculate(completionHandler: { (res, err) in
//                        // 経路検索が終わったら、この中身が呼び出されるよ
//                        if ((err != nil) || (res?.routes.isEmpty)!)
//                        {
//                            return
//                        }
//                        if let route = res?.routes[0]
//                        {
//                            self.mapView.add(route.polyline)
//                        }
//                    })
                }
            }
    })
    
        return true
    }
    
    /* -----------------------------------------------
     * 寄りポを検索する
     ----------------------------------------------- */
    func searchYoripo(fromCoodinate:CLLocationCoordinate2D, toCoodinate:CLLocationCoordinate2D) -> [Yoripo]
    {
        // 寄りポリスト
        var yoripos = [Yoripo]()
        
        //2点間の座標から中心座標を求める
        let  centerlatitude = (fromCoodinate.latitude + toCoodinate.latitude)/2
        let centerlongitude = (fromCoodinate.longitude + toCoodinate.longitude)/2
        let centerPoint = CLLocation(latitude: centerlatitude, longitude: centerlongitude)
//        print(centerlatitude)
//        print(centerlongitude)
        
        //2点間の距離を求める
        let hereLocation = CLLocation(latitude:fromCoodinate.latitude, longitude:fromCoodinate.longitude)
        let destination =  CLLocation(latitude:toCoodinate.latitude,longitude:toCoodinate.longitude)
        let halfdistance = hereLocation.distance(from: destination)/2
        //                        print(centerdistance)
        
        for (index, element) in csvlist.enumerated()
        {
            let latitude = atof(element[1])             // 緯度
            let longitude = atof(element[2])            // 経度
            let yoripoPoint = CLLocation(latitude: latitude, longitude: longitude)

            // 中心座標から寄りポまでの距離
            let d = centerPoint.distance(from: yoripoPoint)
            
            // 中心との距離が半径よりも小さかったら...
            if (d < halfdistance)
            {
                let yoripo = Yoripo()
                yoripo.title =  element[0]          // タイトル
                yoripo.point = yoripoPoint          // 座標
                yoripo.comment = element[3]         // コメント
                yoripos.append(yoripo)
            }
        }
        
        return yoripos
    }
    
    // MARK: - CLLocationManager Delegate methods
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        switch status
        {
        case .notDetermined:
            self.locationManager.requestWhenInUseAuthorization()
            
        case .authorizedWhenInUse:
            self.locationManager.startUpdatingLocation()
            
        default:
            break
        }
    }
    
    // MARK: - MKMapView Delegate methods
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer
    {
        if let route = overlay as? MKPolyline
        {
            let routeRenderer = MKPolylineRenderer(polyline: route)
            routeRenderer.lineWidth = 5.0
            routeRenderer.strokeColor = UIColor.red
            return routeRenderer
    
            
            
        }
        return MKPolylineRenderer()
    }
    
}
