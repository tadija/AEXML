import UIKit
import PlaygroundSupport
import AEXML

//let cardSwipeRequest = ProcessCardSwipeRequest(authentication: authentication,
//                                               cardSwipeInput: cardSwipeInput,
//                                               customerTransactionID: "123",
//                                               transactionInput: transactionInput)
//
//let request = MagensaRequest.processCardSwipe(cardSwipeRequest)
//let soap = request.request
//print(soap.xml)

let magensaErrorURL = Bundle.main.url(forResource: "ProcessCardSwipeApproval", withExtension: "xml")!
let xmlData = try! Data(contentsOf: magensaErrorURL)

do {
    let response = try ProcessCardSwipeResponse(from: xmlData)
    print(response.ticketID)
    print(response.magensaID)
    print(response.error?.errorDescription)
    print(response.output?.transactionID)
    print(response.output?.hostMessage)
} catch {
    print(error)
}
