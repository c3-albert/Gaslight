//
//  SettingsView.swift
//  Gaslight
//
//  Created by Albert Xu on 7/30/25.
//

import SwiftUI

class GaslightSettings: ObservableObject {
    @Published var realityLevel: Double = 1.0
    @Published var autoGenerateEnabled: Bool = true
    @Published var generationFrequency: Double = 0.3 // 30% chance per day
    @Published var colorScheme: ColorScheme = .light
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadSettings()
    }
    
    private func loadSettings() {
        realityLevel = userDefaults.double(forKey: "realityLevel") != 0 ? userDefaults.double(forKey: "realityLevel") : 1.0
        autoGenerateEnabled = userDefaults.bool(forKey: "autoGenerateEnabled")
        generationFrequency = userDefaults.double(forKey: "generationFrequency") != 0 ? userDefaults.double(forKey: "generationFrequency") : 0.3
        
        let savedScheme = userDefaults.string(forKey: "colorScheme") ?? "light"
        colorScheme = savedScheme == "dark" ? .dark : .light
    }
    
    func saveSettings() {
        userDefaults.set(realityLevel, forKey: "realityLevel")
        userDefaults.set(autoGenerateEnabled, forKey: "autoGenerateEnabled")
        userDefaults.set(generationFrequency, forKey: "generationFrequency")
        userDefaults.set(colorScheme == .dark ? "dark" : "light", forKey: "colorScheme")
    }
    
    var realityDescription: String {
        switch realityLevel {
        case 0.9...1.0:
            return "Completely Real"
        case 0.7..<0.9:
            return "Mostly Real"
        case 0.4..<0.7:
            return "Mixed Reality"
        case 0.2..<0.4:
            return "Mostly Fiction"
        case 0.0..<0.2:
            return "Pure Gaslight"
        default:
            return "Reality Unknown"
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject private var settings: GaslightSettings
    @Environment(\.modelContext) private var modelContext
    @StateObject private var aiGenerator = AIEntryGenerator.shared
    @StateObject private var coreMLGenerator = CoreMLTextGenerator.shared
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Text("Appearance")
                            .font(.subheadline)
                        Spacer()
                        Picker("Color Scheme", selection: $settings.colorScheme) {
                            Text("Light").tag(ColorScheme.light)
                            Text("Dark").tag(ColorScheme.dark)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 120)
                        .onChange(of: settings.colorScheme) { _, _ in
                            settings.saveSettings()
                        }
                    }
                } header: {
                    Text("Display")
                }
                
                Section {
                    Toggle("Auto-Generate Entries", isOn: $settings.autoGenerateEnabled)
                        .onChange(of: settings.autoGenerateEnabled) { _, _ in
                            settings.saveSettings()
                        }
                    
                    if settings.autoGenerateEnabled {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Generation Frequency")
                                .font(.subheadline)
                            
                            Slider(value: $settings.generationFrequency, in: 0.1...1.0, step: 0.1)
                                .onChange(of: settings.generationFrequency) { _, _ in
                                    settings.saveSettings()
                                }
                            
                            Text("\(Int(settings.generationFrequency * 100))% chance per day")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Automatic Generation")
                } footer: {
                    Text("When enabled, the app will occasionally generate fake entries automatically.")
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("AI Generation Mode")
                            .font(.subheadline)
                        
                        Picker("AI Mode", selection: $aiGenerator.generationMode) {
                            Text("Templates Only").tag(AIGenerationMode.templates)
                            Text("Core ML Only").tag(AIGenerationMode.coreML)
                            Text("Hybrid Mode").tag(AIGenerationMode.hybrid)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        if aiGenerator.generationMode == .coreML || aiGenerator.generationMode == .hybrid {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Core ML Model Status")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(coreMLGenerator.modelStatus)
                                    .font(.caption)
                                    .foregroundColor(coreMLGenerator.isModelLoaded ? .green : .orange)
                                
                                if !coreMLGenerator.isModelLoaded && !coreMLGenerator.isLoading {
                                    Button("Load GPT-2 Model") {
                                        Task {
                                            try? await coreMLGenerator.loadModel()
                                        }
                                    }
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                }
                                
                                if coreMLGenerator.isLoading {
                                    ProgressView(value: coreMLGenerator.loadingProgress)
                                        .progressViewStyle(LinearProgressViewStyle())
                                }
                            }
                        }
                    }
                } header: {
                    Text("AI Engine")
                } footer: {
                    Text("Templates: Fast, creative responses. Core ML: On-device AI for more natural text. Hybrid: Best of both modes.")
                }
                
                Section {
                    Button("Generate Test Entry") {
                        generateTestEntry()
                    }
                    .foregroundColor(.blue)
                    
                    Button("Generate 30 Days of Entries") {
                        generateBulkEntries()
                    }
                    .foregroundColor(.orange)
                } header: {
                    Text("Testing")
                } footer: {
                    Text("Generate sample entries to test the app. The bulk generation creates entries across the past 30 days with mixed real and AI content.")
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    private func generateTestEntry() {
        Task {
            let generator = AIEntryGenerator.shared
            let content = await generator.generateEntry(realityLevel: 0.2) // Low reality for test
            
            let testEntry = JournalEntry(
                content: content,
                entryType: .aiGenerated,
                realityLevel: 0.2
            )
            
            await MainActor.run {
                modelContext.insert(testEntry)
                
                do {
                    try modelContext.save()
                } catch {
                    print("Failed to save test entry: \(error)")
                }
            }
        }
    }
    
    private func generateBulkEntries() {
        Task {
            let generator = AIEntryGenerator.shared
            let calendar = Calendar.current
            let today = Date()
            
            // Generate entries for the past 30 days
            for daysBack in 0...30 {
                guard let entryDate = calendar.date(byAdding: .day, value: -daysBack, to: today) else { continue }
                
                // Randomly decide how many entries for this day (0-3)
                let entriesForDay = Int.random(in: 0...3)
                
                for _ in 0..<entriesForDay {
                    // Randomize the time of day
                    let hour = Int.random(in: 6...23)
                    let minute = Int.random(in: 0...59)
                    
                    guard let finalDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: entryDate) else { continue }
                    
                    // Randomly choose entry type
                    let entryTypes: [EntryType] = [.userWritten, .aiGenerated, .aiEnhanced]
                    let entryType = entryTypes.randomElement() ?? .userWritten
                    
                    // Generate appropriate content
                    let realityLevel = Double.random(in: 0.1...1.0)
                    let content: String
                    let originalContent: String?
                    
                    switch entryType {
                    case .userWritten:
                        content = generateRealisticUserContent(for: finalDate)
                        originalContent = nil
                    case .aiGenerated:
                        content = await generator.generateEntry(realityLevel: realityLevel)
                        originalContent = nil
                    case .aiEnhanced:
                        let original = generateRealisticUserContent(for: finalDate)
                        content = await generator.enhanceUserEntry(original, realityLevel: realityLevel)
                        originalContent = original
                    }
                    
                    // Create entry with custom date
                    let entry = JournalEntry(
                        content: content,
                        entryType: entryType,
                        realityLevel: realityLevel,
                        originalContent: originalContent,
                        createdDate: finalDate
                    )
                    
                    await MainActor.run {
                        modelContext.insert(entry)
                    }
                }
            }
            
            await MainActor.run {
                do {
                    try modelContext.save()
                    print("Generated bulk entries for past 30 days")
                } catch {
                    print("Failed to save bulk entries: \(error)")
                }
            }
        }
    }
    
    private func generateRealisticUserContent(for date: Date) -> String {
        let userContents = [
            "Had a great day at work today. Finally finished that project I've been working on.",
            "Went for a long walk in the park. The weather was perfect.",
            "Met up with friends for dinner. We tried that new restaurant downtown.",
            "Feeling a bit tired today. Maybe I should go to bed earlier.",
            "Watched a really interesting documentary about ocean life.",
            "Cooked a new recipe for lunch. It turned out better than expected!",
            "Had trouble sleeping last night. Too much on my mind.",
            "Cleaned the entire house today. It feels so much better now.",
            "Started reading a new book. Already hooked after the first chapter.",
            "Went grocery shopping and tried to stick to healthy options.",
            "Had a video call with family. It's been too long since we talked.",
            "Took some photos of the sunset. The colors were incredible.",
            "Feeling grateful for all the good things in my life right now.",
            "Had a lazy Sunday morning with coffee and the newspaper.",
            "Tried meditation for the first time. It was harder than I thought.",
            "Organized my desk and found things I thought I'd lost.",
            "Made plans for the weekend. Looking forward to some downtime.",
            "Had an interesting conversation with a stranger on the bus.",
            "Practiced guitar for an hour. My fingers are getting stronger.",
            "Discovered a new podcast that I'm really enjoying."
        ]
        
        return userContents.randomElement() ?? "Today was an ordinary day, but that's okay too."
    }
}