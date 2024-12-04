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
  
  func testPresenterCallsLoadRequest() {
    // given
    let authHelper = AuthHelper()
    let presenter = WebViewPresenter(authHelper: authHelper)
    let viewControllerSpy = WebViewViewControllerSpy()
    presenter.view = viewControllerSpy
    
    // when
    presenter.viewDidLoad()
    
    // then
    XCTAssertTrue(viewControllerSpy.loadRequestCalled, "Метод load(request:) у вьюконтроллера не был вызван")
    XCTAssertNotNil(viewControllerSpy.lastRequest, "URLRequest должен быть передан в метод load(request:)")
    XCTAssertEqual(viewControllerSpy.lastRequest?.url?.absoluteString, authHelper.authRequest()?.url?.absoluteString, "URLRequest должен содержать ожидаемый URL")
  }
  
  func testProgressHiddenWhenOne() {
    // given
    let presenter = WebViewPresenter()
    let viewControllerSpy = WebViewViewControllerSpy()
    presenter.view = viewControllerSpy
    
    // when
    presenter.didUpdateProgressValue(1.0)
    
    // then
    XCTAssertTrue(viewControllerSpy.isProgressHidden, "Progress должен быть скрыт, если значение равно единице")
  }
  
  
}
