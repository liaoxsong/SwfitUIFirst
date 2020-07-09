//
//  SignUpSectionView.swift
//  SwiftUIFirst
//
//  Created by Song Liao on 7/9/20.
//  Copyright © 2020 Personal. All rights reserved.
//

import Foundation
import SwiftUI

struct SignUpSectionView: View {

    var content: String
    var body: some View {
        Text(content)
        .bold()
        .font(.system(size: 30))
        .foregroundColor(.white)
    }

    static let dummy = ["First Page", "Second Page", "Third Page", "Last Page"]
}
