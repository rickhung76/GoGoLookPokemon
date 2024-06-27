//
//  HttpClient+Extension.swift
//  GoGoPokemonLook
//
//  Created by 黃柏叡 on 2024/6/27.
//

import FiredTofu
import Foundation

extension HttpClient {
	static let cacheClient: HttpClient = {
		let urlSession =  URLSession(configuration: .default)
		var decisions = Decisions.defaults(urlSession: urlSession)
		
		decisions.insert(
			LocaleCacheDecision(dataCacheProvider: UserDefaultDataPool.shared),
			at: 1
		)
		decisions.insert(
			SendRequestStoreCacheDecision(
				session: urlSession,
				dataCacheProvider: UserDefaultDataPool.shared
			),
			at: 2
		)
		
		decisions.removeAll(where: { $0 is SendRequestDecision })
		
		return HttpClient(decisionRouter: DecisionRouter(with: decisions))
	}()
}

extension UserDefaultDataPool: ApiDataCacheProvider {
	subscript(url: URL) -> Data? {
		get {
			apiDataCache[url.absoluteString]
		}
		set {
			apiDataCache[url.absoluteString] = newValue
		}
	}
}
