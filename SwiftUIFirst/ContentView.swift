//
//  ContentView.swift
//  SwiftUIFirst
//
//  Created by Song Liao on 6/11/20.
//  Copyright © 2020 Personal. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            SignUpVideoView()
            PageView(SignUpSectionView.dummy.map {
                SignUpSectionView(content: $0)
            })
        }
	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
		SignUpVideoView()
    }
}
