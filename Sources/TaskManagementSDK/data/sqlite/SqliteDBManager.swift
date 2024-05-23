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
    private let taskTable = Table("tasks_table")
    
    /// Attributes for the `taskTable`
    
    /// The column representing the task ID in the SQLite table.
    private let id = Expression<String>("id")
    
    /// The column representing the task title in the SQLite table.
    private let title = Expression<String>("title")
    
    /// The column representing the task ID in the SQLite table.
    private let dateCreated = Expression<Double>("dateCreated")
    
    /// The column representing the task title in the SQLite table.
    private let isCompleted = Expression<Bool>("isCompleted")
  
    /// The column representing the task ID in the SQLite table.
    private let descriptionTask = Expression<String?>("descriptionTask")
    
    /// The column representing the task title in the SQLite table.
    private let priority = Expression<Int?>("priority")
    
    /// The column representing the task ID in the SQLite table.
    private let tags = Expression<String>("tags")
    
    /// The SQLite table for storing subtasks..
    private let subTaskTable = Table("subtasks_table")
    
    /// Attributes for the `subTasktable`
    
    /// The column representing the task ID in the SQLite table.
    private let parentTaskID = Expression<String>("parentTaskID")
    
    /// The column representing the task ID in the SQLite table.
    private let subTaskID = Expression<String>("subTaskID")
   
    /// The column representing the task title in the SQLite table.
    private let subTaskTitle = Expression<String>("subTaskTitle")
   
    /// The column representing the task title in the SQLite table.
    private let isSubTaskCompleted = Expression<Bool>("isSubTaskCompleted")
   
    
    /**
     Initializes a new instance of the `SqliteDBManager`.
     
     - Parameter databasePath: The file path of the SQLite database.
     */
    public init(databasePath: String) {
        do {
            db = try Connection(databasePath)
            createTaskTable()
            createSubTaskTable()
        } catch {
            print("Error creating database: \(error)")
        }
    }
    
    /**
     Creates the task table in the SQLite database if it doesn't exist.
     */
    private func createTaskTable() {
        do {
            _ = try db.run(taskTable.create { t in
                t.column(id, primaryKey: true)
                t.column(title)
                t.column(isCompleted)
                t.column(dateCreated)
                t.column(descriptionTask)
                t.column(priority)
                t.column(tags)
                
            })
            addDefaultTask()
        } catch {
            print("Error creating table: \(error)")
        }
    }
    
    /**
     Creates the task table in the SQLite database if it doesn't exist.
     */
    private func createSubTaskTable() {
        do {
            _ = try db.run(subTaskTable.create { t in
                t.column(subTaskID, primaryKey: true)
                t.column(parentTaskID)
                t.column(subTaskTitle)
                t.column(isSubTaskCompleted)
            })
            addDefaultSubTask()
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
    private func addDefaultSubTask() {
        let defaultSubTask = SubTask(parentTaskID: "-1", subTaskID: "-1", subTaskTitle: "Default")
        addSubTask(subTask: defaultSubTask)
    }
    
    /**
     Adds a task to the SQLite database.
     
     - Parameter task: The task to be added.
     - Returns: `true` if the task is successfully added, otherwise `false`.
     */
    public func addTask(task: Task) -> Bool {
        do {
            let insert = taskTable.insert(id <- task.id, title <- task.title, descriptionTask <- task.descriptionTask, dateCreated <- task.dateCreated, isCompleted <- task.isCompleted,  tags <- getTagsStringEquivalent(tags: task.tags), priority <- task.priority)
            try db.run(insert)
            return true
        } catch {
            print("Error adding task: \(error)")
            return false
        }
    }
    
    private func getTagsStringEquivalent(tags: [String]?) -> String {
        guard let tags = tags else {
            return ""
        }
        return tags.joined(separator: ",")
    }
    
    public func addSubTask(subTask: SubTask) -> Bool {
        do {
            let insert = subTaskTable.insert(parentTaskID <- subTask.parentTaskID, subTaskID <- subTask.subTaskID)
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
            try db.run(taskToUpdate.update(title <- task.title, descriptionTask <- task.descriptionTask, dateCreated <- task.dateCreated, isCompleted <- task.isCompleted,  tags <- getTagsStringEquivalent(tags: task.tags), priority <- task.priority))
            return true
        } catch {
            print("Error updating task: \(error)")
            return false
        }
    }
    
    public func updateSubTask(subTask: SubTask) -> Bool {
        let taskToUpdate = subTaskTable.filter(subTaskID == subTask.subTaskID)
        do {
            try db.run(taskToUpdate.update(parentTaskID <- subTask.parentTaskID, subTaskTitle <- subTask.subTaskTitle, isSubTaskCompleted <- subTask.isSubTaskCompleted))
            return true
        } catch {
            print("Error updating subtask: \(error)")
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
    
    public func deleteSubTask(subTaskID: String) -> Bool {
        let taskToDelete = subTaskTable.filter(self.subTaskID == subTaskID)
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
                let newTask = Task(id: task[id], title: task[title], descriptionTask: task[descriptionTask], dateCreated: task[dateCreated], isCompleted: task[isCompleted],  tags: getTagsArrayEquivalent(tagsString: task[tags]), priority: task[priority])
                allTasks.append(newTask)
            }
        } catch {
            print("Error fetching tasks: \(error)")
        }
        return allTasks
    }
    
    private func getTagsArrayEquivalent(tagsString: String) -> [String] {
        return tagsString.components(separatedBy: ",")
    }
    
    public func getAllSubtasks(forTaskID taskID: String) -> [SubTask] {
        var allSubTasks = [SubTask]()
        do {
            for subtask in try db.prepare(subTaskTable.filter(parentTaskID == taskID)) {
                // Assuming Subtask model and column names, modify as per your actual implementation
                let newSubtask = SubTask(parentTaskID: subtask[parentTaskID], subTaskID: subtask[subTaskID], subTaskTitle: subtask[subTaskTitle], isSubTaskComplted: subtask[isSubTaskCompleted])
                allSubTasks.append(newSubtask)
            }
        } catch {
            print("Error fetching subtasks: \(error)")
        }
        return allSubTasks
    }
}
