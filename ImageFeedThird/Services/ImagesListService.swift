import UIKit

// MARK: - ImagesListService

final class ImagesListService {
  
  // MARK: - Shared Instance
  
  static let shared = ImagesListService()
  
  private init() {}
  
  // MARK: - Notifications
  static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
  
  // MARK: - Properties
  private(set) var photos: [Photo] = []
  private var lastLoadedPage: Int?
  private var isLoading: Bool = false
  private let urlSession: URLSession = .shared
  
  // MARK: - Public Methods
  func fetchPhotosNextPage() {
    guard !isLoading else { return }
    
    let nextPage = (lastLoadedPage ?? 0) + 1
    isLoading = true
    
    guard let request = makeFetchPhotosRequest(page: nextPage) else {
      print("[fetchPhotosNextPage]: [NetworkError] Ошибка создания запроса")
      isLoading = false
      return
    }
    
    let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
      DispatchQueue.main.async {
        guard let self = self else { return }
        self.isLoading = false
        
        switch result {
        case .success(let photoResults):
          let newPhotos = photoResults.map { self.convertToPhoto(from: $0) }
          self.photos.append(contentsOf: newPhotos)
          self.lastLoadedPage = nextPage
          NotificationCenter.default.post(
            name: ImagesListService.didChangeNotification,
            object: self
          )
        case .failure(let error):
          print("[fetchPhotosNextPage]: [NetworkError] Ошибка сети \(error.localizedDescription), Request: \(request)")
          let alert = UIAlertController(
            title: "Ошибка сети",
            message: "Не удалось загрузить фотографии. Проверьте подключение к интернету.",
            preferredStyle: .alert
          )
          alert.addAction(UIAlertAction(title: "OK", style: .default))
          UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
        }
      }
    }
    task.resume()
  }
  
  // MARK: - Reset Photos
  func resetPhotos() {
    photos = []
    lastLoadedPage = nil
    isLoading = false
  }
  
  func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
    guard let request = makeLikeRequest(photoId: photoId, isLike: isLike) else {
      print("[changeLike]: [NetworkError] Ошибка создания запроса, PhotoID: \(photoId)")
      completion(.failure(NetworkError.urlSessionError))
      return
    }
    
    let task = urlSession.objectTask(for: request) { (result: Result<LikeResponse, Error>) in
      DispatchQueue.main.async {
        switch result {
        case .success:
          print("[changeLike]: Лайк успешно обновлён, PhotoID: \(photoId)")
          completion(.success(()))
        case .failure(let error):
          print("[changeLike]: [NetworkError] Ошибка изменения лайка \(error.localizedDescription), PhotoID: \(photoId), Request: \(request)")
          completion(.failure(error))
        }
      }
    }
    task.resume()
  }
  
  // MARK: - Private Methods
  
  private func makeFetchPhotosRequest(page: Int) -> URLRequest? {
    guard let url = URL(string: "https://api.unsplash.com/photos?page=\(page)&per_page=10") else {
      assertionFailure("Не удалось создать URL для запроса фотографий")
      return nil
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    guard let accessToken = OAuth2TokenStorage().token else {
      assertionFailure("Токен доступа отсутствует")
      return nil
    }
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    return request
  }
  
  private func makeLikeRequest(photoId: String, isLike: Bool) -> URLRequest? {
    let endpoint = isLike
    ? "https://api.unsplash.com/photos/\(photoId)/like"
    : "https://api.unsplash.com/photos/\(photoId)/like"
    
    guard let url = URL(string: endpoint) else {
      assertionFailure("Не удалось создать URL для изменения лайка")
      return nil
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = isLike ? "POST" : "DELETE"
    guard let accessToken = OAuth2TokenStorage().token else {
      assertionFailure("Токен доступа отсутствует")
      return nil
    }
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    return request
  }
  
  private func convertToPhoto(from photoResult: PhotoResult) -> Photo {
    let size = CGSize(width: photoResult.width, height: photoResult.height)
    let createdAt = ISO8601DateFormatter().date(from: photoResult.createdAt)
    
    return Photo(
      id: photoResult.id,
      size: size,
      createdAt: createdAt,
      welcomeDescription: photoResult.description,
      thumbImageURL: photoResult.urls.thumb,
      largeImageURL: photoResult.urls.full,
      isLiked: photoResult.likedByUser
    )
  }
}
