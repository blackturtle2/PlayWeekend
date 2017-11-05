//
//  ViewController.swift
//  PlayWeekendProject
//
//  Created by leejaesung on 2017. 11. 1..
//  Copyright © 2017년 leejaesung. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SWXMLHash
import Kingfisher
import SafariServices
import Toaster

class MainViewController: UIViewController {
    
    @IBOutlet weak var tableViewMain: UITableView!
    @IBOutlet weak var constraintHeaderImageViewHeight: NSLayoutConstraint!
    @IBOutlet var imageViewBackground: UIImageView!
    
    @IBOutlet weak var labelWeatherSummary: UILabel!
    
    @IBOutlet weak var labelFridayDate: UILabel!
    @IBOutlet weak var imageFridayForenoonWeather: UIImageView!
    @IBOutlet weak var labelFridayForenoonWeatherText: UILabel!
    @IBOutlet weak var imageFridayAfternoonWeather: UIImageView!
    @IBOutlet weak var labelFridayAfternoonWeatherText: UILabel!
    @IBOutlet weak var labelFridayMaxTemperature: UILabel!
    @IBOutlet weak var labelFridayMinTemperature: UILabel!
    
    @IBOutlet weak var labelSaturdayDate: UILabel!
    @IBOutlet weak var imageSaturdayForenoonWeather: UIImageView!
    @IBOutlet weak var labelSaturdayForenoonWeatherText: UILabel!
    @IBOutlet weak var imageSaturdayAfternoonWeather: UIImageView!
    @IBOutlet weak var labelSaturdayAfternoonWeatherText: UILabel!
    @IBOutlet weak var labelSaturdayMaxTemperature: UILabel!
    @IBOutlet weak var labelSaturdayMinTemperature: UILabel!
    
    @IBOutlet weak var labelSundayDate: UILabel!
    @IBOutlet weak var imageSundayForenoonWeather: UIImageView!
    @IBOutlet weak var labelSundayForenoonWeatherText: UILabel!
    @IBOutlet weak var imageSundayAfternoonWeather: UIImageView!
    @IBOutlet weak var labelSundayAfternoonWeatherText: UILabel!
    @IBOutlet weak var labelSundayMaxTemperature: UILabel!
    @IBOutlet weak var labelSundayMinTemperature: UILabel!
    
    var allTourInfo:[tourInfoClass] = []
    
    /*******************************************/
    //MARK:-        LifeCycle                  //
    /*******************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 테이블 뷰 Delegate & DataSource
        self.tableViewMain.delegate = self
        self.tableViewMain.dataSource = self
        
        // 지역 검색 뷰에서 지역을 선택했을 때, 받을 Notification Observer 등록 ( refresh )
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshData), name: NSNotification.Name("refresh"), object: nil)
        
        // UI: 내비게이션 바 투명으로 전환
        self.showNavigationBarTranslucent()
        
        // UI: 테이블헤더 뷰의 높이 조정 ( 아래 테이블 뷰 row들이 의도적으로 보이게 하려는 목적(기종마다 다르게) )
        self.constraintHeaderImageViewHeight.constant = self.view.frame.height - 100
        if self.view.frame.height <= 568.0 { // iPhone 4s & iPad에서 iPhone 앱을 작동시키는 케이스 해상도 대응입니다.
            self.constraintHeaderImageViewHeight.constant = self.view.frame.height // - 100
        }
        
        // UI: 테이블헤더 뷰 높이 리사이즈
        self.resizeTableHeaderViewHeightOf(myTableView: self.tableViewMain)
        
        // UI: 내비게이션 바 타이틀
        self.navigationItem.title = " "
        
        // 앱을 최초 실행했을 때, 기본 도시 설정을 세팅합니다.
        if UserDefaults.standard.string(forKey: "UserSelectedCityName") == nil {
            UserDefaults.standard.set("서울특별시", forKey: "UserSelectedCityName")
        }
        if UserDefaults.standard.string(forKey: "UserSelectedCityLatitude") == nil {
            UserDefaults.standard.set("37.56667", forKey: "UserSelectedCityLatitude")
        }
        if UserDefaults.standard.string(forKey: "UserSelectedCityLongitude") == nil {
            UserDefaults.standard.set("126.97806", forKey: "UserSelectedCityLongitude")
        }
        
        // 통신 & UI 새로고침
        self.refreshData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*******************************************/
    //MARK:-         Functions                 //
    /*******************************************/
    // MARK: 날씨와 관광 정보를 통신하는 새로고침 function
    // 검색 뷰에서 메인 뷰로 돌아올 때 호출합니다.
    @objc func refreshData() {
        self.tableViewMain.setContentOffset(CGPoint(x: 0, y: -88), animated: true)
        
        guard let realUserSelectedCityName = UserDefaults.standard.string(forKey: "UserSelectedCityName") else { return }
        guard let realUserSelectedCityLatitude = UserDefaults.standard.string(forKey: "UserSelectedCityLatitude") else { return }
        guard let realUserSelectedCityLongitude = UserDefaults.standard.string(forKey: "UserSelectedCityLongitude") else { return }
        
        // SK Planet Weather API: 날씨 정보 통신
        let nDay = self.getWeekendCountFrom(today: Date())
        print("///// nDay- 6782: ", nDay)
        self.findShowWeatherOf(afterNday: nDay, cityName: realUserSelectedCityName, cityLatitude: realUserSelectedCityLatitude, cityLongitude: realUserSelectedCityLongitude)
        
        // Tour API: 관광 정보 통신
        self.findShowTourInfoOf(cityName: realUserSelectedCityName, cityLatitude: realUserSelectedCityLatitude, cityLongitude: realUserSelectedCityLongitude)
    }
    
