//
//  Task.swift
//  
//
//  Created by Vedant Jha on 05/03/24.
//

import Foundation

public class Task: NSObject, Identifiable {
    
    public init(id: String, title: String) {
        self.id = id
        self.title = title
    }
    
    // id of the Task
    public var id: String
    
    // title of the Task
    public var title: String
    
    
}
