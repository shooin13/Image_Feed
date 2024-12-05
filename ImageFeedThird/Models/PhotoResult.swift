// MARK: - PhotoResult

struct PhotoResult: Decodable {
  // MARK: - Properties
  
  let id: String
  let createdAt: String
  let updatedAt: String
  let width: Int
  let height: Int
  let color: String
  let blurHash: String
  let likes: Int
  let likedByUser: Bool
  let description: String?
  let urls: UrlsResult
  
  // MARK: - CodingKeys
  
  private enum CodingKeys: String, CodingKey {
    case id
    case createdAt = "created_at"
    case updatedAt = "updated_at"
    case width
    case height
    case color
    case blurHash = "blur_hash"
    case likes
    case likedByUser = "liked_by_user"
    case description
    case urls
  }
}

// MARK: - LikeResponse

struct LikeResponse: Decodable {
  // MARK: - Properties
  
  let photo: PhotoResult
}
