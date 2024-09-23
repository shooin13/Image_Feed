import UIKit

class ImagesListViewController: UIViewController {
  
  @IBOutlet private var tableView: UITableView!
  
  private let photosName: [String] = Array(0..<20).map{"\($0)"}
  
  private let showSingleImageIndentifier = "ShowSingleImage"
  
  private lazy var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .none
    return formatter
  }()
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == showSingleImageIndentifier {
      guard
        let viewController = segue.destination as? SingleImageViewController,
        let indexPath = sender as? IndexPath
      else {
        assertionFailure("Invalid segue identifier or indexPath")
        return
      }
      
      let image = UIImage(named: "\(photosName[indexPath.row])")
      _ = viewController.view // CRASH FIXED !?
      viewController.image = image
    } else {
      super.prepare(for: segue, sender: sender)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.rowHeight = 200
    tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
  }
}

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

extension ImagesListViewController {
  func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
    guard let image = UIImage(named: "\(indexPath.row)") else { return }
    cell.cellImage.image = image
    configureGradient(for: cell)
    cell.cellLabel.text = dateFormatter.string(from: Date())
    cell.cellButton.setTitle("", for: .normal)
    let isLiked = indexPath.row % 2 == 0
    let likeImage = isLiked ? UIImage(named: "LikeOn") : UIImage(named: "LikeOff")
    cell.cellButton.setImage(likeImage, for: .normal)
    
    configureGradient(for: cell)
  }
  
  func configureGradient(for cell: ImagesListCell) {
    let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
    let gradient = CAGradientLayer()
    
    gradient.frame = view.bounds
    gradient.colors = [UIColor.white.cgColor, UIColor.black.cgColor]
    
    view.layer.insertSublayer(gradient, at: 0)
  }
}

extension ImagesListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: showSingleImageIndentifier, sender: indexPath)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let imageWidth = Double((UIImage(named: "\(indexPath.row)")?.size.width)!)
    let imageHeight = Double((UIImage(named: "\(indexPath.row)")?.size.height)!)
    let viewWidth = Double(tableView.frame.size.width) - (16 * 2)
    let viewHeight = (viewWidth / imageWidth) * imageHeight
    
    return viewHeight
  }
}
