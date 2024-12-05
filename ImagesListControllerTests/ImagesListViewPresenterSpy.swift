import Foundation
@testable import ImageFeedThird

final class ImagesListViewPresenterSpy: ImagesListPresenterProtocol {
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
