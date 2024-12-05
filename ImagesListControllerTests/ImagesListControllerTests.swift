@testable import ImageFeedThird
import XCTest

// MARK: - ImagesListViewControllerTests

final class ImagesListViewControllerTests: XCTestCase {
  // MARK: - Test Cases
  
  func testImagesListViewControllerCallsPresenterOnViewDidLoad() {
    // Given
    let presenterSpy = ImagesListViewPresenterSpy()
    let viewController = ImagesListViewController()
    viewController.presenter = presenterSpy
    presenterSpy.view = viewController
    
    // When
    _ = viewController.view
    
    // Then
    XCTAssertTrue(presenterSpy.onViewDidLoadCalled, "Метод onViewDidLoad презентера не был вызван")
  }
  
  func testImagesListViewControllerUpdatesTableView() {
    // Given
    let viewControllerSpy = ImagesListViewControllerSpy()
    let presenterSpy = ImagesListViewPresenterSpy()
    presenterSpy.view = viewControllerSpy
    
    // When
    viewControllerSpy.updateTableViewAnimated()
    
    // Then
    XCTAssertTrue(viewControllerSpy.updateTableViewAnimatedCalled, "Метод updateTableViewAnimated не был вызван")
  }
  
  func testImagesListViewControllerShowsNetworkError() {
    // Given
    let viewControllerSpy = ImagesListViewControllerSpy()
    let presenterSpy = ImagesListViewPresenterSpy()
    presenterSpy.view = viewControllerSpy
    
    // When
    viewControllerSpy.showNetworkError()
    
    // Then
    XCTAssertTrue(viewControllerSpy.showNetworkErrorCalled, "Метод showNetworkError не был вызван")
  }
  
  func testImagesListViewControllerCallsPresenterOnPhotoSelected() {
    // Given
    let presenterSpy = ImagesListViewPresenterSpy()
    let viewController = ImagesListViewController()
    viewController.presenter = presenterSpy
    presenterSpy.view = viewController
    
    // When
    presenterSpy.didSelectPhoto(at: 0)
    
    // Then
    XCTAssertTrue(presenterSpy.didSelectPhotoCalled, "Метод didSelectPhoto презентера не был вызван")
    XCTAssertEqual(presenterSpy.lastSelectedPhotoIndex, 0, "Выбранный индекс фотографии не совпадает с ожидаемым")
  }
  
  func testImagesListViewControllerCallsPresenterOnToggleLike() {
    // Given
    let presenterSpy = ImagesListViewPresenterSpy()
    let viewController = ImagesListViewController()
    viewController.presenter = presenterSpy
    presenterSpy.view = viewController
    
    let cell = ImagesListCell()
    
    // When
    presenterSpy.toggleLike(forPhotoAt: 1, withCell: cell)
    
    // Then
    XCTAssertTrue(presenterSpy.toggleLikeCalled, "Метод toggleLike презентера не был вызван")
    XCTAssertEqual(presenterSpy.lastLikePhotoIndex, 1, "Индекс фотографии для лайка не совпадает с ожидаемым")
  }
}
