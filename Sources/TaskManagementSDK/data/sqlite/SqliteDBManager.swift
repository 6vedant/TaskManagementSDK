//
//  SqliteDBManager.swift
//
//
//  Created by Vedant Jha on 11/05/24.
//

import Foundation
import SQLite

public class SqliteDBManager {
    private var db: Connection!
    private let taskTable = Table("tasks")
    private let id = Expression<String>("id")
    private let title = Expression<String>("title")

    public init(databasePath: String) {
        do {
            db = try Connection(databasePath)
            createTable()
        } catch {
            print("error creating database")
        }
    }
    
    private func createTable() {
        do {
            _ = try db.run(taskTable.create { t in
                t.column(id, primaryKey: true)
                t.column(title)
            })
        } catch {
            print("Error creating table: \(error)")
        }
    }
    
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
