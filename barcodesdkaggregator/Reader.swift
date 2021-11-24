//
//  Reader.swift
//  barcodesdkaggregator
//
//  Created by xulihang on 2021/11/23.
//

import Foundation
import UIKit

protocol Reader {
   func decode (image:UIImage) async ->NSArray
}
