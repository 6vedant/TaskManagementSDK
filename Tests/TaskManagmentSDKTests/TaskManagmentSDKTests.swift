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
        XCTAssertTrue(((taskManager.getAllTasks()?.contains(addedTask)) != nil))
    }
//    
//    func testUpdateTask() throws {
//        // Given
//        let taskTitle = "Test Task"
//        let updatedTaskTitle = "Updated Test Task"
//        let addedTask = taskManager.addTask(taskTitle)
//        
//        // When
//        let updatedTask = taskManager.updateTask(id: addedTask.id, newTaskTitle: updatedTaskTitle)
//        
//        // Then
//        XCTAssertEqual(updatedTask.title, updatedTaskTitle)
//        XCTAssertTrue(((taskManager.getAllTasks()?.contains(updatedTask)) != nil))
//        XCTAssertFalse(((taskManager.getAllTasks()?.contains(addedTask)) != nil))
//    }
//    
//    func testRemoveTask() throws {
//        // Given
//        let taskTitle = "Test Task"
//        let addedTask = taskManager.addTask(taskTitle)
//        
//        // When
//        taskManager.removeTask(addedTask)
//        
//        // Then
//        XCTAssertFalse(((taskManager.getAllTasks()?.contains(addedTask)) != nil))
//    }
}
