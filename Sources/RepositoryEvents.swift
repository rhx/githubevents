//
//  RepositoryEvents.swift
//  githubevents
//
//  Created by Rene Hexel on 14/4/17.
//
import Foundation
import RxSwift
import RxCocoa

/// Observable repository events
class RepositoryEvents {
    let bag: DisposeBag
    let url: URL
    let urlSession: URLSession
    init?(uri: String) {
        guard let u = URL(string: uri) else { return nil }
        url = u
        urlSession = URLSession(configuration: URLSessionConfiguration.default)
        bag = DisposeBag()
    }

    /// Asynchronously fetch events
    ///
    /// - Parameter processEvents: callback for processing received events
    func fetchEvents(_ processEvents: @escaping ([Event]) -> Void) {
        let response = Observable.from([url])
            .map { URLRequest(url: $0) }
            .flatMap { self.urlSession.rx.response(request: $0) }
            //.shareReplay(1)

        response.filter { 200..<300 ~= $0.0.statusCode }
            .map { _, data -> [[String : Any]] in
                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
                      let dictionaries = jsonObject as? [[String: Any]] else { return [] }
                return dictionaries
            }
            .filter { $0.count > 0 }
            .map { $0.flatMap(Event.init) }
            .subscribe(onNext: { processEvents($0) })
            .addDisposableTo(bag)
    }
}
