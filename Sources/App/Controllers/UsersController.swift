import Foundation
import Vapor
import HTTP

struct UserController: RouteCollection {
	func boot(router: Router) throws {
		let usersRoutes = router.grouped("api", "users")
		usersRoutes.get(use: getAllHandler)
		usersRoutes.get(User.parameter, use: getHandler)
		usersRoutes.post(use: createHandler)
		usersRoutes.get(User.parameter, "acronyms", use: getAcronymsHandler)
	}
	
	func createHandler(_ req: Request) throws -> Future<User> {
		return try req.content.decode(User.self).flatMap(to: User.self) { user in
			return user.save(on: req)
		}
	}
	
	func getAllHandler(_ req: Request) throws -> Future<[User]> {
		return User.query(on: req).all()
	}
	
	func getHandler(_ req: Request) throws -> Future<User> {
		return try req.parameters.next(User.self)
	}
	
	func getAcronymsHandler(_ req: Request) throws -> Future<[Acronym]> {
		return try req.parameters.next(User.self).flatMap(to: [Acronym].self) { user in
			return try user.acronyms.query(on: req).all()
		}
	}
}

