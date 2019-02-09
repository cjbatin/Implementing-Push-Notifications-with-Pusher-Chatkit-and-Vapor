import Vapor
import Foundation
import PerfectCrypto
import FluentSQLite

struct UserController: RouteCollection {
    // 1
    func boot(router: Router) throws {
        let usersRoute = router.grouped("api", "users")
        usersRoute.post("new", use: createHandler)
        usersRoute.post("login", use: find)
        usersRoute.post(User.parameter, "rooms", Room.parameter, use: addRoomsHandler)
        usersRoute.get(User.parameter, "rooms", use: getRoomsHandler)
    }
    // 2
    func find(_ req: Request) throws -> Future<User> {
        return try req.content.decode(User.self).flatMap({ user in
            return User.query(on: req).filter(\.username == user.username).first().map(to: User.self, { user in
                guard let user = user else {
                    throw Abort(.notFound)
                }
                return user
            })
        })
    }
    // 3
    func createHandler(_ req: Request) throws -> Future<User> {
        return try req.content.decode(User.self).flatMap { user in
            let chatkitEndPoint = "https://us1.pusherplatform.io/services/chatkit/v2/1a87e1e8-eca4-4109-8b5d-1dce3bdd6eaa/users"
            guard let url = URL(string: chatkitEndPoint) else {
                throw Abort.init(HTTPResponseStatus.internalServerError)
            }
            user.id = UUID.init()
            let newUser = user.create(on: req)
            newUser.save(on: req).whenSuccess({ _ in
                let bearer = BearerAuthorization.init(token: AuthController.createJWToken())
                _ = try! req.client().post(url) { post in
                    post.http.headers.bearerAuthorization = bearer
                    post.http.headers.add(name: HTTPHeaderName.contentType.description, value: "application/json")
                    try post.content.encode(User.init(id: user.id, username: user.username))
                }
            })
            return newUser
        }
    }

    // 4
    func addRoomsHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(to: HTTPStatus.self, req.parameters.next(User.self), req.parameters.next(Room.self)) { user, room in
            return user.rooms.attach(room, on: req).transform(to: .created)
        }
    }
    // 5
    func getRoomsHandler(_ req: Request) throws -> Future<[Room]> {
        return try req.parameters.next(User.self).flatMap(to: [Room].self) { user in
            try user.rooms.query(on: req).all()
        }
    }
}
