import Foundation
@testable import ImageFeedThird

// MARK: - ImagesListViewPresenterSpy

final class ImagesListViewPresenterSpy: ImagesListPresenterProtocol {
  // MARK: - Properties
  
  weak var view: ImagesListViewControllerProtocol?
  var photosCount = 0
  
  var onViewDidLoadCalled = false
  var didScrollToLastCellCalled = false
  var didSelectPhotoCalled = false
  var toggleLikeCalled = false
  var formattedDateCalled = false
  
  var lastSelectedPhotoIndex: Int?
  var lastLikePhotoIndex: Int?
  var lastFormattedDate: Date?
  
  // MARK: - ImagesListPresenterProtocol Methods
  
  func onViewDidLoad() {
    onViewDidLoadCalled = true
  }
  
  func didScrollToLastCell(at index: Int) {
    didScrollToLastCellCalled = true
    lastSelectedPhotoIndex = index
  }
  
  func photo(at index: Int) -> Photo? {
    return nil
  }
  
  func toggleLike(forPhotoAt index: Int, withCell cell: ImagesListCell) {
    toggleLikeCalled = true
    lastLikePhotoIndex = index
  }
  
  func formattedDate(from date: Date) -> String {
    formattedDateCalled = true
    lastFormattedDate = date
    return "Mock Date"
  }
  
  func didSelectPhoto(at index: Int) {
    didSelectPhotoCalled = true
    lastSelectedPhotoIndex = index
  }
}
