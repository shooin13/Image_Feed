import UIKit

// MARK: - ImagesListViewController

class ImagesListViewController: UIViewController {
  
  // MARK: - Properties
  
  private let photosName: [String] = Array(0..<20).map{"\($0)"}
  
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
    tableView.rowHeight = 200
    tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    tableView.backgroundColor = UIColor(named: "YPBlack")
    return tableView
  }()
  
  // MARK: - View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView()
    setupConstraints()
  }
  
  // MARK: - Setup Methods
  
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
  
  // MARK: - Cell Configuration
  
  private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
    guard let image = UIImage(named: "\(photosName[indexPath.row])") else { return }
    cell.cellImage.image = image
    configureGradient(for: cell)
    cell.cellLabel.text = dateFormatter.string(from: Date())
    cell.cellButton.setTitle("", for: .normal)
    let isLiked = indexPath.row % 2 == 0
    let likeImage = isLiked ? UIImage(named: "LikeOn") : UIImage(named: "LikeOff")
    cell.cellButton.setImage(likeImage, for: .normal)
  }
  
  private func configureGradient(for cell: ImagesListCell) {
    let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
    let gradient = CAGradientLayer()
    gradient.frame = view.bounds
    gradient.colors = [UIColor.white.cgColor, UIColor.black.cgColor]
    view.layer.insertSublayer(gradient, at: 0)
  }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return photosName.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
    
    guard let imageListCell = cell as? ImagesListCell else {
      return UITableViewCell()
    }
    
    configCell(for: imageListCell, with: indexPath)
    
    return imageListCell
  }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    let singleImageVC = SingleImageViewController()
    
    singleImageVC.image = UIImage(named: photosName[indexPath.row])
    
    singleImageVC.modalPresentationStyle = .fullScreen
    present(singleImageVC, animated: true)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    guard let image = UIImage(named: "\(indexPath.row)") else { return 200 }
    let imageWidth = Double(image.size.width)
    let imageHeight = Double(image.size.height)
    let viewWidth = Double(tableView.frame.size.width) - (16 * 2)
    let viewHeight = (viewWidth / imageWidth) * imageHeight
    
    return CGFloat(viewHeight)
  }
}
