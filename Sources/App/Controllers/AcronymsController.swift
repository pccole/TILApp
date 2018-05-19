import Vapor
struct AcronymsController: RouteCollection {
	func boot(router: Router) throws {
		let acronymsRouter = router.grouped("api", "acronyms")
		acronymsRouter.get(use: getAllHandler)
		acronymsRouter.get(Acronym.parameter, use: getHandler)
		acronymsRouter.post(use: createHandler)
		acronymsRouter.delete(Acronym.parameter, use: deleteHandler)
		acronymsRouter.put(Acronym.parameter, use: updateHandler)
	}
	
	func getAllHandler(_ req: Request) throws -> Future<[Acronym]> {
		return Acronym.query(on: req).all()
	}
	
	func getHandler(_ req: Request) throws -> Future<Acronym> {
		let acronym = try req.parameters.next(Acronym.self)
//		let id = try req.parameters.next(Int.self)
//		let db = try Acronym.find(id, on: req)
//		print(db)
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
}
