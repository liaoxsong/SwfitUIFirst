//
//  ContentView.swift
//  SwiftUIFirst
//
//  Created by Song Liao on 6/11/20.
//  Copyright © 2020 Personal. All rights reserved.
//

import SwiftUI

enum Gender: Int, Identifiable {
    var id: Int { rawValue }

    // api codes: 0=Not known, 1=Male, 2=Female, 9=Non-binary
    case unknown = 0
    case male = 1
    case female = 2
    case nonBinary = 9

    var printable: String {
        switch self {
        case .unknown: return "Unknown"
        case .male: return "Male"
        case .female: return "Female"
        case .nonBinary: return "Non-binary"
        }
    }

    var apiCode: Int { rawValue }

    static let pickerChoices: [Gender] = [.female, .male, .nonBinary]
}

class SignUpUserObject: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var birthdate: Date = .distantPast
    @Published var gender: Gender = .unknown
    @Published var fullName: String = ""
    @Published var preferredName: String = ""
}

struct SignUpWhatsYourEmail: View {
    @EnvironmentObject var flowState: SignUpLoginFlowState
    @State private var email: String = ""

    @State var showPassword = false

    @State var uuid = UUID()
    
    var body: some View {
        VStack(spacing: 55.0) {
            Text("What's your email?")
                .font(.largeTitle)
            TextField("Email", text: self.$email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .background(Color.black.opacity(0.30))

            Button("Next Page") {
                self.flowState.truncateHere()
                self.flowState.content.append(AnyView(SignUpCreateAPassword(email: self.$email)))
                self.flowState.forward()
            }
        }.padding()
        .debug("Email is \(self.email)")
        .debug("Email uuid \(self.uuid.uuidString)")
    }
}

struct ShowResultsView: View {
    var email: String
    var password: String

    var body: some View {
        VStack(spacing: 55.0) {
            Text("Results")
                .font(.largeTitle)
            VStack(alignment: .leading) {
                HStack {
                    Text("Email:")
                        .font(.title)
                    Spacer()
                    Text(self.email)
                        .font(.body)
                }
                HStack {
                    Text("Password:")
                        .font(.title)
                    Spacer()
                    Text(self.password)
                        .font(.body)
                }
            }
        }
    }
}

struct SignUpCreateAPassword: View {
    @Binding var email: String

    @EnvironmentObject var flowState: SignUpLoginFlowState

    @State private var password: String = ""

    @State var showPassword = false

    var body: some View {
        VStack(spacing: 55.0) {
            Text("Create a password")
                .font(.largeTitle)
            Toggle(isOn: $showPassword) { Text("show password")}
            Group {
                // Might need to do some sort of custom UITextField subclass to flip between
                // showing and hiding keyboard focus.  When I do it without, I am getting loss
                // of input focus on the transition.  We might have better control over that on
                // UIKit.  Make everything else work and come back to this, if needed.
                if self.showPassword {
                    TextField("Password", text: self.$password)
                        .textContentType(.newPassword)
                } else {
                    SecureField("Password", text: self.$password)
                        .textContentType(.newPassword)
                }
            }.background(Color.black.opacity(0.30))

            Button("Next Page") {
                self.flowState.content.append(AnyView(ShowResultsView(email: self.email, password: self.password)))
                self.flowState.forward()
            }
        }.padding()
        .debug("Pssword is \(self.password)")
    }
}

struct LoginOrSignUp: View {
    @EnvironmentObject var flowState: SignUpLoginFlowState

    let loginFlow: [AnyView] = [
        AnyView(Text("LOGIN FLOW 1").foregroundColor(.white)),
        AnyView(SignUpSectionView(content: "LOGIN FLOW 2")),
        AnyView(Button("AND NUMBER 3") { print("yepper") })
    ]

    let signupFlow: [AnyView] = [
        AnyView(SignUpWhatsYourEmail()),
//        AnyView(SignUpCreateAPassword()),
//        AnyView(SignUpSectionView(content: "SIGN UP FLOW 1")),
//        AnyView(Text("SIGN UP FLOW #2").foregroundColor(.white)),
//        AnyView(Button("AND SOM OTHER 3rd THING") { print("yepper") })
    ]

    var body: some View {
        VStack(spacing: 50.0) {
            Button("Log in") {
                self.flowState.truncateHere()
                self.flowState.content.append(contentsOf: self.loginFlow)
                self.flowState.forward()
            }
            Button("Sign Up") {
                self.flowState.truncateHere()
                self.flowState.content.append(contentsOf: self.signupFlow)
                self.flowState.forward()
            }
        }
    }
}


class SignUpLoginFlowState: ObservableObject {
    @Published var currentPage = 0
    @Published var content: [AnyView] = [ AnyView(EmptyView()) ]

    public func back() {
        let newPage = max(currentPage - 1, 0)
        if newPage != currentPage {
            currentPage = newPage
        }
    }

    public func forward() {
        let newPage = min(currentPage + 1, content.count - 1)
        if newPage != currentPage {
            currentPage = newPage
        }
    }

    public func truncateHere() {
        let num = self.content.count
        if num > currentPage + 1 {
            self.content.removeLast(num - 1)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject private var flowState: SignUpLoginFlowState
//    @EnvironmentObject var signUpUser: SignUpUserObject

    var body: some View {
        ZStack {
            SignUpVideoView()
            VStack {
                HStack {
                    Button("BACK") {
                        // how to go back here
                        //self.currentPage = max(self.currentPage - 1, 0)
                        self.flowState.back()
                    }
                    Spacer()
                    Button("NEXT") {
                        // how to go back here
                        // self.currentPage = min(self.currentPage + 1, self.content.count - 1)
                        self.flowState.forward()
                    }
                }
                PageView(currentPage: self.$flowState.currentPage, self.flowState.content)
            }
        }
//        .environmentObject(self.flowState)
//        .environmentObject(self.signUpUser)
        .environment(\.colorScheme, .dark)
        .foregroundColor(.white)

        .onAppear {
            // Replace the initial EmptyView with the login/signup screen
            self.flowState.content[0] = AnyView(LoginOrSignUp())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpVideoView()
    }
}
