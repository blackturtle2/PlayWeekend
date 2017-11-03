//
//  TourInfoDeatilViewController.swift
//  PlayWeekendProject
//
//  Created by leejaesung on 2017. 11. 2..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit
import Alamofire
import SWXMLHash

class TourInfoDeatilViewController: UIViewController {

    @IBOutlet weak var tableViewMain: UITableView!
    
    var contentID: String?
    var contentTypeID: String?
    
    
    /*******************************************/
    //MARK:-        LifeCycle                  //
    /*******************************************/
    override func viewDidLoad() {
        super.viewDidLoad()

        // TableView Delegate & DataSource
        self.tableViewMain.delegate = self
        self.tableViewMain.dataSource = self
        
        
        guard let realContentID = self.contentID else { return }
        guard let realContentTypeID = self.contentTypeID else { return }
        self.findShowTourDetailInfoOf(contentID: realContentID, contentTypeID: realContentTypeID)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    /*******************************************/
    //MARK:-         Functions                 //
    /*******************************************/
    // MARK: Tour API: 지역에 따른 관광정보 통신 function
    func findShowTourDetailInfoOf(contentID: String, contentTypeID: String) {
        // API: [Tour API] 국문관광정보 서비스 - 소개정보조회
        // https://www.data.go.kr/subMain.jsp?param=T1BFTkFQSUAxNTAwMDQ5Ng==#/L3B1YnIvcG90L215cC9Jcm9zTXlQYWdlL29wZW5EZXZHdWlkZVBhZ2UkQF4wMTJtMSRAXnB1YmxpY0RhdGFQaz0xNTAwMDQ5NiRAXnB1YmxpY0RhdGFEZXRhaWxQaz11ZGRpOjZiNmI2MWUyLWNmNWQtNDk3Zi04ZmQyLWMwYjg0ZWE5NTRjMl8yMDEzMDMwNDEwMDQkQF5vcHJ0aW5TZXFObz0yOTMzJEBebWFpbkZsYWc9dHJ1ZQ==
//        let tourReqUrl = "\(Constants.tourAPI_RootDomain)/detailIntro?ServiceKey=\(Constants.tourAPI_MyKey)&contentId=\(contentID)&contentTypeId=\(contentTypeID)&MobileOS=IOS&MobileApp=\(Constants.tourAPI_MobileApp)&introYN=Y"
        
        let tourReqUrl = "\(JSsecretKey.tourAPI_RootDomain)/detailCommon?ServiceKey=\(JSsecretKey.tourAPI_MyKey)&contentId=\(contentID)&contentTypeId=\(contentTypeID)&MobileOS=IOS&MobileApp=\(JSsecretKey.tourAPI_MobileApp)&defaultYN=Y&overviewYN=Y&firstImageYN=Y&addrinfoYN=Y&mapinfoYN=Y"
        Alamofire.request(tourReqUrl).response(queue: nil) {[unowned self] (response) in
            let data = response.data
            guard let realData = data else { return }
            print("///// data- 5123: \n", realData)
            
            let xml = SWXMLHash.parse(realData)
            print("///// xml- 5123: \n", xml)
            print("///// xml header- 5123: \n", xml["response"]["header"]["resultMsg"].element?.text ?? "(no data)")
            
            let rawData = xml["response"]["body"]["items"]["item"]
            print("///// rawData- 5523: \n", rawData)
            
            
            // UI
            DispatchQueue.main.async {
                self.tableViewMain.reloadData()
            }
            
        }
        
    }
}

/*******************************************/
//MARK:-         extenstion                //
/*******************************************/
extension TourInfoDeatilViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}
