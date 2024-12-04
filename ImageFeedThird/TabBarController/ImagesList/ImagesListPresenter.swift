import Foundation
import UIKit

// MARK: - Protocols

protocol ImagesListPresenterProtocol: AnyObject {
  var photosCount: Int { get }
  func onViewDidLoad()
  func didScrollToLastCell(at index: Int)
  func photo(at index: Int) -> Photo?
  func toggleLike(forPhotoAt index: Int, withCell cell: ImagesListCell)
  func formattedDate(from date: Date) -> String
  func didSelectPhoto(at index: Int)
}

// MARK: - ImagesListPresenter

final class ImagesListPresenter: ImagesListPresenterProtocol {
  weak var view: ImagesListViewControllerProtocol?
  private let imagesListService: ImagesListService
  private let dateFormatter: DateFormatter
  private var photos: [Photo] = []
  
  // MARK: - Initializer
  init(view: ImagesListViewControllerProtocol,
       imagesListService: ImagesListService = ImagesListService.shared) {
    self.view = view
    self.imagesListService = imagesListService
    self.dateFormatter = DateFormatter()
    self.dateFormatter.dateStyle = .long
    self.dateFormatter.timeStyle = .none
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(onPhotosUpdated),
      name: ImagesListService.didChangeNotification,
      object: nil
    )
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - ImagesListPresenterProtocol
  var photosCount: Int {
    return photos.count
  }
  
  func onViewDidLoad() {
    imagesListService.fetchPhotosNextPage()
  }
  
  func didScrollToLastCell(at index: Int) {
    if index == photos.count - 1 {
      imagesListService.fetchPhotosNextPage()
    }
  }
  
  func photo(at index: Int) -> Photo? {
    guard index < photos.count else { return nil }
    return photos[index]
  }
  
  func toggleLike(forPhotoAt index: Int, withCell cell: ImagesListCell) {
    guard index < photos.count else { return }
    
    let photo = photos[index]
    UIBlockingProgressHUD.show()
    imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
      UIBlockingProgressHUD.dismiss()
      
      switch result {
      case .success:
        self?.photos[index].isLiked.toggle()
        cell.setIsLiked(self?.photos[index].isLiked ?? false)
      case .failure:
        self?.view?.showNetworkError()
      }
    }
  }
  
  func formattedDate(from date: Date) -> String {
    return dateFormatter.string(from: date)
  }
  
  func didSelectPhoto(at index: Int) {
    guard index < photos.count, let url = URL(string: photos[index].largeImageURL) else { return }
    view?.openImageInSingleImageViewController(url: url)
  }
  
  // MARK: - Notification Handlers
  @objc private func onPhotosUpdated() {
    photos = imagesListService.photos
    view?.updateTableViewAnimated()
  }
}
