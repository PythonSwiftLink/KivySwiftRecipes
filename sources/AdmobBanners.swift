//
//  Ads.swift
//  ads_example
//
//  Created by MusicMaker on 02/04/2022.
//

import Foundation
import UIKit
import GoogleMobileAds

fileprivate var kivy_viewController: UIViewController? {
    UIApplication.shared.windows.first?.rootViewController
}

class BannerAd {
    
    var banner: GADBannerView?
    private var scaleFactor: CGFloat = 2.0
    var height: Double
    let adUnitID: String
    
    init(unit_id: String, height: Double) {
        self.height = height
        self.adUnitID = unit_id
    }
    
    func disable() {
        if banner != nil {
            banner?.removeFromSuperview()
            banner = nil
            //set self.ads_space in kivy back to 0
        }
        //py?.banner_did_load(w: 0, h: 0)
    }
    
    func show(delegate: GADBannerViewDelegate) {
        guard
            let kivy_vc = kivy_viewController,
            let view = kivy_vc.view
        else { return }
        scaleFactor = view.contentScaleFactor
        
        
        if banner == nil {
            let frame = view.frame
            let viewWidth = frame.width
            let scale = kivy_vc.view.contentScaleFactor
            scaleFactor = scale
            let banner = GADBannerView(adSize: GADAdSizeFromCGSize(CGSize(width: viewWidth, height: self.height / scale)))
            banner.adUnitID = adUnitID
            banner.delegate = delegate
            banner.translatesAutoresizingMaskIntoConstraints = false
            banner.rootViewController = kivy_vc
            kivy_vc.view.addSubview(banner)
            
            let horizontalConstraint = NSLayoutConstraint(item: banner, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
            let verticalConstraint = NSLayoutConstraint(item: banner, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottomMargin, multiplier: 1, constant: 0)
            
            kivy_vc.view.addConstraints([horizontalConstraint, verticalConstraint])
            banner.load(GADRequest())
            self.banner = banner
        }
        
    }
    
}

class StaticAd {
    
    var banner: GADBannerView?
    private var scaleFactor: CGFloat = 2.0
    var height: Double
    let adUnitID: String
    
    init(unit_id: String, height: Double) {
        self.height = height
        adUnitID = unit_id
    }
    
    func disable() {
        if banner != nil {
            banner?.removeFromSuperview()
            banner = nil
            //set self.ads_space in kivy back to 0
        }
        //py?.banner_did_load(w: 0, h: 0)
    }
    
    func show(delegate: GADBannerViewDelegate) {
        if banner == nil {
            guard
                let kivy_vc = kivy_viewController,
                let view = kivy_vc.view
            else { return }
            scaleFactor = view.contentScaleFactor
            
            let frame = view.frame
            let viewWidth = frame.width
            let scale = kivy_vc.view.contentScaleFactor
            let banner = GADBannerView(adSize: GADAdSizeFromCGSize(CGSize(width: viewWidth, height: 180 / scale)))
            banner.adUnitID = adUnitID
            //enable delegate to call bannerViewDidReceiveAd function to set self.ads_space in kivy
            banner.delegate = delegate
            banner.translatesAutoresizingMaskIntoConstraints = false
            banner.rootViewController = kivy_vc
            kivy_vc.view.addSubview(banner)
            
            let horizontalConstraint = NSLayoutConstraint(item: banner, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
            let verticalConstraint = NSLayoutConstraint(item: banner, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
            
            kivy_vc.view.addConstraints([horizontalConstraint, verticalConstraint])
            banner.load(GADRequest())
            self.banner = banner
        }
        
        
    }
}

class FullScreenAd {
    
    
    var banner: GADInterstitialAd?
    let adUnitID: String
    
    init(unit_id: String) {
        adUnitID = unit_id
    }
    
    func show(delegate: GADFullScreenContentDelegate) {
        let request = GADRequest()
        GADInterstitialAd.load(
            withAdUnitID: adUnitID,
            request: request,
            completionHandler: { [self] ad, error in
                if let error = error {
                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                    return
                }
                ad?.fullScreenContentDelegate = delegate
                guard let kivy = kivy_viewController else {return}
                banner = ad
                banner?.present(fromRootViewController: kivy)
            }
        )
        
    }
}

extension PyFullScreenContentDelegate: GADFullScreenContentDelegate {}
extension PyFullScreenContentDelegate: PyConvertible {
    var pyObject: PythonObject { .init(getter: pyPointer) }
    var pyPointer: PyPointer { create_pyPyFullScreenContentDelegate(self) }
}

extension GADFullScreenPresentingAd {
    var pyPointer: PyPointer { create_pyGADFullScreenPresentingAd(self) }
}

extension GADBannerView: PyConvertible {
    public var pyObject: PythonObject { .init(getter: pyPointer) }
    public var pyPointer: PyPointer { create_pyGADBannerView(self) }
}

extension PyBannerViewDelegate: GADBannerViewDelegate {}
extension PyBannerViewDelegate: PyConvertible {
    var pyObject: PythonObject { .init(getter: pyPointer) }
    var pyPointer: PyPointer { create_pyPyBannerViewDelegate(self) }
}
