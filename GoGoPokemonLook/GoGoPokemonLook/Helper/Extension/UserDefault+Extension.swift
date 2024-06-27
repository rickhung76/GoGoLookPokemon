//
//  UserDefault+Extension.swift
//  GoGoPokemonLook
//
//  Created by 黃柏叡 on 2024/6/27.
//

import Foundation

extension UserDefaults {
	enum Key: String {
		case favoritePokemons
		case apiDataCache
	}
}

extension UserDefaults {
	
	func setObject<CodableObject: Codable>(_ object: CodableObject, forKey key: String) {
		let data = try? JSONEncoder().encode(object)
		UserDefaults.standard.setValue(data, forKey: key)
	}
	
	func codableObject<CodableObject: Codable>(forKey key: String) -> CodableObject? {
		guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
		let element = try? JSONDecoder().decode(CodableObject.self, from: data)
		return element
	}
}

