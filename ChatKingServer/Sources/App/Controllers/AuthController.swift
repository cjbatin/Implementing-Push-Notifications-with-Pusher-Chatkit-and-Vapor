import Vapor
import Foundation
import PerfectCrypto

final class AuthController {
    
    // Creates a JWT token lasting 15 mins
    static func createJWToken(withUserId userId: String = "MasterShake") -> String {
        let timeStamp = Int(Date.init().timeIntervalSince1970)
        let tstPayload = ["instance": "YOUR_INSTANCE_ID",
                          "iss": "api_keys/YOUR_API_KEY_ID",
                          "exp": timeStamp + 86400, //24 hours
            "iat": timeStamp,
            "sub": userId,
            "su":true] as [String : Any]
        let secret = "YOUR_SECRET_KEY"
        guard let jwt1 = JWTCreator(payload: tstPayload) else {
            return ""
        }
        let token = try! jwt1.sign(alg: .hs256, key: secret)
        return token
    }
}
