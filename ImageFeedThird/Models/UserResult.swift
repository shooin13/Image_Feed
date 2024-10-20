//MARK: - UserResult

struct UserResult: Codable {
  let profile_image: ProfileImage
  
  struct ProfileImage: Codable {
    let small: String
  }
}
