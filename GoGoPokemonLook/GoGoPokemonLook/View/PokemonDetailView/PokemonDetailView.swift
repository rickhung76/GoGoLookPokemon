//
//  PokemonDetailView.swift
//  GoGoPokemonLook
//
//  Created by 黃柏叡 on 2024/6/26.
//

import SwiftUI

struct PokemonDetailView: View {
	let pokemon: Pokemon
	
	var body: some View {
		VStack {
			Text(pokemon.name)
				.font(.largeTitle)
			Text(pokemon.url)
				.foregroundColor(.gray)
		}
		.navigationTitle(pokemon.name)
	}
}

#Preview {
    PokemonDetailView(pokemon: Pokemon(name: "種子種子", url: "https://pokeapi.co/api/v2/pokemon/1"))
}
