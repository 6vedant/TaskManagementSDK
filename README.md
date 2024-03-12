# TaskManagementSDK

TaskManagementSDK is a Swift package that demonstrates the CRUD operations of Tasks. It allows you to manage tasks seamlessly using the provided SDK.

## Installation

To integrate TaskManagementSDKConsumer into your project, you can use Swift Package Manager.

Add the following dependency to your `Package.swift` file:

```swift
// swift-tools-version:5.8

import PackageDescription
import Foundation

    dependencies: [
        .package(url: "https://github.com/6vedant/TaskManagementSDK.git", branch: "main")
    ],

    targets: [
        .target(
            name: "YourApp",
            dependencies: [
                .product(name: "TaskManagementSDK", package: "TaskManagementSDK"),
            ],
        )
    ]
)
```

## Usage
```swift
import TaskManagementSDK

// Create a weak reference to the TaskManager
weak var viewModel: TaskManager?

// Initialize the TaskManager instance
viewModel = TaskManager.viewModel

// Add tasks
let task = viewModel?.addTask("Task1")
let task2 = viewModel?.addTask("Task2")
let task3 = viewModel?.addTask("Task3")
let task4 = viewModel?.addTask("Task4")

// Get all task titles
let tasks = viewModel?.getAllTasksTitle()
print("All tasks: \(tasks ?? [])")

// Update a task
viewModel?.updateTask(id: task4!.id, newTaskTitle: "UpdatedTask4")

// Get updated task titles
let newTasks = viewModel?.getAllTasksTitle()
print("Updated tasks: \(newTasks ?? [])")
```
This code snippet demonstrates the basic usage of the TaskManagementSDK library.

