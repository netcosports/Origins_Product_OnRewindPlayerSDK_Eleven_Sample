//
//  ViewController.swift
//  ElevenSDKSample
//
//  Created by Oksana Klimko on 28.10.22.
//

import UIKit

import Astrolabe
import RxSwift
import RxCocoa

import Gnomon

import PinLayout

import SwiftyJSON
import OnRewindSDK

import AVKit

extension UINavigationController {

  public func pushViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
//    CATransaction.begin()
//    CATransaction.setCompletionBlock({
//      print("TEST animation completed")
//      DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
//        completion?()
//      }
//    })
    pushViewController(viewController, animated: animated)
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
      completion?()
    }
//    CATransaction.commit()
  }
}

class HomeCollectionCell: CollectionViewCell, Reusable {

  let label: UILabel = {
    let label = UILabel()
    label.textColor = .black
    label.font = .systemFont(ofSize: 14.0)
    label.numberOfLines = 2
    return label
  }()

  let separator: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.lightGray
    return view
  }()

  let fullscreen: UIButton = {
    let button = UIButton()
    button.setTitle("Fullscreen", for: .normal)
    button.setTitleColor(UIColor.blue, for: .normal)
    return button
  }()

  let list: UIButton = {
    let button = UIButton()
    button.setTitle("List", for: .normal)
    button.setTitleColor(UIColor.blue, for: .normal)
    return button
  }()

  let embedded: UIButton = {
    let button = UIButton()
    button.setTitle("Embedded", for: .normal)
    button.setTitleColor(UIColor.blue, for: .normal)
    return button
  }()

  override func setup() {
    super.setup()
    contentView.addSubview(label)
    contentView.addSubview(fullscreen)
    contentView.addSubview(list)
    contentView.addSubview(embedded)
    contentView.addSubview(separator)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    label.pin.top(12).horizontally(12).sizeToFit(.width)
    separator.pin.bottom().horizontally().height(1.0)

    let width = self.width / 3.0
    fullscreen.pin.start().width(width).below(of: label).bottom()
    list.pin.after(of: fullscreen).width(width).below(of: label).bottom()
    embedded.pin.after(of: list).width(width).below(of: label).bottom()
  }

  typealias Data = ViewModel

  enum Events {
    case fullscreen
    case embeded
    case list
  }

  struct ViewModel {
    let title: String
    let events: AnyObserver<Events>
  }

  private var bindDisposeBag = DisposeBag()
  func setup(with data: Data) {
    label.text = data.title
    bindDisposeBag = DisposeBag()
    fullscreen.rx.tap.map { Events.fullscreen }.bind(to: data.events).disposed(by: bindDisposeBag)
    list.rx.tap.map { Events.list }.bind(to: data.events).disposed(by: bindDisposeBag)
    embedded.rx.tap.map { Events.embeded }.bind(to: data.events).disposed(by: bindDisposeBag)
  }

  class func size(for data: Data, containerSize: CGSize) -> CGSize {
    return CGSize(width: containerSize.width, height: 120.0)
  }
}

public struct TestVideoModel: JSONModel, Equatable {

  public let title: String
  public let baseUrl: String
  public let eventId: String?
  public let configurationUrl: String?
  public let accountKey: String
  public let directVideoUrl: String?
  public let heatmapUrl: String?
  public let bettingUrl: String?

  public init(_ container: JSON) throws {
    title = container["title"].stringValue
    baseUrl = container["base_url"].stringValue
    eventId = container["event_id"].string
    configurationUrl = container["event_configuration_url"].string
    accountKey = container["account_key"].stringValue
    directVideoUrl = container["direct_video_url"].string
    heatmapUrl = container["heatmap_iframe"].string
    bettingUrl = container["betting_iframe"].string
  }
}

class HomeViewController: UIViewController, Loadable, Accessor, Containerable {

  typealias Cell = CollectionCell<HomeCollectionCell>



  enum Events: Equatable {
    case fullscreen(TestVideoModel)
    case list(TestVideoModel)
    case embeded(TestVideoModel)
  }
  let eventsSubject = PublishSubject<Events>()

