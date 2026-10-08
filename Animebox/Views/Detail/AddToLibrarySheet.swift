//
//  AddToLibrarySheet.swift
//  Animebox
//

import SwiftUI
import SwiftData

struct AddToLibrarySheet: View {
    let anime: Anime

    @Environment(\.modelContext) private var context
    @Environment(LinkedAccount.self) private var linkedAccount
    @Environment(\.dismiss) private var dismiss

    @State private var status: LibraryStatus = .planned
    @State private var progress: Int = 0
    @State private var personalScore: Int? = nil
    @State private var notes: String = ""
    @State private var startDate: Date = .now
    @State private var finishDate: Date = .now
    @State private var didPrefill = false
    @State private var presentingError = false
    @State private var errorMessage = ""

    private var maxEpisodes: Int {
        anime.episodes ?? 9_999
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Estado") {
                    Picker("Estado", selection: $status) {
                        ForEach(LibraryStatus.allCases) { status in
                            Text(status.displayName).tag(status)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Progreso") {
                    Stepper(value: $progress, in: 0...maxEpisodes) {
                        LabeledContent("Episodio") {
                            if let total = anime.episodes {
                                Text("\(progress) / \(total)")
                            } else {
                                Text("\(progress)")
                            }
                        }
                    }
                }

                Section("Puntuación personal") {
                    Picker("Puntuación", selection: $personalScore) {
                        Text("Sin puntuar").tag(Int?.none)
                        ForEach(1...10, id: \.self) { value in
                            Text(value, format: .number).tag(Int?.some(value))
                        }
                    }
                }

                Section("Fechas") {
                    DatePicker(
                        "Fecha de inicio",
                        selection: $startDate,
                        displayedComponents: .date
                    )
                    if status == .completed {
                        DatePicker(
                            "Fecha de finalización",
                            selection: $finishDate,
                            displayedComponents: .date
                        )
                    }
                }

                Section("Notas") {
                    TextField("Notas (opcional)", text: $notes, axis: .vertical)
                        .lineLimit(3...)
                }
            }
            .navigationTitle("Mi entrada")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar", action: save)
                }
            }
            .onAppear(perform: prefillIfNeeded)
            .alert("No se pudo guardar", isPresented: $presentingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func prefillIfNeeded() {
        guard !didPrefill else { return }
        didPrefill = true
        let coordinator = LibrarySyncCoordinator(context: context, account: linkedAccount)
        guard let existing = coordinator.libraryStore.entry(
            for: anime.malId, provider: coordinator.currentProvider
        ) else { return }
        status = existing.status
        progress = existing.progress
        personalScore = existing.personalScore
        notes = existing.notes ?? ""
        startDate = existing.startDate ?? .now
        if let storedFinish = existing.finishDate {
            finishDate = storedFinish
        }
    }

    private func save() {
        let coordinator = LibrarySyncCoordinator(context: context, account: linkedAccount)
        do {
            try coordinator.upsertAnime(
                anime: anime,
                status: status,
                progress: progress,
                personalScore: personalScore,
                notes: notes.isEmpty ? nil : notes,
                startDate: startDate,
                finishDate: status == .completed ? finishDate : nil
            )
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            presentingError = true
        }
    }
}