    // MARK: Date 데이터를 입력하면, DateFormatter()를 거쳐서 String으로 반환하는 function
    func getDateStringOf(date: Date ,format: String = "yyyy-MM-dd E HH:mm:ss") -> String {
        let formmater = DateFormatter()
        formmater.dateFormat = format
        return formmater.string(from: date as Date)
    }
    
    // MARK: 오늘로부터 다음 금요일까지 남은 일수를 반환하는 function
    func getWeekendCountFrom(today: Date) -> Int {
        let now = today //.addingTimeInterval(86400) // --> 테스트를 위한, 24시간(86400초) 더하기
        var resultDate = now
        
        print("///// now- 8732: ", now) // UTC+0 시간을 프린트해줍니다.
        print("///// getStrDateOf- 8723: ", getDateStringOf(date: resultDate, format: "yyyy/MM/dd E HH:mm")) // DateFormatter()를 태우면, 로컬라이징이 되어서 한국(UTC+9) 시간으로 출력됩니다.
        
        var count:Double = 0
        while getDateStringOf(date: resultDate, format: "E") != "Fri" || count <= 3 { // 날씨 API가 3일 이하이면, 단기정보 API를 사용해야 하므로, 지금은 다음주 금요일까지 남은 일자를 구합니다.
            count += 1
            resultDate = Date(timeInterval: 86400 * count, since: now as Date)
            print("///// while- count: ", count)
            print("///// while- getDateStringOf: ", getDateStringOf(date: resultDate, format: "E"))
        }
        
        print("///// real count: ", count)
        print("///// real getDateStringOf: ", getDateStringOf(date: resultDate, format: "E"))
        
        return Int(count)
    }
    
