import UIKit
import Kingfisher
import ProgressHUD

// MARK: - SingleImageViewController

final class SingleImageViewController: UIViewController {
  // MARK: - Properties
  
  var imageURL: URL? {
    didSet {
      guard isViewLoaded else { return }
      loadImage()
    }
  }
  
  // MARK: - UI Elements
  
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  private let stubImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "Stub")
    imageView.contentMode = .scaleAspectFit
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  private let backButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(named: "BackButtonLight"), for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.accessibilityIdentifier = "nav back button white"
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
    
    backButton.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
    shareButton.addTarget(self, action: #selector(shareButtonDidTap), for: .touchUpInside)
    
    if let _ = imageURL {
      loadImage()
    }
  }
  
  // MARK: - Setup Methods
  
  private func setupViews() {
    view.backgroundColor = .black
    view.addSubview(scrollView)
    view.addSubview(stubImageView)
    view.addSubview(backButton)
    view.addSubview(shareButton)
    scrollView.addSubview(imageView)
  }
  
  private func setupConstraints() {
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: view.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      stubImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      stubImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      stubImageView.widthAnchor.constraint(equalToConstant: 83),
      stubImageView.heightAnchor.constraint(equalToConstant: 75),
      
      backButton.widthAnchor.constraint(equalToConstant: 44),
      backButton.heightAnchor.constraint(equalTo: backButton.widthAnchor),
      backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
      backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
      
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
  
  // MARK: - Load Image
  
  private func loadImage() {
    guard let url = imageURL else { return }
    
    UIBlockingProgressHUD.show()
    stubImageView.isHidden = false // Show stub image while loading
    
    imageView.kf.setImage(
      with: url,
      options: [.transition(.fade(0.3))]
    ) { [weak self] result in
      UIBlockingProgressHUD.dismiss()
      guard let self = self else { return }
      
      self.stubImageView.isHidden = true // Hide stub image when loading finishes
      
      switch result {
      case .success:
        self.rescaleImage()
        self.centerImage()
      case .failure(let error):
        print("Ошибка загрузки изображения: \(error.localizedDescription)")
      }
    }
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
