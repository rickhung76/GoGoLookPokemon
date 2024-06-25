//
//  PokemonListRequest.swift
//  GoGoPokemonLook
//
//  Created by 黃柏叡 on 2024/6/25.
//

import Foundation
import FiredTofu
import Combine

class PokemonListRequest: Request {
	
	typealias Response = PokemonList
	
	var baseURL: String {
		"https://pokeapi.co/api/v2"
	}
	
	var path: String {
		"/pokemon"
	}
	
	var httpMethod: HTTPMethod {
		.get
	}
	
	var parameters: Parameters? {
		nil
	}
	
	var urlParameters: Parameters? {
		[
			"limit": limit,
			"offset": offset
		]
	}
	
	var bodyEncoding: ParameterEncoding? {
		.urlEncoding
	}
	
	var headers: HTTPHeaders? {
		.none
	}
		
	let limit: Int
	let offset: Int
	
	init(limit: Int,
		 offset: Int
	) {
		self.limit = limit
		self.offset = offset
	}
}

extension HttpClient: PokemonListDataProvider {
	func fetch(
		offset: Int, 
		limit: Int
	) -> AnyPublisher<PokemonList, NSError> {
		let request = PokemonListRequest(limit: limit, offset: offset)
		return HttpClient.default
			.send(request)
			.mapError({$0.asError()})
			.eraseToAnyPublisher()
	}
}
