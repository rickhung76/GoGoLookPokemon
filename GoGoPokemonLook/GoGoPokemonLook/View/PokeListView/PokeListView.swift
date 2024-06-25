//
//  PokeListView.swift
//  GoGoPokemonLook
//
//  Created by 黃柏叡 on 2024/6/24.
//

import SwiftUI
import FiredTofu

struct PokeListView: View {
	
	@ObservedObject var model = PokemonListModel(
		pokemonDataProvider: HttpClient.default
	)

    var body: some View {
		List(0 ..< model.pokemons.count, id: \.self) { i in
			let element = model.pokemons[i]
			let isLast = i == (model.pokemons.count - 1)
			cellView(data: element)
				.onAppear {
					guard isLast else { return }
					print("Fetching from \(model.offset)~\(model.offset + model.limit - 1)")
					model.fetchPokemons(
						offset: model.offset,
						limit: model.limit
					)
				}
		}
		.onAppear {
			model.fetchPokemons(
				offset: model.offset,
				limit: model.limit
			)
		}
    }
}

struct cellView: View {
	
	let data: Pokemon
		
	var body: some View {
		HStack(alignment: .center, spacing: 20, content: {
			Text("\(data.id)")
			Text(data.name)
			Text("Type")
		})
	}
}

#Preview {
    PokeListView()
}
