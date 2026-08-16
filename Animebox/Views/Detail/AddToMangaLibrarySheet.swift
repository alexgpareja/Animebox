//
//  AddToMangaLibrarySheet.swift
//  Animebox
//

import SwiftUI
import SwiftData

struct AddToMangaLibrarySheet: View {
    let manga: Manga

    @Environment(\.modelContext) private var context
    @Environment(MALSession.self) private var malSession
    @Environment(\.dismiss) private var dismiss

    @State private var status: MangaStatus = .planned
    @State private var chaptersRead: Int = 0
    @State private var volumesRead: Int = 0
    @State private var personalScore: Int? = nil
    @State private var notes: String = ""
    @State private var startDate: Date = .now
    @State private var finishDate: Date = .now
    @State private var didPrefill = false
    @State private var presentingError = false
    @State private var errorMessage = ""

    private var maxChapters: Int {
        manga.chapters ?? 9_999
    }

    private var maxVolumes: Int {
        manga.volumes ?? 999
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Estado") {
                    Picker("Estado", selection: $status) {
                        ForEach(MangaStatus.allCases) { status in
                            Text(status.displayName).tag(status)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Progreso") {
                    Stepper(value: $chaptersRead, in: 0...maxChapters) {
                        LabeledContent("Capítulo") {
                            if let total = manga.chapters {
                                Text("\(chaptersRead) / \(total)")
                            } else {
                                Text("\(chaptersRead)")
                            }
                        }
                    }
                    Stepper(value: $volumesRead, in: 0...maxVolumes) {
                        LabeledContent("Volumen") {
                            if let total = manga.volumes {
                                Text("\(volumesRead) / \(total)")
                            } else {
                                Text("\(volumesRead)")
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
        let coordinator = LibrarySyncCoordinator(context: context, session: malSession)
        guard let existing = coordinator.mangaStore.entry(for: manga.malId) else { return }
        status = existing.status
        chaptersRead = existing.chaptersRead
        volumesRead = existing.volumesRead
        personalScore = existing.personalScore
        notes = existing.notes ?? ""
        startDate = existing.startDate ?? .now
        if let storedFinish = existing.finishDate {
            finishDate = storedFinish
        }
    }

    private func save() {
        let coordinator = LibrarySyncCoordinator(context: context, session: malSession)
        do {
            try coordinator.upsertManga(
                manga: manga,
                status: status,
                chaptersRead: chaptersRead,
                volumesRead: volumesRead,
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
