import XCTest
@testable import TaskManagementSDK

final class TaskManagmentSDKTests: XCTestCase {
    var taskManager: TaskManager!
    
    override func setUpWithError() throws {
        taskManager = TaskManager()
    }
    
    func testAddTask() throws {
        // Given
        let taskTitle = "Test Task"
        
        // When
        let addedTask = taskManager.addTask(taskTitle)
        
        // Then
        XCTAssertEqual(addedTask.title, taskTitle)
        XCTAssertTrue(taskManager.getAllTasksTitle().contains(taskTitle))
    }
    
    func testUpdateTask() throws {
        // Given
        let taskTitle = "Test Task"
        let updatedTaskTitle = "Updated Test Task"
        let addedTask = taskManager.addTask(taskTitle)
        
        // When
        let updatedTask = taskManager.updateTask(id: addedTask.id, newTaskTitle: updatedTaskTitle)
        
        // Then
        XCTAssertEqual(updatedTask.title, updatedTaskTitle)
        XCTAssertTrue(taskManager.getAllTasksTitle().contains(updatedTaskTitle))
        XCTAssertFalse(taskManager.getAllTasksTitle().contains(taskTitle))
    }
    
    func testRemoveTask() throws {
        // Given
        let taskTitle = "Test Task"
        let addedTask = taskManager.addTask(taskTitle)
        
        // When
        taskManager.removeTask(addedTask)
        
        // Then
        XCTAssertFalse(taskManager.getAllTasksTitle().contains(taskTitle))
    }
}
