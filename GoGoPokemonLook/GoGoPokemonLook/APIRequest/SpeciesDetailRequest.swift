//
//  SpeciesDetailRequest.swift
//  GoGoPokemonLook
//
//  Created by 黃柏叡 on 2024/6/26.
//

import Foundation
import FiredTofu
import Combine

class SpeciesDetailRequest: Request {
	
	typealias Response = SpeciesDetail
	
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

extension HttpClient: PokemonSpeciesDataProvider {
	func fetchSpecies(_ url: String) -> AnyPublisher<SpeciesDetail, NSError> {
		let request = SpeciesDetailRequest(url: url)
		return HttpClient.default
			.send(request)
			.mapError({$0.asError()})
			.eraseToAnyPublisher()
	}
}
