import UIKit
import Kingfisher

// MARK: - Protocols

protocol ImagesListViewControllerProtocol: AnyObject {
  var presenter: ImagesListPresenterProtocol? { get set }
  func updateTableViewAnimated()
  func showNetworkError()
  func openImageInSingleImageViewController(url: URL)
}

// MARK: - ImagesListViewController

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
  // MARK: - Properties
  
  var presenter: ImagesListPresenterProtocol?
  
  private let tableView: UITableView = {
    let tableView = UITableView()
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 200
    tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    tableView.backgroundColor = UIColor(named: "YPBlack")
    return tableView
  }()
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView()
    setupConstraints()
    presenter?.onViewDidLoad()
  }
  
  // MARK: - Setup
  
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
  
  // MARK: - Protocol Implementation
  
  func updateTableViewAnimated() {
    tableView.reloadData()
  }
  
  func showNetworkError() {
    let alert = UIAlertController(
      title: "Ошибка сети",
      message: "Не удалось загрузить фотографии. Проверьте подключение к интернету.",
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    present(alert, animated: true)
  }
  
  func openImageInSingleImageViewController(url: URL) {
    let singleImageVC = SingleImageViewController()
    singleImageVC.imageURL = url
    singleImageVC.modalPresentationStyle = .fullScreen
    present(singleImageVC, animated: true)
  }
}


// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return presenter?.photosCount ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
    
    guard let imageListCell = cell as? ImagesListCell,
          let photo = presenter?.photo(at: indexPath.row) else {
      return UITableViewCell()
    }
    
    imageListCell.delegate = self
    imageListCell.setLabelText(with: photo.createdAt.map { presenter?.formattedDate(from: $0) } ?? "Дата неизвестна")
    imageListCell.setImage(with: URL(string: photo.thumbImageURL))
    imageListCell.setIsLiked(photo.isLiked)
    
    return imageListCell
  }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    presenter?.didScrollToLastCell(at: indexPath.row)
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    presenter?.didSelectPhoto(at: indexPath.row)
  }
}

// MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {
  func imageListCellDidUpdateHeight(_ cell: ImagesListCell) {
    DispatchQueue.main.async {
      self.tableView.beginUpdates()
      self.tableView.endUpdates()
    }
  }
  
  func imageListCellDidTapLike(_ cell: ImagesListCell) {
    guard let indexPath = tableView.indexPath(for: cell) else { return }
    presenter?.toggleLike(forPhotoAt: indexPath.row, withCell: cell)
  }
}
