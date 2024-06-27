//
//  PokemonListCell.swift
//  GoGoPokemonLook
//
//  Created by 黃柏叡 on 2024/6/27.
//

import SwiftUI

struct PokemonListCell: View {
	
	@ObservedObject var pokemon: PokemonViewModel
	
	let onFavoriteButtonTapped: (PokemonViewModel) -> Void
	
	var body: some View {
		HStack(alignment: .center, spacing: 15) {
			
			Text("\(pokemon.id)\t")
				.onTapGesture {
					print("########")
				}
			
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
			
			Spacer()
			
			Image(systemName: pokemon.isFavorite ? "suit.heart.fill" : "suit.heart")
				.frame(width: 50, height: 50, alignment: .center)
				.foregroundStyle(.red)
				.onTapGesture {
					onFavoriteButtonTapped(pokemon)
				}
		}
		.background {
			NavigationLink(destination: PokemonDetailView(
				model: PokemonDetailModel(pokemon: pokemon)
			)) { EmptyView() }
		}
	}
}

