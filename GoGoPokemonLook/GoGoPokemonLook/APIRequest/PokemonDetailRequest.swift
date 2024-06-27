//
//  PokemonDetailRequest.swift
//  GoGoPokemonLook
//
//  Created by 黃柏叡 on 2024/6/25.
//

import Foundation
import FiredTofu
import Combine

class PokemonDetailRequest: Request {
	
	typealias Response = PokemonDetail
	
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

extension HttpClient: PokemonDetailDataProvider {
	func fetchDetail(_ url: String) -> AnyPublisher<PokemonDetail, NSError> {
		let request = PokemonDetailRequest(url: url)
		return HttpClient.cacheClient
			.send(request)
			.mapError({$0.asError()})
			.eraseToAnyPublisher()
	}
	
	func fetchDetail(_ url: String) async throws -> PokemonDetail {
		let request = PokemonDetailRequest(url: url)
		return try await HttpClient.cacheClient.send(request)
	}
}
