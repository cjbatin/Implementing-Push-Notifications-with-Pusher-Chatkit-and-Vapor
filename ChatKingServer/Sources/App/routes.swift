import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {

    let roomsController = RoomController()
    try router.register(collection: roomsController)

    let usersController = UserController()
    try router.register(collection: usersController)

    router.post("auth", String.parameter) { req -> Token in
        let userId = try req.parameters.next(String.self)
        let userJWToken = AuthController.createJWToken(withUserId: userId)
        let jWToken = AuthController.createJWToken()
        return Token.init(access_token: userJWToken,
                          refresh_token: jWToken,
                          user_id: userId,
                          token_type: "access_token",
                          expires_in: 86400)
    }

    struct Token: Content {
        var access_token: String
        var refresh_token: String
        var user_id: String
        var token_type: String
        var expires_in: Int
    }
}
