//
//  UserDefaultsBacked.swift
//  GoGoPokemonLook
//
//  Created by 黃柏叡 on 2024/6/27.
//

import Foundation

@propertyWrapper struct UserDefaultsBacked<Value: Codable> {
	enum ValueType {
		case value, object
	}
	
	let storage: UserDefaults
	let key: String
	let defaultValue: Value
	let type: ValueType
	
	var wrappedValue: Value {
		get {
			switch type {
			case .value:
				return storage.value(forKey: key) as? Value ?? defaultValue
			case .object:
				let object: Value? = storage.codableObject(forKey: key) ?? nil
				// DO NOT FIX THE WARNING, for handling the optional generic type
				return object as? Value ?? defaultValue
			}
		}
		set {
			if let optional = newValue as? AnyOptional, optional.isNil {
				storage.removeObject(forKey: key)
				return
			}
			switch type {
			case .value:
				storage.setValue(newValue, forKey: key)
			case .object:
				storage.setObject(newValue, forKey: key)
			}
		}
	}
	
	init(storage: UserDefaults = .standard,
		 key: String,
		 defaultValue: Value,
		 type: ValueType) {
		self.storage = storage
		self.defaultValue = defaultValue
		self.key = key
		self.type = type
	}
	
	init(storage: UserDefaults = .standard,
		 key: UserDefaults.Key,
		 defaultValue: Value,
		 type: ValueType) {
		self.storage = storage
		self.defaultValue = defaultValue
		self.key = key.rawValue
		self.type = type
	}
}
