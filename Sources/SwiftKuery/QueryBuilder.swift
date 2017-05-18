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

// MARK: QueryBuilder

/// Used in code dealing with variances between the various database engines. As
/// different databases have different query syntax, sometimes changes need to be
/// made when generating the actual SQL statement to run. Additional needed changes
/// should be done by updating QueryBuilder substitutions array. Every query component
/// then builds its string representation using that array.
public class QueryBuilder {
    /// An array of substitutions to be made in query String representation.
    public var substitutions: [String]
    
    public private (set) var name: String
    
    /// The index for the substitutions array.
    public enum QuerySubstitutionNames: Int {
        /// The SQL UCASE scalar function.
        case ucase
        /// The SQL LCASE scalar function.
        case lcase
        /// The SQL LEN scalar function.
        case len
        /// The SQL NOW scalar function.
        case now
        /// The marker for the query numbered parameters.
        case numberedParameter
        /// The marker for the query named parameters.
        case namedParameter
        /// The boolean true.
        case booleanTrue
        /// The boolean false.
        case booleanFalse
        /// The ALL function for subqueries.
        case all
        /// The character used to quote identifiers (table name, column name, etc.) with spaces or special characters.
        case identifierQuoteCharacter
        /// The database type that corresponds to Int32.
        case int32
        /// The database type that corresponds to Float.
        case float
        /// The database type that corresponds to Double.
        case double
        /// The database type that corresponds to char.
        case char
        
        /// Last case, add new values before it.
        case namesCount
    }
    
    /// An indication whether the parameters should be numbered (e.g., '$1, $2'), or just marked
    /// with the numbered parameter marker (e.g., '?').
    public var addNumbersToParameters = true
    
    /// The starting index for numbered parameters.
    public var firstParameterIndex = 1
    
    /// An indication whether ANY on subqueries is supported.
    public var anyOnSubquerySupported = true
    
    /// An indication whether a `DELETE` query should use `USING` clause for tables in `WITH` clause.
    public var withDeleteRequiresUsing = false
    
    /// An indication whether an `UPDATE` query should use `FROM` clause for tables in `WITH` clause.
    public var withUpdateRequiresFrom = false
    
    /// A function to create column's autoincrement expression based on the column's type.
    public var createAutoIncrement: ((String) -> String)?
    
    
    /// Initialize an instance of QueryBuilder.
    ///
    /// - Parameter addNumbersToParameters: An indication whether query parameters should be numbered.
    /// - Parameter firstParameterIndex: The starting index for numbered parameters.
    /// - Parameter anyOnSubquerySupported: An indication whether ANY on subqueries is supported.
    /// - Parameter withDeleteRequiresUsing: An indication whether a `DELETE` query should use `USING` clause for tables in `WITH` clause.
    /// - Parameter withUpdateRequiresFrom: An indication whether an `UPDATE` query should use `FROM` clause for tables in `WITH` clause.
    /// - Parameter createAutoIncrement: A function to create column's autoincrement expression based on the column's type.
    public init(name: String, addNumbersToParameters: Bool = true, firstParameterIndex: Int = 1, anyOnSubquerySupported: Bool = true, withDeleteRequiresUsing: Bool = false, withUpdateRequiresFrom: Bool = false, createAutoIncrement: ((String) -> String)? = nil) {
        self.name = name
        substitutions = Array(repeating: "", count: QuerySubstitutionNames.namesCount.rawValue)
        substitutions[QuerySubstitutionNames.ucase.rawValue] = "UCASE"
        substitutions[QuerySubstitutionNames.lcase.rawValue] = "LCASE"
        substitutions[QuerySubstitutionNames.len.rawValue] = "LEN"
        substitutions[QuerySubstitutionNames.now.rawValue] = "NOW()"
        substitutions[QuerySubstitutionNames.numberedParameter.rawValue] = "?"
        substitutions[QuerySubstitutionNames.namedParameter.rawValue] = "@"
        substitutions[QuerySubstitutionNames.booleanTrue.rawValue] = "true"
        substitutions[QuerySubstitutionNames.booleanFalse.rawValue] = "false"
        substitutions[QuerySubstitutionNames.all.rawValue] = "ALL"
        substitutions[QuerySubstitutionNames.identifierQuoteCharacter.rawValue] = "\""
        substitutions[QuerySubstitutionNames.int32.rawValue] = "integer"
        substitutions[QuerySubstitutionNames.float.rawValue] = "real"
        substitutions[QuerySubstitutionNames.double.rawValue] = "double"
        substitutions[QuerySubstitutionNames.char.rawValue] = "char"

        self.addNumbersToParameters = addNumbersToParameters
        self.anyOnSubquerySupported = anyOnSubquerySupported
        self.firstParameterIndex = firstParameterIndex
        self.withDeleteRequiresUsing = withDeleteRequiresUsing
        self.withUpdateRequiresFrom = withUpdateRequiresFrom
        self.createAutoIncrement = createAutoIncrement
    }
    
    /// Update substitutions array.
    ///
    /// - Parameter newSubstitutions: A Dictionary containing the entries to update.
    public func updateSubstitutions(_ newSubstitutions: [QuerySubstitutionNames:String]) {
        for (index, substitution) in newSubstitutions {
            substitutions[index.rawValue] = substitution
        }
    }
}
