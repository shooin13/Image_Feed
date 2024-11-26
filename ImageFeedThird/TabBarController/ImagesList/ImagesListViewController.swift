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
    
    imageListCell.cellImage.kf.indicatorType = .activity
    
    imageListCell.cellImage.kf.setImage(
      with: thumbURL,
      placeholder: UIImage(named: "ImageListCellPlaceholder"),
      options: [.transition(.fade(0.3))]
    ) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success:
        UIView.animate(withDuration: 0.3) {
          self.tableView.beginUpdates()
          self.tableView.endUpdates()
        }
        imageListCell.showGradientAndLabel()
      case .failure(let error):
        print("Ошибка загрузки изображения: \(error.localizedDescription)")
      }
    }
    
    imageListCell.cellLabel.text = dateFormatter.string(from: photo.createdAt ?? Date())
    
    let isLiked = indexPath.row % 2 != 0
    let likeImage = isLiked ? UIImage(named: "LikeOn") : UIImage(named: "LikeOff")
    imageListCell.cellButton.setImage(likeImage, for: .normal)
    
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
    let largeURL = URL(string: photo.largeImageURL)
    
    let singleImageVC = SingleImageViewController()
    singleImageVC.imageURL = largeURL
    singleImageVC.modalPresentationStyle = .fullScreen
    present(singleImageVC, animated: true)
  }
}
