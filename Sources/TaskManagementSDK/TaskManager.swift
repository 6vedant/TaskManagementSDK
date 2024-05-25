import Dispatch
import Foundation
import OpenCombine

/// A class that manages tasks.
public class TaskManager {
    
    /// The shared instance of the `TaskManager`.
    public static let viewModel = TaskManager()
    
    /// The Sqlite instance to do CRUD operations
    private var sqliteDbManager: SqliteDBManager?
    
    /// The array containing tasks.
    ///
    /// Tasks are stored in this array, and changes to the array trigger notifications
    /// to subscribers through the `tasksPublisher`.
    private var tasks: [Task] = [] {
        didSet {
            tasksPublisher.send(tasks)
        }
    }
    
    private var subTasks: [SubTask] = [] {
        didSet {
            subTasksPublisher.send(subTasks)
        }
    }
   
    
    /// Initializes a new instance of the `TaskManager`.
    /// Initalize the database instance
    public required init() {
        sqliteDbManager = SqliteDBManager(databasePath: "\(NSHomeDirectory())/task_sqlite_db.db")
        if let sqliteTasks = sqliteDbManager?.getAllTasks() {
                    tasks = sqliteTasks
        }
        if let sqliteSubTasks = sqliteDbManager?.getAllSubTasks() {
                    subTasks = sqliteSubTasks
        }
    }
    
    /// A subject that publishes an array of tasks.
    ///
    /// Subscribers can listen for changes to the tasks using this publisher.
    private let tasksPublisher = CurrentValueSubject<[Task], Never>([])
    
    private let subTasksPublisher = CurrentValueSubject<[SubTask], Never>([])
    
    /// An array of cancellables for handling subscriptions.
    ///
    /// Cancellables are stored in this array to manage the lifecycle of subscriptions.
    private var cancellables: [AnyCancellable] = [] // Use non-optional array
    
    /// Adds a new task with the specified properties.
    ///
    /// - Parameter title: The title of the task to be added.
    /// - Parameter description: The description of the task.
    /// - Parameter isCompleted: The completion status of the task.
    /// - Parameter tags: The tags associated with the task.
    /// - Parameter priority: The priority of the task.
    /// - Returns: The newly added task.
    public func addTask(
        title: String,
        description: String? = nil,
        isCompleted: Bool = false,
        tags: [String]? = nil,
        priority: Int? = nil
    ) -> Task {
        let newTaskID = "tid\(generateUniqueID())"
        let newTask = Task(
            id: newTaskID,
            title: title,
            descriptionTask: description,
            isCompleted: isCompleted,
            tags: tags,
            priority: priority
        )
        tasks.append(newTask)
        print("Task added: \(newTask.title)")
        
        // Add task to sqlite db
        _ = sqliteDbManager?.addTask(task: newTask)
        return newTask
    }
    
    /// Generates a unique ID for tasks based on the current timestamp and a random value.
    ///
    /// - Returns: A unique ID for tasks.
    private func generateUniqueID() -> Int {
        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        let randomValue = Int.random(in: 0..<1000)
        return timestamp + randomValue
    }
    
    /// Updates the title of the task with the specified ID.
    ///
    /// - Parameters:
    ///   - id: The ID of the task to be updated.
    ///   - newTitle: The new title for the task.
    ///   - newDescription: The new description for the task.
    ///   - isCompleted: The new completion status for the task.
    ///   - tags: The new tags for the task.
    ///   - priority: The new priority for the task.
    /// - Returns: The updated task.
    public func updateTask(
        id: String,
        newTitle: String,
        newDescription: String? = nil,
        isCompleted: Bool = false,
        tags: [String]? = nil,
        priority: Int? = nil
    ) -> Task? {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else {
            return nil
        }
        
        let task = tasks[index]
        task.title = newTitle
        task.descriptionTask = newDescription
        task.isCompleted = isCompleted
        task.tags = tags
        task.priority = priority
        
        // Publish the updated tasks array
        tasksPublisher.send(tasks)
        
        // Update the task in sqlite DB
        _ = sqliteDbManager?.updateTask(task: task)
        
        return task
    }
    
