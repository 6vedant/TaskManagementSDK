/*
 Author: Vedant Jha | SCADE
*/

import Dispatch
import Foundation
import OpenCombine


/// A class that manages tasks.
public class TaskManager {
    
    /// The shared instance of the `TaskManager`.
    public static let viewModel = TaskManager()
    
    /// Initializes a new instance of the `TaskManager`.
    public required init() {
        
    }
    
    /// The array containing tasks.
    ///
    /// Tasks are stored in this array, and changes to the array trigger notifications
    /// to subscribers through the `tasksPublisher`.
    private var tasks: [Task] = [] {
        didSet {
            tasksPublisher.send(tasks)
        }
    }
    
    /// A subject that publishes an array of tasks.
    ///
    /// Subscribers can listen for changes to the tasks using this publisher.
    private let tasksPublisher = CurrentValueSubject<[Task], Never>([])
    
    /// An array of cancellables for handling subscriptions.
    ///
    /// Cancellables are stored in this array to manage the lifecycle of subscriptions.
    private var cancellables: [AnyCancellable] = [] // Use non-optional array
    
    /// Adds a new task with the specified title.
    ///
    /// - Parameter task: The title of the task to be added.
    /// - Returns: The newly added task.
    public func addTask(_ task: String) -> Task {
        let newTaskID = "tid\(generateUniqueID())"
        let newTask = Task(id: newTaskID, title: task)
        tasks.append(newTask)
        print("Task added: \(newTask.title)")
        return newTask
    }
    
    /// Generates a unique ID for tasks based on the current timestamp and a random value.
    ///
    /// - Returns: A unique ID for tasks.
    private func generateUniqueID() -> Int {
        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        let randomValue = Int.random(in: 0..<1000)
        let uniqueID = timestamp + randomValue
        return uniqueID
    }
    
    /// Updates the title of the task with the specified ID.
    ///
    /// - Parameters:
    ///   - id: The ID of the task to be updated.
    ///   - newTaskTitle: The new title for the task.
    /// - Returns: The updated task.
    public func updateTask(id: String, newTaskTitle: String) -> Task {
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            tasks[index].title = newTaskTitle
            print("Task updated - New Title: \(newTaskTitle)")
        }
        return Task(id: id, title: newTaskTitle)
    }
    
    /// Removes the specified task from the array.
    ///
    /// - Parameter task: The task to be removed.
    public func removeTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks.remove(at: index)
            print("Task removed: \(task.title)")
        }
    }
    
    /// Gets an array containing the titles of all tasks.
    ///
    /// - Returns: An array of task titles.
    public func getAllTasksTitle() -> [String] {
        var taskStringArray = [String]()
        print("Current tasks:")
        for task in tasks {
            taskStringArray.append(task.title)
        }
        return taskStringArray
    }
    
    /// Gets an array containing all tasks.
    ///
    /// - Returns: An array of tasks.
    public func getAllTasks() -> [Task] {
        return tasks
    }
    
    /// Subscribes to changes in tasks.
    /// Note: One has to loop through each task if there is an update to any task title
    ///
    /// - Parameter handler: A closure to be executed when tasks are updated.
    public func subscribeToChanges(handler: @escaping (Task) -> Void) {
        tasksPublisher
            .sink { [weak self] tasks in
                // Loop through the updated tasks
                for updatedTask in tasks {
                    // Find the corresponding previous task by ID
                    if let previousTask = self?.tasks.first(where: { $0.id == updatedTask.id }) {
                        // Compare the titles of the previous and updated tasks
                        if previousTask.title != updatedTask.title {
                            // If the title has changed, publish the updated task
                            handler(updatedTask)
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
}
