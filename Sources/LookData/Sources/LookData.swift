import Foundation

public enum LookData {
    public static let persistenceController = PersistenceController.shared

    public static func makeBackgroundContext() -> PersistenceController.Context {
        persistenceController.newBackgroundContext()
    }
}
