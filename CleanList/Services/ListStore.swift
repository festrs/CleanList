//
//  ListStore.swift
//  CleanList
//
//  Created by Felipe Dias Pereira on 2019-05-12.
//  Copyright © 2019 FelipeP. All rights reserved.
//

import Foundation
import RealmSwift

//MARK: - ListStore Errors
enum ListStoreError: Equatable, Error {
    case realmError
    case CannotFetch(String)
    case CannotCreate(String)
    case CannotUpdate(String)
    case CannotDelete(String)
}

func ==(lhs: ListStoreError, rhs: ListStoreError) -> Bool {
    switch (lhs, rhs) {
    case (.realmError, .realmError): return true
    case (.CannotFetch(let a), .CannotFetch(let b)) where a == b: return true
    case (.CannotCreate(let a), .CannotCreate(let b)) where a == b: return true
    case (.CannotUpdate(let a), .CannotUpdate(let b)) where a == b: return true
    case (.CannotDelete(let a), .CannotDelete(let b)) where a == b: return true
    default: return false
    }
}

typealias ListStoreFetchItemsCompletionHandler = (Result<[Item], ListStoreError>) -> Void
typealias ListStoreFetchItemCompletionHandler = (Result<Item, ListStoreError>) -> Void

//MARK: - CRUD operations
protocol ListStoreProtocol: AnyObject {
    func fetchItems(completionHandler: @escaping ListStoreFetchItemsCompletionHandler)
    func fetchItem(_ id: String, completionHandler: @escaping ListStoreFetchItemCompletionHandler)
    func createItem(newItem item: Item, completionHandler: @escaping ListStoreFetchItemCompletionHandler)
    func updateItem(itemToUpdate item: Item, completionHandler: @escaping ListStoreFetchItemCompletionHandler)
    func deleteItem(_ id: String, completionHandler: @escaping ListStoreFetchItemCompletionHandler)
}

class ListStore {
    private var realm: Realm? {
        return try? Realm()
    }
    private var backgroundSession: DispatchQueue = DispatchQueue.global(qos: .userInitiated)
    private var dispatchSession: DispatchQueue

    init(_ completionHandlerSession: DispatchQueue = DispatchQueue.main) {
        self.dispatchSession = completionHandlerSession
    }
}

extension ListStore: ListStoreProtocol {
    func fetchItems(completionHandler: @escaping ListStoreFetchItemsCompletionHandler) {
        guard let realm = realm else {
            completionHandler(.failure(ListStoreError.realmError))
            return
        }
        backgroundSession.async {
            autoreleasepool {
                let result = Array(realm.objects(Item.self))
                self.dispatchSession.async {
                    completionHandler(Result.success(result))
                }
            }
        }
    }

    func fetchItem(_ id: String, completionHandler: @escaping ListStoreFetchItemCompletionHandler) {
        guard let realm = realm else {
            completionHandler(.failure(ListStoreError.realmError))
            return
        }
        backgroundSession.async {
            autoreleasepool {
                if let item = realm.object(ofType: Item.self, forPrimaryKey: id) {
                    self.dispatchSession.async {
                        completionHandler(.success(item))
                    }
                } else {
                    self.dispatchSession.async {
                        completionHandler(.failure(ListStoreError.CannotFetch("Cannot fetch item with id = \(id)")))
                    }
                }
            }
        }
    }

    func createItem(newItem item: Item, completionHandler: @escaping ListStoreFetchItemCompletionHandler) {
        guard let realm = realm else {
            completionHandler(.failure(ListStoreError.realmError))
            return
        }
        backgroundSession.async {
            autoreleasepool {
                do {
                    try realm.write {
                        realm.add(item)
                    }
                    self.dispatchSession.async {
                        completionHandler(.success(item))
                    }
                } catch {
                    self.dispatchSession.async {
                        completionHandler(.failure(ListStoreError.CannotFetch("Cannot create item = \(item)")))
                    }
                }
            }
        }
    }

    func updateItem(itemToUpdate item: Item, completionHandler: @escaping ListStoreFetchItemCompletionHandler) {
        guard let realm = realm else {
            completionHandler(.failure(ListStoreError.realmError))
            return
        }
        backgroundSession.async {
            autoreleasepool {
                do {
                    try realm.write {
                        realm.add(item, update: true)
                    }
                    self.dispatchSession.async {
                        completionHandler(.success(item))
                    }
                } catch {
                    self.dispatchSession.async {
                        completionHandler(.failure(ListStoreError.CannotFetch("Cannot update item = \(item)")))
                    }
                }
            }
        }
    }

    func deleteItem(_ id: String, completionHandler: @escaping ListStoreFetchItemCompletionHandler) {
        guard let realm = realm else {
            completionHandler(.failure(ListStoreError.realmError))
            return
        }
        backgroundSession.async {
            autoreleasepool {
                do {
                    if let item = realm.object(ofType: Item.self, forPrimaryKey: id) {
                        try realm.write {
                            realm.delete(item)
                        }
                        self.dispatchSession.async {
                            completionHandler(.success(item))
                        }
                    } else {
                        self.dispatchSession.async {
                            completionHandler(.failure(ListStoreError.CannotFetch("Cannot delete item with id = \(id)")))
                        }
                    }
                } catch {
                    self.dispatchSession.async {
                        completionHandler(.failure(ListStoreError.CannotFetch("Cannot delete item with id = \(id)")))
                    }
                }
            }
        }
    }
}
