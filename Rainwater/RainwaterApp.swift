//
//  RainwaterApp.swift
//  Rainwater
//
//  Created by Surya Swaminathan on 10/10/24.
//

import SwiftUI

@main
struct RainwaterApp: App {
    @StateObject var locationManager = LocationManager()
    
    var body: some Scene {
        WindowGroup {
            MenuPage()
                .environmentObject(locationManager)
        }
    }
}
	
