//
//  CalculateDistance.swift
//  LOChat
//
//  Created by Hasan Bal on 2.04.2020.
//  Copyright © 2020 bal software. All rights reserved.
//

import Foundation

func CalculateDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double ) -> (Double){
    let R = 6371000.0;
    let dLat = (lat1 - lat2);
    let dLon = (lon1 - lon2);
    
    let a = sin(dLat/2) * sin(dLat/2) + cos(lat1) * cos(lat2) * sin(dLon/2) * sin(dLon/2);
    let c = 2*atan2(sqrt(a), sqrt(1-a));
    
    return R*c;
}
