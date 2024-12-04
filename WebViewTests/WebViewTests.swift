@testable import ImageFeedThird
import XCTest

final class WebViewTests: XCTestCase {
  func testViewControllerCallsViewDidLoad() {
    // given
    let viewController = WebViewViewController()
    let presenter = WebViewPresenterSpy()
    viewController.presenter = presenter
    presenter.view = viewController
    
    // when
    _ = viewController.view // Триггер загрузки view
    
    // then
    XCTAssertTrue(presenter.viewDidLoadCalled, "Метод viewDidLoad у презентера не был вызван")
  }
}
