var routesArr = [Dictionary<String, Any>]()

var someDict1 : [String:String] = ["method":"GET", "baseUri":"/bookingshow/api"]

routesArr.append(someDict1)

let networkServer = BSNetworkServerManager(documentRoot: "webroot", port: 8080, routesArr: routesArr)

networkServer.startServer()
