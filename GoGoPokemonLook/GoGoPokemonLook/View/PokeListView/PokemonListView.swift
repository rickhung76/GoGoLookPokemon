//
//  PokemonListView.swift
//  GoGoPokemonLook
//
//  Created by 黃柏叡 on 2024/6/24.
//

import SwiftUI
import FiredTofu

struct PokemonListView: View {
	
	@ObservedObject var model = PokemonListModel(
		pokemonDataProvider: HttpClient.default
	)
	
	var body: some View {
		List(0 ..< model.pokemons.count, id: \.self) { i in
			let element = model.pokemons[i]
			let isLast = i == (model.pokemons.count - 1)
			NavigationLink(destination: PokemonDetailView(
					model: PokemonDetailModel(pokemon: element)
			)) {
				cellView(pokemon: element)
					.onAppear {
						guard isLast else { return }
						print("Fetching from \(model.offset)~\(model.offset + model.limit - 1)")
						model.fetchPokemons(
							offset: model.offset,
							limit: model.limit
						)
					}
			}
		}
		.onAppear {
			guard model.pokemons.isEmpty else { return }
			model.fetchPokemons(
				offset: model.offset,
				limit: model.limit
			)
		}
	}
}

struct cellView: View {
	
	@ObservedObject var pokemon: PokemonViewModel
	
	var body: some View {
		HStack(alignment: .center, spacing: 20) {
			Text("\(pokemon.id)\t")
			
			CachedAsyncImage(
				url: URL(string: pokemon.detail?.sprites.frontDefault ?? "")
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
			}.frame(width: 50, height: 50, alignment: .center)
			
			VStack(alignment: .leading) {
				Text("\(pokemon.name)")
					.font(.title3)
				Text(pokemon.typesString)
					.foregroundStyle(.gray)
			}
		}
	}
}

#Preview {
	PokemonListView()
}