  let activityIndicator: UIActivityIndicatorView = {
    let activityIndicator: UIActivityIndicatorView
    if #available(iOS 13.0, *) {
      activityIndicator = UIActivityIndicatorView(style: .large)
    } else {
      activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    }
    activityIndicator.color = .black
    return activityIndicator
  } ()

  let errorLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 22)
    label.textColor = UIColor.black
    label.text = "Error"
    label.textAlignment = .center
    label.isHidden = true
    return label
  }()

  let noDataLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 22)
    label.textColor = UIColor.black
    label.text = "No data"
    label.textAlignment = .center
    label.isHidden = true
    return label
  }()

  let singleEntryPoint: UIButton = {
    let button = UIButton()
    button.setTitle("HBS EVENT", for: .normal)
    button.backgroundColor = .orange
    button.setTitleColor(UIColor.blue, for: .normal)
    return button
  }()

  let containerView = CollectionView<LoaderDecoratorSource<CollectionViewSource>>()

  var sections: [Sectionable] {
    set {
      source.sections = newValue
    }

    get {
      return source.sections
    }
  }
  let analyticsView = AnalyticsView(frame: .zero)
  var enableAnalyticsDebugView = false
  let item = UIBarButtonItem(title: "Enable analytics overlay", style: .done, target: nil, action: nil)
  let disposeBag = DisposeBag()
  private var lastEvent: Events?
  private var storedEvent: Events?

  private var restoreCompletion: (()->())? = nil

  override func viewDidLoad() {
    super.viewDidLoad()

    OnRewind.pipStoreState = { [weak self] in
      self?.storedEvent = self?.lastEvent
      guard let event = self?.lastEvent else {
        return
      }
      switch event {
      case .fullscreen:
        break
      default:
        self?.navigationController?.popViewController(animated: true)
      }
    }

    OnRewind.pipRestoreState = { [weak self] completion in
      guard let self = self else {
        completion()
        return
      }
      guard let storedEvent = self.storedEvent else {
        completion()
        return
      }
      self.restoreCompletion = completion;
      self.eventsSubject.onNext(storedEvent)
    }

    navigationItem.rightBarButtonItem = item

    item.rx.tap.subscribe(onNext: { [weak self] in
      guard let self = self else { return }
      self.enableAnalyticsDebugView = !self.enableAnalyticsDebugView
      if self.enableAnalyticsDebugView {
        self.item.title = "Disable analytics overlay"
        UIApplication.shared.keyWindow?.addSubview(self.analyticsView)
      } else {
        self.item.title = "Enable analytics overlay"
        self.analyticsView.removeFromSuperview()
      }
    }).disposed(by: disposeBag)

    singleEntryPoint.rx.tap.map({ _ in
      Events.fullscreen(
        try! TestVideoModel.init(
          [
            "title": "World Cup Final",
            "event_id": "78fbebc2-fc52-439e-81f4-8557bba62c1b",
            "event_configuration_url": "https://storage.googleapis.com/static-production.netcosports.com/onrewind/hbs_demo_player_config.json",
            "base_url": "https://api-gateway.onrewind.tv/main-api",
            "account_key": "B1oYoKWDK",
          ]
        )
      )
    }).bind(to: eventsSubject).disposed(by: disposeBag)

    eventsSubject.subscribe(onNext: { [weak self] events in
      guard let self = self else { return }
      self.lastEvent = events
      switch events {
      case .embeded(let model), .list(let model), .fullscreen(let model):
          OnRewind.set(baseUrl: model.baseUrl)
          //        OnRewind.set(vastUrl: "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/ad_rule_samples&ciu_szs=300x250&ad_rule=1&impl=s&gdfp_req=1&env=vp&output=vmap&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ar%3Dpremidpostoptimizedpodbumper&cmsid=496&vid=short_onecue&correlator=")
        let params: OnRewind.EventParams
          if let directUrl = model.directVideoUrl, let streamUrl = URL(string: directUrl) {
          params = .videoStream(streamUrl, isLive: false)
        } else if let configUrl = model.configurationUrl, let url = URL(string: configUrl) {
          params = .configurationURL(url, accountKey: model.accountKey, heatmapUrl: model.heatmapUrl, bettingUrl: model.bettingUrl)
        } else if let eventId = model.eventId {
          params = .eventId(eventId, accountKey: model.accountKey)
        } else {
          return
        }

        switch events {
        case .fullscreen:
            OnRewind.presentPlayer(
              with: params,
              from: self,
              playerWrapperClosure: {
                return AVPlayerDemo()
              },
              playerUIEventsClosure: { event in
                print("TEST ui event: \(event)")
              },
              playerAnalyticsEventsClosure: { event in
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                  self.analyticsView.handle(event: event)
                  guard let window = UIApplication.shared.keyWindow else { return }
                  window.bringSubviewToFront(self.analyticsView)
                  self.analyticsView.pin.horizontally(150.0).bottom().height(50%)
                }
              }
            )
        case .embeded:
          let controller = DetailsViewController(params: params)
          self.navigationController?.pushViewController(controller, animated: true, completion: self.restoreCompletion)
        case .list:
          let controller = ListViewController(params: params)
          self.navigationController?.pushViewController(controller, animated: true, completion: self.restoreCompletion)
        }
      }
    }).disposed(by: disposeBag)

    analyticsView.alpha = 0.8

    view.backgroundColor = .white
    containerView.source.loader = LoaderMediator(loader: self)
    containerView.source.startProgress = { [weak self] _ in
      self?.activityIndicator.startAnimating()
    }
    containerView.source.stopProgress = { [weak self] _ in
      self?.activityIndicator.stopAnimating()
    }
    containerView.source.updateEmptyView = { [weak self] state in
      guard let strongSelf = self else { return }

      switch state {
      case .empty:
        strongSelf.noDataLabel.isHidden = false
        strongSelf.errorLabel.isHidden = true
      case .error:
        strongSelf.noDataLabel.isHidden = true
        strongSelf.errorLabel.isHidden = false
      default:
        strongSelf.noDataLabel.isHidden = true
        strongSelf.errorLabel.isHidden = true
      }
    }
    containerView.collectionViewLayout = collectionViewLayout()

    view.addSubview(containerView)
    view.addSubview(activityIndicator)
    view.addSubview(noDataLabel)
    view.addSubview(errorLabel)
    view.addSubviews(singleEntryPoint)

    noDataLabel.sizeToFit()
    errorLabel.sizeToFit()
    activityIndicator.center = view.center
    noDataLabel.center = view.center
    errorLabel.center = view.center
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    singleEntryPoint.pin.top(view.pin.safeArea.top).horizontally().height(120)

    containerView.pin.below(of: singleEntryPoint).horizontally().bottom()
  }

  func collectionViewLayout() -> UICollectionViewFlowLayout {
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 0
    layout.minimumInteritemSpacing = 0
    layout.sectionInset = UIEdgeInsets(top: 30.0, left: 0.0, bottom: 30, right: 0.0)
    return layout
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    containerView.source.appear()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    containerView.source.disappear()
  }

  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
  }

  typealias Item = Sectionable
  func load(for intent: LoaderIntent) -> Observable<[Sectionable]?>? {
    return Astrolabe.load(pLoader: self, intent: intent)
  }
}

extension HomeViewController: PLoader {

  typealias PLResult = [TestVideoModel?]

  func request(for loadingIntent: LoaderIntent) throws -> Request<[TestVideoModel?]> {
    return try Request<[TestVideoModel?]>(URLString: "https://dl.dropboxusercontent.com/s/aiowk4cw2zduca5/eleven_init_dev.json").setXPath("test_streams").setDisableCache(true)
  }

  func sections(from result: [TestVideoModel?], loadingIntent: LoaderIntent) -> [Sectionable]? {
    let cells: [Cellable] = result.compactMap { $0 }.map { model in
      Cell(data: .init(title: model.title, events: eventsSubject.asObserver().mapObserver({ event -> Events in
        //OnRewind.stopPip()
        switch event {
        case .embeded:
          return .embeded(model)
        case .fullscreen:
          return .fullscreen(model)
        case .list:
          return .list(model)
        }
      })))
    }
    return [Section(cells: cells)]
  }
}