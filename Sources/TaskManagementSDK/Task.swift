//
//  Task.swift
//  
//
//  Created by Vedant Jha on 05/03/24.
//

import Foundation

public class Task: NSObject, Identifiable {
    
    // Initializer
        public init(
            id: String,
            title: String,
            descriptionTask: String? = nil,
            dateCreated: Double = Date().timeIntervalSince1970,
            isCompleted: Bool = false,
            subTasks: [SubTask]? = nil,
            tags: [String]? = nil,
            priority: Int? = nil
        ) {
            self.id = id
            self.title = title
            self.descriptionTask = descriptionTask
            self.dateCreated = dateCreated
            self.isCompleted = isCompleted
            self.subTasks = subTasks
            self.tags = tags
            self.priority = priority
        }
    
    // id of the Task
    public var id: String
    
    // title of the Task
    public var title: String
    
    public var dateCreated: Double
    
    public var isCompleted: Bool
    
    public var descriptionTask: String?
    
    public var subTasks: [SubTask]?
    
    public var priority: Int?
    
    public var tags: [String]?
}

public class SubTask: NSObject {
    
    // Properties
    public var parentTaskID: String
    public var subTaskID: String
    public var subTaskTitle: String
    public var isSubTaskCompleted: Bool = false
    
    // Initializer
    public init(
        parentTaskID: String,
        subTaskID: String,
        subTaskTitle: String,
        isSubTaskComplted: Bool = false
    ) {
        self.parentTaskID = parentTaskID
        self.subTaskID = subTaskID
        self.subTaskTitle = subTaskTitle
        self.isSubTaskCompleted = isSubTaskComplted
    }
}

