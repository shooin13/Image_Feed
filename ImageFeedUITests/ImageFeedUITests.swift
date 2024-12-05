import XCTest

class ImageFeedUITests: XCTestCase {
  private let app = XCUIApplication()
  
  override func setUpWithError() throws {
    continueAfterFailure = false
    app.launch()
  }
  
  override func tearDownWithError() throws {
    // Очистка после выполнения тестов
  }
  
  func testAuth() throws {
    // Нажимаем на кнопку авторизации
    app.buttons["Authenticate"].tap()
    
    // Ждем появления WebView
    let webView = app.webViews["UnsplashWebView"]
    XCTAssertTrue(webView.waitForExistence(timeout: 5))
    
    // Вводим логин
    let loginTextField = webView.descendants(matching: .textField).element
    XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
    loginTextField.tap()
    loginTextField.typeText("pavel.nikolaev.nm@gmail.com")
    webView.swipeUp()
    
    // Вводим пароль
    let passwordTextField = webView.descendants(matching: .secureTextField).element
    XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
    passwordTextField.tap()
    passwordTextField.typeText("5nwcSfXwBmPUVJ9")
    webView.swipeUp()
    
    // Нажимаем на кнопку логина
    webView.buttons["Login"].tap()
    
    // Ждем появления первой ячейки ленты
    let tablesQuery = app.tables
    let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
    XCTAssertTrue(cell.waitForExistence(timeout: 5))
  }
  
  func testFeed() throws {
    // Ждем появления первой ячейки ленты
    let tablesQuery = app.tables
    let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
    cell.swipeUp() // Скроллим вверх
    
    sleep(2)
    
    // Лайкаем фотографию
    let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
    cellToLike.buttons["like button off"].tap()
    cellToLike.buttons["like button on"].tap()
    
    sleep(2)
    
    // Открываем фотографию
    cellToLike.tap()
    sleep(2)
    
    // Увеличиваем фотографию
    let image = app.scrollViews.images.element(boundBy: 0)
    image.pinch(withScale: 3, velocity: 1) // Zoom in
    image.pinch(withScale: 0.5, velocity: -1) // Zoom out
    
    // Возвращаемся к ленте
    let navBackButtonWhiteButton = app.buttons["nav back button white"]
    navBackButtonWhiteButton.tap()
  }
  
  
  func testProfile() throws {
    sleep(3) // Ожидание загрузки
    
    // Переход в профиль
    app.tabBars.buttons.element(boundBy: 1).tap()
    
    // Проверка отображения имени и логина
    XCTAssertTrue(app.staticTexts["pavel nikolaev"].exists)
    XCTAssertTrue(app.staticTexts["@shooingmail"].exists)
    
    // Нажимаем кнопку выхода
    app.buttons["logout button"].tap()
    
    // Подтверждаем выход
    app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
  }
  
}