    // MARK: 사용자가 선택한 지역의 날씨 데이터 통신 및 UI 그리기 function
    func findShowWeatherOf(afterNday: Int, cityName: String, cityLatitude: String, cityLongitude: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // API: [SK Planet] Weather Planet > 날씨정보 > 중기예보
        // https://developers.skplanetx.com/apidoc/pop-view/?guideDocId=11000259&lggId=KOR
        let weatherReqUrl = "\(JSsecretKey.SKPlanetAPI_RootDomain)?lon=\(cityLongitude)&village=&county=&foretxt=&lat=\(cityLatitude)&city=&version=1&appKey=\(JSsecretKey.SKPlanetAPI_MyKey)"
        
        Alamofire.request(weatherReqUrl, method: HTTPMethod.get, parameters: nil, headers: nil).responseJSON {[unowned self] (response) in
            print("///// weather response- 9823: \n", response)
            
            switch response.result {
            case .success(let value):
                print("///// response.success.value- 9823: \n", value)
                
                let json = JSON(value)
                let myData = json["weather"]["forecast6days"][0]
                print("///// myData 9823: \n", myData)
                
                // 데이터 파싱
                let skyData = myData["sky"]
                let mySkyData: WeatherSkyClass? = WeatherSkyClass(amCodeFriday: skyData["amCode\(afterNday)day"].stringValue,
                                                                  pmCodeFriday: skyData["pmCode\(afterNday)day"].stringValue,
                                                                  amCodeSaturday: skyData["amCode\(afterNday+1)day"].stringValue,
                                                                  pmCodeSaturday: skyData["pmCode\(afterNday+1)day"].stringValue,
                                                                  amCodeSunday: skyData["amCode\(afterNday+2)day"].stringValue,
                                                                  pmCodeSunday: skyData["pmCode\(afterNday+2)day"].stringValue,
                                                                  amNameFriday: skyData["amName\(afterNday)day"].stringValue,
                                                                  pmNameFriday: skyData["pmName\(afterNday)day"].stringValue,
                                                                  amNameSaturday: skyData["amName\(afterNday+1)day"].stringValue,
                                                                  pmNameSaturday: skyData["pmName\(afterNday+1)day"].stringValue,
                                                                  amNameSunday: skyData["amName\(afterNday+2)day"].stringValue,
                                                                  pmNameSunday: skyData["pmName\(afterNday+2)day"].stringValue)
                print("///// mySkyData- 7826: \n", mySkyData ?? "no data")
                
                let temperatureData = myData["temperature"]
                let myTemperatureData: WeatherTemperatureClass? = WeatherTemperatureClass(tMaxFriday: temperatureData["tmax\(afterNday)day"].intValue,
                                                                                          tMinFriday: temperatureData["tmin\(afterNday)day"].intValue,
                                                                                          tMaxSaturday: temperatureData["tmax\(afterNday+1)day"].intValue,
                                                                                          tMinSaturday: temperatureData["tmin\(afterNday+1)day"].intValue,
                                                                                          tMaxSunday: temperatureData["tmax\(afterNday+2)day"].intValue,
                                                                                          tMinSunday: temperatureData["tmin\(afterNday+2)day"].intValue)
                print("///// myTemperatureData- 6823: \n", myTemperatureData ?? "no data")
                
                let gridData = myData["grid"]
                let myGridData: WeatherGridClass? = WeatherGridClass(city: gridData["city"].stringValue,
                                                                     county: gridData["county"].stringValue,
                                                                     village: gridData["village"].stringValue)
                print("///// myGridData- 6823: \n", myGridData ?? "no data")
                
                let myTimeReleaseData = myData["timeRelease"].stringValue
                let myLocationData = myData["location"]["name"].stringValue
                print("///// myTimeReleaseData- 5123: \n", myTimeReleaseData)
                print("///// myLocationData- 6234: \n", myLocationData)
                
                // UI 그리기
                DispatchQueue.main.async {
                    // MARK: 다음주 주말 날씨 토스터 구현
                    if afterNday > 3 {
                        Toast.init(text: "다음주 주말 날씨 예보입니다.").show()
                    }
                    
                    // 날짜
                    self.labelFridayDate.text = self.getDateStringOf(date: Date().addingTimeInterval(86400 * Double(afterNday)), format: "MM / dd")
                    self.labelSaturdayDate.text = self.getDateStringOf(date: Date().addingTimeInterval(86400 * Double(afterNday + 1)), format: "MM / dd")
                    self.labelSundayDate.text = self.getDateStringOf(date: Date().addingTimeInterval(86400 * Double(afterNday + 2)), format: "MM / dd")
                    
                    // 타이틀
                    guard let realMyGridData = myGridData else {
                        self.navigationItem.title = "주말에놀러갈래"
                        return
                    }
                    self.navigationItem.title = realMyGridData.city + " " + realMyGridData.county
                    
                    // 날씨 텍스트
                    guard let realMySkyData = mySkyData else { return }
                    self.labelFridayForenoonWeatherText.text = "(오전)\n" + (mySkyData?.amNameFriday ?? "-")
                    self.labelFridayAfternoonWeatherText.text = "(오후)\n" + (mySkyData?.pmNameFriday ?? "-")
                    self.labelSaturdayForenoonWeatherText.text = "(오전)\n" + (mySkyData?.amNameSaturday ?? "-")
                    self.labelSaturdayAfternoonWeatherText.text = "(오후)\n" + (mySkyData?.pmNameSaturday ?? "-")
                    self.labelSundayForenoonWeatherText.text = "(오전)\n" + (mySkyData?.amNameSunday ?? "-")
                    self.labelSundayAfternoonWeatherText.text = "(오후)\n" + (mySkyData?.pmNameSunday ?? "-")
                    
                    // 날씨 이미지
                    self.imageFridayForenoonWeather.image = UIImage(named: self.findSuitableWeatherImageOf(weatherCode: realMySkyData.amCodeFriday))
                    self.imageFridayAfternoonWeather.image = UIImage(named: self.findSuitableWeatherImageOf(weatherCode: realMySkyData.pmCodeFriday))
                    self.imageSaturdayForenoonWeather.image = UIImage(named: self.findSuitableWeatherImageOf(weatherCode: realMySkyData.amCodeSaturday))
                    self.imageSaturdayAfternoonWeather.image = UIImage(named: self.findSuitableWeatherImageOf(weatherCode: realMySkyData.pmCodeSaturday))
                    self.imageSundayForenoonWeather.image = UIImage(named: self.findSuitableWeatherImageOf(weatherCode: realMySkyData.amCodeSunday))
                    self.imageSundayAfternoonWeather.image = UIImage(named: self.findSuitableWeatherImageOf(weatherCode: realMySkyData.pmCodeSunday))
                    
                    // 기온
                    guard let realMyTemperatureData = myTemperatureData else { return }
                    self.labelFridayMaxTemperature.text = String(realMyTemperatureData.tMaxFriday) + " ℃"
                    self.labelFridayMinTemperature.text = String(realMyTemperatureData.tMinFriday) + " ℃"
                    self.labelSaturdayMaxTemperature.text = String(realMyTemperatureData.tMaxSaturday) + " ℃"
                    self.labelSaturdayMinTemperature.text = String(realMyTemperatureData.tMinSaturday) + " ℃"
                    self.labelSundayMaxTemperature.text = String(realMyTemperatureData.tMaxSunday) + " ℃"
                    self.labelSundayMinTemperature.text = String(realMyTemperatureData.tMinSunday) + " ℃"
                    
                    // 날시 요약
                    self.labelWeatherSummary.text = cityName + "의 주말 날씨는 대체로 '" + realMySkyData.amNameSaturday + "'으로 예상됩니다.\n즐거운 주말 보내세요~ :D"
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                
            case .failure(let error):
                print("///// error- 9823: \n", error)
            }
        }
    }
    
    // MARK: 날씨 코드에 따라 날씨 이미지 String 리턴하는 function
    func findSuitableWeatherImageOf(weatherCode:String) -> String {
        switch weatherCode {
        case "SKY_W01": // 맑음
            return "icon_sunny"
        case "SKY_W02": // 구름조금
            return "icon_sunnycloudy"
        case "SKY_W03": // 구름많음
            return "icon_cloudy"
        case "SKY_W04": // 흐림
            return "icon_foggy"
        case "SKY_W07": // 흐리고 비
            return "icon_rainy"
        case "SKY_W09": // 구름많고 비
            return "icon_sunnycloudyrainy"
        case "SKY_W10": // 소나기
            return "icon_sorainy"
        case "SKY_W11": // 비 또는 눈
            return "icon_rainy"
        case "SKY_W12": // 구름많고 눈
            return "icon_snowy"
        case "SKY_W13": // 흐리고 눈
            return "icon_snowy"
        default:
            return "icon_cloudy"
        }
    }
    
    // MARK: UI: 내비게이션 바 투명으로 전환
    func showNavigationBarTranslucent() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }
    
    
    // MARK: UI: 테이블헤더 뷰 높이 재조정
    func resizeTableHeaderViewHeightOf(myTableView: UITableView) {
        myTableView.tableHeaderView?.layoutIfNeeded()
        
        if let headerView = myTableView.tableHeaderView {
            // 테이블헤더 뷰에 데이터를 입력한 후, 헤더뷰의 높이를 재조정합니다.
            let height = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            var headerFrame = headerView.frame
            
            if height != headerFrame.size.height {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                myTableView.tableHeaderView = headerView
            }
        }
    }
    
