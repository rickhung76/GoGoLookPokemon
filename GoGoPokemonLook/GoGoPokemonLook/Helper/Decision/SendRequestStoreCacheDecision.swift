//
//  SendRequestStoreCacheDecision.swift
//  GoGoPokemonLook
//
//  Created by 黃柏叡 on 2024/6/27.
//

import Foundation
import FiredTofu

class SendRequestStoreCacheDecision: Decision {
	
	private let session: URLSession
	
	let isPriority: Bool
	
	var dataCacheProvider: ApiDataCacheProvider
	
	init(
		session: URLSession, 
		dataCacheProvider: ApiDataCacheProvider,
		isPriority: Bool = false
	) {
		self.session = session
		self.isPriority = isPriority
		self.dataCacheProvider = dataCacheProvider
	}
	
	/// SendRequestDecision
	/// - Parameter request: Request Protocol 的 Request
	public func shouldApply<Req: Request>(request: Req) -> Bool {
		return request.rawResponse.isNil
	}
	
	public func apply<Req: Request>(
		request: Req,
		decisions: [Decision],
		completion: @escaping (DecisionAction<Req>) -> Void
	) {
		
		guard let formatRequest = request.formatRequest else {
			let err = APIError(.missingRequest)
			completion(.errored(err))
			return
		}
		
		guard request.isValid else {
			let err = APIError(.deprecatedRequest)
			completion(.errored(err))
			return
		}
		
		let queue = isPriority ? Decisions.priorityQueue : Decisions.normalQueue
		queue.async {
			
			let task = self.session.dataTask(with: formatRequest) { data, response, error in
				request.setResponse(data, response: response, error: error)
				if let data = data, let url = request.formatRequest?.url {
					self.dataCacheProvider[url] = data
				}
				completion(.continueWithRequest(request))
			}
			
			request.task = task
			task.resume()
		}
	}
}
