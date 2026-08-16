//
//  MangaSearchFiltersSheet.swift
//  Animebox
//

import SwiftUI

struct MangaSearchFiltersSheet: View {
    let viewModel: MangaSearchViewModel

    @Environment(\.dismiss) private var dismiss
    @State private var status: MangaSearchStatusFilter
    @State private var type: MangaTypeFilter
    @State private var yearFrom: Int?
    @State private var yearTo: Int?

    init(viewModel: MangaSearchViewModel) {
        self.viewModel = viewModel
        _status = State(initialValue: viewModel.statusFilter)
        _type = State(initialValue: viewModel.typeFilter)
        _yearFrom = State(initialValue: viewModel.yearFrom)
        _yearTo = State(initialValue: viewModel.yearTo)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Estado") {
                    Picker("Estado", selection: $status) {
                        ForEach(MangaSearchStatusFilter.allCases) { filter in
                            Text(filter.displayName).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section("Tipo") {
                    Picker("Tipo", selection: $type) {
                        ForEach(MangaTypeFilter.allCases) { filter in
                            Text(filter.displayName).tag(filter)
                        }
                    }
                }
                Section("Año") {
                    Picker("Desde", selection: $yearFrom) {
                        Text("Cualquiera").tag(Int?.none)
                        ForEach(Self.searchableYears, id: \.self) { year in
                            Text(String(year)).tag(Int?.some(year))
                        }
                    }
                    Picker("Hasta", selection: $yearTo) {
                        Text("Cualquiera").tag(Int?.none)
                        ForEach(Self.searchableYears, id: \.self) { year in
                            Text(String(year)).tag(Int?.some(year))
                        }
                    }
                }
                Section {
                    Button("Restablecer filtros", role: .destructive, action: reset)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Filtros")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Aplicar", action: apply)
                }
            }
        }
    }

    private func reset() {
        status = .all
        type = .all
        yearFrom = nil
        yearTo = nil
    }

    private func apply() {
        viewModel.statusFilter = status
        viewModel.typeFilter = type
        viewModel.yearFrom = yearFrom
        viewModel.yearTo = yearTo
        viewModel.search()
        dismiss()
    }

    /// Años recientes primero; 1960 como límite inferior razonable para no
    /// convertir el picker en una lista interminable.
    private static var searchableYears: [Int] {
        let currentYear = Calendar.current.component(.year, from: .now)
        return Array((1960...(currentYear + 1)).reversed())
    }
}

#if DEBUG
#Preview {
    MangaSearchFiltersSheet(viewModel: MangaSearchViewModel(service: PreviewJikanService()))
        .preferredColorScheme(.dark)
}
#endif
