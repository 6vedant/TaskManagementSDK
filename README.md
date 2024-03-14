# TaskManagementSDK

TaskManagementSDK is a Swift package that demonstrates the CRUD operations of Tasks. It allows you to manage tasks seamlessly using the provided SDK.

![Task Management App Demo](images/app.gif)

## Installation

To integrate TaskManagement SDK into your project, you can use Swift Package Manager.

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


## SCADE App Example
Please checkout the [SCADE app](https://github.com/6vedant/TaskManagerApp) that uses this SDK to build a simple Task Management App.


## Contribution

<p>Consider contributing by creating a pull request (PR) or opening an issue. By creating an issue, you can alert the repository's maintainers to any bugs or missing documentation you've found. 🐛📝 If you're feeling confident and want to make a bigger impact, creating a PR, can be a great way to help others. 📖💡 Remember, contributing to open source is a collaborative effort, and any contribution, big or small, is always appreciated! 🙌 So why not take the first step and start contributing today? 😊</p>

#### Join SCADE Community: [SCADE Discord Channel](https://discord.gg/6PRedqCK)

