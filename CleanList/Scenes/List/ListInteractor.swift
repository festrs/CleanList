//
//  ListInteractor.swift
//  CleanList
//
//  Created by Felipe Dias Pereira on 2019-05-12.
//  Copyright (c) 2019 FelipeP. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol ListBusinessLogic
{
  func doSomething(request: List.Something.Request)
}

protocol ListDataStore
{
  //var name: String { get set }
}

class ListInteractor: ListBusinessLogic, ListDataStore
{
  var presenter: ListPresentationLogic?
  var worker: ListWorker?
  //var name: String = ""
  
  // MARK: Do something
  
  func doSomething(request: List.Something.Request)
  {
    worker = ListWorker()
    worker?.doSomeWork()
    
    let response = List.Something.Response()
    presenter?.presentSomething(response: response)
  }
}
