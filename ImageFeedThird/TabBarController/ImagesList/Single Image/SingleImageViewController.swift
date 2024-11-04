import UIKit

// MARK: - SingleImageViewController

final class SingleImageViewController: UIViewController {
  
  // MARK: - Properties
  
  var image: UIImage? {
    didSet {
      guard
        isViewLoaded,
        let image
      else { return }
      
      imageView?.image = image
      imageView?.frame.size = image.size
      rescaleImage()
      centerImage()
    }
  }
  
  // MARK: - Outlets
  
  @IBOutlet private weak var imageView: UIImageView!
  
  @IBOutlet private weak var backButton: UIButton!
  
  @IBOutlet private weak var scrollView: UIScrollView!
  
  @IBOutlet private weak var shareButton: UIButton!
  
  // MARK: - Actions
  
  @IBAction private func backButtonDidTap() {
    dismiss(animated: true)
  }
  
  @IBAction func shareButtonDidTap() {
    let itemToShare = imageView.image
    let activityController = UIActivityViewController(activityItems: [itemToShare as Any], applicationActivities: nil)
    present(activityController, animated: true)
  }
  
  
  // MARK: - View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    prepareUI()
  }
  
  // MARK: - UI Setup
  
  private func prepareUI() {
    imageView.image = image
    backButton.setImage(UIImage(named: "BackButton"), for: .normal)
    backButton.setTitle("", for: .normal)
    shareButton.layer.cornerRadius = shareButton.frame.width / 2
    prepareScrollView()
  }
  
  private func prepareScrollView() {
    scrollView.minimumZoomScale = 0.1
    scrollView.maximumZoomScale = 1.25
    scrollView.delegate = self
    rescaleImage()
    centerImage()
  }
  
  // MARK: - Image Scaling
  
  private func rescaleImage() {
    guard let image = imageView.image else { return }
    let hScale = view.bounds.width / image.size.width
    let vScale = view.bounds.height / image.size.height
    print("\(view.bounds.width) / \(image.size.width)")
    print("\(view.bounds.height) / (\(image.size.height)")
    
    let minZoomScale = scrollView.minimumZoomScale
    let maxZoomScale = scrollView.maximumZoomScale
    
    let theoreticalZoomScale = min(hScale, vScale)
    let scale = min(maxZoomScale, max(minZoomScale, theoreticalZoomScale))
    print(scale)
    
    scrollView.setZoomScale(scale, animated: false)
    scrollView.layoutIfNeeded()
  }
  
  private func centerImage() {
    guard let imageView = imageView else { return }
    let scrollViewSize = scrollView.bounds.size
    let imageSize = imageView.frame.size
    
    let horizontalInset = max(0, (scrollViewSize.width - imageSize.width) / 2)
    let verticalInset = max(0, (scrollViewSize.height - imageSize.height) / 2)
    
    scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
  }
}

// MARK: - UIScrollViewDelegate

extension SingleImageViewController: UIScrollViewDelegate {
  
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    imageView
  }
  
  func scrollViewDidZoom(_ scrollView: UIScrollView) {
    centerImage()
  }
  
  func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
    centerImage()
  }
}
