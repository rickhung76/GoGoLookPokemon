//
//  UserDefaultCodableObjectTests.swift
//  GoGoPokemonLookTests
//
//  Created by 黃柏叡 on 2024/6/27.
//

import XCTest
import Foundation
@testable import GoGoPokemonLook

final class UserDefaultCodableObjectTests: XCTestCase {

	var userDefault: UserDefaults?
	
	override func setUpWithError() throws {
		guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
			throw NSError()
		}
		UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
	}

	override func tearDownWithError() throws {
		guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
			throw NSError()
		}
		UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
	}
	
	func test_valueTypeSetter_shouldSetValueInUserDefault() {
		let stubText = #function
		var sut: UserDefaultsBacked<String?> = .init(storage: .standard, key: #function, defaultValue: "test", type: .value)
		sut.wrappedValue = stubText
		
		XCTAssertEqual(UserDefaults.standard.string(forKey: #function), stubText)
		
		sut.wrappedValue = nil
		
		XCTAssertNil(UserDefaults.standard.string(forKey: #function))
	}
	
	func test_valueTypeGetter_shouldGetValueInUserDefault() {
		let stubText = #function
		let sut: UserDefaultsBacked<String?> = .init(storage: .standard, key: #function, defaultValue: "test", type: .value)
		UserDefaults.standard.set(stubText, forKey: #function)
		
		XCTAssertEqual(sut.wrappedValue, stubText)
	}
	
	func test_valueTypeArraySetter_shouldSetValueInUserDefault() {
		let stubArray = #function.map { "\($0)" }
		var sut: UserDefaultsBacked<[String]?> = .init(storage: .standard, key: #function, defaultValue: "test".map {"\($0)"}, type: .value)
		sut.wrappedValue = stubArray
		
		let assetArray = UserDefaults.standard.array(forKey: #function) as? [String]
		XCTAssertEqual(assetArray, stubArray)
		
		sut.wrappedValue = nil
		
		XCTAssertNil(UserDefaults.standard.array(forKey: #function))
	}
	
	func test_valueTypeArrayGetter_shouldGetValueInUserDefault() {
		let stubArray = #function.map { "\($0)" }
		let sut: UserDefaultsBacked<[String]?> = .init(storage: .standard, key: #function, defaultValue: "test".map {"\($0)"}, type: .value)
		UserDefaults.standard.set(stubArray, forKey: #function)
		
		XCTAssertEqual(sut.wrappedValue, stubArray)
	}
	
	func test_valueTypeDictionarySetter_shouldSetValueInUserDefault() {
		let stubDic = [#function: #function]
		var sut: UserDefaultsBacked<[String: String]?> = .init(storage: .standard, key: #function, defaultValue: [#function: #function], type: .value)
		sut.wrappedValue = stubDic
		
		let assetArray = UserDefaults.standard.dictionary(forKey: #function) as? [String: String]
		XCTAssertEqual(assetArray, stubDic)
		
		sut.wrappedValue = nil
		
		XCTAssertNil(UserDefaults.standard.dictionary(forKey: #function))
	}
	
	func test_valueTypeDictionaryGetter_shouldGetValueInUserDefault() {
		let stubDic = [#function: #function]
		let sut: UserDefaultsBacked<[String: String]?> = .init(storage: .standard, key: #function, defaultValue: [#function: #function], type: .value)
		UserDefaults.standard.set(stubDic, forKey: #function)
		
		XCTAssertEqual(sut.wrappedValue, stubDic)
	}
	
	func test_valueTypeGetter_DefaultValue() {
		let stubText = #function
		let sut: UserDefaultsBacked<String> = .init(storage: .standard, key: #function, defaultValue: stubText, type: .value)
		
		XCTAssertEqual(sut.wrappedValue, stubText)
	}
	
	func test_valueTypeGetter_Nil() {
		let stubText = #function
		let sut: UserDefaultsBacked<String?> = .init(storage: .standard, key: #function, defaultValue: stubText, type: .value)
		
		XCTAssertNil(sut.wrappedValue)
	}
	
	func test_objectTypeSetter_shouldSetDataInUserDefault() {
		struct AObject: Codable, Equatable {
			let s: String
			init(_ s: String) { self.s = s }
		}
		let stubObject = AObject(#function)
		var sut: UserDefaultsBacked<AObject?> = .init(storage: .standard, key: #function, defaultValue: AObject("test"), type: .object)
		sut.wrappedValue = stubObject

		let stubObjectData = try? JSONEncoder().encode(stubObject)
		XCTAssertEqual(UserDefaults.standard.data(forKey: #function), stubObjectData)

		sut.wrappedValue = nil
		XCTAssertNil(UserDefaults.standard.object(forKey: #function))
	}

	func test_objectTypeGetter_shouldGetObjectInUserDefault() {
		struct AObject: Codable, Equatable {
			let s: String
			init(_ s: String) { self.s = s }
		}
		let stubObject = AObject(#function)
		let sut: UserDefaultsBacked<AObject?> = .init(storage: .standard, key: #function, defaultValue: AObject("test"), type: .object)
		UserDefaults.standard.setObject(stubObject, forKey: #function)

		XCTAssertEqual(sut.wrappedValue, stubObject)
	}

	func test_objectTypeGetter_DefaultValue() {
		struct AObject: Codable, Equatable {
			let s: String
			init(_ s: String) { self.s = s }
		}
		let sut: UserDefaultsBacked<AObject> = .init(storage: .standard, key: #function, defaultValue: AObject("test"), type: .object)

		XCTAssertEqual(sut.wrappedValue, AObject("test"))
	}

	func test_objectTypeGetter_Nil() {
		struct AObject: Codable, Equatable {
			let s: String
			init(_ s: String) { self.s = s }
		}
		let sut: UserDefaultsBacked<AObject?> = .init(storage: .standard, key: #function, defaultValue: AObject("test"), type: .object)

		XCTAssertNil(sut.wrappedValue)
	}
}
