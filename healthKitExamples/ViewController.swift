//
//  ViewController.swift
//  healthKitExamples
//
//  Created by 서민영 on 2023/08/22.
//

import UIKit
import HealthKit
import CoreMotion
import AVFoundation
import MediaPlayer

class ViewController: UIViewController ,AVAudioPlayerDelegate{
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var currentPaceLabel: UILabel!
    @IBOutlet weak var activePaces: UILabel!
    @IBOutlet weak var activePaceLabel: UILabel!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var coreMotion: UILabel!
    @IBOutlet weak var VideoBtn: UIButton!
    @IBOutlet weak var stopBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var playaudioStackView: UIStackView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var walkCountLabel: UILabel!
    @IBOutlet weak var calorys: UILabel!
    @IBOutlet weak var distances: UILabel!
    @IBOutlet weak var walkCount: UILabel!
    
    var player = AVAudioPlayer()
    var session = AVAudioSession()
    var sessions = WorkoutSession()
    let healthStore = HKHealthStore()
    var walkCounts: Double = 0.0
    var todayStartDates = Date()
    var startDates = Date()
    static let shared = ViewController()
    private var pedoMeter = CMPedometer()
    private var workouts: [HKWorkout]?
    var walkControl: Double = 0.0
    var dateString: String = ""
    var walkData: Double = 0.0
    lazy var cals: Double = 0.0
    var eachDistance: Double = 0.0
    var eachDistances: Double = 0.0
    var intervals: [PrancerciseWorkoutInterval] = []
    var calories: Double = 0.0
    let motionManager = CMMotionActivityManager()
    let readData = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!, HKObjectType.quantityType(forIdentifier: .stepCount)!, HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)!, HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!])
    let share = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!, HKObjectType.quantityType(forIdentifier: .stepCount)!, HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)!, HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!])
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 16.0, *) {
            requestHealthAutoirzation()
        } else {
            requestHealthAutoirzation()
            authorizeHealthKit()
        }
        imageView.image = UIImage(named: "JJANg")
        getwalkCount()
        todayStartDates = Date()
        checkDate()

//        UserDefaults.standard.set(0, forKey: "cals")
        cals = UserDefaults.standard.double(forKey: "cals")
        self.caloriesLabel.text = String(format: "%.2f",self.cals) + "kcal"
        Timer.scheduledTimer(timeInterval: 1.0,
                             target: self,
                             selector: #selector(checkSteps),
                             userInfo: nil,
                             repeats: true)
  
    }
    
    func checkDate() {
        let offsetComps = Calendar.current.dateComponents([.year,.month,.day,.second], from: self.todayStartDates, to: Date())
        if case let (d?,s?) = (offsetComps.day,offsetComps.second) {
            if s > 10 {
                todayStartDates = Date()
            } else if d > 0 {
                todayStartDates = Date()

            }
        }
        print("오늘날짜\(todayStartDates)")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.dateString = dateFormatter.string(from: todayStartDates)
        UserDefaults.standard.set(dateString, forKey: "StartDate")
    }
    
    func reloadWorkouts() {
        WorkoutDataStore.loadPrancerciseWorkouts { (workouts, error) in
            self.workouts = workouts
        }
    }
    
    func motionMove() {
        motionManager.startActivityUpdates(
            to: OperationQueue.main,
            withHandler: {(
                deviceActivity: CMMotionActivity!
            ) -> Void in
                if deviceActivity.stationary {
                    print("놀고있네")
                }
                else if deviceActivity.walking {
                    print("걸고잇군")
                    self.sessions.start()
                    self.getCalories()
                }
                else if deviceActivity.running {
                    print("뛴다")
                    self.getCalories()
                }
            }
        )
        
        
    }
    
    func updateDate() {
        let offsetComps = Calendar.current.dateComponents([.year,.month,.day,.second], from: self.todayStartDates, to: Date())
        if case let (d?,s?) = (offsetComps.day,offsetComps.second) {
            
            if s > 1 {
                print("여기오셧나요\(offsetComps)")
                UserDefaults.standard.removeObject(forKey:  "StartDate")
                self.todayStartDates = Calendar.current.date(byAdding: .second, value: 1, to: self.todayStartDates) ?? Date()
                print("여기오셧나요\(todayStartDates)")
                self.checkDate()
            }   else if d > 0 {
                self.cals = 0
                print("여기다테스트")
                UserDefaults.standard.removeObject(forKey:  "cals")
                self.caloriesLabel.text = "0kcal"
                
                UserDefaults.standard.removeObject(forKey:  "StartDate")
                self.todayStartDates = Calendar.current.date(byAdding: .second, value: 1, to: self.todayStartDates) ?? Date()
                self.checkDate()
            } else {
                
            }
            
        }
        
    }
