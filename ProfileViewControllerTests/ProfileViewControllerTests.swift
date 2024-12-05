@testable import ImageFeedThird
import XCTest

final class ProfileViewControllerTests: XCTestCase {
  func testProfileViewControllerCallsPresenterOnViewDidLoad() {
    // Given
    let presenterSpy = ProfilePresenterSpy()
    let viewController = ProfileViewController(presenter: presenterSpy)
    presenterSpy.view = viewController
    
    // When
    _ = viewController.view
    
    // Then
    XCTAssertTrue(presenterSpy.onViewDidLoadCalled, "Метод onViewDidLoad презентера не был вызван")
  }
  
  func testProfileViewControllerDisplaysProfileData() {
    // Given
    let viewControllerSpy = ProfileViewControllerSpy()
    let presenterSpy = ProfilePresenterSpy()
    presenterSpy.view = viewControllerSpy
    
    // When
    viewControllerSpy.displayProfile(name: "John Doe", loginName: "@johndoe", bio: "A simple bio", avatarURL: "https://example.com/avatar.jpg")
    
    // Then
    XCTAssertTrue(viewControllerSpy.displayProfileCalled, "Метод displayProfile не был вызван")
    XCTAssertEqual(viewControllerSpy.displayedProfileData?.name, "John Doe")
    XCTAssertEqual(viewControllerSpy.displayedProfileData?.loginName, "@johndoe")
    XCTAssertEqual(viewControllerSpy.displayedProfileData?.bio, "A simple bio")
    XCTAssertEqual(viewControllerSpy.displayedProfileData?.avatarURL, "https://example.com/avatar.jpg")
  }
  
  func testProfileViewControllerCallsPresenterOnLogoutButtonTapped() {
    // Given
    let presenterSpy = ProfilePresenterSpy()
    let viewController = ProfileViewController(presenter: presenterSpy)
    presenterSpy.view = viewController
    
    // When
    viewController.simulateLogoutButtonTap()
    
    // Then
    XCTAssertTrue(presenterSpy.onLogoutButtonTappedCalled, "Метод onLogoutButtonTapped презентера не был вызван")
  }
  
}
