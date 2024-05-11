/*
 Author: Vedant Jha | SCADE
 */

import Dispatch
import Foundation
import OpenCombine
import SQLite


/// A class that manages tasks.
public class TaskManager {
    
    /// The shared instance of the `TaskManager`.
    public static let viewModel = TaskManager()
    
    private var db: Connection!
    private var taskTable: Table!
    private let id = Expression<String>("id")
      private let title = Expression<String>("title")
    
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
    public required init() {
        
        do {
            db = try Connection(NSHomeDirectory() + "/data.db")
            createTable()
        } catch {
            print("Error creating database!")
        }
        
    }
    
    private func createTable() {
         taskTable = Table("tasks")
     
           do {
               _ = try db.run(taskTable.create { t in
                   t.column(id, primaryKey: true)
                   t.column(title)
               })
           } catch {
               print("Error creating table: \(error)")
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
         let taskAdded = addTaskToLocalDB(task: newTask)
        if !taskAdded {
            print("Unable to add Task \(newTask.title) to local db")
        }
        return newTask
    }
    
    public func addTaskToLocalDB(task: Task) -> Bool {
            do {
                let insert = taskTable.insert(id <- task.id, title <- task.title)
                try db.run(insert)
                return true
            } catch {
                print("Error adding task: \(error)")
                return false
            }
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
        let isTaskUpdated = updateTaskInLocalDb(task: updatedTask)
        if !isTaskUpdated {
            print("Error updating task for id: \(id)")
        }
        return updatedTask
    }
    
    public func updateTaskInLocalDb(task: Task) -> Bool {
            let taskToUpdate = taskTable.filter(id == task.id)
            do {
                try db.run(taskToUpdate.update(title <- task.title))
                return true
            } catch {
                print("Error updating task: \(error)")
                return false
            }
        }
    
 
    
    /// Removes the specified task from the array.
    ///
    /// - Parameter task: The task to be removed.
    public func removeTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks.remove(at: index)
            let isRemoved = removeFromLocalDB(id: task.id)
            if !isRemoved {
                print("Unable to removed task \(task.title)")
            } else {
                print("Task removed: \(task.title)")
            }
        }
    }
    
    public func removeFromLocalDB(id: String) -> Bool {
           let taskToDelete = taskTable.filter(self.id == id)
           do {
               try db.run(taskToDelete.delete())
               return true
           } catch {
               print("Error deleting task: \(error)")
               return false
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
    
    public func getAllTasksFromLocalDB() -> [Task] {
        var allTasks = [Task]()
                do {
                    for task in try db.prepare(taskTable) {
                        let newTask = Task(id: task[id], title: task[title])
                        allTasks.append(newTask)
                    }
                } catch {
                    print("Error fetching tasks: \(error)")
                }
                return allTasks
    }
    
    /// Gets an array containing all tasks.
    ///
    /// - Returns: An array of tasks.
    public func getAllTasks() -> [Task] {
        if(tasks.isEmpty) {
            tasks = getAllTasksFromLocalDB()
        }
        return tasks
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
    
    
    public func testSQLite() -> String {
        do {
            let db = try Connection(NSHomeDirectory() + "/data.db")

            let users = Table("users")
            let id = Expression<Int64>("id")
            let name = Expression<String?>("name")
            let email = Expression<String>("email")

            // ignore potentical exception
            _  = try? db.run(users.create { t in
                t.column(id, primaryKey: true)
                t.column(name)
                t.column(email, unique: true)
            })
            // CREATE TABLE "users" (
            //     "id" INTEGER PRIMARY KEY NOT NULL,
            //     "name" TEXT,
            //     "email" TEXT NOT NULL UNIQUE
            // )

            let insert = users.insert(name <- "Alice", email <- "alice@mac.com")
            let insert2 = users.insert(name <- "Alice2", email <- "al2ice@mac.com")
            let insert3 = users.insert(name <- "Alice3", email <- "ali3ce@mac.com")
            
            let rowid = try db.run(insert)
            let rowid2 = try db.run(insert)
            let rowid3 = try db.run(insert)
            
            var result = "empty"
            // INSERT INTO "users" ("name", "email") VALUES ('Alice', 'alice@mac.com')

            for user in try db.prepare(users) {
                print("id: \(user[id]), name: \(user[name] ?? "null"), email: \(user[email])")
                result = result + " \(user[name] ?? "vedant ")"
                // id: 1, name: Optional("Alice"), email: alice@mac.com
            }
            // SELECT * FROM "users"

            let alice = users.filter(id == rowid)
        
//            try db.run(alice.update(email <- email.replace("mac.com", with: "me.com")))
//            // UPDATE "users" SET "email" = replace("email", 'mac.com', 'me.com')
//            // WHERE ("id" = 1)
//
//            try db.run(alice.delete())
//            // DELETE FROM "users" WHERE ("id" = 1)
//
//            let _ = try db.scalar(users.count) // 0
//            // SELECT count(*) FROM "users"
            return result
        }
        catch {
            print("ERROR: \(error)")
        }
        return "nill173"
    }
}
