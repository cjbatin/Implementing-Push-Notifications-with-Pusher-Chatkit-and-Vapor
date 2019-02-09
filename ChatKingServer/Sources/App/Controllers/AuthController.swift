import Vapor
import Foundation
import PerfectCrypto

final class AuthController {
    
    // Creates a JWT token lasting 15 mins
    static func createJWToken(withUserId userId: String = "MasterShake") -> String {
        let timeStamp = Int(Date.init().timeIntervalSince1970)
        let tstPayload = ["instance": "1a87e1e8-eca4-4109-8b5d-1dce3bdd6eaa",
                          "iss": "api_keys/3c574c00-9fd2-4dfb-9f2d-242b55b57044",
                          "exp": timeStamp + 86400, //24 hours
                          "iat": timeStamp,
                          "sub": userId,
                          "su":true] as [String : Any]
        let secret = "OdY7o9lpx4gYb8sNug1pwj+ppyBbgPPUgA3PBJlAwgU="
        guard let jwt1 = JWTCreator(payload: tstPayload) else {
            return ""
        }
        let token = try! jwt1.sign(alg: .hs256, key: secret)
        return token
    }
}
