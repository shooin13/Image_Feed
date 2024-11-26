import UIKit

// MARK: - SingleImageViewController

final class SingleImageViewController: UIViewController {
  
  // MARK: - Properties
  
  var image: UIImage? {
    didSet {
      guard isViewLoaded, let image = image else { return }
      imageView.image = image
      imageView.frame.size = image.size
      rescaleImage()
      centerImage()
    }
  }
  
  // MARK: - UI Elements
  
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  private let backButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(named: "BackButtonLight"), for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  private let scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.minimumZoomScale = 0.1
    scrollView.maximumZoomScale = 1.25
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    return scrollView
  }()
  
  private let shareButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(named: "ShareButton"), for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  // MARK: - View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    setupConstraints()
    prepareScrollView()
    
    // Добавляем действия для кнопок
    backButton.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
    shareButton.addTarget(self, action: #selector(shareButtonDidTap), for: .touchUpInside)
    
    // Устанавливаем изображение, если оно уже было назначено
    if let image = image {
      imageView.image = image
      imageView.frame.size = image.size
      rescaleImage()
      centerImage()
    }
  }
  
  // MARK: - Setup Methods
  
  private func setupViews() {
    view.backgroundColor = .black
    view.addSubview(scrollView)
    view.addSubview(backButton)
    view.addSubview(shareButton)
    scrollView.addSubview(imageView)
  }
  
  private func setupConstraints() {
    NSLayoutConstraint.activate([
      // Scroll View Constraints
      scrollView.topAnchor.constraint(equalTo: view.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      // Back Button Constraints
      backButton.widthAnchor.constraint(equalToConstant: 44),
      backButton.heightAnchor.constraint(equalTo: backButton.widthAnchor),
      backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
      backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
      
      // Share Button Constraints
      shareButton.widthAnchor.constraint(equalToConstant: 44),
      shareButton.heightAnchor.constraint(equalTo: shareButton.widthAnchor),
      shareButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
      shareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30)
    ])
  }
  
  private func prepareScrollView() {
    scrollView.delegate = self
    rescaleImage()
    centerImage()
  }
  
  // MARK: - Actions
  
  @objc private func backButtonDidTap() {
    dismiss(animated: true)
  }
  
  @objc private func shareButtonDidTap() {
    guard let imageToShare = imageView.image else { return }
    let activityController = UIActivityViewController(activityItems: [imageToShare], applicationActivities: nil)
    present(activityController, animated: true)
  }
  
  // MARK: - Image Scaling
  
  private func rescaleImage() {
    guard let image = imageView.image else { return }
    let hScale = view.bounds.width / image.size.width
    let vScale = view.bounds.height / image.size.height
    
    let minZoomScale = scrollView.minimumZoomScale
    let maxZoomScale = scrollView.maximumZoomScale
    
    let theoreticalZoomScale = min(hScale, vScale)
    let scale = min(maxZoomScale, max(minZoomScale, theoreticalZoomScale))
    
    scrollView.setZoomScale(scale, animated: false)
    scrollView.layoutIfNeeded()
  }
  
  private func centerImage() {
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
}
