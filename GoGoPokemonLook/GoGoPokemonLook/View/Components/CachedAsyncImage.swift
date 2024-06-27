//
//  CachedAsyncImage.swift
//  GoGoPokemonLook
//
//  Created by 黃柏叡 on 2024/6/27.
//

import SwiftUI

struct CachedAsyncImage<Content>: View where Content: View {

	private let url: URL?
	private let scale: CGFloat
	private let transaction: Transaction
	private let content: (AsyncImagePhase) -> Content

	init(
		url: URL?,
		scale: CGFloat = 1.0,
		transaction: Transaction = Transaction(),
		@ViewBuilder content: @escaping (AsyncImagePhase) -> Content
	) {
		self.url = url
		self.scale = scale
		self.transaction = transaction
		self.content = content
	}

	var body: some View {

		if let url = url,
		   let cached = ImageCache[url] {
			content(.success(cached))
		} else {
			AsyncImage(
				url: url,
				scale: scale,
				transaction: transaction
			) { phase in
				cacheAndRender(phase: phase)
			}
		}
	}

	func cacheAndRender(phase: AsyncImagePhase) -> some View {
		if case .success(let image) = phase,
		   let url = url {
			ImageCache[url] = image
		}
		return content(phase)
	}
}

#Preview {
	CachedAsyncImage(
		url: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png")!
	) { phase in
		switch phase {
		case .empty:
			ProgressView()
		case .success(let image):
			image
		case .failure(_):
			Text("🚫")
		@unknown default:
			fatalError()
		}
	}
}


fileprivate class ImageCache {
	static private var cache: [URL: Image] = [:]

	static subscript(url: URL) -> Image? {
		get {
			ImageCache.cache[url]
		}
		set {
			ImageCache.cache[url] = newValue
		}
	}
}