// 걸음수 
    @objc private func checkSteps() {
        
        let nowDate = Date()
        guard let todayStartDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: nowDate) else {
            return
        }
        pedoMeter.queryPedometerData(from: todayStartDate, to: nowDate) { data, error in
            if let error {
                print("CoreMotionService.queryPedometerData Error: \(error)")
                return
            }
            self.updateDate()
            self.motionMove()
            if let steps = data?.numberOfSteps {
                let step = Double(steps.doubleValue)
                DispatchQueue.main.async {
                    self.coreMotion.text = String(describing: steps) + "걸음"
                    var activePace = Double(truncating: data?.averageActivePace ?? 0)
                    let currentPace = Double(truncating: data?.currentPace  ?? 0 )
                    self.getwalkDistance()
                    self.currentPaceLabel.text = String(format: "%0.2f",currentPace) + "pace"
                    self.activePaceLabel.text = String(format: "%0.2f",activePace) + "pace"
                    self.walkCountLabel.text = String(format: "%.f",step) + "걸음"
                }
                
            }
        }
    }
    //권한
    func requestHealthAutoirzation() {
        self.healthStore.requestAuthorization(toShare: share, read: readData ) { (success, error) in
            if error != nil {
                print(error.debugDescription)
            }else {
                if success {
                    print("권한 허락")
                    if #available(iOS 16.0, *) {
                    }else {
                        self.authorizeHealthKit()
                    }
                }else {
                    print("노 권한")
                }
            }
            
        }
    }
    
    func authorizeHealthKit() {
        HealthKitSetupAssistant.authorizeHealthKit { (authorized, error) in
            guard authorized else {
                let baseMessage = "HealthKit Authorization Failed"
                if let error = error {
                    print("\(baseMessage). Reason: \(error.localizedDescription)")
                } else {
                    print(baseMessage)
                }
                return
            }
            
            print("HealthKit Successfully Authorized.")
        }
    }
    
    
    func convertMileToKM(distance: Double) -> Double {
        let km = distance * 1.61
        print("거리환산후\(km)")
        distanceLabel.text = String(format:"%.2f",km) + "km"
        return km
        
    }
    //걸음수
    @objc func getwalkCount(){
        guard let walkCount = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return
        }
        let now = Date()
        let startDate = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: walkCount, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_,result, error) in
            guard let result = result, let sum = result.sumQuantity() else {
                print("nono")
                return
            }
            DispatchQueue.main.async {
                var counts = sum.doubleValue(for: HKUnit.count())
                self.walkCounts = counts
                self.walkCountLabel.text = String(format:"%.0f",self.walkData) + "걸음"
            }
        }
        healthStore.execute(query)
    }
    
    // 거리
    @objc func getwalkDistance() {
        guard let Distance = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            return
        }
        let now = Date()
        let startDate = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: Distance, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_,result, error) in
            var distances: Double = 0
            guard let result = result, let sum = result.sumQuantity() else {
                print("nono")
                return
            }
            self.eachDistances =  result.mostRecentQuantity()?.doubleValue(for: HKUnit.mile()) ?? 0.0
            distances = sum.doubleValue(for: HKUnit.mile())
            DispatchQueue.main.async {
                self.convertMileToKM(distance: distances)
                
            }
        }
        healthStore.execute(query)
    }
    //칼로리
    @objc private func getCalories(){
        guard let Calories = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            return
        }
        
        let now = Date()
        let timezone = TimeZone.autoupdatingCurrent
        var StartString : String = ""
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        StartString = UserDefaults.standard.string(forKey: "StartDate") ?? ""
        startDates = dateFormatter.date(from: StartString) ?? Date()
  
        let startDate = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: Calories, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_,result, error) in
            var cal: Double = 0
            if #available(iOS 16.0, *) {
                guard let result = result, let sum = result.sumQuantity() else {
                    return
                }
                cal = sum.doubleValue(for: HKUnit.kilocalorie())
                self.caloriesLabel.text = String(format: " %.2f",
                                                 cal) + "kcal"
            } else {
                DispatchQueue.main.async {
                    
                    let interval = PrancerciseWorkoutInterval(start: self.startDates,
                                                              end: now)
                    
                    
                    print("시작\(self.startDates)")
                    print("끝\(now)")
                    self.intervals.append(interval)
                    print("시작\(self.intervals)")
                    print("끝\(now)")
                    
                    var completeWorkout: PrancerciseWorkout? {
                        
                        return PrancerciseWorkout(with: self.intervals)
                    }
                    
                    guard let currentWorkout = completeWorkout else {
                        
                        return print(error?.localizedDescription as Any)
                    }
                    WorkoutDataStore.save(prancerciseWorkout: currentWorkout) { (success, error) in
                        if success {
                            self.sessions.clear()
                            print("성공")
                        } else {
                            self.sessions.start()
                            print("실패")
                        }
                    }
                    
                    
                    var calData: Double = 0.0
                    guard let energyQuantityType = HKSampleType.quantityType(
                        forIdentifier: .activeEnergyBurned) else {
                        fatalError("*** Energy Burned Type Not Available ***")
                    }
                
                        let samples: [HKSample] = currentWorkout.intervals.map { interval in
                            var calorieQuantity = HKQuantity(unit: .kilocalorie(),
                                                             doubleValue: interval.totalEnergyBurned)
                            calData += interval.totalEnergyBurned
                            self.calories = calData
                            self.cals +=  interval.totalEnergyBurned
                            UserDefaults.standard.set(self.cals, forKey: "cals")
                            print("칼로리데이터\(interval.totalEnergyBurned)")
                            self.caloriesLabel.text = String(format: "%.2f",self.cals) + "kcal"
                            return HKCumulativeQuantitySample(type: energyQuantityType,
                                                              quantity: calorieQuantity,
                                                              start: interval.start,
                                                              end: interval.end)
                        }
                    self.sessions.clear()
                    
                    self.intervals.removeAll()
                }
                
                
                
            }
        }
        healthStore.execute(query)
    }
    
    
    @IBAction func touchUpPlayButton(_ sender: UIButton) {
        // 재생 합니다.
        self.play()
    }
    
    @IBAction func touchUpPauseButton(_ sender: UIButton) {
        // 재생을 멈춥니다.
        self.pause()
    }
    
    func play() {
        self.initPlayer()
        self.player.play()
        
        imageView.image = UIImage(named: "Gu")
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 1
    }
    func pause() {
        self.player.pause()
        imageView.image = UIImage(named: "JJANg")
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 0
    }
    
    func initPlayer() {
        // Audio Session 설정
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [])
        } catch let error as NSError {
            print("audioSession 설정 오류 : \(error.localizedDescription)")
        }
        
        let soundName = "audioTest"
        // forResource: 파일 이름(확장자 제외) , withExtension: 확장자(mp3, wav 등) 입력
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
            print("파일이 없다")
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            player.numberOfLoops = -1
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
        
        
        self.remoteCommandCenterSetting()
        self.remoteCommandInfoCenterSetting()
    }
    
    func remoteCommandCenterSetting() {
        // remote control event 받기 시작
        UIApplication.shared.beginReceivingRemoteControlEvents()
        let center = MPRemoteCommandCenter.shared()
        center.playCommand.removeTarget(nil)
        center.pauseCommand.removeTarget(nil)
        // 제어 센터 재생버튼 누르면 발생할 이벤트를 정의합니다.
        center.playCommand.addTarget { (commandEvent) -> MPRemoteCommandHandlerStatus in
            self.player.play()
            MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: self.player.currentTime)
            // 재생 할 땐 now playing item의 rate를 1로 설정하여 시간이 흐르도록 합니다.
            MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 1
            return .success
        }
        
        // 제어 센터 pause 버튼 누르면 발생할 이벤트를 정의합니다.
        center.pauseCommand.addTarget { (commandEvent) -> MPRemoteCommandHandlerStatus in
            self.player.pause()
            MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: self.player.currentTime)
            // 일시정지 할 땐 now playing item의 rate를 0으로 설정하여 시간이 흐르지 않도록 합니다.
            MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 0
            return .success
        }
        center.playCommand.isEnabled = true
        center.pauseCommand.isEnabled = true
    }
    
    func remoteCommandInfoCenterSetting() {
        let center = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = center.nowPlayingInfo ?? [String: Any]()
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = "콘텐츠 제목"
        nowPlayingInfo[MPMediaItemPropertyArtist] = "콘텐츠 아티스트"
        if let albumCoverPage = UIImage(named: "Pingu") {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: albumCoverPage.size, requestHandler: { size in
                return albumCoverPage
            })
        }
        // 콘텐츠 총 길이
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = self.player.duration
        // 콘텐츠 재생 시간에 따른 progressBar 초기화
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1
        // 콘텐츠 현재 재생시간
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: self.player.currentTime)
        
        center.nowPlayingInfo = nowPlayingInfo
        
    }
    
    @IBAction func touchUpVideoButton(_ sender: UIButton) {
        // VideoViewController를 modal로 present 합니다.
        self.player.pause()
        
        imageView.image = UIImage(named: "Key")
    }
    
    
    @IBAction func handleVolumeSlider(_ sender: Any) {
        imageView.alpha = CGFloat(volumeSlider.value)
        MPVolumeView.setVolume(volumeSlider.value)
    }
    
}

extension MPVolumeView {
    static func setVolume(_ volume: Float) {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider?.value = volume
        }
    }
}

