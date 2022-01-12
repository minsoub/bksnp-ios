//
//  ImagePickerProtocol.swift
//  bksnpios
//
//  Created by hist on 2022/01/12.
//

import UIKit

protocol ImagePickerProtocol {
    var lastPreparedImage: UIImage? { get }

    func startImagePicker(withSourceType sourceType: UIImagePickerController.SourceType,
                          completion: ((UIImage) -> Void)?)
}