    // MARK: Tour API: 지역에 따른 관광정보 통신 function
    func findShowTourInfoOf(cityName: String, cityLatitude: String, cityLongitude: String) {
        // API: [Tour API] 내주변 관광정보
        // http://api.visitkorea.or.kr/guide/inforLocation.do
        let tourReqUrl = "\(JSsecretKey.tourAPI_RootDomain)/locationBasedList?ServiceKey=\(JSsecretKey.tourAPI_MyKey)&contentTypeId=12&mapX=\(cityLongitude)&mapY=\(cityLatitude)&radius=5000&listYN=Y&MobileOS=IOS&MobileApp=\(JSsecretKey.tourAPI_MobileApp)&arrange=P&numOfRows=12&pageNo=1"
        
        Alamofire.request(tourReqUrl).response(queue: nil) {[unowned self] (response) in
            let data = response.data
            guard let realData = data else { return }
            print("///// data- 5123: \n", realData)
            
            let xml = SWXMLHash.parse(realData)
            print("///// xml- 5123: \n", xml)
            print("///// xml header test- 5123: \n", xml["response"]["header"]["resultMsg"].element?.text ?? "(no data)")
            
            let rawData = xml["response"]["body"]["items"]["item"].all
            print("///// rawData- 5523: \n", rawData)
            
            self.allTourInfo = [] // 기존 데이터를 초기화 합니다.
            for item in rawData {
                if let realImage = item["firstimage"].element?.text {
                    self.allTourInfo.append(tourInfoClass(contentID: item["contentid"].element?.text ?? "",
                                                          contentTypeID: item["contenttypeid"].element?.text ?? "",
                                                          title: item["title"].element?.text ?? "",
                                                          address1: item["addr1"].element?.text ?? "",
                                                          address2: item["addr2"].element?.text ?? "",
                                                          firstImageURL: realImage,
                                                          firstImage2URL: item["firstimage2"].element?.text ?? ""))
                }
            }
            
            // UI
            DispatchQueue.main.async {
                self.tableViewMain.reloadData()
            }
            
        }
        
    }
    
