/**
 Copyright IBM Corporation 2016, 2017
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

// MARK: Update

/// The SQL UPDATE statement.
public class Update: Query {
    /// The table to update.
    public let table: Table

    /// The SQL WHERE clause containing the filter for the rows to update.
    /// Could be represented with a `Filter` clause or a `String` containing raw SQL.
    public private (set) var whereClause: QueryFilterProtocol?
    
    /// A String with a clause to be appended to the end of the query.
    public private (set) var suffix: QuerySuffixProtocol?
    
    private let valueTuples: [(Column, Any)]
    
    /// An array of `AuxiliaryTable` which will be used in a query with a WITH clause.
    public private (set) var with: [AuxiliaryTable]?
    
    private var syntaxError = ""
    
    /// Initialize an instance of Update.
    ///
    /// - Parameter table: The table to update.
    /// - Parameter set: An array of (column, value) tuples to set.
    /// - Parameter conditions: An optional where clause to apply.
    public init(_ table: Table, set: [(Column, Any)], where conditions: QueryFilterProtocol?=nil) {
        self.table = table
        self.valueTuples = set
        self.whereClause = conditions
        if set.count == 0 {
            syntaxError = "An empty set of (column, value) tuples. "
        }
    }

    /// Build the query using `QueryBuilder`.
    ///
    /// - Parameter queryBuilder: The QueryBuilder to use.
    /// - Returns: A String representation of the query.
    /// - Throws: QueryError.syntaxError if query build fails.
    public override func build(queryBuilder: QueryBuilder) throws -> String {
        if let cachedQuery = cachedQuery, cachedQuery.queryBuilderName == queryBuilder.name {
            return cachedQuery.query
        }
        
        if syntaxError != "" {
            throw QueryError.syntaxError(syntaxError)
        }
        
        var result = ""
        result.reserveCapacity(200)
        
        if let with = with {
            result += "WITH "
                + "\(try with.map { try $0.buildWith(queryBuilder: queryBuilder) }.joined(separator: ", "))"
                + " "
        }
        
        result += "UPDATE "
        
        result += try table.build(queryBuilder: queryBuilder)
        result += try " SET " + valueTuples.map {
            column, value in "\(Utils.packName(column.name, queryBuilder: queryBuilder)) = \(try Utils.packType(value, queryBuilder: queryBuilder))"
            }.joined(separator: ", ")
        
        if let with = with,
            queryBuilder.withDeleteRequiresUsing {
            result += try " FROM " + with.map { try $0.build(queryBuilder: queryBuilder) }.joined(separator: ", ")
        }
        
        if let whereClause = whereClause {
            result += try " WHERE " + whereClause.build(queryBuilder: queryBuilder)
        }
        if let suffix = suffix {
            result += try " " + suffix.build(queryBuilder: queryBuilder)
        }
        result = Utils.updateParameterNumbers(query: result, queryBuilder: queryBuilder)
        cachedQuery = CachedQuery(query: result, queryBuilderName: queryBuilder.name)
        return result
    }
    
    /// Add an SQL WHERE clause to the update statement.
    ///
    /// - Parameter conditions: The `Filter` clause or a `String` containing the SQL WHERE to apply.
    /// - Returns: A new instance of Update.
    public func `where`(_ conditions: QueryFilterProtocol) -> Update {
        cachedQuery = nil
        if whereClause != nil {
            syntaxError += "Multiple where clauses. "
        }
        else {
            whereClause = conditions
        }
        return self
    }
    
    /// Add a raw suffix to the update statement.
    ///
    /// - Parameter raw: A String with a clause to be appended to the end of the query.
    /// - Returns: A new instance of Update.
    public func suffix(_ raw: String) -> Update {
        cachedQuery = nil
        if suffix != nil {
            syntaxError += "Multiple suffixes. "
        }
        else {
            suffix = raw
        }
        return self
    }
    
    /// Set tables to be used for WITH clause.
    ///
    /// - Parameter tables: A list of the `AuxiliaryTable` to apply.
    /// - Returns: A new instance of Update with tables for WITH clause.
    func with(_ tables: [AuxiliaryTable]) -> Update {
        cachedQuery = nil
        if with != nil {
            syntaxError += "Multiple with clauses. "
        }
        else {
            with = tables
        }
        return self
    }
}
