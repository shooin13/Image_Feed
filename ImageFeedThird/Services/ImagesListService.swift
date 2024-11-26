import Foundation

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
      print("[fetchPhotosNextPage]: Ошибка создания запроса")
      isLoading = false
      return
    }
    
    let task = urlSession.objectTask(for: request) { (result: Result<[PhotoResult], Error>) in
      DispatchQueue.main.async {
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
          print("[fetchPhotosNextPage]: Ошибка сети - \(error.localizedDescription)")
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
