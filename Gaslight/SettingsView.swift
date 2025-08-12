//
//  SettingsView.swift
//  Gaslight
//
//  Created by Albert Xu on 7/30/25.
//

import SwiftUI
import UniformTypeIdentifiers

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
    @StateObject private var groqGenerator = GroqAIGenerator.shared
    @State private var showingFileImporter = false
    @State private var showingAPIKeyAlert = false
    @State private var tempAPIKey = ""
    @State private var testPrompts: [String] = []
    @State private var isTestingCustomPrompts = false
    
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
                        Text("AI Mode")
                            .font(.subheadline)
                        
                        Text("Using Groq API for AI generation")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        if aiGenerator.generationMode == .groq {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Groq API Key")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Text(groqGenerator.apiKey.isEmpty ? "❌ Not Set" : "✅ Configured")
                                        .font(.caption)
                                        .foregroundColor(groqGenerator.apiKey.isEmpty ? .red : .green)
                                }
                                
                                Button(groqGenerator.apiKey.isEmpty ? "Add API Key" : "Update API Key") {
                                    tempAPIKey = groqGenerator.apiKey
                                    showingAPIKeyAlert = true
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                                
                                if !groqGenerator.apiKey.isEmpty {
                                    HStack {
                                        Text("Model: \(groqGenerator.selectedModel.displayName)")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                        
                                        Spacer()
                                        
                                        Button("Test Connection") {
                                            testGroqConnection()
                                        }
                                        .font(.caption2)
                                        .foregroundColor(.orange)
                                        
                                        Button("Delete Key") {
                                            groqGenerator.deleteAPIKey()
                                        }
                                        .font(.caption2)
                                        .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                    }
                } header: {
                    Text("AI Engine")
                } footer: {
                    Text("Groq provides fast, high-quality AI generation. Get your free API key at console.groq.com/keys. Your API key is stored securely in the iOS Keychain.")
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
                    
                    Button("Import Custom Test Prompts") {
                        showingFileImporter = true
                    }
                    .foregroundColor(.green)
                    
                    if !testPrompts.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Loaded \(testPrompts.count) custom prompts")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Button("Test All AI Modes with Custom Prompts") {
                                testCustomPromptsWithAllModes()
                            }
                            .foregroundColor(.purple)
                            .disabled(isTestingCustomPrompts)
                            
                            if isTestingCustomPrompts {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                    }
                } header: {
                    Text("Testing")
                } footer: {
                    Text("Generate sample entries or import a text file with your own prompts (one per line) to test across all AI modes.")
                }
            }
            .navigationTitle("Settings")
            .fileImporter(
                isPresented: $showingFileImporter,
                allowedContentTypes: [.plainText],
                allowsMultipleSelection: false
            ) { result in
                handleFileImport(result)
            }
            .alert("Groq API Key", isPresented: $showingAPIKeyAlert) {
                TextField("gsk_...", text: $tempAPIKey)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                
                Button("Save") {
                    groqGenerator.saveAPIKey(tempAPIKey)
                }
                .disabled(tempAPIKey.isEmpty)
                
                Button("Cancel", role: .cancel) {
                    tempAPIKey = ""
                }
            } message: {
                Text("Enter your Groq API key from console.groq.com/keys. It will be stored securely in the iOS Keychain with hardware-backed encryption.")
            }
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
    
    private func testGroqConnection() {
        Task {
            let success = await groqGenerator.testConnection()
            await MainActor.run {
                print(success ? "✅ Groq connection successful" : "❌ Groq connection failed")
            }
        }
    }
    
    private func generateRealisticUserContent(for date: Date) -> String {
        let userContents = [
            "work was actually ok today. got stuff done for once",
            "couldn't sleep last night... phone died so just laid there thinking",
            "grabbed coffee with sarah. she's dealing with the same stuff at her job lol",
            "tried to meal prep but ended up ordering pizza instead. classic me",
            "mom called asking about my life. told her im fine which is mostly true",
            "commute took forever. some accident on the highway, everyone just sitting there",
            "finally cleaned my room. found like 3 phone chargers i thought i lost",
            "watched netflix till 2am even though i have work tomorrow. no regrets",
            "went grocery shopping without a list. bought everything except what i actually need",
            "that meeting couldve been an email. spent an hour discussing nothing",
            "weather was perfect so i walked instead of taking the bus. small wins",
            "tried cooking something fancy. smoke alarm went off but it was edible",
            "spent way too much time scrolling social media. everyone looks so happy",
            "laundry has been in the basket for 3 days. wearing my backup underwear",
            "called my dentist to reschedule again. 6 months later still avoiding it",
            "discovered a new podcast. binged 4 episodes while doing dishes",
            "friend canceled plans last minute. honestly kinda relieved",
            "bought plants at the store. hopefully these ones dont die immediately",
            "traffic was terrible but this song came on that made it bearable",
            "realized i forgot to eat lunch until 4pm. grabbed a granola bar and called it good",
            "coworker was being weird today. not sure if its me or them",
            "tried to organize my photos. gave up after 20 minutes. too many screenshots"
        ]
        
        return userContents.randomElement() ?? "today was fine i guess. things happened"
    }
    
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            do {
                let content = try String(contentsOf: url, encoding: .utf8)
                let prompts = content.components(separatedBy: .newlines)
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
                
                testPrompts = prompts
                print("Loaded \(prompts.count) custom prompts")
            } catch {
                print("Failed to read file: \(error)")
            }
            
        case .failure(let error):
            print("File import failed: \(error)")
        }
    }
    
    private func testCustomPromptsWithAllModes() {
        guard !testPrompts.isEmpty else { return }
        
        isTestingCustomPrompts = true
        
        Task {
            let modes: [(AIGenerationMode, String)] = [
                (.groq, "Groq API")
            ]
            
            let realityLevels = [0.1, 0.5, 0.9]
            let originalMode = aiGenerator.generationMode
            
            for prompt in testPrompts {
                for (mode, _) in modes {
                    aiGenerator.generationMode = mode
                    
                    for realityLevel in realityLevels {
                        let content = await aiGenerator.enhanceUserEntry(prompt, realityLevel: realityLevel)
                        
                        let testEntry = JournalEntry(
                            content: content,
                            entryType: .aiEnhanced,
                            realityLevel: realityLevel,
                            originalContent: prompt
                        )
                        
                        await MainActor.run {
                            modelContext.insert(testEntry)
                        }
                        
                        // Small delay to prevent overwhelming the system
                        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds for API calls
                    }
                }
            }
            
            // Restore original mode
            aiGenerator.generationMode = originalMode
            
            await MainActor.run {
                do {
                    try modelContext.save()
                    print("Generated entries for all custom prompts across all AI modes")
                } catch {
                    print("Failed to save custom prompt entries: \(error)")
                }
                
                isTestingCustomPrompts = false
            }
        }
    }
}