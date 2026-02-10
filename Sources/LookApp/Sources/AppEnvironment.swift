import Combine
import Foundation
import LookAutomation
import LookData
import LookKit

@MainActor
final class AppEnvironment: ObservableObject {
    @Published private(set) var isBootstrapped = false
    @Published private(set) var libraryURL: URL?
    @Published var shouldRegenerateThumbnails = false

    let persistenceController: PersistenceController
    let libraryRootStore: LibraryRootStore
    var libraryRootCoordinator: LibraryRootCoordinator
    let featureFlags: FeatureFlagStore
    let telemetry: TelemetryClient
    let automationCoordinator: AutomationCoordinator
    let documentService: DocumentService
    let annotationService: AnnotationService
    let collectionService: CollectionService
    let importService: ImportService
    let thumbnailService: ThumbnailService
    var importCoordinator: ImportCoordinator

    private var cancellables = Set<AnyCancellable>()

    init(
        persistenceController: PersistenceController = .shared,
        libraryRootStore: LibraryRootStore = LibraryRootStore(),
        featureFlags: FeatureFlagStore = FeatureFlagStore(defaults: .standard),
        telemetry: TelemetryClient = TelemetryClient(subsystem: "com.look.app"),
        automationCoordinator: AutomationCoordinator = AutomationCoordinator()
    ) {
        self.persistenceController = persistenceController
        self.libraryRootStore = libraryRootStore
        self.featureFlags = featureFlags
        self.telemetry = telemetry
        self.automationCoordinator = automationCoordinator
        self.libraryRootCoordinator = LibraryRootCoordinator(store: libraryRootStore, telemetry: telemetry)
        self.documentService = DocumentService(persistenceController: persistenceController)
        self.annotationService = AnnotationService(persistenceController: persistenceController)
        self.collectionService = CollectionService(persistenceController: persistenceController)
        self.importService = ImportService(
            persistenceController: persistenceController,
            libraryStore: libraryRootStore
        )
        self.thumbnailService = ThumbnailService(libraryStore: libraryRootStore)
        self.importCoordinator = ImportCoordinator(
            importService: importService,
            documentService: documentService,
            libraryRootCoordinator: libraryRootCoordinator,
            thumbnailService: thumbnailService
        )

        automationCoordinator.registerDefaults()

        // Sync libraryURL from coordinator to trigger SwiftUI updates
        libraryRootCoordinator.$libraryURL
            .receive(on: DispatchQueue.main)
            .sink { [weak self] url in
                self?.libraryURL = url
            }
            .store(in: &cancellables)
    }

    func bootstrap() async {
        guard isBootstrapped == false else { return }
        do {
            if let bookmark = try await libraryRootStore.restorePersistedBookmark() {
                libraryRootCoordinator.activate(url: bookmark)
            } else {
                telemetry.record(event: .librarySetupRequired)
            }
        } catch {
            telemetry.record(error)
            libraryRootCoordinator.presentRecovery(for: error)
        }
        isBootstrapped = true

        // One-time thumbnail regeneration for existing PDFs
        await regenerateThumbnailsIfNeeded()
    }

    // MARK: - One-Time Thumbnail Regeneration

    private static let thumbnailRegenerationKey = "look.thumbnails.regenerated.v1"

    /// Runs a one-time bulk regeneration of thumbnails for every existing PDF.
    /// Gated by a UserDefaults flag so it only executes once per library.
    private func regenerateThumbnailsIfNeeded() async {
        guard !UserDefaults.standard.bool(forKey: Self.thumbnailRegenerationKey) else { return }
        guard let libraryURL = libraryURL else { return }

        // Fetch all documents to get their IDs and PDF paths
        documentService.fetchAllDocuments()
        let documents: [(id: UUID, pdfURL: URL)] = documentService.documents.compactMap { dto in
            guard let url = dto.fileURL else { return nil }
            return (dto.id, url)
        }

        guard !documents.isEmpty else {
            // No documents yet — mark as done so we don't re-check every launch
            UserDefaults.standard.set(true, forKey: Self.thumbnailRegenerationKey)
            return
        }

        let logger = LookLogger(category: "thumbnails")
        logger.info("Starting one-time thumbnail regeneration for \(documents.count) existing PDFs")

        let result = await thumbnailService.regenerateAllThumbnails(
            documents: documents,
            libraryURL: libraryURL
        )

        logger.info("One-time thumbnail regeneration finished — \(result.succeeded) succeeded, \(result.failed) failed")

        // Mark as complete so this never runs again
        UserDefaults.standard.set(true, forKey: Self.thumbnailRegenerationKey)
    }
}
