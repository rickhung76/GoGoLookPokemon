//
//  DataPool.swift
//  GoGoPokemonLook
//
//  Created by 黃柏叡 on 2024/6/27.
//

import Foundation

class UserDefaultDataPool {
	static let shared = UserDefaultDataPool()
	
	@UserDefaultsBacked(key: .favoritePokemons, defaultValue: FavoritePokemonList(pokemons: []), type: .object)
	var favoritePokemons: FavoritePokemonList
	
	@UserDefaultsBacked(key: .apiDataCache, defaultValue: [String: Data](), type: .value)
	var apiDataCache:  [String: Data]
}
