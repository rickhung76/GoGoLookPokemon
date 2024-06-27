//
//  CachedAsyncImage.swift
//  GoGoPokemonLook
//
//  Created by 黃柏叡 on 2024/6/27.
//

import SwiftUI

struct CachedAsyncImage: View {
	
	@State private var phase: AsyncImagePhase
	let urlRequest: URLRequest
	var session: URLSession
	
	init(url: URL, session: URLSession = .imageSession) {
		self.session = session
		self.urlRequest = URLRequest(url: url)
		
		if let data = session.configuration.urlCache?.cachedResponse(for: urlRequest)?.data,
		   let uiImage = UIImage(data: data) {
			phase = .success(.init(uiImage: uiImage))
		} else {
			phase = .empty
		}
	}
	
	var body: some View {
		Group {
			switch phase {
			case .empty:
				ProgressView().task { await load() }
			case .success(let image):
				image.resizable().scaledToFill()
			case .failure:
				ProgressView()
			@unknown default:
				fatalError("This has not been implemented.")
			}
		}.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
	
	func load() async {
		do {
			let (data, response) = try await session.data(for: urlRequest)
			guard let response = response as? HTTPURLResponse,
				  200...299 ~= response.statusCode,
				  let uiImage = UIImage(data: data)
			else {
				throw URLError(.badServerResponse)
			}
			
			phase = .success(.init(uiImage: uiImage))
		} catch {
			phase = .failure(error)
		}
	}
}

extension URLSession {
	static let imageSession: URLSession = {
		let config = URLSessionConfiguration.default
		config.urlCache = .imageCache
		return .init(configuration: config)
	}()
}

extension URLCache {
	static let imageCache: URLCache = {
		.init(
			memoryCapacity: 20 * 1024 * 1024,
			diskCapacity: 30 * 1024 * 1024
		)
	}()
}
