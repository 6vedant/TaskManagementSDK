// The Swift Programming Language
// https://docs.swift.org/swift-book

import Dispatch
import Foundation
import OpenCombine


public class TaskManager {
    // ViewModel to manage tasks
    public static let viewModel = TaskManager()
    public required init() {
        
    }
    
    private var tasks: [Task] = [] {
        didSet {
            tasksPublisher.send(tasks)
        }
    }
    
    private let tasksPublisher = CurrentValueSubject<[Task], Never>([])
    
    private var cancellables: [AnyCancellable] = [] // Use non-optional array
    
    
    
    public func addTask(_ task: String) -> Task {
        let newTaskID = generateUniqueID()
        let newTask = Task(id: newTaskID, title: task)
        tasks.append(newTask)
        print("Task added: \(newTask.title)")
        return newTask
    }
    
    func generateUniqueID() -> Int {
        let timestamp = Int(Date().timeIntervalSince1970 * 1000) // Get current timestamp in milliseconds
        let randomValue = Int.random(in: 0..<1000) // Generate a random number (adjust the range as needed)
        
        let uniqueID = timestamp + randomValue
        return uniqueID
    }
    
    public func updateTask(id: Int, newTaskTitle: String) -> Task {
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            tasks[index].title = newTaskTitle
            print("Task updated - New Title: \(newTaskTitle)")
        }
        return Task(id: id, title: newTaskTitle)
    }
    
    public func removeTask(_ task: Task) {
        tasks.remove(at: task.id)
        print("Task removed: \(task.title)")
    }
    
    public func getAllTasksTitle() -> [String] {
        var taskStringArray = [String]()
        print("Current tasks:")
        for task in tasks {
            taskStringArray.append(task.title)
        }
        return taskStringArray
    }
    
    public func getAllTasks() -> [Task] {
        return tasks
    }
    
    public func subscribeToChanges(handler: @escaping ([Task]) -> Void) {
        tasksPublisher
            .sink { tasks in
                handler(tasks)
            }
            .store(in: &cancellables)
    }
}
