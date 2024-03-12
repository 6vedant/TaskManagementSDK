//
//  Task.swift
//  
//
//  Created by VJ on 05/03/24.
//

import Foundation

public class Task: NSObject, Identifiable {
    
    public init(id: Int, title: String) {
        self.id = id
        self.title = title
    }
    
    // The merchant's ISO country code.
    public var id: Int
    
    // title of the Task
    public var title: String
    
    
}
