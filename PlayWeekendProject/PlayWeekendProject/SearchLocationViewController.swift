//
//  SearchLocationViewController.swift
//  PlayWeekendProject
//
//  Created by leejaesung on 2017. 11. 2..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit

class SearchLocationViewController: UIViewController {
    
    @IBOutlet weak var tableViewMain: UITableView!
    
    var cityData = NSArray()
    
    /*******************************************/
    //MARK:-        LifeCycle                  //
    /*******************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TableView Delegate & DataSource
        self.tableViewMain.delegate = self
        self.tableViewMain.dataSource = self
        
        if let path = Bundle.main.path(forResource: "City", ofType: "plist") {
            self.cityData = NSArray(contentsOfFile: path)!
        }
        
        self.tableViewMain.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /*******************************************/
    //MARK:-         Functions                 //
    /*******************************************/

    
    
}


/*******************************************/
//MARK:-         extenstion                //
/*******************************************/
extension SearchLocationViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: tableView - numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cityData.count
    }
    
    // MARK: tableView - cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = tableView.dequeueReusableCell(withIdentifier: "SearchLocationTableViewCell", for: indexPath) as! SearchLocationTableViewCell
        
        let dictData:[String : Any] = self.cityData[indexPath.row] as! [String : Any]
        myCell.textLabel?.text = dictData["city"] as? String

        myCell.city.name = (dictData["city"] as? String)!
        myCell.city.latitude = (dictData["latitude"] as? String)!
        myCell.city.longitude = (dictData["longitude"] as? String)!
        
        return myCell
    }
    
    // MARK: tableView - DidSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // 터치한 표시를 제거하는 액션
        tableView.deselectRow(at: indexPath, animated: true)
        
        let myCell = tableView.cellForRow(at: indexPath) as! SearchLocationTableViewCell
        print("///// Selected City- 0923: \n", myCell.city.name + " / latitude: " + myCell.city.latitude + " / longitude: " + myCell.city.longitude )
        
        UserDefaults.standard.set(myCell.city.name, forKey: "UserSelectedCityName")
        UserDefaults.standard.set(myCell.city.latitude, forKey: "UserSelectedCityLatitude")
        UserDefaults.standard.set(myCell.city.longitude, forKey: "UserSelectedCityLongitude")
        
        // 메인 뷰의 날씨/관광정보 새로고침 노티피케이션
        NotificationCenter.default.post(name: NSNotification.Name("refresh"), object: nil)
        
        self.navigationController?.popViewController(animated: true)
    }

}
