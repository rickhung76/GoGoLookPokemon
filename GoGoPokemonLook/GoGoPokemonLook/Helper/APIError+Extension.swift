//
//  APIError+Extension.swift
//  GoGoPokemonLook
//
//  Created by 黃柏叡 on 2024/6/25.
//

import Foundation
import FiredTofu

extension APIError {
	func asError() -> NSError {
		NSError(
			domain: "APIError",
			code: statusCode,
			userInfo: ["description": localizedDescription]
		)
	}
}
