import Vapor
import FluentSQLite

final class User: Codable {
    var id: UUID?
    var username: String
    var name: String?

    init(username: String) {
        self.username = username
        self.name = username
    }

    init(id: UUID?, username: String) {
        self.id = id
        self.username = username
        self.name = username
    }
}

extension User: Content {}
extension User: SQLiteUUIDModel {
    static func prepare(on connection: SQLiteConnection)
        -> Future<Void> {
            // 1
            return Database.create(self, on: connection) { builder in
                // 2
                try addProperties(to: builder)
                // 3
                builder.unique(on: \.username)
            }
    }
}
extension User: Migration {}
extension User: Parameter {}
