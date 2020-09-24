//
//  ASWebAuthenticationURLHandler.swift
//  OAuthSwift
//
//  Created by phimage on 01/11/2019.
//  Copyright © 2019 Dongri Jin, Marchand Eric. All rights reserved.
//

import Foundation
#if os(iOS)
import SafariServices
#endif
#if canImport(AuthenticationServices)
import AuthenticationServices
#endif

@available(iOS 13.0, OSX 10.15, macCatalyst 13.0, *)
open class ASWebAuthenticationURLHandler: OAuthSwiftURLHandlerType {
    var webAuthSession: ASWebAuthenticationSession!
    let callbackUrlScheme: String

    weak var presentationContextProvider: ASWebAuthenticationPresentationContextProviding?

    public init(callbackUrlScheme: String, presentationContextProvider: ASWebAuthenticationPresentationContextProviding?) {
        self.callbackUrlScheme = callbackUrlScheme
        self.presentationContextProvider = presentationContextProvider
    }

    public func handle(_ url: URL) {
        webAuthSession = ASWebAuthenticationSession(url: url,
                                                    callbackURLScheme: callbackUrlScheme,
                                                    completionHandler: { callback, error in
                                                        guard error == nil, let successURL = callback else {
                                                            let msg = error?.localizedDescription.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                                                            let urlString = "\(self.callbackUrlScheme)://?error=\(msg ?? "UNKNOWN")"
                                                            guard let url = URL(string: urlString) else {
                                                                return
                                                            }
                                                            
                                                            Self.handle(url: url)
                                                            return
                                                        }
                                                        
                                                        Self.handle(url: successURL)
        })
        webAuthSession.presentationContextProvider = presentationContextProvider

        _ = webAuthSession.start()
    }
    
    private static func handle(url: URL) {
        #if os(iOS) && !OAUTH_APP_EXTENSIONS
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        #else
        // The iOS counterpart requires developers to register custom URL scheme for app and forward throught system available OAuth parameters.
        // Maybe it makes sence to unify flow if you already added such scheme.
        // But, I do not see any reason for us to do this.
        OAuthSwift.handle(url: url)
        #endif
    }
}