    // MARK: 인앱웹뷰(SFSafariView) 열기 function
    // `SafariServices`의 import가 필요합니다.
    func openSafariViewOf(url:String) {
        guard let realURL = URL(string: url) else { return }
        
        // iOS 9부터 지원하는 `SFSafariViewController`를 이용합니다.
        let safariViewController = SFSafariViewController(url: realURL)
        self.present(safariViewController, animated: true, completion: nil)
    }
    
    // MARK: 검색 엔진 function
    func openSearchEngineOf(keyword: String, google: Bool, naver: Bool, daum: Bool) {
        guard let realKeyword = keyword.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            return
        }
        
        if google {
            self.openSafariViewOf(url: "https://www.google.co.kr/search?q=\(realKeyword)")
        }else if naver {
            self.openSafariViewOf(url: "http://search.naver.com/search.naver?query=\(realKeyword)")
        }else if daum {
            self.openSafariViewOf(url: "http://search.daum.net/search?q=\(realKeyword)")
        }
    }
    
    // MARK: 내비게이션 바 버튼: 설정 버튼 액션
    @IBAction func buttonSettingAction(_ sender: UIBarButtonItem) {
        let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let rateAppAction = UIAlertAction(title: "앱 평가하기", style: UIAlertActionStyle.default) {[unowned self] (action) in
            self.rateApp()
        }
        
        let defaultSearchEngineAction = UIAlertAction(title: "기본 검색엔진 설정", style: UIAlertActionStyle.default) {[unowned self] (action) in
            let alert = UIAlertController.init(title: "기본 검색엔진 설정", message: nil, preferredStyle: .actionSheet)
            let naverAction = UIAlertAction(title: "네이버 (Naver)", style: UIAlertActionStyle.default) {(action) in
                UserDefaults.standard.set("naver", forKey: "userDefaults_defaultSearchEngine")
                Toast.init(text: "네이버로 설정되었습니다.").show()
            }
            let googleAction = UIAlertAction(title: "구글 (Google)", style: UIAlertActionStyle.default) {(action) in
                UserDefaults.standard.set("google", forKey: "userDefaults_defaultSearchEngine")
                Toast.init(text: "구글로 설정되었습니다.").show()
            }
            let daumAction = UIAlertAction(title: "다음 (Daum)", style: UIAlertActionStyle.default) {(action) in
                UserDefaults.standard.set("daum", forKey: "userDefaults_defaultSearchEngine")
                Toast.init(text: "다음으로 설정되었습니다.").show()
            }
            let cancelAction:UIAlertAction = UIAlertAction.init(title: "취소", style: .cancel, handler: nil)
            
            alert.addAction(googleAction)
            alert.addAction(naverAction)
            alert.addAction(daumAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)
        }
        
        let cancelAction:UIAlertAction = UIAlertAction.init(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(rateAppAction)
        alert.addAction(defaultSearchEngineAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: 앱 평가하기 기능 function
    func rateApp() {
        let url = URL(string: "itms-apps://itunes.apple.com/app/id1305521645")
        UIApplication.shared.openURL(url!)
    }
}

/*******************************************/
//MARK:-         extenstion                //
/*******************************************/
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: tableView - Row의 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTourInfo.count
    }
    
    // MARK: tableView - Section의 헤더 타이틀
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "가볼만한 곳"
    }
    
    // MARK: tableView - Cell 그리기
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = tableView.dequeueReusableCell(withIdentifier: "MainTourInfoTableViewCell", for: indexPath) as! MainTourInfoTableViewCell

        myCell.labelTitle.text = self.allTourInfo[indexPath.row].title
        myCell.labelLocation.text = self.allTourInfo[indexPath.row].address1
        
        // 메인 관광 정보 이미지 통신
        // 썸네일 이미지(firstImage2URL)을 받아서 placeholder로 만든 다음, 메인 이미지를 수신하여 교체합니다.
        myCell.imageViewRepresentativeTour.kf.indicatorType = .activity // 로딩 인디케이터 작동.
        ImageDownloader.default.downloadImage(with: URL(string: self.allTourInfo[indexPath.row].firstImage2URL)!,
                                              retrieveImageTask: nil,
                                              options: nil,
                                              progressBlock: nil) { (image, error, url, data) in
                                                
                                                DispatchQueue.main.async {
                                                    myCell.imageViewRepresentativeTour.kf.setImage(with: URL(string: self.allTourInfo[indexPath.row].firstImageURL), placeholder: image)
                                                }
        }
        
        myCell.contentID = self.allTourInfo[indexPath.row].contentID
        myCell.contentTypeID = self.allTourInfo[indexPath.row].contentTypeID
        myCell.title = self.allTourInfo[indexPath.row].title
        
        return myCell
    }
    
    // MARK: tableView - Cell 클릭 액션
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 임시 코드: 공모전 제출을 위해, 바로 구글링이 되도록 세팅한 후, 출시함. 추후, 디테일 뷰를 만들어 연결할 것.
//        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "TourInfoDeatilViewController") as! TourInfoDeatilViewController
        let myCell = tableView.cellForRow(at: indexPath) as! MainTourInfoTableViewCell
        
//        nextVC.contentID = myCell.contentID
//        nextVC.contentTypeID = myCell.contentTypeID
        
        guard let realTitle = myCell.title else { return }
        let defaultSearchEngine = UserDefaults.standard.string(forKey: "userDefaults_defaultSearchEngine") ?? "naver"
        switch defaultSearchEngine {
        case "naver":
            self.openSearchEngineOf(keyword: realTitle, google: false, naver: true, daum: false)
        case "google":
            self.openSearchEngineOf(keyword: realTitle, google: true, naver: false, daum: false)
        case "daum":
            self.openSearchEngineOf(keyword: realTitle, google: false, naver: false, daum: true)
        default:
            self.openSearchEngineOf(keyword: realTitle, google: false, naver: true, daum: false)
        }
        
//        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    
}
