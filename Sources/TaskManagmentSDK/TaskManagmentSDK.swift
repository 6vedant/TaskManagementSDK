// The Swift Programming Language
// https://docs.swift.org/swift-book

import Dispatch
import Foundation
import OpenCombine


// Model for a task
struct Task: Identifiable {
  let id: Int
  let title: String
}

// ViewModel to manage tasks
class TaskManagmentSDK {
  static let viewModel = TaskManagmentSDK()
  private init() {}

  var tasks: [Task] = [] {
    didSet {
      tasksPublisher.send(tasks)
    }
  }

  let tasksPublisher = CurrentValueSubject<[Task], Never>([])

  private var cancellables: [AnyCancellable] = [] // Use non-optional array


  func addTask(_ task: Task) {
    tasks.append(task)
    print("Task added: \(task.title)")
  }

  func removeTask(_ task: Task) {
    tasks.remove(at: task.id)
    print("Task removed: \(task.title)")
  }

  func getTasksResultString() -> [String] {
    var taskStringArray = [String]()
    print("Current tasks:")
    for task in tasks {
      taskStringArray.append(task.title)
    }
    return taskStringArray
  }

 func subscribeToChanges(handler: @escaping ([Task]) -> Void) {
         tasksPublisher
             .sink { tasks in
                 handler(tasks)
             }
             .store(in: &cancellables)
 }
}
