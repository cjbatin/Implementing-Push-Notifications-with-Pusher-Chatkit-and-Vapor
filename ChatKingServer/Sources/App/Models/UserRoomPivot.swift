import FluentSQLite
import Foundation
final class UserRoomPivot: SQLiteUUIDPivot, ModifiablePivot {
    var id: UUID?
    var userID: User.ID
    var roomID: Room.ID
    typealias Left = User
    typealias Right = Room
    static let leftIDKey: LeftIDKey = \.userID
    static let rightIDKey: RightIDKey = \.roomID
    init(_ user: User, _ room: Room) throws {
        self.userID = try user.requireID()
        self.roomID = try room.requireID()
    }
}
extension UserRoomPivot: Migration {}
