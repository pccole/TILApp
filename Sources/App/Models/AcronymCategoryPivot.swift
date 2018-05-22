
import FluentSQLite
import Vapor
import Foundation

final class  AcronymCategoryPivot: SQLiteUUIDPivot {
	var id: UUID?
	var categoryID: Category.ID
	var acronymID: Acronym.ID
	
	typealias Left = Acronym
	typealias Right = Category
	
	static let leftIDKey: LeftIDKey = \AcronymCategoryPivot.acronymID
	static let rightIDKey: RightIDKey = \AcronymCategoryPivot.categoryID
	
	init(_ acronymID: Acronym.ID, _ categoryID:Category.ID) {
		self.acronymID = acronymID
		self.categoryID = categoryID
	}
}

extension AcronymCategoryPivot: Migration {}
