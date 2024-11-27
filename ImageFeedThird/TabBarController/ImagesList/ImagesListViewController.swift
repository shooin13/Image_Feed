import UIKit
import Kingfisher

// MARK: - ImagesListViewController

class ImagesListViewController: UIViewController {
  // MARK: - Properties
  private let imagesListService = ImagesListService.shared
  private var photos: [Photo] = []
  private var isFetchingNextPage = false
  
  private lazy var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .none
    return formatter
  }()
  
  // MARK: - UI Elements
  private let tableView: UITableView = {
    let tableView = UITableView()
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 200
    tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    tableView.backgroundColor = UIColor(named: "YPBlack")
    return tableView
  }()
  
  // MARK: - View Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView()
    setupConstraints()
    setupObservers()
    imagesListService.fetchPhotosNextPage()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - Setup Observers
  private func setupObservers() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(updateTableViewAnimated),
      name: ImagesListService.didChangeNotification,
      object: nil
    )
  }
  
  // MARK: - Setup TableView
  private func setupTableView() {
    tableView.dataSource = self
    tableView.delegate = self
    tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
    view.addSubview(tableView)
  }
  
  private func setupConstraints() {
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
  
  // MARK: - Update TableView
  @objc private func updateTableViewAnimated() {
    let oldCount = photos.count
    let newCount = imagesListService.photos.count
    photos = imagesListService.photos
    isFetchingNextPage = false
    if oldCount != newCount {
      tableView.performBatchUpdates {
        let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
        tableView.insertRows(at: indexPaths, with: .automatic)
      } completion: { _ in }
    }
  }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return photos.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
    
    guard let imageListCell = cell as? ImagesListCell else {
      return UITableViewCell()
    }
    
    let photo = photos[indexPath.row]
    let thumbURL = URL(string: photo.thumbImageURL)
    
    imageListCell.delegate = self
    imageListCell.setLabelText(with: dateFormatter.string(from: photo.createdAt ?? Date()))
    imageListCell.setImage(with: thumbURL)
    imageListCell.setIsLiked(photo.isLiked)
    
    return imageListCell
  }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if indexPath.row == photos.count - 1 && !isFetchingNextPage {
      isFetchingNextPage = true
      imagesListService.fetchPhotosNextPage()
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let photo = photos[indexPath.row]
    guard let largeURL = URL(string: photo.largeImageURL) else {
      print("Некорректный URL для фото")
      return
    }
    
    let singleImageVC = SingleImageViewController()
    singleImageVC.imageURL = largeURL
    singleImageVC.modalPresentationStyle = .fullScreen
    present(singleImageVC, animated: true)
  }
}

// MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {
  func imageListCellDidUpdateHeight(_ cell: ImagesListCell) {
    DispatchQueue.main.async {
      guard let indexPath = self.tableView.indexPath(for: cell) else { return }
      self.tableView.beginUpdates()
      self.tableView.endUpdates()
    }
  }
  
  func imageListCellDidTapLike(_ cell: ImagesListCell) {
    guard let indexPath = tableView.indexPath(for: cell) else { return }
    var photo = photos[indexPath.row]
    
    UIBlockingProgressHUD.show()
    
    cell.isUserInteractionEnabled = false
    
    imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
      guard let self = self else { return }
      
      DispatchQueue.main.async {
        cell.isUserInteractionEnabled = true
        
        switch result {
        case .success:
          photo.isLiked.toggle()
          self.photos[indexPath.row].isLiked = photo.isLiked
          cell.setIsLiked(photo.isLiked)
          
        case .failure:
          let alert = UIAlertController(
            title: "Error",
            message: "Failed to change like status. Please try again.",
            preferredStyle: .alert
          )
          alert.addAction(UIAlertAction(title: "OK", style: .default))
          self.present(alert, animated: true)
        }
        
        UIBlockingProgressHUD.dismiss()
      }
    }
  }
}
