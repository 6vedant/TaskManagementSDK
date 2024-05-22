import XCTest
@testable import TaskManagementSDK

final class TaskManagementSDKTests: XCTestCase {
    var taskManager: TaskManager!
    
    override func setUpWithError() throws {
        taskManager = TaskManager()
    }
    
    func testAddTask() throws {
        // Given
        let taskTitle = "Test Task"
        let taskDescription = "This is a test task."
        let isCompleted = false
        let tags: [String] = ["test", "swift"]
        let priority = 1
        
        // When
        let addedTask = taskManager.addTask(
            title: taskTitle,
            description: taskDescription,
            isCompleted: isCompleted,
            tags: tags,
            priority: priority
        )
        
        // Then
        XCTAssertEqual(addedTask.title, taskTitle)
        XCTAssertEqual(addedTask.description, taskDescription)
        XCTAssertEqual(addedTask.isCompleted, isCompleted)
        XCTAssertEqual(addedTask.tags, tags)
        XCTAssertEqual(addedTask.priority, priority)
        XCTAssertTrue(taskManager.getAllTasks().contains { $0.id == addedTask.id })
    }
    
    func testUpdateTask() throws {
        // Given
        let taskTitle = "Test Task"
        let taskDescription = "This is a test task."
        let addedTask = taskManager.addTask(title: taskTitle, description: taskDescription)
        
        let updatedTaskTitle = "Updated Test Task"
        let updatedTaskDescription = "This is an updated test task."
        let updatedIsCompleted = true
        let updatedTags: [String] = ["updated", "test"]
        let updatedPriority = 2
        
        // When
        guard let updatedTask = taskManager.updateTask(
            id: addedTask.id,
            newTitle: updatedTaskTitle,
            newDescription: updatedTaskDescription,
            isCompleted: updatedIsCompleted,
            tags: updatedTags,
            priority: updatedPriority
        ) else {
            XCTFail("Failed to update the task")
            return
        }
        
        // Then
        XCTAssertEqual(updatedTask.title, updatedTaskTitle)
        XCTAssertEqual(updatedTask.description, updatedTaskDescription)
        XCTAssertEqual(updatedTask.isCompleted, updatedIsCompleted)
        XCTAssertEqual(updatedTask.tags, updatedTags)
        XCTAssertEqual(updatedTask.priority, updatedPriority)
        XCTAssertTrue(taskManager.getAllTasks().contains { $0.id == updatedTask.id })
    }
    
    func testRemoveTask() throws {
        // Given
        let taskTitle = "Test Task"
        let addedTask = taskManager.addTask(title: taskTitle)
        
        // When
        taskManager.removeTask(addedTask)
        
        // Then
        XCTAssertFalse(taskManager.getAllTasks().contains { $0.id == addedTask.id })
    }
    
    func testAddSubtask() throws {
        // Given
        let taskTitle = "Test Task"
        let subTaskTitle = "Test Subtask"
        let addedTask = taskManager.addTask(title: taskTitle)
        
        // When
        guard let addedSubtask = taskManager.addSubtask(to: addedTask.id, subTaskTitle: subTaskTitle) else {
            XCTFail("Failed to add the subtask")
            return
        }
        
        // Then
        XCTAssertEqual(addedSubtask.subTaskTitle, subTaskTitle)
        XCTAssertTrue(taskManager.getSubtasks(for: addedTask.id)?.contains { $0.parentTaskID == addedSubtask.parentTaskID && $0.subTaskTitle == addedSubtask.subTaskTitle } ?? false)
    }
    
    func testGetSubtasks() throws {
        // Given
        let taskTitle = "Test Task"
        let subTaskTitle1 = "Test Subtask 1"
        let subTaskTitle2 = "Test Subtask 2"
        let addedTask = taskManager.addTask(title: taskTitle)
        _ = taskManager.addSubtask(to: addedTask.id, subTaskTitle: subTaskTitle1)
        _ = taskManager.addSubtask(to: addedTask.id, subTaskTitle: subTaskTitle2)
        
        // When
        let subtasks = taskManager.getSubtasks(for: addedTask.id)
        
        // Then
        XCTAssertEqual(subtasks?.count, 2)
        XCTAssertTrue(subtasks?.contains { $0.subTaskTitle == subTaskTitle1 } ?? false)
        XCTAssertTrue(subtasks?.contains { $0.subTaskTitle == subTaskTitle2 } ?? false)
    }
}
