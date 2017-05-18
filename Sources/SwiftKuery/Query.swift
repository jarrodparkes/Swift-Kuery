/**
 Copyright IBM Corporation 2016
 
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

// MARK: Query protocol

/// A base class for queries.
public class Query: Buildable {
    var cachedQuery: CachedQuery?

    /// Execute the query.
    ///
    /// - Parameter connection: The plugin that implements the Connection protocol and executes the query.
    /// - Parameter onCompletion: The function to be called when the execution of the query has completed.
    public func execute(_ connection: Connection, onCompletion: @escaping ((QueryResult) -> ())) {
        connection.execute(query: self, onCompletion: onCompletion)
    }
    
    /// Execute the query with parameters.
    ///
    /// - Parameter connection: The plugin that implements the Connection protocol and executes the query.
    /// - Parameter parameters: An array of the query parameters.
    /// - Parameter onCompletion: The function to be called when the execution of the query has completed.
    public func execute(_ connection: Connection, parameters: [Any?], onCompletion: @escaping ((QueryResult) -> ())) {
        connection.execute(query: self, parameters: parameters, onCompletion: onCompletion)
    }
    
    /// Execute the query with parameters.
    ///
    /// - Parameter connection: The plugin that implements the Connection protocol and executes the query.
    /// - Parameter parameters: A dictionary of the parameters with parameter names as the keys.
    /// - Parameter onCompletion: The function to be called when the execution of the query has completed.
    public func execute(_ connection: Connection, parameters: [String:Any?], onCompletion: @escaping ((QueryResult) -> ())) {
        connection.execute(query: self, parameters: parameters, onCompletion: onCompletion)
    }
    
    /// Build the query using `QueryBuilder`.
    ///
    /// - Parameter queryBuilder: The QueryBuilder to use.
    /// - Returns: A String representation of the query.
    /// - Throws: QueryError.syntaxError if query build fails.
    public func build(queryBuilder: QueryBuilder) throws -> String {
        return ""
    }
}

struct CachedQuery {
    var query: String
    var queryBuilderName: String
}
