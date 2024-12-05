import UIKit
@testable import ImageFeedThird

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
  var updateTableViewAnimatedCalled = false
  var showNetworkErrorCalled = false
  var openImageInSingleImageViewControllerCalled = false
  var lastOpenedImageURL: URL?
  
  var presenter: ImagesListPresenterProtocol?
  
  func updateTableViewAnimated() {
    updateTableViewAnimatedCalled = true
  }
  
  func showNetworkError() {
    showNetworkErrorCalled = true
  }
  
  func openImageInSingleImageViewController(url: URL) {
    openImageInSingleImageViewControllerCalled = true
    lastOpenedImageURL = url
  }
}