    /// Removes the specified task from the array.
    ///
    /// - Parameter task: The task to be removed.
    public func removeTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks.remove(at: index)
            
            // Remove the task from Sqlite DB
            _ = sqliteDbManager?.deleteTask(id: task.id)
        }
    }
    
    /// Gets an array containing all tasks.
    ///
    /// - Returns: An array of tasks.
    public func getAllTasks() -> [Task] {
        // Initialize the tasks with the Sqlite data
        if tasks.isEmpty {
            if let sqliteTasks = sqliteDbManager?.getAllTasks() {
                tasks = sqliteTasks
            }
        }
        return tasks
    }
    
    /// Gets the count of tasks.
    ///
    /// - Returns: The count of tasks.
    public func getTasksCount() -> Int {
        return tasks.count
    }
    
    /// Adds a subtask to a specific task.
    ///
    /// - Parameters:
    ///   - parentTaskID: The ID of the parent task.
    ///   - subTaskTitle: The title of the subtask.
    /// - Returns: The newly added subtask.
    public func addSubtask(parentTaskID: String, subTaskTitle: String) -> SubTask? {
        guard let task = tasks.first(where: { $0.id == parentTaskID }) else {
            return nil
        }
        
        let newSubtask = SubTask(parentTaskID: parentTaskID, subTaskID: "subtid\(generateUniqueID())", subTaskTitle: subTaskTitle)
        subTasks.append(newSubtask)
        task.subTasks?.append(newSubtask)
        
        // Update the task in sqlite DB
        _ = sqliteDbManager?.addSubTask(subTask: newSubtask)
        print("Subtask added: \(newSubtask.subTaskTitle)")
        return newSubtask
    }
    
    public func updateSubTask(
        subTask: SubTask,
        newSubTaskTitle: String? = nil,
        isCompleted: Bool = false
      ) -> SubTask? {
          guard let index = subTasks.firstIndex(where: { $0.subTaskID == subTask.subTaskID }) else {
              return nil
          }
          
          let subTask = subTasks[index]
          if (newSubTaskTitle != nil) {
              subTask.subTaskTitle = newSubTaskTitle!
          }
          subTask.isSubTaskCompleted = isCompleted
         
          // Publish the updated tasks array
          subTasksPublisher.send(subTasks)
          
          // Update the task in sqlite DB
          _ = sqliteDbManager?.updateSubTask(subTask: subTask)
          
          return subTask
    }
    
    public func deleteSubTask(subTaskID: String) {
        guard let index = subTasks.firstIndex(where: { $0.subTaskID == subTaskID }) else {
            return
        }
        
        subTasks.remove(at: index)
        subTasksPublisher.send(subTasks)
        _ = sqliteDbManager?.deleteSubTask(subTaskID: subTaskID)
    }
    
    /// Gets all subtasks for a specific task.
    ///
    /// - Parameter parentTaskID: The ID of the parent task.
    /// - Returns: An array of subtasks.
    public func getSubTasksOfTask(parentTaskID: String) -> [SubTask]? {
        var result: [SubTask] = []
        for subTask in subTasks {
            if subTask.parentTaskID == parentTaskID {
                result.append(subTask)
            }
        }
        return result.isEmpty ? nil : result
    }
    
    public func getAllSubTasks() -> [SubTask]? {
        // Initialize the tasks with the Sqlite data
        if subTasks.isEmpty {
            if let sqliteSubTasks = sqliteDbManager?.getAllSubTasks() {
                subTasks = sqliteSubTasks
            }
        }
        return subTasks
    }
    
    /// Subscribes to changes in tasks.
    /// Note: One has to loop through each task if there is an update to any task title
    ///
    /// - Parameter handler: A closure to be executed when tasks are updated.
    public func subscribeToChanges(handler: @escaping ([Task]) -> Void) {
        tasksPublisher
            .sink { tasks in
                handler(tasks)
            }
            .store(in: &cancellables)
    }
    public func subscribeToChangesForSubTasks(handler: @escaping ([SubTask]) -> Void) {
        subTasksPublisher
            .sink { subTasks in
                handler(subTasks)
            }
            .store(in: &cancellables)
    }
}
