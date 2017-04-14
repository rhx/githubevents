import Foundation
import Dispatch
import RxSwift

let repo: String
if CommandLine.arguments.count > 1 {
    repo = CommandLine.arguments[1]
} else {
    repo = "rhx/githubevents"
}
let eventsURI = "https://api.github.com/repos/\(repo)/events"
let handler = RepositoryEvents(uri: eventsURI)

handler?.fetchEvents {
    for event in $0 {
        print("\(event.name): \(event.action)")
    }
    exit(EXIT_SUCCESS)
}

dispatchMain()
