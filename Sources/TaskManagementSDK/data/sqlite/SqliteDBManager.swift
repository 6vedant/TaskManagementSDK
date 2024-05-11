//
//  SqliteDBManager.swift
//
//
//  Created by Vedant Jha on 11/05/24.
//

import Foundation
import SQLite

/**
 A class that manages SQLite database operations for tasks.
 */
public class SqliteDBManager {
    
    /// The SQLite database connection.
    private var db: Connection!
    
    /// The SQLite table for storing tasks.
    private let taskTable = Table("tasks")
    
    /// The column representing the task ID in the SQLite table.
    private let id = Expression<String>("id")
    
    /// The column representing the task title in the SQLite table.
    private let title = Expression<String>("title")
    
    /**
     Initializes a new instance of the `SqliteDBManager`.
     
     - Parameter databasePath: The file path of the SQLite database.
     */
    public init(databasePath: String) {
        do {
            db = try Connection(databasePath)
            createTable()
        } catch {
            print("Error creating database: \(error)")
        }
    }
    
    /**
     Creates the task table in the SQLite database if it doesn't exist.
     */
    private func createTable() {
        do {
            _ = try db.run(taskTable.create { t in
                t.column(id, primaryKey: true)
                t.column(title)
            })
            addDefaultTask()
        } catch {
            print("Error creating table: \(error)")
        }
    }
    
    private func addDefaultTask() {
        let defaultTask = Task(id: "-1", title: "Default")
        addTask(task: defaultTask)
        // if default task is already there, then delete it
        if getAllTasks().count > 1 {
            deleteTask(id: "-1")
        }
    }
    
    /**
     Adds a task to the SQLite database.
     
     - Parameter task: The task to be added.
     - Returns: `true` if the task is successfully added, otherwise `false`.
     */
    public func addTask(task: Task) -> Bool {
        do {
            let insert = taskTable.insert(id <- task.id, title <- task.title)
            try db.run(insert)
            return true
        } catch {
            print("Error adding task: \(error)")
            return false
        }
    }
    
    /**
     Updates a task in the SQLite database.
     
     - Parameter task: The task to be updated.
     - Returns: `true` if the task is successfully updated, otherwise `false`.
     */
    public func updateTask(task: Task) -> Bool {
        let taskToUpdate = taskTable.filter(id == task.id)
        do {
            try db.run(taskToUpdate.update(title <- task.title))
            return true
        } catch {
            print("Error updating task: \(error)")
            return false
        }
    }
    
    /**
     Deletes a task from the SQLite database.
     
     - Parameter id: The ID of the task to be deleted.
     - Returns: `true` if the task is successfully deleted, otherwise `false`.
     */
    public func deleteTask(id: String) -> Bool {
        let taskToDelete = taskTable.filter(self.id == id)
        do {
            try db.run(taskToDelete.delete())
            return true
        } catch {
            print("Error deleting task: \(error)")
            return false
        }
    }
    
    /**
     Retrieves all tasks from the SQLite database.
     
     - Returns: An array containing all tasks.
     */
    public func getAllTasks() -> [Task] {
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
}
