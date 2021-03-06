
import MonkeyKing
import UIKit

class PocketViewController: UIViewController {

    let account = MonkeyKing.Account.pocket(appID: Configs.Pocket.appID)
    var accessToken: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        MonkeyKing.registerAccount(account)
    }

    // Save URL to Pocket
    @IBAction func saveButtonAction(_ sender: UIButton) {
        guard let accessToken = accessToken else {
            return
        }
        let addAPI = "https://getpocket.com/v3/add"
        let parameters = [
            "url": "http://tips.producter.io",
            "title": "Producter",
            "consumer_key": Configs.Pocket.appID,
            "access_token": accessToken,
        ]
        SimpleNetworking.sharedInstance.request(addAPI, method: .post, parameters: parameters, encoding: .json) { info, _, _ in
            guard let status = info?["status"] as? Int, status == 1 else {
                return
            }
            print("Pocket add url successfully")
        }
        // More API
        // https://getpocket.com/developer/docs/v3/add
    }

    // Pocket OAuth
    @IBAction func OAuth(_ sender: UIButton) {
        let requestAPI = "https://getpocket.com/v3/oauth/request"
        let parameters = [
            "consumer_key": Configs.Pocket.appID,
            "redirect_uri": Configs.Pocket.redirectURL,
        ]
        print("S1: fetch requestToken")
        SimpleNetworking.sharedInstance.request(requestAPI, method: .post, parameters: parameters, encoding: .json) { [weak self] info, response, error in
            guard let strongSelf = self, let requestToken = info?["code"] as? String else {
                return
            }
            print("S2: OAuth by requestToken: \(requestToken)")
            MonkeyKing.oauth(for: .pocket, requestToken: requestToken) { result in
                switch result {
                case .success:
                    let accessTokenAPI = "https://getpocket.com/v3/oauth/authorize"
                    let parameters = [
                        "consumer_key": Configs.Pocket.appID,
                        "code": requestToken,
                    ]
                    print("S3: fetch OAuth state")
                    SimpleNetworking.sharedInstance.request(accessTokenAPI, method: .post, parameters: parameters, encoding: .json) { info, response, _ in
                        print("S4: OAuth completion")
                        print("JSON: \(String(describing: info))")
                        // If the HTTP status of the response is 200, then the request completed successfully.
                        print("response: \(String(describing: response))")
                        strongSelf.accessToken = info?["access_token"] as? String
                    }
                case .failure(let error):
                    print(error)
                }
                // More details
                // Pocket Authentication API Documentation: https://getpocket.com/developer/docs/authentication
            }
        }
    }
}
