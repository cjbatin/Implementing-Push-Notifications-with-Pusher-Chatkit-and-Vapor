import Vapor

struct RoomController: RouteCollection {
    // 1
    func boot(router: Router) throws {
        let roomsRoute = router.grouped("api", "rooms")
        roomsRoute.post("new", "user", User.parameter, use: createHandler)
        roomsRoute.get(use: getAllHandler)
        roomsRoute.get(Room.parameter, use: getHandler)
    }
    // 2
    func createHandler(
        _ req: Request) throws -> Future<Room> {
        return try flatMap(to: Room.self, req.content.decode(Room.self), req.parameters.next(User.self)) { room, user in
            let chatkitEndPoint = "https://us1.pusherplatform.io/services/chatkit/v2/1a87e1e8-eca4-4109-8b5d-1dce3bdd6eaa/rooms"
            guard let url = URL(string: chatkitEndPoint) else {
                throw Abort.init(HTTPResponseStatus.internalServerError)
            }
            guard let userId = user.id else {
                throw Abort.init(HTTPResponseStatus.notFound)
            }
            let _ = User.find(userId, on: req).unwrap(or: Abort.init(HTTPResponseStatus.notFound))
            room.id = UUID.init()
            let newRoom = room.create(on: req)
            newRoom.save(on: req).whenSuccess({ _ in
                let bearer = BearerAuthorization.init(token: AuthController.createJWToken(withUserId: userId.uuidString))
                _ = try! req.client().post(url) { post in
                    post.http.headers.bearerAuthorization = bearer
                    post.http.headers.add(name: HTTPHeaderName.contentType.description, value: "application/json")
                    try post.content.encode(Room.init(name: room.name))
                }
            })
            return newRoom
        }
    }
    // 3
    func getAllHandler(
        _ req: Request
        ) throws -> Future<[Room]> {
        return Room.query(on: req).all()
    }
    // 4
    func getHandler(_ req: Request) throws -> Future<Room> {
        return try req.parameters.next(Room.self)
    }
}
