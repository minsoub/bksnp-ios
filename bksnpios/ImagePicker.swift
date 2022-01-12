import UIKit

class ImagePicker: NSObject, ImagePickerProtocol {

    private lazy var imagePicker: UIImagePickerController = {
            let pickerView = UIImagePickerController()
            pickerView.delegate = self
            
            return pickerView
        }()
    
    private let parentViewController: UIViewController

    private var onPreparedImageCallback: ((UIImage) -> Void)?

    var lastPreparedImage: UIImage?

    init(parentViewController: UIViewController) {
        self.parentViewController = parentViewController
    }

    func startImagePicker(withSourceType sourceType: UIImagePickerController.SourceType,
                          completion: ((UIImage) -> Void)?) {
        onPreparedImageCallback = completion
        imagePicker.sourceType = sourceType
        parentViewController.present(imagePicker, animated: true, completion: nil)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension ImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }

        picker.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }

            self.onPreparedImageCallback?(image)
            self.lastPreparedImage = image
        }
    }
}
