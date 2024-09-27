//
//  SplashScreenView.swift
//  PicklePlaySB V1
//
//  Created by ganeshan venu on 8/13/24.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false;
    @State private var size = 0.8
    @State private var opacity = 0.5
    var body: some View {
        if isActive{
            SignInUIView() // CHANGE THIS IF YOU WANT TO GO TO MAIN, this is for authentication
            //wip -- the ode guyatt
        }
        else {
            ZStack{
                Color.white.ignoresSafeArea()
                VStack{
                    VStack{
                        Image(systemName: "sportscourt.circle.fill")
                            .font(.system(size:80))
                            .foregroundColor(.blue)
                        Text("PicklePlay SB")
                            .font(Font.custom("Carlito-Bold", size: 26)).padding(.top, 9.5)
                            .foregroundStyle(.black.opacity(0.80))
                    }
                    .scaleEffect(size)
                    .opacity(opacity)
                    .onAppear{
                        withAnimation(.easeIn(duration: 1.2)){
                            self.size = 0.9
                            self.opacity = 1.0
                        }
                        
                    }
                }
                .onAppear{
                    DispatchQueue.main.asyncAfter(deadline: .now()+2.0){self.isActive = true
                    }
                }
            }
        }
        
        

    }
}

#Preview {
    SplashScreenView()
}
