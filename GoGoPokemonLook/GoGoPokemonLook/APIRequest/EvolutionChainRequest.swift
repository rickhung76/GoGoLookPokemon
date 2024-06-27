//
//  EvolutionChainRequest.swift
//  GoGoPokemonLook
//
//  Created by 黃柏叡 on 2024/6/26.
//

import Foundation
import FiredTofu
import Combine

class EvolutionChainRequest: Request {
	
	typealias Response = EvolutionChain
	
	var baseURL: String {
		url
	}
	
	var path: String {
		""
	}
	
	var httpMethod: HTTPMethod {
		.get
	}
	
	var parameters: Parameters? {
		nil
	}
	
	var urlParameters: Parameters? {
		nil
	}
	
	var bodyEncoding: ParameterEncoding? {
		.urlEncoding
	}
	
	var headers: HTTPHeaders? {
		.none
	}
		
	let url: String
	
	init(url: String) {
		self.url = url
	}
}

extension HttpClient: PokemonEvolutionChainDataProvider {
	func fetchEvolutionChain(_ url: String) -> AnyPublisher<EvolutionChain, NSError> {
		let request = EvolutionChainRequest(url: url)
		return HttpClient.cacheClient
			.send(request)
			.mapError({$0.asError()})
			.eraseToAnyPublisher()
	}
}

