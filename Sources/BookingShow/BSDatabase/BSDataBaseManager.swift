//
//  BSDataBaseManager.swift
//  BookingShow
//
//  Created by jacob on 2019/7/30.
//  Copyright © 2019 CNjacob. All rights reserved.
//

import Foundation
import PerfectMySQL

// MARK: 数据库信息
let mysql_host = "207.246.98.174"
//let mysql_host = "0.0.0.0"
let mysql_user = "root"
let mysql_password = "Jacob@1121"
let mysql_database = "BookingShow"

// MARK: 表信息
let bookingProductTable = "bs_bookingproduct"
let displayboardTable = "bs_displayboard"
let factoryTable = "bs_factory"
let factoryOrderTable = "bs_factory_order"
let productTable = "bs_product"
let saleOrderTable = "bs_sale_order"
let shoppingTrolleyTable = "bs_shoppingtrolley"
let userTable = "bs_user"
let warehouseTable = "bs_warehouse"


open class BSDataBaseManager {
    fileprivate var mysql : MySQL
    internal init() {
        // 创建MySQL对象
        mysql = MySQL.init()
        // 开启MySQL连接
        guard connectDataBase() else {
            return
        }
    }
    
    /// 连接数据库
    ///
    /// - Returns: 返回连接成功/失败
    private func connectDataBase() -> Bool {
        let connected = mysql.connect(host: mysql_host, user: mysql_user, password: mysql_password, db: mysql_database)
        guard connected else {
            print("connect to database failed: " + mysql.errorMessage())
            return false
        }
        print("connect to database success!")
        return true
    }
    
    /// 执行SQL语句
    ///
    /// - Parameter sql: sql语句
    /// - Returns: 返回元组(success:是否成功 result:结果)
    @discardableResult
    func mysqlStatement(_ sql: String) -> (success: Bool, mysqlResult: MySQL.Results?, errorMsg: String) {
        guard mysql.selectDatabase(named:mysql_database) else {
            //指定操作的数据库
            let msg = "no database: \(mysql_database)"
            print(msg)
            return(false, nil, msg)
        }
        
        // sql语句
        let successQuery = mysql.query(statement: sql)
        guard successQuery else{
            let msg = "execute sql failed: \(sql)"
            print(msg)
            return(false, nil, msg)
        }
        let msg = "execute sql success: \(sql)"
        print(msg)
        // sql执行成功
        return (true, mysql.storeResults(), msg)
    }
    
    
    func selectAllDatabaseSQL(tableName: String) -> (success: Bool, mysqlResult: MySQL.Results?, errorMsg: String) {
        
        let SQL = "SELECT * FROM \(tableName)"
        return mysqlStatement(SQL)
        
    }
    
    func mysqlGetHomeDataResult() -> [Dictionary<String, String>]? {
        let result = selectAllDatabaseSQL(tableName: userTable)
        var resultArray = [Dictionary<String, String>]()
        var dic = [String:String]()
        
        result.mysqlResult?.forEachRow(callback: { (row) in
            dic["bs_user_id"] = row[0]
            dic["bs_user_name"] = row[1]
            dic["bs_user_phoneNo"] = row[2]
            dic["bs_user_type"] = row[3]
            dic["bs_user_createdate"] = row[4]
            dic["bs_user_status"] = row[5]
            resultArray.append(dic)
        })
        
        return resultArray
    }
    
}
