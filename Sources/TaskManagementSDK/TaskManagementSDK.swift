// The Swift Programming Language
// https://docs.swift.org/swift-book

import Dispatch
import Foundation
import OpenCombine


// ViewModel to manage tasks
public class TaskManagementSDK {
  public static let viewModel = TaskManagementSDK()
  public required init() {
      
  }

  private var tasks: [Task] = [] {
    didSet {
      tasksPublisher.send(tasks)
    }
  }

  private let tasksPublisher = CurrentValueSubject<[Task], Never>([])

  private var cancellables: [AnyCancellable] = [] // Use non-optional array


  public func addTask(_ task: Task) {
    tasks.append(task)
    print("Task added: \(task.title)")
  }

  public func removeTask(_ task: Task) {
    tasks.remove(at: task.id)
    print("Task removed: \(task.title)")
  }

  public func getTasksResultString() -> [String] {
    var taskStringArray = [String]()
    print("Current tasks:")
    for task in tasks {
      taskStringArray.append(task.title)
    }
    return taskStringArray
  }

 public func subscribeToChanges(handler: @escaping ([Task]) -> Void) {
         tasksPublisher
             .sink { tasks in
                 handler(tasks)
             }
             .store(in: &cancellables)
 }
}
