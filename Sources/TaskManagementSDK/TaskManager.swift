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
    
    /// The Sqlite instance to do CRUD operations
    private var sqliteDbManager: SqliteDBManager!
    
    /// The array containing tasks.
    ///
    /// Tasks are stored in this array, and changes to the array trigger notifications
    /// to subscribers through the `tasksPublisher`.
    private var tasks: [Task] = [] {
        didSet {
            tasksPublisher.send(tasks)
        }
    }
    
    /// Initializes a new instance of the `TaskManager`.
    ///  Initalize the database instance
    public required init() {
        sqliteDbManager = SqliteDBManager(databasePath: "\(NSHomeDirectory())/task_sqlite_db.db")
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
        
        // add task to sqlite db
        let taskAdded = sqliteDbManager.addTask(task: newTask)
        if !taskAdded {
            print("Unable to add Task \(newTask.title) to sqlite db")
        }
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
            // Publish the updated tasks array
            tasksPublisher.send(tasks)
        }
        let updatedTask =  Task(id: id, title: newTaskTitle)
        
        // Update the task in sqlite DB
        let isTaskUpdated = sqliteDbManager.updateTask(task: updatedTask)
        if !isTaskUpdated {
            print("Error updating task for id: \(id)")
        }
        return updatedTask
    }
    
    
    /// Removes the specified task from the array.
    ///
    /// - Parameter task: The task to be removed.
    public func removeTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks.remove(at: index)
            
            // Remove the task from Sqlite DB
            let isRemoved = sqliteDbManager.deleteTask(id: task.id)
            if !isRemoved {
                print("Unable to removed task \(task.title)")
            } else {
                print("Task removed: \(task.title)")
            }
        }
    }
    
    /// Gets an array containing all tasks.
    ///
    /// - Returns: An array of tasks.
    public func getAllTasks() -> [Task] {
        // Initialize the tasks with the Sqlite data
        if (tasks.count == 0) {
            if let dbTasks = sqliteDbManager.getAllTasks() {
                tasks = dbTasks
            }
        }
        return tasks
    }
    
    /// Gets an array containing all tasks.
    ///
    /// - Returns: The count of tasks.
    public func getTasksCount() -> Int {
        return tasks.count
    }
    
    /// Subscribes to changes in tasks.
    /// Note: One has to loop through each task if there is an update to any task title
    ///
    /// - Parameter handler: A closure to be executed when tasks are updated.
    /// Subscribes to changes in tasks.
    ///
    /// - Parameter handler: A closure to be executed when tasks are updated.
    public func subscribeToChanges(handler: @escaping ([Task]) -> Void) {
        tasksPublisher
            .sink { tasks in
                handler(tasks)
            }
            .store(in: &cancellables)
    }
}
