//
//  BSNetworkServerManager.swift
//  BookingShow
//
//  Created by jacob on 2019/7/30.
//  Copyright © 2019 CNjacob. All rights reserved.
//

import Foundation
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

open class BSNetworkServerManager {
    fileprivate var server: HTTPServer
    internal init(documentRoot: String, port: UInt16, routesArr: Array<Dictionary<String, Any>>) {
        server = HTTPServer.init()                             // 创建HTTPServer服务器
        for dict: Dictionary in routesArr {
            let baseUri : String = dict["baseUri"] as! String  // 根地址
            let method : String = dict["method"] as! String    // 方法
            var routes = Routes.init(baseUri: baseUri)         // 创建路由器
            let httpMethod = HTTPMethod.from(string: method)
            configure(routes: &routes, method: httpMethod)     // 注册路由
            server.addRoutes(routes)                           // 路由添加进服务
        }
        server.serverName = "localhost"                        // 服务器正式名称
        server.serverPort = port                               // 端口
        server.documentRoot = documentRoot                     // 服务器文档根目录，用于静态文件存储和服务提供
        server.setResponseFilters([(Filter404(), .high)])      // 404过滤
    }
    
    open func startServer() {
        do {
            print("start server")
            try server.start()
        } catch PerfectError.networkError(let err, let msg) {
            print("network error：\(err) \(msg)")
        } catch {
            print("unknown error!")
        }
    }
    
    fileprivate func configure(routes: inout Routes, method: HTTPMethod) {
        if method == .get {
            routes.add(method: .get, uri: "/selectUserInfo") { (request, response) in
                let queryParams = request.queryParams
                var jsonString = ""
                if queryParams.count == 0 {
                    jsonString = self.baseResponseBodyJSONData(code: 200, message: "成功！", data: BSDataBaseManager().mysqlGetHomeDataResult())
                } else {
                    jsonString = self.baseResponseBodyJSONData(code: 200, message: "成功", data: nil)
                }
                response.setBody(string: jsonString)
                response.completed()
            }
            
        } else if method == .post {
            
        }
    }
    
    // MARK: 基础方法
    func baseResponseBodyJSONData(code: Int, message: String, data: Any!) -> String {
        var result = Dictionary<String, Any>()
        result.updateValue(code, forKey: "code")
        result.updateValue(message, forKey: "message")
        if (data != nil) {
            result.updateValue(data!, forKey: "data")
        } else {
            result.updateValue("", forKey: "data")
        }
        guard let jsonString = try? result.jsonEncodedString() else {
            return ""
        }
        return jsonString
    }
    
    struct Filter404: HTTPResponseFilter {
        func filterBody(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {
            callback(.continue)
        }
        
        func filterHeaders(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {
            if case .notFound = response.status {
                response.bodyBytes.removeAll()
                response.setBody(string: "404, The file \(response.request.path) was not found.")
                response.setHeader(.contentLength, value: "\(response.bodyBytes.count)")
                callback(.done)
            } else {
                callback(.continue)
            }
        }
    }
}
