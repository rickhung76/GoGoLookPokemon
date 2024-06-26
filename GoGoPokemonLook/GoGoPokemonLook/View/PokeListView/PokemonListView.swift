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
			NavigationLink(destination: PokemonDetailView(pokemon: element)) {
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
	
	@ObservedObject var pokemon: Pokemon
	
	var body: some View {
		HStack(alignment: .center, spacing: 20) {
			Text("\(pokemon.id)\t")
			AsyncImage(url: URL(string: pokemon.detail?.sprites.frontDefault ?? ""))
				.frame(width: 50, height: 50, alignment: .center)
			Text("\t\(pokemon.name)")
			Text(pokemon.detail?.types.first?.type.name ?? "")
		}
	}
}

#Preview {
	PokemonListView()
}
