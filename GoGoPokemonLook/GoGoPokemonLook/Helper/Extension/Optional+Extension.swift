//
//  Optional+Extension.swift
//  GoGoPokemonLook
//
//  Created by 黃柏叡 on 2024/6/27.
//

import Foundation

protocol AnyOptional: ExpressibleByNilLiteral {
	var isNil: Bool { get }
}

extension Optional: AnyOptional {
	var isNil: Bool {
		return self == nil
	}
}
