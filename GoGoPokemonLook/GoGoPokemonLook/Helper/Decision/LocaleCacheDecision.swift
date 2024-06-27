//
//  LocaleCacheDecision.swift
//  GoGoPokemonLook
//
//  Created by 黃柏叡 on 2024/6/27.
//

import Foundation
import FiredTofu

protocol ApiDataCacheProvider {
	subscript(url: URL) -> Data? { get set }
}

struct LocaleCacheDecision: Decision {
	
	let dataCacheProvider: ApiDataCacheProvider
	
	func shouldApply<Req>(request: Req) -> Bool where Req : FiredTofu.Request {
		guard let url = request.formatRequest?.url else { return false }
		return !dataCacheProvider[url].isNil
	}
	
	func apply<Req: FiredTofu.Request>(
		request: Req,
		decisions: [any FiredTofu.Decision],
		completion: @escaping (FiredTofu.DecisionAction<Req>) -> Void
	) {
		DispatchQueue.global(qos: .userInteractive).async {
			guard let url = request.formatRequest?.url,
				  let data = dataCacheProvider[url]
			else {
				completion(.continueWithRequest(request))
				return
			}
		
			let response = HTTPURLResponse(
				url: url,
				statusCode: 200,
				httpVersion: nil,
				headerFields: nil
			)
			request.setResponse(data, response: response, error: nil)
			completion(.continueWithRequest(request))
		}
	}
}

