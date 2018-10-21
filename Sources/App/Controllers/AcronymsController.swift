import Vapor
import Fluent

struct AcronymsController: RouteCollection {
	func boot(router: Router) throws {
        // /api/acronyms
        // registered in routes
		let acronymsRouter = router.grouped("api", "acronyms") // very common pattern for creating REST Objects
		acronymsRouter.get(use: getAllHandler)
		acronymsRouter.get(Acronym.parameter, use: getHandler)
		acronymsRouter.post(use: createHandler)
		acronymsRouter.delete(Acronym.parameter, use: deleteHandler)
		acronymsRouter.put(Acronym.parameter, use: updateHandler)
		acronymsRouter.get(Acronym.parameter, "creator", use: getCreatorHandler)
		acronymsRouter.get(Acronym.parameter, "categories", use: getCategoriesHandlers)
		acronymsRouter.post(Acronym.parameter, "categories", Category.parameter, use: addCategoriesHandler)
		acronymsRouter.get("search", use: searchHandler)
	}
	
	func getAllHandler(_ req: Request) throws -> Future<[Acronym]> {
		return Acronym.query(on: req).all()
	}
	
	func getHandler(_ req: Request) throws -> Future<Acronym> {
		let acronym = try req.parameters.next(Acronym.self)
		return acronym
	}
	
	func createHandler(_ req: Request) throws -> Future<Acronym> {
		let acronym = try req.content.decode(Acronym.self)
		return acronym.save(on: req)
	}
	
	func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
		return try req.parameters.next(Acronym.self).flatMap(to: HTTPStatus.self, { (acronym:Acronym) -> EventLoopFuture<HTTPStatus> in
			return acronym.delete(on: req).transform(to: .noContent)
		})
	}
	
	func updateHandler(_ req: Request) throws -> Future<Acronym> {
		return try flatMap(to: Acronym.self, req.parameters.next(Acronym.self), req.content.decode(Acronym.self)) { acronym, updateAcronym in
			acronym.short = updateAcronym.short
			acronym.long = updateAcronym.long
			return acronym.save(on: req)
		}
	}
	
	func getCreatorHandler(_ req: Request) throws -> Future<User> {
		return try req.parameters.next(Acronym.self).flatMap(to: User.self, { acronym in
			return acronym.creator.get(on: req)
		})
	}
	
	func getCategoriesHandlers(_ req: Request) throws -> Future<[Category]> {
		return try req.parameters.next(Acronym.self).flatMap(to: [Category].self, { acronym in
			return try acronym.categories.query(on: req).all()
		})
	}
	
	func addCategoriesHandler(_ req: Request) throws -> Future<HTTPStatus> {
		return try flatMap(to: HTTPStatus.self, req.parameters.next(Acronym.self), req.parameters.next(Category.self)) { acronym, category in
			let pivot = try AcronymCategoryPivot(acronym.requireID(), category.requireID())
			return pivot.save(on: req).transform(to: .ok)
		}
	}
	
	func searchHandler(_ req: Request) throws -> Future<[Acronym]> {
		guard let searchTerm = req.query[String.self, at: "term"] else {
			throw Abort.init(.badRequest, reason: "Missing search term in request")
		}
		return Acronym.query(on: req).group(.or) { or in
			or.filter(\.short == searchTerm)
			or.filter(\.long == searchTerm)
		}.all()
	}
}
