import UIKit
@testable import ImageFeedThird

// MARK: - ImagesListViewControllerSpy

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
  // MARK: - Properties
  
  var updateTableViewAnimatedCalled = false
  var showNetworkErrorCalled = false
  var openImageInSingleImageViewControllerCalled = false
  var lastOpenedImageURL: URL?
  
  var presenter: ImagesListPresenterProtocol?
  
  // MARK: - ImagesListViewControllerProtocol Methods
  
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
